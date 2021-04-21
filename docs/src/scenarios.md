```@meta
CurrentModule = ConfigEnv
```

# Examples

In this section you can find different scenarios of various complexity, which shows how to utilize features of `ConfigEnv.jl`.

## Simple ENV manipulations

If the package that you are using provides support for environmental variables, than all you have to do is write proper `.env` and populate `ENV` with `dotenv` function.

For example, here is how one can setup and use `Telegram.jl` functions

Configure `.env`
```
# .env
TELEGRAM_BOT_TOKEN = <YOUR TELEGRAM BOT TOKEN>
TELEGRAM_BOT_CHAT_ID = <YOUR TELEGRAM CHAT ID>
```

and use it in an application
```julia
using Telegram, Telegram.API
using ConfigEnv

dotenv()

sendMessage(text = "Hello, world!") # uses TELEGRAM_BOT_TOKEN and TELEGRAM_BOT_CHAT_ID
```

## Multifile configuration
One can use merge feature to factor out repeating parts of environment configuration. For example, one can use the following file file structure

```
/
  .root_env
  dir1/
    .env
    file1.jl
  dir2/
    .env
    file2.jl
```

In this case `.root_env` can contain
```
HOST = localhost
PORT = 1234
```

and `.env` in `dir1` can be
```
USER = FOO
PASSWORD = BAR
```

Then `file1.jl` can use the following construction
```julia
using ConfigEnv

dotenv(".env", "../.root_env")
```

As a result, all four variables are set in the environment. By using different user/password in `.env` of `dir2` one can obtain directory dependent environments without repeating `HOST` and `PORT` values.

## Templating configuration

Expanding on the previous example, imagine that you have different user/password pairs for production and testing environments. Than you can organise your `.env` files as follows

```
# .root_env
USER_PRODUCTION = FOO
USER_TEST = TEST

PASSWORD_PRODUCTION = BAR
PASSWORD_TEST = 123

USER = ${USER_${ENVIR}}
PASSWORD = ${PASSWORD_${ENVIR}}
```

```
# dir1/.env
ENVIR = PRODUCTION
```
Then in your `file1.jl` you can get the following
```julia
using ConfigEnv

dotenv("../.root_env", ".env")

ENV["USER"]     # FOO
ENV["PASSWORD"] # BAR
```

So variables `USER` and `PASWORD` will be set according to the value of `ENVIR`.

## Using `IO` objects

One can even go further and use templates together with `IO` objects to dynamically update application configuration. For example, if application looks like
```
/
  .env
  app.jl
```

with `.env` similar to the previous example
```
USER_PRODUCTION = FOO
USER_TEST = TEST

PASSWORD_PRODUCTION = BAR
PASSWORD_TEST = 123

USER = ${USER_${ENVIR}}
PASSWORD = ${PASSWORD_${ENVIR}}
```

and there is a `.env`
```
ENVIR = PRODUCTION
```
located on some server in local network, then one can use the following construction in `app.jl`

```julia
using ConfigEnv
using HTTP

dotenv(IOBuffer(HTTP.get("http://127.0.0.1/.env").body), ".env")

ENV["USER"]     # FOO
ENV["PASSWORD"] # BAR
```

So it is possible to change application mode from `production` to `test`, just by changing value of the `.env` file on server.
