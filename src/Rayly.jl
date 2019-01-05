module Rayly

using LinearAlgebra
using StaticArrays
using Statistics
using ColorTypes
using ProgressMeter
using FileIO
using Images

for (n,f) in [(:compmin, :min), (:compmax, :max)]
    @eval $n(a::SVector{3,T}, b::SVector{3,T}) where T =
        SVector{3,T}($f(a[1], b[1]), $f(a[2], b[2]), $f(a[3], b[3]))
end


struct Ray{T<:AbstractFloat}
    pos::SVector{3,T}
    dir::SVector{3,T}
    Ray(pos::SVector{3,T}, dir::SVector{3,T}) where T =
        new{T}(pos, normalize(dir))
end

abstract type Intersectable{T<:AbstractFloat} end
Base.eltype(::Intersectable{T}) where T = T

abstract type Accelerator{T<:AbstractFloat,O<:Intersectable{T}} end

include("intersection.jl")
include("aabb.jl")
include("sphere.jl")
include("triangle.jl")
include("camera.jl")
include("list_accelerator.jl")
include("bvh.jl")
include("bvh_simple_tree.jl")
include("bvh_int_tree.jl")
include("bvh_simple_builder.jl")
include("bvh_accelerator.jl")
include("bvh_afra.jl")
include("bvh_debug.jl")
include("sampling.jl")
include("render.jl")
include("utils.jl")
include("scene.jl")

# Default BVH builder is bvh_simple_build
Base.convert(::Type{Tree}, objs::Vector{O}) where {T,Tree<:AbstractTree{T},O<:Intersectable{T}} =
    bvh_simple_build(Tree, objs)

export Ray, Intersectable, Accelerator

end # module
