module nqueen

using Dates
using Random

export show_board
export construct
export fast_tabu_search!
export collisions
export diagonals
export show_log

include("util.jl")
include("io.jl")
include("search.jl")

@inline function julia_main()::Cint
    LOG = false
    if length(ARGS) == 0
        println("\$1: #queens")
    end
    n = parse(Int, ARGS[1])
    time_threshold = 600.0

    sol = Array(1:n)
    up, dn = construct(sol)  # construct initial solution by random greedy

    println("--------- Initial solution (random greedy) ---------")
    if LOG
        show_log(sol, up, dn)
    end

    println("--------- starting fast tabu search ---------")
    fast_tabu_search!(
        sol, up, dn,
        LOG=LOG,
        time_threshold=time_threshold
    )

    # Show result
    if LOG
        println("--------- Result of tabu search ---------")
        show_log(sol, up, dn)
    end
    return 0
end

end
