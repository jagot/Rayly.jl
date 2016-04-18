using FixedSizeArrays

immutable Ray{T<:AbstractFloat}
    pos::Vec{3,T}
    dir::Vec{3,T}
    function Ray(pos::Vec{3}, dir::Vec{3})
        new(pos, normalize(dir))
    end
end

abstract Camera

type SimpleCamera{T<:AbstractFloat} <: Camera
    pos::Vec{3,T}
    up::Vec{3,T}
    fwd::Vec{3,T}
    right::Vec{3,T}
    w::T
    h::T
    d::T
    w_px::Integer
    h_px::Integer
end
function SimpleCamera{T<:AbstractFloat}(pos::Vec{3,T},
                                        up::Vec{3,T},
                                        fwd::Vec{3,T},
                                        w::T, h::T, d::T,
                                        w_px, h_px)
    up,fwd = normalize(up), normalize(fwd)
    SimpleCamera(pos, up, fwd, cross(up,fwd),
                 w, h, d,
                 w_px, h_px)
end

abstract Accelerator

export Ray, SimpleCamera, Accelerator
