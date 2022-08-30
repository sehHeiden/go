using Flux
using JLD2

print(pwd())

# Strange paths
X = load("./data/board_400_5000.jld")["xs"]
y = load("./data/move_400_5000.jld")["ys"]

samples = size(X)[1]
boardsize = 9
X2 = reduce(hcat, [reshape(x, length(x)) for X2 in X for x in X2])
y2 = reduce(hcat, [reshape(yyy, length(yyy)) for yy in y for yyy in yy])

trainsamples = convert(Int, 0.9 * samples)

X_train, X_test = X2[1:trainsamples], X2[trainsamples:length(X)]
y_train, y_test = y2[1:trainsamples], y2[trainsamples:length(y)]
data = Flux.DataLoader((X_train, y_train); batchsize=128)

model = Chain(Dense(boardsize*boardsize => 1000, relu),
              Dense(1000=>500, relu),
              Dense(500 => boardsize*boardsize, σ)
            )

loss(x, y) = Flux.Losses.logitcrossentropy(model(x), y)
ps = Flux.params(model)
opt = Descent(0.0001)

# later
@Flux.Optimise.epochs 100 Flux.train!(loss, ps, data, opt)
