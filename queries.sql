---- typical queries for this database

--- some typical SELECT queries
-- find ELO for an account, using the username to search
SELECT "ELO", "total_wins", "total_losses" FROM "players" WHERE "username" = ?;

-- find W/L ratio for an account, using the username to search
SELECT ROUND(1.0 * "total_wins"/"total_losses", 2) AS "win-to-loss ratio" FROM "players" WHERE "username" = ? AND "total_losses" != 0;

-- list all members in a club, using the view already provided
SELECT "players"."username" FROM "clubs_and_members" WHERE "clubs"."name" = ?;

-- list puzzles and order by their ratings. We expect low ratings to have high solve rates
SELECT "id", ROUND(1.0 * "num_solved"/"num_attempts", 2) as "puzzle solve rate" FROM "puzzles" ORDER BY "rating" ASC WHERE "num_attempts" > 0;

--- typical INSERT queries
-- create new account, registered with a username and password
-- something to consider here is hashing the password
INSERT INTO players (username, password) VALUES ('example_username', 'example_password');

-- create new puzzle today.
-- this shows the benefit of having many default values (0 for attempts, and date being the current timestamp)
INSERT INTO "puzzles" ("rating", "game_id") VALUES (1400, 5);

-- add game into db that just finished. This would tie into the UPDATE queries below.
INSERT INTO "games" ("p1_id", "p2_id", "time_control", "game_result") VALUES ((player 1 id), (player 2 id), 10, "p1_win");

--- typical UPDATE queries
-- update ELO of two players after they finish a game
UPDATE "players" SET "ELO" = "ELO" + 9, "total_wins" = "total_wins" + 1 WHERE "username" = (winner of game);
UPDATE "players" SET "ELO" = "ELO" - 8, "total_losses" = "total_losses" + 1 WHERE "username" = (loser of game);

-- add a player to a club. we need to both update the player's club_id, and increment num_members in the club
UPDATE "players" SET "club_id" = (SELECT "id FROM "clubs" WHERE "name" = (club_name)) WHERE "username" = (player_name);
UPDATE "clubs" SET "num_members" = "num_members" + 1 WHERE "name" = (club_name);

--- typical DELETE queries
-- deleting player account
DELETE FROM "players" WHERE "username" = ?;

-- deleting a club, cascade takes care of the rest
DELETE FROM "clubs" WHERE "name" = ?;

-- deleting any puzzles that are more than 2 months old and have not been attempted yet
DELETE FROM "puzzles" WHERE "release_date" < DATE('now', '-60 days') AND "num_attempts" = 0;

