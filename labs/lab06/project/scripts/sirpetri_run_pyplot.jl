using DrWatson
@quickactivate "project"
include(srcdir("SIRPetri_pyplot.jl"))
using .SIRPetri
using DataFrames, CSV

β = 0.3
γ = 0.1
tmax = 100.0

net, u0, states = build_sir_network(β, γ)

# Deterministic
df_det = simulate_deterministic(net, u0, (0.0, tmax), saveat=0.5, rates=[β, γ])
CSV.write(datadir("sir_det.csv"), df_det)
println("Deterministic simulation saved")

# Plot
plot_sir(df_det, "SIR Model (Deterministic)")

println("Lab 6 complete with plot!")
