-- investor_power_index.sql
-- How does investor tier (size of VC raised) correlate with startup outcomes?
-- Answers: "Does bigger money mean better odds of success?"
WITH outcomes AS (
    SELECT * FROM {{ ref('startup_outcomes') }}
),
by_tier AS (
    SELECT
        investor_tier,
        COUNT(*) AS startups,
        ROUND(AVG(is_successful_exit) * 100, 1) AS success_rate_pct,
        ROUND(AVG(is_ipo) * 100, 1) AS ipo_rate_pct,
        ROUND(AVG(is_acquired) * 100, 1) AS acquired_rate_pct,
        ROUND(AVG(is_closed) * 100, 1) AS closure_rate_pct,
        ROUND(AVG(total_funding_usd) / 1e6, 1) AS avg_total_funding_m,
        ROUND(AVG(funding_rounds), 1) AS avg_rounds,
        ROUND(AVG(funding_efficiency), 2) AS avg_funding_efficiency,
        -- What % reached Series B or higher?
        ROUND(AVG(CAST(reached_series_b AS INT)) * 100, 1)
        AS pct_reached_series_b
    FROM outcomes
    WHERE investor_tier != 'No VC'
    GROUP BY investor_tier
)
SELECT
    investor_tier,
    startups,
    success_rate_pct,
    ipo_rate_pct,
    acquired_rate_pct,
    closure_rate_pct,
    avg_total_funding_m,
    avg_rounds,
    avg_funding_efficiency,
    pct_reached_series_b,
    -- Rank tiers by success rate
    RANK() OVER (ORDER BY success_rate_pct DESC) AS success_rank
FROM by_tier
ORDER BY success_rank