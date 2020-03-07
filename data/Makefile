all:
	@echo 'There is no default make target.'

download: download-taxdump download-accession-to-taxid

download-taxdump:
	@echo 'Downloading new_taxdump.tar.gz'
	curl -O -L 'ftp://ftp.ncbi.nih.gov/pub/taxonomy/new_taxdump/new_taxdump.tar.gz'
	@echo 'Untarring new_taxdump.tar.gz'
	tar xfz new_taxdump.tar.gz

download-accession-to-taxid:
	@echo 'Downloading nucl_gb.accession2taxid.gz (be patient)'
	curl -O -L 'ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz'
