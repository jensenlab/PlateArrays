push!(LOAD_PATH,"../src/")


using Documenter, PlateArrays

makedocs(sitename="PlateArrays.jl",
pages = [ 
    "Home" => "index.md"
]
)

deploydocs(
    repo = "github.com/jensenlab/PlateArrays.git",
)
