# Gun: variant S

using Base.Test

include("nleigs_test_utils.jl")
include("gun_test_utils.jl")
include("../../src/nleigs/method_nleigs.jl")

verbose = false

NLEP, Sigma, Xi, v0, nodes, funres = gun_init()

options = Dict(
    "disp" => verbose ? 1 : 0,
    "minit" => 70,
    "maxit" => 100,
    "v0" => v0,
    "funres" => funres,
    "nodes" => nodes,
    "static" => true)

# solve nlep
@time X, lambda, res, solution_info = nleigs(NLEP, Sigma, Xi=Xi, options=options, return_info=verbose)

@testset "Gun: variant S" begin
    nleigs_verify_lambdas(21, NLEP, X, lambda)
end

if verbose
    include("nleigs_residual_plot.jl")
    nleigs_residual_plot("Gun: variant S", solution_info, Sigma; ylims=[1e-17, 1e-1])
end
