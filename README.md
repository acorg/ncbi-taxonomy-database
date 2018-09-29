## Creating a database from NCBI taxonomy data

Here are scripts to help you create a database
([mysql](https://dev.mysql.com/) or
[sqlite](https://www.sqlite.org/index.html)) from some of the NCBI's
taxonomy data.  This can be used with the
[LineageFetcher](https://github.com/acorg/dark-matter/blob/master/dark/taxonomy.py)
Python class in [dark-matter](https://github.com/acorg/dark-matter/), or
with similar code that you write yourself.

## Downloading data

The `download.sh` script will download all the file you need from
[the NCBI ftp site](ftp://ftp.ncbi.nih.gov/pub/taxonomy).  If you already
have what's needed (`gi_taxid_nucl.dmp.gz`, `gi_taxid_prot.dmp.gz`, and
`taxdump.tar.gz`) you can skip this step, though you will need to
uncompress the first two and extract `names.dmp` and `nodes.dmp` from
`taxdump.tar.gz` using e.g.,

```sh
$ gunzip gi_*.gz
$ tar xfz taxdump.tar.gz
$ rm citations.dmp delnodes.dmp division.dmp gencode.dmp merged.dmp gc.prt readme.txt taxdump.tar.gz
```

Note that you don't have to use both the nucleotide and protein files. If
there's one you don't want, don't get it. Or you can edit that file it out
of `download.sh` if you want.

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

