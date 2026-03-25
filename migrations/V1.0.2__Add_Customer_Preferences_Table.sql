-- Create customer_preferences table for privacy and notification settings
CREATE TABLE customer_preferences (
    preference_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    privacy_level VARCHAR(20) NOT NULL DEFAULT 'private',
    email_notifications BOOLEAN NOT NULL DEFAULT true,
    data_retention_days INTEGER NOT NULL DEFAULT 365,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_customer_preferences_user
        FOREIGN KEY (customer_id) REFERENCES users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT chk_privacy_level
        CHECK (privacy_level IN ('public', 'private', 'restricted')),

    CONSTRAINT chk_data_retention_days
        CHECK (data_retention_days > 0 AND data_retention_days <= 2555),

    CONSTRAINT uk_customer_preferences_customer_id
        UNIQUE (customer_id)
);

CREATE INDEX idx_customer_preferences_customer_id ON customer_preferences(customer_id);
CREATE INDEX idx_customer_preferences_privacy_level ON customer_preferences(privacy_level);

CREATE OR REPLACE FUNCTION update_customer_preferences_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_customer_preferences_updated_at
    BEFORE UPDATE ON customer_preferences
    FOR EACH ROW
    EXECUTE FUNCTION update_customer_preferences_timestamp();

INSERT INTO customer_preferences (customer_id, privacy_level, email_notifications, data_retention_days)
SELECT user_id, 'private', true, 365
FROM users
WHERE user_id NOT IN (SELECT customer_id FROM customer_preferences);

COMMENT ON TABLE customer_preferences IS 'Stores customer privacy preferences and notification settings';
COMMENT ON COLUMN customer_preferences.privacy_level IS 'Customer data privacy level: public, private, or restricted';
COMMENT ON COLUMN customer_preferences.data_retention_days IS 'Number of days to retain customer data';
