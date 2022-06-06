include("../gotypes.jl")
include("../goboard.jl")

struct OnePlaneEncoder{}
    boardwith::UInt8
    boardheith::UInt8
    num_planes::UInt
    name::String
end

OnePlaneEncoder(boardsize::Tuple{UInt8, UInt8}) = OnePlaneEncoder(boardsize[1], boardsize[2], 1, "oneplane")
OnePlaneEncoder(boardsize::UInt8) = OnePlaneEncoder((boardsize, boardsize))

function name(oplenc::OnePlaneEncoder)
    return oplenc.name
end

function encode(oplenc::OnePlaneEncoder, gs::GameState)
    boadmatrix = zeros(shape(oplenc))
    nextplayer = gs.nextplayer
    for r in 1:oplenc.boardheith
        for c in 1:oplenc.boardwith
            p = Point(r, c)
            gostring = getgostring(gs.board, p)

            if isnothing(gostring)
                continue
            end
            if gostring.color == nextplayer
                boadmatrix[1, r, c] = 1
            else
                boadmatrix[1, r, c] = -1
            end
        end
    end
    return boadmatrix
end

function encodepoint(oplenc::OnePlaneEncoder, pt::Point)
    return oplenc.boardwith*(pt.row - 1) + pt.col
end

function decodepointindex(oplenc::OnePlaneEncoder, index::UInt)
    row = index // oplenc.boardwith
    col = index % oplenc.boardwith 
    
    return Point(row, col)
end

function numpoints(oplenc::OnePlaneEncoder)
    return oplenc.boardwith * oplenc.boardheith    
end

function shape(oplenc::OnePlaneEncoder)
    return oplenc.num_planes, oplenc.boardheith, oplenc.boardwith
end

