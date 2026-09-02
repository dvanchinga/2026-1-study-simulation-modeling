using DrWatson
@quickactivate "project"

using Agents
using DataFrames
using CairoMakie

include(srcdir("daisyworld.jl"))

model = daisyworld()

daisycolor(a::Daisy) = a.breed

plotkwargs = (
    agent_color = daisycolor,
    agent_size = 20,
    agent_marker = '♠',
    heatarray = :temperature,
    heatkwargs = (colorrange = (-20, 60),)
)

fig1, ax1, _ = abmplot(model; plotkwargs...)
save(plotsdir("daisy_step001.png"), fig1)

step!(model, 5)
fig2, ax2, _ = abmplot(model; heatarray = model.temperature, plotkwargs...)
save(plotsdir("daisy_step005.png"), fig2)

step!(model, 40)
fig3, ax3, _ = abmplot(model; heatarray = model.temperature, plotkwargs...)
save(plotsdir("daisy_step040.png"), fig3)

println("Daisyworld visualizations saved successfully!")
