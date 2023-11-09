from parser import parse_instance
from map import draw_data, draw_solution
from cost import total_cost
from solution import solution_naive, solution_moins_naive
from parser import save_sol


def main():
    file = "small.json"
    instance = parse_instance(file)

    # draw_data(instance)

    x, y, z, I = solution_naive(instance)
    save_sol(x,y,z,I)
    #print(total_cost(*solution_naive(instance)[:-1], I))
    #print(total_cost(*solution_moins_naive(instance)[:-1], I))

    draw_solution(x, y, z, I)


main()
