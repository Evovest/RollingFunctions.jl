module RollingFunctions

using Base: @kwdef

export rolling,
       rollmin,  rollmax,             # min, max
       rollmean, rollmedian,          # mean, median
       rollvar,  rollstd,             # variance, standard deviation
       rollskewness, rollkurtosis,    # skewness, kurtosis
       rollsem,                       # standard error of the mean
       rollmad,                       # mean absolute deviation
       rollmad_normalized,            # mean absolute deviation for normal data
       rollvariation,                 # coefficient of variation
       running,                       #      tapering versions
       runmin,  runmax,               # min, max
       runmean, runmedian,            # mean, median
       runvar,  runstd,               # variance, standard deviation
       runskewness, runkurtosis,      # skewness, kurtosis
       runsem,                        # standard error of the mean
       runmad,                        # mean absolute deviation
       runmad_normalized,             # mean absolute deviation for normal data
       runvariation,                  # coefficient of variation
                                      # with two data vectors
       rollcor, rollcov,
       runcor, runcov
 
using LinearAlgebra: normalize

using Statistics: mean, median, std, var, cor, cov
using StatsBase:  kurtosis, mad, sem, skewness, variation,
                  AbstractWeights, Weights,
                  FrequencyWeights, AnalyticWeights, ProbabilityWeights

using KahanSummation: sum_kbn
using AccurateArithmetic: sum_oro

using LoopVectorization

const Sequence = Union{Vec, Tup} where {N, T, Vec<:AbstractVector{T}, Tup<:NTuple{N,T}}

include("support/exceptions.jl")
include("support/utils.jl")
include("support/normalize_weights.jl")
include("support/tapers.jl")

include("roll/roll.jl")
include("roll/rollvectors.jl")
#include("roll/rollvectors_weighted.jl")
include("roll/rollmatrix.jl")
#include("roll/rollvectors_tapering.jl")


#=
include("roll/rolling.jl")
include("run/running.jl")
include("roll/rollstats.jl")
include("run/runstats.jl")
include("roll/rolling2.jl")
include("run/running2.jl")
=#

end # RollingFunctions

