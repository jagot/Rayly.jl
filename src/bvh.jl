abstract type AbstractNode{T<:AbstractFloat} <: Intersectable{T} end
abstract type AbstractTree{T<:AbstractFloat} end

mutable struct BVH{T,Tree<:AbstractTree{T},N<:AbstractNode{T}}
    tree::Tree
    root::N
end

aabb(n::N) where {N<:AbstractNode} = n.bbox
Base.intersect(ray::Ray{T}, n::N) where {T,N<:AbstractNode{T}} = intersect(ray, n.bbox)

function traverse_reduce(tree::Tree, node::Node,
                         binary::N, binop::Function = +,
                         leafop::Function = n -> one(N)) where {Tree<:AbstractTree, Node<:AbstractNode, N}
    if is_inner(node)
        binary + binop(traverse_reduce(tree, get(tree, node.left), binary, binop, leafop),
                       traverse_reduce(tree, get(tree, node.right),binary, binop, leafop))
    else
        leafop(node)
    end
end

depth(bvh::B) where {B<:BVH} = traverse_reduce(bvh.tree, bvh.root, 1, max)
count_leaves(bvh::B) where {B<:BVH} = traverse_reduce(bvh.tree, bvh.root, 0)
count_objs(bvh::B) where {B<:BVH} = traverse_reduce(bvh.tree, bvh.root, 0, +, n -> length(objects(n)))

Base.show(io::IO, bvh::B) where {B<:BVH} =
    write(io, "$B of depth $(depth(bvh)) with $(count_leaves(bvh)) leaf nodes with $(count_objs(bvh)) objects")

export BVH
