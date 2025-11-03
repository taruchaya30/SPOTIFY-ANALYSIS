# Spotify Data Analysis — SQL Project

# Project Overview
This project performs data analysis on Spotify tracks using SQL.
It explores various aspects such as artist performance, track popularity, album insights, and music characteristics like energy, danceability, and liveness.
The SQL queries help extract meaningful insights from the dataset and demonstrate the use of aggregate functions, window functions, CTEs (WITH clauses), subqueries, and conditional aggregation.

Table Structure

```sql
    CREATE TABLE SPOTIFY(
    Artist              VARCHAR(100),
    Track               VARCHAR(255),
    Album               VARCHAR(255),
    Album_type          VARCHAR(20),
    Danceability        DECIMAL(5,4),
    Energy              DECIMAL(5,4),
    Loudness            DECIMAL(6,3),
    Speechiness         DECIMAL(5,4),
    Acousticness        DECIMAL(5,4),
    Instrumentalness    DECIMAL(5,4),
    Liveness            DECIMAL(5,4),
    Valence             DECIMAL(5,4),
    Tempo               DECIMAL(7,3),
    Duration_min        DECIMAL(7,3),
    Title               VARCHAR(200),
    Channel             VARCHAR(100),
    Views               BIGINT,
    Likes               BIGINT,
    Comments            BIGINT,
    Licensed            BOOLEAN,
    Official_video      BOOLEAN,
    Stream              BIGINT,
    EnergyLiveness      DECIMAL(7,3),
    Most_playedon       VARCHAR(20)
);
```

Q1. Retrieve the names of all tracks that have more than 1 billion streams
Objective: Identify the most popular songs on Spotify with massive listener reach.


```sql

SELECT TRACK FROM SPOTIFY 
WHERE STREAM > 1000000000

```


Explanation:
This query filters tracks whose total streams exceed 1,000,000,000, giving a list of songs that crossed the 1B stream milestone.

Q2 List all albums along with their respective artists
Objective: Display the relationship between artists and the albums they’ve released.

```sql

SELECT DISTINCT ALBUM , ARTIST FROM SPOTIFY
ORDER BY 1

```
 
Explanation:
The DISTINCT keyword removes duplicate rows and ensures each album–artist pair appears only once.


Q3 Get the total number of comments for tracks where licensed = TRUE
Objective: Find how much engagement (comments) licensed tracks receive.

```sql

SELECT SUM(COMMENTS) AS TOTAL_COMMENTS FROM SPOTIFY
WHERE LICENSED = 'TRUE'

```

Explanation:
This sums up all comments on tracks that are officially licensed, giving total audience engagement for legal content.

Q4 all tracks that belong to the album type single
Objective: List all songs released as singles.

```sql

SELECT TRACK FROM SPOTIFY 
WHERE ALBUM_TYPE ILIKE '%SINGLE%'

```

Explanation:
The ILIKE operator (case-insensitive LIKE) ensures even if “Single” appears in different cases, it is included.

Q5 Count the total number of tracks by each artist
Objective: Identify how productive each artist is in terms of track releases.
```sql

SELECT DISTINCT(ARTIST), COUNT(TRACK) FROM SPOTIFY 
GROUP BY 1

```
Explanation:
Counts the number of tracks per artist, allowing ranking or comparison of artist productivity.

Q6 Calculate the average danceability of tracks in each album
Objective: Analyze how danceable each album is on average.

```sql

SELECT ALBUM, AVG(danceability) FROM SPOTIFY
GROUP BY ALBUM

```
Explanation:
Computes the mean danceability for every album, helping to compare which albums have more upbeat tracks.

Q7 Find the top 5 tracks with the highest energy values
Objective: Discover the most energetic tracks.
```sql

SELECT TRACK , MAX(energy) FROM SPOTIFY
GROUP BY TRACK
ORDER BY MAX(energy) DESC 
LIMIT 5

```
Explanation:
Orders tracks by their energy score and limits results to the top 5 most dynamic songs.

Q8 List all tracks along with their views and likes where official_video = TRUE
Objective: View engagement statistics for official music videos.
```sql

SELECT TRACK, SUM(VIEWS) AS TOTAL_VIEWS, SUM(LIKES) AS TOTAL_LIKES
FROM SPOTIFY 
WHERE  official_video = TRUE
GROUP BY TRACK

```
Explanation:
Aggregates total views and likes from all official video versions of each track.


Q9 For each album, calculate the total views of all associated tracks
Objective: Measure an album’s popularity based on view count.
```sql

SELECT ALBUM,track, SUM(VIEWS) AS TOTAL_VIEWS FROM SPOTIFY
GROUP BY ALBUM , track

```
Explanation:
Sums up views across all tracks in each album, showing which albums are most watched or streamed.


Q10 Retrieve the track names that have been streamed on Spotify more than YouTube
Objective: Compare streaming performance across platforms.
```sql

SELECT * FROM 
(SELECT TRACK,
COALESCE(SUM(CASE WHEN MOST_PLAYEDON='Spotify' THEN STREAM END),0) AS STREAMED_ON_SPOTIFY ,
COALESCE(SUM(CASE WHEN MOST_PLAYEDON='Youtube' THEN STREAM END),0) AS STREAMED_ON_YOUTUBE
FROM SPOTIFY
GROUP BY TRACK )
AS TABLE_2 
WHERE
STREAMED_ON_SPOTIFY >STREAMED_ON_YOUTUBE 
AND 
STREAMED_ON_YOUTUBE <> 0

```
Explanation:
Uses conditional aggregation to compare stream counts between Spotify and YouTube and returns tracks where Spotify leads.


Q11 Find the top 3 most-viewed tracks for each artist using window functions
Objective: Identify each artist’s most-viewed songs.
```sql

WITH RANK_TABLE
AS
(SELECT ARTIST, TRACK, SUM(VIEWS),
DENSE_RANK() OVER (PARTITION BY ARTIST ORDER BY SUM(VIEWS) DESC) AS RANK FROM SPOTIFY
GROUP BY 1 , 2
ORDER BY 1, 3 DESC)
SELECT * FROM RANK_TABLE
WHERE RANK <= 3`

```
Explanation:
Uses the DENSE_RANK() window function to rank tracks by view count within each artist, then filters for the top 3 per artist.

Q12 Write a query to find tracks where the liveness score is above the average
Objective: Discover tracks that are more “live” or energetic than average.
```sql

SELECT ARTIST , TRACK , LIVENESS FROM SPOTIFY
WHERE LIVENESS > (SELECT AVG(LIVENESS) FROM SPOTIFY)

```
Explanation:
Compares each track’s liveness score against the global average, returning only above-average performers.

Q13 Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album
Objective: Measure energy variability within albums.
```sql

WITH ENERGY_TABLE AS
(SELECT ALBUM, MAX(ENERGY) AS MAX_ENERGY , MIN(ENERGY) AS MIN_ENERGY FROM SPOTIFY
GROUP BY ALBUM) 
SELECT ALBUM , MAX_ENERGY - MIN_ENERGY  AS ENERGY_DIFFERENCE FROM ENERGY_TABLE
ORDER BY 2 DESC

```
Explanation:
This CTE calculates max and min energy for each album and then finds their difference to show consistency or diversity in sound.

Q14 Find tracks where the energy-to-liveness ratio is greater than 1.2
Objective: Detect tracks that are more energetic than their live performance feel.
```sql

SELECT TRACK FROM SPOTIFY 
WHERE ENERGY/LIVENESS > 1.2
AND ENERGY > 0
AND LIVENESS > 0

```
Explanation:
Avoids division by zero and finds tracks where energy levels significantly exceed liveness, often meaning studio-polished tracks.

# SQL Concepts Used
Aggregate Functions: SUM(), AVG(), MAX(), MIN()
Filtering: WHERE, ILIKE, logical operators
Grouping & Ordering: GROUP BY, ORDER BY
Joins via SubqueriesCommon Table Expressions (CTE): WITH clause
Window Functions: DENSE_RANK() OVER (PARTITION BY … ORDER BY …)
Conditional Aggregation: CASE WHEN with COALESCE()

# Sample Insights
The most streamed tracks cross 1 billion+ streams.
Artists with multiple high-energy tracks dominate playlists.
Danceability varies significantly by album type.
Certain songs perform better on Spotify compared to YouTube.
Licensed tracks receive higher engagement in comments and likes.

# Tech Stack
Language: SQL
Database: PostgreSQL 
Tools: pgAdmin

# How to Run
Create the table using the provided CREATE TABLE statement.
Load your dataset into the SPOTIFY table.
Run each query sequentially to view insights.
Modify query filters (e.g., stream thresholds, album types) for deeper analysis.

# Author
Taruchaya Shanker

