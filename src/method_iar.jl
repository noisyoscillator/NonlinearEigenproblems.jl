export iar
# The Infinite Arnoldi method

function iar(
 nep::NEP;
 maxit=30,
 linsolvercreator::Function=default_linsolvercreator,
 tol=1e-12,
 Neig=maxit,
 errmeasure::Function = default_errmeasure(nep::NEP),
 σ=0.0,
 γ=1,
 v0=rand(size(nep,1),1),
 displaylevel=0,
 p=1
)

 n = size(nep,1);
 m = maxit;

 # initialization
 V = zeros(Complex128,n*(m+1),m+1);
 H = zeros(Complex128,m+1,m);
 y = zeros(Complex128,n,m+1);
 α=γ.^(0:m); α[1]=0;
 local M0inv::LinSolver = linsolvercreator(nep,σ);
 err = ones(m,m);
 λ=complex(zeros(m+1)); Q=complex(zeros(n,m+1));

 vv=view(V,1:1:n,1); # next vector V[:,k+1]
 vv[:]=v0; vv[:]=vv[:]/norm(vv);
 k=1; conv_eig=0;
 while (k <= m)&&(conv_eig<Neig)
  if (displaylevel>0)
   println("Iteration:",k, " conveig:",conv_eig)
  end
  VV=view(V,1:1:n*(k+1),1:k); # extact subarrays, memory-CPU efficient
  vv=view(V,1:1:n*(k+1),k+1); # next vector V[:,k+1]

  y[:,2:k+1] = reshape(VV[1:1:n*k,k],n,k);
  for j=1:k
   y[:,j+1]=y[:,j+1]/j;
  end
  y[:,1] = compute_Mlincomb(nep,σ,y[:,1:k+1],a=α[1:k+1]);
  y[:,1] = -lin_solve(M0inv,y[:,1]);

  vv[:]=reshape(y[:,1:k+1],(k+1)*n,1);
  # orthogonalization
  h,vv[:] = doubleGS(VV,vv,k,n);
  H[1:k,k]=h;
  beta=norm(vv);

  H[k+1,k]=beta;
  vv[:]=vv[:]/beta;

  # compute Ritz pairs (every p iterations)
  if (rem(k,p)==0)||(k==m)
   D,Z=eig(H[1:k,1:k]);
   VV=view(V,1:1:n,1:k);
   Q=VV*Z; λ=σ+γ./D;

   conv_eig=0;
    for s=1:k
     err[k,s]=errmeasure(λ[s],Q[:,s]);
     if err[k,s]>10; err[k,s]=1; end	# artificial fix
     if err[k,s]<tol
      conv_eig=conv_eig+1;
     end
    end
    idx=sortperm(err[1:k,k]); # sort the error
    err[1:k,k]=err[idx,k];

    # extract the converged Ritzpairs
    if (conv_eig>=Neig)||(k==m)
     println("Last iteration. idx=",idx[1:min(length(λ),conv_eig)],"length(λ)=",length(λ),"conv_eig=",conv_eig)
     λ=λ[idx[1:min(length(λ),conv_eig)]];
     Q=Q[:,idx[1:min(length(λ),conv_eig)]];
    end
   end
 k=k+1;
 end


return λ,Q,err
end


function doubleGS(VV,vv,k,n)
 h=VV'*vv;
 vv=vv-VV*h;
 g=VV'*vv;
 vv=vv-VV*g;
 h = h+g;
 return h,vv;
end

function singleGS(V,vv,k,n)
 h=V[1:(k+1)*n,1:k]'*vv;
 vv=vv-V[1:(k+1)*n,1:k]*h;
 return h,vv;
end
