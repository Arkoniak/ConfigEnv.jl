```@meta
CurrentModule = ConfigEnv
```

# ConfigEnv
`ConfigEnv.jl` is an environment configuration package that loads environment variables from a `.env` file into [`ENV`](https://docs.julialang.org/en/latest/manual/environment-variables/). This package was inspired by [python-dotenv](https://github.com/theskumar/python-dotenv) library and [the Twelve-Factor App](https://12factor.net/config) methodology.

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

```@index
```

```@autodocs
Modules = [ConfigEnv]
```
