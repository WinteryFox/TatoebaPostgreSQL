BEGIN;

CREATE INDEX sentences_sentence_index ON sentences (sentence);

CREATE INDEX sentences_id_index ON sentences (id);

CREATE INDEX sentences_tsv_index ON sentences USING gin(tsv);

CREATE INDEX links_index ON links (source, translation);

CREATE INDEX audio_index ON audio (sentence);

CREATE INDEX tags_index ON tags (sentence, tag);

END;