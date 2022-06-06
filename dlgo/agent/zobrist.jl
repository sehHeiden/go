using Random
include("../gotypes.jl")

hashcode = Dict{Tuple{Point, Player}, UInt64}()
const EMPTYBOARD = 0
for row ∈ 1:19
    for col ∈ 1:19
        for state ∈ (black, white)
            code = rand(0:typemax(UInt64))
            hashcode[Point(row, col), state] = code
        end
    end
end
