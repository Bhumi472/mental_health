import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
import joblib

# Load dataset
data = pd.read_csv("app/ai/datasets/memorylane_data.csv")

# Split features and target
X = data.drop("memory_score", axis=1)
y = data["memory_score"]

# Train test split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Create model
model = RandomForestRegressor(n_estimators=150, random_state=42)

# Train
model.fit(X_train, y_train)

# Evaluate
score = model.score(X_test, y_test)
print("MemoryLane R² Score:", round(score, 4))

# Save model
joblib.dump(model, "app/ai/models/memorylane_model.pkl")

print("MemoryLane model saved successfully.")
