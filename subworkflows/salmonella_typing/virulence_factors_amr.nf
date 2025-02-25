process VirulenceFactorIdentification {
    conda '/opt/conda/envs/abricate'
    tag "$params.file_name Virulence factor and AMR identification"
    publishDir "${final_outdir}/abricate", mode: 'copy'

    input:
    path assembly_fasta
    val final_outdir

    output:
    path "virulence_factors.tsv", emit: virulence_factors
    path "amr_results.tsv", emit: amr_results

    script:
    """
    abricate --db vfdb ${assembly_fasta} > virulence_factors.tsv
    abricate --db ncbi ${assembly_fasta} > amr_results.tsv
    """
}
