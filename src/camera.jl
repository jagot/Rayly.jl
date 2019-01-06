abstract type Camera{T<:AbstractFloat} end

Base.eltype(::Camera{T}) where T = T

mutable struct SimpleCamera{T,I<:Integer} <: Camera{T}
    pos::SVector{3,T}
    up::SVector{3,T}
    fwd::SVector{3,T}
    right::SVector{3,T}
    w::T
    h::T
    d::T
    w_px::I
    h_px::I
    dx::T
    dy::T
    x₁::SVector{3,T}
    x₂::SVector{3,T}
    y₁::SVector{3,T}
    y₂::SVector{3,T}
end

function SimpleCamera(pos::SVector{3,T},
                      up::SVector{3,T},
                      fwd::SVector{3,T},
                      w::T, h::T, d::T,
                      w_px::I, h_px::I) where {T,I}
    w/h ≈ w_px/h_px ||
        @warn "Image plane ratio $(w/h) different from pixel ratio $(w_px/h_px)"

    dx = one(T)/(w_px - 1)
    dy = one(T)/(h_px - 1)

    z = zero(T)
    zv = SVector(z, z, z)

    cam = SimpleCamera(pos, up, fwd, zv,
                       w, h, d,
                       w_px, h_px,
                       dx, dy,
                       zv, zv, zv, zv)
    recalc!(cam)
end

function recalc!(cam::SimpleCamera{T}) where T
    cam.right = cross(cam.up, cam.fwd)
    cam.up = cross(cam.fwd, cam.right)
    half = one(T)/2

    cam.x₁ = cam.d*cam.fwd - half*cam.w*cam.right
    cam.x₂ = cam.d*cam.fwd + half*cam.w*cam.right
    cam.y₁ = cam.d*cam.fwd + half*cam.h*cam.up
    cam.y₂ = cam.d*cam.fwd - half*cam.h*cam.up

    cam
end

Images.width(cam::SimpleCamera) = cam.w_px
Images.height(cam::SimpleCamera) = cam.h_px

function Base.getindex(cam::SimpleCamera, i::T, j::T) where T
    t_x = (i-1)*cam.dx
    t_y = (j-1)*cam.dy
    dir = t_x * cam.x₁ + (one(T)-t_x) * cam.x₂ + t_y * cam.y₁ + (one(T)-t_y) * cam.y₂
    Ray(cam.pos, dir)
end

function lookat!(cam::SimpleCamera{T}, target::SVector{3,T},
                 up::SVector{3,T}=SVector(zero(T), one(T), zero(T))) where T
    cam.fwd = normalize(target - cam.pos)
    cam.up = normalize(up)
    recalc!(cam)
end

function Base.show(io::IO, ::MIME"text/plain", cam::SimpleCamera{T}) where T
    write(io, "SimpleCamera{$T} @ ")
    show(io, cam.pos)
    write(io, "\nAxes:\n")
    write(io, "- up:      ")
    show(io, cam.up)
    write(io, "\n- forward: ")
    show(io, cam.fwd)
    write(io, "\n- right:   ")
    show(io, cam.right)
    write(io, "\nImage plane:\n- $(cam.w) × $(cam.h) ($(cam.w_px) × $(cam.h_px) pixels);\n- $(cam.w/cam.h) aspect ratio\n- distance to image plane: $(cam.d)")
end

export Camera, SimpleCamera, lookat!
