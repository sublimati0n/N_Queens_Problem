@inline function diagonals(sol::Array{Int})::Tuple{Array{Int}, Array{Int}}
    # ボード上の各対角線上のクイーンの数を決定する

    n = length(sol)  # ボードの大きさ
    n_diag = 2 * n - 1  # 対角線の数

    diag_up = zeros(Int, n_diag)
    diag_dn = zeros(Int, n_diag)

    @inbounds @simd for i = 1:n
        # 行i列sol[j]のクイーンによって攻撃される斜め上対角線
        d = i + sol[i] - 1  # 対角線のインデックス
        diag_up[d] += 1

        # 行i列sol[j]のクイーンによって攻撃される斜め下対角線
        d = n + sol[i] - i  # 対角線のインデックス
        diag_dn[d] += 1
    end

    return diag_up, diag_dn
end

@inline function collisions(diag::Array{Int})::Int
    # 対角線上の衝突総数を返す
    n_colls = 0
    @inbounds for i in diag
        if i == 0
            continue
        end
        # この対角線上に1つ以上のクイーンが既に配置されている
        n_colls += i - 1
    end
    return n_colls
end

@inline function exchange!(
    i::Int,
    j::Int,
    sol::Array{Int},
    diag_up::Array{Int},
    diag_dn::Array{Int}
)::Nothing
    # 行iと行jを交換し、変更に伴う対角線情報を更新する
    n = length(sol)

    d = i + sol[i] - 1
    diag_up[d] -= 1
    d = j + sol[j] - 1
    diag_up[d] -= 1

    d = n + sol[i] - i
    diag_dn[d] -= 1
    d = n + sol[j] - j
    diag_dn[d] -= 1

    # iとjの位置を交換する
    sol[i], sol[j] = sol[j], sol[i]

    d = i + sol[i] - 1
    diag_up[d] += 1
    d = j + sol[j] - 1
    diag_up[d] += 1

    d = n + sol[i] - i
    diag_dn[d] += 1
    d = n + sol[j] - j
    diag_dn[d] += 1
    return
end

@inline function construct(sol::Array{Int})::Tuple{Array{Int}, Array{Int}}
    # 貪欲的に初期解を構成する
    n = length(sol)
    n_diag = 2n - 1

    diag_up = zeros(Int, n_diag)
    diag_dn = zeros(Int, n_diag)

    cand = Array(1:n)
    trials = 10 * floor(Int, log10(n))  # number of random trials
    @inbounds for i = 1:n
        forelse = true
        @inbounds for _ in 1:trials
            col_id = rand(1:length(cand))
            col = cand[col_id]
            colls = diag_up[i + col - 1] + diag_dn[n - i + col]
            if colls == 0
                sol[i] = col
                diag_up[i + col - 1] += 1
                diag_dn[n - i + col] += 1
                deleteat!(cand, col_id)
                forelse = false
                break
            end
        end
        if forelse
            mincolls = 100000000000
            col = -1
            col_id = -1
            @inbounds for j in 1:length(cand)
                colls = diag_up[i + cand[j] - 1] + diag_dn[n - i + cand[j]]
                if colls < mincolls
                    mincolls = colls
                    col = cand[j]
                    col_id = j
                end
            end
            @assert col != -1
            @assert col_id != -1
            sol[i] = col
            diag_up[i + col - 1] += 1
            diag_dn[n - i + col] += 1
            deleteat!(cand, col_id)
        end
    end
    return diag_up, diag_dn
end

@inline function fast_tabu_search!(
    sol::Array{Int},
    diag_up::Array{Int},
    diag_dn::Array{Int};
    LOG::Bool = false,  # 探索中の解と補助変数を表示するかどうか。表示はかなり遅いので注意
    time_threshold::Float64 = 60.0
)::Nothing
    n = length(sol)
    tabu = ones(Int, n) .* -1
    tabulen = min(10, n)

    timekeeper = TimeKeeper(now(), time_threshold)
    n_iter = 0

    while true
        if isTimeOver(timekeeper)
            println("====================== Timeout ======================")
            return
        end
        n_iter += 1

        i_star = -1
        colls_star = -1
        forelse = true
        @inbounds for i in n:-1:1
            colls = diag_up[i + sol[i] - 1] + diag_dn[n - i + sol[i]]
            if colls > 2
                i_star = i
                colls_star = colls
                forelse = false
                break
            end
        end
        if forelse
            # 衝突がないので、探索を終了する
            println("====================== Found solution ======================")
            return
        end

        println("swap candidate is ", i_star)
        delta = -999999999
        j_star = -1
        @inbounds for j in 1:n
            if tabu[j] >= n_iter || j == i_star
                continue
            end
            temp = (diag_up[j + sol[j] - 1] + diag_dn[n - j + sol[j]] + colls_star) - (diag_up[i_star + sol[j] - 1] + diag_dn[n - i_star + sol[j]] + diag_up[j + sol[i_star] - 1] + diag_dn[n - j + sol[i_star]])
            if temp > delta
                delta = temp
                j_star = j
            end
        end

        println("iter=", n_iter, ": swap ", i_star, "&", j_star, " delta=", delta)
        if j_star == -1  # タブーリストをクリアする
            tabulen = floor(Int, tabulen / 2) + 1
            tabu = ones(Int, n) .* -1
        else
            tabu[i_star] = tabu[j_star] = n_iter + rand(1:tabulen)
            exchange!(i_star, j_star, sol, diag_up, diag_dn)
        end

        if LOG
            show_log(sol, diag_up, diag_dn)
        end
    end
end
