BEGIN;

CREATE EXTENSION IF NOT EXISTS textsearch_ja;

DROP INDEX IF EXISTS sentences_index;

DROP INDEX IF EXISTS links_index;

DROP INDEX IF EXISTS audio_index;

DROP INDEX IF EXISTS tags_index;

DROP TABLE IF EXISTS sentences CASCADE;
DROP TRIGGER IF EXISTS tsvectorupdate ON sentences;
DROP FUNCTION IF EXISTS sentences_search_trigger();

DROP TABLE IF EXISTS links;
DROP TRIGGER IF EXISTS linksinsert ON links;
DROP FUNCTION IF EXISTS links_trigger();

DROP TABLE IF EXISTS audio;
DROP TRIGGER IF EXISTS audioinsert ON audio;
DROP FUNCTION IF EXISTS audio_trigger();

DROP TABLE IF EXISTS tags;
DROP TRIGGER IF EXISTS tagsinsert ON tags;
DROP FUNCTION IF EXISTS tags_insert();

/**
  Sentences
 */

CREATE TABLE sentences
(
    id       INT      NOT NULL PRIMARY KEY,
    lang     TEXT     NOT NULL,
    sentence TEXT     NOT NULL,
    tsv      TSVECTOR NOT NULL
);

CREATE FUNCTION sentences_search_trigger() RETURNS trigger AS
$$
BEGIN
    IF (new.lang = 'eng') THEN
        new.tsv := setweight(to_tsvector('english', coalesce(new.sentence, '')), 'D');
    ELSEIF (new.lang = 'jpn') THEN
        new.tsv := setweight(to_tsvector('japanese', coalesce(new.sentence, '')), 'D');
    ELSEIF (new.lang IS NULL) THEN
        return NULL;
    ELSE
        new.tsv := setweight(to_tsvector(coalesce(new.sentence, '')), 'D');
    END IF;
    return new;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER tsvectorupdate
    BEFORE INSERT OR UPDATE
    ON sentences
    FOR EACH ROW
EXECUTE PROCEDURE sentences_search_trigger();

/**
  Links
 */

CREATE TABLE links
(
    source      INT NOT NULL REFERENCES sentences (id),
    translation INT NOT NULL REFERENCES sentences (id),
    PRIMARY KEY (source, translation)
);

CREATE FUNCTION links_trigger() RETURNS trigger AS
$$
DECLARE
    count INTEGER := (SELECT count(*)
                      FROM sentences s
                      WHERE s.id = new.source
                         OR s.id = new.translation);
BEGIN
    IF count = 2 THEN
        return new;
    ELSE
        return NULL;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER linksinsert
    BEFORE INSERT OR UPDATE
    ON links
    FOR EACH ROW
EXECUTE PROCEDURE links_trigger();

/**
  Audio
 */

CREATE TABLE audio
(
    sentence    INT  NOT NULL REFERENCES sentences (id),
    username    TEXT NOT NULL,
    license     TEXT,
    attribution TEXT,
    PRIMARY KEY (sentence, username)
);

CREATE FUNCTION audio_trigger() RETURNS trigger AS
$$
DECLARE
    sentenceCount INTEGER := (SELECT count(*)
                         FROM sentences
                         WHERE id = new.sentence);
    audioCount    INTEGER := (SELECT count(*)
                         FROM audio
                         WHERE sentence = new.sentence
                           AND username = new.username);
BEGIN
    IF sentenceCount = 0 OR audioCount > 0 OR new.username IS NULL THEN
        return null;
    ELSE
        return new;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER audioinsert
    BEFORE INSERT OR UPDATE
    ON audio
    FOR EACH ROW
EXECUTE PROCEDURE audio_trigger();

/**
  Tags
 */

CREATE TABLE tags
(
    sentence INT  NOT NULL REFERENCES sentences(id),
    tag      TEXT NOT NULL,
    PRIMARY KEY (sentence, tag)
);

CREATE FUNCTION tags_insert() RETURNS trigger AS
$$
DECLARE
    sentenceCount INTEGER := (SELECT count(*)
                              FROM sentences
                              WHERE id = new.sentence);
BEGIN
    IF sentenceCount = 0 THEN
        return null;
    ELSE
        return new;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER tagsinsert
    BEFORE INSERT OR UPDATE
    ON tags
    FOR EACH ROW
EXECUTE PROCEDURE tags_insert();

END;