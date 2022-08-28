using Flux
using JLD2

X = load("../data/board_400_5000.jld")["xs"]
y = load("../data/move_400_5000.jld")["ys"]  

samples = size(X)[1]
boardsize = 9
inputshape = (boardsize, boardsize, 1)
trainsamples = convert(Int, 0.9 * samples)

X_train, X_test = X[1: trainsamples], X[trainsamples:length(X)]
y_train, y_test = y[1: trainsamples], y[trainsamples:length(y)]
data = Flux.DataLoader((X_train, y_train), batchsize=128)

model = Chain(
    Conv((3,3), 3 => 48, relu; pad = SamePad()),
    Dropout(0.5), 
    Conv((3,3), 48 => 48, relu; pad = SamePad()),
    MaxPool((2,2)), 
    Dropout(0.5),
    Flux.flatten,
    Dense(48 => 512, relu),
    Dropout(0.5),
    Dense(512 => boardsize*boardsize, softmax)
    )

loss(x, y) = Flux.Losses.logitcrossentropy(model(x), y)
ps = Flux.params(model)
opt = Descent(0.0001)

# later
@Flux.Optimise.epochs 100 Flux.train!(loss, ps, data, opt)
