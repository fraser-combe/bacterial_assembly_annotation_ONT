process QUASTEvaluation {
    conda '/opt/conda/envs/genome-tools'
    tag "$params.file_name QUAST evaluation"
    publishDir "${final_outdir}/quast", mode: 'copy'
    publishDir "${final_outdir}/logging", mode: 'copy', pattern: '*.{log,txt}', overwrite: true

    input:
    path assembly_fasta
    val final_outdir
    val nproc

    output:
    path "*", emit: quast_files

    script:
    """
    quast.py ${assembly_fasta} -o quast_output --threads ${nproc}
    mv quast_output/* .
    """
}