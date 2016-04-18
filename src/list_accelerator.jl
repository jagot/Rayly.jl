type ListAccelerator <: Accelerator
    objs::Vector{Intersectable}
end
ListAccelerator() = ListAccelerator(Vector{Intersectable}())

add!{T<:Intersectable}(la::ListAccelerator, o::T) = push!(la.objs, o)

function intersect(acc::ListAccelerator, ray::Ray)
    hits = []
    for o in acc.objs
        if intersect(o, ray)
            push!(hits, Intersection(o, ray, calc_intersect(o, ray)...))
        end
    end
    if length(hits) > 0
        first(sort(hits))
    else
        nothing
    end
end

export ListAccelerator, add!, intersect
