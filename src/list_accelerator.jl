mutable struct ListAccelerator{T,O} <: Accelerator{T,O}
    scene::Scene{O}
end
ListAccelerator(scene::Scene{O}) where {T,O<:Intersectable{T}} =
    ListAccelerator{T,O}(scene)

Base.intersect(ray::Ray{T}, acc::ListAccelerator{T}) where T =
    any(o -> intersect(ray,o), acc.scene.objs)

Base.intersect!(intersection::Intersection{T}, acc::ListAccelerator{T}) where T =
    foreach(o -> intersect!(intersection, o), acc.scene.objs)

export ListAccelerator
