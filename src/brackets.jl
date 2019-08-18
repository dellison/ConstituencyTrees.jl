module Brackets

export read_bracketed_tree

import ...Tree

import Automa
import Automa.RegExp: @re_str
const re = Automa.RegExp

struct Open end
struct Close end
struct Node; val end
struct Leaf; val end

function token!(stack, node::Node)
    push!(stack, Tree(node.val))
    return stack
end
function token!(stack, ::Close)
    node = pop!(stack)
    push!(last(stack).children, node)
    return stack
end
function token!(stack, leaf::Leaf)
    push!(last(stack).children, leaf.val)
    return stack
end

function node_string(data, from, to)
    !isvalid(data, from) && (from += 1)
    !isvalid(data, to)   && (to -= 1)
    return data[from:to]
end
const leaf_string = node_string

struct TreeReader
    tokenizer
    read
end

function TreeReader()
    close      = re"\)"
    node       = re"\([ \t\n]*[^ \)\(\t\n]*"
    leaf       = re"[^ \)\(\t\n]+"
    whitespace = re"[ \t\n]*"

    tokenizer = Automa.compile(
        node       => :(token!(stack, Node(read_node(node_string(data, ts+1, te))))),
        close      => :(token!(stack, Close())),
        leaf       => :(token!(stack, Leaf(read_leaf(leaf_string(data, ts, te))))),
        whitespace => :()
    )

    context = Automa.CodeGenContext()
    reader = @eval function (data; read_node = identity, read_leaf = identity)
        stack = Tree[Tree()]
        
        $(Automa.generate_init_code(context, tokenizer))
        p_end = p_eof = sizeof(data)
        while p ≤ p_eof && cs > 0
            $(Automa.generate_exec_code(context, tokenizer))
        end
        if cs != 0
            error("parsing error at position $p: code ", cs)
        end
        return last(last(stack).children)
    end

    return TreeReader(tokenizer, reader)
end

const READER = TreeReader()

"""
    read_bracketed_tree(str)


"""
function read_bracketed_tree end
read_bracketed_tree(str; ks...) = READER.read(str; ks...)
read_bracketed_tree(reader, str; ks...) = reader.read(str; ks...)

(reader::TreeReader)(data; ks...) = reader.read(data; ks...)

end # module
