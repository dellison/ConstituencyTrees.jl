abstract type           Factorization end
struct LeftFactored  <: Factorization end
struct RightFactored <: Factorization end

"""
    chomsky_normal_form(tree, factor, labelf)

todo
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
    ch = children(tree)
    T, N = typeof(tree), length(ch)
    l_children = ch[1:N-1]
    if length(l_children) > 2
        l_children = [T(c...) for c in factorize(T(label(tree), l_children), lf, labelf)]
    end
    l_label = labelf(tree, l_children)
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

function nltk_factored_label(parent, children, child_sep = "|", parent_sep = "^")
    return label(parent) * child_sep * "<" * join(label.(children), "-") * ">"
end

function cnf_label(parent, children, child_sep = "|", parent_sep = "^")
    return label(parent) * child_sep * "<" * join(label.(children), "-") * ">"
end

prime_label(parent, args...) = parent * "'"
