```@meta
CurrentModule = ConfigEnv
```

# ConfigEnv
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

```@index
```

```@autodocs
Modules = [ConfigEnv]
```
