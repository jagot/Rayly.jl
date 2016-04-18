abstract Sampler

type SingleSampler
end

import Base.call
call(::SingleSampler, i, j) = [(i,j)]

weight(::SingleSampler) = 1

type JitteredSampler <: Sampler
    samples
    n
    d
    w
end

function JitteredSampler(samples)
    n = isqrt(samples)
    JitteredSampler(n^2, n, 1.0/n, 1.0/samples)
end

import Base.call
function call(s::JitteredSampler, i, j)
    hcat([[(i - 0.5 + (ii - 1 + rand())*s.d,
            j - 0.5 + (jj - 1 + rand())*s.d)
           for ii in 1:s.n]
          for jj in 1:s.n]...)
end

import Rayly.weight
weight(s::JitteredSampler) = s.w

export Sampler, SingleSampler, JitteredSampler, weight
