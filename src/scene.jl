# * Scene

mutable struct Scene{O<:Intersectable{<:AbstractFloat}}
    objs::Vector{O}
end
# Scene(objs::Vector{O}) where {T,O<:Intersectable{T}} = Scene{T,O}(objs)
Scene{O}() where {O} = Scene(Vector{O}())

Base.eltype(::Scene{O}) where O = O

Base.show(io::IO, scene::S) where {O,S<:Scene{O}} =
    write(io, "$S with $(length(scene.objs)) $(O)s")

function Scene(::Type{O}, filename::String) where {T,O<:Intersectable{T}}
    scene = Scene{O}()
    append!(scene, FileIO.load(filename))
    scene
end

function Base.append!(scene::Scene{Triangle{T}}, mesh::HomogenousMesh) where T
    objs = map(mesh.faces) do face
        Triangle(SVector.(mesh.vertices[face]), SVector.(mesh.normals[face]))
    end
    append!(scene.objs, objs)
    scene
end

function Base.append!(scene::Scene{O}, objs::Vector{O}) where {T,O<:Intersectable{T}}
    append!(scene.objs, objs)
    scene
end

function extents(scene::Scene)
    e = extents.(scene.objs)
    join_extents(a,b) = [(min(a[i][1],b[i][1]),max(a[i][2],b[i][2])) for i=1:3]
    reduce(join_extents, e, init=e[1])
end

Images.center(scene::Scene) = mean.(extents(scene))

# ** Random scenes
rand_point(::Type{T}) where T = SVector{3}(2rand(T)-1,2rand(T)-1,2rand(T)-1)

Random.rand(::Type{Triangle{T}}) where T =
    Triangle((rand_point(T), rand_point(T), rand_point(T)))

Random.rand(::Type{Sphere{T}}) where T =
    Sphere(rand_point(T), T(0.2)*rand(T))

Random.rand(::Type{Intersectable{T}}) where T =
    rand(rand([Triangle{T}, Sphere{T}]))

Random.rand(::Type{O}, n::Integer) where {T,O<:Intersectable{T}} =
    [rand(O) for i=1:n]

Random.rand(::Type{S}, n::Integer) where {T,O<:Intersectable{T},S<:Scene{O}} =
    Scene(rand(O, n))

# ** Scene file format

Base.write(io::IOStream, v::SVector) = write(io, "(", join(string.(v), ","), ")")

function Base.write(io::IOStream, s::Sphere)
    write(io, "Sphere ", string(eltype(s)), " ")
    write(io, s.pos, " ")
    write(io, string(s.radius), "\n")
end

function Base.write(io::IOStream, t::Triangle)
    write(io, "Triangle ", string(eltype(t)), " ")
    for v in [t.o, t.e₁, t.e₂, t.na, t.nb, t.nc]
        write(io, v, " ")
    end
    write(io, "\n")
end

function FileIO.save(f::File{format"RSC"},
                     objs::AbstractVector{O}) where {T,O<:Intersectable{T}}
    open(f, "w") do file
        write(file, magic(format"RSC"))
        write(file, '\n')
        for o in objs
            write(file, o)
        end
    end
end

FileIO.save(f::File{format"RSC"}, scene::Scene) = save(f, scene.objs)

function Base.parse(V::Type{SVector{N,T}}, s::AbstractString) where {N,T<:Number}
    s[1] == '(' && s[end] == ')' || error("Malformed $(V), $(s)")
    s = s[2:end-1]
    V([parse(T,c) for c in split(s, ",")]...)
end

read_primitive(P::Type{Sphere{T}}, pos, radius) where {T<:Number} =
    P(parse(SVector{3,T}, pos), parse(T, radius))

read_primitive(P::Type{Triangle{T}}, o, e₁, e₂, na, nb, nc) where {T<:Number} =
    P(parse(SVector{3,T}, o),
      parse(SVector{3,T}, e₁),
      parse(SVector{3,T}, e₂),
      parse(SVector{3,T}, na),
      parse(SVector{3,T}, nb),
      parse(SVector{3,T}, nc))

function FileIO.load(f::File{format"RSC"})
    open(f) do file
        skipmagic(file)
        readline(stream(file))
        FileIO.load(file)
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
    O = promote_type(unique(typeof.(objs))...)
    Scene{O}(objs)
end

export Scene, extents, save, load
