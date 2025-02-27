#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

process MEDAKA_POLISH {
    tag "${sample} Medaka polishing"
    label 'medaka'
    publishDir "${final_outdir}/medaka", mode: 'copy'

    input:
    tuple val(sample), path(unpolished_fasta)
    path reads
    val auto_model
    val medaka_model
    val cpu
    val memory
    val final_outdir  // Added for consistency

    output:
    tuple val(sample), path("${sample}.polished.fasta"), emit: polished_fasta
    path "MEDAKA_VERSION", emit: version
    path "MEDAKA_MODEL", emit: resolved_model

    script:
    """
    set -euo pipefail

    # Log Medaka version
    medaka --version > MEDAKA_VERSION

    # Automatic model resolution if enabled
    if [ "${auto_model}" == "true" ]; then
        echo "Attempting automatic model selection..."
        medaka tools resolve_model --auto_model consensus ${reads} > auto_model.txt || true
        resolved_model=\$(cat auto_model.txt || echo "")
        medaka_model="\${resolved_model:-${medaka_model}}"
    else
        medaka_model="${medaka_model}"
    fi

    echo "Using Medaka model for polishing: \$medaka_model"
    echo "\$medaka_model" > MEDAKA_MODEL

    # Perform Medaka polishing
    medaka_consensus \
        -i ${reads} \
        -d ${unpolished_fasta} \
        -o . \
        -m "\$medaka_model" \
        -t ${cpu}

    mv consensus.fasta ${sample}.polished.fasta
    """
}