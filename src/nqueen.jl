module nqueen

using Dates

export show_board
export construct
export fast_tabu_search!
export collisions
export diagonals
export show_log

include("util.jl")
include("io.jl")
include("search.jl")

end
