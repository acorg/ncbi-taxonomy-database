#!/bin/bash

set -Eeuo pipefail

case $# in
    2)
        nucl_gb="$1"
        dbfile="$2"
        ;;
    *) echo "Usage: $(basename $0) accession-file db-file" >&2; exit 1;;
esac

tmp=$(mktemp)
trap 'rm -f $tmp' 0 1 2 3 15

# The tail -n +2 in the following is due to the NCBI
# nucl_gb.accession2taxid.gz file starting with a header line.
#
# Note that field 2 is the GenBank accession number with version. If for
# some reason you don't want the version, use column 1 (but then the
# accession numbers are not unique).
case $nucl_gb in
    *.gz) zcat $nucl_gb | tail -n +2 | cut -f2,3 > $tmp;;
    *) tail -n +2 < $nucl_gb | cut -f2,3 > $tmp;;
esac

sqlite3 <<EOT
.open $dbfile
CREATE TABLE IF NOT EXISTS accession_taxid (
    accession VARCHAR UNIQUE PRIMARY KEY,
    taxid INTEGER NOT NULL
);

DROP INDEX IF EXISTS accession_taxid_accession_idx;

.mode tabs
.import $tmp accession_taxid
CREATE UNIQUE INDEX accession_taxid_accession_idx ON accession_taxid(accession);
EOT
