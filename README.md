# DotEnv2.jl

|                                                                                                **Documentation**                                                                                                |                                                                                                                                        **Build Status**                                                                                                                                        |
|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
| [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://Arkoniak.github.io/DotEnv2.jl/stable)[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Arkoniak.github.io/DotEnv2.jl/dev) |                   [![Build](https://github.com/Arkoniak/DotEnv2.jl/workflows/CI/badge.svg)](https://github.com/Arkoniak/DotEnv2.jl/actions)[![Coverage](https://codecov.io/gh/Arkoniak/DotEnv2.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Arkoniak/DotEnv2.jl)                   |

This package is a fork of [DotEnv.jl](https://github.com/vmari/DotEnv.jl).

DotEnv2.jl is a zero-dependency package that loads environment variables from a `.env` file into [`ENV`](https://docs.julialang.org/en/latest/manual/environment-variables/). Storing configuration in the environment is based on [The Twelve-Factor App](http://12factor.net/config) methodology.

## Install

```julia
Pkg.add("DotEnv2")
```

## Usage

```julia
using DotEnv2
DotEnv2.config()
```

Create a `.env` file in your project. You can add environment-specific variables using the rule `NAME=VALUE`.
For example:

```dosini
#.env file
DB_HOST=127.0.0.1
DB_USER=john
DB_PASS=42
```

In this way, `ENV` obtain both, the keys and the values you set in your `.env` file.

```julia
ENV["DB_PASS"]
"42"
```

## Config

`config` reads your .env file, parse the content, stores it to 
[`ENV`](https://docs.julialang.org/en/latest/manual/environment-variables/),
and finally return a `EnvProxyDict` with the content.  

```julia
import DotEnv2

cfg = DotEnv2.config()

println(cfg)
```

### Options

#### Path

Default: `.env`

You can specify a custom path for your .env file.

```julia
using DotEnv2
DotEnv2.config(path = "custom.env")
```

## Manual Parsing

`DotEnv.parse` accepts a String or an IOBuffer (Any value that can be converted into String), and it will return
a Dict with the parsed keys and values.

```julia
import DotEnv2

buff = IOBuffer("BASIC=basic")
cfg = DotEnv2.parse(buff) # will return a Dict
println(config) # Dict("BASIC"=>"basic")
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
using DotEnv2

cfg = DotEnv2.config(".env.override", override = false)
```

## Note about credits and License

We want to thank @motdotla. Our code is mostly based on [his repo](https://github.com/motdotla/dotenv)

We want to thank @vmari for the original code of the [DotEnv.jl](https://github.com/vmari/DotEnv.jl). Original license can be found [here](https://github.com/vmari/DotEnv.jl/blob/master/LICENSE.md)
