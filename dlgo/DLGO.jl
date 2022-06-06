module DLGO
#__precompile__(false)

include("gotypes.jl")
include("goboardtypes.jl")

# include("goboard_slow.jl")
include("goboard.jl")

include("utils.jl")

include("agent/helpers.jl")
include("agent/naive.jl")

include("encoders/oneplaneEncoder.jl")
include("mcts/mcts.jl")

export GoString, GameState, Board, Move, Point, Player, black, white
export newgame, play, selectmove, applymove, isover, printboard, printmove, pointfromcoords, isplay
export MCTSAgent
export OnePlaneEncoder, encode, numpoints, shape, encodepoint

end