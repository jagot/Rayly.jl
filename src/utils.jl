save_clamped(filename::AbstractString, img::AbstractMatrix{<:RGB}) =
    save(filename, map(clamp01, img))

export save_clamped
