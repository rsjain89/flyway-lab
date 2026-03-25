DROP VIEW IF EXISTS user_statistics_view;

CREATE OR REPLACE VIEW user_statistics_view AS
SELECT
    COALESCE(cp.privacy_level, 'not_set') AS privacy_level,
    COUNT(DISTINCT u.user_id) AS user_count,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    COALESCE(AVG(a.balance), 0.00) AS avg_account_balance,
    COALESCE(SUM(a.balance), 0.00) AS total_balance,
    COUNT(t.transaction_id) AS total_transactions,
    COALESCE(AVG(t.amount), 0.00) AS avg_transaction_amount,
    COALESCE(SUM(CASE WHEN t.transaction_type = 'deposit' THEN t.amount ELSE 0 END), 0.00) AS total_deposits,
    COALESCE(SUM(CASE WHEN t.transaction_type = 'withdrawal' THEN t.amount ELSE 0 END), 0.00) AS total_withdrawals,
    COUNT(CASE WHEN u.status = 'active' THEN 1 END) AS active_users,
    COUNT(CASE WHEN u.status = 'inactive' THEN 1 END) AS inactive_users,
    COUNT(CASE WHEN u.status = 'suspended' THEN 1 END) AS suspended_users,
    COUNT(CASE WHEN u.privacy_settings::jsonb->>'marketing_emails' = 'true' THEN 1 END) AS marketing_email_enabled,
    COUNT(CASE WHEN u.privacy_settings::jsonb->>'data_sharing' = 'true' THEN 1 END) AS data_sharing_enabled,
    COUNT(CASE WHEN cp.email_notifications = true THEN 1 END) AS email_notifications_enabled,
    AVG(cp.data_retention_days) AS avg_data_retention_days,
    MIN(cp.data_retention_days) AS min_data_retention_days,
    MAX(cp.data_retention_days) AS max_data_retention_days,
    MIN(u.created_at) AS earliest_user_registration,
    MAX(u.created_at) AS latest_user_registration,
    MAX(t.transaction_date) AS latest_transaction_date,
    COUNT(CASE WHEN a.account_type = 'checking' THEN 1 END) AS checking_accounts,
    COUNT(CASE WHEN a.account_type = 'savings' THEN 1 END) AS savings_accounts,
    COUNT(CASE WHEN a.account_type = 'investment' THEN 1 END) AS investment_accounts
FROM users u
LEFT JOIN customer_preferences cp ON u.user_id = cp.customer_id
LEFT JOIN accounts a ON u.user_id = a.user_id
LEFT JOIN transactions t ON a.account_id = t.account_id
GROUP BY COALESCE(cp.privacy_level, 'not_set')
ORDER BY user_count DESC;

CREATE OR REPLACE VIEW user_statistics_summary AS
SELECT
    COUNT(DISTINCT u.user_id) AS total_users,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(a.balance) AS total_platform_balance,
    ROUND((COUNT(CASE WHEN cp.privacy_level = 'private' THEN 1 END) * 100.0 / COUNT(DISTINCT u.user_id))::numeric, 2) AS private_users_percentage,
    ROUND((COUNT(CASE WHEN cp.email_notifications = true THEN 1 END) * 100.0 / COUNT(DISTINCT u.user_id))::numeric, 2) AS email_opt_in_percentage,
    COUNT(CASE WHEN t.transaction_date >= CURRENT_DATE - INTERVAL '30 days' THEN 1 END) AS transactions_last_30_days,
    COUNT(DISTINCT CASE WHEN t.transaction_date >= CURRENT_DATE - INTERVAL '30 days' THEN u.user_id END) AS active_users_last_30_days,
    CURRENT_TIMESTAMP AS statistics_generated_at
FROM users u
LEFT JOIN customer_preferences cp ON u.user_id = cp.customer_id
LEFT JOIN accounts a ON u.user_id = a.user_id
LEFT JOIN transactions t ON a.account_id = t.account_id;

COMMENT ON VIEW user_statistics_view IS 'Detailed user statistics segmented by privacy level';
COMMENT ON VIEW user_statistics_summary IS 'High-level platform statistics for executive dashboard';
