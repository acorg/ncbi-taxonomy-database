#!/bin/bash

set -Eeuo pipefail

case $# in
    1)
        dbfile="$1"
        ;;
    *) echo "Usage: $(basename $0) db-file" >&2; exit 1;;
esac

sqlite3 <<EOT
.open $dbfile
VACUUM;
EOT
