-- =========================================================
-- Irish Residential Property Price Register — Analytical Queries
-- =========================================================
-- Uses property_sales_enriched (see schema.sql), which standardises the
-- New/Second-Hand flag and flags likely bulk/portfolio sales (>= €5m,
-- e.g. entire apartment blocks recorded as a single "sale") that would
-- otherwise distort typical-price analysis.

USE ppr_ireland;

-- ---------------------------------------------------------
-- 1. Median price by county, most recent full year, excluding bulk sales
--    (median is used instead of mean because property prices are
--    right-skewed; a handful of high-value sales pull the mean up —
--    note the Dublin gap between mean and median below)
-- ---------------------------------------------------------
WITH ranked AS (
    SELECT county, price,
        ROW_NUMBER() OVER (PARTITION BY county ORDER BY price) AS rn,
        COUNT(*) OVER (PARTITION BY county) AS cnt
    FROM property_sales_enriched
    WHERE sale_year = 2025 AND likely_bulk_sale = 0
),
medians AS (
    SELECT county, AVG(price) AS median_price
    FROM ranked
    WHERE rn IN (FLOOR((cnt + 1) / 2), CEIL((cnt + 1) / 2))
    GROUP BY county
),
stats AS (
    SELECT county, COUNT(*) AS sales_count, ROUND(AVG(price), 0) AS mean_price
    FROM property_sales_enriched
    WHERE sale_year = 2025 AND likely_bulk_sale = 0
    GROUP BY county
)
SELECT s.county, s.sales_count, s.mean_price, ROUND(m.median_price, 0) AS median_price
FROM stats s JOIN medians m ON s.county = m.county
ORDER BY median_price DESC;


-- ---------------------------------------------------------
-- 2. Year-over-year price growth, national, 2011–2025
-- ---------------------------------------------------------
SELECT
    sale_year,
    ROUND(AVG(price), 0) AS avg_price,
    ROUND(
        100 * (AVG(price) - LAG(AVG(price)) OVER (ORDER BY sale_year))
        / LAG(AVG(price)) OVER (ORDER BY sale_year), 1
    ) AS yoy_growth_pct
FROM property_sales_enriched
WHERE likely_bulk_sale = 0
  AND sale_year BETWEEN 2011 AND 2025
GROUP BY sale_year
ORDER BY sale_year;


-- ---------------------------------------------------------
-- 3. New vs. Second-Hand price premium by year
-- ---------------------------------------------------------
SELECT
    sale_year,
    ROUND(AVG(CASE WHEN property_type = 'New' THEN price END), 0) AS avg_new_price,
    ROUND(AVG(CASE WHEN property_type = 'Second-Hand' THEN price END), 0) AS avg_second_hand_price,
    ROUND(
        100 * (
            AVG(CASE WHEN property_type = 'New' THEN price END)
            - AVG(CASE WHEN property_type = 'Second-Hand' THEN price END)
        ) / AVG(CASE WHEN property_type = 'Second-Hand' THEN price END), 1
    ) AS new_build_premium_pct
FROM property_sales_enriched
WHERE likely_bulk_sale = 0
  AND sale_year BETWEEN 2015 AND 2025
GROUP BY sale_year
ORDER BY sale_year;


-- ---------------------------------------------------------
-- 4. Top 10 most active postcodes/areas by transaction volume, 2025
--    (parses the Dublin postal district out of the address where present)
-- ---------------------------------------------------------
SELECT
    TRIM(SUBSTRING_INDEX(address, ',', -1)) AS area,
    COUNT(*) AS transactions,
    ROUND(AVG(price), 0) AS avg_price
FROM property_sales_enriched
WHERE county = 'Dublin'
  AND sale_year = 2025
  AND likely_bulk_sale = 0
GROUP BY area
HAVING transactions >= 20
ORDER BY transactions DESC
LIMIT 10;


-- ---------------------------------------------------------
-- 5. Quarterly price trend with a 4-quarter rolling average, national
-- ---------------------------------------------------------
SELECT
    sale_year,
    sale_quarter,
    ROUND(AVG(price), 0) AS avg_price,
    ROUND(
        AVG(AVG(price)) OVER (
            ORDER BY sale_year, sale_quarter
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
        ), 0
    ) AS rolling_4q_avg
FROM property_sales_enriched
WHERE likely_bulk_sale = 0
GROUP BY sale_year, sale_quarter
ORDER BY sale_year, sale_quarter;


-- ---------------------------------------------------------
-- 6. Counties where prices grew fastest, 2020 vs 2025 (pandemic-era shift)
-- ---------------------------------------------------------
SELECT
    county,
    ROUND(AVG(CASE WHEN sale_year = 2020 THEN price END), 0) AS avg_2020,
    ROUND(AVG(CASE WHEN sale_year = 2025 THEN price END), 0) AS avg_2025,
    ROUND(
        100 * (
            AVG(CASE WHEN sale_year = 2025 THEN price END)
            - AVG(CASE WHEN sale_year = 2020 THEN price END)
        ) / AVG(CASE WHEN sale_year = 2020 THEN price END), 1
    ) AS pct_change
FROM property_sales_enriched
WHERE likely_bulk_sale = 0
  AND sale_year IN (2020, 2025)
GROUP BY county
ORDER BY pct_change DESC;
