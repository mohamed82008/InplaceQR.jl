function house!(h, j, X, k)
    T = eltype(h)
    n = size(X,1)
    σ = mapreduce((i)->(X[i,k]^2), +, j+1:n)
    h .= zero(T)
    h[j] = one(T)
    for i in j+1:n
        h[i] = X[i,k]
    end
    if σ == zero(T)
        β = zero(T)
    else
        μ = sqrt(X[j,k]^2 + σ)
        if X[j,k] <= zero(T)
            h[j] = X[j,k] - μ
        else
            h[j] = -σ/(X[j,k] + μ)
        end
        β = 2*(h[j]^2) / (σ + h[j]^2)
        d = h[j]
        for i in j:n
            h[i] /= d
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
    Q .= zero(T)
    for i in 1:n
        Q[i,i] = one(T)
    end
    for j in n:-1:1
        for t in j:n
            dp = mapreduce((i)->(A[i,j]*Q[i,t]), +, j+1:m) + Q[j,t]
            Q[j,t] -= β[j]*dp
            for i in j+1:m
                Q[i,t] -= β[j]*dp*A[i,j]
            end
        end
    end
    Q
end

"""
getR(R, A)

Copies the right triangular part of A into the right triangular part of R.
"""
function getR!(R, A)
    T = eltype(R)
    m, n = size(A)
    for j in 1:n
        for i in 1:j
            R[i,j] = A[i,j]
        end
    end
    R
end

"""
qrfact!(A, β, h=zeros(size(A,1)))

A: Matrix to be QR factorized, returned by the function
β: Empty buffer to store the Householder coefficients, returned by the function
h: Empty buffer for in-place operations
"""
function qrfact!(A, β, h=zeros(size(A,1)))
    m, n = size(A)
    for j in 1:n
        β[j] = house!(h, j, A, j)
        for k in j:n
            dp = mapreduce((i)->(h[i]*A[i,k]), +, j:m)
            for l in j:m
                A[l,k] -= (β[j] * dp) * h[l]
            end
        end
        if j < m
            for k in 1:(m-j)
                A[k+j,j] = h[k+j]
            end
        end
    end
    A, β  
end
