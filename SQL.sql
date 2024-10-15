# Задача 1
WITH monthly_transactions AS (
    SELECT 
        ID_client,
        DATE_FORMAT(date_new, '%Y-%m-01') AS transaction_month,
        COUNT(Id_check) AS transaction_count
    FROM transactions_info
    WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY ID_client, transaction_month
),
clients_full_year AS (
    SELECT 
        ID_client
    FROM monthly_transactions
    GROUP BY ID_client
    HAVING COUNT(DISTINCT transaction_month) = 12
)
SELECT 
    c.ID_client,
    AVG(t.Sum_payment) AS avg_check,
    SUM(t.Sum_payment) / 12 AS monthly_avg_sum,
    COUNT(t.Id_check) AS total_operations
FROM transactions_info t
JOIN clients_full_year c ON t.ID_client = c.ID_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY c.ID_client;

# Задача 2
WITH monthly_summary AS (
    SELECT 
        DATE_FORMAT(date_new, '%Y-%m-01') AS transaction_month,
        AVG(Sum_payment) AS avg_monthly_check,
        COUNT(Id_check) AS monthly_transaction_count,
        COUNT(DISTINCT ID_client) AS unique_clients,
        SUM(Sum_payment) AS total_sum
    FROM transactions_info
    WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY transaction_month
),
total_summary AS (
    SELECT 
        SUM(monthly_transaction_count) AS total_transactions_year,
        SUM(total_sum) AS total_sum_year
    FROM monthly_summary
)
SELECT 
    m.transaction_month,
    m.avg_monthly_check,
    m.monthly_transaction_count,
    m.unique_clients,
    m.total_sum,
    m.monthly_transaction_count / t.total_transactions_year AS transaction_share,
    m.total_sum / t.total_sum_year AS sum_share
FROM monthly_summary m, total_summary t;

# Задача 2: Соотношение M/F/NA по месяцам и доля затрат
WITH gender_summary AS (
    SELECT 
        DATE_FORMAT(date_new, '%Y-%m-01') AS transaction_month,
        c.Gender,
        COUNT(t.Id_check) AS gender_transaction_count,
        SUM(t.Sum_payment) AS gender_sum
    FROM transactions_info t
    JOIN customer_info c ON t.ID_client = c.Id_client
    WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY transaction_month, c.Gender
),
monthly_totals AS (
    SELECT 
        transaction_month,
        SUM(gender_transaction_count) AS total_transactions,
        SUM(gender_sum) AS total_sum
    FROM gender_summary
    GROUP BY transaction_month
)
SELECT 
    g.transaction_month,
    g.Gender,
    g.gender_transaction_count,
    g.gender_sum,
    g.gender_transaction_count / m.total_transactions AS transaction_percentage,
    g.gender_sum / m.total_sum AS sum_percentage
FROM gender_summary g
JOIN monthly_totals m ON g.transaction_month = m.transaction_month;

# Задача 3: Возрастные группы с шагом 10 лет.
WITH age_groups AS (
    SELECT 
        Id_client,
        CASE 
            WHEN Age < 20 THEN '<20'
            WHEN Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN Age BETWEEN 60 AND 69 THEN '60-69'
            WHEN Age BETWEEN 70 AND 79 THEN '70-79'
            WHEN Age BETWEEN 80 AND 89 THEN '80-89'
            ELSE '90+'
        END AS AgeGroup
    FROM customer_info
)
SELECT 
    a.AgeGroup,
    SUM(t.Sum_payment) AS total_sum,
    COUNT(t.Id_check) AS transaction_count
FROM transactions_info t
JOIN age_groups a ON t.ID_client = a.Id_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY 1
ORDER BY 1;

# Задача 3: Поквартальные показатели по возрастным группам.
WITH age_groups AS (
    SELECT 
        Id_client,
        CASE 
            WHEN Age < 20 THEN '<20'
            WHEN Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN Age BETWEEN 60 AND 69 THEN '60-69'
            WHEN Age BETWEEN 70 AND 79 THEN '70-79'
            WHEN Age BETWEEN 80 AND 89 THEN '80-89'
            ELSE '90+'
        END AS AgeGroup
    FROM customer_info
), quarterly_summary AS (
    SELECT 
        CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new)) AS transaction_quarter,
        a.AgeGroup,
        AVG(t.Sum_payment) AS avg_sum_per_quarter,
        COUNT(t.Id_check) AS avg_transaction_count_per_quarter
    FROM transactions_info t
    JOIN age_groups a ON t.ID_client = a.Id_client
    WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY transaction_quarter, a.AgeGroup
)
SELECT * FROM quarterly_summary
ORDER BY quarterly_summary.transaction_quarter;

