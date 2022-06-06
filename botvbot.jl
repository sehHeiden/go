include("dlgo/DLGO.jl")
using .DLGO

function main()
    boardsize = 9
    game = newgame(boardsize)
    bots = Dict(
        black=> selectmove,
        white=> selectmove,
    )

    while !isover(game)
        sleep(0.3)
        print(Char(27) * "[2J")
        printboard(game.board)
        botmove=bots[game.nextplayer](game)
        printmove(game.nextplayer, botmove)
        game = applymove(game, botmove)
    end
end

main()
