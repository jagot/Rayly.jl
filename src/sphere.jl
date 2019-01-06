mutable struct Sphere{T} <: Intersectable{T}
    pos::SVector{3,T}
    radius::T
end

#=
\[d=-[\mathbf{l}\cdot(\mathbf{o}-\mathbf{c})]\pm\sqrt{[\mathbf{l}\cdot(\mathbf{o}-\mathbf{c})]^2-||\mathbf{o}-\mathbf{c}||^2+r^2}\]
=#

function extents(sphere::Sphere{T}) where T
    e = √(3one(T))
    [(pos[i]-e,pos[i]+e) for i=1:3]
end

function Base.intersect(ray::Ray{T}, sphere::Sphere{T}) where T
    oc = ray.pos - sphere.pos
    loc = dot(ray.dir, oc)
    loc^2 - dot(oc, oc) + sphere.radius^2 >= 0
end

function Base.intersect!(i::Intersection{T}, sphere::Sphere{T}) where T
    oc = i.ray.pos - sphere.pos
    loc = dot(i.ray.dir, oc)
    D = loc^2 - dot(oc, oc) + sphere.radius^2
    (D < 0) && return
    t = D != 0 ? -loc + sign(loc)*sqrt(D) : -loc
    (t > i.t) && return
    i.o = sphere
    i.t = t
end

normal(sphere::Sphere{T}, p::SVector{3,T}, ::Intersection{T}) where T =
    normalize(p-sphere.pos)

aabb(s::Sphere{T}) where T = AABB{T}(s.pos-s.radius,s.pos+s.radius)

export Sphere, extents, normal, aabb
