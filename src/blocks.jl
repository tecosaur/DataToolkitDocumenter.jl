import Documenter.Object, Documenter.AbstractDocumenterBlock

struct DataNode <: AbstractDocumenterBlock
    page::Documenter.Page
    anchor::Documenter.Anchor
    dataset::DataSet
    description::Union{MarkdownAST.Node, Nothing}
end

function DataNode(doc, page::Documenter.Page, dataset::DataSet)
    slug = Documenter.slugify(@advise dataset string(Identifier(dataset)))
    anchor = Documenter.anchor_add!(doc.internal.docs, dataset, slug, page.build)
    description = if (desc = get(dataset, "description")) |> !isnothing
        # Taken from `create_docsnode`
        ast = convert(Node, Markdown.parse(desc))
        for headingnode in ast.children
            headingnode.element isa MarkdownAST.Heading || continue
            boldnode = Node(MarkdownAST.Strong())
            for textnode in collect(headingnode.children)
                push!(boldnode.children, textnode)
            end
            headingnode.element = MarkdownAST.Paragraph()
            push!(headingnode.children, boldnode)
        end
        ast
    end
    DataNode(page, anchor, dataset, description)
end

struct DataNodesBlock <: AbstractDocumenterBlock
    codeblock :: MarkdownAST.CodeBlock
end

MarkdownAST.iscontainer(::DataNodesBlock) = true
MarkdownAST.can_contain(::DataNodesBlock, ::MarkdownAST.AbstractElement) = false
MarkdownAST.can_contain(::DataNodesBlock, ::Union{DataNode, MarkdownAST.Admonition}) = true
