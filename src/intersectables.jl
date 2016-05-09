using FixedSizeArrays

abstract Intersectable{T}

import Base.eltype
eltype{T}(::Intersectable{T}) = T

export Intersectable
