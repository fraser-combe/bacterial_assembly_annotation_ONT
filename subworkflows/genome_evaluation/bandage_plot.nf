#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

process BandagePlot {
    tag "${sample} Bandage plot"
    label 'bandage'
    publishDir "${final_outdir}/bandage", mode: 'copy'

    input:
    tuple val(sample), path(assembly_graph)
    val final_outdir

    output:
    path "${sample}_assembly_graph.png", emit: bandage_plot

    script:
    """
    Bandage image ${assembly_graph} ${sample}_assembly_graph.png
    """
}