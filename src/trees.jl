"""
    ConstituencyTree{T}

Constituency parse tree of a natural language sentence.
"""
struct ConstituencyTree{T}
    node::T
    children
end

const Tree = ConstituencyTree

Tree{T}(label) where T = Tree{T}(label, [])
Tree() = Tree{Any}(nothing, [])
Tree(node) = Tree(node, [])
Tree(node::String, child::String) = Tree(node, [child])
Tree(node, child::Tree, children...) = Tree(node, [child; children...])

AbstractTrees.children(tree::Tree) = tree.children
AbstractTrees.printnode(io::IO, tree::Tree) =
    print(io, ifelse(tree.node === nothing, "", tree.node))

isleaf(args...)    = true
isleaf(tree::Tree) = isempty(tree.children)

isterminal(x) = false
isterminal(tree::Tree) = length(tree.children) == 1 && isempty(children(tree.children[1]))

label(tree::Tree{Nothing}) = ""
label(tree::Tree) = tree.node
label(x::String) = x

function production(tree; nonterminal = identity, terminal = identity)
    lhs, rhs = label(tree), label.(children(tree))
    if isterminal(tree)
        return nonterminal(lhs), terminal.(rhs)
    else
        return nonterminal(lhs), nonterminal.(rhs)
    end
end

"""
    productions(tree; search = PreOrderDFS, nonterminal = identity, terminal = identity)

todo
"""
productions(tree; search = PreOrderDFS, ks...) =
    filter(p -> p[2] != (), map(p -> production(p;ks...), search(tree)))

Base.getindex(tree::ConstituencyTree, i) =
    i == 1 ? tree.node :
    1 <= i-1 <= length(children(tree)) ? tree.children[i-1] :
    error(BoundsError, "cannot access $tree at index $i")

Base.iterate(tree::ConstituencyTree, state=1) = (tree[state], state+1)

Base.keys(tree::ConstituencyTree) = 1:length(children(tree))

function Base.show(io::IO, tree::ConstituencyTree)
    print(io, typeof(tree))
    print_bracketed(io, tree; multiline = false)
end

Base.:(==)(t1::Tree, t2::Tree) = label(t1) == label(t2) && children(t1) == children(t2)

"""
    print_bracketed([io::IO,] tree; depth = 0, indent = 2, multiline = true)

Print a constituency parse tree in bracketed format.
"""
print_bracketed(tree; kws...) = print_bracketed(stdout, tree; kws...)
print_bracketed(io::IO, tree; kws...) = print(io, brackets(tree; kws...))

function brackets(tree; depth = 0, indent = 2, multiline = true)
    s = "(" * label(tree)
    if !isleaf(tree)
        for child in children(tree)
            if !isleaf(child)
                if multiline
                    s *= "\n"
                    s *= repeat(" ", (depth + 1) * indent)
                else
                    s *= " "
                end
                kws = (depth = depth + 1, indent = indent, multiline = multiline)
                s *= brackets(child; kws...)
            else
                s *= " " * label(child)
            end
        end
    end
    return s * ")"
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
julia> POS(tree"(S (NP (DT the) (N cat)) (VP (V ate)))") |> collect
3-element Array{Any,1}:
 ("DT", "the")
 ("N", "cat")
 ("V", "ate")
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
julia> Words(tree"(S (NP (DT the) (N cat)) (VP (V ate)))") |> collect
3-element Array{Any,1}:
 "the"
 "cat"
 "ate"
```
"""
Words(tree::Tree) = WordsIterator(Leaves(tree))
