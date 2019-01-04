# Implementation of
#
# Áfra, Attila T., & Szirmay-Kalos, László (2013). Stackless
# multi-bvh traversal for CPU, mic and GPU ray tracing. Computer
# Graphics Forum. http://dx.doi.org/10.1111/cgf.12259
#

struct AfraBVHAccelerator{T,B<:BVH{T,IntTree{T}},UI<:Unsigned} <: BVHAccelerator{T,B}
    bvh::B
end
AfraBVHAccelerator(bvh::B, ::Type{UI}=UInt64) where {T,B<:BVH{T},UI} = AfraBVHAccelerator{T,B,UI}(bvh)

for (fun,R,getray) in [(:intersect,:Ray,:identity), (:intersect!,:Intersection,:(r->r.ray))]
    @eval function Base.$fun(ray::$R{T}, acc::AfraBVHAccelerator{T,B,UI}) where {T,B,UI}
        tree = acc.bvh.tree
        node = acc.bvh.root
        bitstack = zero(UI)
        while true
            if is_inner(node)
                # lnode = get(tree, node.left)
                # rnode = get(tree, node.right)
                left = intersect($getray(ray), tree.nodes[node.left].bbox)
                right = intersect($getray(ray), tree.nodes[node.right].bbox)
                if left || right
                    bitstack <<= 1
                    if left ⊻ right
                        node = tree.nodes[left ? node.left : node.right]
                    else
                        # node = nearest child
                        node = tree.nodes[node.left] # lnode # Suboptimal
                        bitstack |= 1
                    end
                    continue
                end
            else # Leaf
                $fun(ray, node) && return true
            end
            # Backtrack
            while bitstack & 1 == 0
                bitstack == 0 && return false
                node = parent(node, tree)
                bitstack >>= 1
            end
            node = sibling(node, tree)
            bitstack ⊻= 1
        end
        false
    end
end

export AfraBVHAccelerator
