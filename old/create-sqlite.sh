#!/bin/sh -e

case $# in
    0) dbfile=ncbi-taxonomy-sqlite.db;;
    1) dbfile="$1";;
    *) echo "Usage: $(basename $0) db-filename" >&2; exit 1;;
esac

if [ -f "$dbfile" ]
then
    echo "Database file $dbfile already exists. Will not overwrite." >&2
    exit 2
else
    echo "Creating database file $dbfile."
fi

sqlite3 <<EOT
.open $dbfile
CREATE TABLE gi_taxid (gi INT, taxID INT);
CREATE TABLE names (taxID INT, name VARCHAR(300), unique_name VARCHAR(300), name_class VARCHAR(300));
CREATE TABLE nodes (taxID INT, parent_taxID INT, rank VARCHAR(300));

.separator '	'
-- If you do not want nucleotide data taxonomy info, remove the next two lines.
.shell echo Importing nucleotide gi-to-taxid data. Be patient.
.import gi_taxid_nucl.dmp gi_taxid

-- If you do not want protein taxonomy info, remove the next two lines.
.shell echo Importing protein gi-to-taxid data. Be patient.
.import gi_taxid_prot.dmp gi_taxid

.shell echo Indexing gi_taxid.
create index gi_idx on gi_taxid(gi);

.shell echo Importing names
.separator '|'
.import names.dmp names
.shell echo Indexing names.
create index name_idx on names(taxID);

.shell echo Importing nodes
.separator '|'
.import nodes.dmp nodes
.shell echo Indexing nodes.
create index nodes_idx on nodes(taxID);

EOT
