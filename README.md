# ConfigEnv

|                                                                                                  **Documentation**                                                                                                  |                                                                                                                          **Build Status**                                                                                                                          |                                                                                                          **JuliaHub**                                                                                                          |
|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
| [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://Arkoniak.github.io/ConfigEnv.jl/stable)[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Arkoniak.github.io/ConfigEnv.jl/dev) | [![Build](https://github.com/Arkoniak/ConfigEnv.jl/workflows/CI/badge.svg)](https://github.com/Arkoniak/ConfigEnv.jl/actions)[![Coverage](https://codecov.io/gh/Arkoniak/ConfigEnv.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Arkoniak/ConfigEnv.jl) | [![pkgeval](https://juliahub.com/docs/ConfigEnv/pkgeval.svg)](https://juliahub.com/ui/Packages/ConfigEnv/y83nC)[![version](https://juliahub.com/docs/ConfigEnv/version.svg)](https://juliahub.com/ui/Packages/ConfigEnv/y83nC) |

`ConfigEnv.jl` is an environment configuration package that loads environment variables from a `.env` file into [`ENV`](https://docs.julialang.org/en/latest/manual/environment-variables/). This package was inspired by [python-dotenv](https://github.com/theskumar/python-dotenv) library and [the Twelve-Factor App](https://12factor.net/config) methodology.

It's intended usage is when you have some secrets like database passwords, which shouldn't leak into public space and at the same time you want to have simple and flexible management of such secrets. Another usage possibility is when some library uses environmental variables for configuration and you want to configure them without editing your `.bashrc` or Windows environment.

## Installation

`ConfigEnv.jl` is a registered package, so it can be installed with

```julia
julia> using Pkg; Pkg.add("ConfigEnv")
```

or

```julia
# switch to pkg mode
julia> ] 
v1.6> add ConfigEnv
```

## Usage
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

## Features

`ConfigEnv.jl` provides following features in order to make environment configuration more flexible

- load data from configuration files to `ENV` in overwriting and non overwriting mode;
- reading data from `String` and `IO` objects;
- merging data from different configuration files;
- templating variables with an arbitrary templating depth and introspection tools for discovering unresolved templates and circular dependencies.
