
     COUNT(*) AS TOTAL_ROW,
     COUNT(DISTINCT company_name) AS UNIQUE_COMPANIES,
     COUNT(DISTINCT COUNTRY) AS COUNTRIES,
     COUNT(DISTINCT primary_category) AS PRIMARY_CATEGORIES,
     MIN(founded_year) AS EARLIEST_FOUNDED,
     MAX(founded_year) AS LATEST_FOUNDED
 FROM `venturescope-warehouse`.venturescopoe.startups_raw

 SELECT
     OUTCOME,
     COUNT(*) AS COUNT,
     ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS PERCENTAGE
 FROM `venturescope-warehouse`.venturescopoe.startups_raw
 WHERE outcome IS NOT NULL
 GROUP BY OUTCOME
 ORDER BY COUNT DESC