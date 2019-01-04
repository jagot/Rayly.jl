abstract type BVHAccelerator{T,B<:BVH{T}} <: Accelerator{T} end

struct StackBVHAccelerator{T,B} <: BVHAccelerator{T,B}
    bvh::B
end
StackBVHAccelerator(bvh::B) where {T,B<:BVH{T}} =
    StackBVHAccelerator{T,B}(bvh)

function Base.intersect(ray::Ray{T}, acc::StackBVHAccelerator{T}) where T
    tree = acc.bvh.tree
    node = acc.bvh.root
    intersect(ray, node, tree)
end

function Base.intersect!(intersection::Intersection{T}, acc::StackBVHAccelerator{T}) where T
    tree = acc.bvh.tree
    node = acc.bvh.root
    intersect!(intersection, node, tree)
end

export StackBVHAccelerator
