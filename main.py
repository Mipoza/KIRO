from parser import parse_instance
from map import draw_data, draw_solution
from cost import const_cost
from solution import solution_naive, solution_moins_naive


def main():
    file = "small.json"
    instance = parse_instance(file)

    # draw_data(instance)

    x, y, z, I = solution_naive(instance)

    print(const_cost(*solution_moins_naive(instance)[:-1], I))
    print(const_cost(*solution_naive(instance)[:-1], I))

    draw_solution(x, y, z, I)


main()
