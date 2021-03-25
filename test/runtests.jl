module TestDotEnv

using ConfigEnv

using Test

const dir = dirname(@__FILE__)

# There is no "USER" variable on windows.
initial_value = haskey(ENV, "USER") ? ENV["USER"] : "WINDOWS"
ENV["USER"] = initial_value

@testset "basic" begin
    # basic input
    str = "BASIC=basic"
    file = joinpath(dir, ".env.override")
    file2 = joinpath(dir, ".env")

    # can turn off override of ENV vars
    cfg = dotenv(file, false)
    @test ENV["USER"] != cfg["USER"]
    @test ENV["USER"] == initial_value

    # iobuffer, string, file
    @test ConfigEnv.parse(str) == Dict("BASIC"=>"basic")
    @test ConfigEnv.parse(read(file)) == Dict("CUSTOMVAL123"=>"yes","USER"=>"replaced value")
    @test ConfigEnv.config(file).dict == Dict("CUSTOMVAL123"=>"yes","USER"=>"replaced value")

    @test isempty(dotenv("inexistentfile.env"))

    # length of returned values
    @test length(dotenv(file2).dict) == 10

    # appropiately loaded into ENV if CUSTOM_VAL is non existent
    @test ENV["CUSTOMVAL123"] == "yes"

    # Test that EnvProxyDict is reading from ENV
    ENV["SOME_RANDOM_KEY"] = "abc"
    cfg = dotenv(file)
    @test !haskey(cfg.dict, "SOME_RANDOM_KEY")
    @test cfg["SOME_RANDOM_KEY"] == "abc"
    @test get(cfg, "OTHER_RANDOM_KEY", "zxc") == "zxc"
end

@testset "Override" begin
    # basic input
    file = joinpath(dir, ".env.override")

    # By default force override
    cfg = dotenv(file)
    @test ENV["USER"] == cfg["USER"]
    @test ENV["USER"] == "replaced value"
    
    # Restore previous environment
    ENV["USER"] = initial_value
end

@testset "parsing" begin

    #comment
    @test ConfigEnv.parse("#HIMOM") == Dict()

    #spaces without quotes
    @test begin
        p = ConfigEnv.parse("TEST=hi  the  re")
        count(c -> c == ' ', collect(p["TEST"])) == 4
    end

    #single quotes
    @test ConfigEnv.parse("TEST=''")["TEST"] == ""
    @test ConfigEnv.parse("TEST='something'")["TEST"] == "something"

    #double quotes
    @test ConfigEnv.parse("TEST=\"\"")["TEST"] == ""
    @test ConfigEnv.parse("TEST=\"something\"")["TEST"] == "something"

    #inner quotes are mantained
    @test ConfigEnv.parse("TEST=\"\"json\"\"")["TEST"] == "\"json\""
    @test ConfigEnv.parse("TEST=\"'json'\"")["TEST"] == "'json'"
    @test ConfigEnv.parse("TEST=\"\"\"")["TEST"] == "\""
    @test ConfigEnv.parse("TEST=\"'\"")["TEST"] == "'"

    #line breaks
    @test ConfigEnv.parse("TEST=\"\\n\"")["TEST"] == "" #It's null because of final trim
    @test ConfigEnv.parse("TEST=\"\\n\\n\\nsomething\"")["TEST"] == "something"
    @test ConfigEnv.parse("TEST=\"something\\nsomething\"")["TEST"] == "something\nsomething"
    @test ConfigEnv.parse("TEST=\"something\\n\\nsomething\"")["TEST"] == "something\n\nsomething"
    @test ConfigEnv.parse("TEST='\\n'")["TEST"] == "\\n"
    @test ConfigEnv.parse("TEST=\\n")["TEST"] == "\\n"

    #empty vars
    @test ConfigEnv.parse("TEST=")["TEST"] == ""

    #trim spaces with and without quotes
    @test ConfigEnv.parse("TEST='  something  '")["TEST"] == "something"
    @test ConfigEnv.parse("TEST=\"  something  \"")["TEST"] == "something"
    @test ConfigEnv.parse("TEST=  something  ")["TEST"] == "something"
    @test ConfigEnv.parse("TEST=    ")["TEST"] == ""
end

end # module
