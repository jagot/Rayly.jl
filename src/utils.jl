import Images

save_clamped(filename::AbstractString, img::AbstractMatrix{<:RGB}) =
    Images.save(filename, map(clamp01, img))

export save_clamped
