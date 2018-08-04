using Base.Test

include(normpath(string(@__DIR__), "..", "..", "src", "nleigs", "lusolver.jl"))

function lusolve_and_verify(funA, shift, y)
    x = lusolve(funA, shift, y)
    @test funA(shift) * x ≈ y
end

macro testcache(ex, cache_size)
    :(
        $(esc(ex));
        @test length(lucache) == $cache_size
    )
end

function run_tests(funA, y)
    @testcache lureset() 0
    @testcache lusolve_and_verify(funA, 2.5, y) 1
    @testcache lusolve_and_verify(funA, 2.5, y) 1
    @testcache lusolve_and_verify(funA, 3.5, y) 2
    @testcache lureset() 0
    @testcache lusolve_and_verify(funA, 2.5, y) 1
end

srand(0)
n = 20
y = collect(1.0:n)

@testset "cached_lu_solver" begin
    @testcache () 0

    # sparse matrix
    A = sprandn(n, n, .1)
    funA = shift -> A + im * shift * speye(n, n)
    run_tests(funA, y)

    # full matrix
    A = randn(n, n)
    funA = shift -> A + im * shift * eye(n, n)
    run_tests(funA, y)
end

#=
function solve(A::Base.LinAlg.LU, AA, y)
    x = A[:U] \ (A[:L] \ y[A[:p],:])
    # improve accuracy
    resid = y - AA * x
    err = A[:U] \ (A[:L] \ resid[A[:p],:])
    x + err
end

function solve(A::Base.SparseArrays.UMFPACK.UmfpackLU, AA, y)
    x = zeros(length(y), 1)
    x[A[:q]] = A[:U] \ (A[:L] \ (A[:Rs] .* y)[A[:p]])
    # improve accuracy
    resid = y - AA * x
    err = zeros(length(y), 1)
    err[A[:q]] = A[:U] \ (A[:L] \ (A[:Rs] .* resid)[A[:p]])
    x + err
end

function solve2(A::Base.LinAlg.LU, AA, y)
    x = A \ y
    # improve accuracy
    resid = y - AA * x
    err = A \ resid
    x + err
end

function solve2(A::Base.SparseArrays.UMFPACK.UmfpackLU, AA, y)
    x = A \ y
    # improve accuracy
    resid = y - AA * x
    err = A \ resid
    x + err
end

# matlab sparse luf: Elapsed time is 2.982806 seconds.
# matlab full luf: Elapsed time is 1.012269 seconds.
# matlab sparse luf solve: Elapsed time is 0.018604 seconds. (norm 5.4267e-06)
# matlab corrected sparse luf solve: Elapsed time is 0.041630 seconds. (norm 1.99e-09)

macro timel(prefix, ex)
    :( print("\n"*$prefix), @time $(esc(ex)) )
end

function cached_lu_solver()
    n = 5000

    srand(0)
    As = sprandn(n, n, .005) #+ spdiagm(0 => randn(n, 1))
    #As[43, 123] = 100000
    A = full(As)

    @timel "Full LU fact" F=lufact(A)
    @timel "Sparse LU fact" Fs=lufact(As)

    y = 1:n


    @timel "Full solve" x = A\y
    println(norm(y - A*x))

    @timel "Sparse solve" x = As\y
    println(norm(y - A*x))

    @timel "Full lufact solve " x = F\y
    println(norm(y - A*x))

    @timel "Sparse lufact solve" x = Fs\y
    println(norm(y - A*x))

    @timel "Full corrected solve" x = solve(F, A, y)
    println(norm(y - A*x))

    @timel "Sparse corrected solve" x = solve(Fs, A, y)
    println(norm(y - A*x))

    @timel "Full lufact corrected solve" x = solve2(F, A, y)
    println(norm(y - A*x))

    @timel "Sparse lufact corrected solve" x = solve2(Fs, A, y)
    println(norm(y - A*x))
end

cached_lu_solver()
=#
