process BaktaAnnotation {
    conda '/opt/conda/envs/genome-tools'
    tag "$params.file_name"
    publishDir "${final_outdir}/bakta", mode: 'copy'
    publishDir "${final_outdir}/logging", mode: 'copy', pattern: '*.{log,txt}', overwrite: true

    input:
    path assembly_fasta
    val final_outdir
    val sample
    val db_path
    val nproc
    val genus
    val species

    output:
    path "${sample}.embl", emit: bakta_embl
    path "${sample}.faa", emit: bakta_faa
    path "${sample}.ffn", emit: bakta_ffn
    path "${sample}.fna", emit: bakta_fna
    path "${sample}.gbff", emit: bakta_gbff
    path "${sample}.gff3", emit: bakta_gff3
    path "${sample}.hypotheticals.faa", emit: bakta_hypotheticals_faa
    path "${sample}.hypotheticals.tsv", emit: bakta_hypotheticals_tsv
    path "${sample}.tsv", emit: bakta_tsv
    path "${sample}.txt", emit: bakta_txt
    path "${sample}.svg", emit: bakta_plot

    script:
    """
    echo "Starting Bakta annotation with input: ${sample}.fasta"
    mkdir -p bakta_output
    if [[ -f "${assembly_fasta}" ]]; then
        echo "Input file found, proceeding with Bakta..."
        bakta_cmd="bakta --db ${db_path} --threads ${nproc} --output bakta_output --prefix ${sample} --force --skip-crispr"
        if [[ -n '${genus}' ]]; then
            bakta_cmd+=" --genus '${genus}'"
        fi
        if [[ -n '${species}' ]]; then
            bakta_cmd+=" --species '${species}'"
        fi
        \$bakta_cmd ${assembly_fasta}

        # List the contents of the bakta_output directory for debugging
        echo "Contents of bakta_output directory:"
        ls bakta_output

        # Move files to final destination, handling cases where files may not exist
        for ext in embl faa ffn fna gbff gff3 hypotheticals.faa hypotheticals.tsv tsv txt svg; do
            if [[ -f "bakta_output/${sample}.\$ext" ]]; then
                mv "bakta_output/${sample}.\$ext" .
            else
                echo "Warning: File bakta_output/${sample}.\$ext not found."
            fi
        done

        echo "Bakta processing complete."
    else
        echo "Input file not found, skipping Bakta."
    fi
    """
}
