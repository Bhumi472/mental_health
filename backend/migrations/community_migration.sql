-- Users table - COMPLETE with all fields
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY,
    username VARCHAR(80) UNIQUE NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(200) NOT NULL,
    
    -- ADD ALL THESE MISSING COLUMNS
    account_type VARCHAR(20) DEFAULT 'individual',
    age_group VARCHAR(20) DEFAULT 'over_18',
    language VARCHAR(10) DEFAULT 'en',
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    gender VARCHAR(20),
    profession VARCHAR(100),
    city VARCHAR(100),
    country VARCHAR(100),
    address VARCHAR(200),
    organization_name VARCHAR(100),
    organization_token VARCHAR(100),
    terms_accepted BOOLEAN DEFAULT FALSE,
    privacy_accepted BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ... rest of your community tables (keep everything else the same)