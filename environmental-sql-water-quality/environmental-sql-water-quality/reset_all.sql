/* ======================
   WATER QUALITY DEMO DB
   Clean reset + seed
   ====================== */

-- 0) RESET (drop objects if they exist, in dependency-safe order)
DROP VIEW  IF EXISTS vw_results_long;
DROP TABLE IF EXISTS results;
DROP TABLE IF EXISTS samples;
DROP TABLE IF EXISTS sites;
DROP TABLE IF EXISTS analytes;

-- 1) SCHEMA

-- 1a) Sampling locations
CREATE TABLE sites (
  site_id       INTEGER PRIMARY KEY,
  site_name     TEXT NOT NULL,
  latitude      REAL,
  longitude     REAL,
  water_body    TEXT,      -- e.g., creek name
  region        TEXT       -- e.g., county/basin
);

-- 1b) Analyte dictionary
CREATE TABLE analytes (
  analyte_id    INTEGER PRIMARY KEY,
  analyte_name  TEXT NOT NULL,   -- e.g., Nitrate as N
  unit          TEXT NOT NULL,   -- e.g., mg/L, CFU/100mL
  rl            REAL             -- reporting limit
);

-- 1c) Field samples
CREATE TABLE samples (
  sample_id     INTEGER PRIMARY KEY,
  site_id       INTEGER NOT NULL,
  sample_dt     DATE NOT NULL,
  matrix        TEXT NOT NULL,   -- 'surface water', 'groundwater'
  sampler       TEXT,
  weather       TEXT,
  FOREIGN KEY (site_id) REFERENCES sites(site_id)
);

-- 1d) Lab results (long/narrow format)
CREATE TABLE results (
  result_id     INTEGER PRIMARY KEY,
  sample_id     INTEGER NOT NULL,
  analyte_id    INTEGER NOT NULL,
  result_val    REAL,            -- numeric result
  qualifier     TEXT,            -- 'U' non-detect, 'J' estimated, etc.
  FOREIGN KEY (sample_id) REFERENCES samples(sample_id),
  FOREIGN KEY (analyte_id) REFERENCES analytes(analyte_id)
);

-- 2) SEED DATA

-- 2a) Sites
INSERT INTO sites (site_id, site_name, latitude, longitude, water_body, region) VALUES
(1,'Cypress Creek Upstream',27.9001,-82.7001,'Cypress Creek','Pinellas'),
(2,'Cypress Creek Mid',     27.9020,-82.7050,'Cypress Creek','Pinellas'),
(3,'Cypress Creek Down',    27.9055,-82.7090,'Cypress Creek','Pinellas');

-- 2b) Analytes
INSERT INTO analytes (analyte_id, analyte_name, unit, rl) VALUES
(1,'Nitrate as N','mg/L',0.05),
(2,'Total Phosphorus','mg/L',0.01),
(3,'E. coli','CFU/100mL',1);

-- 2c) Samples
INSERT INTO samples (sample_id, site_id, sample_dt, matrix, sampler, weather) VALUES
(1001,1,'2025-09-01','surface water','Emma','clear'),
(1002,2,'2025-09-01','surface water','Emma','clear'),
(1003,3,'2025-09-01','surface water','Emma','clear'),
(1004,1,'2025-09-15','surface water','Will','rain prior day'),
(1005,3,'2025-09-15','surface water','Will','rain prior day');

-- 2d) Results
INSERT INTO results (result_id, sample_id, analyte_id, result_val, qualifier) VALUES
(1,1001,1,0.42,NULL),
(2,1001,2,0.028,NULL),
(3,1001,3,120,NULL),
(4,1002,1,0.55,NULL),
(5,1002,2,0.015,NULL),
(6,1002,3,250,NULL),
(7,1003,1,0.61,NULL),
(8,1003,2,0.022,NULL),
(9,1003,3,520,NULL),
(10,1004,1,0.48,NULL),
(11,1004,2,0.040,'J'),
(12,1004,3,300,NULL),
(13,1005,1,0.72,NULL),
(14,1005,2,0.035,NULL),
(15,1005,3,800,NULL);

-- 3) VIEW (drop-safe above)
CREATE VIEW vw_results_long AS
SELECT s.sample_dt, si.site_name, si.region, s.matrix,
       a.analyte_name, r.result_val, a.unit, r.qualifier
FROM results r
JOIN samples s  ON r.sample_id = s.sample_id
JOIN sites   si ON s.site_id   = si.site_id
JOIN analytes a ON r.analyte_id = a.analyte_id;

-- 4) OPTIONAL INDEXES (speed up joins/filters as data grows)
CREATE INDEX IF NOT EXISTS idx_samples_site   ON samples(site_id);
CREATE INDEX IF NOT EXISTS idx_results_sample ON results(sample_id);
CREATE INDEX IF NOT EXISTS idx_results_an     ON results(analyte_id);

-- 5) QUICK VERIFICATION QUERIES

SELECT 'sites' AS tbl, COUNT(*) n FROM sites
UNION ALL SELECT 'analytes', COUNT(*) FROM analytes
UNION ALL SELECT 'samples',  COUNT(*) FROM samples
UNION ALL SELECT 'results',  COUNT(*) FROM results;

SELECT * FROM vw_results_long
ORDER BY sample_dt, site_name, analyte_name
LIMIT 10;
