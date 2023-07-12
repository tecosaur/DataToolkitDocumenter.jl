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
    _println(io, "\n\\noindent\\rule{0.96\\textwidth}{0.5pt}\\\\")
    if isempty(node.dataset.loaders)
        latex(io, first(Documenter.mdparse("""
            !!! warning "Unloadable"
                This data set has not defined any loaders, and so cannot be loaded.
            """, mode=:blocks)))
    else
        types = map(t -> "\\texttt{" * sprint(latexesc, string(t)) * "}",
                    getfield.(node.dataset.loaders, :type) |>
                        Iterators.flatten |> unique)
        tjoiners = if length(types) == 0; String[]
        elseif length(types) == 1; [""]
        elseif length(types) == 2; [" or ", ""]
        else vcat(fill(", ", length(types)-2), ", or ", "")
        end
        _println(io, " This data set can be loaded as a ",
                 collect(zip(types, tjoiners) |> Iterators.flatten)...,
                 ".")
    end
    metalabels =
        [if haskey(node.dataset.parameters, "creator")
             "Creator" => sprint(latexesc, get(node.dataset, "creator"))
         end,
         if haskey(node.dataset.parameters, "date")
             "Date" => sprint(latexesc, get(node.dataset, "date"))
         end,
         if haskey(node.dataset.parameters, "doi")
             doi = replace(get(node.dataset, "doi"), r"^(?:https?://)?(?:doi\.org)?/?" => "")
             "DOI" => string("\\href{https://doi.org/", sprint(latexesc, doi),
                             "}{", sprint(latexesc, doi), "}")
         end,
         if haskey(node.dataset.parameters, "webpage")
             string("\\href{", sprint(latexesc, get(node.dataset, "webpage")), "}{Webpage}") => ""
         end]
    filter!(!isnothing, metalabels)
    if !isempty(metalabels)
        _println(io)
        for (label, content) in metalabels
            _print(io, "\\textbf{", label, "}~", content, "\\hspace{0.75em}")
        end
        _println(io)
    end
    _println(io, "\\end{adjustwidth}")
end
