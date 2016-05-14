# Implementation of
#
# Áfra, Attila T., & Szirmay-Kalos, László (2013). Stackless
# multi-bvh traversal for CPU, mic and GPU ray tracing. Computer
# Graphics Forum. http://dx.doi.org/10.1111/cgf.12259
#

type AfraBVHAccelerator{UI<:Unsigned} <: BVHAccelerator
    bvh::BVH
    bitstack_type::Type{UI}
end
AfraBVHAccelerator(bvh::BVH) = AfraBVHAccelerator(bvh, UInt64)

function intersect{UI<:Unsigned}(acc::AfraBVHAccelerator{UI}, ray::Ray)
    tree = acc.bvh.tree
    node = acc.bvh.root
    bitstack = acc.bitstack_type(0)
    while true
        if Rayly.is_inner(node)
            # lnode = get(tree, node.left)
            # rnode = get(tree, node.right)
            left = intersect(tree.nodes[node.left].bbox, ray)
            right = intersect(tree.nodes[node.right].bbox, ray)
            if left || right
                bitstack <<= 1
                if left $ right
                    node = (left ? tree.nodes[node.left]
                            : tree.nodes[node.right])
                else
                    # node = nearest child
                    node = tree.nodes[node.left] # lnode # Suboptimal
                    bitstack |= 1
                end
                continue
            end
        else # Leaf
            for i in eachindex(node.objs)
                intersect(node.objs[i], ray) && return true
            end
        end
        # Backtrack
        while bitstack & 1 == 0
            bitstack == 0 && return false
            node = parent(node, tree)
            bitstack >>= 1
        end
        node = sibling(node, tree)
        bitstack $= 1
    end
    false
end

export AfraBVHAccelerator, intersect
