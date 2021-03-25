# ConfigEnv

|                                                                                                  **Documentation**                                                                                                  |                                                                                                                          **Build Status**                                                                                                                          |
|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
| [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://Arkoniak.github.io/ConfigEnv.jl/stable)[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Arkoniak.github.io/ConfigEnv.jl/dev) | [![Build](https://github.com/Arkoniak/ConfigEnv.jl/workflows/CI/badge.svg)](https://github.com/Arkoniak/ConfigEnv.jl/actions)[![Coverage](https://codecov.io/gh/Arkoniak/ConfigEnv.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Arkoniak/ConfigEnv.jl) |

`ConfigEnv.jl` is an environment configuration package that loads environment variables from a `.env` file into [`ENV`](https://docs.julialang.org/en/latest/manual/environment-variables/) in the same manner as [python-dotenv](https://github.com/theskumar/python-dotenv) library.

## Installation

```julia
Pkg.add("ConfigEnv")
```

## Usage
Create a `.env` file in your project. You can add environment-specific variables using the rule `NAME=VALUE`.
For example:

```dosini
#.env file
DB_HOST=127.0.0.1
DB_USER=john
DB_PASS=42
```

After that you can use it in your application

```julia
using ConfigEnv

dotenv() # loads environment variables from .env
```

In this way, `ENV` obtain both, the keys and the values you set in your `.env` file.

```julia
ENV["DB_PASS"]
"42"
```

## Configuration

Main command is `dotenv` which reads your .env file, parse the content, stores it to 
[`ENV`](https://docs.julialang.org/en/latest/manual/environment-variables/),
and finally return a `EnvProxyDict` with the content.  

```julia
import ConfigEnv

cfg = dotenv()

println(cfg)
```

`EnvProxyDict` acts as a proxy to `ENV` dictionary, if `key` is not found in `EnvProxyDict` it will try to return value from `ENV`.

### Options

#### Path

Default: `.env`

You can specify a custom path for your `.env` file.

```julia
using ConfigEnv

dotenv(path = "custom.env")
```

## Manual Parsing

`ConfigEnv.parse` accepts a `String` or an `IOBuffer`, and it will return a `Dict` with the parsed keys and values.

```julia
import ConfigEnv

buff = IOBuffer("BASIC=basic")
cfg = ConfigEnv.parse(buff) # will return a Dict
println(cfg) # Dict("BASIC"=>"basic")
```

### Rules

You can write your `.env` file using the following rules:

- `BASIC=basic` becomes `Dict("BASIC"=>"basic")`
- empty lines are skipped
- `#` are comments
- empty content is treated as an empty string (`EMPTY=` -> `Dict("EMPTY"=>"")`)
- external single and double quotes are removed (`SINGLE_QUOTE='quoted'` -> `Dict("SINGLE_QUOTE"=>"quoted")`)
- inside double quotes, new lines are expanded (`MULTILINE="new\nline"` ->
```
Dict("MULTILINE"=>"new
line")
```
- inner quotes are maintained (like JSON) (`JSON={"foo": "bar"}` -> `Dict("JSON"=>"{\"foo\": \"bar\"}")"`)
- extra spaces are removed from both ends of the value (`FOO="  some value  "` -> `Dict("FOO"=>"some value")`)

- previous `ENV` environment variables are replaced. If you want to keep original version of `ENV` use:

```julia
using ConfigEnv

cfg = dotenv(override = false)
```
