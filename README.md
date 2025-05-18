# Netflix 2023 Viewership Analysis using SQL

## Overview
This project contains SQL scripts for analyzing Netflix viewership data for the year 2023. The scripts provide insights into viewership patterns, content types (movies vs. shows), language distribution, seasonal trends, and release strategies. The dataset is stored in a SQL Server database named `NETFLIX` with a table `netflix_2023`.

## Prerequisites
- **SQL Server**: Access to a SQL Server instance (e.g., Microsoft SQL Server or Azure SQL Database).
- **Database Setup**: The `NETFLIX` database must be created, and the `netflix_2023` table must be populated.
- **SQL Client**: Use SQL Server Management Studio (SSMS), Azure Data Studio, or another SQL client.

## Import the Data from flat file
Import the data from file option in the SSMS, it will automatically try to get the schema

## Setup Instructions
1. **Create the Database**:
   ```sql
   CREATE DATABASE NETFLIX;
   ```
2. **Use the Database**:
   ```sql
   USE NETFLIX;
   ```
3.  **Load Data**:
Load the Data using the option of Import from flat file.

4. **Data Verification**
    ```sql
   select * from netflix_2023;
   ```
5.  **Sample Data Output**
   ```sql
Title                                                                                                                                                                                                                                                            Available_Globally Release_Date Hours_Viewed Language_Indicator                                 Content_Type
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ------------------ ------------ ------------ -------------------------------------------------- --------------------------------------------------
The Night Agent: Season 1                                                                                                                                                                                                                                        1                  2023-03-23   812100000    English                                            Show
Ginny & Georgia: Season 2                                                                                                                                                                                                                                        1                  2023-01-05   665100000    English                                            Show
The Glory: Season 1 // 더 글로리: 시즌 1                                                                                                                                                                                                                               1                  2022-12-30   622800000    Korean                                             Show
Wednesday: Season 1                                                                                                                                                                                                                                              1                  2022-11-23   507700000    English                                            Show
Queen Charlotte: A Bridgerton Story                                                                                                                                                                                                                              1                  2023-05-04   503000000    English                                            Movie
You: Season 4                                                                                                                                                                                                                                                    1                  2023-02-09   440600000    English                                            Show
La Reina del Sur: Season 3                                                                                                                                                                                                                                       0                  2022-12-30   429600000    English                                            Show
Outer Banks: Season 3                                                                                                                                                                                                                                            1                  2023-02-23   402500000    English                                            Show
Ginny & Georgia: Season 1                                                                                                                                                                                                                                        1                  2021-02-24   302100000    English                                            Show
```
## SQL Scripts Overview
The scripts perform the following analyses:
1. **Comparison of Viewer Hours by Content Type**: Viewership hours by `Language` for movies and shows.
2. **Monthly Viewership in 2023**: Total viewership hours by month.
3. **Normal View for Monthly Viewership**: View (`NetflixMonthlyView`) for monthly viewership.
4. **Materialized View for Monthly Viewership**: Attempted materialized view (`NetflixMonthlyView1`).
5. **Total Hours Viewed by Language**: Viewership hours by `Language_Indicator`.
6. **Top 5 Titles by Viewership**: Top 5 titles by viewership hours.
7. **Stored Procedure for Dynamic Month Selection**: Query movie/show viewership for a specific month.
8. **Seasonal Viewership**: Viewership hours by season (Spring, Summer, Fall, Winter).
9. **Monthly Releases and Viewership**: Release counts and viewership by month.
10. **Weekly Release Patterns and Viewership**: Release counts and viewership by weekday, with rankings.

## Sample Query Outputs
Below are sample outputs for selected queries.

### 1. Comparison of Viewer Hours by Content Type for each Language
**Query**:
```sql
SELECT Language_Indicator as Language,
       SUM(CASE WHEN content_type = 'movie' THEN CAST(Hours_Viewed AS BIGINT) ELSE 0 END) AS movie_viewers,
       SUM(CASE WHEN content_type = 'show' THEN CAST(Hours_Viewed AS BIGINT) ELSE 0 END) AS show_viewers
FROM netflix_2023
GROUP BY Language_Indicator;
```

**Sample Output**:
```
Language                                           movie_viewers        Show_viewers
-------------------------------------------------- -------------------- --------------------
English                                            36300900000          88140800000
Japanese                                           2529500000           4572500000
Non-English                                        3591500000           6847600000
Russian                                            25200000             89400000
Hindi                                              604900000            321200000
Korean                                             7585800000           7792600000
```

### 2. Monthly Viewership in 2023
**Query**:
```sql
SELECT DATENAME(MONTH, Release_Date) AS Month,
       SUM(CAST(Hours_Viewed AS BIGINT)) AS TotalHours
FROM netflix_2023
WHERE Release_Date IS NOT NULL
GROUP BY DATENAME(MONTH, Release_Date), MONTH(Release_Date)
ORDER BY MONTH(Release_Date);
```

**Sample Output**:
```
Month                          TotalHours
------------------------------ --------------------
January                        7271600000
February                       7103700000
March                          7437100000
April                          6865700000
May                            7094600000
June                           8522000000
July                           6524800000
August                         6817800000
September                      7262200000
October                        8123200000
November                       7749500000
December                       10055800000
```


### 3. Normal View for Monthly Viewership: View (`NetflixMonthlyView`) for monthly viewership.
**Query**:
```sql
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
```
**Sample Output**:
```
Month                          TotalHours
------------------------------ --------------------
January                        7271600000
February                       7103700000
March                          7437100000
April                          6865700000
May                            7094600000
June                           8522000000
July                           6524800000
August                         6817800000
September                      7262200000
October                        8123200000
November                       7749500000
December                       10055800000

```


### 4. Materialized View for Monthly Viewership: Attempted materialized view (`NetflixMonthlyView1`).
**Query**:
```sql
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
```
**Sample Output**:
```sql
Month                          MonthNumber TotalHours
------------------------------ ----------- --------------------
January                        1           7271600000
February                       2           7103700000
March                          3           7437100000
April                          4           6865700000
May                            5           7094600000
June                           6           8522000000
July                           7           6524800000
August                         8           6817800000
September                      9           7262200000
October                        10          8123200000
November                       11          7749500000
December                       12          10055800000
```



### 5. Total Hours Viewed by Language: Viewership hours by `Language`.
**Query**:
```sql
select Language_Indicator as Language,
       SUM(CAST(Hours_Viewed AS BIGINT)) as Total_Hours_Viewed
       from netflix_2023
	   group by Language_Indicator
```
**Sample Output**:
```sql
Language                                           Total_Hours_Viewed
-------------------------------------------------- --------------------
English                                            124441700000
Japanese                                           7102000000
Non-English                                        10439100000
Russian                                            114600000
Hindi                                              926100000
Korean                                             15378400000
```


### 6. Top 5 Titles by Viewership
**Query**:
```sql
SELECT TOP 5 * FROM netflix_2023 ORDER BY Hours_Viewed DESC;
```

**Sample Output**:
```
Title                                                                                                                                                                                                                                                            Available_Globally Release_Date Hours_Viewed Language_Indicator                                 Content_Type
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ------------------ ------------ ------------ -------------------------------------------------- --------------------------------------------------
The Night Agent: Season 1                                                                                                                                                                                                                                        1                  2023-03-23   812100000    English                                            Show
Ginny & Georgia: Season 2                                                                                                                                                                                                                                        1                  2023-01-05   665100000    English                                            Show
King the Land: Limited Series // 킹더랜드: 리미티드 시리즈                                                                                                                                                                                                                  1                  2023-06-17   630200000    Korean                                             Movie
The Glory: Season 1 // 더 글로리: 시즌 1                                                                                                                                                                                                                               1                  2022-12-30   622800000    Korean                                             Show
ONE PIECE: Season 1                                                                                                                                                                                                                                              1                  2023-08-31   541900000    English                                            Show

```

### 7. Stored Procedure Example (February)
**Query**:
```sql
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
```

**Sample Output**:
```
Month                          movie_viewers        show_viewers
------------------------------ -------------------- --------------------
February                       1654400000           5449300000
```

### 8. Seasonal Viewership: Viewership hours by season (Spring, Summer, Fall, Winter).
**Query**:
```sql
SELECT SUM(CASE WHEN MONTH(Release_Date) >= 3 AND MONTH(Release_Date) <= 5 THEN CAST(Hours_Viewed AS BIGINT) ELSE 0 END) AS Spring,
       SUM(CASE WHEN MONTH(Release_Date) >= 6 AND MONTH(Release_Date) <= 8 THEN CAST(Hours_Viewed AS BIGINT) ELSE 0 END) AS Summer,
       SUM(CASE WHEN MONTH(Release_Date) >= 9 AND MONTH(Release_Date) <= 11 THEN CAST(Hours_Viewed AS BIGINT) ELSE 0 END) AS Fall,
       SUM(CASE WHEN MONTH(Release_Date) = 12 OR MONTH(Release_Date) <= 2 THEN CAST(Hours_Viewed AS BIGINT) ELSE 0 END) AS Winter
FROM netflix_2023;
```

**Sample Output**:
```
Spring               Summer               Fall                 Winter
-------------------- -------------------- -------------------- --------------------
21397400000          21864600000          23134900000          24431100000
```


### 9. Monthly Releases and Viewership: Release counts and viewership by month.
**Query**:
```sql
select DATENAME(MONTH,Release_Date) as Month, 
       count(*) as Total_Releases,
       sum(cast(Hours_Viewed as bigint)) as TotalHours 
	   from netflix_2023 
	   WHERE Release_Date is not null
	   group by DATENAME(MONTH,Release_Date), MONTH(release_date)
	   order by MONTH(release_date)
```
**Sample Output**:
```
Month                          Total_Releases TotalHours
------------------------------ -------------- --------------------
January                        608            7271600000
February                       560            7103700000
March                          690            7437100000
April                          647            6865700000
May                            624            7094600000
June                           670            8522000000
July                           631            6524800000
August                         674            6817800000
September                      739            7262200000
October                        802            8123200000
November                       734            7749500000
December                       787            10055800000
```

### 10. Weekly Release Patterns and Viewership: Release counts and viewership by weekday, with rankings.
**Query**:
```sql
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
```
**Sample Output**:
```
Week                           Total_Releases ReleaseRank          TotalHours           HoursRank
------------------------------ -------------- -------------------- -------------------- --------------------
Sunday                         179            7                    1935300000           7
Monday                         436            5                    3954500000           6
Tuesday                        995            4                    5562300000           4
Wednesday                      1310           2                    15744100000          3
Thursday                       1145           3                    20292800000          2
Friday                         3863           1                    38217200000          1
Saturday                       238            6                    5121800000           5
```



## How to Run
1. **Open SQL Client**: Connect to your SQL Server instance.
2. **Execute Scripts**:
   - Run `CREATE DATABASE NETFLIX;` and `USE NETFLIX;`.
   - Populate the `netflix_2023` table.
   - Execute queries or stored procedures as needed.
3. **Stored Procedure Example**:
   ```sql
   EXEC SelectMonth @MonthNum = 2;
   ```
4. **View Results**:
   - Normal view: `SELECT * FROM NetflixMonthlyView ORDER BY MonthNumber;`
   - Materialized view (if created): `SELECT * FROM dbo.NetflixMonthlyView1 ORDER BY MonthNumber;`
