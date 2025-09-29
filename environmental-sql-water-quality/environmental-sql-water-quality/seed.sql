-- === SEED DATA ===

-- Sites
INSERT INTO sites (site_id, site_name, latitude, longitude, water_body, region) VALUES
(1,'Cypress Creek Upstream',27.9001,-82.7001,'Cypress Creek','Pinellas'),
(2,'Cypress Creek Mid',     27.9020,-82.7050,'Cypress Creek','Pinellas'),
(3,'Cypress Creek Down',    27.9055,-82.7090,'Cypress Creek','Pinellas');

-- Analytes
INSERT INTO analytes (analyte_id, analyte_name, unit, rl) VALUES
(1,'Nitrate as N','mg/L',0.05),
(2,'Total Phosphorus','mg/L',0.01),
(3,'E. coli','CFU/100mL',1);

-- Samples
INSERT INTO samples (sample_id, site_id, sample_dt, matrix, sampler, weather) VALUES
(1001,1,'2025-09-01','surface water','Emma','clear'),
(1002,2,'2025-09-01','surface water','Emma','clear'),
(1003,3,'2025-09-01','surface water','Emma','clear'),
(1004,1,'2025-09-15','surface water','Will','rain prior day'),
(1005,3,'2025-09-15','surface water','Will','rain prior day');

-- Results
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
