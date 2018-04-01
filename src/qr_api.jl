struct QR{TQ,TR}
    Q::TQ
    R::TR
end
struct QnoR{TQ}
    Q::TQ
end
struct RnoQ{TR}
    R::TR
end
struct QRBuffers{TB,TH}
    β::TB
    h::TH
end
QRBuffers(A) = QRBuffers(zeros(min(size(A)...)), zeros(size(A,1)))
struct QRCompact{T,S}
    A::T
    β::S
end
QRCompact(A) = QRCompact(A, zeros(min(size(A)...)))

function qrfact!(A, qrb::QRBuffers=QRBuffers(A))
    qrfact!(A, qrb.β, qrb.h)
    QRCompact(A, qrb.β)
end
function qrfact!(qrc::QRCompact, h=zeros(size(qrc.A,1)))
    qrfact!(qrc.A, qrc.β, h)
    qrc
end

function QR(A, ::Type{Void})
    m, n = size(A)
    qr = QR(similar(A), zeros(min(m,n), n))
    qr
end
function QR!(qr::QR, qrc::QRCompact)
    accumulate!(qr.Q, qrc.A, qrc.β)
    getR!(qr.R, qrc.A)
    qr
end
function QR(qrc::QRCompact)
    m, n = size(qrc.A)
    qr = QR(similar(qrc.A), zeros(min(m,n), n))
    QR!(qr, qrc)
    qr
end

function QnoR!(qnor::QnoR, qrc::QRCompact)
    accumulate!(qnor.Q, qrc.A, qrc.β)
    qnor
end
function QnoR(qrc::QRCompact)
    qnor = QnoR(similar(qrc.A))
    QnoR!(qnor, qrc)
    qnor
end

function RnoQ!(rnoq::RnoQ, qrc::QRCompact)
    getR!(rnoq.R, qrc.A)
    rnoq
end
function RnoQ(qrc::QRCompact)
    m, n = size(qrc.A)
    rnoq = RnoQ(zeros(min(m,n), n))
    RnoQ!(rnoq, qrc)
    rnoq
end

const qr! = qrfact!