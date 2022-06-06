include("gotypes.jl")
include("goboard.jl")
# include("../goboard_slow.jl")

const COLS = "ABCDEFGHJKLMNOPQRST"

STONETOCHAR = Dict(
    nothing => '.',
    black => 'x',
    white => "o",
)

function printmove(p::Player, mv::Move)
    if mv.ispass
        movestr = "passes"
    elseif mv.isresign
        movestr = "resigns"
    else
        movestr = "$(COLS[mv.point.col])$(mv.point.row)."
    end
    println("$p, $movestr")
end

function printboard(b::Board)
    for row ∈ b.numrows:-1:1
        bump =  row <= 9 ? " " :  ""
        line  = []
        for col ∈ 1:b.numcols
            stone = get(b, Point(row, col))
            push!(line, STONETOCHAR[stone])
        end
        println("$bump $row $(join(line))")
    end
    println("    " * join(COLS[1:b.numcols]))
end

function pointfromcoords(coords::Union{String, SubString})
    col = UInt8(findfirst(coords[1], COLS))
    row = parse(UInt8, coords[2:length(coords)])
    return Point(row, col)
end