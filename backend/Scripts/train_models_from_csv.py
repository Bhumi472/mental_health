# backend/scripts/train_models_from_csv.py
import os
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, mean_absolute_error
import joblib

data_dir = os.path.join(os.path.dirname(__file__), '..', 'data')
models_dir = os.path.join(os.path.dirname(__file__), '..', 'app', 'ai', 'models')
os.makedirs(models_dir, exist_ok=True)

# Load daily features
features_df = pd.read_csv(os.path.join(data_dir, 'daily_features.csv'))
features_df['date'] = pd.to_datetime(features_df['date'])

def create_targets(df):
    """
    Create synthetic targets for demonstration.
    In a real system, you'd have actual labels.
    """
    users = df.groupby('user_id')
    records = []
    for user_id, group in users:
        group = group.sort_values('date')
        if len(group) < 7:
            continue
        recent = group.tail(7)
        avg_sentiment = recent['sentiment'].mean()
        avg_test = recent['avg_test_score'].mean()
        total_game = recent['game_events'].sum()
        total_community = recent['community_actions'].sum()

        # Risk label: 1 if sentiment < -0.1 and avg_test > 10, else 0
        risk = 1 if (avg_sentiment < -0.1 and avg_test > 10) else 0

        # Condition: 0=healthy, 1=mild, 2=moderate, 3=severe
        if avg_sentiment < -0.3 and avg_test > 20:
            condition = 3
        elif avg_sentiment < -0.2 and avg_test > 15:
            condition = 2
        elif avg_sentiment < -0.1 and avg_test > 10:
            condition = 1
        else:
            condition = 0

        # Trend forecast: next week's avg sentiment
        if len(group) >= 14:
            next_week = group.iloc[-7:]['sentiment'].mean()
        else:
            next_week = np.nan

        records.append({
            'user_id': user_id,
            'avg_sentiment_7d': avg_sentiment,
            'avg_test_score_7d': avg_test,
            'total_game_events_7d': total_game,
            'total_community_actions_7d': total_community,
            'risk_label': risk,
            'condition_label': condition,
            'future_sentiment': next_week
        })
    return pd.DataFrame(records)

def train_risk_model(X, y):
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X, y)
    return model

def train_condition_model(X, y):
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X, y)
    return model

def train_trend_model(X, y):
    mask = ~y.isna()
    X_clean = X[mask]
    y_clean = y[mask]
    if len(X_clean) < 10:
        raise Exception("Not enough data for trend model")
    model = RandomForestRegressor(n_estimators=100, random_state=42)
    model.fit(X_clean, y_clean)
    return model

def main():
    print("🚀 Creating target variables...")
    target_df = create_targets(features_df)

    feature_cols = ['avg_sentiment_7d', 'avg_test_score_7d', 'total_game_events_7d', 'total_community_actions_7d']
    X = target_df[feature_cols]

    # 1. Risk Model
    print("\n📊 Training Risk Stratification Model...")
    y_risk = target_df['risk_label']
    X_train, X_test, y_train, y_test = train_test_split(X, y_risk, test_size=0.2, random_state=42)
    risk_model = train_risk_model(X_train, y_train)
    y_pred = risk_model.predict(X_test)
    print(classification_report(y_test, y_pred))
    joblib.dump(risk_model, os.path.join(models_dir, 'risk_model.pkl'))
    print("✅ Risk model saved.")

    # 2. Condition Model
    print("\n📊 Training Condition Prediction Model...")
    y_cond = target_df['condition_label']
    X_train, X_test, y_train, y_test = train_test_split(X, y_cond, test_size=0.2, random_state=42)
    cond_model = train_condition_model(X_train, y_train)
    y_pred = cond_model.predict(X_test)
    print(classification_report(y_test, y_pred))
    joblib.dump(cond_model, os.path.join(models_dir, 'condition_model.pkl'))
    print("✅ Condition model saved.")

    # 3. Trend Model
    print("\n📊 Training Trend Forecasting Model...")
    y_trend = target_df['future_sentiment']
    try:
        trend_model = train_trend_model(X, y_trend)
        mask = ~y_trend.isna()
        X_clean = X[mask]
        y_clean = y_trend[mask]
        X_train, X_test, y_train, y_test = train_test_split(X_clean, y_clean, test_size=0.2, random_state=42)
        trend_model.fit(X_train, y_train)
        y_pred = trend_model.predict(X_test)
        mae = mean_absolute_error(y_test, y_pred)
        print(f"Trend Model MAE: {mae:.3f}")
        joblib.dump(trend_model, os.path.join(models_dir, 'trend_model.pkl'))
        print("✅ Trend model saved.")
    except Exception as e:
        print(f"⚠️ Could not train trend model: {e}")

if __name__ == "__main__":
    main()