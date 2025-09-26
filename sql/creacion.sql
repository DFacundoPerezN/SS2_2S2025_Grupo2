-- Tabla base de q1 2022 (particionada y clusterizada)
CREATE OR REPLACE TABLE `ss2-bigquery-proyecto-473223.fase1_dataset.trips_q1_clean`
PARTITION BY DATE(pickup_datetime)
CLUSTER BY pickup_location_id, dropoff_location_id, payment_type AS
SELECT *
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE data_file_month BETWEEN 1 AND 3
  AND trip_distance > 0
  AND total_amount >= 0
  AND fare_amount >= 0
  AND passenger_count BETWEEN 1 AND 6; 

--Tabla base de TODO 2022 (particionada, sin cluster)
CREATE OR REPLACE TABLE `ss2-bigquery-proyecto-473223.fase1_dataset.trips_2022_part`
PARTITION BY DATE(pickup_datetime)
OPTIONS (
  require_partition_filter = TRUE
) AS
SELECT
  pickup_datetime,
  dropoff_datetime,
  pickup_location_id,
  dropoff_location_id,
  passenger_count,
  trip_distance,
  fare_amount,
  tip_amount,
  total_amount,
  payment_type
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE pickup_datetime >= '2022-01-01' AND pickup_datetime < '2023-01-01';

-- Validaciones rápidas
-- Rango con TIMESTAMP (recomendado)
SELECT COUNT(*)
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_2022_part`
WHERE pickup_datetime >= '2022-01-01' AND pickup_datetime < '2023-01-01';
-- Con DATE() sobre la columna
SELECT COUNT(*)
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_2022_part`
WHERE DATE(pickup_datetime) BETWEEN '2022-05-01' AND '2022-05-31';
-- Un día específico
SELECT COUNT(*)
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_2022_part`
WHERE pickup_datetime >= '2022-02-15' AND pickup_datetime < '2022-02-16';

-- Particiones creadas
SELECT partition_id, total_rows
FROM `ss2-bigquery-proyecto-473223.fase1_dataset`.INFORMATION_SCHEMA.PARTITIONS
WHERE table_name = 'trips_2022_part'
ORDER BY partition_id
LIMIT 20;

-- Publica mas costosa
-- Sin particiones
SELECT EXTRACT(MONTH FROM pickup_datetime) AS mes, COUNT(*) AS viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE pickup_datetime >= '2022-01-01' AND pickup_datetime < '2023-01-01'
GROUP BY mes
ORDER BY mes;

-- Mi particionada
-- Filtrando por rango de partición
SELECT EXTRACT(MONTH FROM pickup_datetime) AS mes, COUNT(*) AS viajes
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_2022_part`
WHERE pickup_datetime >= '2022-01-01' AND pickup_datetime < '2023-01-01'
GROUP BY mes
ORDER BY mes;


-- Metricasa para dashboard 2022
CREATE OR REPLACE TABLE `ss2-bigquery-proyecto-473223.fase1_dataset.monthly_metrics_2022`
PARTITION BY month_date
CLUSTER BY payment_type AS
SELECT
  DATE_TRUNC(DATE(pickup_datetime), MONTH) AS month_date,
  payment_type,
  COUNT(*) AS trips,
  ROUND(AVG(trip_distance), 2) AS avg_distance,
  ROUND(AVG(total_amount), 2) AS avg_total,
  ROUND(AVG(tip_amount), 2) AS avg_tip
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_2022_part`
WHERE pickup_datetime >= '2022-01-01' AND pickup_datetime < '2023-01-01'
GROUP BY month_date, payment_type;


-- KPIs para dashboard 2022
SELECT month_date, SUM(trips) AS total_trips
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.monthly_metrics_2022`
WHERE month_date >= '2022-01-01' AND month_date < '2023-01-01'
GROUP BY month_date
ORDER BY month_date;



-- Demanda por hora y zona 2022
CREATE OR REPLACE TABLE `ss2-bigquery-proyecto-473223.fase1_dataset.hourly_demand_2022`
PARTITION BY DATE(pickup_datetime)
CLUSTER BY pickup_location_id, hour_of_day AS
SELECT
  pickup_location_id,
  EXTRACT(HOUR FROM pickup_datetime) AS hour_of_day,
  DATE(pickup_datetime) AS pickup_date,
  COUNT(*) AS trips,
  ANY_VALUE(pickup_datetime) AS pickup_datetime
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_2022_part`
WHERE pickup_datetime >= '2022-01-01' AND pickup_datetime < '2023-01-01'
GROUP BY pickup_location_id, hour_of_day, pickup_date;

-- Consulta de ejemplo
SELECT SUM(trips) AS viajes_zona_hora
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.hourly_demand_2022`
WHERE DATE(pickup_datetime) = '2022-02-15'
  AND pickup_location_id = 237
  AND hour_of_day BETWEEN 7 AND 9;

-- Distribucion de propinas 2022
CREATE OR REPLACE TABLE `ss2-bigquery-proyecto-473223.fase1_dataset.tips_buckets_2022`
PARTITION BY month_date
CLUSTER BY tip_bucket AS
WITH base AS (
  SELECT
    DATE_TRUNC(DATE(pickup_datetime), MONTH) AS month_date,
    CASE
      WHEN tip_amount = 0 THEN 'Sin propina'
      WHEN tip_amount <= 2 THEN 'Hasta 2 USD'
      WHEN tip_amount <= 5 THEN '2–5 USD'
      WHEN tip_amount <= 10 THEN '5–10 USD'
      ELSE 'Más de 10 USD'
    END AS tip_bucket
  FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_2022_part`
  WHERE pickup_datetime >= '2022-01-01' AND pickup_datetime < '2023-01-01'
)
SELECT month_date, tip_bucket, COUNT(*) AS trips
FROM base
GROUP BY month_date, tip_bucket;

-- Consulta de ejemplo
SELECT tip_bucket, SUM(trips) AS total
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.tips_buckets_2022`
WHERE month_date >= '2022-01-01' AND month_date < '2023-01-01'
GROUP BY tip_bucket
ORDER BY total DESC;


--Top 10 zonas de abordaje en mayo 2022
SELECT pickup_location_id, COUNT(*) AS viajes
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_2022_part`
WHERE pickup_datetime >= '2022-05-01' AND pickup_datetime < '2022-06-01'
GROUP BY pickup_location_id
ORDER BY viajes DESC
LIMIT 10;


-- Tarifa y propina promedio por hora (fin de semana vs. entre semana)
SELECT
  EXTRACT(HOUR FROM pickup_datetime) AS hora,
  IF(EXTRACT(DAYOFWEEK FROM pickup_datetime) IN (1,7), 'Fin de semana','Entre semana') AS tipo_dia,
  ROUND(AVG(total_amount),2) AS avg_total,
  ROUND(AVG(tip_amount),2)   AS avg_tip
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_2022_part`
WHERE pickup_datetime >= '2022-01-01' AND pickup_datetime < '2023-01-01'
GROUP BY hora, tipo_dia
ORDER BY hora, tipo_dia;

-- Distribución por método de pago en Q3
SELECT payment_type, COUNT(*) AS viajes
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_2022_part`
WHERE pickup_datetime >= '2022-07-01' AND pickup_datetime < '2022-10-01'
GROUP BY payment_type
ORDER BY viajes DESC;


--Tablas asumidas
--Pública: bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022
--Particionada: ss2-bigquery-proyecto-473223.fase1_dataset.trips_2022_part

-- Agregacion anual (Publica vs particionada)
-- Viajes por mes (tabla pública, sin particiones)
SELECT EXTRACT(MONTH FROM pickup_datetime) AS mes, COUNT(*) AS viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE pickup_datetime >= '2022-01-01' AND pickup_datetime < '2023-01-01'
GROUP BY mes
ORDER BY mes;

-- Misma consulta sobre tu tabla particionada
SELECT EXTRACT(MONTH FROM pickup_datetime) AS mes, COUNT(*) AS viajes
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_2022_part`
WHERE pickup_datetime >= '2022-01-01' AND pickup_datetime < '2023-01-01'
GROUP BY mes
ORDER BY mes;

-- Rango mensual selectivo (pública vs. particionada)
-- Mayo 2022: viajes por zona de abordaje
SELECT pickup_location_id, COUNT(*) AS viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE pickup_datetime >= '2022-05-01' AND pickup_datetime < '2022-06-01'
GROUP BY pickup_location_id
ORDER BY viajes DESC
LIMIT 20;

-- Misma consulta sobre tu tabla particionada
SELECT pickup_location_id, COUNT(*) AS viajes
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_2022_part`
WHERE pickup_datetime >= '2022-05-01' AND pickup_datetime < '2022-06-01'
GROUP BY pickup_location_id
ORDER BY viajes DESC
LIMIT 20;


-- Día específico + horas
-- Total de 7–9 AM para un día específico, todas las zonas
SELECT SUM(trips) AS viajes
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.hourly_demand_2022`
WHERE pickup_datetime >= '2022-02-15' AND pickup_datetime < '2022-02-16'
  AND hour_of_day BETWEEN 7 AND 9;


--Promedios económicos (pública vs. particionada)
-- Promedios por mes: total y propina
SELECT
  EXTRACT(MONTH FROM pickup_datetime) AS mes,
  ROUND(AVG(total_amount),2) AS avg_total,
  ROUND(AVG(tip_amount),2)   AS avg_tip
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE pickup_datetime >= '2022-01-01' AND pickup_datetime < '2023-01-01'
GROUP BY mes
ORDER BY mes;

-- Misma consulta sobre tu tabla particionada
SELECT
  EXTRACT(MONTH FROM pickup_datetime) AS mes,
  ROUND(AVG(total_amount),2) AS avg_total,
  ROUND(AVG(tip_amount),2)   AS avg_tip
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_2022_part`
WHERE pickup_datetime >= '2022-01-01' AND pickup_datetime < '2023-01-01'
GROUP BY mes
ORDER BY mes;


-- -- Versión sin cluster (usa tu trips_2022_part)
SELECT COUNT(*) AS viajes
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_q1_clean`
WHERE pickup_datetime >= '2022-01-01' AND pickup_datetime < '2022-04-01'
  AND pickup_location_id = '237'
  AND dropoff_location_id = '237'
  AND payment_type = '1';

-- Versión con cluster (usa tu trips_q1_clean)
SELECT COUNT(*) AS viajes
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.trips_q1_clean`
WHERE pickup_datetime >= '2022-01-01' AND pickup_datetime < '2022-04-01'
  AND pickup_location_id = '237'
  AND dropoff_location_id = '237'
  AND payment_type = '1';

-- Dia Especifico
-- Total de 7–9 AM para un día específico, todas las zonas
SELECT SUM(trips) AS viajes
FROM `ss2-bigquery-proyecto-473223.fase1_dataset.hourly_demand_2022`
WHERE pickup_datetime >= '2022-02-15' AND pickup_datetime < '2022-02-16'
  AND hour_of_day BETWEEN 7 AND 9;


