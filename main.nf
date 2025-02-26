#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
========================================================================================
    Basic Bacterial Genome Assembly Workflow with Flye and Bandage
========================================================================================
*/

// Include Flye module and Bandage subworkflow
include { FLYE_ASSEMBLY } from './modules/flye'
include { BandagePlot } from './subworkflows/genome_evaluation/bandage_plot'  // Updated import name to match process

// Default parameters
params.reads = null                     // Force user to specify reads
params.outdir = "output"                // Base output directory
params.sample = "sample"                // Default sample name
params.genome_size = "5m"               // Default genome size (5 Mb, Flye format)
params.nproc = 8                        // Default CPU threads
params.memory = "16.GB"                 // Default memory allocation
params.run_name = System.getenv('RUN_NAME') ?: "flye_assembly_${new Date().format('yyyyMMdd_HHmmss')}" // Simplified run name

// Validate critical parameters
if (!params.reads) {
    error "Parameter 'reads' must be specified (e.g., --reads 'path/to/reads/*.fastq.gz')"
}

// Define output directory with timestamp
final_outdir = "${params.outdir}/${params.sample}_${params.run_name}"

// Log pipeline info
log.info """\
    Basic Flye Assembly Workflow with Bandage
    ========================================
    Reads            : ${params.reads}
    Output Dir       : ${final_outdir}
    Sample Name      : ${params.sample}
    Genome Size      : ${params.genome_size}
    Threads          : ${params.nproc}
    Memory           : ${params.memory}
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
        params.memory
    )

    // Bandage plot using the Flye assembly graph
    BandagePlot(
        flyeOutput.graph,  // Pass the GFA output tuple [sample, assembly_graph.gfa]
        final_outdir
    )
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