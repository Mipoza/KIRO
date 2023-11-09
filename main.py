from parser import parse_instance
from map import draw_data
from cost import const_cost
from solution import solution_naive


def main():
    file = "tiny.json"
    instance = parse_instance(file)

    # draw_data(instance)

    x, y, z, I = solution_naive(instance)

    print(const_cost(x, y, z, I))


main()
