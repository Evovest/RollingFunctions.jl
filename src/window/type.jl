using Base: @kwdef

abstract type AbstractWindow end

@kwdef mutable struct BasicWindow <: AbstractWindow
    const length::Int              # span of contiguous elements
    
                                   # >> it is an error to select both <<
    const drop_first::Bool=true    # omit results at start¹, if needed²
    const drop_final::Bool=false   # omit results at finish¹, if needed²

    const direct::Bool=true        # process from low indices to high
end

@kwdef mutable struct TrimmedWindow <: AbstractWindow
    const length::Int              # span of contiguous elements
    
                                   # >> it is an error to select both <<
    const trim_first::Bool=false   # use partial windowing over first elements, if needed
    const trim_final::Bool=false   # use partial windowing over final elements, if needed

    const direct::Bool=true        # process from low indices to high
end

@kwdef mutable struct PaddedWindow{T} <: AbstractWindow
    const length::Int              # span of contiguous elements
    
                                   # >> it is an error to select both <<
    const pad_first::Bool=false    # use partial windowing over first elements, if needed
    const pad_final::Bool=false    # use partial windowing over final elements, if needed
    const padding::T=missing       # the value with which to pad

    const direct::Bool=true        # process from low indices to high
end

@kwdef mutable struct OffsetWindow <: AbstractWindow
    const length::Int              # span of contiguous elements
    
                                   # >> setting both is supported <<
    offset_first::Int=0            # start  at index (offset_first + 1)
    offset_final::Int=0            # finish at index (length - offset_final)

    const direct::Bool=true        # process from low indices to high
end

@kwdef mutable struct OffsetBasicWindow <: AbstractWindow
    const length::Int              # span of contiguous elements
    
                                   # >> setting both is supported <<
    offset_first::Int=0            # start  at index (offset_first + 1)
    offset_final::Int=0            # finish at index (length - offset_final)
    
                                   # >> it is an error to select both <<
    const drop_first::Bool=true    # omit results at start¹, if needed²
    const drop_final::Bool=false   # omit results at finish¹, if needed²

    const direct::Bool=true        # process from low indices to high
end

@kwdef mutable struct OffsetTrimmedWindow <: AbstractWindow
    const length::Int              # span of contiguous elements
    
                                   # >> setting both is supported <<
    offset_first::Int=0            # start  at index (offset_first + 1)
    offset_final::Int=0            # finish at index (length - offset_final)

                                   # >> it is an error to select both <<
    const trim_first::Bool=false   # use partial windowing over first elements, if needed
    const trim_final::Bool=false   # use partial windowing over final elements, if needed

    const direct::Bool=true        # process from low indices to high
end

@kwdef mutable struct OffsetPaddedWindow{T} <: AbstractWindow
    const length::Int              # span of contiguous elements
    
                                   # >> setting both is supported <<
    offset_first::Int=0            # start  at index (offset_first + 1)
    offset_final::Int=0            # finish at index (length - offset_final)

                                   # >> it is an error to select both <<
    const pad_first::Bool=false    # use partial windowing over first elements, if needed
    const pad_final::Bool=false    # use partial windowing over final elements, if needed
    const padding::T=missing       # the value with which to pad

    const direct::Bool=true        # process from low indices to high
end




@kwdef mutable struct Window{T} <: AbstractWindow
    const length::Int              # span of contiguous elements
    
    offset_first::Int=0            # start  at index offset_first + 1
    offset_final::Int=0            # finish at index length - offset_final + 1

    pad_first::Int=0               # pad with this many paddings at start
    pad_final::Int=0               # pad with this many padding at end
    const padding::T=nothing       # use this as the value with which to pad

    const direct::Bool=true        # process from low indices to high

    const onlywhole::Bool=true     # prohibit partial windows
    const drop_first::Bool=true    # omit results at start¹, if needed²
    const drop_final::Bool=false   # omit results at finish¹, if needed²

    const trim_first::Bool=false   # use partial windowing over first elements, if needed
    const trim_final::Bool=false   # use partial windowing over final elements, if needed
    
    const fill_first::Bool=true    # a simpler, often faster alternative to trim
    const fill_final::Bool=false   # a simpler, often faster alternative to trim
end

@kwdef mutable struct WeightedWindow{Pad,F,T} <: AbstractWindow
    window::Window{Pad}          # struct annotated above
    weightfun::F=nothing         # a function that yields the weights
    weighting::Vector{T}         # the weights collected
end

# the weight function is optional
# if you specify a weight function, the `weighting` will be autogenerated
# >> weightings are checked to ensure they sum to 1

# is indexing to be offset
notoffset(w::Window) = iszero(w.offset_first) && iszero(w.offset_final)
isoffset(w::Window) = !notoffset(w)
# >> specifying both a leading offset and a trailing offset is supported

# is there to be padding
notpadded(w::Window) = iszero(w.pad_first) && iszero(w.pad_final)
ispadded(w::Window) = !notpadded(w)
# >> it is an error to specify both a leading padding and a trailing padding

# is the information processed in direct (lower index to higher index) order
isdirect(w::Window) = w.direct

# are only complete window spans to be allowed
onlywhole(w::Window) = w.onlywhole
allowpartial(w::Window) = !onlywhole(w)

# is dropping incomplete results expected
isdropping(w::Window) = (w.drop_first ⊻ w.drop_final)
notdropping(w::Window) = !isdropping(w)
# >> it is an error to select both `drop_first` and `drop_final`
  
# is trimmed windowing to be allowed
maytrim(w::Window) = allowspartials(w) && (w.trim_first ⊻ w.trim_last)
# >> it is an error to select both `trim_first` and `trim_final`
# >> it is an error to select either `trim` and select any `fill`

# is filled windowing to be allowed
mayfill(w::Window) = allowspartials(w) && (w.fill_first ⊻ w.fill_last)
# >> it is an error to select both `fill_first` and `fill_final`
# >> it is an error to select either `fill` and select any `trim`


#=

    ¹ "at start"  is from the lowest  indices where `direct == true`
                  is from the highest indices where `direct == false`

      "at finish" is from the highest indices where `direct == true`
                  is from the lowest  indices where `direct == false`

    ² "if needed" is true if and only if `onlywhole == true` and
                  `!iszero(rem(data_length, window_length))`
=#

