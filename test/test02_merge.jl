module TestMerge
using ConfigEnv
using Test

const dir = dirname(@__FILE__)
const path1 = joinpath(dir, ".env1")
const path2 = joinpath(dir, ".env2")
const path3 = joinpath(dir, ".env3")

@testset "Multiargs" begin
    cfg = dotenv(path1, path2)
    @test cfg["FOO"] == "BAR"
    @test cfg["QWE"] == "ASD"
end

@testset "Merge with merge" begin
    cfg1 = dotenv(path1)
    cfg2 = dotenv(path2)

    cfg = merge(cfg1, cfg2)
    @test cfg["FOO"] == "BAR"
    @test cfg["QWE"] == "ASD"
    @test !haskey(cfg1.dict, "QWE")
    @test !haskey(cfg2.dict, "FOO")
end

@testset "Merge with merge!" begin
    cfg1 = dotenv(path1)
    cfg2 = dotenv(path2)

    cfg = merge!(cfg1, cfg2)
    @test cfg["FOO"] == "BAR"
    @test cfg["QWE"] == "ASD"
    @test cfg1["FOO"] == "BAR"
    @test cfg1["QWE"] == "ASD"
    
    @test !haskey(cfg2.dict, "FOO")
end

@testset "Merge with *" begin
    cfg1 = dotenv(path1)
    cfg2 = dotenv(path2)

    cfg = cfg1 * cfg2
    @test cfg["FOO"] == "BAR"
    @test cfg["QWE"] == "ASD"
    @test !haskey(cfg1.dict, "QWE")
    @test !haskey(cfg2.dict, "FOO")
end

@testset "Merge with duplicates" begin
    cfg1 = dotenv(path1)
    cfg3 = dotenv(path3)

    cfg = cfg1 * cfg3
    @test cfg["FOO"] == "FUU"
end

end # module
