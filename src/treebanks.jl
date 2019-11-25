struct TreeReader{T}
    io::T

    function TreeReader(input::String)
        io = isfile(input) ? open(input) : IOBuffer(input)
        return new{typeof(io)}(io)
    end
end

function next_tree(reader::TreeReader)
    depth = 0
    input, buf = reader.io, IOBuffer()
    while !eof(input)
        c = Char(read(reader.io, 1)[1])
        !isvalid(c) && continue
        c == '(' && (depth += 1)
        c == ')' && (depth -= 1)
        write(buf, c)
        c == ')' && depth == 0 && break
    end
    str = String(take!(buf))
    try
        tree = read_tree(str)
        readuntil(input, '(')
        return tree
    catch err
        @show err str
        throw(err)
    end
end

function Base.iterate(reader::TreeReader, state...)
    if eof(reader.io)
        close(reader.io)
        return nothing
    else
        return (next_tree(reader), position(reader.io))
    end
end

struct Treebank
    files::Vector{String}
end

"""
    Treebank(corpus::String)
    Treebank(corpus::Vector)

A Treebank is an iterator over a corpus of trees in bracketed format.
"""
function Treebank(corpus::String)
    if isfile(corpus)
        Treebank([corpus])
    elseif isdir(corpus)
        # todo
    else
        error("don't know how to read treebank '$corpus'")
    end
end

function Base.iterate(treebank::Treebank)
    iter = TreebankIterator(treebank, 1, TreeReader(treebank.files[1]))
    tree, state = iterate(iter)
    return (tree, (iter, state))
end
function Base.iterate(treebank::Treebank, state)
    (iter, st) = state
    next = iterate(iter, st)
    if next == nothing
        return nothing
    else
        tree, next_state = next
        return (tree, (iter, next_state))
    end
end

Base.IteratorEltype(::Type{<:Treebank}) = Base.HasEltype()
Base.eltype(::Type{<:Treebank})         = ConstituencyTree
Base.IteratorSize(::Type{<:Treebank})   = Base.SizeUnknown()

mutable struct TreebankIterator
    tb::Treebank
    i::Int
    r::TreeReader
end
function Base.iterate(t::TreebankIterator)
    return iterate(t.r)
end
function Base.iterate(t::TreebankIterator, state)
    next = iterate(t.r, state)
    if next === nothing
        close(t.r.io)
        if t.i < length(t.tb.files)
            t.i += 1
            t.r = TreeReader(t.tb.files[t.i])
            return iterate(t.r)
        end
    else
        return next        
    end
end
