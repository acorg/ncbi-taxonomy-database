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
# of Riboviria to have the correct 'realm' value.
cut -f1-3 -d\| < $nodeFile | tr -d '\011' | sed -e 's/^2559587|10239|no rank$/2559587|10239|realm/' > $tmp

sqlite3 <<EOT
.open $dbfile
DROP TABLE IF EXISTS nodes;
CREATE TABLE nodes (
    taxid INTEGER NOT NULL,
    parent_taxid INTEGER NOT NULL,
    rank VARCHAR NOT NULL
);

.separator '|'
.import $tmp nodes
CREATE INDEX nodes_idx ON nodes(taxid);
EOT
