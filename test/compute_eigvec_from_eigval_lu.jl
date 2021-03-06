using NonlinearEigenproblemsTest
using NonlinearEigenproblems
using Test

# explicit import needed for overloading functions from packages
import NonlinearEigenproblems.NEPCore.compute_Mlincomb

nep_test_problems=["pep0_sparse","dep0","pep0"]

@testset "Eigenvector extraction (small scale)" begin
    @testset "Test problem: $nep_test_problem" for nep_test_problem in nep_test_problems
    nep=nep_gallery(nep_test_problem)
    compute_Mlincomb(nep::DEP,λ::Number,V,a=ones(size(V,2)))=compute_Mlincomb_from_MM!(nep,λ,V,a)
    errormeasure=default_errmeasure(nep);
    λ,Q,err = iar(nep,maxit=50,Neig=5,σ=2.0,γ=3);
        @bench @testset "default_linsolvercreator" begin
            v=compute_eigvec_from_eigval_lu(nep,λ[1],default_linsolvercreator);
            @test errormeasure(λ[1],v)<eps()*10000;
        end
        @bench @testset "backslash_linsolvercreator" begin
            M0inv = backslash_linsolvercreator(nep,λ[1])
            v=compute_eigvec_from_eigval_lu(nep,λ[1],default_linsolvercreator);
            @test errormeasure(λ[1],v)<eps()*10000;
        end
        @bench @testset "Passing a linsolvercreator as argument" begin
            M0inv = default_linsolvercreator(nep,λ[1])
            v=compute_eigvec_from_eigval_lu(nep,λ[1],(nep, σ) -> M0inv);
            @test errormeasure(λ[1],v)<eps()*10000;
        end
    end
end


@testset "Eigenvector extraction (medium/large scale)" begin
    @testset "Test problem: $nep_test_problem" for nep_test_problem in nep_test_problems
    nep=nep_gallery(nep_test_problem,500)
    compute_Mlincomb(nep::DEP,λ::Number,V,a=ones(size(V,2)))=compute_Mlincomb_from_MM!(nep,λ,V,a)
    errormeasure=default_errmeasure(nep);
    λ,Q,err = iar(nep,maxit=100,Neig=5);
        @bench @testset "default_linsolvercreator" begin
            v=compute_eigvec_from_eigval_lu(nep,λ[1],default_linsolvercreator);
            @test errormeasure(λ[1],v)<eps()*10000;
        end
        @bench @testset "backslash_linsolvercreator" begin
            M0inv = backslash_linsolvercreator(nep,λ[1])
            v=compute_eigvec_from_eigval_lu(nep,λ[1],default_linsolvercreator);
            @test errormeasure(λ[1],v)<eps()*10000;
        end
        @bench @testset "Passing a linsolvercreator as argument" begin
            M0inv = default_linsolvercreator(nep,λ[1])
            v=compute_eigvec_from_eigval_lu(nep,λ[1],(nep, σ) -> M0inv);
            @test errormeasure(λ[1],v)<eps()*10000;
        end
    end
end
