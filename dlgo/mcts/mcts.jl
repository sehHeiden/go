include("../goboard.jl")
include("../goboard.jl")
using Random

mutable struct MCTSNode{}
    gamestate::GameState
    parent::Union{MCTSNode, Nothing}
    move::Union{Move, Nothing}
    wincounts::Dict{Player,UInt}
    numrollouts::UInt
    children::Vector{MCTSNode}
    unvisitedmoves::Vector
end

MCTSNode(gamestate, parent, move) = MCTSNode(gamestate, parent, move, Dict(black => 0x00, white => 0x00), 0, Vector{MCTSNode}([]), legalmoves(gamestate))
MCTSNode(gamestate) = MCTSNode(gamestate, nothing, nothing)

function addrandomchild!(mn::MCTSNode)
    index = rand(1:length(mn.unvisitedmoves))
    newmove = popat!(mn.unvisitedmoves, index)
    newgamestate = applymove(mn.gamestate, newmove)
    newnode = MCTSNode(newgamestate, mn, newmove)
    push!(mn.children, newnode)
    return newnode
end

function recordwin!(mn::MCTSNode, winner)
    mn.wincounts[winner] = mn.wincounts[winner] + 1
    mn.numrollouts = mn.numrollouts + 1    
end

function canaddchild(mn::MCTSNode)
    return length(mn.unvisitedmoves) > 0
end

function isterminal(mn::MCTSNode)
    return isover(mn.gamestate)
end

function winningfrac(mn::MCTSNode, pl::Player)
    return float(mn.wincounts[pl]) / float(mn.numrollouts)
end

struct MCTSAgent{}
    numrounds::UInt
    temperature::Float64
 end


 function selectmove(ma::MCTSAgent, gs::GameState)
    root = MCTSNode(gs)
    for i ∈ 1:ma.numrounds
        node = root
        while ! canaddchild(node) & ! isterminal(node)
            node = selectchild(ma, node)
        end
        if canaddchild(node)
            node = addrandomchild!(node)
        end
        winner = simulaterandomgame(node.gamestate)
        while ! isnothing(node)
            recordwin!(node, winner)
            node = node.parent
        end
    end
     bestmove = nothing
     bstpct = -1
     for child ∈ root.children
        childpct = winningfrac(child, gs.nextplayer)
        if childpct > bstpct
            bstpct = childpct
            bestmove = child.move
        end
    end
    return bestmove
 end

function selectchild(ma::MCTSAgent, node::MCTSNode)
    totalrollouts = sum(child.numrollouts for child in node.children)
    bestscore = -1
    bestchild = nothing
    for child in node.children
        score = uctscore(totalrollouts, child.numrollouts, winningfrac(child, node.gamestate.nextplayer), ma.temperature)
        if score > bestscore
            bestscore = score
            bestchild = child
        end
    end
    return bestchild
end

 function uctscore(parentrollouts::UInt, childrollouts::UInt, winpct::Float64, temperature::Float64)
     exploration = √(log(parentrollouts) / childrollouts)
     return winpct + temperature * exploration
 end