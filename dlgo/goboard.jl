include("scoring.jl")
include("gotypes.jl")
include("goboardtypes.jl")
include("agent/zobrist.jl")



function play(pt::Point)
     m = Move(pt)
     return m
end

isplay(m::Move) = ! isnothing(m.point)

function passturn()
    m = Move(nothing, true, false)
    return m
end

function resign()
    m = Move(nothing, false, true)
    return  m
end


function withoutliberty(gs::GoString, pt::Point)
    newliberties = setdiff(gs.liberties, Set([pt]))
    return GoString(gs.color, gs.stones, newliberties)
end

function withliberty(gs::GoString, pt::Point)
    newliberties = union(gs.liberties, Set([pt]))
    return GoString(gs.color, gs.stones, newliberties)
end


function mergewith(fstgstring::GoString, sndgstring::GoString)
    @assert fstgstring.color == sndgstring.color

    combinedstones = union(fstgstring.stones, sndgstring.stones)
    return GoString(fstgstring.color, combinedstones, setdiff(union(fstgstring.liberties, sndgstring.liberties), combinedstones))
end

function numliberties(gstring::GoString)
    return length(gstring.liberties)
end

function equal(fstgstring::GoString, sndgstring::GoString)
    colorequal = fstgstring.color == sndgstring.color
    stonesqual = fstgstring.stones == sndgstring.stones
    libertiesequal = fstgstring.liberties == sndgstring.liberties
    return (typeof(sndgstring) == GoString) &  colorequal & stonesqual & libertiesequal
end


isongrid(b::Board, pt::Point)= (1 <= pt.row <= b.numrows) & (1 <= pt.col <= b.numcols)

function get(b::Board, pt::Point)
    string = Base.get(b.grid, pt, nothing)
    if isnothing(string)
        return nothing
    end

    return string.color
end

function getgostring(b::Board, pt::Point)
    string = Base.get(b.grid, pt, nothing)
    if isnothing(string)
        return nothing
    end

    return string
end

function placestone!(b::Board, player::Player, pt::Point)
    @assert isongrid(b, pt)
    @assert isnothing(get(b, pt))


    adjacentsamecolor = GoString[]
    adjacentoppositecolor = GoString[]
    liberties = Point[]
    for neighbor ∈ neighbors(pt)
        if ! isongrid(b, neighbor)
            continue
        end

        neighborstring = Base.get(b.grid, neighbor, nothing)

        if isnothing(neighborstring)
            push!(liberties, neighbor)
        elseif neighborstring.color == player
            if !(neighborstring ∈ adjacentsamecolor)
                push!(adjacentsamecolor, neighborstring)
            end
        else
            if !(neighborstring ∈ adjacentoppositecolor)
                push!(adjacentoppositecolor, neighborstring)
            end
        end
    end
    newstring = GoString(player, Set([pt]), Set(liberties))

    for samecolorstring ∈ adjacentsamecolor
        newstring =  mergewith(newstring, samecolorstring)
    end

    for newstringpoint ∈ newstring.stones
        b.grid[newstringpoint] = newstring
        b.hash = xor(b.hash, hashcode[pt, player])
    end

    for othercolorstring ∈ adjacentoppositecolor
        replacement = withoutliberty(othercolorstring, pt)
        if numliberties(replacement) > 0
            replacestring!(b, withoutliberty(othercolorstring, pt))
        else
            removestring!(b, othercolorstring)
        end
    end
end

function replacestring!(b::Board, newstring::GoString)
    for point in newstring.stones
        b.grid[point] = newstring
    end
end

function removestring!(b::Board, gs::GoString)
    for point in gs.stones
        for neigbor in neighbors(point)
            neighborstring = Base.get(b.grid, neigbor, nothing)
            if isnothing(neighborstring)
                continue
            end

            # What is the meaning, grid only allows to add GoString as value. 
            if typeof(neighborstring) != GoString
                replacestring!(b, withliberty(neighborstring, point))
            end
        end
        Base.pop!(b.grid, point)
        b.hash = xor(b.hash, hashcode[point, gs.color])
    end
end

function zobristhash(b::Board)
    return b.hash
end


function getsituation(gs::GameState)
    return (gs.nextplayer, gs.board)
end

function isover(gs::GameState)
    if isnothing(gs.lastmove)
        return false
    end

    if gs.lastmove.isresign
        return true
    end

    secondlastmove = gs.previousstate.lastmove
    if isnothing(secondlastmove)
        return false
    end

    return gs.lastmove.ispass & secondlastmove.ispass
end

function applymove(gs::GameState, mv::Move)
    if isplay(mv)
        nextboard=deepcopy(gs.board)
        placestone!(nextboard, gs.nextplayer, mv.point)
    else
        nextboard=gs.board
    end
    return GameState(nextboard, getother(gs.nextplayer), gs, mv)
end

function newgame(boardsize::Integer)
    board = Board(boardsize)

    return GameState(board, black)
end

function ismoveselfcapture(gs::GameState, player::Player, mv::Move)
    if !isplay(mv)
        return false
    end
    nextboard = deepcopy(gs.board)
    placestone!(nextboard, player, mv.point)
    newstring = getgostring(nextboard, mv.point)

    return  isnothing(newstring) ? false : numliberties(newstring) == 0
end

situation(gs::GameState) =  (gs.nextplayer, gs.board)

function doesmoveviolateko(gs::GameState, player::Player, mv::Move)
    if !isplay(mv)
        return false
    end

    nextboard = deepcopy(gs.board)
    placestone!(nextboard, player, mv.point)
    nextsituation = (getother(player), zobristhash(nextboard))

    return nextsituation ∈ gs.previousstates
end

function isvalidmove(gs::GameState, mv::Move)
    if isover(gs)
        return false
    end
    if mv.ispass | mv.isresign
        return true
    end

    isfree = isnothing(get(gs.board, mv.point))
    if isfree
        ismoveselfcaptured::Bool = ismoveselfcapture(gs, gs.nextplayer, mv)
        didviolateko::Bool = doesmoveviolateko(gs, gs.nextplayer, mv)

        return  ! ismoveselfcaptured & ! didviolateko
    else
        return false
    end
end


function legalmoves(gs::GameState)
    # code not found in the book but on: https://github.com/maxpumperla/deep_learning_and_the_game_of_go/blob/master/code/dlgo/goboard.py
    moves = Vector{Move}([])
    for row ∈ 1:gs.board.numrows
        for col ∈ 1:gs.board.numcols
            m = play(Point(row, col))
            if isvalidmove(gs, m)
                push!(moves, m)
            end
        end
    end
    # These two moves are always legal.
    push!(moves, passturn())
    push!(moves, resign())
    return moves
end


function winner(gs::GameState)
    # TODO is it needed, if not remove
    # code not found in the book but on: https://github.com/maxpumperla/deep_learning_and_the_game_of_go/blob/master/code/dlgo/goboard.py
    if ! isover(gs)
        return None
    end
    if gs.lastmove.isresign
        return gs.nextplayer
    end
    gameresult = computegameresult(gs)
    return winner(gameresult)
end

function simulaterandomgame(game::GameState)
  # code taken from: https://github.com/maxpumperla/deep_learning_and_the_game_of_go/blob/35f983cabb7294d84f2554dc4c23063f23f985b8/code/dlgo/mcts/mcts.py#L163
  bots = Dict(black => selectmove,
              white => selectmove,
             )
  while ! isover(game)
    botmove = bots[game.nextplayer](game)
    game = applymove(game, botmove)
  end
  return winner(game)
end
