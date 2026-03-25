-- =====================================================
-- Course: Level Up: Advanced SQL for Data Engineering
-- Module 1: CI/CD Database Deployments - Foundation
-- Lab: Building Automated Database Migration Pipelines with Flyway
-- =====================================================

-- PROVIDED CODE - DO NOT MODIFY --
-- Base schema for customer management system
-- This represents your current database state (version 1.0.1)

-- Existing users table structure
/*
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active'
);
*/

-- Existing accounts table structure  
/*
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    user_id INT,
    account_number VARCHAR(20) UNIQUE NOT NULL,
    balance DECIMAL(15,2) DEFAULT 0.00,
    account_type VARCHAR(20) DEFAULT 'checking',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
*/

-- PROVIDED PIPELINE CONFIGURATION TEMPLATE - DO NOT MODIFY --
/*
CI/CD Pipeline Structure:
Stage 1: Validation
  - flyway validate
  - syntax checking
  - baseline verification

Stage 2: Staging Deployment  
  - flyway info
  - flyway migrate (staging)
  - integration testing

Stage 3: Production Deployment
  - manual approval
  - flyway migrate (production)
  - post-deployment verification
*/

-- =====================================================
-- PRACTICE CHALLENGES - COMPLETE THE FOLLOWING
-- =====================================================

### PRACTICE CHALLENGE 1 ###
-- TASK: Write a complete Flyway migration script (V1.0.2__Add_Customer_Privacy_Features.sql) 
-- that creates a customer_preferences table with columns: customer_id (INT, FK), 
-- privacy_level (VARCHAR(20)), email_notifications (BOOLEAN), data_retention_days (INT), 
-- and adds a privacy_settings (JSON) column to the existing users table.
-- YOUR CODE HERE

-- Migration script filename: V1.0.2__Add_Customer_Privacy_Features.sql
-- Remember: Proper Flyway naming convention is critical for version control




### PRACTICE CHALLENGE 2 ###
-- TASK: Create a CI/CD pipeline configuration (YAML format) that includes three stages: 
-- 1) Migration validation using flyway validate, 2) Staging deployment using flyway migrate, 
-- and 3) Production deployment with manual approval gate.
-- YOUR CODE HERE

-- Pipeline Configuration (YAML format)
-- Include environment-specific database connections
-- Add error handling for failed migrations




### PRACTICE CHALLENGE 3 ###
-- TASK: Implement a complete deployment monitoring system that logs migration execution details,
-- sends notifications on success/failure, and provides a rollback mechanism if production deployment fails.
-- YOUR CODE HERE

-- Monitoring and Logging Configuration
-- Include Flyway callback implementations
-- Add notification system integration




-- =====================================================
-- TESTING UTILITIES - PROVIDED CODE - DO NOT MODIFY
-- =====================================================

-- Test validation command
-- flyway validate -configFiles=flyway.conf

-- Test staging deployment  
-- flyway migrate -configFiles=flyway-staging.conf

-- Check migration status
-- flyway info -configFiles=flyway.conf

-- Verify schema state
/*
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'your_database_name'
ORDER BY table_name, ordinal_position;
*/

