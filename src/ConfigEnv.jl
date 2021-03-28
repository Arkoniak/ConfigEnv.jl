module ConfigEnv

import Base: getindex, get, isempty, merge, merge!, haskey

export dotenv, dotenvx

struct EnvProxyDict
    dict::Dict{String, String}
end

getindex(ed::EnvProxyDict, key) = get(ed.dict, key, ENV[key])
get(ed::EnvProxyDict, key, default) = get(ed.dict, key, get(ENV, key, default))
isempty(ed::EnvProxyDict) = isempty(ed.dict)
merge(epd1::EnvProxyDict, epd2::EnvProxyDict...) = EnvProxyDict(foldl((x, y) -> merge(x, y.dict), epd2; init = epd1.dict))
haskey(ed::EnvProxyDict, key) = haskey(ed.dict, key) || haskey(ENV, key)

function merge!(epd1::EnvProxyDict, epd2::EnvProxyDict...)
    foldl((x, y) -> merge!(x, y.dict), epd2; init = epd1.dict)
    epd1
end

Base.:*(epd1::EnvProxyDict, epd2::EnvProxyDict...) = EnvProxyDict(foldl((x, y) -> merge(x, y.dict), epd2; init = epd1.dict))

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
function dotenv(path = ".env"; overwrite = true)
    parsed = if (validatefile(path))
        parse(read(path, String))
    else
        parse(path)
    end

    for (k, v) in parsed
        if !haskey(ENV, k) || overwrite
            ENV[k] = v
        end
    end

    return EnvProxyDict(parsed)
end

dotenv(paths...; overwrite = true) = merge!(dotenv.(paths; overwrite = overwrite)...)

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
dotenvx(paths...; overwrite = false) = dotenv(paths...; overwrite = overwrite)

end
