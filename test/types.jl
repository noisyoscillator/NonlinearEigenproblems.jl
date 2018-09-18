# Tests for core functionality

push!(LOAD_PATH, @__DIR__); using TestUtils
using NonlinearEigenproblems
using Test

@bench @testset "NEW" begin

n=3;
A1 = rand(n,n); A2 = rand(n,n); A3 = rand(n,n); A4 = rand(n,n);
f1 = S -> one(S); f2 = S -> -S; f3 = S -> exp(-S); f4 = S -> sqrt(S)
nep=SPMF_NEP([A1,A2,A3,A4],[f1,f2,f3,f4]);


f1 = S -> 1
@test_throws ErrorException nep=SPMF_NEP([A1,A2,A3,A4],[f1,f2,f3,f4]);



end