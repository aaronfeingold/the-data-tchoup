-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create the database if it doesn't exist (this is handled by POSTGRES_DB env var)
-- But we can add any additional initialization here if needed
