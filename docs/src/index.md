# ConstituencyTrees.jl

ConstituencyTrees.jl is a Julia package for working with constituency trees of natural language sentences (also called parse trees, syntax trees).

## Trees

```@docs
ConstituencyTree
@tree_str
read_tree
pprint
```

```@docs
POS
Words
productions
```

## Transformations
```@docs
chomsky_normal_form
collapse_unary
```
