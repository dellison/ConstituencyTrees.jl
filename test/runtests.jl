using ConstituencyTrees, Test

@testset "ConstituencyTrees.jl" begin
    @test 1 == 1

    @testset "Trees" begin
        S = "(S (NP (DT the) (N cat)) (VP (V slept)))"
        tree = read_tree(S)
        @test tree.node == "S"

        @test collect(POS(tree)) == [("DT","the"),("N","cat"),("V","slept")]
        @test collect(Words(tree)) == ["the","cat","slept"]
        
        t2 = tree"(S (NP (DT the) (N cat)) (VP (V slept)))"
        @test tree == t2

        vals(x) = ConstituencyTrees.label.(collect(x))
        for (iter, nodes) in [(Leaves, "the cat slept"),
                              (PreOrderDFS, "S NP DT the N cat VP V slept"),
                              (PostOrderDFS, "the DT cat N NP slept V VP S")]
            @test vals(iter(tree)) == vals(iter(t2)) == split(nodes)
        end

        @test collect(Leaves(tree)) == collect(Leaves(t2)) == split("the cat slept")

        @test ConstituencyTrees.isterminal(ConstituencyTree("DT", "the"))
        @test ConstituencyTrees.label(ConstituencyTree()) == nothing
        @test ConstituencyTrees.label("x") == "x"
    end

    @testset "Sentiment" begin
        str = read(joinpath(@__DIR__, "data", "sentiment1.txt"), String)
        tree_str = read_tree(str)
        tree_int = read_tree(str, read_node = x -> parse(Int, x))
        @test collect(Words(tree_str)) == collect(Words(tree_int))
    end

    @testset "Brackets" begin
        S = "(S (NP (DT the) (N cat)) (VP (V slept)))"
        tree = read_tree(S)
    end

    @testset "Pierre" begin
        S = read(joinpath(@__DIR__, "data", "pierre.mrg"), String)
        tree = read_tree(S)
    end

    @testset "Productions" begin
        tree = tree"(S (NP (DT the) (N cat)) (VP (V slept)))"
        @test productions(tree) == [
            ("S", ["NP","VP"]),
            ("NP", ["DT","N"]),
            ("DT", ["the"]),
            ("N", ["cat"]),
            ("VP", ["V"]),
            ("V", ["slept"])
        ]
    end

    @testset "Chomsky Normal Form" begin
        t = tree"(A B C D)"

        function testbrackets(t, str)
            buf = IOBuffer()
            Base.show(buf, t)
            result = String(take!(buf))
            ref = strip(replace(str, r"\s+"=>" "))
            return result == "ConstituencyTree{String}" * ref
        end

        tree = tree"(A (B b) (C c) (D d))"

        @test !testbrackets(tree, "()")

        @test testbrackets(chomsky_normal_form(tree, RightFactored()),
                           "(A (B b) (A|<C-D> (C c) (D d)))")

        ftree = tree"(A (B b) (C c) (D d) (E e) (F f))"
        @test testbrackets(chomsky_normal_form(ftree, LeftFactored()),
                           "(A (A|<B-C-D-E> (A|<B-C-D> (A|<B-C> (B b) (C c)) (D d)) (E e)) (F f))")

        @test testbrackets(chomsky_normal_form(ftree, RightFactored()),
                           "(A (B b) (A|<C-D-E-F> (C c) (A|<D-E-F> (D d) (A|<E-F> (E e) (F f)))))")

        pierre = tree"""
        (S
          (NP-SBJ
            (NP (NNP Pierre) (NNP Vinken))
            (, ,)
            (ADJP (NP (CD 61) (NNS years)) (JJ old))
            (, ,))
          (VP
            (MD will)
            (VP
              (VB join)
              (NP (DT the) (NN board))
              (PP-CLR
                (IN as)
                (NP
                  (DT a)
                  (JJ nonexecutive) (NN director)))
              (NP-TMP (NNP Nov.) (CD 29))))
          (. .))"""

        @test testbrackets(chomsky_normal_form(pierre, RightFactored()),
                           """
                           (S
                           (NP-SBJ
                               (NP (NNP Pierre) (NNP Vinken))
                               (NP-SBJ|<,-ADJP-,>
                               (, ,)
                               (NP-SBJ|<ADJP-,>
                                   (ADJP (NP (CD 61) (NNS years)) (JJ old))
                                   (, ,))))
                           (S|<VP-.>
                               (VP
                               (MD will)
                               (VP
                                   (VB join)
                                   (VP|<NP-PP-CLR-NP-TMP>
                                   (NP (DT the) (NN board))
                                   (VP|<PP-CLR-NP-TMP>
                                       (PP-CLR
                                       (IN as)
                                       (NP
                                           (DT a)
                                           (NP|<JJ-NN> (JJ nonexecutive) (NN director))))
                                       (NP-TMP (NNP Nov.) (CD 29))))))
                               (. .)))
                           """)

        @test testbrackets(chomsky_normal_form(pierre, LeftFactored()),
                           """
                           (S
                             (S|<NP-SBJ-VP>
                               (NP-SBJ
                                 (NP-SBJ|<NP-,-ADJP>
                                   (NP-SBJ|<NP-,> (NP (NNP Pierre) (NNP Vinken)) (, ,))
                                   (ADJP (NP (CD 61) (NNS years)) (JJ old)))
                                 (, ,))
                               (VP
                                 (MD will)
                                 (VP
                                   (VP|<VB-NP-PP-CLR>
                                     (VP|<VB-NP> (VB join) (NP (DT the) (NN board)))
                                     (PP-CLR
                                       (IN as)
                                       (NP (NP|<DT-JJ> (DT a) (JJ nonexecutive)) (NN director))))
                                   (NP-TMP (NNP Nov.) (CD 29)))))
                             (. .))
                           """)
    end
end
