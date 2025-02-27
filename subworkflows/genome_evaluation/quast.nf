#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

process QUASTEvaluation {
    tag "${sample} QUAST evaluation"
    label 'quast'
    publishDir "${final_outdir}/quast", mode: 'copy'
    publishDir "${final_outdir}/logging", mode: 'copy', pattern: '*.{log,txt}', overwrite: true

    input:
    tuple val(sample), path(assembly_fasta)  // Expecting [sample, fasta] from Flye or Medaka
    val final_outdir
    val nproc

    output:
    path "quast_output/*", emit: quast_files

    script:
    """
    quast.py ${assembly_fasta} -o quast_output --threads ${nproc}
    """
}