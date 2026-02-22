# backend/scripts/load_to_postgres.py
import os
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# Load environment variables from ../.env
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '..', '.env'))

DB_USER = os.getenv('POSTGRES_USER', 'user')
DB_PASSWORD = os.getenv('POSTGRES_PASSWORD', 'password')
DB_HOST = os.getenv('POSTGRES_HOST', 'localhost')
DB_PORT = os.getenv('POSTGRES_PORT', '5432')
DB_NAME = os.getenv('POSTGRES_DB', 'mentalhealth')

DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(DATABASE_URL)

# Path to CSV files
data_dir = os.path.join(os.path.dirname(__file__), '..', 'data')

# List of CSV files and corresponding table names
csv_files = [
    ('users.csv', 'users'),
    ('psychologists.csv', 'psychologists'),
    ('journal_entries.csv', 'journal_entries'),
    ('test_results.csv', 'test_results'),
    ('game_telemetry.csv', 'game_telemetry'),
    ('community_posts.csv', 'community_posts'),
    ('community_comments.csv', 'community_comments'),
    ('community_likes.csv', 'community_likes'),
    ('activities.csv', 'activities'),
    ('consultancy_bookings.csv', 'consultancy_bookings'),
    ('progress_metrics.csv', 'progress_metrics')
]

def load_csv_to_postgres(csv_name, table_name):
    file_path = os.path.join(data_dir, csv_name)
    if not os.path.exists(file_path):
        print(f"⚠️  {csv_name} not found, skipping.")
        return
    df = pd.read_csv(file_path)
    # Convert date/time columns if needed (pandas will try to infer)
    # For simplicity, we let pandas/sqlalchemy handle it.
    df.to_sql(table_name, engine, if_exists='replace', index=False)
    print(f"✅ Loaded {len(df)} rows into {table_name}")

def main():
    print("🚀 Loading CSV files into PostgreSQL...")
    for csv_name, table_name in csv_files:
        load_csv_to_postgres(csv_name, table_name)
    print("🎉 All data loaded.")

if __name__ == "__main__":
    main()