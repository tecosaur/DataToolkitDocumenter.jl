import Documenter.LaTeXWriter: latex, latexesc, Context, _hash, _print, _println

function latex(io::Context, node::Node, ::DataNodesBlock)
    latex(io, node.children)
end

function latex(io::Context, ::Node, node::DataNode)
    id = _hash(Anchors.label(node.anchor))
    _print(io, "\\hypertarget{", id, "}{\\texttt{")
    latexesc(io, replace(sprint(show, MIME("text/plain"),
                                Identifier(node.dataset)),
                         "■:" => ""))
    _print(io, "}} ")
    _print(io, " --- DataSet")
    if haskey(node.dataset.parameters, "licence") || haskey(node.dataset.parameters, "license")
        licence = @something(get(node.dataset, "licence"),
                                get(node.dataset, "license"))
        link = nothing
        for (matcher, llink) in LICENCE_LINKS
            if !isnothing(match(matcher, licence))
                link = llink
                break
            end
        end
        if !isnothing(link)
            _print(io, "\\hfill\\href{")
            latexesc(io, last(link))
            _print(io, "}{", first(link), "}")
        else
            _print(io, " \\hfill ", licence)
        end
    else "" end
    _println(io, "\n\n\\begin{adjustwidth}{2em}{0pt}")
    _println(io)
    latex(io, node.description.children)
    _println(io)
    _println(io, "\n\\end{adjustwidth}")
end
