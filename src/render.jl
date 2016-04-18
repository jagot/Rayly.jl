using FixedSizeArrays
using Images, ColorTypes
using ProgressMeter

function render{C<:Camera}(f::Function, cam::C)
    w,h = width(cam),height(cam)
    img = Image(zeros(RGB{eltype(cam)}, (w,h)))

    @showprogress "Rendering: " for i = 1:w
        for j = 1:h
            img[i,j] = f(cam[i,j])
        end
    end

    img
end

export render
