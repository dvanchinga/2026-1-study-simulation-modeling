using DrWatson
@quickactivate "project"

using Agents
using DataFrames
using CairoMakie
using StatsBase

include(srcdir("daisyworld.jl"))

## Параметры эксперимента
param_dict = Dict(
    :griddims => (30, 30),
    :max_age => [25, 40],
    :init_white => [0.2, 0.8],
    :init_black => 0.2,
    :albedo_white => 0.75,
    :albedo_black => 0.25,
    :surface_albedo => 0.4,
    :solar_change => 0.005,
    :solar_luminosity => 1.0,
    :scenario => :default,
    :seed => 165,
)

params_list = dict_list(param_dict)

for params in params_list
    model = daisyworld(; params...)

    daisycolor(a::Daisy) = a.breed

    plotkwargs = (
        agent_color = daisycolor,
        agent_size = 20,
        agent_marker = '♠',
        heatarray = :temperature,
        heatkwargs = (colorrange = (-20, 60),)
    )

    fig1, ax1, _ = abmplot(model; plotkwargs...)
    save(plotsdir("daisy_param_step001.png"), fig1)

    step!(model, 5)
    fig2, ax2, _ = abmplot(model; heatarray = model.temperature, plotkwargs...)
    save(plotsdir("daisy_param_step005.png"), fig2)

    step!(model, 40)
    fig3, ax3, _ = abmplot(model; heatarray = model.temperature, plotkwargs...)
    save(plotsdir("daisy_param_step040.png"), fig3)

    println("Saved plots for params: max_age=$(params[:max_age]), init_white=$(params[:init_white])")
end

println("Parameter experiments complete!")
