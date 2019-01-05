abstract type BVHAccelerator{T,B<:BVH{T}} <: Accelerator{T} end

struct RecursiveBVHAccelerator{T,B} <: BVHAccelerator{T,B}
    bvh::B
end
RecursiveBVHAccelerator(bvh::B) where {T,B<:BVH{T}} =
    RecursiveBVHAccelerator{T,B}(bvh)

function Base.intersect(ray::Ray{T}, acc::RecursiveBVHAccelerator{T}) where T
    tree = acc.bvh.tree
    node = acc.bvh.root
    intersect(ray, node, tree)
end

function Base.intersect!(intersection::Intersection{T}, acc::RecursiveBVHAccelerator{T}) where T
    tree = acc.bvh.tree
    node = acc.bvh.root
    intersect!(intersection, node, tree)
end

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
    stack = nodetype(tree)[acc.bvh.root]
    while !isempty(stack)
        node = pop!(stack)
        if is_inner(node)
            if intersect(intersection.ray, node.bbox)
                push!(stack, get(tree, node.left))
                push!(stack, get(tree, node.right))
            end
        else
            intersect!(intersection, node)
        end
    end
end

export RecursiveBVHAccelerator, StackBVHAccelerator
