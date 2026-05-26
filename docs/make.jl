push!(LOAD_PATH,"../src/")


using Documenter, PlateArrays

makedocs(sitename="PlateArrays.jl",
pages = [ 
    "Home" => "index.md",
    "Quick Start Guide" => "quickstart.md",
    "API Reference" => "api-reference.md"
]
)

deploydocs(
    repo = "github.com/jensenlab/PlateArrays.git",
)
