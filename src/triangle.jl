using FixedSizeArrays

type Triangle{T<:AbstractFloat} <: Intersectable{T}
    o::Point{3,T}
    e1::Vec{3,T}
    e2::Vec{3,T}
    na::Vec{3,T}
    nb::Vec{3,T}
    nc::Vec{3,T}
end

Triangle(a::Point, b::Point, c::Point,
         na::Vec, nb::Vec, nc::Vec) = Triangle(a, b-a, c-a,
                                               na, nb, nc)
Triangle(a::Point, b::Point, c::Point,
         normal::Vec) = Triangle(a, b, c,
                                 normal,
                                 normal,
                                 normal)
Triangle(a::Point, b::Point, c::Point) = Triangle(a,b,c, cross(b-a,c-a))

#=
Tomas Möller & Ben Trumbore (1997). Fast, minimum
storage ray-triangle intersection. Journal of Graphics Tools, 2(1),
21–28. http://dx.doi.org/10.1080/10867651.1997.10487468
=#

function intersect(tri::Triangle, ray::Ray)
    p = cross(ray.dir, tri.e2)
    det = dot(tri.e1, p)

    (det < eltype(tri.o)(1e-6)) && return false

    tv = ray.pos - tri.o

    u = dot(tv, p)

    (u < 0 || u > det) && return false

    v = dot(ray.dir, cross(tv, tri.e1))
    (v < 0 || u+v > det) && return false

    true
end

function calc_intersect(tri::Triangle, ray::Ray)
    p = cross(ray.dir, tri.e2)
    det = dot(tri.e1, p)

    inv_det = one(det)/det

    tv = ray.pos - tri.o

    q = cross(tv, tri.e1)

    t = dot(tri.e2, q) * inv_det
    u = dot(tv, p) * inv_det
    v = dot(ray.dir, q) * inv_det

    t,u,v
end

function normal(tri::Triangle, p::Point{3}, i::Intersection)
    normalize((1 - i.u - i.v)*tri.na + i.u * tri.nb + i.v * tri.nc)
end

export Triangle, intersect, calc_intersect, normal
