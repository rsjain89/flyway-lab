-- Wrapper migration to execute provided starter script

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
    COALESCE(SUM(CASE WHEN t.transaction_type = 'withdrawal' THEN t.amount ELSE 0 END), 0.00) AS total_withdrawals
FROM users u
LEFT JOIN customer_preferences cp ON u.user_id = cp.customer_id
LEFT JOIN accounts a ON u.user_id = a.user_id
LEFT JOIN transactions t ON a.account_id = t.account_id
GROUP BY COALESCE(cp.privacy_level, 'not_set');
