-- Tabla de los meses 1 a 3
CREATE OR REPLACE TABLE `ss2-bigquery-proyecto-473223.fase2_dataset.trips_q1_feature`
PARTITION BY  DATE(pickup_datetime)
CLUSTER BY pickup_loc AS
SELECT 
  --Partición explícita
  DATE(pickup_datetime) AS pickup_date,
  --Label
  CASE WHEN tip_amount > 0 THEN 1 ELSE 0 END AS tipped,
  --Señales temporales
  EXTRACT(HOUR FROM pickup_datetime) AS hour_of_day,
  EXTRACT(DAYOFWEEK FROM pickup_datetime) AS day_of_week,
  EXTRACT(DAY FROM pickup_datetime) AS day,
  EXTRACT(MONTH FROM pickup_datetime) AS month,
  --Magnitudes
  trip_distance, 
  total_amount,
  fare_amount,
  passenger_count,
  -- Señales de ubicación
  CAST(pickup_location_id AS STRING) AS pickup_loc,
  CAST(dropoff_location_id AS STRING) AS dropoff_loc,
  -- Conservamos timestamp
  pickup_datetime 

FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_q1_clean`
WHERE data_file_month BETWEEN 1 AND 3
  AND trip_distance > 0
  AND total_amount >= 0
  AND fare_amount >= 0
  AND passenger_count BETWEEN 1 AND 6;

-- Tabla de los meses 4 a 6

CREATE OR REPLACE TABLE `ss2-bigquery-proyecto-473223.fase2_dataset.trips_q2_feature`
PARTITION BY  DATE(pickup_datetime)
CLUSTER BY pickup_loc AS
SELECT 
  --Partición explícita
  DATE(pickup_datetime) AS pickup_date,
  --Label
  CASE WHEN tip_amount > 0 THEN 1 ELSE 0 END AS tipped,
  --Señales temporales
  EXTRACT(HOUR FROM pickup_datetime) AS hour_of_day,
  EXTRACT(DAYOFWEEK FROM pickup_datetime) AS day_of_week,
  EXTRACT(DAY FROM pickup_datetime) AS day,
  EXTRACT(MONTH FROM pickup_datetime) AS month,
  --Magnitudes
  trip_distance, 
  total_amount,
  fare_amount,
  passenger_count,
  -- Señales de ubicación
  CAST(pickup_location_id AS STRING) AS pickup_loc,
  CAST(dropoff_location_id AS STRING) AS dropoff_loc,
  -- Conservamos timestamp
  pickup_datetime 
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_2022_part`
WHERE DATE(pickup_datetime) BETWEEN '2022-04-01' AND '2022-06-30'
  AND EXTRACT(MONTH FROM pickup_datetime) BETWEEN 4 AND 6
  AND trip_distance > 0
  AND total_amount >= 0
  AND fare_amount >= 0
  AND passenger_count BETWEEN 1 AND 6;

-- Tabla de los meses 7 a 9
CREATE OR REPLACE TABLE `ss2-bigquery-proyecto-473223.fase2_dataset.trips_q3_feature`
PARTITION BY  DATE(pickup_datetime)
CLUSTER BY pickup_loc AS
SELECT 
  --Partición explícita
  DATE(pickup_datetime) AS pickup_date,
  --Label
  CASE WHEN tip_amount > 0 THEN 1 ELSE 0 END AS tipped,
  --Señales temporales
  EXTRACT(HOUR FROM pickup_datetime) AS hour_of_day,
  EXTRACT(DAYOFWEEK FROM pickup_datetime) AS day_of_week,
  EXTRACT(DAY FROM pickup_datetime) AS day,
  EXTRACT(MONTH FROM pickup_datetime) AS month,
  --Magnitudes
  trip_distance, 
  total_amount,
  fare_amount,
  passenger_count,
  -- Señales de ubicación
  CAST(pickup_location_id AS STRING) AS pickup_loc,
  CAST(dropoff_location_id AS STRING) AS dropoff_loc,
  -- Conservamos timestamp
  pickup_datetime 
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_2022_part`
WHERE DATE(pickup_datetime) BETWEEN '2022-07-01' AND '2022-09-30'
  AND trip_distance > 0
  AND total_amount >= 0
  AND fare_amount >= 0
  AND passenger_count BETWEEN 1 AND 6;  

-- Tabla de los meses 10 a 12
CREATE OR REPLACE TABLE `ss2-bigquery-proyecto-473223.fase2_dataset.trips_q4_feature`
PARTITION BY  DATE(pickup_datetime)
CLUSTER BY pickup_loc AS
SELECT 
  --Partición explícita
  DATE(pickup_datetime) AS pickup_date,
  --Label
  CASE WHEN tip_amount > 0 THEN 1 ELSE 0 END AS tipped,
  --Señales temporales
  EXTRACT(HOUR FROM pickup_datetime) AS hour_of_day,
  EXTRACT(DAYOFWEEK FROM pickup_datetime) AS day_of_week,
  EXTRACT(DAY FROM pickup_datetime) AS day,
  EXTRACT(MONTH FROM pickup_datetime) AS month,
  --Magnitudes
  trip_distance, 
  total_amount,
  fare_amount,
  passenger_count,
  -- Señales de ubicación
  CAST(pickup_location_id AS STRING) AS pickup_loc,
  CAST(dropoff_location_id AS STRING) AS dropoff_loc,
  -- Conservamos timestamp
  pickup_datetime 
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_2022_part`
WHERE DATE(pickup_datetime) BETWEEN '2022-10-01' AND '2022-12-31'
  AND trip_distance > 0
  AND total_amount >= 0
  AND fare_amount >= 0
  AND passenger_count BETWEEN 1 AND 6;

