using DrWatson
@quickactivate "project"

using Agents
using DataFrames
using CSV
using PyPlot

include(srcdir("sir_model.jl"))

# Beta values to scan
beta_range = 0.1:0.1:1.0
seeds = [42, 43, 44]

results = []

for β in beta_range
    for seed in seeds
        println("Running β=$β, seed=$seed")
        
        model = initialize_sir(;
            Ns = [1000, 1000, 1000],
            β_und = fill(β, 3),
            β_det = fill(β/10, 3),
            infection_period = 14,
            detection_time = 7,
            death_rate = 0.02,
            reinfection_probability = 0.1,
            Is = [0, 0, 1],
            seed = seed,
            n_steps = 100
        )

        times = Int[]
        I_vals = Int[]

        for step in 1:100
            Agents.step!(model, 1)
            push!(times, step)
            push!(I_vals, infected_count(model))
        end

        peak = maximum(I_vals)
        final = I_vals[end]
        
        push!(results, (β=β, seed=seed, peak=peak, final=final))
    end
end

df = DataFrame(results)
CSV.write(datadir("beta_scan_results.csv"), df)

println("Beta scan complete!")
println("Results saved to data/beta_scan_results.csv")

