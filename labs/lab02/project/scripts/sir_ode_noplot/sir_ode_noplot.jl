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

δt = 0.1
tmax = 40.0
tspan = (0.0, tmax)
u0 = [990.0, 10.0, 0.0]
p = [0.05, 10.0, 0.25]

R0 = (p[2] * p[1]) / p[3]

prob_ode = ODEProblem(sir_ode!, u0, tspan, p)
sol_ode = solve(prob_ode, dt = δt)

df = DataFrame(t=sol_ode.t, S=[u[1] for u in sol_ode.u], I=[u[2] for u in sol_ode.u], R=[u[3] for u in sol_ode.u])
df[!, :N] = df.S + df.I + df.R

CSV.write(datadir(script_name, "sir_results.csv"), df)
@save datadir(script_name, "sir_results.jld2") df

println("Модель SIR выполнена успешно!")
println("R0 = ", round(R0, digits=3))
println("Результаты сохранены в data/$(script_name)/")
