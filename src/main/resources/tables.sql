BEGIN;

DROP INDEX IF EXISTS sentences_index;

DROP INDEX IF EXISTS links_index;

DROP INDEX IF EXISTS audio_index;

DROP INDEX IF EXISTS tags_index;

DROP TABLE IF EXISTS sentences CASCADE;
CREATE TABLE sentences
(
    id       INT      NOT NULL PRIMARY KEY,
    lang     TEXT,
    sentence TEXT     NOT NULL,
    tsv      TSVECTOR
);

DROP FUNCTION IF EXISTS sentences_search_trigger();
CREATE FUNCTION sentences_search_trigger() RETURNS trigger AS
$$
begin
    new.tsv := setweight(to_tsvector(coalesce(new.sentence, '')), 'D');
    return new;
end
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tsvectorupdate ON sentences;
CREATE TRIGGER tsvectorupdate
    BEFORE INSERT OR UPDATE
    ON sentences
    FOR EACH ROW
EXECUTE PROCEDURE sentences_search_trigger();

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
    sentence    INT  NOT NULL,
    username    TEXT NOT NULL,
    license     TEXT,
    attribution TEXT,
    PRIMARY KEY (sentence, username)
);

DROP TABLE IF EXISTS tmp;
CREATE TABLE tmp AS
SELECT *
FROM audio
    WITH NO DATA;

DROP TABLE IF EXISTS tags;
CREATE TABLE tags
(
    sentence INT  NOT NULL,
    tag      TEXT NOT NULL,
    PRIMARY KEY (sentence, tag)
);

END;