## Google-Data-Certificate-Capstone-Bike-Share
I am completing the capstone project for the Google Data Analytics Certificate. SQL code chunks and visualizations from Tableau will be included.

---


This is my capstone project for the Google Data Analytics Certificate. I completed the instruction for the certificate program in early June of 2025. The certificate contains a very broad look at the entire workflow of a data analyst, including data cleaning, transformation, analysis, visualization, and more. It features instruction on using spreadsheets, SQL, Tableau, and R. 

For the course, I took a detailed and exhaustive approach to learning- I did not believe there is any sense in saying I've learned something if I don't actually understand it. The quizzes and examinations in the GDAC are quite easy, but the quality of the instruction is solid. It also features hundreds of links to other sources of knowledge- nearly all of which I read, in many cases multiple times in order to understand concepts that were completely new to me.

I took a similar approach to the capstone analysis project. My primary goal for this project was to use SQL and Tableau in enough different ways, and with enough complexity, that I felt fully prepared to use those tools in a professional setting. 

If I were looking at software and data projects that people posted online in 2025, I'd like to know how they incorporate AI, so I include how I used AI tools in this project. 
Generally, I used AI, specifically ChatGPT and Google Gemini Pro, as a **personal tutor**. Google's certificate course taught me the basics of tools like SQL and Business Intelligence software, but in many lessons I wanted to go much further that what was covered in the course, and AI was able to quickly find useful information. As I became more comfortable in the world of computer science, I would also incorporate Stack Overflow and other more traditional resources. The goal was always to improve my understanding, and I used AI to that end, while stubbornly making sure that I actually completed all my work by myself. Back when I was in school, I thrived when given the opportunity to ask questions- and AI gives a level of feedback that can only be found through tiny class sizes and 1-on-1 tutoring.

Amusingly, while working with AI to solve a few challenging problems, I actually found myself answering the questions that the AI model couldn't figure out, and I would politely educate it about where it went wrong.

The project is an analysis of rider behavior for a fictional bike sharing company called Cyclistic that does business in Chicago. The business task is to establish differences in rider behavior between subscription members and casual riders, with the goal of converting casual riders to subscribers.

For this project, I queried the data using PostgreSQL. I used Tableau business intelligence software to create visualizations, and I used QGIS software to convert tables to geometric data that could be understood by Tableau. 
I did some exploratory analysis using Google Sheets as well.

Rather than including dozens of queries in seperate files for this repository, I stored most of my SQL code in the Queries_Bike_Share_GDA.sql file. PostgreSQL query tool allows code chunks to be easily run individually. I saved the large query for the table I used for my conclusions in a seperate file.
My SQL files contain a few items in the SELECT and GROUP BY statements that are commented out, to allow the queries to be easily customized.

In total, this repository contains:

- My final report (final_report.md)
- A detailed description of the steps taken to complete the project (Project_Description_and_Progression.md)
- 2 SQL files containing the queries I used through PostgreSQL (Queries_Bike_Share_GDA.sql, final_analysis_query.sql)
- A packaged Tableau workbook containing all the visualizations I used for this project (GDA Bike Sharing Dashboard v2 Packaged__10439.twbr)
- A spreadsheet that organizes the relationships I found in the data (Bike Trips_ Useful Relationships.xlsx)
- and this README file.