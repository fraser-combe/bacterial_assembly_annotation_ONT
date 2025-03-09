#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

process DNAAplerReorient {
    tag "${sample} DNAApler reorientation"
    label 'dnaapler'
    publishDir "${final_outdir}/dnaapler", mode: 'copy'

    input:
    tuple val(sample), path(input_fasta)  // From Medaka polished FASTA
    val dnaapler_mode                     // Mode: 'all', 'chromosome', etc.
    val cpu
    val memory
    val final_outdir

    output:
    tuple val(sample), path("${sample}_reoriented.fasta"), emit: reoriented_fasta
    path "VERSION", emit: version

    script:
    """
    set -euo pipefail

    # Log DNAApler version
    dnaapler --version > VERSION

    # Run DNAApler
    dnaapler ${dnaapler_mode} \
        -i ${input_fasta} \
        -o dnaapler_output \
        -p ${sample} \
        -t ${cpu} \
        -f || { echo "ERROR: dnaapler command failed"; exit 1; }

    # Check output FASTA exists
    if [ ! -f "dnaapler_output/${sample}_reoriented.fasta" ]; then
        echo "ERROR: Expected output file not found: dnaapler_output/${sample}_reoriented.fasta"
        exit 1
    fi

    # Move reoriented FASTA to working directory
    mv dnaapler_output/${sample}_reoriented.fasta .
    """
}