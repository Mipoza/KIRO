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

import time


def main():
    """
    Scores pour naive, nbr_ss, naive2:
    -> toy.json = (303, 303, 306)
    -> small.json = (238 308, 5137, 7 270)
    -> medium.json  = ( 2 872 282, ? , 524 330)
    -> large.json = (  3 541 061, ?, 784 861)
    -> huge.json = ( 3 477 701, ?, 23 298)

    """
    file = "small.json"
    instance = parse_instance(file)

    # draw_data(instance)

    # print(total_cost(*solution_naive(instance)[:-1], instance))

    name = "KIRO-" + file[:-5]

    I = parse_instance(file)
    I2 = parse_instance2(file)

    tic = time.time()
    x, y, z, I = solution_naive(instance)
    tac = time.time()
    print("tic-tac= ", tac - tic, " s")
    print("cout tot pour solution_naive= ", total_cost(x, y, z, I))
    draw_solution(x, y, z, I)
    save_sol(x, y, z, name + "-naive")

    tic = time.time()
    x, y, z, I2 = solution_naive2(I2)
    tac = time.time()
    print("tic-tac= ", tac - tic, " s")
    print("cout tot pour solution_naive2= ", total_cost(x, y, z, I2))
    draw_solution(x, y, z, I)
    save_sol(x, y, z, name + "-naive2")

    # tic = time.time()
    # x2, y2, z2, I = improve_nbr_ss(x, y, z, I)
    # tac = time.time()
    # print("tic-tac= ", tac - tic, " s")
    # print("cout tot pour improve_nbr_ss= ", total_cost(x2, y2, z2, I))
    # draw_solution(x2, y2, z2, I)
    # save_sol(x2, y2, z2, name + "-nbr_ss")

    # x3, y3, z3, I = improve_type_ss(x2,y2,z2,I)
    # print(total_cost(x3,y3,z3,I))
    # draw_solution(x3,y3,z3,I)
    # save_sol(x3,y3,z3,I,3)


main()
