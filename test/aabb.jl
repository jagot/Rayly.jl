@testset "AABB" begin
    @testset "Construction" begin
        for T in [Float16, Float32, Float64]
            e = one(T)
            z = zero(T)
            a = AABB(SVector(-2e,-2e,-2e),SVector(-e,-e,-e))
            b = AABB(SVector(-2e,-2e,-2e),SVector(-3e,-3e,-3e))
            c = AABB(a, b)
            @test c.pmin == SVector(-3e,-3e,-3e)
            @test c.pmax == SVector(-e,-e,-e)
        end
    end
    @testset "Intersections" begin
        for T in [Float16, Float32, Float64]
            e = one(T)
            for ϵ in [eps(T), e/10]
                z = zero(T)
                
                finite_aabb = AABB(SVector(-e,-e,-e), SVector(e,e,e))

                r₁ = Ray(SVector(z, z, 2e), SVector(z, z, -e))
                @test intersect(r₁, finite_aabb)
                
                r₂ = Ray(SVector(z, z, 2e), SVector(z, z, e))
                @test !intersect(r₂, finite_aabb)
                
                r₃ = Ray(SVector(z, z, 2e), SVector(e,e,-(e+ϵ)))
                @test intersect(r₃, finite_aabb)
                
                r₄ = Ray(SVector(z, z, 2e), SVector(e,e,-(e-ϵ)))
                @test !intersect(r₄, finite_aabb)
                
                r₅ = Ray(SVector(z, e-ϵ, 2e), SVector(z,z,-e))
                @test intersect(r₅, finite_aabb)
                
                r₆ = Ray(SVector(z, e+ϵ, 2e), SVector(z,z,-e))
                @test !intersect(r₆, finite_aabb)
            end
        end
    end    
end
