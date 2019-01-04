mutable struct AABB{T<:AbstractFloat} <: Intersectable{T}
    pmin::SVector{3,T}
    pmax::SVector{3,T}
end
AABB(t::T) where T = AABB(SVector(t,t,t),SVector(t,t,t))

AABB(a::AABB{T}, b::AABB{T}) where T =
    AABB(compmin(a.pmin,b.pmin), compmax(a.pmax,b.pmax))

function AABB(bboxes::VA) where {T,VA<:AbstractVector{AABB{T}}}
    # Calculate bbox encompassing all objects
    bbox = AABB(zero(T))
    for b in bboxes
        bbox = AABB(bbox, b)
    end
    bbox
end
AABB(objs::AbstractVector{Intersectable{T}}) where T = AABB(map(aabb, objs))

center(a::AABB) = (a.pmin+a.pmax)/2

# http://psgraphics.blogspot.se/2016/02/new-simple-ray-box-test-from-andrew.html
function Base.intersect(ray::Ray{T}, ab::AABB{T}) where T
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

export AABB, center
