using Images

save_clamped(filename::AbstractString, img::AbstractMatrix) =
    save(filename, map(clamp01, img))

export save_clamped
