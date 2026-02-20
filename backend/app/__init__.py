from flask import Flask
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from .config import Config

db = SQLAlchemy()
jwt = JWTManager()

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    # Initialize extensions
    db.init_app(app)
    jwt.init_app(app)
    CORS(app, resources={r"/*": {"origins": "*"}}, expose_headers=["Authorization"], allow_headers=["*"])
    
    # Register blueprints
    from app.routes.auth import auth_bp
    from app.routes.assessment import assessment_bp
    from app.routes.mood import mood_bp
    from app.routes.group import group_bp
    from app.routes.community_routes import community_bp
    from app.routes.popslash import popslash_bp
    from app.routes.memorylane import memorylane_bp

    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(assessment_bp, url_prefix='/api/assessment')
    app.register_blueprint(mood_bp, url_prefix='/api/mood')
    app.register_blueprint(group_bp, url_prefix='/api/group')
    app.register_blueprint(community_bp, url_prefix='/api/community')
    app.register_blueprint(popslash_bp, url_prefix='/api/games/popslash')
    app.register_blueprint(memorylane_bp, url_prefix='/api/games/memorylane')
    
    @app.route('/')
    def index():
        return {'message': 'Mental Health Flask API', 'status': 'running'}
    
    @app.route('/health')
    def health():
        return {'status': 'healthy'}
    
    return app