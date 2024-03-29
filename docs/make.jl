using MusicXML
using Documenter

# using Pkg
# pkg"activate .."
# push!(LOAD_PATH,"../src/")

makedocs(;
    modules=[MusicXML],
    authors="Amin Yahyaabadi",
    repo="https://github.com/JuliaMusic/MusicXML.jl/blob/{commit}{path}#L{line}",
    sitename="MusicXML.jl",
    format=Documenter.HTML(;
        canonical="https://JuliaMusic.github.io/MusicXML.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaMusic/MusicXML.jl",
)
