# BactONTics
Nextflow pipeline for bacterial genome assembly and visualization using Oxford Nanopore (ONT) data.

## Overview
BactONTics is a lightweight, reproducible pipeline for assembling bacterial genomes from ONT raw reads and visualizing the assembly graph. It uses Flye for assembly and Bandage for generating a graphical representation of the contigs and genome annotation with Bakta, all executed within Docker containers for simplicity and consistency.

### Current Features
- **Assembly**: Flye assembles raw ONT reads into contigs using a user-specified or default genome size (e.g., 5 Mb).
- **Visualization**: Bandage creates a PNG plot of the assembly graph (GFA format) produced by Flye.
- **Evaluation**: QUAST assesses the polished assembly’s quality metrics.
- **Annotation**: Bakta annotates the polished assembly with genomic features.

### Planned Features
- Annotation with tools like Bakta (in progress).
- Read quality control (e.g., Fastcat) and filtering.
- Multi-sample support.

## Requirements
- **Nextflow**: Version 24.10.4 or later (`curl -s https://get.nextflow.io | bash`).
- **Docker**: Installed and running (`sudo apt install docker.io` on Ubuntu; ensure your user is in the `docker` group).
- **Input**: Raw ONT reads in FASTQ format (compressed `.fastq.gz` supported).
- **Bakta Database**: Download the Bakta database and specify its path via `--bakta_db` (e.g., `wget -r https://zenodo.org/records/7669534/files/db-light.tar.gz && tar -xzf db-light.tar.gz`).

## Installation
Clone the repository:
```bash
https://github.com/fraser-combe/bacterial_assembly_annotation_ONT
cd bactontics
```

# Usage

Run the pipeline with a single command:

```bash
nextflow run main.nf --reads "/path/to/your/reads.fastq.gz"
```

# Optional Parameters

```
--sample "sample_name": Set the sample name (default: sample).
--outdir "output_dir": Set the output directory (default: output).
--genome_size "size": Genome size for Flye (e.g., 5m for 5 Mb, default: 5m).
--nproc N: Number of CPU threads (default: 8).
--memory "size.GB": Memory allocation (default: 16 GB).
--medaka_auto_model true|false: Enable/disable Medaka auto model selection (default: true).
--medaka_model "model": Set Medaka model (default: r1041_e82_400bps_sup_v5.0.0).
--bakta_db "path": Path to Bakta database (default: ~/bakta/db).
--genus "Genus": Genus for Bakta annotation (optional).
--species "Species": Species for Bakta annotation (optional).
```

# Output

```
output/sample_flye_assembly_YYYYMMDD_HHMMSS/flye/:
  sample.assembly.fasta      # Assembled contigs.
  sample.assembly_graph.gfa  # Assembly graph.
  sample.assembly_info.txt   # Assembly statistics.
  sample.flye_version.txt    # Flye version.
  sample_flye.log            # Flye log.
output/sample_flye_assembly_YYYYMMDD_HHMMSS/medaka/:
    sample.polished.fasta: Polished contigs.
    MEDAKA_VERSION: Medaka version.
    MEDAKA_MODEL: Resolved Medaka model.
output/sample_flye_assembly_YYYYMMDD_HHMMSS/bandage/:
  sample_assembly_graph.png  # Bandage plot of the assembly graph.
output/sample_flye_assembly_YYYYMMDD_HHMMSS/quast/:
report.html, report.tsv, etc.: QUAST evaluation files.
output/sample_flye_assembly_YYYYMMDD_HHMMSS/bakta/:
sample.embl, .faa, .ffn, .fna, .gbff, .gff3, .hypotheticals.faa, .hypotheticals.tsv, .tsv, .txt, .svg: Bakta annotation files.
```

# Pipeline Structure

```
bactontics/
├── main.nf                # Main workflow script
├── modules/
│   ├── flye.nf            # Flye assembly process
│   └── medaka.nf          # Medaka polishing process
├── subworkflows/
│   ├── genome_evaluation/
│   │   ├── bandage_plot.nf # Bandage visualization process
│   │   └── quast.nf        # QUAST evaluation process
│   └── assembly_annotation/
│       └── bakta.nf        # Bakta annotation process
└── nextflow.config        # Configuration file
```

# Configuration

Edit nextflow.config to adjust defaults:

```
params {
    genome_size = "5m"
    cpu = 8
    memory = 16
    medaka_auto_model = true
    medaka_model = "r1041_e82_400bps_sup_v5.0.0"
}
process {
    withLabel: 'assembly' { container = 'staphb/flye:latest' }
    withLabel: 'medaka' { container = 'staphb/medaka:latest' }
    withLabel: 'bandage' { container = 'staphb/bandage:latest' }
    withLabel: 'quast' { container = 'staphb/quast:latest' }
    withLabel: 'bakta' { container = 'staphb/bakta:latest' }
}
docker { enabled = true }

```


---

### Run the Pipeline

```bash
nextflow run main.nf --reads "/home/fraser/bioinformatics/test_reads_BYHO.fastq.gz"
```

#Optional

```bash

nextflow run main.nf \
    --reads "/home/fraser/bioinformatics/test_reads_BYHO.fastq.gz" \
    --sample "test_sample" \
    --outdir "results" \
    --medaka_auto_model false \
    --medaka_model "r941_min_high_g360"
    --bakta_db "/path/to/bakta/db"
```
  
Genus/Species: Optional parameters; specify with --genus "Escherichia" and --species "coli" if known.
Memory: Bakta can be memory-intensive with the full database; 16 GB should suffice for most bacterial genomes, but increase if needed.

# Expected output

```
N E X T F L O W  ~  version 24.10.4
Launching `main.nf` [some_name] DSL2 - revision: ...
[xx/xxxxxx] process > FLYE_ASSEMBLY (sample) [100%] 1 of 1, cached ✔
[yy/yyyyyy] process > MEDAKA_POLISH (sample Medaka polishing) [100%] 1 of 1, cached ✔
[zz/zzzzzz] process > BandagePlot (sample Bandage plot) [100%] 1 of 1, cached ✔
[ww/wwwwww] process > QUASTEvaluation (sample QUAST evaluation) [100%] 1 of 1, cached ✔
[vv/vvvvvv] process > BaktaAnnotation (sample Bakta annotation) [100%] 1 of 1 ✔
```

## License
This work is licensed under a [Creative Commons Attribution-NonCommercial 4.0 International License](https://creativecommons.org/licenses/by-nc/4.0/).

