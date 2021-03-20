module TestDotEnv

using DotEnv2

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
    cfg = DotEnv2.config(file, false)
    @test ENV["USER"] != cfg["USER"]
    @test ENV["USER"] == initial_value

    # iobuffer, string, file
    @test DotEnv2.parse(str) == Dict("BASIC"=>"basic")
    @test DotEnv2.parse(read(file)) == Dict("CUSTOMVAL123"=>"yes","USER"=>"replaced value")
    @test DotEnv2.config(file).dict == Dict("CUSTOMVAL123"=>"yes","USER"=>"replaced value")

    @test isempty(DotEnv2.config("inexistentfile.env"))

    # length of returned values
    @test length(DotEnv2.config(file2).dict) == 10

    # appropiately loaded into ENV if CUSTOM_VAL is non existent
    @test ENV["CUSTOMVAL123"] == "yes"

    # Test that EnvProxyDict is reading from ENV
    ENV["SOME_RANDOM_KEY"] = "abc"
    cfg = DotEnv2.config(file)
    @test !haskey(cfg.dict, "SOME_RANDOM_KEY")
    @test cfg["SOME_RANDOM_KEY"] == "abc"
    @test get(cfg, "OTHER_RANDOM_KEY", "zxc") == "zxc"

    #test alias
    @test DotEnv2.load(file).dict == DotEnv2.config(file).dict
    @test DotEnv2.load(; path = file).dict == DotEnv2.config(file).dict
end

@testset "Override" begin
    # basic input
    file = joinpath(dir, ".env.override")

    # By default force override
    cfg = DotEnv2.config(file)
    @test ENV["USER"] == cfg["USER"]
    @test ENV["USER"] == "replaced value"
    
    # Restore previous environment
    ENV["USER"] = initial_value
end

@testset "parsing" begin

    #comment
    @test DotEnv2.parse("#HIMOM") == Dict()

    #spaces without quotes
    @test begin
        p = DotEnv2.parse("TEST=hi  the  re")
        count(c -> c == ' ', collect(p["TEST"])) == 4
    end

    #single quotes
    @test DotEnv2.parse("TEST=''")["TEST"] == ""
    @test DotEnv2.parse("TEST='something'")["TEST"] == "something"

    #double quotes
    @test DotEnv2.parse("TEST=\"\"")["TEST"] == ""
    @test DotEnv2.parse("TEST=\"something\"")["TEST"] == "something"

    #inner quotes are mantained
    @test DotEnv2.parse("TEST=\"\"json\"\"")["TEST"] == "\"json\""
    @test DotEnv2.parse("TEST=\"'json'\"")["TEST"] == "'json'"
    @test DotEnv2.parse("TEST=\"\"\"")["TEST"] == "\""
    @test DotEnv2.parse("TEST=\"'\"")["TEST"] == "'"

    #line breaks
    @test DotEnv2.parse("TEST=\"\\n\"")["TEST"] == "" #It's null because of final trim
    @test DotEnv2.parse("TEST=\"\\n\\n\\nsomething\"")["TEST"] == "something"
    @test DotEnv2.parse("TEST=\"something\\nsomething\"")["TEST"] == "something\nsomething"
    @test DotEnv2.parse("TEST=\"something\\n\\nsomething\"")["TEST"] == "something\n\nsomething"
    @test DotEnv2.parse("TEST='\\n'")["TEST"] == "\\n"
    @test DotEnv2.parse("TEST=\\n")["TEST"] == "\\n"

    #empty vars
    @test DotEnv2.parse("TEST=")["TEST"] == ""

    #trim spaces with and without quotes
    @test DotEnv2.parse("TEST='  something  '")["TEST"] == "something"
    @test DotEnv2.parse("TEST=\"  something  \"")["TEST"] == "something"
    @test DotEnv2.parse("TEST=  something  ")["TEST"] == "something"
    @test DotEnv2.parse("TEST=    ")["TEST"] == ""
end

end # module
