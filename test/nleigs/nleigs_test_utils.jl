function nleigs_verify_lambdas(nrlambda, nep::NEP, X, lambda, tol = 1e-5)
    @test length(lambda) == nrlambda

    @printf("Found %d lambdas:\n", length(lambda))
    for i in eachindex(lambda)
        λ = lambda[i]
        nrm = norm(compute_Mlincomb(nep, λ, X[:, i]))
        @test nrm < tol
        @printf("λ[%d] = %s (norm = %.3g)\n", i, λ, nrm)
    end
end

function funM(NLEP, λ)
    as_matrix(x::Number) = (M = Matrix{eltype(x)}(1,1); M[1] = x; M)
    if haskey(NLEP, "B")
        M = copy(NLEP["B"][1])
        for j = 2:length(NLEP["B"])
            M += λ^(j-1) * NLEP["B"][j]
        end
        c1 = 1
    else
        M = NLEP["f"][1](as_matrix(λ))[1] * NLEP["C"][1]
        c1 = 2
    end
    for j = c1:length(get(NLEP, "C", []))
        M += NLEP["f"][j](as_matrix(λ))[1] * NLEP["C"][j]
    end
    return M
end
