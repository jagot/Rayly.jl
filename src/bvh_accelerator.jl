struct BVHAccelerator{T,O,B<:BVH{T,O},strategy} <: Accelerator{T,O}
    bvh::B
end
BVHAccelerator(bvh::B,strategy::Symbol) where {T,O,B<:BVH{T,O}} = BVHAccelerator{T,O,B,strategy}(bvh)

function Base.show(io::IO, ::MIME"text/plain", acc::Acc) where {Acc<:BVHAccelerator}
    write(io, "$Acc\n- ")
    show(io, acc.bvh)
end

# * Recursive traversal

const RecursiveBVHAccelerator{T,O,B} = BVHAccelerator{T,O,B,:recursive}

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

# * Stack traversal

const StackBVHAccelerator{T,O,B} = BVHAccelerator{T,O,B,:stack}

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
                push!(stack, tree[node.left])
                push!(stack, tree[node.right])
            end
        else
            intersect!(intersection, node)
        end
    end
end

export BVHAccelerator, RecursiveBVHAccelerator, StackBVHAccelerator
