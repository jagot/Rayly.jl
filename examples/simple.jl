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

acc = ListAccelerator()
rand_point() = Point{3,Float64}(2rand()-1,2rand()-1,2rand()-1)
for i = 1:10
    add!(acc, Sphere(rand_point(), 0.2rand()))
    add!(acc, Triangle(rand_point(), rand_point(), rand_point()))
end

@time img = render(cam) do ray::Ray
    hit = Rayly.intersect(acc, ray)
    hit != nothing ? shade(hit) : background
end

save_clamped("simple.png", img)
