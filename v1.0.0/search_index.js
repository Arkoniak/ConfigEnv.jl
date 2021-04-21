var documenterSearchIndex = {"docs":
[{"location":"usage/","page":"Usage","title":"Usage","text":"CurrentModule = ConfigEnv","category":"page"},{"location":"usage/#Usage","page":"Usage","title":"Usage","text":"","category":"section"},{"location":"usage/#Main-commands","page":"Usage","title":"Main commands","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"Create a .env file in your project. You can add environment-specific variables using the rule NAME=VALUE. For example:","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"#.env file\nUSER = foo\nPASSWORD = bar","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"Usually it is a good idea to put this file into your .gitignore file, so secrets wouldn't leak to the public space. After that you can use it in your application","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"using ConfigEnv\n\ndotenv() # loads environment variables from .env","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"This way ENV obtains key values pairs you set in your .env file.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"julia> ENV[\"PASSWORD\"]\n\"bar\"","category":"page"},{"location":"usage/#.env-definitions","page":"Usage","title":".env definitions","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"Following rules are applied when you are writing .env:","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"FOO = BAR becomes ENV[\"FOO\"] = \"BAR\";\nempty lines are skipped;\nlines starting with # are comments and ignored during parsing;\nempty content is treated as an empty string, i.e. EMPTY= becomes ENV[\"EMPTY\"] = \"\";\nexternal single and double quotes are removed, i.e. SINGLE_QUOTE='quoted' becomes ENV[\"SINGLE_QUOTE\"] = \"quoted\";\ninside double quotes, new lines are expanded, i.e.\nMULTILINE = \"new\nline\"\nbecomes ENV[\"MULTILINE\"] = \"new\\nline\";\ninner quotes are automatically escaped, i.e. JSON={\"foo\": \"bar\"} becomes ENV[\"JSON\"] = \"{\\\"foo\\\": \\\"bar\\\"}\";\nextra spaces are removed from both ends of the value, i.e. FOO=\"  some value  \" becomes ENV[\"FOO\"] = \"some value\";","category":"page"},{"location":"usage/#Configuration","page":"Usage","title":"Configuration","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"Main command is dotenv which reads your .env file, parse the content, stores it to  ENV, and finally return a EnvProxyDict.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"julia> cfg = dotenv()\n\njulia> println(cfg)\nConfigEnv.EnvProxyDict(Dict(\"FOO\" => \"BAR\"))","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"EnvProxyDict acts as a proxy to ENV dictionary, if key is not found in EnvProxyDict it will try to return value from ENV.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"julia> ENV[\"XYZ\"] = \"ABC\"\njulia> cfg = dotenv()\njulia> println(cfg)\nConfigEnv.EnvProxyDict(Dict(\"FOO\" => \"BAR\"))\njulia> cfg[\"FOO\"]\n\"BAR\"\njulia> cfg[\"XYZ\"]\n\"ABC\"","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"By default dotenv use local .env file, but you can specify a custom path for your .env file.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"dotenv(\"custom.env\") # Loads `custom.env` file","category":"page"},{"location":"usage/#Overwriting-and-nonoverwriting-functions","page":"Usage","title":"Overwriting and nonoverwriting functions","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"Take note that dotenv function replace previous ENV environment variables by default. If you want to keep original version of ENV you should use overwrite argument","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"ENV[\"FOO\"] = \"BAR\"\ncfg = dotenv(overwrite = false)\n\ncfg[\"FOO\"] # \"BAZ\"\nENV[\"FOO\"] # \"BAR\"","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"Alternatively one can use function dotenvx. This function is just an alias to dotenv(overwrite = false), but sometimes it can be more convenient to use.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"ENV[\"FOO\"] = \"BAR\"\ncfg = dotenvx() # Same as `dotenv(overwrite = false)`\n\ncfg[\"FOO\"] # \"BAZ\"\nENV[\"FOO\"] # \"BAR\"","category":"page"},{"location":"usage/#Merging-multiple-environments","page":"Usage","title":"Merging multiple environments","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"You can provide more than one configuration file and all of them will be uploaded to ENV.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"dotenv(\"custom1.env\", \"custom2.env\")","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"Alternatively, you can combine different configuration files together using merge function or multiplication sign *","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"cfg1 = dotenv(\"custom1.env\")\ncfg2 = dotenv(\"custom2.env\")\n\ncfg = merge(cfg1, cfg2)\n\n# or equivalently\n\ncfg = cfg1 * cfg2","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"Take note that merge not only combines dictionaries together, but also apply resulting dictionary to ENV.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"if duplicate keys encountered, then values from the rightmost dictionary is used.","category":"page"},{"location":"usage/#Templating","page":"Usage","title":"Templating","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"One can use templates in .env files, with the help of ${...} construction. For example, this file","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"# .env\nFOO = ZZZ\nBAR = ${FOO}","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"is converted to","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"julia> dotenv();\njulia> ENV[\"FOO\"]\n\"ZZZ\"\n\njulia> ENV[\"BAR\"]\n\"ZZZ\"","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"Usage of {} is mandatory, single $ is ignored, i.e.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"# .env\nFOO = ZZZ\nBAR = $FOO","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"julia> dotenv();\njulia> ENV[\"FOO\"]\n\"ZZZ\"\n\njulia> ENV[\"BAR\"]\n\"\\$FOO\"","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"Together with environments merging described in previous paragraph, templating can be very powerful tool to setup your ENV in a very flexible way. For example, one can set global parameters in a .env located in a root of the application and combine it with individual files located deeper inside the application file tree.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"You can diagnose problems like unresolved templates and circular dependencies with isresolved and unresolved_keys. For example","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"# .env\nFOO = ${BAR}\nBAR = ${FOO}\nZZZ = ${YYY}","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"julia> cfg = dotenv();\njulia> isresolved(cfg)\nfalse\n\njulia> unresolved_keys(cfg).circular\n2-element Vector{Pair{String, String}}:\n \"FOO\" => \"\\${BAR}\"\n \"BAR\" => \"\\${FOO}\"\n\njulia> unresolved_keys(cfg).undefined\n1-element Vector{Pair{String, String}}:\n \"ZZZ\" => \"\\${YYY}\"","category":"page"},{"location":"usage/#Nested-templates","page":"Usage","title":"Nested templates","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"One can also use nested interpolations of an arbitrary depth to build more complicated environment constructions.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"# .env\nUSER_1 = FOO\nUSER_2 = BAR\nN = 1\nUSER = ${USER_${N}}","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"is translated to the following config","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"julia> dotenv();\njulia> ENV[\"USER\"]\n\"FOO\"","category":"page"},{"location":"usage/#IO-streaming","page":"Usage","title":"IO streaming","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"dotenv function supports IO objects, so one can download configuration from net if needed or read it any other way.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"using ConfigEnv\nusing HTTP\n\ncfg = HTTP.get(\"https://raw.githubusercontent.com/Arkoniak/ConfigEnv.jl/master/test/.env\") |> x -> IOBuffer(x.body) |> dotenv\n\ncfg[\"QWERTY\"] # \"ZXC\"","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"CurrentModule = ConfigEnv","category":"page"},{"location":"scenarios/#Examples","page":"Examples","title":"Examples","text":"","category":"section"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"In this section you can find different scenarios of various complexity, which shows how to utilize features of ConfigEnv.jl.","category":"page"},{"location":"scenarios/#Simple-ENV-manipulations","page":"Examples","title":"Simple ENV manipulations","text":"","category":"section"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"If the package that you are using provides support for environmental variables, than all you have to do is write proper .env and populate ENV with dotenv function.","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"For example, here is how one can setup and use Telegram.jl functions","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"Configure .env","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"# .env\nTELEGRAM_BOT_TOKEN = <YOUR TELEGRAM BOT TOKEN>\nTELEGRAM_BOT_CHAT_ID = <YOUR TELEGRAM CHAT ID>","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"and use it in an application","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"using Telegram, Telegram.API\nusing ConfigEnv\n\ndotenv()\n\nsendMessage(text = \"Hello, world!\") # uses TELEGRAM_BOT_TOKEN and TELEGRAM_BOT_CHAT_ID","category":"page"},{"location":"scenarios/#Multifile-configuration","page":"Examples","title":"Multifile configuration","text":"","category":"section"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"One can use merge feature to factor out repeating parts of environment configuration. For example, one can use the following file file structure","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"/\n  .root_env\n  dir1/\n    .env\n    file1.jl\n  dir2/\n    .env\n    file2.jl","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"In this case .root_env can contain","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"HOST = localhost\nPORT = 1234","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"and .env in dir1 can be","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"USER = FOO\nPASSWORD = BAR","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"Then file1.jl can use the following construction","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"using ConfigEnv\n\ndotenv(\".env\", \"../.root_env\")","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"As a result, all four variables are set in the environment. By using different user/password in .env of dir2 one can obtain directory dependent environments without repeating HOST and PORT values.","category":"page"},{"location":"scenarios/#Templating-configuration","page":"Examples","title":"Templating configuration","text":"","category":"section"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"Expanding on the previous example, imagine that you have different user/password pairs for production and testing environments. Than you can organise your .env files as follows","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"# .root_env\nUSER_PRODUCTION = FOO\nUSER_TEST = TEST\n\nPASSWORD_PRODUCTION = BAR\nPASSWORD_TEST = 123\n\nUSER = ${USER_${ENVIR}}\nPASSWORD = ${PASSWORD_${ENVIR}}","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"# dir1/.env\nENVIR = PRODUCTION","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"Then in your file1.jl you can get the following","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"using ConfigEnv\n\ndotenv(\"../.root_env\", \".env\")\n\nENV[\"USER\"]     # FOO\nENV[\"PASSWORD\"] # BAR","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"So variables USER and PASWORD will be set according to the value of ENVIR.","category":"page"},{"location":"scenarios/#Using-IO-objects","page":"Examples","title":"Using IO objects","text":"","category":"section"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"One can even go further and use templates together with IO objects to dynamically update application configuration. For example, if application looks like","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"/\n  .env\n  app.jl","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"with .env similar to the previous example","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"USER_PRODUCTION = FOO\nUSER_TEST = TEST\n\nPASSWORD_PRODUCTION = BAR\nPASSWORD_TEST = 123\n\nUSER = ${USER_${ENVIR}}\nPASSWORD = ${PASSWORD_${ENVIR}}","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"and there is a .env","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"ENVIR = PRODUCTION","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"located on some server in local network, then one can use the following construction in app.jl","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"using ConfigEnv\nusing HTTP\n\ndotenv(IOBuffer(HTTP.get(\"http://127.0.0.1/.env\").body), \".env\")\n\nENV[\"USER\"]     # FOO\nENV[\"PASSWORD\"] # BAR","category":"page"},{"location":"scenarios/","page":"Examples","title":"Examples","text":"So it is possible to change application mode from production to test, just by changing value of the .env file on server.","category":"page"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = ConfigEnv","category":"page"},{"location":"#ConfigEnv","page":"Home","title":"ConfigEnv","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"ConfigEnv.jl is an environment configuration package that loads environment variables from a .env file into ENV. This package was inspired by python-dotenv library and the Twelve-Factor App methodology. ","category":"page"},{"location":"","page":"Home","title":"Home","text":"It's intended usage is when you have some secrets like database passwords, which shouldn't leak into public space and at the same time you want to have simple and flexible management of such secrets. Another usage possibility is when some library uses environmental variables for configuration and you want to configure them without editing your .bashrc or Windows environment.","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"ConfigEnv.jl is a registered package, so it can be installed with","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> using Pkg; Pkg.add(\"ConfigEnv\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"or","category":"page"},{"location":"","page":"Home","title":"Home","text":"# switch to pkg mode\njulia> ] \nv1.6> add ConfigEnv","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [ConfigEnv]","category":"page"},{"location":"#ConfigEnv.dotenv","page":"Home","title":"ConfigEnv.dotenv","text":"dotenv(path1, path2, ...; overwrite = true)\n\ndotenv reads .env files from your path, parse their content, merge them together, stores result to ENV, and finally return a EnvProxyDict with the content. If no path argument is given , then  .env is used as a default path. During merge procedure, if duplicate keys encountered then value from the rightmost dictionary is used.\n\nBy default if key already exists in ENV it is overwritten with the values in .env file.  This behaviour can be changed by setting overwrite flag to false or using dual dotenvx function.\n\nExamples\n\n# .env\nFOO = bar\nUSER = john_doe\n\n# julia REPL\n# load key-value pairs from \".env\", `ENV` duplicate keys are overwritten\njulia> ENV[\"USER\"]\nuser1\njulia> cfg = dotenv()\njulia> ENV[\"FOO\"]\nbar\njulia> ENV[\"USER\"]\njohn_doe\njulia> cfg[\"USER\"]\njohn_doe\n\n\n\n\n\n","category":"function"},{"location":"#ConfigEnv.dotenvx-Tuple","page":"Home","title":"ConfigEnv.dotenvx","text":"dotenvx(path1, path2, ...; overwrite = false)\n\ndotenvx reads .env files from your path, parse their content, merge them together, stores result to ENV, and finally return a EnvProxyDict with the content. If no path argument is given , then  .env is used as a default path. During merge procedure, if duplicate keys encountered then value from the rightmost dictionary is used.\n\nBy default if key already exists in ENV it is overwritten with the values in .env file.  This behaviour can be changed by setting overwrite flag to true or using dual dotenv function.\n\nExamples\n\n# .env\nFOO = bar\nUSER = john_doe\n\n# julia REPL\n# load key-value pairs from \".env\", `ENV` duplicate keys are not overwritten\njulia> ENV[\"USER\"]\nuser1\njulia> cfg = dotenvx()\njulia> ENV[\"FOO\"]\nbar\njulia> ENV[\"USER\"]\nuser1\njulia> cfg[\"USER\"]\njohn_doe\n\n\n\n\n\n","category":"method"},{"location":"#ConfigEnv.isresolved-Tuple{ConfigEnv.EnvProxyDict}","page":"Home","title":"ConfigEnv.isresolved","text":"isresolved(cfg::EnvProxyDict)\n\nReturns whether templating procedure was successful or not. Templating can be unsuccessful if there are circular dependencies or templated variables do not exist in the environment.\n\n\n\n\n\n","category":"method"},{"location":"#ConfigEnv.parse-Tuple{Any}","page":"Home","title":"ConfigEnv.parse","text":"ConfigEnv.parse accepts a String or an IOBuffer (any value that  can be converted into String), and returns a Dict with  the parsed keys and values.\n\n\n\n\n\n","category":"method"},{"location":"#ConfigEnv.unresolved_keys-Tuple{ConfigEnv.EnvProxyDict}","page":"Home","title":"ConfigEnv.unresolved_keys","text":"unresolved_keys(cfg::EnvProxyDict)\n\nReturns tuple of circular and undefined keys, where circular are keys which depends on each other and undefined are keys, which use variables that do not exist in the environment.\n\n\n\n\n\n","category":"method"}]
}
