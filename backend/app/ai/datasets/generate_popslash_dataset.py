import pandas as pd
import numpy as np

np.random.seed(42)

rows = 1000  # good size for training

data = []

for _ in range(rows):

    # performance tier selection
    tier = np.random.choice(
        ["poor", "average", "good", "excellent"],
        p=[0.2, 0.35, 0.3, 0.15]
    )

    if tier == "poor":
        reaction_time = np.random.randint(550, 850)
        accuracy = np.random.randint(40, 65)
        wrong_hits = np.random.randint(10, 25)
        missed = np.random.randint(15, 35)

    elif tier == "average":
        reaction_time = np.random.randint(400, 600)
        accuracy = np.random.randint(60, 80)
        wrong_hits = np.random.randint(5, 15)
        missed = np.random.randint(10, 20)

    elif tier == "good":
        reaction_time = np.random.randint(300, 450)
        accuracy = np.random.randint(75, 90)
        wrong_hits = np.random.randint(3, 10)
        missed = np.random.randint(5, 15)

    else:  # excellent
        reaction_time = np.random.randint(200, 350)
        accuracy = np.random.randint(85, 100)
        wrong_hits = np.random.randint(0, 5)
        missed = np.random.randint(0, 8)

    variance = np.random.randint(50, 250)
    correct_hits = np.random.randint(30, 80)
    session_duration = np.random.randint(60, 130)

    # realistic cognitive score formula
    score = (
        accuracy * 0.5
        + (1000 - reaction_time) * 0.05
        - wrong_hits * 0.7
        - missed * 0.6
        + np.random.normal(0, 5)
    )

    score = max(30, min(100, round(score, 2)))

    data.append([
        reaction_time,
        variance,
        correct_hits,
        wrong_hits,
        missed,
        accuracy,
        session_duration,
        score
    ])

df = pd.DataFrame(data, columns=[
    "reaction_time_avg",
    "reaction_time_variance",
    "correct_hits",
    "wrong_hits",
    "missed_targets",
    "accuracy",
    "session_duration",
    "cognitive_score"
])

df.to_csv("popslash_data.csv", index=False)

print("Balanced dataset created successfully.")
