using Test

cleanup() = rm(joinpath(@__DIR__, "docs", "build"), recursive=true, force=true)

const NEEDLES = [
    """<article class="docstring"><header><a class="docstring-binding" id="test:sample" href="#test:sample"><code>sample</code></a> — <span class="docstring-category">DataSet</span></header><section><div><p>Some description</p></div></section><section><div><div class="admonition is-warning"><header class="admonition-header">Unloadable</header><div class="admonition-body"><p>This data set has not defined any loaders, and so cannot be loaded.</p></div></div></div></section></article>""",
    """<article class="docstring"><header><a class="docstring-binding" id="test:formatted" href="#test:formatted"><code>formatted</code></a> — <span class="docstring-category">DataSet</span></header><section><div><p>Text with <strong>bold</strong> and <em>italics</em></p></div></section><section><div><div class="admonition is-warning"><header class="admonition-header">Unloadable</header><div class="admonition-body"><p>This data set has not defined any loaders, and so cannot be loaded.</p></div></div></div></section></article>""",
    """<article class="docstring"><header><a class="docstring-binding" id="test:iris" href="#test:iris"><code>iris</code></a> — <span class="docstring-category">DataSet</span></header><section><div><p>The Iris flower data set or Fisher&#39;s Iris data set is a multivariate data set introduced by the British statistician and biologist Ronald Fisher in his 1936 paper <em>&quot;The use of multiple measurements in taxonomic problems as an example of linear discriminant analysis&quot;</em>.</p><p>The data set consists of 50 samples from each of three species of Iris (Iris <strong>setosa</strong>, Iris <strong>virginica</strong> and Iris <strong>versicolor</strong>). Four features were measured from each sample: the length and the width of the sepals and petals, in centimetres.</p></div></section><section><p><i class="fas fa-file-import"></i> This data set can be loaded as a <code>DataFrame</code> or <code>Matrix</code>.</p></section></article>""",
    """<div class="admonition is-warning"><header class="admonition-header">Unresolveable Identifier</header><div class="admonition-body"><p>Could not resolve <code>nonexistant</code> to a data set.</p></div></div><div class="admonition is-warning"><header class="admonition-header">Duplicated data set entry</header><div class="admonition-body"><p><code>sample</code> has already beeen included in the generated documentation.</p></div></div>"""
]

@testset "Mockup" begin
    cleanup()
    include(joinpath(@__DIR__, "docs", "make.jl"))
    indexfile = joinpath(@__DIR__, "docs", "build", "index.html")
    @test isfile(indexfile)
    content = read(indexfile, String)
    for needle in NEEDLES
        @test occursin(needle, content)
    end
end

cleanup()
