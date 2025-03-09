#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
========================================================================================
    Bacterial Genome Assembly Workflow with Flye, Medaka, DNAApler, Bandage, QUAST, and Bakta
========================================================================================
*/

// Include modules and subworkflows
include { FLYE_ASSEMBLY } from './modules/flye'
include { MEDAKA_POLISH } from './modules/medaka'
include { DNAAplerReorient } from './modules/dnaapler'
include { BandagePlot } from './subworkflows/genome_evaluation/bandage_plot'
include { QUASTEvaluation } from './subworkflows/genome_evaluation/quast'
include { BaktaAnnotation } from './subworkflows/assembly_annotation/bakta'

// Default parameters
params.reads = null                     // Force user to specify reads
params.outdir = "output"                // Base output directory
params.sample = "sample"                // Default sample name
params.genome_size = "5m"               // Default genome size (5 Mb, Flye format)
params.nproc = 8                        // Default CPU threads (overridden in CI)
params.memory = "16.GB"                 // Default memory allocation
params.medaka_auto_model = true         // Enable Medaka auto model selection
params.medaka_model = "r1041_e82_400bps_sup_v5.0.0"  // Default Medaka model
params.bakta_db = ""                    // Empty uses light DB in container; override with full DB path
params.genus = ""                       // Optional genus for Bakta
params.species = ""                     // Optional species for Bakta
params.dnaapler_mode = "all"            // Default DNAApler mode
params.run_name = System.getenv('RUN_NAME') ?: "flye_assembly_${new Date().format('yyyyMMdd_HHmmss')}"

// Validate critical parameters
if (!params.reads) {
    error "Parameter 'reads' must be specified (e.g., --reads 'path/to/reads/*.fastq.gz')"
}

// Define output directory with timestamp
final_outdir = "${params.outdir}/${params.sample}_${params.run_name}"

// Log pipeline info
log.info """\
    Bacterial Genome Assembly Workflow with Flye, Medaka, DNAApler, Bandage, QUAST, and Bakta
    ========================================================================================
    Reads            : ${params.reads}
    Output Dir       : ${final_outdir}
    Sample Name      : ${params.sample}
    Genome Size      : ${params.genome_size}
    Threads          : ${params.nproc}
    Memory           : ${params.memory}
    Medaka Auto Model: ${params.medaka_auto_model}
    Medaka Model     : ${params.medaka_model}
    Bakta DB         : ${params.bakta_db ?: 'Using light DB in container'}
    Genus            : ${params.genus ?: 'Not specified'}
    Species          : ${params.species ?: 'Not specified'}
    DNAApler Mode    : ${params.dnaapler_mode}
    Run Name         : ${params.run_name}
    """.stripIndent()

// Main workflow
workflow {
    // Input channel for reads
    reads_ch = Channel
        .fromPath(params.reads, checkIfExists: true)
        .map { file -> tuple(params.sample, file) }

    // Flye assembly
    flyeOutput = FLYE_ASSEMBLY(
        reads_ch,
        params.genome_size,
        params.nproc,
        params.memory,
        final_outdir
    )

    // Medaka polishing
    medakaOutput = MEDAKA_POLISH(
        flyeOutput.assembly,
        reads_ch.map { it[1] },
        params.medaka_auto_model,
        params.medaka_model,
        params.nproc,
        params.memory,
        final_outdir
    )

    // DNAApler reorientation
    dnaaplerOutput = DNAAplerReorient(
        medakaOutput.polished_fasta,
        params.dnaapler_mode,
        params.nproc,
        params.memory,
        final_outdir
    )

    // Bandage plot using the Flye assembly graph
    BandagePlot(
        flyeOutput.graph,
        final_outdir
    )

    // QUAST evaluation using the DNAApler reoriented fasta
    QUASTEvaluation(
        dnaaplerOutput.reoriented_fasta,
        final_outdir,
        params.nproc
    )

    // Bakta annotation using the DNAApler reoriented fasta
    if (params.bakta_db && file(params.bakta_db, checkIfExists: false).exists()) {
        log.info "Using user-provided Bakta DB: ${params.bakta_db}"
        BaktaAnnotation(
            dnaaplerOutput.reoriented_fasta,
            final_outdir,
            params.bakta_db,
            params.nproc,
            params.genus,
            params.species
        )
    } else {
        log.info "No valid Bakta DB path provided; using light DB from container"
        BaktaAnnotation(
            dnaaplerOutput.reoriented_fasta,
            final_outdir,
            "default",  // Use "default" to signal light DB
            params.nproc,
            params.genus,
            params.species
        )
    }
}

// Completion handler
workflow.onComplete {
    log.info """\
    Workflow Execution Summary
    --------------------------
    Completed At     : ${workflow.complete}
    Duration         : ${workflow.duration}
    Success          : ${workflow.success}
    Exit Code        : ${workflow.exitStatus}
    Output Directory : ${final_outdir}
    """.stripIndent()

    // Ensure output directory permissions
    def outDir = new File(final_outdir)
    if (outDir.exists()) {
        outDir.setWritable(true, false)
        log.info "Set ${final_outdir} as writable"
    }
}