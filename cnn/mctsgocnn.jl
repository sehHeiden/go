using Flux
using JLD

X = load("./data/board_200_2000.jld")["xs"]
y = load("./data/move_200_2000.jld", "ys")["ys"]

samples = size(X)[1]
size = 9
inputshape = (shape, shape, 1)
trainsamples = convert(Int, 0.9 * samples)

X_train, X_test = X[1: trainsamples], X[trainsamples:length(X)]
y_train, y_test = y[1: trainsamples], y[trainsamples:length(X)]
data = DataLoader((X_train, y_train), batchsize=128)

model = Chain(Conv((3,3), inputshape => 48, relu; pad = SamePad()),
              DropOut(0.5), 
              Conv((3,3), 48 => 48, relu; pad = SamePad()),
              MaxPool((2,2)), 
              DropOut(0.51,
              Flux.flatten(),
              Dense(48 => 512, relu),
              DropOut(0.5),
              Dense(512 => size*size, softmax))

loss(x, y) = Flux.Losses.logitcrossentropy(model(x), y)
ps = Flux.params(model)
opt = Descent(0.0001)

# later
@Flux.Optimise.epochs 100 Flux.train!(loss, ps, data, opt)
