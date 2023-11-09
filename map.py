import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import geopandas as gpd  # For maps


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


def draw_data(data):
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
