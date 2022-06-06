using StatsBase
include("../goboard.jl")
# include("../goboard_slow.jl")


function selectmove(gs::GameState)
    """Chose a random valid move that preserves out own eyes"""

    candidates = Vector(Point[])
    for r ∈ 1:(gs.board.numrows)
        for c ∈ 1:(gs.board.numcols)
            candidate = Point(r, c)
            if isvalidmove(gs, play(candidate)) & !ispointaneye(gs.board, candidate, gs.nextplayer)
                push!(candidates, candidate)
            end
        end
    end
    if length(candidates) == 0
        return Move(nothing, true, false)
    end
    return play(sample(candidates))
end