--###QUERIES 12 & 13: Full table query with calculated fields JOINED with Chicago Neighborhoods GIS table. Then pivoted wider to compare cohorts.

--Start of double CTE
CREATE TABLE measures_by_member_neigh_weekday_1 AS
WITH FullTableForPivot AS ( 

WITH JoinedAndCalculated AS(
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
	AS absolute_distance_miles,
	--ROUND(
		EXTRACT (EPOCH FROM (ended_at - started_at))/60
		--, 2) 
		AS trip_duration_minutes,
	EXTRACT(DOW FROM started_at) AS weekday_num,
	TO_CHAR(started_at, 'Day') AS weekday,
	TO_CHAR(started_at, 'Month') AS month,
	EXTRACT(MONTH FROM started_at) AS month_num,
	ST_SetSRID(ST_MakePoint(start_lng, start_lat), 4326) AS location
	
	
	
	FROM
		bikeshare_06_24_to_05_25
	)

SELECT
	--ride_id,
	t1.rideable_type,
	t1.start_station_name,
	--end_station_name,
 	--started_at,
 	--ended_at,
	--start_station_id,
 	--end_station_id,
 	t1.start_lat,
 	t1.start_lng,
 	t1.end_lat,  
 	t1.end_lng,
 	t1.member_casual,
	t1.trip_direction,
	t1.absolute_distance_miles,
	t1.trip_duration_minutes,
	t1.month,
	t1.month_num,
	t1.weekday,
	t1.weekday_num,
	t1.location,
	t2.the_geom,
	t2.primary_neigh,
	t2.shape_area
	

FROM 
	WithCalculatedFields AS t1

INNER JOIN
	chicago_gis_neighborhoods AS t2 ON ST_Intersects(t2.the_geom, ST_SetSRID(t1.location, 4326))

WHERE absolute_distance_miles > 0	
)
--End of double CTE, start of aggregation
SELECT
		--dimensions
	member_casual,
	rideable_type,
	primary_neigh,
	--weekday,
	--weekday_num,
	the_geom,
		--measures
	COUNT(*) AS num_rides,
	AVG(absolute_distance_miles) AS absolute_distance_miles,
	AVG(trip_duration_minutes) AS trip_duration_minutes
	


FROM
	JoinedAndCalculated

GROUP BY member_casual, primary_neigh, 
rideable_type,
--weekday, weekday_num, 
the_geom

--ORDER BY member_casual, COUNT(*)
)

SELECT
	rideable_type,
	primary_neigh,
	SUM(CASE WHEN member_casual='casual' THEN num_rides END) AS num_rides_casual,
	SUM(CASE WHEN member_casual='member' THEN num_rides END) AS num_rides_member,
	SUM(CASE WHEN member_casual='casual' THEN absolute_distance_miles END) AS avg_distance_casual,
	SUM(CASE WHEN member_casual='member' THEN absolute_distance_miles END) AS avg_distance_member,
	SUM(CASE WHEN member_casual='casual' THEN trip_duration_minutes END) AS avg_duration_casual,
	SUM(CASE WHEN member_casual='member' THEN trip_duration_minutes END) AS avg_duration_member

FROM 
	FullTableForPivot
	
GROUP BY rideable_type, primary_neigh

ORDER BY num_rides_casual DESC
