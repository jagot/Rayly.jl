abstract Camera

type SimpleCamera{T<:AbstractFloat} <: Camera
    pos::Point{3,T}
    up::Vec{3,T}
    fwd::Vec{3,T}
    right::Vec{3,T}
    w::T
    h::T
    d::T
    w_px::Integer
    h_px::Integer
end
function SimpleCamera{T<:AbstractFloat}(pos::Point{3,T},
                                        up::Vec{3,T},
                                        fwd::Vec{3,T},
                                        w::T, h::T, d::T,
                                        w_px, h_px)
    up,fwd = normalize(up), normalize(fwd)
    SimpleCamera(pos, up, fwd, cross(up,fwd),
                 w, h, d,
                 w_px, h_px)
end

export SimpleCamera
