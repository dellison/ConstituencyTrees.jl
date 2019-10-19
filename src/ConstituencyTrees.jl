module ConstituencyTrees

using Reexport
@reexport using AbstractTrees

export ConstituencyTree
export print_bracketed, read_tree, @tree_str

export POS, Words

export productions

export chomsky_normal_form, LeftFactored, RightFactored
export collapse_unary

include("trees.jl")
include("transformations.jl")

include("brackets.jl")
using .Brackets

"""
    @tree_str(str)

String macro for reading a constituency parse tree from bracketed format.

    tree"(S (NP (DT the) (N cat)) (VP (V ate)))"
"""
macro tree_str(str)
    return read_tree(str)
end

end # module
