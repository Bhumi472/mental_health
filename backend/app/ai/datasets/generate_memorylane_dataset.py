import pandas as pd
import numpy as np

np.random.seed(42)
rows = 1000
data = []

for _ in range(rows):
    level = np.random.randint(3, 25)
    total_sequences = level
    correct_sequences = np.random.randint(int(level*0.5), level+1)
    wrong_attempts = np.random.randint(0, 10)
    avg_reaction = np.random.randint(300, 1200)
    max_streak = np.random.randint(2, level+1)
    duration = np.random.randint(60, 300)

    score = (
        correct_sequences * 3
        + max_streak * 2
        - wrong_attempts * 4
        + (1500 - avg_reaction) * 0.02
        + np.random.normal(0, 5)
    )

    score = max(30, min(100, round(score, 2)))

    data.append([
        level,
        total_sequences,
        correct_sequences,
        wrong_attempts,
        avg_reaction,
        max_streak,
        duration,
        score
    ])

df = pd.DataFrame(data, columns=[
    "level_reached",
    "total_sequences",
    "correct_sequences",
    "wrong_attempts",
    "avg_reaction_time",
    "max_streak",
    "session_duration",
    "memory_score"
])

df.to_csv("memorylane_data.csv", index=False)
print("MemoryLane dataset created.")
