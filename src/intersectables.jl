abstract type Intersectable{T<:AbstractFloat} end

Base.eltype(::Intersectable{T}) where T = T

export Intersectable, eltype
