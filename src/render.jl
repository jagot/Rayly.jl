using FixedSizeArrays
using Images, ColorTypes
using ProgressMeter

function render{C<:Camera}(f::Function, cam::C, sampler = SingleSampler())
    w,h = width(cam),height(cam)
    img = Image(zeros(RGB{eltype(cam)}, (w,h)))

    @showprogress "Rendering: " for i = 1:w
        for j = 1:h
            img[i,j] = weight(sampler)*mapreduce(+, sampler(i,j)) do ij
                f(cam[ij...])
            end
        end
    end

    img
end

export render
