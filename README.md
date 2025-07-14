## Google-Data-Certificate-Capstone-Bike-Share
I am completing the capstone project for the Google Data Analytics Certificate. SQL code chunks and visualizations from Tableau will be included.

---


This is my capstone project for the Google Data Analytics Certificate. I completed the instruction for the certificate program in early June of 2025. The certificate contains a very broad look at the entire workflow of a data analyst, including data cleaning, transformation, analysis, visualization, and more. It features instruction on using spreadsheets, SQL, Tableau, and R. 

For the course, I took a detailed and exhaustive approach to learning- I did not believe there is any sense in saying I've learned something if I don't actually understand it. The quizzes and examinations in the GDAC are quite easy, but the quality of the instruction is solid. It also features hundreds of links to other sources of knowledge- nearly all of which I read, in many cases multiple times in order to understand concepts that were completely new to me.

I took a similar approach to the capstone analysis project. My primary goal for this project was to use SQL and Tableau in enough different ways, and with enough complexity, that I felt fully prepared to use those tools in a professional setting. 

If I were looking at software and data projects that people posted online, I'd like to know how they incorporate AI, so I will include how I used AI tools in this project. 
Generally, I used AI, specifically ChatGPT and Google Gemini Pro, as a **personal tutor**. Google's certificate course taught me the basics of tools like SQL and Business Intelligence software, but in many lessons I wanted to go much further that what was covered in the course, and AI was able to quickly find useful information. As I became more comfortable in the world of computer science, I would also incorporate Stack Overflow and other more traditional resources. The goal was always to improve my understanding, and I used AI to that end, while stubbornly making sure that I actually completed all my work by myself. Back when I was in school, I thrived when given the opportunity to ask questions- and AI gives a level of feedback that can only be found through tiny class sizes and 1-on-1 tutoring.

Amusingly, while working with AI to solve a few challenging problems, I actually found myself answering the questions that the AI model couldn't figure out, and I would politely educate it about where it went wrong.

### The project itself

Google provides a number of options for how to complete the capstone project. I chose the bike share company analysis _"Case Study 1: How does a bike-share navigate speedy success?"_ because it appeared to have a large, clean, and complete dataset associated with it. The project asks the analyst to determine the differences in behavior between casual riders and subscription members who use the bike share service, and it allows the analyst to determine what information can be gleaned from the data, and what might be useful from a business perspective. 

The first step was to actually load the data- and this was an extremely useful, though at times frustrating exercise. The project calls for one year's worth of data about bike trips in Chicago, and the data was organized by month on the source website (source: https://divvy-tripdata.s3.amazonaws.com/index.html). One year of data from June of 2024 through May of 2025 made up over 5.7 million combined observations and about 1.17GB - and even the individual monthly tables were too large to easily preview in either a spreadsheet or RStudio. It was also too large for me to use in the free sandbox version of Google BigQuery that I had been using to learn SQL. 

I'd heard a lot about PostgreSQL and I decided to download it. It was easy to install, although I had a difficult time at first with the graphical user interface. But the query tool made sense to me as it was just a SQL coding environment. I ran a few commands to create a table- I asked Google Gemini about the appropriate syntax for this as it was not covered in the certificate course. I also checked Gemini's work by reading about table creation on the w3schools website. 


```
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
```

This was difficult at first because I wasn't aware that PostgreSQL (and many data management systems) require the user to create an empty table before uploading the actual contents from eg. a .csv file. The SQL code here includes the basic DROP TABLE IF EXISTS and CREATE TABLE statements with my desired table name, and then I manually generate the schema by defining the column names with their corresponding datatypes, and then a character limit, which I believe is to prevent broken/super long fields from being uploaded. I had to navigate some issues with file editing permissions on my computer, but the table was created and populated fairly easily after the SQL was written.

I then began querying the data, first to make sure it was clean, which it very much was, and then to gather some information about how many unique entries existed for various dimensions, or qualitative data columns. I found that a simple query featuring a GROUP BY statment was a good approach here.

For the cohorts- there are 2 possible values here, plus the number of observations for each:
```
--determine number of rides for each main cohort.
SELECT
	member_casual,
	COUNT(*) AS num_rides
FROM
	bikeshare_06_24_to_05_25

GROUP BY member_casual
```
Output:
|member_casual|num_rides|
|:--------|:-------:|
|casual |	2112667 |
|member	| 3623217 |

And for the equipment being ridden, we have 3 possible values:
```
--determine number of rides for each option for ride types.
SELECT
	rideable_type,
	COUNT(*) AS num_rides
FROM
	bikeshare_06_24_to_05_25

GROUP BY rideable_type
```
Output:
|rideable_type|num_rides|
|:------------|----------:|
|classic_bike |	2533829 |
|electric_bike |	3057718 |
|electric_scooter	| 144337 |

After running a few other similar queries, I tried to determine what quantitative variables, or measurements, could be found in this table. After a bit of thought, and some trial and error, I settled on three:

-**Number of rides**: calculated through the COUNT function.

-**Trip Duration**: calculated by subtracting the start date/time from the end date/time. I learned through a few hiccups that I had to cast the INTERVAL datatype that was created by subtracting those timestamps to an EPOCH special date/time input (number of seconds since the beginning of the year 1970) in order for the resulting column to be a numeric datatype.

-**Absolute Distance Traveled**: calculated through a simple trigonometric formula using the coordinates that the rider started and ended at (the starting and ending stations). It is "as the crow flies".

These measurements could be used in any grouping of the data, so it was important to establish them first. It took some trial and error- I needed to fully wrap my head around grouping logic, most fundamentally how it features qualitative dimensions that are consolidated into single rows, and then these qualitative measures that are aggregated in some way with SUM, COUNT, AVG, and other functions. I explored the data by running a few queries where I grouped by month and day of week with just the number of rides before I thought to use other measurements.

After that came the dimensions. The project summary from Google suggested using day of week, and it seemed to follow logically that I could also derive month from the timestamps, plus the data was organized by month. I also organized by the ride type. 
At this point, I had:

**Dimensions: member/casual (primary cohorts being compared), ride type, day of week, and month.**

**Measures: number of rides, trip duration, and distance traveled.**

Tableau Public Desktop would not accept a 5.7 million row table, so I did the aggregation in PostgreSQL first and used seperate grouped tables for my visualizations. 
I made a dozen charts that looked like this:

<img width="648" height="704" alt="Duration by Week or Month and Ridetype" src="https://github.com/user-attachments/assets/f6e8ad27-190a-45af-b231-7f13e8680570" />

and determined a few basic insights about rider behavior. The only clear pattern that emerged between casual riders and members was that they took more trips in opposite parts of the week: 
Members took relatively more trips on Monday through Friday, and casual riders took more trips on weekends.

I found this unsatisfying, and wanted to do something more interesting with the tools I've learned. I came up with the idea to derive the direction traveled for each ride using the starting and ending coordinates.
I used this calculated field in my SELECT statement in SQL:
```
SELECT *,
	CASE WHEN (end_lat-start_lat) > 0 AND (end_lat-start_lat) >= (ABS(end_lng-start_lng) * 2.414213562) THEN 'North'
	WHEN (end_lat-start_lat) < 0 AND (start_lat-end_lat) >= (ABS(end_lng-start_lng) * 2.414213562) THEN 'South'
	WHEN (end_lng-start_lng) > 0 AND (end_lng-start_lng) >= (ABS(end_lat-start_lat) * 2.414213562) THEN 'East'
	WHEN (end_lng-start_lng) < 0 AND (start_lng-end_lng) >= (ABS(end_lat-start_lat) * 2.414213562) THEN 'West'
	WHEN (end_lat-start_lat) > 0 AND (end_lng-start_lng) > 0 AND (end_lat-start_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (end_lng-start_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Northeast'
	WHEN (end_lat-start_lat) > 0 AND (end_lng-start_lng) < 0 AND (end_lat-start_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (start_lng-end_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Northwest'
	WHEN (end_lat-start_lat) < 0 AND (end_lng-start_lng) > 0 AND (start_lat-end_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (end_lng-start_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Southeast'
	WHEN (end_lat-start_lat) < 0 AND (end_lng-start_lng) < 0 AND (start_lat-end_lat) < (ABS(end_lng-start_lng) * 2.414213562) AND (start_lng-end_lng) < (ABS(end_lat-start_lat)*2.414213562) THEN 'Southwest'
	ELSE 'None' END AS trip_direction
```
I originally set the ratio between the directions to 2 just to make the query work, then later I looked up some basic trigonometry and came up with 1 + square root of 2.
The directions dimension didn't lend a huge amount of insight. Both members and casual riders took longer trips traveling north and south as opposed to east and west, but that likely has to do with the geography of Chicago. 

Thinking about Chicago's geography gave me an idea, and that was to look at the locations where the riders started their rides from and try to categorize them somehow. I went to the City of Chicago website and found a table that contained the geometry of all the city's neighborhoods (source: https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Neighborhoods/bbvz-uum9). I figured I'd overlay the start station coordinates over this, but Tableau wouldn't accept the two tables without connecting them.
This is where things got difficult, and I started asking Gemini AI questions about how to connect these data tables. It suggested a "spatial join" which can be used in PostgreSQL after downloading its GIS (Geographic Information System) extension. 
After a tremendous amount of trial and error, over a hundred pages of instructions from Gemini, and a fair amount of frustration I was able to load a summary table with my three measurements joined to the map of Chicago neighborhoods into Tableau by way of QGIS software. 

<img width="479" height="850" alt="Chicago Neighborhoods by casual rider percentage" src="https://github.com/user-attachments/assets/d58e0507-4380-4f6f-a96b-f7692cd8d5cc" />

I added a calculated field to show how much the percentage of casual riders varies by neighborhood. This turned out to be, in my opinion, the most insightful way to use this dataset.

The next step was to organize all the ways that I had looked at the data, and record which relationships contained insight. I made a big spreadsheet with my three measures, plus all six dimensions used to organize the data (I ran a query for time of day as well, realizing I'd forgotten that). Lots of words here but this helped to guide me closer to my conclusions.

<img width="1621" height="627" alt="Useful Relationships for Bike Share dataset" src="https://github.com/user-attachments/assets/9fc39271-41fa-4c0b-a049-d9e268ed7310" />

I manually (using my subjective opinion) bucketed the neighborhoods into three natural categories: Central, Inner Ring, and Outer. I assigned the categories and then joined a small category table to my main grouped analysis table.   
The map of neighborhoods categorized:  

<img width="781" height="787" alt="Categorized Chicago Neighborhoods" src="https://github.com/user-attachments/assets/8a297c52-60c1-4f74-8d4a-3ab6060c95e8" />   <br> 
and the number of rides by category, for members and casual riders:

<img width="249" height="785" alt="Rides by Neighborhood Category" src="https://github.com/user-attachments/assets/ad80cff5-34e9-44b9-a0b2-4446c8c02afa" /> <br>
<br>
At this point, I had created a final analysis table containing all the relevant information that I believe might show significant insights about rider behavior, and about this project in general. I ran a query, which is saved in a separate file, that includes dimension columns for casual rider or member cohort, bike type, weekday, time of day by hour, neighborhood, and broad neighborhood category. I kept my same three measures- number of rides, ride duration, and absolute distance, although at this point my analysis is focused on number of rides as the most useful measurement. I loaded this table into Tableau, which gave me the ability to quickly manipulate visualizations on the fly in all the ways that I thought might be insightful. I included the most useful ones below: <br>

I sorted the number of rides by time of day and weekend (Saturday and Sunday) versus work week (Monday through Friday) to show the difference in the time of day patterns.
<img width="1023" height="829" alt="Weekend vs Work Week Rides" src="https://github.com/user-attachments/assets/4ce7dd50-e08f-4941-8f01-6d37402e8531" /> <br>
Clear patterns are visible: Rides were distributed smoothly on weekends, with a peak time around noon to 5pm, and there were two peaks on weekdays that coincide with regular commuting hours: 6am to 9am and 3pm to 6pm. These patterns held when I filtered for members and for casual riders: the pattern was especially pronounced for members, but still clearly existed for casual riders.

The existence of the weekday ride pattern where more rides are happening during commuting hours implies that there are still a nontrivial number of commuters who are using the bike share without subscribing: an ideal group for Cyclistic to target. I focused on this cohort a bit more, and isolated morning commuting hours. 



