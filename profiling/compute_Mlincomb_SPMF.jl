#Intended to be run from nep-pack/ directory or nep-pack/profiling directory
using NonlinearEigenproblems

using LinearAlgebra
using IterativeSolvers
using Random
using SparseArrays
import Base.exp


f1 = S -> -S;
f2 = S -> one(S);
f3 = S -> exp(-S);
f4 = S -> sqrt(10*S+100*one(S));

n=1000;
Random.seed!(1) # reset the random seed
K=[1:n;2:n;1:n-1]; J=[1:n;1:n-1;2:n]; # sparsity pattern of tridiag matrix
A1=sparse(K, J, rand(3*n-2))
A2=sparse(K, J, rand(3*n-2))
A3=sparse(K, J, rand(3*n-2))
A4=sparse(K, J, rand(3*n-2))

AA = [A1,A2,A3,A4]
fi = [f1,f2,f3,f4]
nep=SPMF_NEP(AA, fi)

n=size(nep,1);	k=20;
V=rand(n,k);	λ=rand()*im+rand();
a=rand(k)

z1=compute_Mlincomb(nep,λ,copy(V),a)
@time z1=compute_Mlincomb(nep,λ,V,a)
# old way of compute_Mlincomb used for SPMF
import NonlinearEigenproblems.NEPCore.compute_Mlincomb_from_MM
z2=compute_Mlincomb_from_MM(nep,λ,V,a)
@time z2=compute_Mlincomb_from_MM(nep,λ,V,a)
println("Error=",norm(z1-z2))
