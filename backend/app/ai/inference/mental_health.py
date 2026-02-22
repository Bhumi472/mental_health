import os
import joblib
import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent.parent
MODELS_DIR = os.path.join(BASE_DIR, 'ai', 'models')
DATA_DIR = os.path.join(BASE_DIR, '..', 'data')

# Load models
risk_model = joblib.load(os.path.join(MODELS_DIR, 'risk_model.pkl'))
condition_model = joblib.load(os.path.join(MODELS_DIR, 'condition_model.pkl'))
trend_model = joblib.load(os.path.join(MODELS_DIR, 'trend_model.pkl'))

# Load daily features and ensure user_id is string
daily_features = pd.read_csv(os.path.join(DATA_DIR, 'daily_features.csv'))
daily_features['user_id'] = daily_features['user_id'].astype(str)   # convert to string
daily_features['date'] = pd.to_datetime(daily_features['date'])

def get_user_features(user_id: str):
    """Return last 7 days aggregated features for a user. user_id is string."""
    user_df = daily_features[daily_features['user_id'] == user_id]
    if user_df.empty:
        return None
    recent = user_df.sort_values('date').tail(7)
    features = {
        'avg_sentiment_7d': recent['sentiment'].mean(),
        'avg_test_score_7d': recent['avg_test_score'].mean(),
        'total_game_events_7d': recent['game_events'].sum(),
        'total_community_actions_7d': recent['community_actions'].sum()
    }
    return pd.DataFrame([features])

def predict_risk(user_id: str):
    feats = get_user_features(user_id)
    if feats is None:
        return None, None
    pred = risk_model.predict(feats)[0]
    # Get probability array
    proba = risk_model.predict_proba(feats)[0]
    # Handle both binary and single-class cases
    if len(proba) == 2:
        proba_positive = proba[1]
    else:
        # Single class: probability is 1.0 if prediction is 1, else 0.0
        proba_positive = 1.0 if pred == 1 else 0.0
    return int(pred), float(proba_positive)

def predict_condition(user_id: str):
    feats = get_user_features(user_id)
    if feats is None:
        return None
    return int(condition_model.predict(feats)[0])

def predict_trend(user_id: str):
    feats = get_user_features(user_id)
    if feats is None:
        return None
    return float(trend_model.predict(feats)[0])

CONDITION_LABELS = {
    0: 'Healthy',
    1: 'Mild',
    2: 'Moderate',
    3: 'Severe'
}