# BactONTics
Nextflow pipeline for bacterial genome assembly and visualization using Oxford Nanopore (ONT) data.

## Overview
BactONTics is a lightweight, reproducible pipeline for assembling bacterial genomes from ONT raw reads and visualizing the assembly graph. It uses Flye for assembly and Bandage for generating a graphical representation of the contigs, all executed within Docker containers for simplicity and consistency.

### Current Features
- **Assembly**: Flye assembles raw ONT reads into contigs using a user-specified or default genome size (e.g., 5 Mb).
- **Visualization**: Bandage creates a PNG plot of the assembly graph (GFA format) produced by Flye.
- **Dockerized**: Runs Flye (`staphb/flye:latest`) and Bandage (`staphb/bandage:latest`) in containers, eliminating local dependency setup.

### Planned Features
- Annotation with tools like Bakta (in progress).
- Read quality control (e.g., Fastcat) and filtering.
- Multi-sample support.

## Requirements
- **Nextflow**: Version 24.10.4 or later (`curl -s https://get.nextflow.io | bash`).
- **Docker**: Installed and running (`sudo apt install docker.io` on Ubuntu; ensure your user is in the `docker` group).
- **Input**: Raw ONT reads in FASTQ format (compressed `.fastq.gz` supported).

## Installation
Clone the repository:
```bash
git clone https://github.com/yourusername/bactontics.git
cd bactontics
```

# Usage

Run the pipeline with a single command:

```bash
nextflow run main.nf --reads "/path/to/your/reads.fastq.gz"
```

# Optional Parameters
--sample "sample_name": Set the sample name (default: sample).
--outdir "output_dir": Set the output directory (default: output).
--genome_size "size": Genome size for Flye (e.g., 5m for 5 Mb, default: 5m).
--nproc N: Number of CPU threads (default: 8).
--memory "size.GB": Memory allocation (default: 16 GB).

# Output

```
output/sample_flye_assembly_YYYYMMDD_HHMMSS/flye/:
  sample.assembly.fasta      # Assembled contigs.
  sample.assembly_graph.gfa  # Assembly graph.
  sample.assembly_info.txt   # Assembly statistics.
  sample.flye_version.txt    # Flye version.
  sample_flye.log            # Flye log.
output/sample_flye_assembly_YYYYMMDD_HHMMSS/bandage/:
  sample_assembly_graph.png  # Bandage plot of the assembly graph.
```

# Pipeline Structure
```
bactontics/
├── main.nf                # Main workflow script
├── modules/
│   └── flye.nf            # Flye assembly process
├── subworkflows/
│   └── genome_evaluation/
│       └── bandage_plot.nf # Bandage visualization process
└── nextflow.config        # Configuration file
```
# Configuration
Edit nextflow.config to adjust defaults:

```
params {
    genome_size = "5m"
    cpu = 8
    memory = 16
}
process {
    withLabel: 'assembly' { container = 'staphb/flye:latest' }
    withLabel: 'bandage' { container = 'staphb/bandage:latest' }
}
docker { enabled = true }

```
## License
This work is licensed under a [Creative Commons Attribution-NonCommercial 4.0 International License](https://creativecommons.org/licenses/by-nc/4.0/).

