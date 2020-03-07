#!/bin/bash

set -Eeuo pipefail

case $# in
    2)
        nodeFile="$1"
        dbfile="$2"
        ;;
    *) echo "Usage: $(basename $0) node-file db-file" >&2; exit 1;;
esac

tmp=$(mktemp)
trap 'rm -f $tmp' 0 1 2 3 15

# The sed command in the following adjusts the 'no rank' value of the rank
# of Riboviria to have the correct 'realm' value, and all other 'no rank'
# ranks get changed to '-'.  The '-' value is relied upon in dark-matter
# (https://github.com/acorg/dark-matter) taxonomy code.
cut -f1-3 -d\| < $nodeFile | tr -d '\011' | \
    sed -e 's/^2559587|10239|no rank$/2559587|10239|realm/' \
        -e 's/|no rank$/|-/' > $tmp

sqlite3 <<EOT
.open $dbfile
CREATE TABLE IF NOT EXISTS nodes (
    taxid INTEGER NOT NULL,
    parent_taxid INTEGER NOT NULL,
    rank VARCHAR NOT NULL
);

DROP INDEX IF EXISTS nodes_taxid_idx;
DROP INDEX IF EXISTS nodes_parent_idx;

.separator '|'
.import $tmp nodes
CREATE UNIQUE INDEX nodes_taxid_idx ON nodes(taxid);
CREATE INDEX nodes_parent_idx ON nodes(parent_taxid);
EOT
