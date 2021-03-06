export mzeros, mones, mcopy, @mmap

function mmap_tempname()
    isdir(".mempool") || mkdir(".mempool")
    file = joinpath(".mempool", randstring())
end

for (fname, felt) in ((:mzeros, :zero), (:mones, :one))
    @eval begin
        $fname(a::AbstractArray, T::Type, dims::Tuple) = $fname(T, dims)
        $fname(a::AbstractArray, T::Type, dims...) = $fname(T, dims...)
        $fname(a::AbstractArray, T::Type = eltype(a)) = $fname(T, size(a))
        function $fname(T::Type, dims::Tuple)
            src = mmap_tempname()
            fid = open(src, "w+")
            for i in prod(dims)
                write(fid, $felt(T))
            end
            seekstart(fid)
            x = Mmap.mmap(fid, Array{T, length(dims)}, dims)
            fill!(x, $felt(T))
            close(fid)
            finalizer(z -> rm(src), x)
            return x
        end
        $fname(dims::Tuple) = ($fname)(Float64, dims)
        $fname(T::Type, dims...) = $fname(T, dims)
        $fname(dims...) = $fname(dims)
    end
end

function mcopy(x::AbstractArray{T, N}) where {T, N}
    src = mmap_tempname()
    fid = open(src, "w+")
    write(fid, x)
    seekstart(fid)
    xm = Mmap.mmap(fid, Array{T, N}, size(x))
    close(fid)
    finalizer(z -> rm(src), xm)
    return xm
end

macro mmap(ex)
    esc(ex)
end
