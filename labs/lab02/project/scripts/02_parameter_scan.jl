# # Параметрическое сканирование модели SIR
# **Цель:** Исследовать влияние коэффициента заражения β на динамику эпидемии.

using DrWatson
@quickactivate "project"

using DifferentialEquations
using DataFrames
using CSV
using JLD2

script_name = splitext(basename(PROGRAM_FILE))[1]
mkpath(plotsdir(script_name))
mkpath(datadir(script_name))

function sir_ode!(du, u, p, t)
    (S, I, R) = u
    (β, c, γ) = p
    N = S + I + R
    @inbounds begin
        du[1] = -β * c * I / N * S
        du[2] = β * c * I / N * S - γ * I
        du[3] = γ * I
    end
    nothing
end

# Параметры
δt = 0.1
tmax = 40.0
tspan = (0.0, tmax)
u0 = [990.0, 10.0, 0.0]
c = 10.0
γ = 0.25

# Сканирование β
β_values = [0.02, 0.04, 0.06, 0.08, 0.10]

results = []

for β in β_values
    p = [β, c, γ]
    prob = ODEProblem(sir_ode!, u0, tspan, p)
    sol = solve(prob, dt=δt)
    
    # Находим пик I
    I_values = [u[2] for u in sol.u]
    peak_I = maximum(I_values)
    peak_time = sol.t[argmax(I_values)]
    final_R = sol.u[end][3]
    R0 = (β * c) / γ
    
    push!(results, (β=β, R0=round(R0, digits=3), peak_I=round(peak_I, digits=2), peak_time=round(peak_time, digits=2), final_R=round(final_R, digits=2)))
end

# Сохранение результатов
df_results = DataFrame(results)
CSV.write(datadir(script_name, "sir_parameter_scan.csv"), df_results)
@save datadir(script_name, "sir_parameter_scan.jld2") df_results

println("Параметрическое сканирование завершено!")
println("Результаты сохранены в data/$(script_name)/")
println("\nСводная таблица:")
println(df_results)
