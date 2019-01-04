add_format(format"RSC", "RSC", ".rsc")

Base.write(io::IOStream, v::SVector) = write(io, string(v))

function Base.write(io::IOStream, s::Sphere)
    write(io, "Sph ", string(eltype(s)), " ")
    write(io, s.pos, " ")
    write(io, string(s.radius), "\n")
end

function Base.write(io::IOStream, t::Triangle)
    write(io, "Tri ", string(eltype(t)))
    for v in [t.o, t.e1, t.e2, t.na, t.nb, t.nc]
        write(io, v, " ")
    end
    write(io, "\n")
end

function FileIO.save(f::File{format"RSC"},
                     objs::AbstractVector{Intersectable})
    open(f, "w") do file
        write(file, magic(format"RSC"))
        write(file, '\n')
        for o in objs
            write(file, o)
        end
    end
end

function Base.parse(::Type{SVector{N,T}}, s::AbstractString) where {N,T<:Number}
    s[1] == '(' && s[end] == ')' || error("Malformed $(V), $(s)")
    s = s[2:end-1]
    V([parse(T,c) for c in split(s, ",")]...)
end

read_primitive(P::Type{Sphere{T}}, pos, radius) where {T<:Number} =
    P(parse(Point{3,T}, pos), parse(T, radius))

read_primitive(P::Type{Triangle{T}}, o, e₁, e₂, na, nb, nc) where {T<:Number} =
    P(parse(Point{3,T}, o),
      parse(Vec{3,T}, e₁),
      parse(Vec{3,T}, e₂),
      parse(Vec{3,T}, na),
      parse(Vec{3,T}, nb),
      parse(Vec{3,T}, nc))

function FileIO.load(f::File{format"RSC"})
    open(f) do file
        skipmagic(file)
        readline(stream(file))
        load(file)
    end
end

function FileIO.load(s::Stream{format"RSC"})
    objs = Vector{Intersectable}()
    for line in eachline(stream(s))
        d = split(strip(line))
        P = eval(Symbol(d[1]))
        T = eval(Symbol(d[2]))
        push!(objs, read_primitive(P{T}, d[3:end]...))
    end
    objs
end
