using Flux
using JLD

print(pwd())

X = load("./data/board.jld")["xs"]
y = load("./data/move.jld")["ys"]

samples = size(X)[1]
boardsize = 9
X = reshape(X, (boardsize, length(X/boardsize)))
Y = reshape(y, (boardsize, length(X/boardsize)))

trainsamples = convert(Int, 0.9 * samples)

X_train, X_test = X[1:trainsamples], X[trainsamples:length(x)]
Y_train, Y_test = X[1:trainsamples], X[trainsamples:length(x)]

model = Chain(Dense(boardsize => 1000, relu),
              Dense(1000=>500, relu),
              Dense(500 => boardsize, σ)
            )

loss(x, y) = Flux.Losses.logitcrossentropy(model(x), y)
ps = Flux.params(model)
opt = Descent(0.0001)

# later
@Flux.Optimise.epochs 100 Flux.train!(loss, ps, data, opt)




