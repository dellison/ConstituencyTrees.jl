using Documenter
using ConstituencyTrees

makedocs(
    sitename = "ConstituencyTrees.jl",
    format = Documenter.HTML(),
    modules = [ConstituencyTrees],
    pages = ["Home" => "index.md"],
    doctest = true)

# deploydocs(repo = "github.com/dellison/ConstituencyTrees.jl.git")
