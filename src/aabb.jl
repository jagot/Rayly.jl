mutable struct AABB{T<:AbstractFloat} <: Intersectable{T}
    pmin::SVector{3,T}
    pmax::SVector{3,T}
    AABB(pmin::SVector{3,T}, pmax::SVector{3,T}) where T =
        new{T}(compmin(pmin,pmax), compmax(pmin,pmax))
end
AABB(t::T) where T = AABB(SVector(t,t,t),SVector(t,t,t))

AABB(a::AABB{T}, b::AABB{T}) where T =
    AABB(compmin(a.pmin,b.pmin), compmax(a.pmax,b.pmax))

function AABB(bboxes::VA) where {T,VA<:AbstractVector{AABB{T}}}
    # Calculate bbox encompassing all objects
    bbox = first(bboxes)
    for b in bboxes
        bbox = AABB(bbox, b)
    end
    bbox
end
AABB(objs::AbstractVector{Intersectable{T}}) where T = AABB(map(aabb, objs))

Base.show(io::IO, bbox::AABB{T}) where T =
    write(io, "$(T)⟦", join(map(i -> "$(bbox.pmin[i])..$(bbox.pmax[i])", 1:3), "; "), "⟧")

Images.center(a::AABB) = (a.pmin+a.pmax)/2

# http://psgraphics.blogspot.se/2016/02/new-simple-ray-box-test-from-andrew.html
function Base.intersect(ray::Ray{T}, ab::AABB{T}, tₘᵢₙ::T=zero(T), tₘₐₓ::T=one(T)/zero(T)) where T
    for a = 1:3
        D⁻¹ = one(T)/ray.dir[a]
        t₀ = (ab.pmin[a] - ray.pos[a]) * D⁻¹
        t₁ = (ab.pmax[a] - ray.pos[a]) * D⁻¹
        if D⁻¹ < 0
            t₀,t₁ = t₁,t₀
        end
        tₘᵢₙ = t₀ > tₘᵢₙ ? t₀ : tₘᵢₙ
        tₘₐₓ = t₁ < tₘₐₓ ? t₁ : tₘₐₓ
        tₘₐₓ ≤ tₘᵢₙ && return false
    end
    true
end

export AABB, center
