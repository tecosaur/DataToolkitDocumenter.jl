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
    _println(io, " --- DataSet\n")
    _println(io, "\\begin{adjustwidth}{2em}{0pt}")
    _println(io)
    latex(io, node.description.children)
    _println(io)
    _println(io, "\n\\end{adjustwidth}")
end
