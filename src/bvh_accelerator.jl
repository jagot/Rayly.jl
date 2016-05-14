abstract BVHAccelerator <: Accelerator

type StackBVHAccelerator <: BVHAccelerator
    bvh::BVH
end

function intersect(acc::StackBVHAccelerator, ray::Ray)
    tree = acc.bvh.tree
    node = acc.bvh.root
    intersect(node, tree, ray)
end

export StackBVHAccelerator, intersect
