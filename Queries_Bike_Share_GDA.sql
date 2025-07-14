--Delete mistake version of table; create table with columns and character limits specified. 

DROP TABLE IF EXISTS bikeshare_06_24_to_05_25;
CREATE TABLE bikeshare_06_24_to_05_25 (
 ride_id VARCHAR(50),
 rideable_type VARCHAR(50),
 started_at TIMESTAMP,
 ended_at TIMESTAMP,
 start_station_name VARCHAR(100),
 start_station_id VARCHAR(50),
 end_station_name VARCHAR(100),
 end_station_id VARCHAR(50),
 start_lat DOUBLE PRECISION CHECK (start_lat >= -90.0 AND start_lat <= 90.0),  --check on whether location exists
 start_lng DOUBLE PRECISION CHECK (start_lng >= -180.0 AND start_lng <= 180.0),
 end_lat DOUBLE PRECISION CHECK (end_lat >= -90.0 AND end_lat <= 90.0),  
 end_lng DOUBLE PRECISION CHECK (end_lng >= -180.0 AND end_lng <= 180.0),
 member_casual VARCHAR(50) 
);


--Populate table with downloaded dataset on hard drive. 12 months combined into one table.

COPY bikeshare_06_24_to_05_25 FROM 'C:\Users\Public\Documents\Trip Data for Bike Share Case Study\202405-divvy-tripdata.csv' DELIMITER ',' CSV HEADER;
COPY bikeshare_06_24_to_05_25 FROM 'C:\Users\Public\Documents\Trip Data for Bike Share Case Study\202406-divvy-tripdata.csv' DELIMITER ',' CSV HEADER;
COPY bikeshare_06_24_to_05_25 FROM 'C:\Users\Public\Documents\Trip Data for Bike Share Case Study\202407-divvy-tripdata.csv' DELIMITER ',' CSV HEADER;
COPY bikeshare_06_24_to_05_25 FROM 'C:\Users\Public\Documents\Trip Data for Bike Share Case Study\202408-divvy-tripdata.csv' DELIMITER ',' CSV HEADER;
COPY bikeshare_06_24_to_05_25 FROM 'C:\Users\Public\Documents\Trip Data for Bike Share Case Study\202409-divvy-tripdata.csv' DELIMITER ',' CSV HEADER;
COPY bikeshare_06_24_to_05_25 FROM 'C:\Users\Public\Documents\Trip Data for Bike Share Case Study\202410-divvy-tripdata.csv' DELIMITER ',' CSV HEADER;
COPY bikeshare_06_24_to_05_25 FROM 'C:\Users\Public\Documents\Trip Data for Bike Share Case Study\202411-divvy-tripdata.csv' DELIMITER ',' CSV HEADER;
COPY bikeshare_06_24_to_05_25 FROM 'C:\Users\Public\Documents\Trip Data for Bike Share Case Study\202412-divvy-tripdata.csv' DELIMITER ',' CSV HEADER;
COPY bikeshare_06_24_to_05_25 FROM 'C:\Users\Public\Documents\Trip Data for Bike Share Case Study\202501-divvy-tripdata.csv' DELIMITER ',' CSV HEADER;
COPY bikeshare_06_24_to_05_25 FROM 'C:\Users\Public\Documents\Trip Data for Bike Share Case Study\202502-divvy-tripdata.csv' DELIMITER ',' CSV HEADER;
COPY bikeshare_06_24_to_05_25 FROM 'C:\Users\Public\Documents\Trip Data for Bike Share Case Study\202503-divvy-tripdata.csv' DELIMITER ',' CSV HEADER;
COPY bikeshare_06_24_to_05_25 FROM 'C:\Users\Public\Documents\Trip Data for Bike Share Case Study\202504-divvy-tripdata.csv' DELIMITER ',' CSV HEADER;

--View head of combined table, now that it has been created
SELECT *

FROM 
	bikeshare_06_24_to_05_25
LIMIT 100	

--determine total number of observations in table (5,735,884)
SELECT COUNT(*)
FROM bikeshare_06_24_to_05_25

--determine number of rides for all possible membership statuses

SELECT
	member_casual,
	COUNT(*) AS num_rides
FROM
	bikeshare_06_24_to_05_25

GROUP BY member_casual

--###QUERIES 1 & 2
--determine totals for three measurements (number of rides, avg trip distance, avg trip duration)
--for casual riders vs subscription members
SELECT
	member_casual,
	COUNT(*) AS num_rides,
	ROUND(AVG(
	SQRT(
	POWER((end_lat-start_lat) * 69, 2) + 
	POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
	)::NUMERIC
	), 2) AS avg_distance_miles,
	ROUND(AVG(EXTRACT (EPOCH FROM (ended_at - started_at))/60), 2) AS avg_trip_duration_minutes
	
FROM
	bikeshare_06_24_to_05_25
/*WHERE 
SQRT(
	POWER((end_lat-start_lat) * 69, 2) + 
	POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
	)::NUMERIC >0
*/
GROUP BY member_casual	
--determine number of values for bike type (3: classic bike, electric bike, electric scooter)
SELECT
	DISTINCT(rideable_type)
FROM
	bikeshare_06_24_to_05_25

--determine number of rides for each of these 3 ride types.
SELECT
	rideable_type,
	COUNT(*) AS num_rides
FROM
	bikeshare_06_24_to_05_25

GROUP BY rideable_type

--###QUERIES 3 & 4
--expand on the above by determining all three measures by ride type.
SELECT
	member_casual,
	rideable_type,
	COUNT(*) AS num_rides,
	ROUND(AVG(
	SQRT(
	POWER((end_lat-start_lat) * 69, 2) + 
	POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
	)::NUMERIC
	), 2) AS avg_distance_miles,
	ROUND(AVG(EXTRACT (EPOCH FROM (ended_at - started_at))/60), 2) AS avg_trip_duration_minutes
	

FROM
	bikeshare_06_24_to_05_25
/*	
WHERE SQRT(
	POWER((end_lat-start_lat) * 69, 2) + 
	POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
	)::NUMERIC >0
*/

GROUP BY member_casual, rideable_type 

--###QUERY 5
--Pivot to allow cohorts to be compared side-by-side
WITH AggMeasuresByRideType AS(
SELECT
	member_casual,
	rideable_type,
	COUNT(*) AS num_rides,
	ROUND(AVG(
	SQRT(
	POWER((end_lat-start_lat) * 69, 2) + 
	POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
	)::NUMERIC
	), 2) AS avg_distance_miles,
	ROUND(AVG(EXTRACT (EPOCH FROM (ended_at - started_at))/60), 2) AS avg_trip_duration_minutes
	

FROM
	bikeshare_06_24_to_05_25	


WHERE SQRT(
	POWER((end_lat-start_lat) * 69, 2) + 
	POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
	)::NUMERIC >0


GROUP BY member_casual, rideable_type 

)
SELECT 
	rideable_type,
	SUM(CASE WHEN member_casual='casual' THEN num_rides END) AS num_rides_casual,
	SUM(CASE WHEN member_casual='member' THEN num_rides END) AS num_rides_member,
	SUM(CASE WHEN member_casual='casual' THEN avg_distance_miles END) AS avg_distance_casual,
	SUM(CASE WHEN member_casual='member' THEN avg_distance_miles END) AS avg_distance_member,
	SUM(CASE WHEN member_casual='casual' THEN avg_trip_duration_minutes END) AS avg_duration_casual,
	SUM(CASE WHEN member_casual='member' THEN avg_trip_duration_minutes END) AS avg_duration_member

FROM
	AggMeasuresByRideType


GROUP BY rideable_type	
	
	
--extract month from timestamp, convert month number to month name, count trips by month

SELECT
	
	CASE WHEN EXTRACT(MONTH FROM started_at) = 1 THEN 'January'
	WHEN EXTRACT(MONTH FROM started_at) = 2 THEN 'February'
	WHEN EXTRACT(MONTH FROM started_at) = 3 THEN 'March'
	WHEN EXTRACT(MONTH FROM started_at) = 4 THEN 'April'
	WHEN EXTRACT(MONTH FROM started_at) = 5 THEN 'May'
	WHEN EXTRACT(MONTH FROM started_at) = 6 THEN 'June'
	WHEN EXTRACT(MONTH FROM started_at) = 7 THEN 'July'
	WHEN EXTRACT(MONTH FROM started_at) = 8 THEN 'August'
	WHEN EXTRACT(MONTH FROM started_at) = 9 THEN 'September'
	WHEN EXTRACT(MONTH FROM started_at) = 10 THEN 'October'
	WHEN EXTRACT(MONTH FROM started_at) = 11 THEN 'November'
	WHEN EXTRACT(MONTH FROM started_at) = 12 THEN 'December'
	ELSE null END AS month,
	COUNT (ride_id) AS num_rides 
	
FROM
	bikeshare_06_24_to_05_25
	
GROUP BY month, EXTRACT(MONTH FROM started_at)

ORDER BY EXTRACT(MONTH FROM started_at) ASC

--###QUERIES 6 & 7
/*Derive summary table including the following:
	grouped by:
-member vs casual rider - factor 2 values
-type of bike or scooter - factor 3 values

-month (two columns for month: one for the name, one to sort by) OR
 day of week 

	summary data:
-number of rides - count, discrete
-average trip duration, displayed as text string - average, continuous
**two different ways to include average trip duration are written

ALSO: add distance traveled to summary table
*/
WITH AggMeasuresByRideTypeMonthOrWeek AS (
SELECT 
	member_casual,
	rideable_type,
	COUNT (ride_id) AS num_rides,
	ROUND(EXTRACT (EPOCH FROM AVG(ended_at - started_at))/60, 2) AS avg_trip_duration_minutes,
	--TO_CHAR(AVG(ended_at - started_at), 'HH24:MI:SS') AS avg_trip_duration,  -alternative method for creating field
	ROUND(AVG(
	SQRT(
	POWER((end_lat-start_lat) * 69, 2) + 
	POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
	)::NUMERIC), 2) AS avg_distance_miles,
	EXTRACT(DOW FROM started_at) AS week_num,  --for day of week
	TO_CHAR(started_at, 'Day') AS day_of_week  --for day of week
	--TO_CHAR(started_at, 'Month') AS month,  --for month
	--EXTRACT(MONTH FROM started_at) AS month_num  --for month

FROM bikeshare_06_24_to_05_25

WHERE 
SQRT(
	POWER((end_lat-start_lat) * 69, 2) + 
	POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
	)::NUMERIC >0

GROUP BY member_casual, rideable_type, --TO_CHAR(started_at, 'Day'),
day_of_week,
--month, 
--EXTRACT(MONTH FROM started_at) 
EXTRACT(DOW FROM started_at)

--ORDER BY EXTRACT(MONTH FROM started_at)
ORDER BY EXTRACT(DOW FROM started_at) ASC
)

SELECT 
	rideable_type,
	day_of_week,
	SUM(CASE WHEN member_casual='casual' THEN num_rides END) AS num_rides_casual, --These CASE statements create calculated columns to split each column by another dimension. The effect is to pivot the data wider.
	SUM(CASE WHEN member_casual='member' THEN num_rides END) AS num_rides_member,
	SUM(CASE WHEN member_casual='casual' THEN avg_distance_miles END) AS avg_distance_casual,
	SUM(CASE WHEN member_casual='member' THEN avg_distance_miles END) AS avg_distance_member,
	SUM(CASE WHEN member_casual='casual' THEN avg_trip_duration_minutes END) AS avg_duration_casual,
	SUM(CASE WHEN member_casual='member' THEN avg_trip_duration_minutes END) AS avg_duration_member,
	week_num

FROM
	AggMeasuresByRideTypeMonthOrWeek


GROUP BY rideable_type, 
day_of_week, week_num
--month, month_num

--###QUERIES 8 & 9: Create calculated field for Hour and group by it, including the three measures. Then pivot wider to compare cohorts 
WITH AggMeasuresByHour AS (
SELECT 
	member_casual,
	rideable_type,
	EXTRACT (HOUR FROM started_at) AS hour,
	COUNT (ride_id) AS num_rides,
	ROUND(EXTRACT (EPOCH FROM AVG(ended_at - started_at))/60, 2) AS avg_trip_duration_minutes,
	ROUND(AVG(
	SQRT(
	POWER((end_lat-start_lat) * 69, 2) + 
	POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
	)::NUMERIC), 2) AS avg_distance_miles
	/*COUNT(CASE WHEN (SQRT(
	POWER((end_lat-start_lat) * 69, 2) + 
	POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
	)::NUMERIC = 0) THEN 1 END) AS num_rides_nowhere
	*/
	
FROM
	bikeshare_06_24_to_05_25

WHERE 
	SQRT(
	POWER((end_lat-start_lat) * 69, 2) + 
	POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
	)::NUMERIC > 0

GROUP BY member_casual, rideable_type, EXTRACT (HOUR FROM started_at)	

)
SELECT 
	rideable_type,
	hour,
	SUM(CASE WHEN member_casual='casual' THEN num_rides END) AS num_rides_casual,
	SUM(CASE WHEN member_casual='member' THEN num_rides END) AS num_rides_member,
	SUM(CASE WHEN member_casual='casual' THEN avg_distance_miles END) AS avg_distance_casual,
	SUM(CASE WHEN member_casual='member' THEN avg_distance_miles END) AS avg_distance_member,
	SUM(CASE WHEN member_casual='casual' THEN avg_trip_duration_minutes END) AS avg_duration_casual,
	SUM(CASE WHEN member_casual='member' THEN avg_trip_duration_minutes END) AS avg_duration_member

FROM
	AggMeasuresByHour


GROUP BY rideable_type, hour	

ORDER BY rideable_type, hour

--calculate length (absolute) in miles, and direction of ride *this is a crude estimate for direction: I update with the correct multipliers below*
WITH WithCalculatedDistances AS (    -- CTE to translate latitude/longitude changes into direction
	SELECT *,
	CASE WHEN (end_lat-start_lat) > 0 AND (end_lat-start_lat) >= (ABS(end_lng-start_lng) * 2) THEN 'North'
	WHEN (end_lat-start_lat) < 0 AND (start_lat-end_lat) >= (ABS(end_lng-start_lng)*2) THEN 'South'
	WHEN (end_lng-start_lng) > 0 AND (end_lng-start_lng) >= (ABS(end_lat-start_lat)*2) THEN 'East'
	WHEN (end_lng-start_lng) < 0 AND (start_lng-end_lng) >= (ABS(end_lat-start_lat)*2) THEN 'West'
	WHEN (end_lat-start_lat) > 0 AND (end_lng-start_lng) > 0 AND (end_lat-start_lat) < (ABS(end_lng-start_lng) * 2) AND (end_lng-start_lng) < (ABS(end_lat-start_lat)*2) THEN 'Northeast'
	WHEN (end_lat-start_lat) > 0 AND (end_lng-start_lng) < 0 AND (end_lat-start_lat) < (ABS(end_lng-start_lng) * 2) AND (start_lng-end_lng) < (ABS(end_lat-start_lat)*2) THEN 'Northwest'
	WHEN (end_lat-start_lat) < 0 AND (end_lng-start_lng) > 0 AND (start_lat-end_lat) < (ABS(end_lng-start_lng) * 2) AND (end_lng-start_lng) < (ABS(end_lat-start_lat)*2) THEN 'Southeast'
	WHEN (end_lat-start_lat) < 0 AND (end_lng-start_lng) < 0 AND (start_lat-end_lat) < (ABS(end_lng-start_lng) * 2) AND (start_lng-end_lng) < (ABS(end_lat-start_lat)*2) THEN 'Southwest'
	ELSE 'None' END AS trip_direction,
	--SQRT((end_lat-start_lat)^2 + (end_lng-start_lng)^2) AS absolute_distance
	--ROUND(
	SQRT(
	POWER((end_lat-start_lat) * 69, 2) + 
	POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
	)::NUMERIC
	--, 2) 
	AS absolute_distance_miles,
	ROUND(EXTRACT (EPOCH FROM AVG(ended_at - started_at))/60, 2) AS avg_trip_duration_minutes

FROM 
	bikeshare_06_24_to_05_25	
)

SELECT 
	member_casual,
	trip_direction,
	--AVG (SQRT((end_lat-start_lat)^2 + (end_lng-start_lng)^2)) AS avg_abs_distance  -calculated average and distance inline
	COUNT (*) AS num_trips,
	ROUND(AVG (absolute_distance_miles), 2) AS avg_abs_distance
	

FROM
	WithCalculatedDistances
	
GROUP BY member_casual, trip_direction

ORDER BY num_trips

--LIMIT 100



--###QUERIES 10 & 11: Updated CTE with correct directon formula constant ( tan(22.5 degrees) or 2.414213562). Data is grouped by direction and member/casual.
-- Then, table is pivoted wider to allow measures to be compared side-by-side by cohort
WITH GroupedForPivot AS (
WITH WithCalculatedFields AS (
	SELECT *,
	CASE WHEN (end_lat-start_lat) > 0 AND (end_lat-start_lat) >= (ABS(end_lng-start_lng) * 2.414213562) THEN 'North'
	WHEN (end_lat-start_lat) < 0 AND (start_lat-end_lat) >= (ABS(end_lng-start_lng)*2.414213562) THEN 'South'
	WHEN (end_lng-start_lng) > 0 AND (end_lng-start_lng) >= (ABS(end_lat-start_lat)*2.414213562) THEN 'East'
	WHEN (end_lng-start_lng) < 0 AND (start_lng-end_lng) >= (ABS(end_lat-start_lat)*2.414213562) THEN 'West'
	WHEN (end_lat-start_lat) > 0 AND (end_lng-start_lng) > 0 AND (end_lat-start_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (end_lng-start_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Northeast'
	WHEN (end_lat-start_lat) > 0 AND (end_lng-start_lng) < 0 AND (end_lat-start_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (start_lng-end_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Northwest'
	WHEN (end_lat-start_lat) < 0 AND (end_lng-start_lng) > 0 AND (start_lat-end_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (end_lng-start_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Southeast'
	WHEN (end_lat-start_lat) < 0 AND (end_lng-start_lng) < 0 AND (start_lat-end_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (start_lng-end_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Southwest'
	ELSE 'None' END AS trip_direction,
	--ROUND(
	SQRT(
	POWER((end_lat-start_lat) * 69, 2) + 
	POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
	)::NUMERIC
	--, 2) 
	AS absolute_distance_miles
	
	
	
	FROM
		bikeshare_06_24_to_05_25
		
	WHERE
		SQRT(
	POWER((end_lat-start_lat) * 69, 2) + 
	POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
	)::NUMERIC > 0
	)
SELECT 
	member_casual,
	rideable_type,
	trip_direction,
	--AVG (SQRT((end_lat-start_lat)^2 + (end_lng-start_lng)^2)) AS avg_abs_distance  -calculated average and distance inline
	COUNT (*) AS num_rides,
	ROUND(AVG (absolute_distance_miles), 2) AS avg_distance_miles,
	ROUND(EXTRACT (EPOCH FROM AVG(ended_at - started_at))/60, 2) AS avg_trip_duration_minutes
	
	

FROM
	WithCalculatedFields
	
GROUP BY member_casual, rideable_type, trip_direction

ORDER BY member_casual, rideable_type
)

SELECT 
	rideable_type,
	trip_direction,
	SUM(CASE WHEN member_casual='casual' THEN num_rides END) AS num_rides_casual, --These CASE statements create calculated columns to split each column by another dimension. The effect is to pivot the data wider.
	SUM(CASE WHEN member_casual='member' THEN num_rides END) AS num_rides_member,
	SUM(CASE WHEN member_casual='casual' THEN avg_distance_miles END) AS avg_distance_casual,
	SUM(CASE WHEN member_casual='member' THEN avg_distance_miles END) AS avg_distance_member,
	SUM(CASE WHEN member_casual='casual' THEN avg_trip_duration_minutes END) AS avg_duration_casual,
	SUM(CASE WHEN member_casual='member' THEN avg_trip_duration_minutes END) AS avg_duration_member


FROM
	GroupedForPivot


GROUP BY rideable_type, trip_direction





--Query for entire table (too large to reliably use in Tableau)

WITH WithCalculatedFields AS (
	SELECT *,
	CASE WHEN (end_lat-start_lat) > 0 AND (end_lat-start_lat) >= (ABS(end_lng-start_lng) * 2.414213562) THEN 'North'
	WHEN (end_lat-start_lat) < 0 AND (start_lat-end_lat) >= (ABS(end_lng-start_lng)*2.414213562) THEN 'South'
	WHEN (end_lng-start_lng) > 0 AND (end_lng-start_lng) >= (ABS(end_lat-start_lat)*2.414213562) THEN 'East'
	WHEN (end_lng-start_lng) < 0 AND (start_lng-end_lng) >= (ABS(end_lat-start_lat)*2.414213562) THEN 'West'
	WHEN (end_lat-start_lat) > 0 AND (end_lng-start_lng) > 0 AND (end_lat-start_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (end_lng-start_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Northeast'
	WHEN (end_lat-start_lat) > 0 AND (end_lng-start_lng) < 0 AND (end_lat-start_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (start_lng-end_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Northwest'
	WHEN (end_lat-start_lat) < 0 AND (end_lng-start_lng) > 0 AND (start_lat-end_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (end_lng-start_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Southeast'
	WHEN (end_lat-start_lat) < 0 AND (end_lng-start_lng) < 0 AND (start_lat-end_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (start_lng-end_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Southwest'
	ELSE 'None' END AS trip_direction,
	--ROUND(
	SQRT(
	POWER((end_lat-start_lat) * 69, 2) + 
	POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
	)::NUMERIC
	--, 2) 
	AS absolute_distance_miles
	
	
	
	FROM
		bikeshare_06_24_to_05_25
		
	WHERE
		SQRT(
	POWER((end_lat-start_lat) * 69, 2) + 
	POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
	)::NUMERIC > 0
)
	
SELECT
	rideable_type,
	start_station_name,
	end_station_name,
 	started_at,
 	ended_at,
 	start_station_name,
 	end_station_name,
 	end_station_id,
 	start_lat,
 	start_lng,
 	end_lat,  
 	end_lng,
 	member_casual,
	trip_direction,
	ROUND(absolute_distance_miles), 2) AS absolute_distance_miles

FROM 
	WithCalculatedFields


--show what is in columns for GIS table
SELECT
	the_geom::geometry
FROM
	chicago_gis_neighborhoods

LIMIT 5

--View to upload joined table to QGIS (to ultimately convert to a GEOJSON and use with Tableau)

CREATE OR REPLACE VIEW public.final_analysis_view AS
WITH GroupedAndCalculatedFields AS(
	WITH WithCalculatedFields AS (
		SELECT *,
		CASE WHEN (end_lat-start_lat) > 0 AND (end_lat-start_lat) >= (ABS(end_lng-start_lng) * 2.414213562) THEN 'North'
		WHEN (end_lat-start_lat) < 0 AND (start_lat-end_lat) >= (ABS(end_lng-start_lng)*2.414213562) THEN 'South'
		WHEN (end_lng-start_lng) > 0 AND (end_lng-start_lng) >= (ABS(end_lat-start_lat)*2.414213562) THEN 'East'
		WHEN (end_lng-start_lng) < 0 AND (start_lng-end_lng) >= (ABS(end_lat-start_lat)*2.414213562) THEN 'West'
		WHEN (end_lat-start_lat) > 0 AND (end_lng-start_lng) > 0 AND (end_lat-start_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (end_lng-start_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Northeast'
		WHEN (end_lat-start_lat) > 0 AND (end_lng-start_lng) < 0 AND (end_lat-start_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (start_lng-end_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Northwest'
		WHEN (end_lat-start_lat) < 0 AND (end_lng-start_lng) > 0 AND (start_lat-end_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (end_lng-start_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Southeast'
		WHEN (end_lat-start_lat) < 0 AND (end_lng-start_lng) < 0 AND (start_lat-end_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (start_lng-end_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Southwest'
		ELSE 'None' END AS trip_direction,
		--ROUND(
		SQRT(
		POWER((end_lat-start_lat) * 69, 2) + 
		POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
		)::NUMERIC
		--, 2) 
		AS absolute_distance_miles
	
	
		FROM
		bikeshare_06_24_to_05_25
		)


	SELECT
	member_casual,
	start_station_name,
	MIN(ST_SetSRID(ST_MakePoint(start_lng, start_lat), 4326)) AS location,
	COUNT(*) AS num_rides,
	ROUND(AVG(EXTRACT (EPOCH FROM (ended_at - started_at))/60), 2) AS avg_trip_duration_minutes,
	ROUND(AVG(absolute_distance_miles), 2) AS avg_distance_miles,
	AVG(start_lat) AS start_lat,
	AVG(start_lng) AS start_lng


	FROM 
		WithCalculatedFields AS t1

	WHERE start_station_name IS NOT NULL

	GROUP BY member_casual, start_station_name

	--HAVING COUNT(*) < 5
	HAVING ROUND(AVG(EXTRACT (EPOCH FROM (ended_at - started_at))/60), 2) > 0
	)

SELECT
	t1.member_casual,
	t1.start_station_name,
	t1.location,
	t1.num_rides,
	t1.avg_trip_duration_minutes,
	t1.avg_distance_miles,
	--ST_AsText(
	t2.the_geom,
	--) AS neighborhood_wkt,
	t2.primary_neigh,
	t1.start_lat,
	t1.start_lng
	

FROM
	GroupedAndCalculatedFields AS t1

INNER JOIN 	
	chicago_gis_neighborhoods AS t2
	
ON ST_Intersects(t2.the_geom, ST_SetSRID(t1.location, 4326))

ORDER BY t1.member_casual, t1.num_rides DESC

-- for checking where functions from extensions are organized
SELECT n.nspname AS function_schema
FROM   pg_proc p
JOIN   pg_namespace n ON p.pronamespace = n.oid
WHERE  p.proname = 'st_intersects'; -- check for a common function


--Text to display results
--Joined table with chicago neighborhood boundaries and station locations, plus measurements
SELECT*

FROM
	final_analysis_table_station_neighborhoods

LIMIT 10


--number of stations per neighborhood, number of neighborhoods
SELECT
	primary_neigh,
	COUNT(DISTINCT start_station_name) AS num_stations

FROM 
	final_analysis_table_station_neighborhoods
	
GROUP BY primary_neigh

ORDER BY num_stations DESC

--to create index for fast organization of geometric data
CREATE INDEX final_analysis_table_geom_idx
ON public.final_analysis_table_station_neighborhoods_2
USING GIST (the_geom); 


--creating table with neighborhood categories in PostgreSQL to join with main table
DROP TABLE IF EXISTS neighborhood_categories
CREATE TABLE neighborhood_categories (
primary_neigh VARCHAR(100),
neigh_category VARCHAR(100)
);
COPY neighborhood_categories FROM '/Users/reedw.solomon/Data_Folder/Table Creation for Trip Data in Postgresql/chicago_neighborhood_categories.csv' DELIMITER ',' CSV HEADER;

--fix mistake on categorization of one neighborhood
UPDATE neighborhood_categories
SET neigh_category = 'Inner Ring'
WHERE primary_neigh = 'United Center';

SELECT *

FROM neighborhood_categories

--query to compare ride direction, hour, and weekday
WITH WithCalculatedFields AS (
	SELECT *,
	TO_CHAR(started_at, 'Day') AS day_of_week,
	EXTRACT(DOW FROM started_at) AS week_num, 
	EXTRACT (HOUR FROM started_at) AS hour,
	CASE WHEN (end_lat-start_lat) > 0 AND (end_lat-start_lat) >= (ABS(end_lng-start_lng) * 2.414213562) THEN 'North'
	WHEN (end_lat-start_lat) < 0 AND (start_lat-end_lat) >= (ABS(end_lng-start_lng)*2.414213562) THEN 'South'
	WHEN (end_lng-start_lng) > 0 AND (end_lng-start_lng) >= (ABS(end_lat-start_lat)*2.414213562) THEN 'East'
	WHEN (end_lng-start_lng) < 0 AND (start_lng-end_lng) >= (ABS(end_lat-start_lat)*2.414213562) THEN 'West'
	WHEN (end_lat-start_lat) > 0 AND (end_lng-start_lng) > 0 AND (end_lat-start_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (end_lng-start_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Northeast'
	WHEN (end_lat-start_lat) > 0 AND (end_lng-start_lng) < 0 AND (end_lat-start_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (start_lng-end_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Northwest'
	WHEN (end_lat-start_lat) < 0 AND (end_lng-start_lng) > 0 AND (start_lat-end_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (end_lng-start_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Southeast'
	WHEN (end_lat-start_lat) < 0 AND (end_lng-start_lng) < 0 AND (start_lat-end_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (start_lng-end_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Southwest'
	ELSE 'None' END AS trip_direction,
	--ROUND(
	SQRT(
	POWER((end_lat-start_lat) * 69, 2) + 
	POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
	)::NUMERIC
	--, 2) 
	AS absolute_distance_miles
	
	
	
	FROM
		bikeshare_06_24_to_05_25
		
	WHERE
		SQRT(
	POWER((end_lat-start_lat) * 69, 2) + 
	POWER((COS(start_lat * PI()/180) * (end_lng-start_lng) * 69.17), 2)
	)::NUMERIC > 0		
)

SELECT
	member_casual,
	rideable_type,
	trip_direction,
	day_of_week,
	hour,
	COUNT(*) AS num_rides,
	ROUND(AVG(absolute_distance_miles), 2) AS absolute_distance_miles,
	ROUND(AVG(EXTRACT (EPOCH FROM (ended_at - started_at))/60), 2) AS ride_duration,
 	week_num

FROM 
	WithCalculatedFields

GROUP BY member_casual, 
rideable_type, 
trip_direction, 	
day_of_week,
week_num,
hour