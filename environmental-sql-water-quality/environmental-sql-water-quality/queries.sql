-- === ANALYSIS QUERIES ===

-- 1) Row counts (sanity check)
SELECT 'sites' AS tbl, COUNT(*) n FROM sites
UNION ALL SELECT 'analytes', COUNT(*) FROM analytes
UNION ALL SELECT 'samples',  COUNT(*) FROM samples
UNION ALL SELECT 'results',  COUNT(*) FROM results;

-- 2) Joined, human-readable results
SELECT s.sample_dt, si.site_name, a.analyte_name, r.result_val, a.unit, r.qualifier
FROM results r
JOIN samples s  ON r.sample_id = s.sample_id
JOIN sites   si ON s.site_id   = si.site_id
JOIN analytes a ON r.analyte_id = a.analyte_id
ORDER BY s.sample_dt, si.site_name, a.analyte_name;

-- 3) Average by analyte and site
SELECT a.analyte_name, si.site_name,
       ROUND(AVG(r.result_val), 3) AS avg_value
FROM results r
JOIN samples s  ON r.sample_id = s.sample_id
JOIN sites   si ON s.site_id   = si.site_id
JOIN analytes a ON r.analyte_id = a.analyte_id
GROUP BY a.analyte_name, si.site_name
ORDER BY a.analyte_name, avg_value DESC;

-- 4) Daily creek-wide average for Nitrate
SELECT s.sample_dt, ROUND(AVG(r.result_val), 3) AS avg_nitrate_mgL
FROM results r
JOIN samples s  ON r.sample_id = s.sample_id
JOIN analytes a ON r.analyte_id = a.analyte_id
WHERE a.analyte_name = 'Nitrate as N'
GROUP BY s.sample_dt
ORDER BY s.sample_dt;

-- 5) Exceedance flags (illustrative thresholds)
SELECT s.sample_dt, si.site_name, a.analyte_name, r.result_val, a.unit,
       CASE
         WHEN a.analyte_name = 'E. coli' AND r.result_val > 410           THEN 'EXCEEDS'
         WHEN a.analyte_name = 'Total Phosphorus' AND r.result_val > 0.03 THEN 'EXCEEDS'
         ELSE 'OK'
       END AS status
FROM results r
JOIN samples s  ON r.sample_id = s.sample_id
JOIN sites   si ON s.site_id   = si.site_id
JOIN analytes a ON r.analyte_id = a.analyte_id
WHERE a.analyte_name IN ('E. coli','Total Phosphorus')
ORDER BY s.sample_dt, si.site_name, a.analyte_name;

-- 6) Pivot-style summary for a single date
-- Change the date as needed
SELECT si.site_name,
       ROUND(AVG(CASE WHEN a.analyte_name='Nitrate as N'     THEN r.result_val END),3) AS nitrate_mgL,
       ROUND(AVG(CASE WHEN a.analyte_name='Total Phosphorus' THEN r.result_val END),3) AS tp_mgL,
       ROUND(AVG(CASE WHEN a.analyte_name='E. coli'          THEN r.result_val END),3) AS ecoli_cfu_100mL
FROM results r
JOIN samples s  ON r.sample_id = s.sample_id
JOIN sites   si ON s.site_id   = si.site_id
JOIN analytes a ON r.analyte_id = a.analyte_id
WHERE s.sample_dt = '2025-09-15'
GROUP BY si.site_name
ORDER BY si.site_name;

-- 7) Upstream vs. downstream after rain
SELECT si.site_name, r.result_val AS nitrate_mgL
FROM results r
JOIN samples s  ON r.sample_id = s.sample_id
JOIN sites   si ON s.site_id   = si.site_id
JOIN analytes a ON r.analyte_id = a.analyte_id
WHERE a.analyte_name='Nitrate as N'
  AND s.sample_dt='2025-09-15'
ORDER BY r.result_val DESC;

-- 8) Qualifier counts
SELECT COALESCE(r.qualifier,'(none)') AS qualifier, COUNT(*) AS n
FROM results r
GROUP BY COALESCE(r.qualifier,'(none)')
ORDER BY n DESC;

-- 9) Latest sample per site (CTE pattern)
WITH latest AS (
  SELECT site_id, MAX(sample_dt) AS max_dt
  FROM samples
  GROUP BY site_id
)
SELECT si.site_name, s.sample_dt, a.analyte_name, r.result_val, a.unit
FROM latest L
JOIN samples s  ON s.site_id = L.site_id AND s.sample_dt = L.max_dt
JOIN results r  ON r.sample_id = s.sample_id
JOIN analytes a ON a.analyte_id = r.analyte_id
JOIN sites si   ON si.site_id = s.site_id
ORDER BY si.site_name, a.analyte_name;
