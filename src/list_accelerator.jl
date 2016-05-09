type ListAccelerator <: Accelerator
    objs::Vector{Intersectable}
end
ListAccelerator() = ListAccelerator(Vector{Intersectable}())

function intersect(acc::ListAccelerator, ray::Ray)
    intersection = Intersection(ray)
    for o in acc.objs
        intersect!(o, intersection)
    end
    intersection
end

export ListAccelerator, intersect
