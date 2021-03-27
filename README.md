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

#### Paths

By default `dotenv` use local `.env` file, but you can specify a custom path for your `.env` file.

```julia
using ConfigEnv

dotenv("custom.env") # Loads `custom.env` file
```

You can supply more than one configuration file

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
if duplicate keys encountered, then values from the rightmost dictionary is used.

Take note that `dotenv` function replace previous `ENV` environment variables by default. If you want to keep original version of `ENV` you should use `overwrite` argument

```julia
using ConfigEnv

ENV["FOO"] = "BAR"
cfg = dotenv(overwrite = false)

cfg["FOO"] # "BAZ"
ENV["FOO"] # "BAR"
```

Since many dotenv packages uses another default setting when environment is not overwritten, function `dotenvx` was introduced. This function is just an alias to `dotenv(overwrite = false)`, but it can be more convenient to use.

```julia
using ConfigEnv

ENV["FOO"] = "BAR"
cfg = dotenvx() # Same as `dotenv(overwrite = false)`

cfg["FOO"] # "BAZ"
ENV["FOO"] # "BAR"
```

### Rules

You can write your `.env` file using the following rules:

- `FOO = BAR` becomes `ENV["FOO"] = "BAR"`
- empty lines are skipped
- `#` are comments
- empty content is treated as an empty string, i.e. `EMPTY=` becomes `ENV["EMPTY"] = ""`
- external single and double quotes are removed, i.e. `SINGLE_QUOTE='quoted'` becomes `ENV["SINGLE_QUOTE"] = "quoted"`
- inside double quotes, new lines are expanded, i.e.
  ```
  MULTILINE = "new
  line"
  ```
  becomes `ENV["MULTILINE"] = "new\nline"`
- inner quotes are automatically escaped, i.e. `JSON={"foo": "bar"}` becomes `ENV["JSON"] = "{\"foo\": \"bar\"}"`
- extra spaces are removed from both ends of the value, i.e. `FOO="  some value  "` becomes `ENV["FOO"] = "some value"`
