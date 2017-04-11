using FileIO
using FixedSizeArrays

add_format(format"RSC", "RSC", ".rsc")

import Base.write
write(io::IOStream, v::Union{Vec,Point}) = write(io, string(v[1:end]))
function write(io::IOStream, s::Sphere)
    write(io, "Sph ", string(eltype(s)), " ")
    write(io, s.pos, " ")
    write(io, string(s.radius), "\n")
end
function write(io::IOStream, t::Triangle)
    write(io, "Tri ", string(eltype(t)))
    for v in [t.o, t.e1, t.e2, t.na, t.nb, t.nc]
        write(io, v, " ")
    end
    write(io, "\n")
end

import FileIO.save
function save(f::File{format"RSC"},
              objs::AbstractVector{Intersectable})
    open(f, "w") do file
        write(file, magic(format"RSC"))
        write(file, '\n')
        for o in objs
            write(file, o)
        end
    end
end

import Base.parse
function parse{N,T<:Number}(V::Union{Type{Vec{N,T}},Type{Point{N,T}}}, s::AbstractString)
    s[1] == '(' && s[end] == ')' || error("Malformed $(V), $(s)")
    s = s[2:end-1]
    V([parse(T,c) for c in split(s, ",")]...)
end

read_primitive{T<:Number}(P::Type{Sphere{T}}, pos, radius) =
    P(parse(Point{3,T}, pos), parse(T, radius))
read_primitive{T<:Number}(P::Type{Triangle{T}}, o, e1, e2, na, nb, nc) =
    P(parse(Point{3,T}, o),
      parse(Vec{3,T}, e1),
      parse(Vec{3,T}, e2),
      parse(Vec{3,T}, na),
      parse(Vec{3,T}, nb),
      parse(Vec{3,T}, nc))

import FileIO.load
function load(f::File{format"RSC"})
    open(f) do file
        skipmagic(file)
        readline(stream(file))
        load(file)
    end
end

function load(s::Stream{format"RSC"})
    objs = Vector{Intersectable}()
    for line in eachline(stream(s))
        d = split(strip(line))
        P = eval(Symbol(d[1]))
        T = eval(Symbol(d[2]))
        push!(objs, read_primitive(P{T}, d[3:end]...))
    end
    objs
end

export save, load
