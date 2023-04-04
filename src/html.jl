import Documenter.HTMLWriter: DCtx, domify
import Documenter.DOM: DOM, Tag, @tags

function domify(dctx::DCtx, node::Node, ::DataNodesBlock)
    domify(dctx, node.children)
end

function domify(dctx::DCtx, ::Node, node::DataNode)
    @tags article header section div a p span code i

    name = replace(sprint(show, MIME("text/plain"),
                          Identifier(node.dataset)),
                   "■:" => "")

    topbar = header(a[".docstring-binding",
                      :id=>node.anchor.id,
                      :href=>"#$(node.anchor.id)"](code(name)),
                    " — ",
                    span[".docstring-category"]("DataSet"))

    description = if !isnothing(node.description)
        section(div(domify(dctx, node.description)))
    else "" end

    loadinfo = if isempty(node.dataset.loaders)
        section(div(domify(dctx,first(Documenter.mdparse("""
            !!! warning "Unloadable"
                This data set has not defined any loaders, and so cannot be loaded.
            """, mode=:blocks)))))
    else
        types = map(t -> string(t) |> code,
                    getfield.(node.dataset.loaders, :type) |>
                        Iterators.flatten |> unique)
        tjoiners = if length(types) == 0; String[]
        elseif length(types) == 1; [""]
        elseif length(types) == 2; [" or ", ""]
        else vcat(fill(", ", length(types)-2), ", or ", "")
        end
        section(p(i[".fas.fa-file-import"](),
                    " This data set can be loaded as a ",
                    collect(zip(types, tjoiners) |> Iterators.flatten)...,
                    "."))
    end

    article[".docstring"](topbar, description, loadinfo)
end
