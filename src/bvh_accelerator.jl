abstract BVHAccelerator <: Accelerator

type SimpleBVHAccelerator <: BVHAccelerator
    bvh::BVH
end

function intersect(acc::SimpleBVHAccelerator, ray::Ray)
    false
end

function intersect!(acc::SimpleBVHAccelerator, intersection::Intersection)
end

export SimpleBVHAccelerator, intersect
