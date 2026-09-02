using DrWatson
@quickactivate "project"

using Agents
using DataFrames
using CairoMakie
using StatsBase

include(srcdir("daisyworld.jl"))

black(a) = a.breed == :black
white(a) = a.breed == :white
adata = [(black, count), (white, count)]

model = daisyworld(solar_luminosity = 1.0, scenario = :ramp)

temperature(model) = StatsBase.mean(model.temperature)
mdata = [temperature, :solar_luminosity]

agent_df, model_df = run!(model, 1000; adata = adata, mdata = mdata)

fig = Figure(size = (600, 600))
ax1 = fig[1, 1] = Axis(fig, ylabel = "daisy count")
black1 = lines!(ax1, agent_df[!, :time], agent_df[!, :count_black], color = :red)
white1 = lines!(ax1, agent_df[!, :time], agent_df[!, :count_white], color = :blue)
fig[1, 2] = Legend(fig, [black1, white1], ["black", "white"])

ax2 = fig[2, 1] = Axis(fig, ylabel = "temperature")
lines!(ax2, model_df[!, :time], model_df[!, :temperature], color = :red)

ax3 = fig[3, 1] = Axis(fig, xlabel = "tick", ylabel = "luminosity")
lines!(ax3, model_df[!, :time], model_df[!, :solar_luminosity], color = :red)

for ax in (ax1, ax2)
    ax.xticklabelsvisible = false
end

save(plotsdir("daisy_luminosity.png"), fig)

println("Luminosity plot saved!")
