"""
    ConstituencyTree{T}

Constituency parse tree of a natural language sentence.
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

isleaf(args...)    = true
isleaf(tree::Tree) = isempty(tree.children)

istree(x) = false
istree(::Tree) = true

isterminal(x)             = true
isterminal(tree::Tree)    = length(tree.children) == 1 && isempty(children(tree.children[1]))
isnonterminal(tree::Tree) = !isterminal(tree)

label(tree::Tree{Nothing}) = ""
label(tree::Tree{<:AbstractString}) = tree.node
label(x::String) = x

function production(tree; nonterminal = identity, terminal = identity)
    lhs, rhs = label(tree), label.(children(tree))
    if isterminal(tree)
        return nonterminal(lhs), terminal.(rhs)
    else
        return nonterminal(lhs), nonterminal.(rhs)
    end
end
productions(tree; ks...) = filter(p -> p[2] != (), map(p -> production(p;ks...), PreOrderDFS(tree)))

import Base.getindex, Base.iterate
Base.getindex(tree::ConstituencyTree, i) =
    i == 1 ? tree.node : i == 2 ? tree.children : error(BoundsError, "oops $tree $i")
Base.iterate(tree::ConstituencyTree, state=1) = (tree[state], state+1)

import Base.show
function show(io::IO, tree::ConstituencyTree)
    print(io, typeof(tree))
    print_bracketed(io, tree; multiline = false)
end

import Base.==
==(t1::Tree, t2::Tree) = label(t1) == label(t2) && children(t1) == children(t2)

"""
    print_bracketed([io::IO,] tree; depth = 0, indent = 2, multiline = true)

Print a constituency parse tree in bracketed format.
"""
print_bracketed(tree; kw...) = print_bracketed(stdout, tree; kw...)
function print_bracketed(io::IO, tree; depth = 0, indent = 2, multiline = true)
    print("(", label(tree))
    if !isleaf(tree)
        for child in children(tree)
            if !isleaf(child)
                if multiline
                    print(io, "\n")
                    print(io, repeat(" ", (depth + 1) * indent))
                else
                    print(io, " ")
                end
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

Iterator for part-of-speech tagged words.

```jldoctest
julia> POS(read_tree("(S (NP (DT the) (N cat)) (VP ate))")
```
"""
POS(tree::Tree) =
    POSIterator((label(node), node.children[1]) for node in PreOrderDFS(tree)
                if length(children(node)) == 1 && isleaf(node.children[1]))

struct WordsIterator{T} <: ConstituencyTreeIterator
    iterator::T
end
Base.iterate(w::WordsIterator, state...) = iterate(w.iterator, state...)

"""
    Words(tree)

Iterator for words in a sentence.

```jldoctest
julia> POS(read_tree("(S (NP (DT the) (N cat)) (VP ate))")
```
"""
Words(tree::Tree) = WordsIterator(Leaves(tree))
