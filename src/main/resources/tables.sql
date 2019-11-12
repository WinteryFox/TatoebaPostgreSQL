DROP TABLE IF EXISTS sentences CASCADE;
CREATE TABLE sentences
(
    id       INT  NOT NULL PRIMARY KEY,
    lang     TEXT,
    sentence TEXT NOT NULL
);

DROP TABLE IF EXISTS links;
CREATE TABLE links
(
    source      INT NOT NULL,
    translation INT NOT NULL,
    PRIMARY KEY (source, translation)
);

DROP TABLE IF EXISTS audio;
CREATE TABLE audio
(
    sentence INT NOT NULL PRIMARY KEY,
    username TEXT NOT NULL,
    license TEXT,
    attribution TEXT
)