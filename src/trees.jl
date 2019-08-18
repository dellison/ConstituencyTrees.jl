"""
"""
struct ConstituencyTree{T}
    node::T
    children
end

const Tree = ConstituencyTree

# Tree(node) = ConstituencyTree{typeof(node)}(node, [])
Tree() = Tree{Any}(nothing, [])
Tree(node) = Tree(node, [])
Tree(node::String, child::String) = Tree(node, [child])
Tree(node, child::Tree, children...) = Tree(node, [child; children...])

AbstractTrees.children(tree::Tree) = tree.children
AbstractTrees.printnode(io::IO, tree::Tree) = print(io, ifelse(isnothing(tree.node), "", tree.node))

isleaf(args...)           = true
isleaf(tree::Tree)        =  isempty(tree.children)
isterminal(tree::Tree)    =  isempty(tree.children)
isnonterminal(tree::Tree) = !isempty(tree.children)

label(tree::Tree{Nothing}) = ""
label(tree::Tree{<:AbstractString}) = tree.node
label(x::String) = x

import Base.getindex, Base.iterate
Base.getindex(tree::ConstituencyTree, i) =
    i == 1 ? tree.node : i == 2 ? tree.children : error(BoundsError, "oops $tree $i")
Base.iterate(tree::ConstituencyTree, state=1) = (tree[state], state+1)

import Base.show
function show(io::IO, tree::ConstituencyTree)
    AbstractTrees.print_tree(io, tree)
end

"""
    print_bracketed

todo
"""
function print_bracketed end

print_bracketed(tree; kw...) = print_bracketed(stdout, tree; kw...)
function print_bracketed(io::IO, tree; depth = 0, indent = 2, multiline = true)
    print("(", label(tree))
    if !isleaf(tree)
        for child in children(tree)
            if !isleaf(child)
                multiline && print(io, "\n")
                print(io, repeat(" ", (depth + 1) * indent))
                print_bracketed(io, child; depth = depth + 1, indent = indent, multiline = multiline)
            else
                print(io, " ", label(child))
            end
        end
    end
    print(io, ")")
end
            


# iteration

abstract type ConstituencyTreeIterator end

Base.IteratorSize(::Type{<:ConstituencyTreeIterator}) = Base.SizeUnknown()

struct POSIterator{T} <: ConstituencyTreeIterator
    iterator::T
end
Base.iterate(pos::POSIterator, state...) = iterate(pos.iterator, state...)

"""
   POS(tree)

Iterator for part-of-speech tags.
"""
POS(tree::Tree) =
    POSIterator(label(node) for node in PreOrderDFS(tree)
                if length(children(node)) == 1 && isleaf(node.children[1]))

struct WordsIterator{T} <: ConstituencyTreeIterator
    iterator::T
end
Base.iterate(w::WordsIterator, state...) = iterate(w.iterator, state...)

"""
    Words(tree)

Iterator for words in a sentence.
"""
Words(tree::Tree) = Words(Leaves(tree))
