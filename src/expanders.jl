import Documenter: @docerror
import Documenter.Selectors
import Documenter.Expanders: ExpanderPipeline, iscode

abstract type DatasetBlocks <: ExpanderPipeline end

abstract type AutoDatasetBlocks <: ExpanderPipeline end

Selectors.order(::Type{DatasetBlocks}) = 3.5
Selectors.order(::Type{AutoDatasetBlocks}) = 4.5

Selectors.matcher(::Type{DatasetBlocks},     node, page, doc) = iscode(node, "@datasets")
Selectors.matcher(::Type{AutoDatasetBlocks}, node, page, doc) = iscode(node, "@autodatasets")

function Selectors.runner(::Type{DatasetBlocks}, node, page, doc)
    @assert node.element isa MarkdownAST.CodeBlock
    x = node.element
    datanodes = Node[]
    lines = Documenter.find_block_in_file(x.code, page.source)
    @debug "Evaluating @datasets block:\n$(x.code)"
    for (_, line) in Documenter.parseblock(x.code, doc, page)
        ident = String(strip(line))
        dataset = try
            resolve(ident, resolvetype=false)
        catch err
            if err isa UnresolveableIdentifier
                admonition = first(Documenter.mdparse("""
                !!! warning "Unresolveable Identifier"
                    Could not resolve `$ident` to a data set.
                """, mode=:blocks))
                push!(datanodes, admonition)
                continue
            else
                rethrow(err)
            end
        end

        if haskey(doc.internal.bindings, dataset)
            @docerror(doc, :docs_block,
                """
                duplicate entry found for $(sprint(show, ident)) in `@datasets` block in $(Documenter.locrepr(page.source, lines))
                ```$(x.info)
                $(x.code)
                ```
                """)
            admonition = first(Documenter.mdparse("""
                !!! warning "Duplicated data set entry"
                    `$ident` has already beeen included in the generated documentation.
                """, mode=:blocks))
            push!(datanodes, admonition)
            continue
        end

        push!(datanodes, Node(DataNode(doc, page, dataset)))
        doc.internal.bindings[dataset] = nothing
    end
    node.element = DataNodesBlock(x)
    for docsnode in datanodes
        push!(node.children, docsnode)
    end
end

function Selectors.runner(::Type{AutoDatasetBlocks}, node, page, doc)
    @info "Running AutoDatasetBlocks"
    isempty(STACK) && error("The data collection stack is empty")
    @assert node.element isa MarkdownAST.CodeBlock
    x = node.element
    datanodes = Node[]
    collections = DataCollection[first(STACK)]
    for (ex, _) in Documenter.parseblock(x.code, doc, page)
        if ex.head == :(=) && first(ex.args) == :Collections &&
            ex.args[2].head == :vect
            collections = DataCollection[]
            for id in ex.args[2].args
                push!(collections, DataToolkitBase.getlayer(
                    if id != :nothing
                        something(tryparse(Base.UUID, id), id)
                    end))
            end
        else
            @warn "@AutoDatasetBlocks: strange expression, $ex"
        end
    end
    for collection in collections
        for dataset in collection.datasets
            push!(datanodes, Node(DataNode(doc, page, dataset)))
        end
    end
    node.element = DataNodesBlock(x)
    for docsnode in datanodes
        push!(node.children, docsnode)
    end
end
