import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
import joblib
import matplotlib.pyplot as plt
# Load dataset
data = pd.read_csv("app/ai/datasets/popslash_data.csv")

# Separate features and target
X = data.drop("cognitive_score", axis=1)
y = data["cognitive_score"]

# Train test split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Create model
model = RandomForestRegressor(n_estimators=150, random_state=42)

# Train model
model.fit(X_train, y_train)

# Evaluate
score = model.score(X_test, y_test)
print("R² Score:", round(score, 4))

# Save model
joblib.dump(model, "app/ai/models/popslash_model.pkl")

print("Model saved successfully.")



# importances = model.feature_importances_
# features = X.columns

# plt.figure(figsize=(8,5))
# plt.barh(features, importances)
# plt.title("Feature Importance - PopSlash Model")
# plt.tight_layout()
# plt.show()
