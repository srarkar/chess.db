-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it


CREATE TABLE "players" (
    "id" INTEGER NOT NULL,
    "username" TEXT NOT NULL UNIQUE,
    "password" TEXT NOT NULL,
    "reg_datetime" TEXT DEFAULT (DATETIME('now')),
    "ELO" INTEGER NOT NULL CHECK("ELO" >= 100) DEFAULT 1000, -- min ELO is 100, and new accounts start at 1000
    "total_wins" INTEGER NOT NULL DEFAULT 0,
    "total_losses" INTEGER NOT NULL DEFAULT 0,
    "club_id" INTEGER DEFAULT NULL, -- NULL if player has not joined a club, including a new account. is set to NULL if a club is deleted
    PRIMARY KEY("id"),
    FOREIGN KEY("club_id") REFERENCES "clubs"."id" ON DELETE SET NULL
);

CREATE TABLE "clubs" (
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL UNIQUE,
    "num_members" INTEGER NOT NULL DEFAULT 0 CHECK("num_members" >= 0 AND "num_members" <= "max_members"),
    "max_members" INTEGER NOT NULL CHECK("max_members" > 0),
    "club_category" TEXT NOT NULL CHECK("club_category" IN ('casual', 'tournament', 'school', 'community')),
    PRIMARY KEY("id")
);

CREATE TABLE "games" (
    "id" INTEGER NOT NULL,
    "p1_id" INTEGER NOT NULL,
    "p2_id" INTEGER NOT NULL,
    "time_control" INTEGER NOT NULL CHECK ("time_control" >= 1),
    "game_result" TEXT NOT NULL CHECK("game_result" = "p1_win" OR "game_result" = "p2_win" OR "game_result" = "draw"),
    PRIMARY KEY("id"),
    FOREIGN KEY(p1_id) REFERENCES "players"."id" ON DELETE CASCADE, -- remove games from the database if at least one of the player accounts is deleted
    FOREIGN KEY(p2_id) REFERENCES "players"."id" ON DELETE CASCADE
);

CREATE TABLE "puzzles" (
    "id" INTEGER NOT NULL,
    "release_date" TEXT NOT NULL CHECK("release_date" <= (DATE('now'))) DEFAULT (DATE('now')), -- when the puzzle was released to the site
    "rating" INTEGER NOT NULL CHECK("rating" >= 100),
    "game_id" INTEGER, -- game where the puzzle was taken from. If game is deleted, set to NULL
    "num_attempts" INTEGER NOT NULL CHECK("num_attempts" >= 0) DEFAULT 0,
    "num_solved" INTEGER NOT NULL CHECK("num_solved" >= 0) DEFAULT 0,
    PRIMARY KEY("id"),
    FOREIGN KEY ("game_id") REFERENCES "games"."id" ON DELETE SET NULL
);

-- View that lists all players that belong to clubs, and the name of the club they belong to.
-- Also shows the current number of people in the club, and capacity.
-- Useful for searching for a player searching for a club to join.
CREATE VIEW "clubs_and_members" AS SELECT "players"."username", "clubs"."name", "clubs"."num_members", "clubs"."max_members" FROM "players" INNER JOIN "clubs" ON "players"."club_id" = "clubs"."id" WHERE "players"."club_id" IS NOT NULL;

-- View that displays the puzzle ids from the past month. It is very common on chess websites to have a calendar of puzzles.
CREATE VIEW "monthly_puzzles" AS SELECT * FROM "puzzles" WHERE "release_date" >= date('now', '-30 days');

-- View that shows game history
CREATE VIEW "player_games" AS SELECT id AS game_id, p1_id AS player_id FROM games UNION SELECT id, p2_id FROM games;

-- index for player usernames
CREATE INDEX "player_usernames" ON "players"("username");

-- index for clubs based on category
CREATE INDEX "club_categorical" ON "clubs" ("club_category");

-- index for puzzles based on when they were released (easy to find daily puzzles)
CREATE INDEX "puzzle_release_date" ON "puzzles" ("release_date");
