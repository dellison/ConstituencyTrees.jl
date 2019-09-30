using Documenter
using ConstituencyTrees

DocMeta.setdocmeta!(ConstituencyTrees,
                    :DocTestSetup, :(using ConstituencyTrees); recursive=true)

makedocs(
    sitename = "ConstituencyTrees.jl",
    format = Documenter.HTML(),
    modules = [ConstituencyTrees],
    pages = ["Home" => "index.md"],
    doctest = true)

deploydocs(repo = "github.com/dellison/ConstituencyTrees.jl.git")
