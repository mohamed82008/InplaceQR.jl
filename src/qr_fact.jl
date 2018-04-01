function house!(h, j, X, k)
    T = eltype(h)
    n = size(X,1)
    σ = zero(T)
    @inbounds @simd for i in j+1:n
        σ += X[i,k]^2
    end
    @inbounds begin
        h[j] = one(T)
        @simd for i in j+1:n
            h[i] = X[i,k]
        end
    end
    if σ == zero(T)
        β = zero(T)
    else
        @inbounds begin
            μ = sqrt(X[j,k]^2 + σ)
            if X[j,k] <= zero(T)
                h[j] = X[j,k] - μ
            else
                h[j] = -σ/(X[j,k] + μ)
            end
            β = 2*(h[j]^2) / (σ + h[j]^2)
            d = h[j]
            @simd for i in j:n
                h[i] /= d
            end
        end
    end
    β
end

"""
accumulate!(Q, A, β)

Q: Matrix to be over-written with Q, gets returned
A: Has the Householder vectors on the lower triangle
β: Has the Householder coefficients
"""
function accumulate!(Q, A, β)
    T = eltype(Q)
    m, n = size(Q)
    @inbounds begin
        Q .= zero(T)
        @simd for i in 1:n
            Q[i,i] = one(T)
        end
    end
    @inbounds for j in n:-1:1
        @simd for t in j:n
            dp = Q[j,t]
            for i in j+1:m
                dp += A[i,j]*Q[i,t]
            end
            Q[j,t] -= β[j]*dp
            for i in j+1:m
                Q[i,t] -= β[j]*dp*A[i,j]
            end
        end
    end
    Q
end

"""
getR!(R, A)

Copies the right triangular part of A into the right triangular part of R.
"""
function getR!(R, A)
    T = eltype(R)
    m, n = size(A)
    @inbounds @simd for j in 1:n
        for i in 1:j
            R[i,j] = A[i,j]
        end
    end
    R
end

"""
qrfact!(A, β, h=zeros(eltype(A), size(A,1)))

A: Matrix to be QR factorized, returned by the function
β: Empty buffer to store the Householder coefficients, returned by the function
h: Empty buffer for in-place operations
"""
function qrfact!(A, β, h=zeros(eltype(A), size(A,1)))
    m, n = size(A)
    @inbounds for j in 1:n
        β[j] = house!(h, j, A, j)
        @simd for k in j:n
            dp = A[j,k]
            for i in j+1:m
                dp += h[i]*A[i,k]
            end
            for l in j:m
                A[l,k] -= (β[j] * dp) * h[l]
            end
        end
        if j < m
            @simd for k in 1:(m-j)
                A[k+j,j] = h[k+j]
            end
        end
    end
    A, β  
end
