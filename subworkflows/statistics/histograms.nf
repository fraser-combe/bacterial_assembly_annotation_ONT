process PlotHistograms {
    conda '/opt/conda/envs/abricate'
    tag "$params.file_name Plot histograms"
    publishDir "${final_outdir}/histograms", mode: 'copy'

    input:
    path length_histogram
    path quality_histogram
    val final_outdir
    val file_name

    output:
    path "length_histogram_kb.png", emit: length_histogram_plot
    path "quality_histogram.png", emit: quality_histogram_plot

    script:
    """
    python3 - <<EOF
import matplotlib.pyplot as plt

def plot_histogram(file_path, output_path, title, xlabel, ylabel, scale_factor=1, xlim=None):
    data = []
    with open(file_path, 'r') as f:
        for line in f:
            if line.startswith('lower'):
                continue
            lower, upper, count = map(float, line.split())
            data.extend([lower / scale_factor] * int(count))
    plt.hist(data, bins=50, edgecolor='black')
    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    if xlim:
        plt.xlim(0, xlim / scale_factor)
    plt.savefig(output_path)
    plt.close()

# Determine the maximum read length
max_length = 0
with open('${length_histogram}', 'r') as f:
    for line in f:
        if line.startswith('lower'):
            continue
        lower, upper, count = map(float, line.split())
        if upper > max_length:
            max_length = upper

plot_histogram('${length_histogram}', 'length_histogram_kb.png', 'Read Length Distribution', 'Read Length (kb)', 'Frequency', scale_factor=1000, xlim=max_length)
plot_histogram('${quality_histogram}', 'quality_histogram.png', 'Read Quality Distribution', 'Read Quality Score', 'Frequency')
EOF
    """
}