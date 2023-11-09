from parser import parse_instance
from map import draw_data


def main():
    file = "instances/small.json"
    instance = parse_instance(file)

    draw_data(instance)


main()
