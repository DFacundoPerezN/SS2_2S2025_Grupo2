1. Introducción

Contexto del dataset

Objetivo: analizar patrones de viajes, pagos y costos con BigQuery, optimizando consultas con particiones y clustering.

2. Metodología

Tablas creadas: trips_2022_part (particionada), trips_q1_clean (particionada+clusterizada).

Transformaciones: limpieza de registros inválidos, filtros de pasajeros, distancias y montos.

Optimización: comparación de bytes procesados (pública vs particionada vs clusterizada).

3. Hallazgos

La demanda de viajes presenta patrones estacionales, con mayor número de viajes entre febrero–abril y una caída en verano (jun–ago).

Existen zonas recurrentes de alta demanda (IDs como 239, 113, 86), lo que sugiere puntos estratégicos como aeropuertos o centros urbanos.

El análisis de métodos de pago aún muestra los códigos crudos; se recomienda mapearlos para identificar si predomina tarjeta de crédito o efectivo.

En cuanto a propinas, se observa una distribución variada, destacando viajes sin propina y propinas intermedias (2–10 USD), lo que muestra diferentes perfiles de pasajeros y hábitos de pago.