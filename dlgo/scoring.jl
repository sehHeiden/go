include("gotypes.jl")
include("goboardtypes.jl")

# could not finde the file in book, had to look it up on: 
# https://github.com/maxpumperla/deep_learning_and_the_game_of_go/blob/35f983cabb7294d84f2554dc4c23063f23f985b8/code/dlgo/scoring.py

mutable struct Territory{}
    numblackterritory::UInt
    numwhiteterritory::UInt
    numblackstones::UInt
    numwhitestones::UInt
    numdame::UInt
    damepoints::Vector{Point}

    function Territory(territorymap::Dict)
        numblackterritory = 0
        numwhiteterritory = 0
        numblackstones = 0
        numwhitestones = 0
        numdame = 0
        damepoints = Vector{Point}([])

        for (point, status) ∈ territorymap
            if status == black
                numblackstones = numblackstones + 1
            elseif status == white
                numwhitestones = numwhitestones + 1
            elseif status == "territory_b"
                numblackterritory = numblackterritory + 1
            elseif status == "territory_w"
                numwhiteterritory = numwhiteterritory + 1
            elseif status == "dame"
                numdame = numdame + 1
                push!(damepoints, point)
            end  # if
        end  # for
        new(numblackterritory, numwhiteterritory, numblackstones, numwhitestones, numdame, damepoints)
      end  # function
end  # struct


struct GameResult
  b::UInt
  w::UInt
  komi::Float64
end


function winner(gr::GameResult)
  if gr.b > gr.w + gr.komi
    return black
  end
  return white
end



function winningmargin(gr::GameResult)
  w = gr.w + self.komi
  return abs(gr.b - w)
end


function evaluateterritory(b::Board)
  """ evaluateterritory:
  Map a board into territory and dame.
  Any points that are completely surrounded by a single color are
  counted as territory; it makes no attempt to identify even
  trivially dead groups.
  """
  status = Dict{Point, Union{String, Player}}([])
  for r in 1:b.numrows
    for c in 1:b.numcols
      p = Point(r, c)
      if p ∈ keys(status)
        continue
      end

      stone = get(b, p)
      if !isnothing(stone)
        status[p] = stone
      else
        group, neighbors = collectregion(p, b)
      
        if length(neighbors) == 1
          neighborstone = pop!(neighbors)
          stone_str = neighborstone == black ? "b" : "w"
          fill_with = "territory_" * stone_str
        else
          fill_with = "dame"
          for pos ∈ group
            status[pos] = fill_with
          end
        end
      end
    end
  end
  return Territory(status)
end


function collectregion(startpos::Point, board::Board, visited::Dict{Point, Bool} = Dict{Point, Bool}([]))
  """ collectregion:
  Find the contiguous section of a board containing a point. Also
  identify all the boundary points.
  """

  if startpos ∈ keys(visited)
    return [], Set()
  end

  allpoints = [startpos]
  allborders = Set([])
  visited[startpos] = true
  here = get(board, startpos)
  deltas = [(-1, 0), (1, 0), (0, -1), (0, 1)]
  for (delta_r, delta_c) ∈ deltas
    nextp = Point(startpos.row + delta_r, startpos.col + delta_c)
    if !isongrid(board, nextp)
      continue
    end
    neighbor = get(board, nextp)
    if neighbor == here
      points, borders = collectregion(nextp, board, visited)
      append!(allpoints, points)
      union!(allborders, borders)
    else
      push!(allborders, neighbor)
    end
  end
  return allpoints, allborders
end


function computegameresult(gs::GameState)
  territory = evaluateterritory(gs.board)
  return GameResult(
    territory.numblackterritory + territory.numblackstones,
    territory.numwhiteterritory + territory.numwhitestones,
    7.5)
end
