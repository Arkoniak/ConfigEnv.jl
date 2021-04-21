```@meta
CurrentModule = ConfigEnv
```

# Usage

## Main commands

Create a `.env` file in your project. You can add environment-specific variables using the rule `NAME=VALUE`.
For example:

```
#.env file
USER = foo
PASSWORD = bar
```
Usually it is a good idea to put this file into your `.gitignore` file, so secrets wouldn't leak to the public space. After that you can use it in your application

```julia
using ConfigEnv

dotenv() # loads environment variables from .env
```

This way `ENV` obtains key values pairs you set in your `.env` file.

```julia
julia> ENV["PASSWORD"]
"bar"
```

### `.env` definitions

Following rules are applied when you are writing `.env`:

- `FOO = BAR` becomes `ENV["FOO"] = "BAR"`;
- empty lines are skipped;
- lines starting with `#` are comments and ignored during parsing;
- empty content is treated as an empty string, i.e. `EMPTY=` becomes `ENV["EMPTY"] = ""`;
- external single and double quotes are removed, i.e. `SINGLE_QUOTE='quoted'` becomes `ENV["SINGLE_QUOTE"] = "quoted"`;
- inside double quotes, new lines are expanded, i.e.
  ```
  MULTILINE = "new
  line"
  ```
  becomes `ENV["MULTILINE"] = "new\nline"`;
- inner quotes are automatically escaped, i.e. `JSON={"foo": "bar"}` becomes `ENV["JSON"] = "{\"foo\": \"bar\"}"`;
- extra spaces are removed from both ends of the value, i.e. `FOO="  some value  "` becomes `ENV["FOO"] = "some value"`;

## Configuration

Main command is `dotenv` which reads your .env file, parse the content, stores it to 
[`ENV`](https://docs.julialang.org/en/latest/manual/environment-variables/),
and finally return a `EnvProxyDict`.

```julia
julia> cfg = dotenv()

julia> println(cfg)
ConfigEnv.EnvProxyDict(Dict("FOO" => "BAR"))
```

`EnvProxyDict` acts as a proxy to `ENV` dictionary, if `key` is not found in `EnvProxyDict` it will try to return value from `ENV`.

```julia
julia> ENV["XYZ"] = "ABC"
julia> cfg = dotenv()
julia> println(cfg)
ConfigEnv.EnvProxyDict(Dict("FOO" => "BAR"))
julia> cfg["FOO"]
"BAR"
julia> cfg["XYZ"]
"ABC"
```

By default `dotenv` use local `.env` file, but you can specify a custom path for your `.env` file.

```julia
dotenv("custom.env") # Loads `custom.env` file
```

## Overwriting and nonoverwriting functions

Take note that `dotenv` function replace previous `ENV` environment variables by default. If you want to keep original version of `ENV` you should use `overwrite` argument

```julia
ENV["FOO"] = "BAR"
cfg = dotenv(overwrite = false)

cfg["FOO"] # "BAZ"
ENV["FOO"] # "BAR"
```

Alternatively one can use function `dotenvx`. This function is just an alias to `dotenv(overwrite = false)`, but sometimes it can be more convenient to use.

```julia
ENV["FOO"] = "BAR"
cfg = dotenvx() # Same as `dotenv(overwrite = false)`

cfg["FOO"] # "BAZ"
ENV["FOO"] # "BAR"
```

## Merging multiple environments

You can provide more than one configuration file and all of them will be uploaded to `ENV`.

```julia
dotenv("custom1.env", "custom2.env")
```

Alternatively, you can combine different configuration files together using `merge` function or multiplication sign `*`

```julia
cfg1 = dotenv("custom1.env")
cfg2 = dotenv("custom2.env")

cfg = merge(cfg1, cfg2)

# or equivalently

cfg = cfg1 * cfg2
```
Take note that `merge` not only combines dictionaries together, but also apply resulting dictionary to `ENV`.

if duplicate keys encountered, then values from the rightmost dictionary is used.

## Templating

One can use templates in `.env` files, with the help of `${...}` construction. For example, this file

```
# .env
FOO = ZZZ
BAR = ${FOO}
```
is converted to
```julia
julia> dotenv();
julia> ENV["FOO"]
"ZZZ"

julia> ENV["BAR"]
"ZZZ"
```
Usage of `{}` is mandatory, single `$` is ignored, i.e.

```
# .env
FOO = ZZZ
BAR = $FOO
```

```julia
julia> dotenv();
julia> ENV["FOO"]
"ZZZ"

julia> ENV["BAR"]
"\$FOO"
```

Together with environments merging described in previous paragraph, templating can be very powerful tool to setup your `ENV` in a very flexible way. For example, one can set global parameters in a `.env` located in a root of the application and combine it with individual files located deeper inside the application file tree.

You can diagnose problems like unresolved templates and circular dependencies with `isresolved` and `unresolved_keys`. For example
```
# .env
FOO = ${BAR}
BAR = ${FOO}
ZZZ = ${YYY}
```

```julia
julia> cfg = dotenv();
julia> isresolved(cfg)
false

julia> unresolved_keys(cfg).circular
2-element Vector{Pair{String, String}}:
 "FOO" => "\${BAR}"
 "BAR" => "\${FOO}"

julia> unresolved_keys(cfg).undefined
1-element Vector{Pair{String, String}}:
 "ZZZ" => "\${YYY}"
```

### Nested templates
One can also use nested interpolations of an arbitrary depth to build more complicated environment constructions.

```
# .env
USER_1 = FOO
USER_2 = BAR
N = 1
USER = ${USER_${N}}
```

is translated to the following config

```julia
julia> dotenv();
julia> ENV["USER"]
"FOO"
```

## `IO` streaming

`dotenv` function supports `IO` objects, so one can download configuration from net if needed or read it any other way.

```julia
using ConfigEnv
using HTTP

cfg = HTTP.get("https://raw.githubusercontent.com/Arkoniak/ConfigEnv.jl/master/test/.env") |> x -> IOBuffer(x.body) |> dotenv

cfg["QWERTY"] # "ZXC"
```
