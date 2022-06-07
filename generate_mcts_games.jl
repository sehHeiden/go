include("dlgo/DLGO.jl")
using .DLGO
using ArgParse
using JLD2
using FileIO

function generate_game(boardsize::UInt8, rounds::UInt, maxmoves::UInt, temperature::Float64)
  boards = Vector{Array{Int8, 3}}([])
  moves = Vector{Vector{UInt8}}([])

  encoder = OnePlaneEncoder(boardsize)
  game = newgame(boardsize)
  bot = MCTSAgent(rounds, temperature)
  nummoves = 0
  while !isover(game)
    printboard(game.board)
    move = selectmove(bot, game)

    if isplay(move)
      push!(boards, encode(encoder, game))
      moveonehot = zeros(UInt8, numpoints(encoder))
      moveonehot[encodepoint(encoder, move.point)] = 1
      push!(moves, moveonehot)
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
    default = 3
    "--boardout"
    default = "./data/board.jld"
    "--moveout"
    default = "./data/move.jld"
  end

  args = parse_args(s)

  xs = Vector{Array{Int8, 3}}[]
  ys = Vector{Vector{UInt8}}[]

  for i in 1:args["numgames"]
    println("Generating game $i $(args["numgames"])")
    x, y = generate_game(args["boardsize"], UInt(args["rounds"]), UInt(args["maxmoves"]), args["temperature"])
    push!(xs, x)
    push!(ys, y)
  end
  print(pwd())
  jldsave(args["boardout"], true; xs)
  jldsave(args["moveout"], true; ys)
end

main()
