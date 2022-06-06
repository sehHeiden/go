include("../gotypes.jl")
include("../goboard.jl")
# include("../goboard_slow.jl")

function ispointaneye(b::Board, pt::Point, color::Player)
    if !isnothing(get(b, pt))
        return false
    end
    for neighbor ∈ neighbors(pt)
        if isongrid(b, neighbor)
            neighborcolor = get(b, neighbor)
            if neighborcolor != color
                return false
            end
        end
    end
    friendlycorners = 0
    offboardcorners = 0

    corners = [
        Point(pt.row - 1, pt.col - 1), 
        Point(pt.row - 1, pt.col + 1), 
        Point(pt.row + 1, pt.col - 1), 
        Point(pt.row + 1, pt.col + 1), 
    ]
    for corner ∈ corners
        if isongrid(b, corner)
            cornercolor = get(b, corner)
            if cornercolor == color
                friendlycorners+=1
            end
        else
            offboardcorners+=1
        end
    end
    if offboardcorners > 0
        return (offboardcorners + friendlycorners) == 4
    end
    return friendlycorners >= 3
end