BEGIN;

CREATE INDEX sentences_index ON sentences (id, sentence);

CREATE INDEX links_index ON links (source, translation);

CREATE INDEX audio_index ON audio (sentence);

CREATE INDEX tags_index ON tags (sentence, tag);

END;