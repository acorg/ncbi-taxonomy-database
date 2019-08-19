TAXONOMY_DIR := ../taxonomy
DB = taxonomy.db

$(DB): names nodes taxids

taxids:
	./sqlite-add-accession-taxid.sh $(TAXONOMY_DIR)/nucl_gb.accession2taxid.gz $(DB)

nodes:
	./sqlite-add-nodes.sh $(TAXONOMY_DIR)/nodes.dmp $(DB)

names:
	./sqlite-add-names.sh $(TAXONOMY_DIR)/names.dmp $(DB)

clean:
	rm -f $(DB)
