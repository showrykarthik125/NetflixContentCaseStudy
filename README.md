# Netflix 2023 Viewership Analysis

## Overview
This project contains SQL scripts for analyzing Netflix viewership data for the year 2023. The scripts provide insights into viewership patterns, content types (movies vs. shows), language distribution, seasonal trends, and release strategies. The dataset is stored in a SQL Server database named `NETFLIX` with a table `netflix_2023`.

## Prerequisites
- **SQL Server**: Access to a SQL Server instance (e.g., Microsoft SQL Server or Azure SQL Database).
- Délégation de l'administration du serveur SQL : Assurez-vous que l'utilisateur dispose des autorisations nécessaires pour créer des bases de données, des tables, des vues et des procédures stockées.
- **Database Setup**: The `NETFLIX` database must be created, and the `netflix_2023` table must be populated.
- **SQL Client**: Use SQL Server Management Studio (SSMS), Azure Data Studio, or another SQL client.

## Database Schema
The `netflix_2023` table is expected to include:
- `Hours_Viewed`: Viewership hours (string or numeric, cast to `BIGINT` in queries).
- `Content_Type`: `movie` or `show`.
- `Language_Indicator`: Language of the content.
- `Release_Date`: Release date of the content.
- Other columns may exist but are not used in all queries.

## Setup Instructions
1. **Create the Database**:
   ```sql
   CREATE DATABASE NETFLIX;
   ```
2. **Use the Database**:
   ```sql
   USE NETFLIX;
   ```
3. **Load Data**:
   Populate the `netflix_2023` table with your dataset. Example schema:
   ```sql
   CREATE TABLE netflix_2023 (
       Title NVARCHAR(255),
       Hours_Viewed NVARCHAR(50), -- Cast to BIGINT in queries
       Content_Type NVARCHAR(50),
       Language_Indicator NVARCHAR(50),
       Release_Date DATE
       -- Add other columns as needed
   );
   ```
   Use `BULK INSERT`, SSMS Import Wizard, or other methods to load data.

## SQL Scripts Overview
The scripts perform the following analyses:
1. **Comparison of Viewer Hours by Content Type**: Viewership hours by `Language_Indicator` for movies and shows.
2. **Monthly Viewership in 2023**: Total viewership hours by month.
3. **Normal View for Monthly Viewership**: View (`NetflixMonthlyView`) for monthly viewership.
4. **Materialized View for Monthly Viewership**: Attempted materialized view (`NetflixMonthlyView1`), with limitations (see [Known Issues](#known-issues)).
5. **Total Hours Viewed by Language**: Viewership hours by `Language_Indicator`.
6. **Top 5 Titles by Viewership**: Top 5 titles by viewership hours.
7. **Content Type Comparison by Month**: Movie vs. show viewership by month.
8. **Stored Procedure for Dynamic Month Selection**: Query movie/show viewership for a specific month.
9. **Seasonal Viewership**: Viewership hours by season (Spring, Summer, Fall, Winter).
10. **Monthly Releases and Viewership**: Release counts and viewership by month.
11. **Weekly Release Patterns and Viewership**: Release counts and viewership by weekday, with rankings.

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

### 3. Top 5 Titles by Viewership
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

### 4. Seasonal Viewership
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


### 5. Stored Procedure Example (February)
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
