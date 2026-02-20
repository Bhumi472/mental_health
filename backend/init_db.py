import os
from app import create_app, db
from app.models.user import User
from app.models.organization_token import OrganizationToken
from app.models.community_models import *
from werkzeug.security import generate_password_hash
from app.models.popslash_session import PopSlashSession
from app.models.memorylane_session import MemoryLaneSession

def init_database():
    """Initialize the database with tables"""
    
    app = create_app()
    
    with app.app_context():
        # Create all tables - let SQLAlchemy do it, NOT the migration file
        db.create_all()
        print("✅ Database tables created successfully!")
        
        # Create test user
        if User.query.count() == 0:
            test_user = User(
                username='testuser',
                email='test@example.com',
                password_hash=generate_password_hash('password123'),
                account_type='individual',
                age_group='over_18',
                first_name='Test',
                last_name='User',
                terms_accepted=True,
                privacy_accepted=True,
                is_active=True
            )
            db.session.add(test_user)
            db.session.commit()
            print("✅ Test user created!")
            print("   Email: test@example.com")
            print("   Password: password123")

if __name__ == '__main__':
    init_database()