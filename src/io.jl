@inline function show_board(sol::Array{Int})::Nothing
    n = length(sol)
    for i = 1:n
        for j = 1:n
            if sol[i] == j
                print("o ")
            else
                print(". ")
            end
        end
        println()
    end
end

@inline function show_log(
    sol::Array{Int},
    diag_up::Array{Int},
    diag_dn::Array{Int},
)::Nothing
    println("array: ", sol)
    show_board(sol)
    println("queens on upward diagonals: ", diag_up)
    println("queens on downward diagonals: ", diag_dn)
    n_colls = collisions(diag_up) + collisions(diag_dn)
    println("#collisions: ", n_colls)
    println()
end
