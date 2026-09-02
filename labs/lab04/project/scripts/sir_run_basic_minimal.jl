using DrWatson
@quickactivate "project"

using Agents
using DataFrames
using CSV
using JLD2
using PyPlot

include(srcdir("sir_model.jl"))

# Parameters
Ns = [1000, 1000, 1000]
β_und = [0.5, 0.5, 0.5]
β_det = [0.05, 0.05, 0.05]
infection_period = 14
detection_time = 7
death_rate = 0.02
reinfection_probability = 0.1
Is = [0, 0, 1]
seed = 42
n_steps = 100

model = initialize_sir(; Ns, β_und, β_det, infection_period, detection_time,
                        death_rate, reinfection_probability, Is, seed, n_steps)

# Run simulation
times = Int[]
S_vals = Int[]
I_vals = Int[]
R_vals = Int[]

for step in 1:n_steps
    Agents.step!(model, 1)
    push!(times, step)
    push!(S_vals, susceptible_count(model))
    push!(I_vals, infected_count(model))
    push!(R_vals, recovered_count(model))
end

df = DataFrame(time=times, susceptible=S_vals, infected=I_vals, recovered=R_vals)
CSV.write(datadir("sir_basic_results.csv"), df)
@save datadir("sir_basic_results.jld2") df

println("SIR model simulation complete!")
println("Final infected: ", df.infected[end])
println("Peak infected: ", maximum(df.infected))

# Plot with PyPlot
figure(figsize=(10,6))
plot(times, S_vals, label="Susceptible", linewidth=2)
plot(times, I_vals, label="Infected", linewidth=2)
plot(times, R_vals, label="Recovered", linewidth=2)
xlabel("Time (days)")
ylabel("Population")
title("SIR Model Dynamics")
legend()
PyPlot.grid(true)
savefig(plotsdir("sir_dynamics.png"))
println("Plot saved to plots/sir_dynamics.png")
