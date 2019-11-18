# Tatoeba PostgreSQL Importer

This is a small tool to import the sentences, links, audio and tags
from the Tatoeba project into a PostgreSQL database. This tool was
written for [Jibiki](https://jibiki.app/) which is a free Japanese dictionary
website integrating many data sources into one.

### Dependencies

This tool requires the [textsearch_ja](https://github.com/oknj/textsearch_ja)
extension to be installed. Without this extension, the Japanese full text search
will not work.

#### Installing [textsearch_ja](https://github.com/oknj/textsearch_ja)

*If you are on Windows, you need to install [MinGW](https://sourceforge.net/projects/mingw-w64/) to use make*

1. Download [textsearch_ja](https://github.com/oknj/textsearch_ja) as ZIP and extract it
2. Open any command line utility
3. `cd` into the textsearch_ja folder
4. Run `make`
5. Run `make install`
6. Done!

### Usage

1. Download the jar from the releases tap of this page
2. Download and install [Java runtime 8](https://java.com/en/download/) or above
3. Open any command line utility (CMD on Windows and Terminal on Linux and Mac)
4. Navigate to the directory you downloaded the tool to using `cd DIRECTORY_HERE`
5. Run the following command to run the tool `java -jar TatoebaPostgreSQL.jar`
6. Follow the prompts on screen and then wait for it to install
8. Done!

### Example query

```sql
SELECT sentence FROM sentences WHERE tsv @@ to_tsquery('I like dogs!');
```

*Read more about [tsvector and tsquery](https://www.postgresql.org/docs/9.0/datatype-textsearch.html)*
