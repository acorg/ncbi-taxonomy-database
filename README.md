## Creating a database from NCBI taxonomy data

Here are scripts to help you create a database
([mysql](https://dev.mysql.com/) or
[sqlite](https://www.sqlite.org/index.html)) from some of the NCBI's
taxonomy data.  This can be used with the
[LineageFetcher](https://github.com/acorg/dark-matter/blob/master/dark/taxonomy.py)
Python class in [dark-matter](https://github.com/acorg/dark-matter/), or
with similar code that you write yourself.

## Nucleotides, proteins, or both?

There are two large files on the NCBI FTP site and you may not want them
both. You'll need at least one of them. It all depends on the `gi` numbers
you want to be able to look up taxonomy information for.

The download script and database creation scripts assume you want both
files.  If you don't, you can edit these scripts to remove the file you
don't need.

To change `download.sh` just remove one of the file names from the line
that says `for file in gi_taxid_nucl.dmp gi_taxid_prot.dmp`. To change the
create scripts, delete the line that imports the data from the file you
don't want (`gi_taxid_nucl.dmp` or `gi_taxid_prot.dmp`).

## Downloading data

The `download.sh` script will download all the file you need from
[the NCBI ftp site](ftp://ftp.ncbi.nih.gov/pub/taxonomy).  If you already
have what's needed (at least one of `gi_taxid_nucl.dmp.gz`,
`gi_taxid_prot.dmp.gz`, and `taxdump.tar.gz`) you can skip this step,
though you will need to uncompress the first two and extract `names.dmp`
and `nodes.dmp` from `taxdump.tar.gz` using e.g.,

```sh
$ gunzip gi_*.gz
$ tar xfz taxdump.tar.gz names.dmp nodes.dmp
```

## Building the database

### Sqlite3

Run

```sh
$ create-sqlite.sh ncbi-taxonomy-sqlite.db
```

to make the database file (or give your own database filename on the
command line).

### Mysql

Run

```sh
$ create-mysql.sh database-name
```

you will probably need to add additional arguments (like `--user` and
`--password`). All arguments are simply given to `mysql` on its command
line.
