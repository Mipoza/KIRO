from parser import parse_instance, parse_instance2
from display import display_data, display_solution, display_type_ss
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
    -> small.json = (238 308, 5137, 6 398) #type 16 (max failure, min cost)
    -> medium.json  = ( 2 872 282, ? , 520 931) # type 19
    -> large.json = (  3 541 061, ?, 773 934) # type 19
    -> huge.json = ( 3 477 701, ?, 19 539) # type 22

    """
    file = "huge.json"
    instance = parse_instance(file)

    # display_data(instance)

    # print(total_cost(*solution_naive(instance)[:-1], instance))

    name = "KIRO-" + file[:-5]

    I = parse_instance(file)
    I2 = parse_instance2(file)

    # tic = time.time()
    # x, y, z, I = solution_naive(instance)
    # tac = time.time()
    # print("tic-tac= ", tac - tic, " s")
    # print("cout tot pour solution_naive= ", total_cost(x, y, z, I))
    # display_solution(x, y, z, I)
    # save_sol(x, y, z, name + "-naive")

    tic = time.time()
    x, y, z, I2 = solution_naive2(I2)
    tac = time.time()
    print("tic-tac= ", tac - tic, " s")
    cout = total_cost(x, y, z, I)
    print("cout tot pour solution_naive2= ", cout)
    # display_solution(x, y, z, I)
    save_sol(x, y, z, name + "-naive2-2")

    display_type_ss(I)


main()
