module ConfigEnv

import Base: getindex, get, isempty, merge, merge!, haskey

export dotenv, dotenvx, isresolved, unresolved_keys

struct EnvProxyDict{T}
    dict::Dict{String, String}
    env::T
    undefined::Vector{String}
    circular::Vector{String}
end
EnvProxyDict(dict) = EnvProxyDict(dict, ENV, String[], String[])
EnvProxyDict(dict, env) = EnvProxyDict(dict, env, String[], String[])

getindex(ed::EnvProxyDict, key) = get(ed.dict, key, ed.env[key])
get(ed::EnvProxyDict, key, default) = get(ed.dict, key, get(ed.env, key, default))
isempty(ed::EnvProxyDict) = isempty(ed.dict)
Base.:*(epd1::EnvProxyDict, epd2::EnvProxyDict...) = merge(epd1, epd2...; overwrite = false)
function imprint(epd::EnvProxyDict, env)
    for (k, v) in epd.dict
        env[k] = v
    end
end

function merge(epd1::EnvProxyDict, epd2::EnvProxyDict...; overwrite = true) 
    epd = EnvProxyDict(foldl((x, y) -> merge(x, y.dict), epd2; init = epd1.dict), epd1.env)
    resolve!(epd, epd.env)
    overwrite && imprint(epd, epd.env)
    epd
end

haskey(ed::EnvProxyDict, key) = haskey(ed.dict, key) || haskey(ed.env, key)

function merge!(epd1::EnvProxyDict, epd2::EnvProxyDict...; overwrite = true)
    foldl((x, y) -> merge!(x, y.dict), epd2; init = epd1.dict)
    # You shouldn't use different envs during `merge!`. This is undefined behaviour.
    # first dictionary environment can't be changed, cause it can be `ENV`
    resolve!(epd1, epd1.env)
    overwrite && imprint(epd1, epd1.env)
    return epd1
end

function isdefin(s, i = 0, lev = 0)
    i = nextind(s, i)
    len = ncodeunits(s)
    mode = 0
    cnt_brackets = 0
    while i <= len
        c = s[i]
        if c == '$'
            mode = 1
        elseif c == '{'
            if mode == 1
                return isdefin(s, i, 1)
            else
                cnt_brackets += 1
                mode = 0
            end
        elseif c == '}'
            mode = 0
            cnt_brackets -= 1
            lev == 1 && cnt_brackets < 0 && return false
        else
            mode = 0
        end
        i = nextind(s, i)
    end

    return true
end

mutable struct KVNode
    key::String
    value::String
    children::Vector{KVNode}
    parents_cnt::Int
    isfinal::Bool
    isresolved::Bool
end

KVNode(k, v) = KVNode(k, v, KVNode[], 0, true, false)
KVNode(v) = KVNode("", v, KVNode[], 0, false, false)
isresolved(kvnode::KVNode) = kvnode.isresolved
isresolved(epd::EnvProxyDict) = isempty(epd.undefined) && isempty(epd.circular)

function unresolved_keys(edp::EnvProxyDict)
    undefined = map(k -> k => edp.dict[k], edp.undefined)
    circular = map(k -> k => edp.dict[k], edp.circular)

    return (; circular = circular, undefined = undefined)
end

function destructure!(v::KVNode, stack, knodes, i = 0, env = ENV)
    val = v.value
    len = ncodeunits(val)
    i0 = nextind(val, i)
    i = i0
    bracket_count = 0
    mode = 0 # everything is normal
    isvalid = v.isfinal ? true : false

    while i <= len
        c = val[i]
        if c == '$'
            mode = 1 # waiting for the opening {
        elseif c == '{'
            if mode == 1
                node = KVNode(val)
                push!(node.children, v)
                i, valid = destructure!(node, stack, knodes, i, env) # should return index of the closing bracket }
                if valid
                    v.parents_cnt += 1
                    isvalid = true
                end
            else
                bracket_count += 1
            end
            mode = 0 # calm down
        elseif c == '}' # we should produce some reasonable result if this is our closing bracket
            bracket_count -= 1
            mode = 0
            if !v.isfinal
                bracket_count >= 0 && continue # false alarm
                if v.parents_cnt == 0 # we are key node
                    v.key = v.value[i0:i-1]
                    if haskey(knodes, v.key)
                        append!(knodes[v.key].children, v.children)
                        empty!(v.children)
                    elseif haskey(env, v.key)
                        v.value = env[v.key]
                        push!(stack, v)
                    else
                        # Unknown key
                        v.value = v.value[i0-2:i]
                        push!(stack, v)
                    end
                else # we are intermidiate node
                    v.value = v.value[i0:i-1]
                end
                return i, true
            end
        else
            mode = 0
        end
    
        if i <= len 
            i = nextind(val, i)
        end
    end
    return i, isvalid
end

function resolve!(edp::EnvProxyDict, env = ENV)
    knodes = Dict{String, KVNode}()
    for (k, v) in edp.dict
        knodes[k] = KVNode(k, v)
    end
    stack = KVNode[]
    
    prepare_stack!(stack, knodes, env)

    resolve!(stack, knodes, env)

    empty!(edp.undefined)
    empty!(edp.circular)
    for (k, v) in knodes
        edp.dict[k] = v.value
        if !v.isresolved
            push!(edp.circular, k)
        elseif !isdefin(v.value)
            push!(edp.undefined, k)
        end
    end

    edp
end

function prepare_stack!(stack, knodes, env)
    for v in values(knodes)
        # we extract interpolated terms from the value and last tier should be put on 
        # the stack for further imprinting
        destructure!(v, stack, knodes, 0, env)
    end

    for v in values(knodes)
        # if we do not have anything to interpolate inside the value, we are good. 
        # If we still have some other value where node should be used for interpolation,
        # we put node on the interpolation stack
        if v.parents_cnt == 0
            v.isresolved = true
            if !isempty(v.children)
                push!(stack, v)
            end
        end
    end
end

function recursive_replace!(node, key, val)
    occursin(key, node.value) || return
    node.value = replace(node.value, key => val)
    foreach(x -> recursive_replace!(x, key, val), node.children)
    nothing
end

function resolve!(stack, knodes, env)
    while !isempty(stack)
        v = pop!(stack)
        key = "\${" * v.key * "}"
        while !isempty(v.children)
            kid = pop!(v.children)
            recursive_replace!(kid, key, v.value)
            kid.parents_cnt -= 1
            kid.parents_cnt == 0 || continue
            if kid.isfinal
                kid.isresolved = true
            else
                kid.key = kid.value
                if haskey(knodes, kid.key)
                    append!(knodes[kid.key].children, kid.children)
                    empty!(kid.children)
                    if !isempty(knodes[kid.key].children) && knodes[kid.key].parents_cnt == 0
                        push!(stack, knodes[kid.key])
                    end
                elseif haskey(env, kid.key)
                    kid.value = env[kid.key]
                else
                    kid.value = "\${" * kid.key * "}"
                end
            end
            if !isempty(kid.children)
                push!(stack, kid)
            end
        end
    end
end

"""
`ConfigEnv.parse` accepts a String or an IOBuffer (any value that
 can be converted into String), and returns a Dict with
 the parsed keys and values.
"""
function parse(src)
    res = Dict{String,String}()
    src = IOBuffer(src)
    for line in eachline(src)
        m = match(r"^\s*([\w.-]+)\s*=\s*(.*)?\s*$", line)
        if m !== nothing
            key = m.captures[1]
            value = string(m.captures[2])

            if (length(value) > 0 && value[1] === '"' && value[end] === '"')
                value = replace(value, r"\\n"m => "\n")
            end

            value = replace(value, r"(^['\u0022]|['\u0022]$)" => "")

            value = strip(value)

            push!(res, key => value)
        end
    end
    res
end

parse(src::IO) = parse(String(take!(src)))

########################################
# Main part
########################################

validatefile(s) = false
validatefile(s::AbstractString) = isfile(s)

"""
    dotenv(path1, path2, ...; overwrite = true)

`dotenv` reads .env files from your `path`, parse their content, merge them together, stores result to `ENV`,
and finally return a `EnvProxyDict` with the content. If no `path` argument is given , then 
`.env` is used as a default path. During merge procedure, if duplicate keys encountered
then value from the rightmost dictionary is used.

By default if key already exists in `ENV` it is overwritten with the values in .env file. 
This behaviour can be changed by setting `overwrite` flag to `false` or using dual `dotenvx` function.

Examples
========
```
# .env
FOO = bar
USER = john_doe

# julia REPL
# load key-value pairs from ".env", `ENV` duplicate keys are overwritten
julia> ENV["USER"]
user1
julia> cfg = dotenv()
julia> ENV["FOO"]
bar
julia> ENV["USER"]
john_doe
julia> cfg["USER"]
john_doe
```
"""
function dotenv(path = ".env"; overwrite = true, env = ENV)
    parsed = if (validatefile(path))
        parse(read(path, String))
    else
        parse(path)
    end

    epd = EnvProxyDict(parsed, env)
    resolve!(epd, env)

    for (k, v) in epd.dict
        if !haskey(env, k) || overwrite
            env[k] = v
        end
    end

    return epd
end

dotenv(paths...; overwrite = true, env = ENV) = merge!(dotenv.(paths; overwrite = overwrite, env = env)..., overwrite = overwrite)

"""
    dotenvx(path1, path2, ...; overwrite = false)

`dotenvx` reads .env files from your `path`, parse their content, merge them together, stores result to `ENV`,
and finally return a `EnvProxyDict` with the content. If no `path` argument is given , then 
`.env` is used as a default path. During merge procedure, if duplicate keys encountered
then value from the rightmost dictionary is used.

By default if key already exists in `ENV` it is overwritten with the values in .env file. 
This behaviour can be changed by setting `overwrite` flag to `true` or using dual `dotenv` function.

Examples
========
```
# .env
FOO = bar
USER = john_doe

# julia REPL
# load key-value pairs from ".env", `ENV` duplicate keys are not overwritten
julia> ENV["USER"]
user1
julia> cfg = dotenvx()
julia> ENV["FOO"]
bar
julia> ENV["USER"]
user1
julia> cfg["USER"]
john_doe
```
"""
dotenvx(paths...; overwrite = false, env = ENV) = dotenv(paths...; overwrite = overwrite, env = env)

end
