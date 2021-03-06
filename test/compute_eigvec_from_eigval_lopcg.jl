using NonlinearEigenproblemsTest
using NonlinearEigenproblems
using Random
using Test

# explicit import needed for overloading functions from packages
import NonlinearEigenproblems.NEPCore.compute_Mlincomb

@testset "compute eigvec lopcg" begin
    @bench @testset "dep0_sparse" begin
        nep = nep_gallery("dep0_sparse", 100);
        nept = DEP([copy(nep.A[1]'), copy(nep.A[2]')], nep.tauv);
        Random.seed!(13) # this results in a good start vector
        λ,Q,err = iar(nep,maxit=100,Neig=2,σ=1.0,γ=1,displaylevel=0,check_error_every=1);
        v=compute_eigvec_from_eigval_lopcg(nep,nept,λ[1]);
        errormeasure=default_errmeasure(nep);
        @test errormeasure(λ[1],v)<1e-5;
    end

    @bench @testset "pep0" begin
        nep = nep_gallery("pep0", 100);
        nept = PEP([copy(nep.A[1]'), copy(nep.A[2]'), copy(nep.A[3]')])
        λ,Q,err = iar(nep,maxit=100,Neig=2,σ=1.0,γ=1,displaylevel=0,check_error_every=1);
        v=compute_eigvec_from_eigval_lopcg(nep,nept,λ[1]);
        errormeasure=default_errmeasure(nep);
        @test errormeasure(λ[1],v)<1e-5;
    end

end
