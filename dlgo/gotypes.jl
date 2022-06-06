@enum Player black white

function getother(pl::Player)
  if pl == white
    r = black
  else
    r = white
  end
  return r
end

struct Point{}
  row::UInt8
  col::UInt8
end

function neighbors(pt::Point)
  return [Point(UInt8(pt.row - 1), UInt8(pt.col)),
    Point(UInt8(pt.row + 1), UInt8(pt.col)),
    Point(UInt8(pt.row), UInt8(pt.col - 1)),
    Point(UInt8(pt.row), UInt8(pt.col + 1)),]
end
