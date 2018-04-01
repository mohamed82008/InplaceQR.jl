# InplaceQR

[![Build Status](https://travis-ci.org/mohamed82008/InplaceQR.jl.svg?branch=master)](https://travis-ci.org/mohamed82008/InplaceQR.jl)

[![Coverage Status](https://coveralls.io/repos/mohamed82008/InplaceQR.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/mohamed82008/InplaceQR.jl?branch=master)

[![codecov.io](http://codecov.io/github/mohamed82008/InplaceQR.jl/coverage.svg?branch=master)](http://codecov.io/github/mohamed82008/InplaceQR.jl?branch=master)

```julia

julia> using InplaceQR

julia> A = rand(3,2);

julia> qrb = InplaceQR.QRBuffers(A);

julia> qrc = InplaceQR.qrfact!(copy(A), qrb);

julia> qr = InplaceQR.QR(A, Void);

julia> InplaceQR.QR!(qr, qrc);

julia> qr.Q * qr.R ≈ A
true

julia> B = copy(A);

julia> using BenchmarkTools

julia> @btime InplaceQR.qrfact!(B, qrb);
  2.310 μs (93 allocations: 1.56 KiB)
```