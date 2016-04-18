using FixedSizeArrays

type Sphere{T<:AbstractFloat} <: Intersectable
    pos::Vec{3,T}
    radius::T
end

#=
\[d=-[\mathbf{l}\cdot(\mathbf{o}-\mathbf{c})]\pm\sqrt{[\mathbf{l}\cdot(\mathbf{o}-\mathbf{c})]^2-||\mathbf{o}-\mathbf{c}||^2+r^2}\]
=#

function intersect(sphere::Sphere, ray::Ray)
    oc = ray.pos - sphere.pos
    loc = dot(ray.dir, oc)
    D = loc^2 - dot(oc, oc) + sphere.radius^2
    D >= 0
end

function calc_intersect(sphere::Sphere, ray::Ray)
    oc = ray.pos - sphere.pos
    loc = dot(ray.dir, oc)
    D = loc^2 - dot(oc, oc) + sphere.radius^2
    if D != 0
        -loc + sign(loc)*sqrt(D)
    else
        -loc
    end
end

normal(sphere::Sphere, p::Vec{3}) = normalize(p-sphere.pos)

export Sphere, intersect, calc_intersect, normal
