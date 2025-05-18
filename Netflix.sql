CREATE DATABASE NETFLIX;

USE NETFLIX;


select * from netflix_2023;


-- Comparision of viewer_hours between Movie and Show Type
select Language_Indicator as Language,
       SUM(CASE WHEN content_type = 'movie' THEN cast(Hours_Viewed as bigint) ELSE 0 END) AS movie_viewers,
	   SUM(CASE WHEN content_type = 'show' THEN cast(Hours_Viewed as bigint) ELSE 0 END) AS Show_viewers
	   from netflix_2023
	   group by Language_Indicator;

-- Monthly viewership in the year of 2023
select DATENAME(MONTH,Release_Date) as Month, 
       sum(cast(Hours_Viewed as bigint)) as TotalHours 
	   from netflix_2023 
	   WHERE Release_Date is not null
	   group by DATENAME(MONTH,Release_Date), MONTH(release_date) 
	   order by MONTH(release_date)

-- Creating a Normal view for Monthly viewership in the year of 2023

CREATE OR ALTER VIEW NetflixMonthlyView
AS
SELECT TOP 100 PERCENT 
       DATENAME(MONTH, Release_Date) AS Month,
       MONTH(Release_Date) AS MonthNumber, -- Added for sorting
       SUM(CAST(Hours_Viewed AS BIGINT)) AS TotalHours
FROM netflix_2023
WHERE Release_Date IS NOT NULL
GROUP BY DATENAME(MONTH, Release_Date), MONTH(Release_Date)
ORDER BY MONTH(Release_Date);

select Month,TotalHours from NetflixMonthlyView order by MonthNumber

-- Creating a Materialised view for Monthly viewership in the year of 2023

CREATE VIEW [dbo].NetflixMonthlyView1 WITH SCHEMABINDING as(
SELECT TOP 100 PERCENT 
       DATENAME(MONTH, Release_Date) AS Month,
       MONTH(Release_Date) AS MonthNumber, -- Added for sorting
       SUM(CAST(Hours_Viewed AS BIGINT)) AS TotalHours
FROM [dbo].netflix_2023
WHERE Release_Date IS NOT NULL
GROUP BY DATENAME(MONTH, Release_Date), MONTH(Release_Date)
ORDER BY MONTH(Release_Date)
)

select * from dbo.NetflixMonthlyView1 order by MonthNumber

-- Total_Hours_Viewed in each Language
select Language_Indicator as Language,
       SUM(CAST(Hours_Viewed AS BIGINT)) as Total_Hours_Viewed
       from netflix_2023
	   group by Language_Indicator


-- Top 5 Titles with Largest Viewership
select Top 5 * from netflix_2023 order by Hours_Viewed desc;


-- Comparision of content_Type each month

select DATENAME(MONTH,Release_Date) as Month,
       SUM(CASE WHEN content_type = 'movie' THEN cast(Hours_Viewed as bigint) ELSE 0 END) AS movie_viewers,
       SUM(CASE WHEN content_type = 'show' THEN cast(Hours_Viewed as bigint) ELSE 0 END) AS show_viewers
	   from netflix_2023
	   WHERE Release_Date is not null
	   group by DATENAME(MONTH,Release_Date),MONTH(release_date)
	   order by MONTH(release_date)


-- CREATE a stored procedure to select the Month dynamically to find Total viewers

CREATE PROCEDURE SelectMonth @MonthNum int
AS
select DATENAME(MONTH,Release_Date) as Month,
       SUM(CASE WHEN content_type = 'movie' THEN cast(Hours_Viewed as bigint) ELSE 0 END) AS movie_viewers,
       SUM(CASE WHEN content_type = 'show' THEN cast(Hours_Viewed as bigint) ELSE 0 END) AS show_viewers
	   from netflix_2023
	   WHERE Release_Date is not null AND MONTH(release_date) = @MonthNum
	   group by DATENAME(MONTH,Release_Date), MONTH(release_date)
	   order by MONTH(release_date)

exec SelectMonth @MonthNum = 2


-- Total Hours Viewership by each season

select * from netflix_2023;

select 
       SUM(CASE WHEN MONTH(Release_Date) >= 3 AND MONTH(Release_Date) <= 5 THEN cast(Hours_Viewed as bigint) ELSE 0 END) AS Spring,
	   SUM(CASE WHEN MONTH(Release_Date) >= 6 AND MONTH(Release_Date) <= 8 THEN cast(Hours_Viewed as bigint) ELSE 0 END) AS Summer,
	   SUM(CASE WHEN MONTH(Release_Date) >= 9 AND MONTH(Release_Date) <= 11 THEN cast(Hours_Viewed as bigint) ELSE 0 END) AS Fall,
	   SUM(CASE WHEN MONTH(Release_Date) = 12 OR MONTH(Release_Date) <= 2 THEN cast(Hours_Viewed as bigint) ELSE 0 END) AS Winter
	   from netflix_2023


-- Monthly Releases and Total Hours Viewership

select DATENAME(MONTH,Release_Date) as Month, 
       count(*) as Total_Releases,
       sum(cast(Hours_Viewed as bigint)) as TotalHours 
	   from netflix_2023 
	   WHERE Release_Date is not null
	   group by DATENAME(MONTH,Release_Date), MONTH(release_date)
	   order by MONTH(release_date)

-- Weekly Release Patterns and Hours Viewership

select DATENAME(WEEKDAY,Release_Date) as Week, 
       count(*) as Total_Releases,
	   rank() over(order by count(*) desc) as ReleaseRank,
       sum(cast(Hours_Viewed as bigint)) as TotalHours,
	   rank() over(order by sum(cast(Hours_Viewed as bigint)) desc) as HoursRank
	   from netflix_2023 
	   WHERE Release_Date is not null
	   group by DATENAME(WEEKDAY,Release_Date),DATEPART(WEEKDAY, Release_Date)
ORDER BY
     DATEPART(WEEKDAY, Release_Date)