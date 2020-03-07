#!/bin/bash

set -Eeuo pipefail

case $# in
    2)
        hostFile="$1"
        dbfile="$2"
        ;;
    *) echo "Usage: $(basename $0) host-file db-file" >&2; exit 1;;
esac

tmp=$(mktemp)
trap 'rm -f $tmp' 0 1 2 3 15

# There are some lines in the host.dmp file that end with a trailing
# comma. Clean that up as well as removing TABs.
cut -f1-2 -d\| < $hostFile | tr -d '\011' | sed -e 's/,$//' > $tmp

sqlite3 <<EOT
.open $dbfile
CREATE TABLE IF NOT EXISTS hosts (
    taxid INTEGER NOT NULL,
    hosts VARCHAR NOT NULL
);

DROP INDEX IF EXISTS hosts_taxid_idx;

.separator '|'
.import $tmp hosts
CREATE UNIQUE INDEX hosts_taxid_idx ON hosts(taxid);
EOT
