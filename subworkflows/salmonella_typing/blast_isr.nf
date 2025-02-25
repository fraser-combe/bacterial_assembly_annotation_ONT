process BlastISR {
    conda 'genome-tools.yml'
    tag "$params.file_name BLAST ISR"
    publishDir "${final_outdir}/blast", mode: 'copy'

    input:
    path assembly_fasta
    val final_outdir

    output:
    path "blast_results.txt", emit: blast_results

    script:
    """
    makeblastdb -in /app/isr_db/Salmonella-ISR-database-17Jul23.fasta -dbtype nucl -out /app/isr_db/salmonella_isr

    # Perform BLAST search
    blastn -query ${assembly_fasta} -db /app/isr_db/salmonella_isr -out blast_results.txt -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore"
    """
}