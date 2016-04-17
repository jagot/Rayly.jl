using FixedSizeArrays
using Images, ColorTypes
using ProgressMeter

function render{T<:AbstractFloat}(f::Function, cam::SimpleCamera{T})
    img = Image(zeros(RGB{T}, (cam.w_px, cam.h_px)))

    dx = 1.0/(cam.w_px - 1)
    dy = 1.0/(cam.h_px - 1)

    x1 = cam.d*cam.fwd - 0.5cam.w*cam.right
    x2 = cam.d*cam.fwd + 0.5cam.w*cam.right
    y1 = cam.d*cam.fwd + 0.5cam.h*cam.up
    y2 = cam.d*cam.fwd - 0.5cam.h*cam.up

    @showprogress "Rendering: " for i = 1:cam.w_px
        for j = 1:cam.h_px
            t_x = (i-1)*dx
            t_y = (j-1)*dy
            dir = t_x * x1 + (1.0-t_x) * x2 + t_y * y1 + (1.0-t_y) * y2
            img[i,j] = f(Ray{T}(cam.pos, dir))
        end
    end

    img
end

export render
