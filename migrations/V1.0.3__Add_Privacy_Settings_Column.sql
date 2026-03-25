-- TASK: Add privacy_settings column to the users table:
-- - Column type: TEXT (for JSON data storage)
-- - Add CHECK constraint to validate JSON format
-- - Set default value for existing users: '{"data_sharing": false, "marketing_emails": true, "analytics": false}'
-- - Update existing users with the default privacy settings
-- - Include rollback instructions as comments

-- YOUR CODE HERE
