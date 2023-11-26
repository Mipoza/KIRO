from parser import parse_instance, parse_instance2
from display import (
    display_data,
    display_solution,
    display_type_ss,
    display_type_cable_land_ss,
)
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
    -> small.json = (238 308, 5137, 5 327)
    -> medium.json  = ( 2 872 282, ? , 517 153)
    -> large.json = (  3 541 061, ?, 757 468)
    -> huge.json = ( 3 477 701, ?, 17825)

    scores = [10129655, 1340062, 1334244, 1321105, 1295076 ]

    """
    file = "small.json"
    I = parse_instance(file)
    I2 = parse_instance2(file)

    # display_data(I)
    # display_type_ss(I)
    # display_type_cable_land_ss(I)

    name = "KIRO-" + file[:-5]

    tic = time.time()
    x, y, z, I = solution_naive(I)
    tac = time.time()
    print("tic-tac= ", tac - tic, " s")
    print("cout tot pour solution_naive= ", total_cost(x, y, z, I))
    display_solution(x, y, z, I)
    save_sol(x, y, z, name + "-naive")

    # tic = time.time()
    # x, y, z, I2 = solution_naive2(I2)
    # tac = time.time()
    # print("tic-tac= ", tac - tic, " s")
    # cout = total_cost(x, y, z, I)
    # print("cout tot pour solution_naive2= ", cout)
    # display_solution(x, y, z, I)
    # save_sol(x, y, z, name + "-naive2-2")


main()
