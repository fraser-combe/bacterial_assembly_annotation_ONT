#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

process BaktaAnnotation {
    tag "${sample} Bakta annotation"
    label 'bakta'
    publishDir "${final_outdir}/bakta", mode: 'copy'
    publishDir "${final_outdir}/logging", mode: 'copy', pattern: '*.{log,txt}', overwrite: true

    input:
    tuple val(sample), path(assembly_fasta)  // From Medaka polished FASTA
    val final_outdir
    val db_path
    val nproc
    val genus
    val species

    output:
    path "${sample}.embl", emit: bakta_embl, optional: true
    path "${sample}.faa", emit: bakta_faa, optional: true
    path "${sample}.ffn", emit: bakta_ffn, optional: true
    path "${sample}.fna", emit: bakta_fna, optional: true
    path "${sample}.gbff", emit: bakta_gbff, optional: true
    path "${sample}.gff3", emit: bakta_gff3, optional: true
    path "${sample}.hypotheticals.faa", emit: bakta_hypotheticals_faa, optional: true
    path "${sample}.hypotheticals.tsv", emit: bakta_hypotheticals_tsv, optional: true
    path "${sample}.tsv", emit: bakta_tsv, optional: true
    path "${sample}.txt", emit: bakta_txt, optional: true
    path "${sample}.svg", emit: bakta_plot, optional: true

    script:
    """
    set -euo pipefail

    echo "Starting Bakta annotation with input: ${assembly_fasta}"

    # Construct Bakta command
    bakta_cmd="bakta --db ${db_path} --threads ${nproc} --prefix ${sample} --force --skip-crispr"
    if [ -n "${genus}" ]; then
        bakta_cmd+=" --genus '${genus}'"
    fi
    if [ -n "${species}" ]; then
        bakta_cmd+=" --species '${species}'"
    fi

    # Run Bakta
    \$bakta_cmd ${assembly_fasta}

    # Debug: List output files
    echo "Contents of current directory after Bakta:"
    ls -l
    """
}