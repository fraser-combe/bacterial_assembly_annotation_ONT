process DragonflyeAssembly {
    conda '/opt/conda/envs/dragonflye'
    tag "$params.file_name Dragonflye assembly"
    publishDir "${final_outdir}/dragonflye", mode: 'copy'
    publishDir "${final_outdir}/logging", mode: 'copy', pattern: '*.{log,txt}', overwrite: true

    input:
    path reads
    val final_outdir
    val file_name
    val genome_size
    val nproc
    val model
    val sample

    output:
    path "${sample}.fasta", emit: assembly_fasta
    path "dragonflye.log", emit: assembly_log
    path "${sample}_contigs.gfa", emit: assembly_graph
    path "flye-info.txt", emit: assembly_info

    script:
    """
    set -x  # Enable detailed logging
    dragonflye --reads ${reads} --outdir output --gsize ${genome_size} --cpus ${nproc} --medaka 2 --model ${model} --depth 0 --nofilter 2>&1 | tee dragonflye.log

    # Check if the expected files are generated
    if [ ! -f output/contigs.fa ]; then
        echo "Error: contigs.fa not found in output directory." >> dragonflye.log
        exit 1
    fi

    if [ ! -f output/flye-unpolished.gfa ]; then
        echo "Warning: flye-unpolished.gfa not found in output directory." >> dragonflye.log
    fi

    # Rename and move the final output files
    mv output/contigs.fa ${sample}.fasta || exit 1
    if [ -f output/flye-unpolished.gfa ]; then
        mv output/flye-unpolished.gfa ${sample}_contigs.gfa
    fi
    if [ -f output/flye-info.txt ]; then
        mv output/flye-info.txt flye-info.txt
    fi

    # Move all other output files to the final output directory
    mv output/* .
    """
}
