import re
from datetime import datetime
from email_validator import validate_email as validate_email_format, EmailNotValidError

def validate_email(email: str) -> tuple[bool, str]:
    try:
        validate_email_format(email)
        return True, ""
    except EmailNotValidError as e:
        return False, str(e)

def validate_password(password: str) -> tuple[bool, str]:
    if len(password) < 8:
        return False, "Password must be at least 8 characters"
    if not re.search(r'[A-Z]', password):
        return False, "Password must contain at least one uppercase letter"
    if not re.search(r'[a-z]', password):
        return False, "Password must contain at least one lowercase letter"
    if not re.search(r'\d', password):
        return False, "Password must contain at least one digit"
    return True, ""

def validate_username(username: str) -> tuple[bool, str]:
    if len(username) < 3:
        return False, "Username must be at least 3 characters"
    if len(username) > 50:
        return False, "Username must be less than 50 characters"
    if not re.match(r'^[a-zA-Z0-9_.-]+$', username):
        return False, "Username can only contain letters, numbers, dots, hyphens and underscores"
    return True, ""

def validate_age(date_of_birth: datetime, age_group: str) -> tuple[bool, str]:
    today = datetime.now()
    age = today.year - date_of_birth.year
    if today.month < date_of_birth.month or (today.month == date_of_birth.month and today.day < date_of_birth.day):
        age -= 1
    
    if age_group == 'under_18' and age >= 18:
        return False, "Age must be under 18 for this age group"
    elif age_group == 'over_18' and age < 18:
        return False, "Age must be 18 or over for this age group"
    
    return True, ""