module ConstituencyTrees

using Reexport
@reexport using AbstractTrees

export ConstituencyTree
export print_bracketed, read_bracketed_tree, @tree_str

export POS, Words

include("trees.jl")

include("brackets.jl")
using .Brackets

"""
    @tree_str(str)

String macro for quickly reading trees.

    tree"(S (NP (DT the) (N cat)) (VP (V ate)))
"""
macro tree_str(str)
    return read_bracketed_tree(str)
end

end # module
