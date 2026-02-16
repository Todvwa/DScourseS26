

# Import CSV into SQLite
.mode csv
.import FL_insurance_sample.csv insurance_df

# First 10 rows
SELECT * FROM insurance_df LIMIT 10;

# Unique counties
SELECT DISTINCT county FROM insurance_df ORDER BY county;

# Average appreciation 2012-2011
SELECT AVG(tiv_2012 - tiv_2011) AS avg_appreciation
FROM insurance_df;

# Construction frequency + fraction
SELECT construction,
       COUNT(*) AS frequency,
       ROUND(COUNT(*) * 1.0 / (SELECT COUNT(*) FROM insurance_df), 4) AS fraction
FROM insurance_df
GROUP BY construction
ORDER BY frequency DESC;
