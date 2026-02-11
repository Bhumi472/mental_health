try:
    from app import create_app, db
except ImportError:
    from backend.app import create_app, db

app = create_app()

# Create tables
with app.app_context():
    db.create_all()

if __name__ == '__main__':
    import os
    port = int(os.environ.get('PORT', 8000))
    app.run(
        host='0.0.0.0',
        port=port,
        debug=False
    )