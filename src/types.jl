using FixedSizeArrays

import Base.+, Base.-

function +{T1<:Point,T2<:Vec}(a::T1, v::T2)
    a + Point(v)
end

function -{T<:Point}(a::T, b::T)
    Vec(a) - Vec(b)
end

immutable Ray{T<:AbstractFloat}
    pos::Point{3,T}
    dir::Vec{3,T}
    function Ray(pos::Point{3}, dir::Vec{3})
        new(pos, normalize(dir))
    end
end

abstract Accelerator

export Ray, Accelerator
