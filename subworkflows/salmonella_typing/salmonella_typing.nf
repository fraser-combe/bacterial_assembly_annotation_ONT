process SeqSero2 {
    conda '/opt/conda/envs/typing'
    tag "$params.file_name SeqSero2"
    publishDir "${final_outdir}/seqsero2", mode: 'copy'

    input:
    path assembly_fasta
    val genus
    val final_outdir

    output:
    path "seqsero2_output/*", emit: seqsero2_files

    script:
    """
    set -e

    echo "Starting SeqSero2 process..." > seqsero2_debug.log

    if [ "${params.genus}" == "Salmonella" ]; then
        if [ -s ${assembly_fasta} ]; then
            echo "Running SeqSero2 with input file: ${assembly_fasta}" >> seqsero2_debug.log

            # Run SeqSero2
            SeqSero2_package.py -m k -t 4 -i ${assembly_fasta} -d seqsero2_output 2>&1 | tee -a seqsero2_debug.log

            # Check if output was generated and move results
            if [ -f seqsero2_output/SeqSero_result.txt ]; then
                mv seqsero2_output/SeqSero_result.txt seqsero2_output/serotype_results.txt
                echo "SeqSero2 results file found and moved to seqsero2_output/serotype_results.txt" >> seqsero2_debug.log
            else
                echo "SeqSero2 did not produce the expected results file." >> seqsero2_debug.log
                touch seqsero2_output/seqsero2_failed.txt
            fi
        else
            echo "Input file is empty or invalid: ${assembly_fasta}" >> seqsero2_debug.log
            touch seqsero2_output/seqsero2_input_invalid.txt
        fi
    else
        echo "Genus is not Salmonella, skipping SeqSero2." >> seqsero2_debug.log
        touch seqsero2_output/seqsero2_skipped.txt
    fi

    echo "SeqSero2 process completed." >> seqsero2_debug.log

    # Copy debug log to output directory
    cp seqsero2_debug.log seqsero2_output/
    """
}