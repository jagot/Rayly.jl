function render(f::Function, cam::C, sampler = SingleSampler(T);
                save_interval::Number=Inf, filename::String="render.png",
                resolution::Integer=1) where {T,C<:Camera{T}}
    w,h = width(cam),height(cam)
    img = zeros(RGB{eltype(cam)}, (w,h))

    W = weight(sampler)
    t₀ = time()
    @showprogress "Rendering: " for i = 1:resolution:w
        for j = 1:resolution:h
            img[i,j] = W*mapreduce(ij -> f(cam[ij...]), +, sampler(i,j))
            if resolution > 1
                n = resolution-1
                for i′ = i:i+n
                    for j′ = j:j+n
                        img[i′,j′] = img[i,j]
                    end
                end
            end
            now = time()
            if now - t₀ > save_interval
                save_clamped(filename, img)
                t₀ = now
            end
        end
    end

    img
end

function render(cam::C, acc::A,
                shade::Function, background::RGB{T},
                args...; kwargs...) where {T,C<:Camera{T},O,A<:Accelerator{T,O}}
    render(cam, args...; kwargs...) do ray::Ray
        hit = Intersection(ray, O)
        intersect!(hit, acc)
        is_hit(hit) ? shade(hit) : background
    end
end

export render
