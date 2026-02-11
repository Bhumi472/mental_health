from .. import User, OrganizationToken
from ..utils.security import hash_password, verify_password, create_jwt_token
from ..utils.validators import validate_email, validate_password, validate_username, validate_age
from datetime import datetime

class AuthService:
    @staticmethod
    def register_individual(user_data: dict, db):
        # Validate required fields
        required_fields = ['account_type', 'age_group', 'email', 'username', 'password', 
                          'first_name', 'last_name', 'date_of_birth', 'city', 'country']
        
        for field in required_fields:
            if field not in user_data or not user_data[field]:
                return None, f"Missing required field: {field}"
        
        # Check terms
        if not user_data.get('terms_accepted') or not user_data.get('privacy_accepted'):
            return None, "You must accept terms and conditions and privacy policy"
        
        # Validate email
        is_valid_email, email_error = validate_email(user_data['email'])
        if not is_valid_email:
            return None, email_error
        
        # Validate password
        is_valid_password, password_error = validate_password(user_data['password'])
        if not is_valid_password:
            return None, password_error
        
        # Validate username
        is_valid_username, username_error = validate_username(user_data['username'])
        if not is_valid_username:
            return None, username_error
        
        # Check if user exists
        existing_user = User.query.filter(
            (User.email == user_data['email']) | (User.username == user_data['username'])
        ).first()
        
        if existing_user:
            return None, "Email or username already exists"
        
        # Validate age
        dob = datetime.strptime(user_data['date_of_birth'], '%Y-%m-%d').date()
        is_valid_age, age_error = validate_age(dob, user_data['age_group'])
        if not is_valid_age:
            return None, age_error
        
        # Create user
        user = User(
            account_type=user_data['account_type'],
            age_group=user_data['age_group'],
            language=user_data.get('language', 'en'),
            username=user_data['username'],
            email=user_data['email'],
            password_hash=hash_password(user_data['password']),
            first_name=user_data['first_name'],
            last_name=user_data['last_name'],
            date_of_birth=dob,
            gender=user_data.get('gender'),
            profession=user_data.get('profession'),
            city=user_data['city'],
            country=user_data['country'],
            address=user_data.get('address'),
            terms_accepted=user_data['terms_accepted'],
            privacy_accepted=user_data['privacy_accepted']
        )
        
        db.session.add(user)
        db.session.commit()
        
        # Create JWT token
        token = create_jwt_token(user.id, user.username, user.account_type)
        
        return {
            'user': user.to_dict(),
            'token': token,
            'message': 'Registration successful'
        }, None
    
    @staticmethod
    def register_organization(user_data: dict, db):
        # Validate required fields
        required_fields = ['account_type', 'age_group', 'email', 'username', 'password',
                          'organization_token', 'organization_name']
        
        for field in required_fields:
            if field not in user_data or not user_data[field]:
                return None, f"Missing required field: {field}"
        
        # Check terms
        if not user_data.get('terms_accepted') or not user_data.get('privacy_accepted'):
            return None, "You must accept terms and conditions and privacy policy"
        
        # Validate organization token
        token_record = OrganizationToken.query.filter_by(
            token=user_data['organization_token'],
            account_type=user_data['account_type'],
            is_active=True
        ).first()
        
        if not token_record:
            return None, "Invalid or expired organization token"
        
        if token_record.expires_at and token_record.expires_at < datetime.utcnow():
            return None, "Organization token has expired"
        
        if token_record.current_members >= token_record.max_members:
            return None, "Maximum number of members reached"
        
        # Validate email and username
        is_valid_email, email_error = validate_email(user_data['email'])
        if not is_valid_email:
            return None, email_error
        
        is_valid_username, username_error = validate_username(user_data['username'])
        if not is_valid_username:
            return None, username_error
        
        # Check if user exists
        existing_user = User.query.filter(
            (User.email == user_data['email']) | (User.username == user_data['username'])
        ).first()
        
        if existing_user:
            return None, "Email or username already exists"
        
        # Create user
        user = User(
            account_type=user_data['account_type'],
            age_group=user_data['age_group'],
            organization_token=user_data['organization_token'],
            language=user_data.get('language', 'en'),
            username=user_data['username'],
            email=user_data['email'],
            password_hash=hash_password(user_data['password']),
            organization_name=user_data['organization_name'],
            terms_accepted=user_data['terms_accepted'],
            privacy_accepted=user_data['privacy_accepted']
        )
        
        # Update token member count
        token_record.current_members += 1
        
        db.session.add(user)
        db.session.add(token_record)
        db.session.commit()
        
        # Create JWT token
        token = create_jwt_token(user.id, user.username, user.account_type)
        
        return {
            'user': user.to_dict(),
            'token': token,
            'message': 'Registration successful'
        }, None
    
    @staticmethod
    def login(username_or_email: str, password: str):
        # Find user by email or username
        user = User.query.filter(
            (User.email == username_or_email) | (User.username == username_or_email)
        ).first()
        
        if not user:
            return None, "Invalid credentials"
        
        if not user.is_active:
            return None, "Account is deactivated"
        
        if not verify_password(user.password_hash, password):
            return None, "Invalid credentials"
        
        # Create JWT token
        token = create_jwt_token(user.id, user.username, user.account_type)
        
        return {
            'user': user.to_dict(),
            'token': token,
            'message': 'Login successful'
        }, None