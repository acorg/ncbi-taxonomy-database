#!/bin/bash

set -Eeuo pipefail

case $# in
    2)
        names="$1"
        dbfile="$2"
        ;;
    *) echo "Usage: $(basename $0) name-file db-file" >&2; exit 1;;
esac

tmp=$(mktemp)
trap 'rm -f $tmp' 0 1 2 3 15

# Be careful with TABs in the next line.
egrep '\|	scientific name	\|' $names | tr -d '\011' | awk -F \| '{printf "%s|%s\n", $1, $2}' > $tmp

sqlite3 <<EOT
.open $dbfile
DROP TABLE IF EXISTS names;
CREATE TABLE names (
    taxid INTEGER NOT NULL,
    name VARCHAR NOT NULL
);

.separator '|'
.import $tmp names
CREATE INDEX name_idx ON names(taxid);
EOT
