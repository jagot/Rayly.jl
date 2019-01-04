abstract type Sampler{T<:AbstractFloat} end

struct SingleSampler{T} <: Sampler{T} end
SingleSampler(::Type{T}) where T = SingleSampler{T}()

(::SingleSampler{T})(i::I, j::I) where {T,I} = [(convert(T,i),convert(T,j))]

weight(::SingleSampler) = 1

struct JitteredSampler{T,I<:Integer} <: Sampler{T}
    samples::I
    n::I
    d::T
    w::T
end

function JitteredSampler(::Type{T}, samples::I) where {T<:AbstractFloat, I<:Integer}
    n = isqrt(samples)
    JitteredSampler(n^2, n, one(T)/n, one(T)/samples)
end

function (s::JitteredSampler{T,I})(i::I, j::I) where {T,I}
    hcat([[(i - one(T)/2 + (ii - 1 + rand(T))*s.d,
            j - one(T)/2 + (jj - 1 + rand(T))*s.d)
           for ii in 1:s.n]
          for jj in 1:s.n]...)
end

weight(s::JitteredSampler) = s.w

export Sampler, SingleSampler, JitteredSampler, weight
