You may pad the result with the padding value of your choice

padding is a keyword argument
- if you assign e.g. padding = missing, the result will be padded
- you may pad using any defined value and all types except Nothing
- example pads `(missing, 0, nothing, NaN, '∅', AbstractString)`

```
using RollingFunctions

𝐃𝐚𝐭𝐚₁ = [1, 2, 3, 4, 5]
𝐃𝐚𝐭𝐚₂ = [5, 4, 3, 2, 1]

𝐅𝐮𝐧𝐜 = cov
𝐒𝐩𝐚𝐧 = 3

result = rolling(𝐅𝐮𝐧𝐜, 𝐃𝐚𝐭𝐚₁, 𝐃𝐚𝐭𝐚₂, 𝐒𝐩𝐚𝐧; padding = zero(eltype(ℳ)))
#=
5 element Vector {Float64}:
  0.0
  0.0
 -1.0
 -1.0
 -1.0
=#
```

### Give me the real values first, pad to the end.
```
result = rolling(𝐅𝐮𝐧𝐜, 𝐃𝐚𝐭𝐚₁, 𝐃𝐚𝐭𝐚₂, 𝐒𝐩𝐚𝐧; padding = missing, padlast=true)
#=
5 element Vector {Float64}:
 -1.0
 -1.0
 -1.0
  missing
  missing
=#
```
**technical aside:** this is not the same as reverse(rolling(𝐅𝐮𝐧𝐜, 𝐃𝐚𝐭𝐚₁, 𝐃𝐚𝐭𝐚₂, 𝐒𝐩𝐚𝐧; padding = missing).


