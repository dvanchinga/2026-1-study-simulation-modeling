# # Модель Лотки-Вольтерры (Хищник-Жертва)
# **Цель:** Исследовать модель взаимодействия хищник-жертва с помощью 
# дифференциальных уравнений.

# ## Инициализация проекта и загрузка пакетов
# Для работы с проектом используем DrWatson, который управляет путями и 
# структурой проекта.

ENV["GKSwstype"] = "nul"

using DrWatson
@quickactivate "project"

using DifferentialEquations
using DataFrames
using CSV
using JLD2

# ## Настройка каталогов
# Создаем каталоги для сохранения данных и результатов.

script_name = splitext(basename(PROGRAM_FILE))[1]
mkpath(plotsdir(script_name))
mkpath(datadir(script_name))

# ## Определение модели Лотки-Вольтерры
# Модель описывается системой уравнений:
# 
# $$ \frac{dx}{dt} = \alpha x - \beta xy $$
# $$ \frac{dy}{dt} = \delta xy - \gamma y $$
# 
# где:
# - x — популяция жертв
# - y — популяция хищников
# - α — скорость размножения жертв (в отсутствие хищников)
# - β — скорость поедания жертв хищниками
# - δ — коэффициент конверсии пищи в потомство хищников
# - γ — смертность хищников (в отсутствие жертв)

function lotka_volterra!(du, u, p, t)
    x, y = u
    α, β, δ, γ = p
    @inbounds begin
        du[1] = α*x - β*x*y
        du[2] = δ*x*y - γ*y
    end
    nothing
end

# ## Параметры модели
# Задаем начальные условия и параметры модели.
# 
# Начальная популяция: x₀ = 40, y₀ = 9
# Параметры: α = 0.1, β = 0.02, δ = 0.01, γ = 0.3
# Временной интервал: от 0 до 200

p_lv = [0.1, 0.02, 0.01, 0.3]  # α, β, δ, γ
u0_lv = [40.0, 9.0]              # начальная популяция
tspan_lv = (0.0, 200.0)
dt_lv = 0.01

# ## Стационарные точки
# Стационарные точки системы:
# - x* = γ/δ (равновесная численность жертв)
# - y* = α/β (равновесная численность хищников)

x_star = p_lv[4] / p_lv[3]  # γ/δ
y_star = p_lv[1] / p_lv[2]  # α/β

println("Стационарные точки:")
println("x* = ", round(x_star, digits=3))
println("y* = ", round(y_star, digits=3))

# ## Решение системы ОДУ
# Создаем задачу Коши и решаем ее численно методом Tsit5.

prob_lv = ODEProblem(lotka_volterra!, u0_lv, tspan_lv, p_lv)
sol_lv = solve(prob_lv, dt=dt_lv, Tsit5(), saveat=0.1)

# ## Сохранение результатов
# Сохраняем результаты в форматах CSV и JLD2 для дальнейшего анализа.

df_lv = DataFrame(t=sol_lv.t, prey=[u[1] for u in sol_lv.u], predator=[u[2] for u in sol_lv.u])

CSV.write(datadir(script_name, "lv_results.csv"), df_lv)
@save datadir(script_name, "lv_results.jld2") df_lv

# ## Вывод результатов
# Выводим основные результаты моделирования.

println("\nМодель Лотки-Вольтерры выполнена успешно!")
println("Количество точек: ", length(df_lv.t))
println("Результаты сохранены в data/$(script_name)/")

# ## Анализ результатов
# Выводим основные статистики.

println("\nАнализ результатов:")
println("Популяция жертв:")
println("  Минимум: ", round(minimum(df_lv.prey), digits=2))
println("  Максимум: ", round(maximum(df_lv.prey), digits=2))
println("  Среднее: ", round(mean(df_lv.prey), digits=2))

println("Популяция хищников:")
println("  Минимум: ", round(minimum(df_lv.predator), digits=2))
println("  Максимум: ", round(maximum(df_lv.predator), digits=2))
println("  Среднее: ", round(mean(df_lv.predator), digits=2))

