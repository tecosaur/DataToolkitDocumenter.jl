using Documenter
using DataToolkitDocumenter
using DataToolkitBase

loadcollection!(joinpath(@__DIR__, "..", "Data.toml"))

makedocs(;
    source = joinpath(@__DIR__, "src"),
    build = joinpath(@__DIR__, "build"),
    format = Documenter.HTML(),
    pages = ["Test" => "index.md"],
    sitename = "test"
)
