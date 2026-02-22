# backend/scripts/generate_dummy_data.py
import os
import pandas as pd
import numpy as np
from faker import Faker
import random
from datetime import datetime, timedelta
import json
import uuid
import hashlib

fake = Faker(['en_US', 'es_ES', 'fr_FR', 'de_DE', 'hi_IN', 'zh_CN'])

# Configuration
NUM_USERS = 200
START_DATE = datetime.now() - timedelta(days=180)
END_DATE = datetime.now()
LANGUAGES = ['English', 'Spanish', 'French', 'German', 'Hindi', 'Mandarin']
CITIES = ['New York', 'London', 'Mumbai', 'Tokyo', 'Berlin', 'Paris', 'Sydney', 'Cape Town']
PROFESSIONS = ['Student', 'Software Engineer', 'Teacher', 'Doctor', 'Artist', 'Business Owner', 'Homemaker', 'Retired']
TEST_NAMES = ['Mood Assessment', 'Anxiety Screening', 'Stress Level', 'Sleep Quality', 'Social Wellness']

# Helper functions
def generate_age_group(age):
    if age < 18:
        return 'under_18'
    elif age <= 35:
        return '18-35'
    elif age <= 55:
        return '36-55'
    else:
        return '55_plus'

def generate_group_token():
    return str(uuid.uuid4())[:8].upper()

def generate_test_questions(test_name, num_questions=5):
    """Generate 4-5 situational questions per test"""
    questions_db = {
        'Mood Assessment': [
            "Over the past 2 weeks, how often have you felt down or hopeless?",
            "Have you lost interest in activities you used to enjoy?",
            "How would you rate your energy levels?",
            "Do you feel your mood affects your daily functioning?",
            "Have you experienced any changes in appetite?"
        ],
        'Anxiety Screening': [
            "How often do you feel nervous or on edge?",
            "Do you experience sudden feelings of panic?",
            "How often do you worry about different things?",
            "Do you have trouble relaxing?",
            "How often do you feel afraid something awful might happen?"
        ],
        'Stress Level': [
            "How often do you feel overwhelmed by responsibilities?",
            "Do you have difficulty sleeping due to stress?",
            "How often do you feel irritable or angry?",
            "Do you feel you can cope with daily pressures?",
            "How often do you feel physically tense?"
        ],
        'Sleep Quality': [
            "How many hours of sleep do you average per night?",
            "Do you have trouble falling asleep?",
            "How often do you wake up during the night?",
            "Do you feel rested when you wake up?",
            "Do you use any sleep aids?"
        ],
        'Social Wellness': [
            "How satisfied are you with your social connections?",
            "How often do you feel lonely?",
            "Do you have someone to confide in?",
            "How often do you participate in social activities?",
            "Do you feel supported by your community?"
        ]
    }
    return questions_db.get(test_name, questions_db['Mood Assessment'])[:num_questions]

def calculate_test_score(answers, test_name):
    """Convert answers to scores (0-100 scale)"""
    base_scores = {
        'Mood Assessment': random.randint(30, 90),
        'Anxiety Screening': random.randint(20, 85),
        'Stress Level': random.randint(25, 88),
        'Sleep Quality': random.randint(40, 95),
        'Social Wellness': random.randint(35, 92)
    }
    score = base_scores.get(test_name, 70)
    # Add variation based on answer patterns
    variation = sum(answers) / len(answers) if answers else 0
    return min(100, max(0, score + (variation - 2) * 5))

def generate_journal_entry(user_age, user_gender, sentiment_bias=0):
    """Generate journal text with emotional tone based on user profile"""
    templates = {
        'positive': [
            "Today was really good! {activity} made me happy.",
            "I'm feeling optimistic about {topic}.",
            "Had a great conversation with {person}.",
            "Finally made progress on {goal}!"
        ],
        'neutral': [
            "Just another {day_type} day. {activity} as usual.",
            "Thinking about {topic}. Not sure how I feel.",
            "Went to {place} today. It was okay.",
            "Need to plan for {future_event}."
        ],
        'negative': [
            "Feeling really anxious about {concern}.",
            "Couldn't sleep last night because of {worry}.",
            "Everything feels overwhelming right now.",
            "I wish {situation} was different."
        ]
    }
    
    # Weight sentiment based on user profile (younger users more variable)
    sentiment_probs = [0.3, 0.4, 0.3]  # positive, neutral, negative
    if sentiment_bias > 0.5:
        sentiment_probs = [0.5, 0.3, 0.2]  # more positive
    elif sentiment_bias < -0.5:
        sentiment_probs = [0.2, 0.3, 0.5]  # more negative
    
    sentiment = random.choices(['positive', 'neutral', 'negative'], weights=sentiment_probs)[0]
    template = random.choice(templates[sentiment])
    
    # Fill template
    fillers = {
        'activity': random.choice(['meditation', 'exercise', 'reading', 'cooking', 'walking']),
        'topic': random.choice(['work', 'relationships', 'health', 'future', 'past']),
        'person': random.choice(['friend', 'family', 'colleague', 'neighbor']),
        'goal': random.choice(['project', 'fitness', 'learning', 'savings']),
        'day_type': random.choice(['productive', 'lazy', 'busy', 'quiet']),
        'place': random.choice(['gym', 'park', 'store', 'cafe']),
        'future_event': random.choice(['meeting', 'trip', 'deadline', 'appointment']),
        'concern': random.choice(['health', 'money', 'job', 'family']),
        'worry': random.choice(['deadlines', 'bills', 'conflict', 'uncertainty']),
        'situation': random.choice(['at work', 'at home', 'with friends', 'in general'])
    }
    
    return template.format(**fillers)

def generate_game_telemetry(user_id, session_id, game_type):
    """Generate behavioral data for the 3 games"""
    games = {
        'Memory Match': {
            'events': ['card_flip', 'match_found', 'level_complete', 'hint_used'],
            'metrics': ['reaction_time', 'accuracy', 'completion_time']
        },
        'Emotion Recognition': {
            'events': ['face_shown', 'emotion_selected', 'feedback', 'next'],
            'metrics': ['response_time', 'accuracy', 'confidence']
        },
        'Breathing Exercise': {
            'events': ['session_start', 'inhale', 'exhale', 'session_end'],
            'metrics': ['duration', 'completion_rate', 'calmness_rating']
        }
    }
    
    game_data = games.get(game_type, games['Memory Match'])
    num_events = random.randint(5, 20)
    telemetry = []
    
    for _ in range(num_events):
        event = random.choice(game_data['events'])
        timestamp = fake.date_time_between(start_date='-7d', end_date='now')
        
        # Generate game-specific metrics
        if game_type == 'Memory Match':
            value = {
                'reaction_time': random.uniform(0.5, 3.0),
                'accuracy': random.uniform(0.6, 1.0),
                'cards_matched': random.randint(1, 12)
            }
        elif game_type == 'Emotion Recognition':
            value = {
                'response_time': random.uniform(0.8, 4.0),
                'accuracy': random.uniform(0.5, 1.0),
                'emotion': random.choice(['happy', 'sad', 'angry', 'surprised', 'neutral'])
            }
        else:  # Breathing Exercise
            value = {
                'breath_count': random.randint(5, 30),
                'completion': random.uniform(0.3, 1.0),
                'calmness': random.randint(1, 10)
            }
        
        telemetry.append({
            'id': len(telemetry) + 1,
            'user_id': user_id,
            'session_id': session_id,
            'game_type': game_type,
            'event_type': event,
            'value': json.dumps(value),
            'timestamp': timestamp
        })
    
    return telemetry

def generate_community_post(user_id, is_moderated=True):
    """Generate Reddit-style post with content moderation"""
    topics = ['anxiety', 'depression', 'stress', 'relationships', 'therapy', 'medication', 'self_care']
    
    if is_moderated:
        # Clean content for 18+ community
        templates = [
            "Has anyone tried {therapy_type}? Looking for experiences.",
            "How do you cope with {issue} at work?",
            "Just started {medication_type} – any advice?",
            "Feeling {emotion} today. How do you deal with it?",
            "Success story: I finally {achievement}!"
        ]
    else:
        templates = templates  # Same for now, could add more sensitive content
        
    template = random.choice(templates)
    post = template.format(
        therapy_type=random.choice(['CBT', 'mindfulness', 'group therapy', 'online counseling']),
        issue=random.choice(['anxiety', 'stress', 'burnout']),
        medication_type=random.choice(['SSRI', 'SNRI', 'natural supplements']),
        emotion=random.choice(['hopeful', 'anxious', 'overwhelmed', 'lonely']),
        achievement=random.choice(['started therapy', 'joined a support group', 'opened up to family'])
    )
    
    return post

def generate_consultancy_booking(user_id, psychologists):
    """Generate nearest psychologist booking"""
    psychologist = random.choice(psychologists)
    booking_date = fake.date_time_between(start_date='+1d', end_date='+30d')
    
    return {
        'booking_id': str(uuid.uuid4()),
        'user_id': user_id,
        'psychologist_id': psychologist['id'],
        'psychologist_name': psychologist['name'],
        'clinic_address': psychologist['address'],
        'distance_km': random.uniform(0.5, 15.0),
        'booking_date': booking_date,
        'consultation_type': random.choice(['in_person', 'video']),
        'status': random.choice(['confirmed', 'pending', 'completed']),
        'created_at': datetime.now()
    }

# ==================== MAIN DATA GENERATION ====================

def main():
    print("🚀 Starting Mental Health App dummy data generation...")

    # 1. GENERATE USERS (with all registration fields)
    print("\n📝 Generating users...")
    users = []
    psychologists = []  # Separate list for consultants

    for i in range(1, NUM_USERS + 1):
        # Determine user type (80% individual, 15% family, 5% organisation)
        user_type = random.choices(
            ['individual', 'family', 'organisation'], 
            weights=[0.8, 0.15, 0.05]
        )[0]
        
        age = random.randint(13, 85)
        age_group = generate_age_group(age)
        
        # Generate group token for family/organisation
        group_token = generate_group_token() if user_type != 'individual' else None
        
        # For family/organisation, create multiple members
        if user_type != 'individual':
            # Generate primary user (head)
            num_members = random.randint(2, 8) if user_type == 'family' else random.randint(5, 20)
        else:
            num_members = 1
        
        # Generate each member
        for member_num in range(num_members):
            member_age = max(13, age + random.randint(-15, 15))
            user = {
                'id': len(users) + 1,
                'username': fake.user_name() + str(random.randint(10, 99)),
                'email': fake.email(),
                'password_hash': hashlib.sha256(fake.password().encode()).hexdigest()[:16],
                'full_name': fake.name(),
                'user_type': user_type,
                'group_token': group_token,
                'age': member_age,
                'age_group': generate_age_group(member_age),
                'gender': random.choice(['Male', 'Female', 'Non-binary', 'Prefer not to say']),
                'profession': random.choice(PROFESSIONS) if member_age > 18 else 'Student',
                'address': fake.street_address(),
                'city': random.choice(CITIES),
                'preferred_language': random.choice(LANGUAGES),
                'phone': fake.phone_number(),
                'dob': fake.date_of_birth(minimum_age=13, maximum_age=85),
                'created_at': fake.date_time_between(start_date='-180d', end_date='-30d'),
                'privacy_consent': random.choice([True, True, True, False]),  # 75% consent
                'data_retention_months': 6,  # Free tier default
                'app_analytics_allowed': random.choice([True, False]),
                'is_active': random.random() > 0.1  # 90% active
            }
            users.append(user)
        
        # Generate a few psychologists for consultancy
        if i % 20 == 0:  # Every 20 users, create a psychologist
            psychologists.append({
                'id': len(psychologists) + 1,
                'name': fake.name(),
                'specialization': random.choice(['Clinical Psychologist', 'Counselor', 'Psychiatrist', 'Therapist']),
                'clinic_name': fake.company() + " Clinic",
                'address': fake.address(),
                'city': random.choice(CITIES),
                'phone': fake.phone_number(),
                'email': fake.email(),
                'available_days': random.sample(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'], 4)
            })

    print(f"✅ Generated {len(users)} users across all types")
    print(f"✅ Generated {len(psychologists)} psychologists")

    # 2. GENERATE JOURNAL ENTRIES
    print("\n📔 Generating journal entries...")
    journal_entries = []
    for user in users:
        if user['age'] < 18:  # Minors might journal less
            num_entries = random.randint(0, 15)
        else:
            num_entries = random.randint(5, 40)
        
        for _ in range(num_entries):
            created_at = fake.date_time_between(start_date=user['created_at'], end_date='now')
            # Add voice journaling for some entries
            has_voice = random.random() < 0.3
            
            # Add PIN lock for some entries (privacy feature)
            is_locked = random.random() < 0.15
            
            # Generate sentiment bias based on user age/gender (just for variety)
            sentiment_bias = random.uniform(-1, 1)
            
            # Safe timestamp for voice filename
            try:
                timestamp_str = fake.date_time().strftime('%Y%m%d_%H%M%S')
            except Exception:
                timestamp_str = datetime.now().strftime('%Y%m%d_%H%M%S')
            voice_filename = f"voice_journal_{user['id']}_{timestamp_str}.mp3" if has_voice else None

            entry = {
                'id': len(journal_entries) + 1,
                'user_id': user['id'],
                'text': generate_journal_entry(user['age'], user['gender'], sentiment_bias),
                'voice_file': voice_filename,
                'voice_transcript': fake.sentence() if has_voice else None,
                'is_locked': is_locked,
                'pin_code': str(random.randint(1000, 9999)) if is_locked else None,
                'sentiment_score': sentiment_bias,
                'mood_tag': random.choice(['happy', 'sad', 'anxious', 'calm', 'stressed', 'hopeful']),
                'created_at': created_at,
                'word_count': random.randint(20, 300)
            }
            journal_entries.append(entry)

    print(f"✅ Generated {len(journal_entries)} journal entries (some with voice)")

    # 3. GENERATE TEST RESULTS (5 tests × 4-5 questions each)
    print("\n📊 Generating test results...")
    test_results = []
    test_questions_cache = {}  # Store generated questions per test

    for user in users:
        if user['age'] < 18:
            num_test_sessions = random.randint(1, 3)
        else:
            num_test_sessions = random.randint(2, 8)
        
        for session in range(num_test_sessions):
            taken_at = fake.date_time_between(start_date=user['created_at'], end_date='now')
            
            # Each session includes all 5 tests
            for test_name in TEST_NAMES:
                # Generate 4-5 questions with answers
                num_q = random.randint(4, 5)
                if test_name not in test_questions_cache:
                    questions = generate_test_questions(test_name, num_q)
                    test_questions_cache[test_name] = questions
                else:
                    questions = test_questions_cache[test_name][:num_q]
                
                # Generate answers (0-4 scale for most questions)
                answers = [random.randint(0, 4) for _ in range(len(questions))]
                score = calculate_test_score(answers, test_name)
                
                # Store patterns (detailed response data)
                patterns = {
                    'questions': questions,
                    'answers': answers,
                    'response_times': [random.uniform(2, 30) for _ in answers],
                    'hesitation_flags': [random.random() < 0.2 for _ in answers]
                }
                
                test_results.append({
                    'id': len(test_results) + 1,
                    'user_id': user['id'],
                    'session_id': str(uuid.uuid4()),  # Use UUID instead of timestamp
                    'test_name': test_name,
                    'score': round(score, 1),
                    'patterns': json.dumps(patterns),
                    'num_questions': len(questions),
                    'completion_time_seconds': random.randint(60, 300),
                    'taken_at': taken_at
                })

    print(f"✅ Generated {len(test_results)} test results (5 tests per session)")

    # 4. GENERATE GAME TELEMETRY (3 games with behavioral data)
    print("\n🎮 Generating game telemetry...")
    game_telemetry = []
    game_types = ['Memory Match', 'Emotion Recognition', 'Breathing Exercise']

    for user in users:
        if user['age'] < 18:
            num_sessions = random.randint(2, 10)
        else:
            num_sessions = random.randint(5, 25)
        
        for session in range(num_sessions):
            session_id = str(uuid.uuid4())  # Use UUID instead of timestamp
            game_type = random.choice(game_types)
            
            telemetry_data = generate_game_telemetry(user['id'], session_id, game_type)
            game_telemetry.extend(telemetry_data)

    print(f"✅ Generated {len(game_telemetry)} game telemetry events")

    # 5. GENERATE COMMUNITY ACTIVITY
    print("\n👥 Generating community activity...")
    community_posts = []
    community_comments = []
    community_likes = []

    # Generate posts (only for 18+ users)
    adult_users = [u for u in users if u['age'] >= 18]

    for user in adult_users:
        num_posts = random.randint(0, 10)
        for _ in range(num_posts):
            post_id = len(community_posts) + 1
            created_at = fake.date_time_between(start_date=user['created_at'], end_date='now')
            
            post = {
                'id': post_id,
                'user_id': user['id'],
                'title': fake.sentence(nb_words=6),
                'content': generate_community_post(user['id'], is_moderated=True),
                'topic': random.choice(['anxiety', 'depression', 'therapy', 'self_care', 'success_story']),
                'created_at': created_at,
                'updated_at': created_at + timedelta(days=random.randint(0, 5)) if random.random() < 0.3 else created_at,
                'is_flagged': random.random() < 0.02,  # 2% flagged
                'is_pinned': random.random() < 0.05
            }
            community_posts.append(post)
            
            # Generate comments for this post
            num_comments = random.randint(0, 15)
            for _ in range(num_comments):
                commenter = random.choice(adult_users)
                comment = {
                    'id': len(community_comments) + 1,
                    'post_id': post_id,
                    'user_id': commenter['id'],
                    'content': fake.sentence(nb_words=random.randint(5, 30)),
                    'created_at': fake.date_time_between(start_date=created_at, end_date='now'),
                    'is_flagged': random.random() < 0.01
                }
                community_comments.append(comment)
            
            # Generate likes
            num_likes = random.randint(0, 30)
            for _ in range(num_likes):
                liker = random.choice(adult_users)
                community_likes.append({
                    'id': len(community_likes) + 1,
                    'post_id': post_id,
                    'user_id': liker['id'],
                    'created_at': fake.date_time_between(start_date=created_at, end_date='now')
                })

    print(f"✅ Generated {len(community_posts)} posts, {len(community_comments)} comments, {len(community_likes)} likes")

    # 6. GENERATE ACTIVITIES (Exercises, Music, Books)
    print("\n🧘 Generating activities data...")
    activity_types = ['mental_exercise', 'physical_exercise', 'music', 'social', 'books']
    activities = []

    for user in users:
        num_activities = random.randint(10, 50)
        for _ in range(num_activities):
            activity_type = random.choice(activity_types)
            
            if activity_type == 'mental_exercise':
                name = random.choice(['Meditation', 'Deep Breathing', 'Mindfulness', 'Gratitude Journal', 'Progressive Relaxation'])
                duration = random.randint(5, 30)
            elif activity_type == 'physical_exercise':
                name = random.choice(['Walking', 'Yoga', 'Stretching', 'Light Cardio', 'Dance'])
                duration = random.randint(10, 45)
            elif activity_type == 'music':
                name = random.choice(['Calm Playlist', 'Focus Beats', 'Nature Sounds', 'Classical', 'LoFi'])
                duration = random.randint(15, 60)
            elif activity_type == 'social':
                name = random.choice(['Group Chat', 'Virtual Meetup', 'Support Group', 'Coffee with Friend'])
                duration = random.randint(20, 90)
            else:  # books
                name = random.choice(['Self-Help Book', 'Mental Wellness Guide', 'Biography', 'Fiction', 'Poetry'])
                duration = random.randint(30, 120)
            
            activities.append({
                'id': len(activities) + 1,
                'user_id': user['id'],
                'activity_type': activity_type,
                'activity_name': name,
                'duration_minutes': duration,
                'completed_at': fake.date_time_between(start_date=user['created_at'], end_date='now'),
                'mood_before': random.randint(1, 10),
                'mood_after': random.randint(1, 10),
                'notes': fake.sentence() if random.random() < 0.4 else None
            })

    print(f"✅ Generated {len(activities)} activity records")

    # 7. GENERATE CONSULTANCY BOOKINGS
    print("\n📅 Generating consultancy bookings...")
    consultancy_bookings = []

    for user in adult_users:
        if random.random() < 0.3:  # 30% of adults book consultations
            num_bookings = random.randint(1, 3)
            for _ in range(num_bookings):
                booking = generate_consultancy_booking(user['id'], psychologists)
                consultancy_bookings.append(booking)

    print(f"✅ Generated {len(consultancy_bookings)} consultancy bookings")

    # 8. GENERATE PROGRESS METRICS FOR REPORTS
    print("\n📈 Generating progress metrics for reports...")
    progress_metrics = []

    for user in users:
        # Weekly aggregates for 24 weeks
        weeks = 24
        for week in range(weeks):
            week_start = START_DATE + timedelta(days=week*7)
            week_end = week_start + timedelta(days=6)
            
            metrics = {
                'user_id': user['id'],
                'week_start': week_start.date(),
                'week_end': week_end.date(),
                'avg_test_score': round(random.uniform(40, 95), 1),
                'test_trend': random.choice(['improving', 'stable', 'declining']),
                'avg_sentiment': round(random.uniform(-0.5, 0.8), 2),
                'sentiment_trend': random.choice(['improving', 'stable', 'declining']),
                'games_played': random.randint(0, 14),
                'game_engagement': random.choice(['low', 'medium', 'high']),
                'community_posts': random.randint(0, 5),
                'community_comments': random.randint(0, 15),
                'activities_completed': random.randint(0, 10),
                'consultations_scheduled': random.randint(0, 2),
                'risk_level': random.choice(['low', 'medium', 'high']),
                'risk_probability': round(random.uniform(0, 1), 2)
            }
            progress_metrics.append(metrics)

    print(f"✅ Generated {len(progress_metrics)} weekly progress records")

    # 9. SAVE ALL TO CSV FILES
    print("\n💾 Saving all data to CSV files...")

    # Create output directory (backend/data/)
    output_dir = os.path.join(os.path.dirname(__file__), '..', 'data')
    os.makedirs(output_dir, exist_ok=True)

    # Save each dataset
    pd.DataFrame(users).to_csv(os.path.join(output_dir, 'users.csv'), index=False)
    pd.DataFrame(psychologists).to_csv(os.path.join(output_dir, 'psychologists.csv'), index=False)
    pd.DataFrame(journal_entries).to_csv(os.path.join(output_dir, 'journal_entries.csv'), index=False)
    pd.DataFrame(test_results).to_csv(os.path.join(output_dir, 'test_results.csv'), index=False)
    pd.DataFrame(game_telemetry).to_csv(os.path.join(output_dir, 'game_telemetry.csv'), index=False)
    pd.DataFrame(community_posts).to_csv(os.path.join(output_dir, 'community_posts.csv'), index=False)
    pd.DataFrame(community_comments).to_csv(os.path.join(output_dir, 'community_comments.csv'), index=False)
    pd.DataFrame(community_likes).to_csv(os.path.join(output_dir, 'community_likes.csv'), index=False)
    pd.DataFrame(activities).to_csv(os.path.join(output_dir, 'activities.csv'), index=False)
    pd.DataFrame(consultancy_bookings).to_csv(os.path.join(output_dir, 'consultancy_bookings.csv'), index=False)
    pd.DataFrame(progress_metrics).to_csv(os.path.join(output_dir, 'progress_metrics.csv'), index=False)

    print("\n✅ ALL DATA GENERATED SUCCESSFULLY!")
    print("\n📁 Files saved in 'backend/data/' folder:")
    print("   - users.csv")
    print("   - psychologists.csv")
    print("   - journal_entries.csv")
    print("   - test_results.csv")
    print("   - game_telemetry.csv")
    print("   - community_posts.csv")
    print("   - community_comments.csv")
    print("   - community_likes.csv")
    print("   - activities.csv")
    print("   - consultancy_bookings.csv")
    print("   - progress_metrics.csv")

if __name__ == "__main__":
    main()