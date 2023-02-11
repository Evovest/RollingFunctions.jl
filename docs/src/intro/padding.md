You may pad the result with the padding value of your choice

padding is a keyword argument
- if you assign e.g. padding = missing, the result will be padded
- you may pad using any defined value and all types except Nothing
- example pads `(missing, 0, nothing, NaN, '∅', AbstractString)`

```
using RollingFunctions

𝐃𝐚𝐭𝐚 = [1, 2, 3, 4, 5]
𝐅𝐮𝐧𝐜 = sum
𝐒𝐩𝐚𝐧 = 3

result = rolling(𝐅𝐮𝐧𝐜, 𝐃𝐚𝐭𝐚, 𝐒𝐩𝐚𝐧; padding = missing);
#=
5-element Vector{Union{Missing, Int64}}:
   missing
   missing
  6
  9
 12
=#
 
result = rolling(𝐅𝐮𝐧𝐜, 𝐃𝐚𝐭𝐚, 𝐒𝐩𝐚𝐧; padding = zero(eltype(𝐃𝐚𝐭𝐚));
#=
5-element Vector{Int64}:
  0
  0
  6
  9
 12
=#
```

### Give me the real values first, pad to the end.
```
result = rolling(𝐅𝐮𝐧𝐜, 𝐃𝐚𝐭𝐚, 𝐒𝐩𝐚𝐧; padding = missing, padlast=true);
#=
5-element Vector{Union{Missing,Int64}}:
  6
  9
 12
  missing
  missing
=#
```

**technical aside:** this is not the same as reverse(rolling(𝐅𝐮𝐧𝐜, 𝐃𝐚𝐭𝐚, 𝐒𝐩𝐚𝐧; padding = zero(eltype(𝐃𝐚𝐭𝐚)).
