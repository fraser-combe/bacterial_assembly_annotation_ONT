process BandagePlot {
    conda '/opt/conda/envs/typing'
    tag "$params.file_name Bandage plot"
    publishDir "${final_outdir}/bandage", mode: 'copy'

    input:
    path assembly_graph
    val final_outdir

    output:
    path "assembly_graph.png", emit: bandage_plot

    script:
    """
    Bandage image ${assembly_graph} assembly_graph.png
    """
}