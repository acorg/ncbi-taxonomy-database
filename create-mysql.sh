#!/bin/sh -e

case $# in
    0) echo "Usage: $(basename $0) mysql-args" >&2; exit 1;;
esac

mysql "$@" <<EOT
DROP TABLE IF EXISTS gi_taxid, names, nodes;

CREATE TABLE gi_taxid (gi INT, taxID INT);
CREATE TABLE names (taxID INT, divider1 VARCHAR(300), name VARCHAR(300),
                    divider2 VARCHAR(300), unique_name VARCHAR(300),
                    divider3 VARCHAR(300), name_class VARCHAR(300));
CREATE TABLE nodes (taxID INT, divider1 VARCHAR(300), parent_taxID INT,
                    divider2 VARCHAR(300), rank VARCHAR(300));

LOAD DATA LOCAL INFILE 'gi_taxid_nucl.dmp' INTO TABLE gi_taxid;
LOAD DATA LOCAL INFILE 'gi_taxid_prot.dmp' INTO TABLE gi_taxid;
ALTER TABLE gi_taxid ADD INDEX (gi);

LOAD DATA LOCAL INFILE 'names.dmp' INTO TABLE names;
ALTER TABLE nodes ADD INDEX (taxID);

LOAD DATA LOCAL INFILE 'nodes.dmp' INTO TABLE nodes;
ALTER TABLE names ADD INDEX (taxID);
EOT
