-- This test FAILS (returns rows) if any startup has negative funding.
-- dbt treats any rows returned by a test as a failure.
SELECT
    company_name,
    total_funding_usd
FROM {{ ref('stg_startups') }}
WHERE total_funding_usd < 0