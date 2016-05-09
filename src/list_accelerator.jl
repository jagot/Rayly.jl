type ListAccelerator <: Accelerator
    objs::Vector{Intersectable}
end
ListAccelerator() = ListAccelerator(Vector{Intersectable}())

function intersect(acc::ListAccelerator, ray::Ray)
    for o in acc.objs
        intersect(o, ray) && return true
    end
    false
end

function intersect!(acc::ListAccelerator, intersection::Intersection)
    for o in acc.objs
        intersect!(o, intersection)
    end
end

export ListAccelerator, intersect, intersect!
