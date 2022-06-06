include("gotypes.jl")

struct Move{}
    point::Union{Point, Nothing}
    ispass::Bool
    isresign::Bool
end

Move(pt::Union{Point, Nothing}) = Move(pt, false, false)
Move() = Move(nothing)

struct GoString{}
    color::Player
    stones::Set{Point}
    liberties::Set{Point}
end


mutable struct Board{}
    numrows::UInt8
    numcols::UInt8
    grid::Dict{Point, GoString}
    hash::UInt64
end

Board(numrows::Integer, numcols::Integer) = Board(numcols, numrows, Dict{Point, GoString}(), EMPTYBOARD)
Board(num::Integer) = Board(num, num)

struct GameState
    board::Board
    nextplayer::Player
    previousstate::Union{GameState, Nothing}
    previousstates::Vector{Tuple{Player, UInt64}}
    lastmove::Union{Move, Nothing}
end

GameState(b::Board, nextplayer::Player, previous:: GameState, mv::Union{Move, Nothing}) =  GameState(b, nextplayer, previous, union(previous.previousstates, [(previous.nextplayer, zobristhash(previous.board))]), mv) 
GameState(b::Board, nextplayer::Player, mv::Union{Move, Nothing}) = GameState(b, nextplayer, nothing, Vector(Tuple{Player, UInt64}[]), mv)
GameState(b::Board, nextplayer::Player) = GameState(b, nextplayer, nothing)