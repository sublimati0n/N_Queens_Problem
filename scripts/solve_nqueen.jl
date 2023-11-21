using nqueen
using ProfileSVG

@inline function main()
    LOG = false
    if length(ARGS) == 0
        println("\$1: #queens")
    end
    n = parse(Int, ARGS[1])
    time_threshold = 60.0

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
    println("--------- finish fast tabu search ---------")

    # Show result
    println("--------- Result of tabu search ---------")
    if LOG
        show_log(sol, up, dn)
    end
end
@showtime main()
