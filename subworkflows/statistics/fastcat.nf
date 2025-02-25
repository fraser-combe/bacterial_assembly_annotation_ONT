process FastcatStats {
    conda '/opt/conda/envs/abricate'
    tag "$params.file_name Fastcat stats"
    publishDir "${final_outdir}/histograms", mode: 'copy'


    input:
    path reads
    val final_outdir
    val file_name

    output:
    path "fastcat_stats.txt", emit: fastcat_stats
    path "histograms/length.hist", emit: length_histogram
    path "histograms/quality.hist", emit: quality_histogram

    script:
    """
    echo "Working directory contents before running fastcat:"
    ls -lh

    if [ -f "${reads}" ]; then
        echo "Found input file: ${reads}"
        echo "Running fastcat command..."

        fastcat -r fastcat_stats.txt --histograms=histograms ${reads}
        exit_status=\$?
        echo "fastcat command exit status: \$exit_status"
        if [ \$exit_status -ne 0 ]; then
            echo "fastcat command failed."
            exit 1
        fi
    else
        echo "Error: Input file ${reads} not found."
        exit 1
    fi

    echo "Working directory contents after running fastcat:"
    ls -lh
    """
}