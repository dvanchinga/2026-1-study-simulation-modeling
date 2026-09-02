ENV["GKSwstype"] = "nul"

using DrWatson
@quickactivate "project"

using DifferentialEquations
using DataFrames
using CSV
using JLD2

script_name = splitext(basename(PROGRAM_FILE))[1]
mkpath(plotsdir(script_name))
mkpath(datadir(script_name))

function lotka_volterra!(du, u, p, t)
    x, y = u
    α, β, δ, γ = p
    @inbounds begin
        du[1] = α*x - β*x*y
        du[2] = δ*x*y - γ*y
    end
    nothing
end

p_lv = [0.1, 0.02, 0.01, 0.3]  # α, β, δ, γ
u0_lv = [40.0, 9.0]              # начальная популяция
tspan_lv = (0.0, 200.0)
dt_lv = 0.01

x_star = p_lv[4] / p_lv[3]  # γ/δ
y_star = p_lv[1] / p_lv[2]  # α/β

println("Стационарные точки:")
println("x* = ", round(x_star, digits=3))
println("y* = ", round(y_star, digits=3))

prob_lv = ODEProblem(lotka_volterra!, u0_lv, tspan_lv, p_lv)
sol_lv = solve(prob_lv, dt=dt_lv, Tsit5(), saveat=0.1)

df_lv = DataFrame(t=sol_lv.t, prey=[u[1] for u in sol_lv.u], predator=[u[2] for u in sol_lv.u])

CSV.write(datadir(script_name, "lv_results.csv"), df_lv)
@save datadir(script_name, "lv_results.jld2") df_lv

println("\nМодель Лотки-Вольтерры выполнена успешно!")
println("Количество точек: ", length(df_lv.t))
println("Результаты сохранены в data/$(script_name)/")

println("\nАнализ результатов:")
println("Популяция жертв:")
println("  Минимум: ", round(minimum(df_lv.prey), digits=2))
println("  Максимум: ", round(maximum(df_lv.prey), digits=2))
println("  Среднее: ", round(mean(df_lv.prey), digits=2))

println("Популяция хищников:")
println("  Минимум: ", round(minimum(df_lv.predator), digits=2))
println("  Максимум: ", round(maximum(df_lv.predator), digits=2))
println("  Среднее: ", round(mean(df_lv.predator), digits=2))
