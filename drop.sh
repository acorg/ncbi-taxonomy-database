#!/bin/bash

set -Eeuo pipefail

case $# in
    2)
        table="$1"
        dbfile="$2"
        ;;
    *) echo "Usage: $(basename $0) table db-file" >&2; exit 1;;
esac

sqlite3 <<EOT
.open $dbfile
DROP TABLE IF EXISTS $table;
EOT
