using FixedSizeArrays

type AABB{T<:AbstractFloat} <: Intersectable{T}
    pmin::Point{3,T}
    pmax::Point{3,T}
end
AABB(a::AABB, b::AABB) = AABB(min(a.pmin, b.pmin), max(a.pmax,b.pmax))

# http://psgraphics.blogspot.se/2016/02/new-simple-ray-box-test-from-andrew.html
function intersect(ab::AABB, ray::Ray)
    for a = 1:3
        invD = 1.0/ray.dir[a]
        t0 = (ab.pmin[a] - ray.pos[a])* invD
        t1 = (ab.pmax[a] - ray.pos[a])* invD
        if invD < 0
            t0,t1 = t1,t0
        end
        if t1 <= t0
            return false
        end
    end
    true
end

export AABB, intersect
