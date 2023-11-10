from parser import parse_instance, parse_instance2
from map import draw_data, draw_solution
from cost import total_cost
from solution import (
    solution_naive,
    solution_moins_naive,
    improve_nbr_ss,
    improve_type_ss,
)
from solution2 import solution_naive2
from parser import save_sol


def main():
    """
    Meilleure solution pour small.json -> cout = 5137.945022007392 (KIRO-small-nbr_ss.json)
    """
    file = "small.json"
    instance = parse_instance(file)

    # draw_data(instance)

    # print(total_cost(*solution_naive(instance)[:-1], instance))

    name = "KIRO-" + file[:-5]

    I2 = parse_instance2(file)
    I = parse_instance(file)

    x, y, z, I2 = solution_naive2(I2)
    print(total_cost(x, y, z, I))
    draw_solution(x, y, z, I)
    save_sol(x, y, z, I, name + "-naive2")

    # x, y, z, I = solution_naive(instance)
    # print(total_cost(x, y, z, I))
    # draw_solution(x, y, z, I)
    # save_sol(x, y, z, I, name + "-naive")
    # print(x, y, z)

    # x2, y2, z2, I = improve_nbr_ss(x, y, z, I)
    # print(total_cost(x2, y2, z2, I))
    # draw_solution(x2, y2, z2, I)
    # save_sol(x2, y2, z2, I, name + "-improve_nbr_ss")
    # print(x2, y2, z2)

    # x3, y3, z3, I = improve_type_ss(x2,y2,z2,I)
    # print(total_cost(x3,y3,z3,I))
    # draw_solution(x3,y3,z3,I)
    # save_sol(x3,y3,z3,I,3)


main()
