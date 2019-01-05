function render(f::Function, cam::C, sampler = SingleSampler(T)) where {T,C<:Camera{T}}
    w,h = width(cam),height(cam)
    img = zeros(RGB{eltype(cam)}, (w,h))

    W = weight(sampler)
    @showprogress "Rendering: " for i = 1:w
        for j = 1:h
            img[i,j] = W*mapreduce(ij -> f(cam[ij...]), +, sampler(i,j))
        end
    end

    img
end

function render(cam::C, acc::A,
                shade::Function, background::RGB{T},
                args...) where {T,C<:Camera{T},O,A<:Accelerator{T,O}}
    render(cam, args...) do ray::Ray
        hit = Intersection(ray, O)
        intersect!(hit, acc)
        is_hit(hit) ? shade(hit) : background
    end
end

export render
