using FixedSizeArrays

type AABB{T<:AbstractFloat} <: Intersectable{T}
    pmin::Point{3,T}
    pmax::Point{3,T}
end
AABB{T<:AbstractFloat}(t::T) = AABB(Point{3,T}(t),Point{3,T}(t))
AABB(a::AABB, b::AABB) = AABB(min(a.pmin, b.pmin), max(a.pmax,b.pmax))
function AABB{T<:AbstractFloat}(bboxes::AbstractVector{AABB{T}})
    # Calculate bbox encompassing all objects
    bbox = AABB(zero(T))
    for b in bboxes
        bbox = AABB(bbox, b)
    end
    bbox
end
AABB{T<:AbstractFloat}(objs::AbstractVector{Intersectable{T}}) = AABB(map(aabb, objs))

center(a::AABB) = (a.pmin+a.pmax)/2

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

export AABB, intersect, center
