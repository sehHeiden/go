include("dlgo/DLGO.jl")
using .DLGO

function main()
    boardsize = 9
    game = newgame(boardsize)
    
    while !isover(game)
        sleep(0.3)
        print(Char(27) * "[2J")
        printboard(game.board)

        if game.nextplayer == black
            println()
            println("--")
            humanmove = readline()
            point = pointfromcoords(strip(humanmove))
            move = play(point)
        else
            move = selectmove(game)
            printmove(game.nextplayer, move)
        end
        game = applymove(game, move)

    end     
end

main()