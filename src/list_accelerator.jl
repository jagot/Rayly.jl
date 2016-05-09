type ListAccelerator <: Accelerator
    objs::Vector{Intersectable}
end
ListAccelerator() = ListAccelerator(Vector{Intersectable}())

function intersect(acc::ListAccelerator, ray::Ray)
    hits = []
    for o in acc.objs
        intersect(o, ray) && push!(hits, Intersection(o, ray, calc_intersect(o, ray)...))
    end
    length(hits) > 0 ? first(sort(hits)) : nothing
end

export ListAccelerator, intersect
