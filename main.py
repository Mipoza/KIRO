from parser import parse_instance
from map import draw_data, draw_solution
from cost import total_cost
from solution import solution_naive, solution_moins_naive


def main():
    file = "small.json"
    instance = parse_instance(file)

    # draw_data(instance)

    print(total_cost(*solution_naive(instance)[:-1], instance))

    x, y, z, I = solution_moins_naive(instance)
    print(total_cost(x, y, z, I))

    draw_solution(x, y, z, I)


main()
