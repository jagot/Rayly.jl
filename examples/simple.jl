using Rayly, FixedSizeArrays, ColorTypes
using Images

function shade(i::Intersection)
    f = abs(dot(normal(i), i.ray.dir))
    RGB(f,f,f)
end

background = RGB(0.,0,0)

cam = SimpleCamera(Point{3}(0.,0,-5.0),
                   Vec{3}(0.,1,0),
                   Vec{3}(0.,0,1),
                   1.0, 1.0, 1.0,
                   400, 400)

acc = ListAccelerator(load("scene.rsc"))

@time img = render(cam, JitteredSampler(9)) do ray::Ray
    hit = Intersection(ray)
    Rayly.intersect!(acc, hit)
    !isnull(hit.o) ? shade(hit) : background
end

save_clamped("simple.png", img)
