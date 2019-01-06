mutable struct Triangle{T} <: Intersectable{T}
    o::SVector{3,T}
    e₁::SVector{3,T}
    e₂::SVector{3,T}
    na::SVector{3,T}
    nb::SVector{3,T}
    nc::SVector{3,T}
end

Triangle(ABC::NTuple{3,SVector{3,T}}, normals::NTuple{3,SVector{3,T}}) where T=
    Triangle(ABC[1], ABC[2]-ABC[1], ABC[3]-ABC[1], normals...)

Triangle(ABC::NTuple{3,SVector{3,T}},
         normal::SVector{3,T}=cross(ABC[2]-ABC[1], ABC[3]-ABC[1])) where T =
             Triangle(ABC, (normal, normal, normal))

function extents(tri::Triangle)
    a,b,c=vertices(tri)
    [extrema([a[i],b[i],c[i]]) for i=1:3]
end

function add_tris!(fun::Function, acc::A, faces::Vector{NTuple{3}}) where {A<:Accelerator}
    for face in faces
        add!(acc, fun(face...))
    end
end

function add_tris!(acc::A, vertices::Vector{SVector{3,T}},
                   faces::Vector{NTuple{3}}) where {A<:Accelerator, T}
    add_tris!(acc, faces) do (i,j,k)
        Triangle((vertices[i], vertices[j], vertices[k]))
    end
end

function add_tris!(acc::A, vertices::Vector{SVector{3,T}}, normals::Vector{SVector{3,T}},
                   faces::Vector{NTuple{3}}) where {A<:Accelerator, T}
    add_tris!(acc, faces) do (i,j,k)
        Triangle((vertices[i], vertices[j], vertices[k]),
                 (normals[i], normals[j], normals[k]))
    end
end

#=
Tomas Möller & Ben Trumbore (1997). Fast, minimum
storage ray-triangle intersection. Journal of Graphics Tools, 2(1),
21–28. http://dx.doi.org/10.1080/10867651.1997.10487468
=#

function Base.intersect(ray::Ray{T}, tri::Triangle{T}) where T
    p = cross(ray.dir, tri.e₂)
    det = dot(tri.e₁, p)

    (det < eltype(tri.o)(1e-6)) && return false

    tv = ray.pos - tri.o

    u = dot(tv, p)

    (u < 0 || u > det) && return false

    v = dot(ray.dir, cross(tv, tri.e₁))
    (v < 0 || u+v > det) && return false

    true
end

function Base.intersect!(i::Intersection{T}, tri::Triangle{T}) where T
    p = cross(i.ray.dir, tri.e₂)
    det = dot(tri.e₁, p)

    (det < eltype(tri.o)(1e-6)) && return

    tv = i.ray.pos - tri.o

    u = dot(tv, p)

    (u < 0 || u > det) && return

    q = cross(tv, tri.e₁)
    v = dot(i.ray.dir, q)
    (v < 0 || u+v > det) && return

    inv_det = inv(det)
    t = dot(tri.e₂, q) * inv_det
    (t > i.t) && return

    u *= inv_det
    v *= inv_det

    i.o = tri
    i.t = t
    i.u = u
    i.v = v
end

normal(tri::Triangle{T}, p::SVector{3,T}, i::Intersection{T}) where T =
    normalize((1 - i.u - i.v)*tri.na + i.u * tri.nb + i.v * tri.nc)

vertices(tri::Triangle{T}) where T= (tri.o, tri.o + tri.e₁, tri.o + tri.e₂)

function aabb(t::Triangle{T}) where T
    a,b,c = vertices(t)
    AABB(compmin(compmin(a,b),c), compmax(compmax(a,b),c))
end

export Triangle, extents, add_tris!, normal, aabb
