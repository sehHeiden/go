using Flux
using JLD2

print(pwd())

# Strange paths
X = load("./data/board_400_5000.jld")["xs"]
y = load("./data/move_400_5000.jld")["ys"]

samples = size(X)[1]
boardsize = 9
X = Flux.flatten(X)
Y = Flux.flatten(y)

trainsamples = convert(Int, 0.9 * samples)

X_train, X_test = X[1:trainsamples], X[trainsamples:length(X)]
Y_train, Y_test = y[1:trainsamples], y[trainsamples:length(y)]

model = Chain(Dense(boardsize => 1000, relu),
              Dense(1000=>500, relu),
              Dense(500 => boardsize, σ)
            )

loss(x, y) = Flux.Losses.logitcrossentropy(model(x), y)
ps = Flux.params(model)
opt = Descent(0.0001)

# later
@Flux.Optimise.epochs 100 Flux.train!(loss, ps, data, opt)




