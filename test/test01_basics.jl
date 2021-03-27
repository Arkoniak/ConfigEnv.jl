module TestBasics
using ConfigEnv
using Test

const dir = dirname(@__FILE__)

# There is no "USER" variable on windows.
initial_value = haskey(ENV, "USER") ? ENV["USER"] : "WINDOWS"
ENV["USER"] = initial_value

@testset "Locality" begin
    cfg = dotenv()
    @test haskey(cfg.dict, "QWERTY")
    @test cfg["QWERTY"] == "ZXC"
end

@testset "basic" begin
    # basic input
    str = "BASIC=basic"
    file = joinpath(dir, ".env.override")
    file2 = joinpath(dir, ".testenv")

    # can turn off override of ENV vars
    cfg = dotenv(file, overwrite = false)
    @test ENV["USER"] != cfg["USER"]
    @test ENV["USER"] == initial_value

    # iobuffer, string, file
    @test ConfigEnv.parse(str) == Dict("BASIC"=>"basic")
    @test ConfigEnv.parse(read(file)) == Dict("CUSTOMVAL123"=>"yes","USER"=>"replaced value")
    @test dotenv(file).dict == Dict("CUSTOMVAL123"=>"yes","USER"=>"replaced value")

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

@testset "Overwrite dotenv" begin
    # basic input
    file = joinpath(dir, ".env.override")

    # By default force override
    cfg = dotenv(file)
    @test ENV["USER"] == cfg["USER"]
    @test ENV["USER"] == "replaced value"
    
    # Restore previous environment
    ENV["USER"] = initial_value
end

@testset "No overwrite dotenvx" begin
    # basic input
    file = joinpath(dir, ".env1")

    # By default force overwrite
    ENV["FOO"] = "FUU"
    cfg = dotenvx(file)
    @test ENV["FOO"] == "FUU"
    @test cfg["FOO"] == "BAR"
end

@testset "Other means to load data" begin
    txt = "FOO = BAR"
    cfg = dotenv(txt)
    @test cfg.dict["FOO"] == "BAR"

    iob = IOBuffer()
    print(iob, "FOO = BAR")
    cfg = dotenv(iob)
    @test cfg.dict["FOO"] == "BAR"
end

end # module
