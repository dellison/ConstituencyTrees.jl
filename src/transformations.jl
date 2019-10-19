abstract type           Factorization end
struct LeftFactored  <: Factorization end
struct RightFactored <: Factorization end

"""
    chomsky_normal_form(tree, [factor, labelf])

Convert a tree into chomsky normal form.
"""
function chomsky_normal_form(tree, factor::Factorization=RightFactored(), labelf = nltk_factored_label)
    T, node, ch = typeof(tree), label(tree), children(tree)
    N = length(ch)
    if isleaf(tree) || isterminal(tree)
        return tree
    elseif N == 1
        return T(node, [chomsky_normal_form(ch[1], factor, labelf)])
    elseif N == 2
        return T(node, [chomsky_normal_form(child, factor, labelf) for child in ch])
    else
        left, right = factorize(tree, factor, labelf)
        return T(node, [chomsky_normal_form(T(left...), factor, labelf),
                        chomsky_normal_form(T(right...), factor, labelf)])
    end
end

function factorize(tree, lf::LeftFactored, labelf)
    T, ch = typeof(tree), children(tree)
    N = length(ch)
    l_children = ch[1:N-1]
    l_label = labelf(tree, l_children)
    if length(l_children) > 2
        l_children = [T(c...) for c in factorize(T(label(tree), l_children), lf, labelf)]
    end
    r = last(ch)
    return ((l_label, l_children), (label(r), children(r)))
end
function factorize(tree, rf::RightFactored, labelf)
    T, ch = typeof(tree), children(tree)
    r_children = ch[2:end]
    r_label = labelf(tree, r_children)
    if length(r_children) > 2
        r_children = [T(c...) for c in factorize(T(label(tree), r_children), rf, labelf)]
    end
    l = first(ch)
    return ((label(l), children(l)), (r_label, r_children))
end

"""
    collapse_unary(tree, labelf=unary_label; collapse_pos=false, collapse_root=false)

todo
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
            node, ch = labelf(n, children(tree)[1]), children(children(tree)[1])
            return collapse_unary(T(node, ch); kw...)
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
