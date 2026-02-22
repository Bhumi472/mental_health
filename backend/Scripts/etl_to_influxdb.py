# backend/scripts/etl_to_influxdb.py
import os
import pandas as pd
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS
from datetime import datetime
from textblob import TextBlob
from dotenv import load_dotenv

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '..', '.env'))

data_dir = os.path.join(os.path.dirname(__file__), '..', 'data')

INFLUXDB_URL = os.getenv('INFLUXDB_URL', 'http://localhost:8086')
INFLUXDB_TOKEN = os.getenv('INFLUXDB_TOKEN', 'your-token')
INFLUXDB_ORG = os.getenv('INFLUXDB_ORG', 'mentalhealth')
INFLUXDB_BUCKET = os.getenv('INFLUXDB_BUCKET', 'features')

influx_client = InfluxDBClient(url=INFLUXDB_URL, token=INFLUXDB_TOKEN, org=INFLUXDB_ORG)
write_api = influx_client.write_api(write_options=SYNCHRONOUS)

def get_sentiment(text):
    if pd.isna(text) or text == '':
        return 0.0
    return TextBlob(text).sentiment.polarity

def compute_daily_features():
    users = pd.read_csv(os.path.join(data_dir, 'users.csv'))
    journal = pd.read_csv(os.path.join(data_dir, 'journal_entries.csv'), parse_dates=['created_at'])
    tests = pd.read_csv(os.path.join(data_dir, 'test_results.csv'), parse_dates=['taken_at'])
    telemetry = pd.read_csv(os.path.join(data_dir, 'game_telemetry.csv'), parse_dates=['timestamp'])
    
    comments = pd.read_csv(os.path.join(data_dir, 'community_comments.csv'), parse_dates=['created_at'])
    likes = pd.read_csv(os.path.join(data_dir, 'community_likes.csv'), parse_dates=['created_at'])
    
    comments['action'] = 'comment'
    likes['action'] = 'like'
    community = pd.concat([comments[['user_id', 'created_at', 'action']], 
                           likes[['user_id', 'created_at', 'action']]], ignore_index=True)
    community = community.rename(columns={'created_at': 'timestamp'})

    start_date = min(journal['created_at'].min(), tests['taken_at'].min(), community['timestamp'].min()).date()
    end_date = datetime.now().date()
    all_dates = pd.date_range(start=start_date, end=end_date, freq='D')

    for user_id in users['id'].unique():
        print(f"Processing user {user_id}")

        user_journal = journal[journal['user_id'] == user_id].copy()
        if not user_journal.empty:
            user_journal['date'] = user_journal['created_at'].dt.date
            daily_sentiment = user_journal.groupby('date').apply(
                lambda x: get_sentiment(' '.join(x['text']))
            ).reset_index(name='sentiment')
        else:
            daily_sentiment = pd.DataFrame(columns=['date', 'sentiment'])

        user_tests = tests[tests['user_id'] == user_id].copy()
        if not user_tests.empty:
            user_tests['date'] = user_tests['taken_at'].dt.date
            daily_test_avg = user_tests.groupby('date')['score'].mean().reset_index(name='avg_test_score')
        else:
            daily_test_avg = pd.DataFrame(columns=['date', 'avg_test_score'])

        user_telemetry = telemetry[telemetry['user_id'] == user_id].copy()
        if not user_telemetry.empty:
            user_telemetry['date'] = user_telemetry['timestamp'].dt.date
            daily_game_count = user_telemetry.groupby('date').size().reset_index(name='game_events')
        else:
            daily_game_count = pd.DataFrame(columns=['date', 'game_events'])

        user_community = community[community['user_id'] == user_id].copy()
        if not user_community.empty:
            user_community['date'] = user_community['timestamp'].dt.date
            daily_community_count = user_community.groupby('date').size().reset_index(name='community_actions')
        else:
            daily_community_count = pd.DataFrame(columns=['date', 'community_actions'])

        daily = pd.DataFrame({'date': all_dates.date})
        daily = daily.merge(daily_sentiment, on='date', how='left')
        daily = daily.merge(daily_test_avg, on='date', how='left')
        daily = daily.merge(daily_game_count, on='date', how='left')
        daily = daily.merge(daily_community_count, on='date', how='left')
        daily = daily.fillna(0)

        for _, row in daily.iterrows():
            point = Point("user_daily_features") \
                .tag("user_id", str(user_id)) \
                .field("sentiment", float(row['sentiment'])) \
                .field("avg_test_score", float(row['avg_test_score'])) \
                .field("game_events", int(row['game_events'])) \
                .field("community_actions", int(row['community_actions'])) \
                .time(row['date'].strftime('%Y-%m-%d'))
            write_api.write(bucket=INFLUXDB_BUCKET, record=point)

    print("✅ Daily features written to InfluxDB.")

if __name__ == "__main__":
    compute_daily_features()