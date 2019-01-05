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
        print_bboxes(io, tree, get(tree, node.left), maxdepth)
        print_bboxes(io, tree, get(tree, node.right), maxdepth)
    end
end

print_bboxes(bvh::B, maxdepth=Inf) where {B<:BVH} =
    print_bboxes(stdout, bvh.tree, bvh.root,maxdepth)
