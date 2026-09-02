using DrWatson
@quickactivate "project"

using Agents
using DataFrames
using CairoMakie

include(srcdir("daisyworld.jl"))

black(a) = a.breed == :black
white(a) = a.breed == :white
adata = [(black, count), (white, count)]

model = daisyworld()

agent_df, model_df = run!(model, 1000; adata)

fig = Figure(size = (600, 400))
ax = fig[1, 1] = Axis(fig, xlabel = "tick", ylabel = "daisy count")
blackl = lines!(ax, agent_df[!, :time], agent_df[!, :count_black], color = :black)
whitel = lines!(ax, agent_df[!, :time], agent_df[!, :count_white], color = :orange)
Legend(fig[1, 2], [blackl, whitel], ["black", "white"], labelsize = 12)
save(plotsdir("daisy_count.png"), fig)

println("Daisy count plot saved!")
