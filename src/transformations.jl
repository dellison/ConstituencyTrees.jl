abstract type           Factorization end
struct LeftFactored  <: Factorization end
struct RightFactored <: Factorization end

"""
    chomsky_normal_form(tree, factor=RightFactored(), labelf)

Convert a tree into chomsky normal form.

# Arguments

- `tree`: the constituency tree to convert
- `factor=RightFactored()`: can be `LeftFactored()` or `RightFactored()`
- `labelf`: function (called like `labelf(tree, children)`)

# Returns

- a tree of the same type as its argument 
"""
function chomsky_normal_form(tree, factor::Factorization=RightFactored(), labelf=nltk_factored_label)
    T, node, ch = typeof(tree), label(tree), children(tree)
    N = length(ch)
    cnf = t -> chomsky_normal_form(t, factor, labelf)
    if isleaf(tree) || isterminal(tree)
        return tree
    elseif N == 1
        return cnf(ch[1])
    elseif N == 2
        return T(node, cnf.(ch))
    else
        return T(node, cnf.(factorize(tree, factor, labelf)))
    end
end

function factorize(tree, lf::LeftFactored, labelf)
    T, ch = typeof(tree), children(tree)
    N = length(ch)
    l_children = ch[1:N-1]
    l_label = labelf(tree, l_children)
    if length(l_children) > 2
        l_children = factorize(T(label(tree), l_children), lf, labelf)
    end
    r = last(ch)
    return [T(l_label, l_children), T(label(r), children(r))]
end
function factorize(tree, rf::RightFactored, labelf)
    T, ch = typeof(tree), children(tree)
    r_children = ch[2:end]
    r_label = labelf(tree, r_children)
    if length(r_children) > 2
        r_children = factorize(T(label(tree), r_children), rf, labelf)
    end
    l = first(ch)
    return [T(label(l), children(l)), T(r_label, r_children)]
end

"""
    collapse_unary(tree, labelf=unary_label; collapse_pos=false, collapse_root=false)

Transform a parse tree by collapsing all single-child nodes.

# Arguments

- `tree`: parse tree to transform
- `labelf`: function called to create new label representing the collapsed nodes.

# Keywords

- `collapse_pos=false`: whether to collapse `(POS word)` nodes
- `collapse_root=false`: whether to collapse the top-level root node

# Returns

- a transformed tree of the same type as its argument 
"""
function collapse_unary(tree, labelf=unary_label; collapse_pos=false, collapse_root=false)
    isleaf(tree) && return tree
    T, n = typeof(tree), label(tree)
    kw = (collapse_pos=collapse_pos, collapse_root=collapse_root)
    if !collapse_root
        f = x -> collapse_unary(x, labelf; collapse_pos=collapse_pos, collapse_root=true)
        return T(n, f.(children(tree)))
    elseif collapse_pos && isterminal(tree)
        return children(tree)[1]
    elseif length(children(tree)) == 1
        if isterminal(tree)
            return tree
        else
            node = labelf(n, children(tree)[1])
            ch = children(children(tree)[1])
            return collapse_unary(T(node, ch), labelf; kw...)
        end
    else
        return T(n, [collapse_unary(c, labelf; kw...) for c in children(tree)])
    end
end

function nltk_factored_label(parent, children, child_sep = "|", parent_sep = "^")
    return label(parent) * child_sep * "<" * join(label.(children), "-") * ">"
end

parent_label(parent, args...) = parent
prime_label(parent, args...) = parent * "'"

unary_label(parent, children) = join([label(parent), label(children)], "+")
