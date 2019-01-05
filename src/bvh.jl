abstract type AbstractNode{T<:AbstractFloat,O<:Intersectable{T}} <: Intersectable{T} end
abstract type AbstractTree{T<:AbstractFloat,O} end

mutable struct BVH{T,O,Tree<:AbstractTree{T,O},Node<:AbstractNode{T,O}}
    tree::Tree
    root::Node
end

aabb(n::Node) where {Node<:AbstractNode} = n.bbox
Base.intersect(ray::Ray{T}, n::Node) where {T,Node<:AbstractNode{T}} = intersect(ray, n.bbox)

function traverse_reduce(tree::Tree, node::Node,
                         binary::N, binop::Function = +,
                         leafop::Function = n -> one(N)) where {Tree<:AbstractTree, Node<:AbstractNode, N}
    if is_inner(node)
        binary + binop(traverse_reduce(tree, tree[node.left], binary, binop, leafop),
                       traverse_reduce(tree, tree[node.right], binary, binop, leafop))
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
