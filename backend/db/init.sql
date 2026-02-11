-- Connect to the database
\c mental_health_app;

-- Create tables
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY,
    account_type VARCHAR(20) NOT NULL CHECK (account_type IN ('individual', 'organization', 'family')),
    age_group VARCHAR(10) NOT NULL CHECK (age_group IN ('under_18', 'over_18')),
    organization_token VARCHAR(100),
    language VARCHAR(10) DEFAULT 'en',
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    date_of_birth DATE,
    gender VARCHAR(20),
    profession VARCHAR(100),
    city VARCHAR(100),
    country VARCHAR(100),
    address TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    terms_accepted BOOLEAN DEFAULT FALSE,
    privacy_accepted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    organization_name VARCHAR(200),
    family_name VARCHAR(200),
    member_count INTEGER DEFAULT 1
);

CREATE TABLE IF NOT EXISTS organization_tokens (
    id VARCHAR(36) PRIMARY KEY,
    token VARCHAR(100) UNIQUE NOT NULL,
    account_type VARCHAR(20) NOT NULL CHECK (account_type IN ('organization', 'family')),
    created_by VARCHAR(36),
    organization_name VARCHAR(200) NOT NULL,
    max_members INTEGER DEFAULT 10,
    current_members INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_org_tokens_token ON organization_tokens(token);

-- Insert sample tokens for testing
INSERT INTO organization_tokens (id, token, account_type, organization_name, max_members, is_active) 
VALUES 
    ('org-token-1', 'ORG1234567890', 'organization', 'Test Organization', 50, true),
    ('family-token-1', 'FAM1234567890', 'family', 'Test Family', 20, true)
ON CONFLICT (token) DO NOTHING;