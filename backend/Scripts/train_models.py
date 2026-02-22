# backend/scripts/train_models.py
import os
import pandas as pd
import numpy as np
from influxdb_client import InfluxDBClient
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, mean_absolute_error
import joblib
from dotenv import load_dotenv

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '..', '.env'))

# InfluxDB connection
INFLUXDB_URL = os.getenv('INFLUXDB_URL', 'http://localhost:8086')
INFLUXDB_TOKEN = os.getenv('INFLUXDB_TOKEN', 'your-token')
INFLUXDB_ORG = os.getenv('INFLUXDB_ORG', 'mentalhealth')
INFLUXDB_BUCKET = os.getenv('INFLUXDB_BUCKET', 'features')

client = InfluxDBClient(url=INFLUXDB_URL, token=INFLUXDB_TOKEN, org=INFLUXDB_ORG)
query_api = client.query_api()

# Output directory for models
models_dir = os.path.join(os.path.dirname(__file__), '..', 'app', 'ai', 'models')
os.makedirs(models_dir, exist_ok=True)

def fetch_features():
    # Query all daily features for the last 30 days (or all available)
    query = f'''
    from(bucket: "{INFLUXDB_BUCKET}")
      |> range(start: -90d)
      |> filter(fn: (r) => r._measurement == "user_daily_features")
      |> pivot(rowKey:["_time"], columnKey:["_field"], valueColumn:"_value")
    '''
    result = query_api.query_data_frame(query)
    if result.empty:
        raise Exception("No data found in InfluxDB. Run ETL first.")
    
    # Clean up
    df = result.drop(columns=['result', 'table', '_start', '_stop', '_measurement'], errors='ignore')
    df['_time'] = pd.to_datetime(df['_time'])
    df = df.rename(columns={'_time': 'date', 'user_id': 'user_id'})
    return df

def create_targets(df):
    """
    Create synthetic targets for demonstration.
    In a real system, you'd have actual labels (e.g., clinician diagnoses).
    """
    # Group by user and aggregate last 7 days of features
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
        
        # Condition (multi-class): 0=healthy, 1=mild, 2=moderate, 3=severe
        if avg_sentiment < -0.3 and avg_test > 20:
            condition = 3
        elif avg_sentiment < -0.2 and avg_test > 15:
            condition = 2
        elif avg_sentiment < -0.1 and avg_test > 10:
            condition = 1
        else:
            condition = 0
        
        # Trend forecast target: next week's avg sentiment (for regression)
        # Use the following week if available, otherwise NaN
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
    
    target_df = pd.DataFrame(records)
    return target_df

def train_risk_model(X, y):
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X, y)
    return model

def train_condition_model(X, y):
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X, y)
    return model

def train_trend_model(X, y):
    # Only use rows where future_sentiment is not NaN
    mask = ~y.isna()
    X_clean = X[mask]
    y_clean = y[mask]
    if len(X_clean) < 10:
        raise Exception("Not enough data for trend model")
    model = RandomForestRegressor(n_estimators=100, random_state=42)
    model.fit(X_clean, y_clean)
    return model

def main():
    print("🚀 Fetching features from InfluxDB...")
    df_features = fetch_features()
    
    print("⚙️ Creating target variables...")
    target_df = create_targets(df_features)
    
    # Features for all models (same set for simplicity)
    feature_cols = ['avg_sentiment_7d', 'avg_test_score_7d', 'total_game_events_7d', 'total_community_actions_7d']
    X = target_df[feature_cols]
    
    # 1. Risk Model
    print("📊 Training Risk Stratification Model...")
    y_risk = target_df['risk_label']
    X_train, X_test, y_train, y_test = train_test_split(X, y_risk, test_size=0.2, random_state=42)
    risk_model = train_risk_model(X_train, y_train)
    y_pred = risk_model.predict(X_test)
    print(classification_report(y_test, y_pred))
    joblib.dump(risk_model, os.path.join(models_dir, 'risk_model.pkl'))
    print("✅ Risk model saved.")
    
    # 2. Condition Prediction Model
    print("📊 Training Condition Prediction Model...")
    y_cond = target_df['condition_label']
    X_train, X_test, y_train, y_test = train_test_split(X, y_cond, test_size=0.2, random_state=42)
    cond_model = train_condition_model(X_train, y_train)
    y_pred = cond_model.predict(X_test)
    print(classification_report(y_test, y_pred))
    joblib.dump(cond_model, os.path.join(models_dir, 'condition_model.pkl'))
    print("✅ Condition model saved.")
    
    # 3. Trend Forecasting Model
    print("📊 Training Trend Forecasting Model...")
    y_trend = target_df['future_sentiment']
    try:
        trend_model = train_trend_model(X, y_trend)
        # Evaluate on a test set
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