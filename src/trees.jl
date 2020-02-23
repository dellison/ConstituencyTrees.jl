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

height(tree) = isleaf(tree) ? 1 : 1 + maximum(height.(children(tree)))

isleaf(args...)    = true
isleaf(tree::Tree) = isempty(tree.children)

isterminal(x) = false
isterminal(tree::Tree) = length(tree.children) == 1 && isempty(children(tree.children[1]))

label(tree::Tree{Nothing}) = ""
label(tree::Tree) = tree.node
label(x::String) = x

function production(tree; nonterminal=identity, terminal=identity)
    lhs, rhs = label(tree), label.(children(tree))
    if isterminal(tree)
        return nonterminal(lhs), terminal.(rhs)
    else
        return nonterminal(lhs), nonterminal.(rhs)
    end
end

"""
    productions(tree; search=PreOrderDFS, nonterminal=identity, terminal=identity)

Return a vector of (lhs, rhs) productions from a constituency parse tree.

# Arguments

- `tree`: the tree to search

# Keywords

- `nonterminal`: a function to call on nonterminal symbols.
- `terminal`: a function to call on terminal symbols.

# Returns

- a `Vector` of (lhs, rhs) tuples

"""
function productions(tree; search=PreOrderDFS, ks...)
    ps = [production(p; ks...) for p in search(tree)]
    return [p for p in ps if p[2] != ()]
end

function Base.show(io::IO, tree::ConstituencyTree)
    print(io, typeof(tree))
    pprint(io, tree; multiline=false)
end

Base.:(==)(t1::Tree, t2::Tree) = label(t1) == label(t2) && children(t1) == children(t2)

"""
    pprint([io::IO,] tree; indent=2, multiline=true)

Print a constituency parse tree in bracketed format.

# Arguments

- `io`: `IO` stream to write the tree to
- `tree`: the tree to search

# Keywords

- `multiline=true`: whether to include newlines in string representation
- `indent=2`: how many characters of whitespace to use in indentation (ignored if `multiline` is `false`)

# Returns

- bracketed `String` representation of the parse tree
"""
pprint(tree; kws...) = pprint(stdout, tree; kws...)
pprint(io::IO, tree; kws...) = print(io, brackets(tree; kws...))

function brackets(tree; depth=0, indent=2, multiline=true)
    s = "(" * label(tree)
    if !isleaf(tree)
        for child in children(tree)
            if !isleaf(child)
                if multiline
                    s *= "\n"
                    s *= repeat(" ", (depth + 1) * indent)
                else
                    if !isempty(label(tree))
                        s *= " "
                    end
                end
                kws = (depth=depth + 1, indent=indent, multiline=multiline)
                s *= brackets(child; kws...)
            else
                if !isempty(label(child))
                    s *= " " * label(child)
                end
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

# Arguments

- `tree`: the tree to search

# Returns

- `POSIterator`- a lazy iterator over (POS, token) pairs
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

# Arguments

- `tree`: the tree to search

# Returns

- `WordsIterator`: an iterator over tokens
"""
Words(tree::Tree) = WordsIterator(Leaves(tree))
