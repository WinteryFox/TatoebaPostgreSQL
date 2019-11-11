DROP TABLE IF EXISTS sentences CASCADE;
CREATE TABLE sentences
(
    id       INT  NOT NULL PRIMARY KEY,
    lang     TEXT NOT NULL,
    sentence TEXT NOT NULL
)