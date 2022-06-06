include("dlgo/DLGO.jl")
using .DLGO
using ArgParse
using JLD
using FileIO

function generate_game(boardsize::UInt8, rounds::UInt, maxmoves::UInt, temperature::Float64)
  boards = Vector([])
  moves = Vector([])

  encoder = OnePlaneEncoder(boardsize)
  game = newgame(boardsize)
  bot = MCTSAgent(rounds, temperature)
  nummoves = 0
  while !isover(game)
    printboard(game.board)
    move = selectmove(bot, game)

    if isplay(move)
      append!(boards, encode(encoder, game))
      moveonehot = zeros(numpoints(encoder))
      moveonehot[encodepoint(encoder, move.point)] = 1
      append!(moves, moveonehot)
    end
    printmove(game.nextplayer, move)
    game = applymove(game, move)

    nummoves = nummoves + 1
    if nummoves > maxmoves
      break
    end
  end
  return boards, moves
end

function main()
  s = ArgParseSettings()
  @add_arg_table s begin
    "--boardsize", "-b"
    arg_type = UInt8
    default = 0x09
    "--rounds", "-r"
    arg_type = Int
    default = 10 
    "--temperature", "-t"
    arg_type = Float64
    default = 0.8
    "--maxmoves", "-m"
    arg_type = Int
    default = 1000
    help = "Max moves per game."
    "--numgames", "-n"
    arg_type = Int
    default = 10
    "--boardout"
    default = "./data/board.jld"
    "--moveout"
    default = "./data/move.jld"
  end

  args = parse_args(s)

  xs = []
  ys = []

  for i in 1:args["numgames"]
    println("Generating game $i $(args["numgames"])")
    x, y = generate_game(args["boardsize"], UInt(args["rounds"]), UInt(args["maxmoves"]), args["temperature"])
    append!(xs, x)
    append!(ys, y)
  end
  save(args["boardout"], "xs", xs)
  save(args["moveout"], "ys", ys)
end

main()
