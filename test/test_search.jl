using nqueen
using Test

@testset "test_search" begin
    sol = [1, 2, 2, 4]
    diag_up, diag_dn = diagonals(sol)
    @test diag_up == [1, 0, 1, 1, 0, 0, 1]
    @test diag_dn == [0, 0, 1, 3, 0, 0, 0]
    @test collisions(diag_up) == 0
    @test collisions(diag_dn) == 2
    nqueen.exchange!(1, 3, sol, diag_up, diag_dn)
    @test sol == [2, 2, 1, 4]
    diag_up_, diag_dn_ = diagonals(sol)
    @test diag_up_ == [0, 1, 2, 0, 0, 0, 1]
    @test diag_dn_ == [0, 1, 0, 2, 1, 0, 0]
    @test diag_up == diag_up_
    @test diag_dn == diag_dn_
    @test collisions(diag_up) == 1
    @test collisions(diag_dn) == 1
end
