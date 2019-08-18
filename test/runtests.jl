using ConstituencyTrees, Test

@testset "ConstituencyTrees.jl" begin
    @test 1 == 1

    @testset "Trees" begin
        S = "(S (NP (DT the) (N cat)) (VP (V slept)))"
        tree = read_bracketed_tree(S)
        @test tree.node == "S"
        
        t2 = tree"(S (NP (DT the) (N cat)) (VP (V slept)))"
        # @test tree == t2 # TODO

        vals(x) = ConstituencyTrees.label.(collect(x))
        for (iter, nodes) in [(Leaves, "the cat slept"),
                              (PreOrderDFS, "S NP DT the N cat VP V slept"),
                              (PostOrderDFS, "the DT cat N NP slept V VP S")]
            @test vals(iter(tree)) == vals(iter(t2)) == split(nodes)
        end

        @test collect(Leaves(tree)) == collect(Leaves(t2)) == split("the cat slept")
    end

    @testset "Brackets" begin
        S = "(S (NP (DT the) (N cat)) (VP (V slept)))"
        tree = read_bracketed_tree(S)
    end

    @testset "Pierre" begin
        S = read(joinpath(@__DIR__, "data", "pierre.mrg"), String)
        tree = read_bracketed_tree(S)
    end
end
