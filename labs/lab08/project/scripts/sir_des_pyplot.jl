using DrWatson
@quickactivate "project"

include(srcdir("sir_model.jl"))

using Random, CSV, JLD2
using PyPlot

# Parameters
tmax = 40.0
u0 = [990, 10, 0]
p = [0.05, 10.0, 0.25]  # β, c, γ

Random.seed!(1234)

# Run simulation
des_model = MakeSIRModel(u0, p)
activate(des_model)
sir_run(des_model, tmax)
data_des = out(des_model)

println("SIR DES model complete!")
println("Final S: ", data_des.S[end])
println("Final I: ", data_des.I[end])
println("Final R: ", data_des.R[end])

# Save data
CSV.write(datadir("sir_des_results.csv"), data_des)
@save datadir("sir_des_results.jld2") data_des

# Plot with PyPlot
figure(figsize=(10,6))
plot(data_des.t, data_des.S, label="S (Susceptible)", linewidth=2)
plot(data_des.t, data_des.I, label="I (Infected)", linewidth=2)
plot(data_des.t, data_des.R, label="R (Recovered)", linewidth=2)
xlabel("Time")
ylabel("Population")
title("SIR Model (Discrete-Event Simulation)")
legend()
grid(true)
savefig(plotsdir("sir_des.png"))
println("Plot saved to plots/sir_des.png")
