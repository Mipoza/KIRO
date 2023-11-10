import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import geopandas as gpd  # For maps
import json


data = [
    [350.0, 35000.0, 5.0, [0, 0], 0.1, 18.0, 0.5],
    {
        1: [200.0, 6.84931506849315e-05, 200],
        2: [160.0, 0.000273972602739726, 200],
        3: [140.0, 0.0008219178082191781, 200],
    },
    {1: [80, 0]},
    {1: [40.0, 0.0], 2: [35.0, 0.0]},
    {
        1: [0.0, 5.479452054794521e-05, 200, 0.015],
        2: [0.0, 5.479452054794521e-05, 300, 0.045],
        3: [0.0, 0.000273972602739726, 200, 0.01],
        4: [0.0, 0.000273972602739726, 300, 0.03],
        5: [0.0, 0.0008219178082191781, 200, 0.0085],
        6: [0.0, 0.0008219178082191781, 300, 0.0255],
    },
    {
        1: [0.0, 100, 0.01],
        2: [0.0, 200, 0.02],
        3: [0.0, 100, 0.009000000000000001],
        4: [0.0, 200, 0.018000000000000002],
        5: [0.0, 100, 0.0085],
        6: [0.0, 200, 0.017],
    },
]


def display_data(data):
    # wind turbines = red
    # substation = blue
    # cable = black
    # land station = green

    V_t = data[2]
    V_s = data[3]

    # Create a figure and axis
    fig, ax = plt.subplots()

    r = 0.1

    # Draw a red filled circle for each wind turbine
    for v in V_t.values():
        circle = plt.Circle(v, r, fill=True, color="red")
        ax.add_patch(circle)

    # Draw a blue circle for each substation
    for v in V_s.values():
        circle = plt.Circle(v, r, fill=True, color="blue")
        ax.add_patch(circle)

    # Draw a green circle for the land station (in 0,0)
    circle = plt.Circle([0, 0], r, fill=True, color="green")
    ax.add_patch(circle)

    # Adapt the x axis
    plt.xlim(-5, 85)
    plt.ylim(-10, 10)

    # Display the plot
    plt.show()


# draw_data(data)


def display_solution(x, y, z, I):
    V_t = I[2]
    V_s = I[3]
    S = I[1]

    # Create a figure and axis
    fig, ax = plt.subplots()

    r = 0.1

    # Draw a red filled circle for each wind turbine
    for t in V_t.values():
        circle = plt.Circle(t, r, fill=True, color="red")
        ax.add_patch(circle)

    # Draw a blue circle for each substation
    for s in V_s:
        # s'il existe une sous-station ie il existe j tel que x[(s,j)]==1
        for j in S:
            if x[(s, j)] == 1:
                # Draw a line from the substation to the land
                plt.plot([V_s[s][0], 0], [V_s[s][1], 0], color="green")
                # Draw a line from the substation s to the turbines t si z[(s,t)]==1
                for t in V_t:
                    if z[(s, t)] == 1:
                        plt.plot(
                            [V_s[s][0], V_t[t][0]],
                            [V_s[s][1], V_t[t][1]],
                            color="red",
                        )
            circle = plt.Circle(V_s[s], r, fill=True, color="blue")
            ax.add_patch(circle)
    for s in V_s:
        circle = plt.Circle(V_s[s], r, fill=True, color="blue")
        ax.add_patch(circle)

    # Draw a green circle for the land station (in 0,0)
    circle = plt.Circle([0, 0], r, fill=True, color="green")
    ax.add_patch(circle)

    # Adapt the x axis
    plt.xlim(-5, 85)
    plt.ylim(-10, 10)

    # Display the plot
    plt.show()


def display_type_ss(I):
    S = I[1]
    fig, ax = plt.subplots()

    costs = [s[0] for s in S.values()]
    failure = [s[1] for s in S.values()]
    rating = [s[2] for s in S.values()]
    id = [s for s in S.keys()]

    # Sur chaque point, ajouter une étiquette avec son identifiant
    for i, txt in enumerate(id):
        ax.annotate(txt, (costs[i], failure[i]))
    plt.scatter(costs, failure, c=rating, cmap="viridis")
    plt.xlabel("Cost")
    plt.ylabel("Failure probability")

    # add legend for rating
    plt.colorbar()

    plt.show()


def display_type_cable_land_ss(I):
    pass


# def load_sol(file_path):
#     with open(file_path, "r") as json_file:
#         data = json.load(json_file)

#     # Initialiser les structures de données
#     x = {}
#     y = [[], []]
#     z = {}

#     # Remplir les structures de données à partir du contenu du fichier JSON
#     for substation in data.get("substations", []):
#         substation_id = substation["id"]
#         substation_type = substation["substation_type"]
#         x[(substation_id, substation_type)] = 1

#     for cable in data.get("substation_substation_cables", []):
#         substation_id = cable["substation_id"]
#         other_substation_id = cable["other_substation_id"]
#         cable_type = cable["cable_type"]
#         y[1].append((substation_id, other_substation_id, 0, cable_type))

#     for turbine in data.get("turbines", []):
#         substation_id = turbine["substation_id"]
#         turbine_id = turbine["id"]
#         z[(substation_id, turbine_id)] = 1

#     return x, y, z

# # Exemple d'utilisation
# file_path = "solutions/votre_solution.json"
# x, y, z = load_sol(file_path)
