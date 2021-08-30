## praph
PanTools Pangenome building/annotation nextflow workflow implementation\
# Features:
  - Downloads bacterial whole genome sequences from the refseq database of desired genus
  - Builds a pangenome representation of the selected genomes using the PanTools pangenomic toolkit (https://git.wur.nl/bioinformatics/pantools/-/tree/master)
  - Annotates genomes with data downloaded from the refseq database
  - Adds species phenotypes to genomes in pangenome
  - Performs homology grouping and gene_classification analysis on annotated pangenome, outputting various statistics and information about the annotated pangenome for further analysis

# Instructions for running PanTools nextflow pipeline:
  - DEPENDENCIES: 
    - Nextflow 21.04.3 https://www.nextflow.io/docs/latest/getstarted.html
    - Java 8 or higher (OpenJDK works fine)
    - Pantools 3.1 https://git.wur.nl/bioinformatics/pantools/-/tree/master
    - Singularity 3.8.* https://sylabs.io/guides/3.0/user-guide/installation.html
  - Step 1:
    - Build the Singularity image with `sudo singularity build pipeline.sif pipeline.def`
  - Step 2:
    - Locate path to pantools.jar && nextflow
  - Step 3:
    - Run nextflow with `/path/to/nextflow run pangenome.nf -with-singularity pipeline.sif --genera Brucella,Ochrobactrum --n 50 (-bg)`
    - Specify parameters for genera with `--genera Comma,Seperated,Genera` supplying a list of a bacteria genomes to download from the refseq database
    - To specify the amount of genomes to build the pangenome with use `--n 50` (default 10)
    - If you already have the genomes downloaded from a previous pangenome you can specify `--download false` so genomes won't be re-downloaded
