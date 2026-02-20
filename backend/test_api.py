import requests

BASE_URL = "http://127.0.0.1:8000"

# ---------------------------
# STEP 1: Login
# ---------------------------
print("🔐 Logging in...")

login_response = requests.post(
    f"{BASE_URL}/api/auth/login",
    json={
        "email": "test@example.com",
        "password": "password123"
    }
)

if login_response.status_code != 200:
    print("❌ Login failed:", login_response.text)
    exit()

token = login_response.json().get("access_token")
print("✅ Login successful")
print("Token:", token[:50], "...")

headers = {
    "Authorization": f"Bearer {token}"
}

# ---------------------------
# STEP 2: Test MemoryLane
# ---------------------------
print("\n🧠 Testing MemoryLane...")

memory_response = requests.post(
    f"{BASE_URL}/api/memorylane/session",
    headers=headers,
    json={
        "level_reached": 12,
        "total_sequences": 12,
        "correct_sequences": 10,
        "wrong_attempts": 2,
        "avg_reaction_time": 650,
        "max_streak": 8,
        "session_duration": 180
    }
)

print("MemoryLane Status:", memory_response.status_code)
print("MemoryLane Response:", memory_response.json())

# ---------------------------
# STEP 3: Test PopSlash
# ---------------------------
print("\n🎯 Testing PopSlash...")

popslash_response = requests.post(
    f"{BASE_URL}/api/popslash/session",
    headers=headers,
    json={
        "reaction_time_avg": 300,
        "reaction_time_variance": 120,
        "correct_hits": 70,
        "wrong_hits": 5,
        "missed_targets": 10,
        "accuracy": 93,
        "session_duration": 90
    }
)

print("PopSlash Status:", popslash_response.status_code)
print("PopSlash Response:", popslash_response.json())

print("\n🎉 Testing Complete.")
