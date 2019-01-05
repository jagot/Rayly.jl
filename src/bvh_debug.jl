function print_block(fun::Function,out=stdout)
    io = IOBuffer()
    fun(io)
    data = split(String(take!(io)), "\n")
    if length(data) == 1
        println(out, "[ $(data[1])")
    elseif length(data) > 1
        for (p,dl) in zip(vcat("⎡", repeat(["⎢"], length(data)-2), "⎣"),data)
            println(out, "$(p) $(dl)")
        end
    end
end

function print_bboxes(io::IO, tree::Tree, node::Node, maxdepth::N) where {Tree<:AbstractTree, Node<:AbstractNode, N<:Number}
    println(io, aabb(node))
    (maxdepth -= 1) == 0 && return
    is_inner(node) && print_block(io) do io
        print_bboxes(io, tree, tree[node.left], maxdepth)
        print_bboxes(io, tree, tree[node.right], maxdepth)
    end
end

print_bboxes(bvh::B, maxdepth=Inf) where {B<:BVH} =
    print_bboxes(stdout, bvh.tree, bvh.root,maxdepth)


shadebox(ray::Ray, node::BN, tree::Tree, factor::T) where {T,BN<:Union{BinaryNode{T},BinaryIntNode{T}},Tree<:AbstractTree{T}} =
    intersect(ray, node.bbox) ? factor*(shadebox(ray, tree[node.left], tree, factor) +
                                        shadebox(ray, tree[node.right], tree, factor)) : 1

shadebox(ray::Ray,node::N,tree::Tree, ::T) where {T,N<:Union{LeafNode,LeafIntNode},Tree<:AbstractTree} =
    0 # intersect(ray, node.bbox) ? 1 : 0

function debug_bvh_render(acc::Acc, cam::Camera,
                          factor::T=T(1.3),gain::T=T(1e-4);
                          show_model::Bool=true, kwargs...) where {T,O,B<:BVH{T,O},Acc<:BVHAccelerator{T,O,B}}
    e = one(T)
    z = zero(T)
    black = RGB(z,z,z)
    white = RGB(e,e,e)
    red = RGB(e,z,z)

    tree = acc.bvh.tree
    node = acc.bvh.root

    render(cam, kwargs...) do ray::Ray
        if intersect(ray, node.bbox)
            if show_model && intersect(ray, acc)
                red
            else
                gain*white*shadebox(ray,node,tree,factor)
            end
        else
            black
        end
    end
end
