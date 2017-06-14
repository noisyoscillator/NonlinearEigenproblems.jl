    export tiar
    #Tensor Infinite Arnoldi for a given number of max iters (No error measure yet)
"""
    The Tensor Infinite Arnoldi method
"""
    function tiar(
     nep::NEP;
     maxit=30,
     linsolvercreator::Function=default_linsolvercreator,
     tol=1e-12,
     Neig=maxit,
     errmeasure::Function = default_errmeasure(nep::NEP),
     σ=0.0,
     γ=1,
     displaylevel=0
    )

     n = size(nep,1); m = maxit;
     # initialization
     a  = zeros(Complex128,m+1,m+1,m+1);
     Z  = zeros(Complex128,n,m+1);
     t  = zeros(Complex128,m+1);
     tt = zeros(Complex128,m+1);

     g  = zeros(Complex128,m+1,m+1);
     f  = zeros(Complex128,m+1,m+1);
     ff = zeros(Complex128,m+1,m+1);

     H  = zeros(Complex128,m+1,m);
     h  = zeros(Complex128,m+1);
     hh = zeros(Complex128,m+1);

     y  = zeros(Complex128,n,m+1);
     α  = [0;ones(m)];
     # rescaled coefficients(TODO: integrate in compute_Mlincomb)
     for i=2:m+1; α[i]=γ^(i-1); end
     local M0inv::LinSolver = linsolvercreator(nep,σ);
     err = zeros(m,m);
     λ=complex(zeros(m+1)); Q=complex(zeros(n,m+1));

     Z[:,1]=ones(n,1); Z[:,1]=Z[:,1]/norm(Z[:,1]);
     a[1,1,1]=1;

     k=1; conv_eig=0;
          while (k <= m)&(conv_eig<Neig)
            if (displaylevel>0)
                println("Iteration:",k, " conveig:",conv_eig)
                end

            # computation of y[:,2], ..., y[:,k+1]
            y[:,2:k+1]=Z[:,1:k]*(a[1:k,k,1:k].');
            y[:,2:k+1]=y[:,2:k+1]/diagm(1:1:k);

            # computation of y[:,1]
            y[:,1] = compute_Mlincomb(nep,σ,y[:,1:k+1],a=α[1:k+1]);
            y[:,1] = -lin_solve(M0inv,y[:,1]);

            # Gram–Schmidt orthogonalization in Z
            t[1:k]=Z[:,1:k]'*y[:,1];
            Z[:,k+1]=y[:,1]-Z[:,1:k]*t[1:k];

            # Gram–Schmidt re-orthogonalization in Z
            tt[1:k]=Z[:,1:k]'*Z[:,k+1];
            Z[:,k+1]=Z[:,k+1]-Z[:,1:k]*tt[1:k];
            t=t+tt;
            t[k+1]=norm(Z[:,k+1]);
            Z[:,k+1]=Z[:,k+1]/t[k+1]

            # compute the matrix G
            for l=1:k+1
              for i=2:k+1
                g[i,l]=a[i-1,k,l]/(i-1);
              end
              g[1,l]=t[l];
            end

            # compute h (orthogonalization with tensors factorization)
            h=0*h;
            for l=1:k
              h[1:k]=h[1:k]+a[1:k,1:k,l]'*g[1:k,l];
            end

            # compute the matrix F
            for l=1:k
                f[1:k+1,l]=g[1:k+1,l]-a[1:k+1,1:k,l]*h[1:k];
            end

            for i=1:k+1
                f[i,k+1]=g[i,k+1];
            end

            # re-orthogonalization
            # compute hh (re-orthogonalization with tensors factorization)
            hh=0*hh;
            for l=1:k
                hh[1:k]=hh[1:k]+a[1:k,1:k,l]'*f[1:k,l];
            end

            # compute the matrix FF
            for l=1:k
                ff[1:k+1,l]=f[1:k+1,l]-a[1:k+1,1:k,l]*hh[1:k];
            end

            for i=1:k+1
                ff[i,k+1]=f[i,k+1];
            end

            # update the orthogonalization coefficients
            h=h+hh; f=ff;

            β=vecnorm(f[1:k+1,1:k+1]); # equivalent to Frobenius norm

            # extend the matrix H
            H[1:k,k]=h[1:k]; H[k+1,k]=β;

            # extend the tensor
            for i=1:k+1
                for l=1:k+1
                    a[i,k+1,l]=f[i,l]/β;
                end
            end

            # compute error history
            D,W=eig(H[1:k,1:k]); D=σ+γ./D;
            VV=Z[:,1:k]*(a[1,1:k,1:k].');	# extract proper subarray

            conv_eig=0;
            for s=1:k
             err[k,s]=errmeasure(D[s],VV* W[:,s]);
             if err[k,s]>10; err[k,s]=1; end	# artificial fix
             if err[k,s]<tol
              conv_eig=conv_eig+1;
              Q[:,conv_eig]=VV*W[:,s]; λ[conv_eig]=D[s];
             end
            end

            k=k+1;
          end

      # extract the converged Ritzpairs
      λ=λ[1:min(length(λ),conv_eig)];
      Q=Q[:,1:min(size(Q,2),conv_eig)];

      return λ,Q,err
    end
