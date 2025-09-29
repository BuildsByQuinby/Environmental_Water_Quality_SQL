-- === SCHEMA (drop-safe) ===
DROP VIEW  IF EXISTS vw_results_long;
DROP TABLE IF EXISTS results;
DROP TABLE IF EXISTS samples;
DROP TABLE IF EXISTS sites;
DROP TABLE IF EXISTS analytes;

-- Sampling locations
CREATE TABLE sites (
  site_id       INTEGER PRIMARY KEY,
  site_name     TEXT NOT NULL,
  latitude      REAL,
  longitude     REAL,
  water_body    TEXT,
  region        TEXT
);

-- Analyte dictionary
CREATE TABLE analytes (
  analyte_id    INTEGER PRIMARY KEY,
  analyte_name  TEXT NOT NULL,   -- e.g., Nitrate as N
  unit          TEXT NOT NULL,   -- e.g., mg/L, CFU/100mL
  rl            REAL             -- reporting limit
);

-- Field samples
CREATE TABLE samples (
  sample_id     INTEGER PRIMARY KEY,
  site_id       INTEGER NOT NULL,
  sample_dt     DATE NOT NULL,
  matrix        TEXT NOT NULL,   -- 'surface water', 'groundwater'
  sampler       TEXT,
  weather       TEXT,
  FOREIGN KEY (site_id) REFERENCES sites(site_id)
);

-- Lab results (long format)
CREATE TABLE results (
  result_id     INTEGER PRIMARY KEY,
  sample_id     INTEGER NOT NULL,
  analyte_id    INTEGER NOT NULL,
  result_val    REAL,
  qualifier     TEXT,            -- e.g., 'U' non-detect, 'J' estimated
  FOREIGN KEY (sample_id) REFERENCES samples(sample_id),
  FOREIGN KEY (analyte_id) REFERENCES analytes(analyte_id)
);

-- Helpful view
CREATE VIEW vw_results_long AS
SELECT s.sample_dt, si.site_name, si.region, s.matrix,
       a.analyte_name, r.result_val, a.unit, r.qualifier
FROM results r
JOIN samples s  ON r.sample_id = s.sample_id
JOIN sites   si ON s.site_id   = si.site_id
JOIN analytes a ON r.analyte_id = a.analyte_id;
