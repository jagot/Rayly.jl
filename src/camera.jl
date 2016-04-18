abstract Camera{T}

import Base.eltype
eltype{T}(c::Camera{T}) = T

type SimpleCamera{T<:AbstractFloat} <: Camera{T}
    pos::Point{3,T}
    up::Vec{3,T}
    fwd::Vec{3,T}
    right::Vec{3,T}
    w::T
    h::T
    d::T
    w_px::Integer
    h_px::Integer
    dx::T
    dy::T
    x1::Vec{3,T}
    x2::Vec{3,T}
    y1::Vec{3,T}
    y2::Vec{3,T}
end
function SimpleCamera{T<:AbstractFloat}(pos::Point{3,T},
                                        up::Vec{3,T},
                                        fwd::Vec{3,T},
                                        w::T, h::T, d::T,
                                        w_px, h_px)
    up,fwd = normalize(up), normalize(fwd)
    right = cross(up,fwd)

    dx = 1.0/(w_px - 1)
    dy = 1.0/(h_px - 1)

    x1 = d*fwd - 0.5w*right
    x2 = d*fwd + 0.5w*right
    y1 = d*fwd + 0.5h*up
    y2 = d*fwd - 0.5h*up

    SimpleCamera(pos, up, fwd, right,
                 w, h, d,
                 w_px, h_px,
                 dx, dy,
                 x1, x2, y1, y2)
end

import Images.width, Images.height
width(cam::SimpleCamera) = cam.w_px
height(cam::SimpleCamera) = cam.h_px

import Base.getindex
function getindex{T<:Real}(cam::SimpleCamera, i::T, j::T)
    t_x = (i-1)*cam.dx
    t_y = (j-1)*cam.dy
    dir = t_x * cam.x1 + (1.0-t_x) * cam.x2 + t_y * cam.y1 + (1.0-t_y) * cam.y2
    Ray{eltype(cam.pos)}(cam.pos, dir)
end

export Camera, SimpleCamera, getindex, width, height
