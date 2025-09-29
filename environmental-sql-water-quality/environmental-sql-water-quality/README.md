# Water Quality Monitoring – Beginner SQL Project

A small **environmental data** database you can run locally with **SQLite** (via DB Browser for SQLite or the `sqlite3` CLI).  
You’ll practice core SQL: table design, inserts, joins, grouping, and simple analytics relevant to water quality.

---

## 🗺️ What’s inside
```
environmental-sql-water-quality/
├─ README.md
├─ schema.sql        # Tables (drop-safe)
├─ seed.sql          # Sample data
├─ queries.sql       # Analysis queries
├─ reset_all.sql     # One-shot build: reset + schema + seed + view + checks
├─ .gitignore
└─ LICENSE (MIT)
```

---

## 📚 Entities (ERD)
```
sites( site_id PK, site_name, latitude, longitude, water_body, region )
   1─* samples( sample_id PK, site_id FK→sites, sample_dt, matrix, sampler, weather )
            1─* results( result_id PK, sample_id FK→samples, analyte_id FK→analytes, result_val, qualifier )
analytes( analyte_id PK, analyte_name, unit, rl )
```

- **sites** – sampling locations (e.g., Cypress Creek Upstream/Mid/Down).
- **analytes** – what was measured (Nitrate as N, Total Phosphorus, E. coli).
- **samples** – field samples collected at a site on a date (with simple metadata).
- **results** – lab results in “long” format: one analyte per row.

A convenience **view** `vw_results_long` joins the four tables for easy analysis.

---

## 🚀 Quick start (DB Browser for SQLite – GUI)
1. Open **DB Browser (SQLite)** → **New Database...** → name it `water_quality.db` → *Cancel* the table wizard.
2. Go to **Execute SQL**.
3. Paste & run: open `reset_all.sql` and run the whole script.
4. Try a query from `queries.sql` (e.g., the joined view).

### CLI (optional)
```bash
sqlite3 water_quality.db < reset_all.sql
sqlite3 water_quality.db "SELECT * FROM vw_results_long LIMIT 10;"
```

---

## 📈 Example questions you’ll answer
- Creek-wide **daily averages** for Nitrate (`AVG` + `GROUP BY`).
- **Exceedance flags** for E. coli and Total Phosphorus (simple thresholds).
- **Upstream vs. downstream** comparisons after a rain day.
- A **pivot-style** summary using conditional aggregates.
- **Latest samples per site** using a CTE.

See `queries.sql` for ready-to-run examples.

---

## 📝 Notes
- All schema and column names use **snake_case** (e.g., `sample_dt`, `result_val`).
- Scripts are **drop-safe** so you can re-run them any time.
- The data is tiny and illustrative—adjust thresholds to match your context.

---

## 📄 License
MIT — see `LICENSE`.
