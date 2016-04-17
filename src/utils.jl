using Images

save_clamped(filename::AbstractString, img::Image) = save(filename, map(Clamp(eltype(data(img))), img))

export save_clamped
