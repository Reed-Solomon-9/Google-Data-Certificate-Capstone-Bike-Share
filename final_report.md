# Casual Riders Vs. Subscription Members: Differences in Behavior

## For Cyclistic bicycle sharing company, July 2025

### Section 1: Project Overview

This analysis focuses on the behaviors of casual riders and subscription members who rode Cyclistic bikes in Chicago through their bike sharing service. The company would like to convert more casual riders to subscriptions, and tasked me with finding the ways in which the two groups behave differently. 
The data has a single observation for each ride. The key information that is missing from this data is a way to identify the riders themselves: I will not be able to connect the individual rides to the person riding the bike.

I am using one year of data from [divvy-tripdata](divvy-tripdata.s3.amazonaws.com) for the time period from May 2024 through April 2025. This was the most recent data available when I first loaded the data into my table on June 2nd.

It was made available under this license: [Data License Agreement | Divvy Bikes](https://divvybikes.com/data-license-agreement)

My goal for this project is to establish ways in which behavior differed between casual riders and subscription members, and to identify patterns that could potentially be relevant to the business goal of increasing the number of subscription members as a share of all riders.


### Section 2: Preparation, Data Integrity, and ETL

I began this project by previewing the first and last months of the data in RStudio in order to determine the schema, and whether the columns were the same for the entire year. I then used PostgreSQL (by way of the query tool in pgAdmin GUI) to clean, transform, and analyze the data.
First, I created a table for the entire year. I specified all the datatypes for the table, and included a check to ensure the locations specified by the starting and ending latitude and longitude columns were valid. 
Once the table was specified, I loaded the data into it using SQL. The table is composed of 12 CSV files organized consecutively.

I then checked the data for cleanliness and validity. I used COUNT DISTINCT and GROUP BY statements to determine the number of unique values for the character fields, and searched for null values in every column. The data is very clean, and every observation has a value in the primary key column.

I used a few more basic queries to check for the total number of observations (5,735,884) and to generally explore and get a feel for the data. 

### Section 3: Data Transformation

The data table contains the following dimensions: ride type, start station, end station, and whether the rider is a subscription member; plus the start time and end time. There was no quantitative data immediately available in the data, and the raw timestamps were not useful in their current form. It was necessary to create some calculated columns. 

I started with the quantitative measurements, because these can easily be used in every query without complicated grouping logic. I came up with three:

- **Number of rides**, derived using the COUNT function.

- **Trip duration**, derived by subtracting the start timestamp from the end timestamp and converting the interval to an EPOCH numeric datatype.

- **Absolute distance traveled**, derived through a simple trigonometric formula using the starting and ending longitude and latitude. This formula operated on the assumption of a flat plane of coordinates, which I believe is appropriate for a set of locations concentrated in a single city.

I then ran a series of queries grouping the data with SQL by both membership cohort and each of the qualitative columns, with the three measurements included. This yielded limited insight, so I began transforming the qualitative columns as well. I created the following calculated qualitative columns for my analysis: 

- **Month**, extracted from the ride start timestamp

- **Day of week**, extracted from the ride start timestamp

- **Hour**, extracted from the ride start timestamp

- **Trip direction**, derived using a CASE statement with a trigonometric function from the starting and ending longitude and latitude

- **Neighborhood**. This was created by spatial-joining my table to a GIS geometry table that I found on the City of Chicago website [(link: Boundaries - Neighborhoods | City of Chicago | Data Portal)](https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Neighborhoods/bbvz-uum9). I chose neighborhoods rather than zip codes or wards because they are more recognizable.

I created summary tables with SQL that featured each of these, and made simple visualizations for each to help with my understanding. For these, I also isolated rides where the rider did not actually go anywhere (likely never used the bike at all), and then updated my queries to exclude these zero-distance rides when I failed to find a useful pattern for when they happened. 

I also attempted to load the entire table into Tableau to allow me to more easily manipulate the data on the fly. However, the program would not run smoothly with a data table so large, especially once calculated fields were added. Nearly all data transformation was done through SQL.


### Section 4: Analysis

With my relevant columns having been created, I made an overview table in Google Sheets to summarize all of the relationships I was able to measure. I highlighted significant relationships in red, and small but potentially useful relationships in a light pink. 

<img width="1619" height="623" alt="Bike Trips Useful Relationships" src="https://github.com/user-attachments/assets/52147c50-2aac-4208-96d6-303e89f72b06" />

_(this table is also included in my repository as it may be too difficult to read in this format)_</br>
</br>
This gave me a somewhat comprehensive look at what is in the dataset. In terms of completeness, the logical next step would be to analyze combinations of multiple qualitative columns, but that could require hundreds of separate queries and charts, and likely a lot of wasted time.

This first analysis yielded some concrete insights about rider behavior, which I outline below, supported with visualizations from Tableau.

<img width="649" height="855" alt="Basics Dashboard" src="https://github.com/user-attachments/assets/f50569f1-90dc-4587-b881-d5aa9becd0c8" /></br>

Approximately 65% of trips were taken by subscription members.
Casual riders took longer trips (in terms of ride duration) than subscription members.
Both groups travelled similar distances.</br>
</br>

<img width="649" height="855" alt="Number of Rides by Month, Weekday, Hour" src="https://github.com/user-attachments/assets/d102eb33-dea6-490d-b74a-3173e1bd4f37" /></br>

- Number of rides followed a similar monthly pattern for members and casual riders. 
- By week, there was an opposite pattern: **casual** rides were **higher on weekends**, while **member** rides were **higher on weekdays**
- By hour, both groups took the most rides around 5pm (17:00 hour). However, for subscription members there were **two clear peaks**, one around 8am and one around 5pm.

<img width="479" height="850" alt="Chicago Neighborhoods by casual rider percentage" src="https://github.com/user-attachments/assets/7930a96b-7d2a-44c7-b7a3-e739487c216a" /></br>

Percentage of casual rides varies a lot between neighborhoods.
There was a high share of casual rides in neighborhoods in the **south** and **west** of the city, and generally far from the highest-density areas.
**Central neighborhoods** with lots of landmarks also had **relatively high** shares of casual rides.
**Inner ring neighborhoods** just outside of the city center, particularly to the north, had the **lowest** share of casual riders (highest share of subscribers). 


The other relationships between variables were less relevant to this analysis, so I focused on combining the most useful qualitative data.

I grouped the data by both day of week and time of day. First I determined that most of the difference in the numbers of casual rides and subscription members happened during the work week. 



Then I established a distinct difference between rider behavior during the work week (Monday through Friday) and the weekend. There was a clear pattern to rider behavior between these days, and though the pattern was more pronounced for subscription members, it was still clearly observable for casual riders.




Weekend rides gradually increased from the early morning to a flat peak from 11am to 5pm, while work week rides showed the hourly pattern where rides had a sharp peak from 7-9am, and then a larger sharp peak from 3-7pm. 

I also bucketed the 97 Chicago neighborhoods into three categories: Central, Inner Ring, and Outer Ring. These categories showed noticeable differences in rider behavior. 

On the map, this is how they are oriented:



Rides are broken down between these neighborhood categories as shown above.

Below is how they were distributed:




### Section 5: Conclusions

Behavior differs significantly between casual riders and subscription members by weekday. Many more midweek/work week riders are subscription members, while casual riders are more frequent users on weekends. This implies that subscription members use the bikes to commute to work.
Behavior also differs by neighborhood. Casual rides are most frequent as a share of all rides in the most high-traffic and tourist friendly neighborhoods like Millennium Park, Wrigleyville, Grant Park, Museum Campus, Streeterville, Gold Coast; as well as outer neighborhoods with far lower ride frequency like Lawndale, Brighton Park, and Ashburn. 
Ride behavior follows a consistent pattern by hour throughout the day. Rides are highest on weekdays (Monday through Friday) during morning and especially afternoon commute hours, while the daily distribution is a smooth curve on weekends (Saturday and Sunday) with the peak occurring from 11am to 5pm.
Subscription rides are most frequent as a share of all rides in inner ring neighborhoods like Little Italy, West Loop, East Village, and Douglas.
I’ve pinpointed a few neighborhoods, particularly Lakeview and Lincoln Park, that have a combination of large usage and relatively low subscription rate that may be worth targeting with neighborhood-specific promotions.
This dataset does not have any information on the riders themselves- only the information about each individual ride. Because of this, it is necessary to infer group differences between members and casual riders based on each group’s average behavior.
Subscription uptake is quite strong, meaning that gains will have to be made on the margins- either to increase already high subscription use in the inner ring neighborhoods, to convert a relatively small population in outer neighborhoods, or to convert the casual weekend users in central neighborhoods who are not just temporarily visiting the city.
A large majority (over 71%) of bike share users reside in inner ring neighborhoods of the city, such as Little Italy, River North, and the Lower West Side. These neighborhoods have strong subscription uptake, but they still contain a solid majority of casual riders. 
Riders starting from outer neighborhoods make up less than 8% of total rides. They have generally higher percentages of casual users, so it looks like there could be some opportunity for subscriber growth, but I think it’s important to note that from these locations, it is hard to position bike share rides as a viable alternative to the rail system for commuters.



### Section 6: Business Recommendations


After reviewing this dataset in a comprehensive manner, I propose the following business decisions. These may rely on other factors, but they are rooted in insights from this data.
Target the highest traffic inner ring neighborhoods with online targeted advertisements and neighborhood-specific promotions, and perhaps physical advertisements such as billboards/wallscapes/mural advertising. Chicago residents take pride in their neighborhoods, and the neighborhood names are highly recognizable. I believe they will respond well to neighborhood-specific appeals.
Target early morning weekday riders who are not subscribed. Casual riders ought to be shown how they can benefit from a subscription when they are making the decision to purchase a ride. Giving them this option for early rides will target the riders who would be most likely to want a subscription.
Present subscriptions differently on weekends versus weekdays. Weekend subscriptions could be offered as a way to enjoy the city, while the practicality of weekday commute hour subscriptions could be emphasized.
Consider a “nights and weekends” subscription option. This could be usable outside of commute hours, to segment the market and allow the offerings to be priced more optimally.
Consider a discount for longer rides in outer neighborhoods. Riders took longer rides from these neighborhoods, and they have significantly lower rates of subscription. If financially feasible, a discount could allow the bikes to be competitive with rail transportation. This could potentially be more efficient than advertising due to the lower concentration of riders.
