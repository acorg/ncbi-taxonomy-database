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

# Be careful: there are two TABs in the egrep next line!
#
# Note that $3 is the unique name and is only present if the value in $2 is
# not unique. See data/taxdump_readme.txt for details.
egrep '\|	scientific name	\|' $names |
    tr -d '\011' |
    # awk -F \| '{printf "%s|%s\n", $1, $2}' > $tmp
    awk -F \| '{printf "%s|%s\n", $1, length($3) ? $3 : $2}' > $tmp

sqlite3 <<EOT
.open $dbfile
CREATE TABLE IF NOT EXISTS names (
    taxid INTEGER NOT NULL,
    name VARCHAR NOT NULL
);

DROP INDEX IF EXISTS names_taxid_idx;
DROP INDEX IF EXISTS names_name_idx;

.separator '|'
.import $tmp names
CREATE UNIQUE INDEX names_taxid_idx ON names(taxid);
CREATE UNIQUE INDEX names_name_idx ON names(name);
EOT
