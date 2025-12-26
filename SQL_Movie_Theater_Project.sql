/* ============================================================
   PROJECT: Movie Screening Management System
   CINEMA : Cine Grande Elegance
   SCREENS: 3
   MOVIES :
     1. Dhurandhar (4h 15m = 255 mins)
     2. Avatar 3  (4h = 240 mins)

   FEATURES:
   - Proper database design
   - Long-duration movie scheduling
   - 15-minute cleaning gap between shows
   - Business & analyst-focused SQL queries
   ============================================================ */


/* ============================================================
   STEP 1: DATABASE CREATION
   ============================================================ */

DROP DATABASE IF EXISTS movie_screening;
CREATE DATABASE movie_screening;
USE movie_screening;


/* ============================================================
   STEP 2: TABLE CREATION
   ============================================================ */

-- Cinema master table
CREATE TABLE cinema (
    cinema_id INT PRIMARY KEY AUTO_INCREMENT,
    cinema_name VARCHAR(100),
    city VARCHAR(50)
);

-- Screens available in the cinema
CREATE TABLE screen (
    screen_id INT PRIMARY KEY AUTO_INCREMENT,
    cinema_id INT,
    screen_name VARCHAR(20),
    capacity INT,
    FOREIGN KEY (cinema_id) REFERENCES cinema(cinema_id)
);

-- Movies metadata
CREATE TABLE movie (
    movie_id INT PRIMARY KEY AUTO_INCREMENT,
    movie_name VARCHAR(100),
    duration_minutes INT,
    language VARCHAR(30)
);

-- Show scheduling table
CREATE TABLE shows (
    show_id INT PRIMARY KEY AUTO_INCREMENT,
    screen_id INT,
    movie_id INT,
    show_date DATE,
    start_time TIME,
    end_time TIME,
    FOREIGN KEY (screen_id) REFERENCES screen(screen_id),
    FOREIGN KEY (movie_id) REFERENCES movie(movie_id)
);


/* ============================================================
   STEP 3: INSERT MASTER DATA
   ============================================================ */

-- Insert cinema details
INSERT INTO cinema (cinema_name, city)
VALUES ('Cine Grande Elegance', 'Mumbai');

-- Insert screen details (3 screens)
INSERT INTO screen (cinema_id, screen_name, capacity)
VALUES
(1, 'Screen 1', 180),
(1, 'Screen 2', 150),
(1, 'Screen 3', 120);

-- Insert movie details
INSERT INTO movie (movie_name, duration_minutes, language)
VALUES
('Dhurandhar', 255, 'Hindi'),
('Avatar 3', 240, 'English');


/* ============================================================
   STEP 4: SHOW SCHEDULING
   DATE          : 2025-01-01
   CLEANING GAP  : 15 minutes
   ============================================================ */

-- SCREEN 1: Only Dhurandhar shows
INSERT INTO shows VALUES
(NULL, 1, 1, '2025-01-01', '09:00:00', '13:15:00'),
(NULL, 1, 1, '2025-01-01', '13:30:00', '17:45:00'),
(NULL, 1, 1, '2025-01-01', '18:00:00', '22:15:00');

-- SCREEN 2: Only Avatar 3 shows
INSERT INTO shows VALUES
(NULL, 2, 2, '2025-01-01', '09:00:00', '13:00:00'),
(NULL, 2, 2, '2025-01-01', '13:15:00', '17:15:00'),
(NULL, 2, 2, '2025-01-01', '17:30:00', '21:30:00');


-- SCREEN 3: Mixed shows
INSERT INTO shows VALUES
(NULL, 3, 1, '2025-01-01', '10:00:00', '14:15:00'),
(NULL, 3, 2, '2025-01-01', '14:30:00', '18:30:00'),
(NULL, 3, 1, '2025-01-01', '18:45:00', '23:00:00');


/* ============================================================
   STEP 5: DATA VALIDATION QUERIES
   ============================================================ */

-- View all movies
SELECT * FROM movie;

-- View all screens
SELECT * FROM screen;

-- View all scheduled shows
SELECT * FROM shows;


/* ============================================================
   STEP 6: BUSINESS & ANALYTICAL QUERIES
   ============================================================ */

-- 1. Full show schedule with movie & screen details
SELECT 
    s.screen_name,
    m.movie_name,
    sh.show_date,
    sh.start_time,
    sh.end_time
FROM shows sh
JOIN screen s ON sh.screen_id = s.screen_id
JOIN movie m ON sh.movie_id = m.movie_id
ORDER BY s.screen_name, sh.start_time;

-- 2. List all shows of Dhurandhar
SELECT 
    s.screen_name,
    sh.start_time,
    sh.end_time
FROM shows sh
JOIN screen s ON sh.screen_id = s.screen_id
JOIN movie m ON sh.movie_id = m.movie_id
WHERE m.movie_name = 'Dhurandhar';

-- 3. Total number of shows per screen
SELECT 
    s.screen_name,
    COUNT(sh.show_id) AS total_shows
FROM screen s
LEFT JOIN shows sh ON s.screen_id = sh.screen_id
GROUP BY s.screen_name;

-- 4. Total screen usage time per screen (in hours)
SELECT 
    s.screen_name,
    ROUND(SUM(TIMESTAMPDIFF(MINUTE, sh.start_time, sh.end_time)) / 60, 2)
    AS total_hours_used
FROM shows sh
JOIN screen s ON sh.screen_id = s.screen_id
GROUP BY s.screen_name;

-- 5. Movie-wise total runtime across all screens
SELECT 
    m.movie_name,
    ROUND(SUM(TIMESTAMPDIFF(MINUTE, sh.start_time, sh.end_time)) / 60, 2)
    AS total_hours
FROM shows sh
JOIN movie m ON sh.movie_id = m.movie_id
GROUP BY m.movie_name;

-- 6. Evening shows (after 6 PM)
SELECT 
    s.screen_name,
    m.movie_name,
    sh.start_time,
    sh.end_time
FROM shows sh
JOIN screen s ON sh.screen_id = s.screen_id
JOIN movie m ON sh.movie_id = m.movie_id
WHERE sh.start_time >= '18:00:00';

-- 7. Maximum seating potential per screen per day
SELECT 
    s.screen_name,
    s.capacity,
    COUNT(sh.show_id) AS total_shows,
    s.capacity * COUNT(sh.show_id) AS max_daily_seating_capacity
FROM screen s
JOIN shows sh ON s.screen_id = sh.screen_id
GROUP BY s.screen_name, s.capacity;


/* ============================================================
   END OF PROJECT
   ============================================================ */