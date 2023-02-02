#=
   basic_running(window_fn, data1, window_span) ..
   basic_running(window_fn, data1, data2, data3, data4, window_span)

   padded_running(window_fn, data1, window_span; padding) ..
   padded_running(window_fn, data1, data2, data3, data4, window_span; padding)
=#

#=
   basic_running(window_fn, data1, window_span) ..
   basic_running(window_fn, data1, data2, data3, data4, window_span)

   padded_running(window_fn, data1, window_span; padding) ..
   padded_running(window_fn, data1, data2, data3, data4, window_span; padding)
=#

function basic_running(window_fn::Function, data1::AbstractVector{T}, window_span::Int, weights::AbstractVector{T}) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷweights = asview(weights)
    n = length(ᵛʷdata1)
    nvalues = nrolled(n, window_span)
    ntapers = n - nvalues

    rettype  = rts(window_fn, (Vector{T},))
    results = Vector{rettype}(undef, n)

    @tturbo for idx in 1:ntapers
        wts = fast_normalize(ᵛʷweights[window_span:-1:window_span-idx+1])
        @views results[idx] = window_fn(ᵛʷdata1[1:idx] .* wts)
    end

    ilow, ihigh = 1, window_span
    @tturbo for idx in ntapers+1:n
        @views results[idx] = window_fn(ᵛʷdata1[ilow:ihigh] .* ᵛʷweights)
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    results
end

function basic_running(window_fn::Function, 
    data1::AbstractVector{T}, data2::AbstractVector{T}, 
    window_span::Int, weights::AbstractVector{T}) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷweights = asview(weights)
    n = min(length(ᵛʷdata1), length(ᵛʷdata2))
    nvalues = nrolled(n, window_span)
    ntapers = n - nvalues

    rettype  = rts(window_fn, (Vector{T},))
    results = Vector{rettype}(undef, n)

    @tturbo for idx in 1:ntapers
        wts = fast_normalize(ᵛʷweights[1:idx])
        @views results[idx] = window_fn(ᵛʷdata1[1:idx] .* wts, ᵛʷdata2[1:idx] .* wts)
    end

    ilow, ihigh = 1, window_span
    @tturbo for idx in ntapers+1:n
        @views results[idx] = window_fn(ᵛʷdata1[ilow:ihigh] .* ᵛʷweights, ᵛʷdata2[ilow:ihigh] .* ᵛʷweights)
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    results
end

function basic_running(window_fn::Function, data1::AbstractVector{T}, data2::AbstractVector{T}, data3::AbstractVector{T}, 
                       window_span::Int, weights::AbstractVector{T}) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷdata3 = asview(data3)
    ᵛʷweights = asview(weights)
    n = min(length(ᵛʷdata1),length(ᵛʷdata2),length(ᵛʷdata3))
    nvalues  = nrolled(n, window_span)
    ntapers = n - nvalues
 
    rettype  = rts(window_fn, (Vector{T}, Vector{T}, Vector{T}))
    results = Vector{rettype}(undef, nvalues)

    @tturbo for idx in 1:ntapers
        wts = fast_normalize(ᵛʷweights[1:idx])
        @views results[idx] = window_fn(ᵛʷdata1[1:idx] .* wts, ᵛʷdata2[1:idx] .* wts), ᵛʷdata3[1:idx] .* wts
    end

    ilow, ihigh = 1, window_span
    @tturbo for idx in eachindex(results)
        @views results[idx] = window_fn(ᵛʷdata1[ilow:ihigh] .* ᵛʷweights, ᵛʷdata2[ilow:ihigh] .* ᵛʷweights, ᵛʷdata3[ilow:ihigh] .* ᵛʷweights)
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    results
end

function basic_running(window_fn::Function, data1::AbstractVector{T}, data2::AbstractVector{T}, data3::AbstractVector{T}, data4::AbstractVector{T},
                       window_span::Int, weights::AbstractVector{T}) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷdata3 = asview(data3)
    ᵛʷdata4 = asview(data4)
    ᵛʷweights = asview(weights)
    n = min(length(ᵛʷdata1),length(ᵛʷdata2),length(ᵛʷdata3),length(ᵛʷdata4))
    nvalues  = nrolled(n, window_span)
    ntapers = n - nvalues

    rettype  = rts(window_fn, (Vector{T}, Vector{T}, Vector{T}, Vector{T}))
    results = Vector{rettype}(undef, nvalues)

    @tturbo for idx in 1:ntapers
        wts = fast_normalize(ᵛʷweights[1:idx])
        @views results[idx] = window_fn(ᵛʷdata1[1:idx] .* wts, ᵛʷdata2[1:idx] .* wts, ᵛʷdata3[1:idx] .* wts, ᵛʷdata4[1:idx] .* wts)
    end

    ilow, ihigh = 1, window_span
    @tturbo for idx in eachindex(results)
        @views results[idx] = window_fn(ᵛʷdata1[ilow:ihigh] .* ᵛʷweights, ᵛʷdata2[ilow:ihigh] .* ᵛʷweights, ᵛʷdata3[ilow:ihigh .* ᵛʷweights], ᵛʷdata4[ilow:ihigh .* ᵛʷweights])
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    results
end


# pad first

function padded_running(window_fn::Function,
    data1::AbstractVector{T},
    window_span::Int, weights::AbstractVector{T}; padding::AbstractVector{T}) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷweights = asview(weights)
    ᵛʷpadding = asview(padding)
    n = length(ᵛʷdata1)
    npads = length(padding)
    nvalues = nrolled(n, window_span)
    ntapers = n - nvalues - npads

    rettype = rts(window_fn, (Vector{T},))
    results = Vector{rettype}(undef, n)

    results[1:npads] .= ᵛʷpadding
    @tturbo for idx in npads+1:npads+ntapers
        @views results[idx] = window_fn(ᵛʷdata1[1:idx])
    end

    ilow, ihigh = 1, window_span
    @tturbo for idx in npads+ntapers+1:n
        @views results[idx] = window_fn(ᵛʷdata1[ilow:ihigh])
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    results
end

function padded_running(window_fn::Function,
    data1::AbstractVector{T}, data2::AbstractVector{T},
    window_span::Int, weights::AbstractVector{T}; padding::AbstractVector{T}) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷweights = asview(weights)
    ᵛʷpadding = asview(padding)
    n = min(length(ᵛʷdata1), length(ᵛʷdata2))
    npads = length(padding)
    nvalues = nrolled(n, window_span)
    ntapers = n - nvalues - npads

    rettype = rts(window_fn, (Vector{T},))
    results = Vector{rettype}(undef, n)

    results[1:npads] .= ᵛʷpadding
    @tturbo for idx in npads+1:npads+ntapers
        @views results[idx] = window_fn(ᵛʷdata1[1:idx], ᵛʷdata2[1:idx])
    end

    ilow, ihigh = 1, window_span
    @tturbo for idx in npads+ntapers+1:n
        @views results[idx] = window_fn(ᵛʷdata1[ilow:ihigh], ᵛʷdata2[ilow:ihigh])
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    results
end

function padded_running(window_fn::Function,
    data1::AbstractVector{T}, data2::AbstractVector{T}, data3::AbstractVector{T},
    window_span::Int, weights::AbstractVector{T}; padding::AbstractVector{T}) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷdata3 = asview(data3)
    ᵛʷweights = asview(weights)
    ᵛʷpadding = asview(padding)
    n = min(length(ᵛʷdata1), length(ᵛʷdata2), length(ᵛʷdata3))
    npads = length(padding)
    nvalues = nrolled(n, window_span)
    ntapers = n - nvalues - npads

    rettype = rts(window_fn, (Vector{T},))
    results = Vector{rettype}(undef, n)

    results[1:npads] .= ᵛʷpadding
    @tturbo for idx in npads+1:npads+ntapers
        @views results[idx] = window_fn(ᵛʷdata1[1:idx], ᵛʷdata2[1:idx], ᵛʷdata3[1:idx])
    end

    ilow, ihigh = 1, window_span
    @tturbo for idx in npads+ntapers+1:n
        @views results[idx] = window_fn(ᵛʷdata1[ilow:ihigh], ᵛʷdata2[ilow:ihigh], ᵛʷdata3[1:idx])
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    results
end

function padded_running(window_fn::Function,
    data1::AbstractVector{T}, data2::AbstractVector{T}, data3::AbstractVector{T}, data4::AbstractVector{T},
    window_span::Int, weights::AbstractVector{T}; padding::AbstractVector{T}) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷdata3 = asview(data3)
    ᵛʷdata4 = asview(data4)
    ᵛʷweights = asview(weights)
    ᵛʷpadding = asview(padding)
    n = min(length(ᵛʷdata1), length(ᵛʷdata2), length(ᵛʷdata3), length(ᵛʷdata4))
    npads = length(padding)
    nvalues = nrolled(n, window_span)
    ntapers = n - nvalues - npads

    rettype = rts(window_fn, (Vector{T},))
    results = Vector{rettype}(undef, n)

    results[1:npads] .= ᵛʷpadding
    @tturbo for idx in npads+1:npads+ntapers
        @views results[idx] = window_fn(ᵛʷdata1[1:idx], ᵛʷdata2[1:idx], ᵛʷdata3[1:idx], ᵛʷdata4[1:idx])
    end

    ilow, ihigh = 1, window_span
    @tturbo for idx in npads+ntapers+1:n
        @views results[idx] = window_fn(ᵛʷdata1[ilow:ihigh], ᵛʷdata2[ilow:ihigh], ᵛʷdata3[1:idx], ᵛʷdata4[1:idx])
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    results
end

#=



function basic_running(window_fn::Function, data1::AbstractVector{T}, window_span::Int, weights::AbstractVector{T}) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷweights = asview(weights)

    n = length(ᵛʷdata1)
    nvalues  = nrolled(n, window_span)
   
    rettype  = rts(window_fn, (Vector{eltype(ᵛʷdata1)},))
    results = Vector{rettype}(undef, nvalues)

    ilow, ihigh = 1, window_span
    @tturbo for idx in eachindex(results)
        @views results[idx] = window_fn(ᵛʷdata1[ilow:ihigh] .* ᵛʷweights)
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    results
end

function basic_running(window_fn::Function, data1::AbstractVector{T}, data2::AbstractVector{T}, window_span::Int, weights::AbstractVector{T}) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷweights = asview(weights)

    n = min(length(ᵛʷdata1),length(ᵛʷdata2))
    nvalues  = nrolled(n, window_span)
   
    rettype  = rts(window_fn, (Vector{eltype(ᵛʷdata1)}, Vector{eltype(ᵛʷdata2)}))
    results = Vector{rettype}(undef, nvalues)

    ilow, ihigh = 1, window_span
    @tturbo for idx in eachindex(results)
        @views results[idx] = window_fn(ᵛʷdata1[ilow:ihigh] .* ᵛʷweights, ᵛʷdata2[ilow:ihigh] .* ᵛʷweights)
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    results
end

function basic_running(window_fn::Function, data1::AbstractVector{T}, data2::AbstractVector{T}, data3::AbstractVector{T}, 
                       window_span::Int, weights::AbstractVector{T}) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷdata3 = asview(data3)
    ᵛʷweights = asview(weights)

    n = min(length(ᵛʷdata1),length(ᵛʷdata2),length(ᵛʷdata3))
    nvalues  = nrolled(n, window_span)
   
    rettype  = rts(window_fn, (Vector{eltype(ᵛʷdata1)}, Vector{eltype(ᵛʷdata2)}, Vector{eltype(ᵛʷdata3)}))
    results = Vector{rettype}(undef, nvalues)

    ilow, ihigh = 1, window_span
    @tturbo for idx in eachindex(results)
        @views results[idx] = window_fn(ᵛʷdata1[ilow:ihigh] .* ᵛʷweights, ᵛʷdata2[ilow:ihigh] .* ᵛʷweights, ᵛʷdata3[ilow:ihigh] .* ᵛʷweights)
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    results
end

function basic_running(window_fn::Function, data1::AbstractVector{T}, data2::AbstractVector{T}, data3::AbstractVector{T}, data4::AbstractVector{T},
                       window_span::Int, weights::AbstractVector{T}) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷdata3 = asview(data3)
    ᵛʷdata4 = asview(data4)
    ᵛʷweights = asview(weights)

    n = min(length(ᵛʷdata1),length(ᵛʷdata2),length(ᵛʷdata3),length(ᵛʷdata4))
    nvalues  = nrolled(n, window_span)
   
    rettype  = rts(window_fn, (Vector{eltype(ᵛʷdata1)}, Vector{eltype(ᵛʷdata2)}, Vector{eltype(ᵛʷdata3)}, Vector{eltype(ᵛʷdata4)}))
    results = Vector{rettype}(undef, nvalues)

    ilow, ihigh = 1, window_span
    @tturbo for idx in eachindex(results)
        @views results[idx] = window_fn(ᵛʷdata1[ilow:ihigh] .* ᵛʷweights, ᵛʷdata2[ilow:ihigh] .* ᵛʷweights, ᵛʷdata3[ilow:ihigh] .* ᵛʷweights, ᵛʷdata4[ilow:ihigh] .* ᵛʷweights)
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    results
end


# pad first

function padded_running(window_fn::Function, data1::AbstractVector{T},
                        window_span::Int, weights::AbstractVector{T}; padding=Nothing) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷweights = asview(weights)

    n = length(ᵛʷdata1)

    nvalues  = nrolled(n, window_span) 
    # only completed window_span coverings are resolvable
    # the first (window_span - 1) values are unresolved wrt window_fn
    padding_span = window_span - 1
    padding_idxs = nvalues-padding_span:nvalues

    rettype  = rts(window_fn, (Vector{eltype(ᵛʷdata1)},))
    results = Vector{Union{typeof(padding), rettype}}(undef, n)
    results[padding_idxs] .= padding

    ilow, ihigh = 1, window_span
    @tturbo for idx in window_span:n
        @views results[idx] = window_fn(ᵛʷdata1[ilow:ihigh] .* ᵛʷweights)
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    results
end 

function padded_running(window_fn::Function, data1::AbstractVector{T}, data2::AbstractVector{T},
                        window_span::Int, weights::AbstractVector{T}; padding=Nothing) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷweights = asview(weights)

    n = min(length(ᵛʷdata1), length(ᵛʷdata2))
 
    nvalues  = nrolled(n, window_span)
    # only completed window_span coverings are resolvable
    # the first (window_span - 1) values are unresolved wrt window_fn
    padding_span = window_span - 1
    padding_idxs = nvalues-padding_span:nvalues
 
    rettype  = rts(window_fn, (Vector{eltype(ᵛʷdata1)}, Vector{eltype(ᵛʷdata2)}))
    results = Vector{Union{typeof(padding), rettype}}(undef, n)
    results[padding_idxs] .= padding

    ilow, ihigh = 1, window_span
    @tturbo for idx in 1:nvalues-padding_span
        @views results[idx] = window_fn(ᵛʷdata1[ilow:ihigh] .* ᵛʷweights, ᵛʷdata2[ilow:ihigh] .* ᵛʷweights)
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    results
end 

function padded_running(window_fn::Function, data1::AbstractVector{T}, data2::AbstractVector{T}, data3::AbstractVector{T},
                        window_span::Int, weights::AbstractVector{T}; padding=Nothing) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷdata3 = asview(data3)
    ᵛʷweights = asview(weights)

    n = min(length(ᵛʷdata1), length(ᵛʷdata2), length(ᵛʷdata3))

    nvalues  = nrolled(n, window_span)
    # only completed window_span coverings are resolvable
    # the first (window_span - 1) values are unresolved wrt window_fn
    padding_span = window_span - 1
    padding_idxs = nvalues-padding_span:nvalues
   
    rettype  = rts(window_fn, (Vector{eltype(ᵛʷdata1)}, Vector{eltype(ᵛʷdata2)}, Vector{eltype(ᵛʷdata3)}))
    results = Vector{Union{typeof(padding), rettype}}(undef, n)
    results[padding_idxs] .= padding

    ilow, ihigh = 1, window_span
    @tturbo for idx in 1:nvalues-padding_span
        @views results[idx] = window_fn(ᵛʷdata1[ilow:ihigh] .* ᵛʷweights, ᵛʷdata2[ilow:ihigh] .* ᵛʷweights, ᵛʷdata3[ilow:ihigh] .* ᵛʷweights)
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    results
end

function padded_running(window_fn::Function, data1::AbstractVector{T}, data2::AbstractVector{T}, data3::AbstractVector{T}, data4::AbstractVector{T},
                        window_span::Int, weights::AbstractVector{T}; padding=Nothing) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷdata3 = asview(data3)
    ᵛʷdata4 = asview(data4)
    ᵛʷweights = asview(weights)

    n = min(length(ᵛʷdata1), length(ᵛʷdata2), length(ᵛʷdata3), length(ᵛʷdata4))
      
    nvalues  = nrolled(min(length(ᵛʷdata1),length(ᵛʷdata2),length(ᵛʷdata3),length(ᵛʷdata4)), window_span)
    # only completed window_span coverings are resolvable
    # the first (window_span - 1) values are unresolved wrt window_fn
    padding_span = window_span - 1
    padding_idxs = nvalues-padding_span:nvalues
   
    rettype  = rts(window_fn, (Vector{eltype(ᵛʷdata1)}, Vector{eltype(ᵛʷdata2)}, Vector{eltype(ᵛʷdata3)}, Vector{eltype(ᵛʷdata4)}))
    results = Vector{Union{typeof(padding), rettype}}(undef, n)
    results[padding_idxs] .= padding

    ilow, ihigh = 1, window_span
    @tturbo for idx in 1:nvalues-padding_span
        @views results[idx] = window_fn(ᵛʷdata1[ilow:ihigh] .* ᵛʷweights, ᵛʷdata2[ilow:ihigh] .* ᵛʷweights, ᵛʷdata3[ilow:ihigh] .* ᵛʷweights, ᵛʷdata4[ilow:ihigh] .* ᵛʷweights)
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    results
end 
=#

