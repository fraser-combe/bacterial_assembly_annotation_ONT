#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

process FLYE_ASSEMBLY {
    tag "${sample}"
    label 'assembly'
    publishDir "${final_outdir}/flye", mode: 'copy', overwrite: true

    input:
    tuple val(sample), path(reads)
    val cpu
    val memory
    val final_outdir

    output:
    tuple val(sample), path("${sample}.assembly.fasta"), emit: assembly
    tuple val(sample), path("${sample}.assembly_graph.gfa"), emit: graph
    tuple val(sample), path("${sample}.assembly_info.txt"), emit: info
    path "${sample}.flye_version.txt", emit: version
    path "${sample}_flye.log", emit: log

    script:
    """
    set -euo pipefail

    # Debug: Check final_outdir
    echo "Final outdir: ${final_outdir}" > debug_outdir.txt

    # Log Flye version
    flye --version > ${sample}.flye_version.txt

    # Run Flye assembly with minimal options
    flye \
        --nano-hq ${reads} \
        --threads ${cpu} \
        --out-dir ${sample}_flye \
        2>&1 | tee ${sample}_flye.log

    # Rename outputs for consistency
    mv ${sample}_flye/assembly.fasta ${sample}.assembly.fasta
    mv ${sample}_flye/assembly_graph.gfa ${sample}.assembly_graph.gfa
    mv ${sample}_flye/assembly_info.txt ${sample}.assembly_info.txt
    """
}