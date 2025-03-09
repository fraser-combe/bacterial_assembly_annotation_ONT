#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

process BaktaAnnotation {
    tag "${sample} Bakta annotation"
    label 'bakta'
    publishDir "${final_outdir}/bakta", mode: 'copy'

    input:
    tuple val(sample), path(input_fasta)
    val final_outdir
    val db_path  // Can be empty string or a path
    val cpu
    val genus
    val species

    output:
    tuple val(sample), path("${sample}_bakta/*"), emit: bakta_outputs
    path "VERSION", emit: version

    script:
    def db_option = db_path ? "--db ${db_path}" : ""
    def genus_option = genus ? "--genus ${genus}" : ""
    def species_option = species ? "--species ${species}" : ""
    """
    set -euo pipefail

    # Log Bakta version
    bakta --version > VERSION

    # Run Bakta
    bakta \\
        --input ${input_fasta} \\
        --output ${sample}_bakta \\
        --prefix ${sample} \\
        --threads ${cpu} \\
        ${db_option} \\
        ${genus_option} \\
        ${species_option} \\
        --verbose \\
        2>&1 | tee ${sample}_bakta.log

    # Check output exists
    if [ ! -f "${sample}_bakta/${sample}.gff3" ]; then
        echo "ERROR: Bakta output file not found: ${sample}_bakta/${sample}.gff3"
        exit 1
    fi
    """
}