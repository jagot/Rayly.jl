abstract type Camera{T<:AbstractFloat} end

Base.eltype(::Camera{T}) where T = T

struct SimpleCamera{T,I<:Integer} <: Camera{T}
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
    up,fwd = normalize(up), normalize(fwd)
    right = cross(up,fwd)

    dx = inv(w_px - 1)
    dy = inv(h_px - 1)

    x₁ = d*fwd - 0.5w*right
    x₂ = d*fwd + 0.5w*right
    y₁ = d*fwd + 0.5h*up
    y₂ = d*fwd - 0.5h*up

    SimpleCamera(pos, up, fwd, right,
                 w, h, d,
                 w_px, h_px,
                 dx, dy,
                 x₁, x₂, y₁, y₂)
end

Images.width(cam::SimpleCamera) = cam.w_px
Images.height(cam::SimpleCamera) = cam.h_px

function Base.getindex(cam::SimpleCamera, i::T, j::T) where T
    t_x = (i-1)*cam.dx
    t_y = (j-1)*cam.dy
    dir = t_x * cam.x₁ + (one(T)-t_x) * cam.x₂ + t_y * cam.y₁ + (one(T)-t_y) * cam.y₂
    Ray(cam.pos, dir)
end

export Camera, SimpleCamera
