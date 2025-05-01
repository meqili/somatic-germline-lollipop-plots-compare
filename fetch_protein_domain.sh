#!/bin/bash

# Function to check if a command was successful
check_command_success() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed."
        exit 1
    fi
}

# Install jq if not installed
sudo apt-get update
sudo apt-get install -y jq

# Read gene name from command line argument
if [ -z "$1" ]; then
    echo "Please provide a gene name as an argument."
    exit 1
fi

GENE_NAME=$1

# Fetch the UniProt accession number using the gene name
ACCESSION=$(curl -s "https://rest.uniprot.org/uniprotkb/search?query=reviewed:true+AND+gene:${GENE_NAME}+AND+organism_id:9606&format=json" | jq -r '.results[0].primaryAccession')

# Error handling if the accession is not found
if [ -z "$ACCESSION" ] || [ "$ACCESSION" == "null" ]; then
    echo "Error: UniProt accession not found for gene ${GENE_NAME}."
    exit 1
fi

echo "Fetching Pfam domains for UniProt accession: ${ACCESSION}"

curl -s "https://www.ebi.ac.uk/interpro/api/entry/pfam/protein/uniprot/${ACCESSION}/" | (echo -e "${ACCESSION}_Pfam_domains\tprotein_length\tstart\tend"; jq -r '.results[] | .proteins[0].entry_protein_locations[].fragments[] as $frag | [.metadata.name, .proteins[0].protein_length, $frag.start, $frag.end] | @tsv' | sort -gk3 -t$'\t') > ${GENE_NAME}_protein_domain.tsv

check_command_success "Fetching Pfam domain information"