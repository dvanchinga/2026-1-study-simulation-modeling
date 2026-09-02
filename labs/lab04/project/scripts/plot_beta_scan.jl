using DrWatson
@quickactivate "project"

using DataFrames
using CSV
using PyPlot
using Statistics

df = CSV.read(datadir("beta_scan_results.csv"), DataFrame)

# Average over seeds
grouped = combine(groupby(df, :β), :peak => mean, :final => mean)

figure(figsize=(10,6))
plot(grouped.β, grouped.peak_mean, "o-", label="Peak infected", linewidth=2, markersize=8)
plot(grouped.β, grouped.final_mean, "s-", label="Final infected", linewidth=2, markersize=8)
xlabel("β (infection rate)")
ylabel("Infected count")
title("Beta Scan Results")
legend()
grid(true)
savefig(plotsdir("beta_scan_plot.png"))
println("Plot saved to plots/beta_scan_plot.png")
