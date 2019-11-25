var documenterSearchIndex = {"docs":
[{"location":"#ConstituencyTrees.jl-1","page":"Home","title":"ConstituencyTrees.jl","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"ConstituencyTrees.jl is a Julia package for working with constituency trees of natural language sentences (also called parse trees, syntax trees).","category":"page"},{"location":"#Trees-1","page":"Home","title":"Trees","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"ConstituencyTree\n@tree_str\nread_tree\npprint","category":"page"},{"location":"#ConstituencyTrees.ConstituencyTree","page":"Home","title":"ConstituencyTrees.ConstituencyTree","text":"ConstituencyTree{T}\n\nConstituency parse tree of a natural language sentence.\n\n\n\n\n\n","category":"type"},{"location":"#ConstituencyTrees.@tree_str","page":"Home","title":"ConstituencyTrees.@tree_str","text":"@tree_str(str)\n\nString macro for reading a constituency parse tree from bracketed format.\n\ntree\"(S (NP (DT the) (N cat)) (VP (V ate)))\"\n\n\n\n\n\n","category":"macro"},{"location":"#ConstituencyTrees.Brackets.read_tree","page":"Home","title":"ConstituencyTrees.Brackets.read_tree","text":"read_tree(str)\n\n\n\n\n\n","category":"function"},{"location":"#ConstituencyTrees.pprint","page":"Home","title":"ConstituencyTrees.pprint","text":"pprint([io::IO,] tree; depth=0, indent=2, multiline=true)\n\nPrint a constituency parse tree in bracketed format.\n\n\n\n\n\n","category":"function"},{"location":"#","page":"Home","title":"Home","text":"POS\nWords\nproductions","category":"page"},{"location":"#ConstituencyTrees.POS","page":"Home","title":"ConstituencyTrees.POS","text":"POS(tree)\n\nIterator for part-of-speech tagged words.\n\njulia> POS(tree\"(S (NP (DT the) (N cat)) (VP (V ate)))\") |> collect\n3-element Array{Any,1}:\n (\"DT\", \"the\")\n (\"N\", \"cat\")\n (\"V\", \"ate\")\n\n\n\n\n\n","category":"function"},{"location":"#ConstituencyTrees.Words","page":"Home","title":"ConstituencyTrees.Words","text":"Words(tree)\n\nIterator for words in a sentence.\n\njulia> Words(tree\"(S (NP (DT the) (N cat)) (VP (V ate)))\") |> collect\n3-element Array{Any,1}:\n \"the\"\n \"cat\"\n \"ate\"\n\n\n\n\n\n","category":"function"},{"location":"#ConstituencyTrees.productions","page":"Home","title":"ConstituencyTrees.productions","text":"productions(tree; search = PreOrderDFS, nonterminal = identity, terminal = identity)\n\ntodo\n\n\n\n\n\n","category":"function"},{"location":"#Treebanks-1","page":"Home","title":"Treebanks","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"Treebank","category":"page"},{"location":"#ConstituencyTrees.Treebank","page":"Home","title":"ConstituencyTrees.Treebank","text":"Treebank(corpus::String)\nTreebank(corpus::Vector)\n\nA Treebank is an iterator over a corpus of trees in bracketed format.\n\n\n\n\n\n","category":"type"},{"location":"#Transformations-1","page":"Home","title":"Transformations","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"chomsky_normal_form\ncollapse_unary","category":"page"},{"location":"#ConstituencyTrees.chomsky_normal_form","page":"Home","title":"ConstituencyTrees.chomsky_normal_form","text":"chomsky_normal_form(tree, factor=RightFactored(), labelf)\n\nConvert a tree into chomsky normal form.\n\n\n\n\n\n","category":"function"},{"location":"#ConstituencyTrees.collapse_unary","page":"Home","title":"ConstituencyTrees.collapse_unary","text":"collapse_unary(tree, labelf=unary_label; collapse_pos=false, collapse_root=false)\n\ntodo\n\n\n\n\n\n","category":"function"}]
}