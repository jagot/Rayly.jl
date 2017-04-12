function divide{T<:AbstractFloat,IT<:Integer}(tree::Tree{T},
                                              objs::Vector{Intersectable{T}},
                                              bboxes::Vector{AABB{T}},
                                              centroids::Vector{Point{3,T}},
                                              indices::Vector{IT},
                                              I::AbstractUnitRange{IT},
                                              axis::IT)
    # Calculate bbox encompassing all objects
    bbox = AABB(view(bboxes, I))

    if length(I) <= 2 # A better SAH is needed
        return add_leaf_node!(tree, view(objs, I), bbox)
    end

    sort!(view(indices, I), by = i -> centroids[i][axis])
    m = round(IT, mean(I))

    axis += 1
    axis == 4 && (axis = 1)

    left = divide(tree, objs, bboxes, centroids, indices, I[1]:m, axis)
    right = divide(tree, objs, bboxes, centroids, indices, m+1:I[end], axis)

    add_binary_node!(tree, left, right)
end

function bvh_simple_build{T<:AbstractFloat,TT<:Tree}(objs::Vector{Intersectable{T}},
                                                     tree_type::Type{TT} = IntTree{T})
    tree = tree_type()
    bboxes = map(aabb, objs)
    centroids = map(center, bboxes)
    root = get(tree, divide(tree, objs, bboxes, centroids,
                            collect(eachindex(objs)), eachindex(objs), 1))
    BVH(tree, root)
end

export bvh_simple_build
