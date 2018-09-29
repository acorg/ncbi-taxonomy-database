#!/bin/sh -e

ftp=ftp://ftp.ncbi.nih.gov/pub/taxonomy

for file in gi_taxid_nucl.dmp gi_taxid_prot.dmp
do
    filegz=$file.gz

    if [ -f $file ]
    then
        echo "$file already exists, no need to download."
    elif [ -f $filegz ]
    then
        echo "$filegz exists, uncompressing."
        gunzip $filegz
    else
        echo "$filegz does not exist, downloading from NCBI."
        curl -s -L -O $ftp/$filegz
        echo "Uncompressing $filegz."
        gunzip $filegz
    fi
done

taxdump=taxdump.tar.gz
if [ -f nodes.dmp -a -f names.dmp ]
then
    echo "nodes.dmp and names.dmp already exist, no need to download."
elif [ -f $taxdump ]
then
    echo "$taxdump exists, unpacking."
    tar xfz $taxdump nodes.dmp names.dmp
else
    echo "$taxdump does not exist, downloading from NCBI."
    curl -s -L -O $ftp/$taxdump
    echo "Extracting nodes.dmp and names.dmp from $taxdump."
    tar xfz $taxdump nodes.dmp names.dmp
    rm $taxdump
fi
