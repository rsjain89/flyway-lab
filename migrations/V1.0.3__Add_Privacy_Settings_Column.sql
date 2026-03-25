-- Step 1: Add the privacy_settings column as nullable first
ALTER TABLE users ADD COLUMN privacy_settings TEXT;

-- Step 2: Add CHECK constraint to validate JSON format
ALTER TABLE users
ADD CONSTRAINT chk_users_privacy_settings_json
CHECK (privacy_settings IS NULL OR (privacy_settings::json IS NOT NULL));

-- Step 3: Set default privacy settings for existing users
UPDATE users
SET privacy_settings = jsonb_build_object(
    'data_sharing', false,
    'marketing_emails', true,
    'analytics', false,
    'third_party_cookies', false,
    'location_tracking', false,
    'profile_visibility', 'private',
    'last_updated', CURRENT_TIMESTAMP
)::text
WHERE privacy_settings IS NULL;

-- Step 4: Create index for JSON queries
CREATE INDEX idx_users_privacy_settings_gin ON users USING gin ((privacy_settings::jsonb));

-- Step 5: Create helper function for privacy settings validation
CREATE OR REPLACE FUNCTION validate_privacy_settings(settings TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    IF settings IS NULL THEN RETURN TRUE; END IF;
    PERFORM settings::json;
    IF NOT (settings::jsonb ? 'data_sharing' AND settings::jsonb ? 'marketing_emails') THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- Step 6: Add constraint using validation function
ALTER TABLE users
ADD CONSTRAINT chk_users_privacy_settings_structure
CHECK (validate_privacy_settings(privacy_settings));

COMMENT ON COLUMN users.privacy_settings IS 'JSON-formatted privacy configuration settings';

-- Step 7: Create helper function for updating individual settings
CREATE OR REPLACE FUNCTION update_user_privacy_setting(
    p_user_id INTEGER, p_setting_key TEXT, p_setting_value TEXT
) RETURNS VOID AS $$
BEGIN
    UPDATE users
    SET privacy_settings = jsonb_set(
        COALESCE(privacy_settings::jsonb, '{}'::jsonb),
        ARRAY[p_setting_key],
        to_jsonb(p_setting_value)
    )::text
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

/*
ROLLBACK INSTRUCTIONS:
-- 1. ALTER TABLE users DROP CONSTRAINT chk_users_privacy_settings_structure;
-- 2. DROP FUNCTION validate_privacy_settings(TEXT);
-- 3. DROP INDEX idx_users_privacy_settings_gin;
-- 4. ALTER TABLE users DROP CONSTRAINT chk_users_privacy_settings_json;
-- 5. ALTER TABLE users DROP COLUMN privacy_settings;
-- 6. DROP FUNCTION update_user_privacy_setting(INTEGER, TEXT, TEXT);
*/
