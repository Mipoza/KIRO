from parser import parse_instance
from map import draw_data, draw_solution
from cost import total_cost
from solution import solution_naive, solution_moins_naive, improve_nbr_ss, improve_type_ss
from parser import save_sol


def main():
    file = "small.json"
    instance = parse_instance(file)

    # draw_data(instance)

    #print(total_cost(*solution_naive(instance)[:-1], instance))

    x,y,z,I = solution_naive(instance)
    print(total_cost(x,y,z,I))
    draw_solution(x,y,z,I)
    save_sol(x,y,z,I,1)
    
    x2,y2,z2, I = improve_nbr_ss(x,y,z,I)
    print(total_cost(x2,y2,z2,I))
    draw_solution(x2,y2,z2,I)
    save_sol(x2,y2,z2,I,2)

    #x3, y3, z3, I = improve_type_ss(x2,y2,z2,I)
    #print(total_cost(x3,y3,z3,I))
    #draw_solution(x3,y3,z3,I)
    #save_sol(x3,y3,z3,I,3)


main()
