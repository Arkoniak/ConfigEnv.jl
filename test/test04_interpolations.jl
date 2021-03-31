module TestInterpolations

using ConfigEnv
using ConfigEnv: KVNode, resolve!, prepare_stack!, isdefin
using Test

const dir = dirname(@__FILE__)

@testset "Internal implementation" begin
    @testset "Simple interpolation" begin
        stack = KVNode[]
        knodes = Dict("X" => KVNode("X", "\${Y}"),
                      "Y" => KVNode("Y", "Z"))
        env = Dict{String, String}()

        prepare_stack!(stack, knodes, env)
        resolve!(stack, knodes, env)

        @test knodes["X"].isresolved
        @test knodes["X"].value == "Z"

        @test knodes["Y"].isresolved
        @test knodes["Y"].value == "Z"
    end

    @testset "Simple interpolation with extra characters" begin
        stack = KVNode[]
        knodes = Dict("X" => KVNode("X", "FOO_\${Y}"),
                      "Y" => KVNode("Y", "Z"))
        env = Dict{String, String}()

        prepare_stack!(stack, knodes, env)
        resolve!(stack, knodes, env)

        @test knodes["X"].isresolved
        @test knodes["X"].value == "FOO_Z"

        @test knodes["Y"].isresolved
        @test knodes["Y"].value == "Z"
    end

    @testset "Circular dependencies" begin
        stack = KVNode[]
        knodes = Dict("X" => KVNode("X", "\${Y}"),
                      "Y" => KVNode("Y", "\${X}"))
        env = Dict{String, String}()

        prepare_stack!(stack, knodes, env)
        resolve!(stack, knodes, env)

        @test !knodes["X"].isresolved
        @test knodes["X"].value == "\${Y}"

        @test !knodes["Y"].isresolved
        @test knodes["Y"].value == "\${X}"
    end

    @testset "Two level interpolation" begin
        stack = KVNode[]
        knodes = Dict("X" => KVNode("X", "A_\${Y}"),
                      "Y" => KVNode("Y", "B_\${Z}"),
                      "Z" => KVNode("Z", "FOO"))
        env = Dict{String, String}()

        prepare_stack!(stack, knodes, env)
        resolve!(stack, knodes, env)

        @test knodes["X"].isresolved
        @test knodes["X"].value == "A_B_FOO"

        @test knodes["Y"].isresolved
        @test knodes["Y"].value == "B_FOO"

        @test knodes["Z"].isresolved
        @test knodes["Z"].value == "FOO"
    end

    @testset "Nested interpolation" begin
        stack = KVNode[]
        knodes = Dict("X" => KVNode("X", "\${USER_\${N}}"),
                      "N" => KVNode("N", "1"),
                      "USER_1" => KVNode("USER_1", "FOO"))
        env = Dict{String, String}()

        prepare_stack!(stack, knodes, env)
        resolve!(stack, knodes, env)

        @test knodes["X"].isresolved
        @test knodes["X"].value == "FOO"

        @test knodes["N"].isresolved
        @test knodes["N"].value == "1"

        @test knodes["USER_1"].isresolved
        @test knodes["USER_1"].value == "FOO"
    end

    @testset "Two neighbours interpolation" begin
        stack = KVNode[]
        knodes = Dict("X" => KVNode("X", "\${FOO}_\${BAR}"),
                      "FOO" => KVNode("FOO", "A"),
                      "BAR" => KVNode("BAR", "B"))
        env = Dict{String, String}()

        prepare_stack!(stack, knodes, env)
        resolve!(stack, knodes, env)

        @test knodes["X"].isresolved
        @test knodes["X"].value == "A_B"

        @test knodes["FOO"].isresolved
        @test knodes["FOO"].value == "A"

        @test knodes["BAR"].isresolved
        @test knodes["BAR"].value == "B"
    end

    @testset "One unknown key" begin
        stack = KVNode[]
        knodes = Dict("X" => KVNode("X", "\${FOO}_\${BAR}"),
                      "FOO" => KVNode("FOO", "A"))
        env = Dict{String, String}()

        prepare_stack!(stack, knodes, env)
        resolve!(stack, knodes, env)

        @test knodes["X"].isresolved
        @test knodes["X"].value == "A_\${BAR}"

        @test knodes["FOO"].isresolved
        @test knodes["FOO"].value == "A"
    end

    @testset "One key from ENV" begin
        stack = KVNode[]
        knodes = Dict("X" => KVNode("X", "\${FOO}_\${BAR}"),
                      "FOO" => KVNode("FOO", "A"))
        env = Dict{String, String}("BAR" => "zzz")

        prepare_stack!(stack, knodes, env)
        resolve!(stack, knodes, env)

        @test knodes["X"].isresolved
        @test knodes["X"].value == "A_zzz"

        @test knodes["FOO"].isresolved
        @test knodes["FOO"].value == "A"
    end

    @testset "Three level circular dependencies" begin
        stack = KVNode[]
        knodes = Dict("X" => KVNode("X", "\${Y}"),
                      "Y" => KVNode("Y", "\${Z}"),
                      "Z" => KVNode("Z", "\${X}"))
        env = Dict{String, String}()

        prepare_stack!(stack, knodes, env)
        resolve!(stack, knodes, env)

        @test !knodes["X"].isresolved
        @test knodes["X"].value == "\${Y}"

        @test !knodes["Y"].isresolved
        @test knodes["Y"].value == "\${Z}"

        @test !knodes["Z"].isresolved
        @test knodes["Z"].value == "\${X}"
    end

    @testset "Broken key" begin
        stack = KVNode[]
        knodes = Dict("X" => KVNode("X", "\${Y"),
                      "Y" => KVNode("Y", "FOO"))
        env = Dict{String, String}()

        prepare_stack!(stack, knodes, env)
        resolve!(stack, knodes, env)
    
        @test knodes["X"].isresolved
        @test knodes["X"].value == "\${Y"

        @test knodes["Y"].isresolved
        @test knodes["Y"].value == "FOO"
    end

    @testset "Json substring is ignored" begin
        stack = KVNode[]
        knodes = Dict("X" => KVNode("X", "A_\${Y}"),
                      "Y" => KVNode("Y", "{foo: bar}"))
        env = Dict{String, String}()

        prepare_stack!(stack, knodes, env)
        resolve!(stack, knodes, env)
    
        @test knodes["X"].isresolved
        @test knodes["X"].value == "A_{foo: bar}"

        @test knodes["Y"].isresolved
        @test knodes["Y"].value == "{foo: bar}"
    end
end

@testset "Test isdefin" begin
    @test isdefin("asd")
    @test isdefin("zxc\${asdf")
    @test isdefin("zxc\${as\${df")
    @test isdefin("zxc\${")
    
    @test !isdefin("asd\${xzcvcv}")
    @test !isdefin("asd\${xzcvcv}cxv")
    @test !isdefin("asd\${xz\${cv}cv}")
end

@testset "File interpolations" begin
    @testset "Simple file interpolation" begin
        haskey(ENV, "X") && pop!(ENV, "X")
        haskey(ENV, "Y") && pop!(ENV, "Y")
        file = joinpath(dir, ".env_interpolation1")
        cfg = dotenv(file)

        @test isresolved(cfg)
        @test isempty(unresolved_keys(cfg).circular)
        @test isempty(unresolved_keys(cfg).undefined)
        @test cfg["X"] == "A_FOO"
        @test cfg["Y"] == "FOO"
    end

    @testset "Nested file interpolation" begin
        haskey(ENV, "USER") && pop!(ENV, "USER")
        haskey(ENV, "N") && pop!(ENV, "N")
        haskey(ENV, "USER_1") && pop!(ENV, "USER_1")
        file = joinpath(dir, ".env_interpolation2")
        cfg = dotenv(file)

        @test isresolved(cfg)
        @test isempty(unresolved_keys(cfg).circular)
        @test isempty(unresolved_keys(cfg).undefined)
        @test cfg["USER"] == "FOO"
        @test cfg["N"] == "1"
        @test cfg["USER_1"] == "FOO"
    end

    @testset "Merge file interpolation" begin
        haskey(ENV, "USER") && pop!(ENV, "USER")
        haskey(ENV, "N") && pop!(ENV, "N")
        haskey(ENV, "USER_1") && pop!(ENV, "USER_1")
        file1 = joinpath(dir, ".env_interpolation3")
        file2 = joinpath(dir, ".env_interpolation4")

        cfg = dotenv(file1, file2)

        @test isresolved(cfg)
        @test isempty(unresolved_keys(cfg).circular)
        @test isempty(unresolved_keys(cfg).undefined)
        @test cfg["USER"] == "FOO"
        @test cfg["N"] == "1"
        @test cfg["USER_1"] == "FOO"

        haskey(ENV, "USER") && pop!(ENV, "USER")
        haskey(ENV, "N") && pop!(ENV, "N")
        haskey(ENV, "USER_1") && pop!(ENV, "USER_1")
        cfg1 = dotenv(file1)
        @test !isresolved(cfg1)
        @test isempty(unresolved_keys(cfg1).circular)
        @test !isempty(unresolved_keys(cfg1).undefined)
        cfg2 = dotenv(file2)
        cfg = cfg1 * cfg2
        @test isresolved(cfg)
        @test isempty(unresolved_keys(cfg).circular)
        @test isempty(unresolved_keys(cfg).undefined)
        @test cfg["USER"] == "FOO"
        @test cfg["N"] == "1"
        @test cfg["USER_1"] == "FOO"

        haskey(ENV, "USER") && pop!(ENV, "USER")
        haskey(ENV, "N") && pop!(ENV, "N")
        haskey(ENV, "USER_1") && pop!(ENV, "USER_1")
        cfg1 = dotenv(file1)
        cfg2 = dotenv(file2)
        cfg = merge(cfg1, cfg2)
        @test isresolved(cfg)
        @test isempty(unresolved_keys(cfg).circular)
        @test isempty(unresolved_keys(cfg).undefined)
        @test cfg["USER"] == "FOO"
        @test cfg["N"] == "1"
        @test cfg["USER_1"] == "FOO"

        haskey(ENV, "USER") && pop!(ENV, "USER")
        haskey(ENV, "N") && pop!(ENV, "N")
        haskey(ENV, "USER_1") && pop!(ENV, "USER_1")
        cfg1 = dotenv(file1)
        cfg2 = dotenv(file2)
        merge!(cfg1, cfg2)
        @test isresolved(cfg1)
        @test isempty(unresolved_keys(cfg1).circular)
        @test isempty(unresolved_keys(cfg1).undefined)
        @test cfg1["USER"] == "FOO"
        @test cfg1["N"] == "1"
        @test cfg1["USER_1"] == "FOO"
    end

    @testset "Circular file interpolation" begin
        haskey(ENV, "X") && pop!(ENV, "X")
        haskey(ENV, "Y") && pop!(ENV, "Y")
        file = joinpath(dir, ".env_interpolation5")
        cfg = dotenv(file)

        @test !isresolved(cfg)
        badkeys = unresolved_keys(cfg).circular
        sort!(badkeys, by = x -> x[1])
        @test length(badkeys) == 2
        @test badkeys[1][2] == "\${Y}"
        @test badkeys[2][2] == "\${X}"
        @test cfg["X"] == "\${Y}"
        @test cfg["Y"] == "\${X}"
    end
end

end # module
