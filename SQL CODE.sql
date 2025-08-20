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
    official_video      BOOLEAN,
    Stream              BIGINT,
    EnergyLiveness      DECIMAL(7,3),
    most_playedon       VARCHAR(20)
)

SELECT * FROM SPOTIFY

-- Q1 Retrieve the names of all tracks that have more than 1 billion streams
SELECT TRACK FROM SPOTIFY 
WHERE STREAM > 1000000000

-- Q2 List all albums along with their respective artists
SELECT DISTINCT ALBUM , ARTIST FROM SPOTIFY
ORDER BY 1

-- Q3 Get the total number of comments for tracks where licensed = TRUE
SELECT SUM(COMMENTS) AS TOTAL_COMMENTS FROM SPOTIFY
WHERE LICENSED = 'TRUE'

-- Q4 all tracks that belong to the album type single
SELECT TRACK FROM SPOTIFY 
WHERE ALBUM_TYPE ILIKE '%SINGLE%'

-- Q5 Count the total number of tracks by each artist
SELECT DISTINCT(ARTIST), COUNT(TRACK) FROM SPOTIFY 
GROUP BY 1

-- Q6 Calculate the average danceability of tracks in each album
SELECT ALBUM, AVG(danceability) FROM SPOTIFY
GROUP BY ALBUM

-- Q7 Find the top 5 tracks with the highest energy values
SELECT TRACK , MAX(energy) FROM SPOTIFY
GROUP BY TRACK
ORDER BY MAX(energy) DESC 
LIMIT 5

-- Q8 List all tracks along with their views and likes where official_video = TRUE
SELECT TRACK, SUM(VIEWS) AS TOTAL_VIEWS, SUM(LIKES) AS TOTAL_LIKES
FROM SPOTIFY 
WHERE  official_video = TRUE
GROUP BY TRACK

-- Q9 For each album, calculate the total views of all associated tracks
SELECT ALBUM,track, SUM(VIEWS) AS TOTAL_VIEWS FROM SPOTIFY
GROUP BY ALBUM , track

-- Q10 Retrieve the track names that have been streamed on Spotify more than YouTube
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

-- Q11 Find the top 3 most-viewed tracks for each artist using window functions
WITH RANK_TABLE
AS
(SELECT ARTIST, TRACK, SUM(VIEWS),
DENSE_RANK() OVER (PARTITION BY ARTIST ORDER BY SUM(VIEWS) DESC) AS RANK FROM SPOTIFY
GROUP BY 1 , 2
ORDER BY 1, 3 DESC)
SELECT * FROM RANK_TABLE
WHERE RANK <= 3

-- Q12 Write a query to find tracks where the liveness score is above the average
SELECT ARTIST , TRACK , LIVENESS FROM SPOTIFY
WHERE LIVENESS > (SELECT AVG(LIVENESS) FROM SPOTIFY)

-- Q13 Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album
WITH ENERGY_TABLE AS
(SELECT ALBUM, MAX(ENERGY) AS MAX_ENERGY , MIN(ENERGY) AS MIN_ENERGY FROM SPOTIFY
GROUP BY ALBUM) 
SELECT ALBUM , MAX_ENERGY - MIN_ENERGY  AS ENERGY_DIFFERENCE FROM ENERGY_TABLE
ORDER BY 2 DESC

-- Q14 Find tracks where the energy-to-liveness ratio is greater than 1.2
SELECT TRACK FROM SPOTIFY 
WHERE ENERGY/LIVENESS > 1.2
AND ENERGY > 0
AND LIVENESS > 0


