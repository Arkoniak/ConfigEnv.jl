module TestParser

using ConfigEnv
using Test

@testset "parsing" begin

    #comment
    @test ConfigEnv.parse("# Comment") == Dict()

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
