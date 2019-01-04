function divide(tree::Tree,
                objs::Vector{Intersectable{T}},
                bboxes::Vector{AABB{T}},
                centroids::Vector{SVector{3,T}},
                indices::Vector{I},
                selection::UR,
                axis::I) where {T<:AbstractFloat,Tree<:AbstractTree{T},
                                I<:Integer,UR<:AbstractUnitRange{I}}
    # Calculate bbox encompassing all objects
    bbox = AABB(view(bboxes, selection))

    # A better SAH is needed
    length(selection) <= 2 && return add_leaf_node!(tree, view(objs, selection), bbox)

    sort!(view(indices, selection), by = i -> centroids[i][axis])
    m = round(I, mean(selection))

    (axis += 1) == 4 && (axis = 1)

    left = divide(tree, objs, bboxes, centroids, indices, selection[1]:m, axis)
    right = divide(tree, objs, bboxes, centroids, indices, m+1:selection[end], axis)

    add_binary_node!(tree, left, right)
end

function bvh_simple_build(::Type{Tree}, objs::Vector{Intersectable{T}}) where {T<:AbstractFloat,Tree<:AbstractTree{T}}
    tree = Tree()
    bboxes = map(aabb, objs)
    centroids = map(center, bboxes)
    root = get(tree, divide(tree, objs, bboxes, centroids,
                            collect(eachindex(objs)), eachindex(objs), 1))
    BVH(tree, root)
end

export bvh_simple_build
