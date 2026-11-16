# One Health *Acinetobacter baumannii*

Data and code for a comparative genomic analysis of 1,094 *Acinetobacter baumannii* genomes from human, hospital, environmental and animal sources, within a One Health framework.

## Genomes analysed

| Isolation source | Genomes |
|---|---|
| Human | 684 |
| Hospital | 118 |
| Environmental | 209 |
| Animal | 83 |
| **Total** | **1,094** |

Genomes were classified using the "Isolation source" field: human (blood isolates only), hospital environment (e.g., bed, alcohol dispenser, light switch), environmental (e.g., sewage, river, soil) and animal (e.g., chicken, cow, pig). Only entries with year of isolation, country of origin and isolation source were included.

## Data availability

All genomes are publicly available in **NCBI Pathogen Detection** and **BV-BRC**. Accession numbers and isolation-source metadata are listed in `database_tables/` (all candidate genomes) and `genomes_by_group/` (genomes used in the analyses). No new sequencing data were generated.

## Repository structure

```
One_Health_Abaumannii/
├── database_tables/
├── genomes_by_group/
├── quality_control/
├── genome_annotations_by_group/
├── phylogenetic_tree/
├── rgi_output_tables/
├── vfdb_output_tables/
├── gene_grouping/
├── statistical_tests/
└── README.md
```

### `database_tables/`
Original, unfiltered genome tables downloaded from public databases, before quality filtering and group assignment.

| File | Description |
|---|---|
| `original_BVBRC_table.csv` | Genome metadata from BV-BRC (accession, isolation source, host, etc.) |
| `original_NCBI_table.csv` | Genome metadata from NCBI |

### `genomes_by_group/`
Final genome tables after quality control, split by isolation source, with accession and metadata. These genomes were used in all downstream analyses.

| File | Group |
|---|---|
| `abaumannii_human.csv` | Human (n = 684) |
| `abaumannii_hospital.csv` | Hospital (n = 118) |
| `abaumannii_environmental.csv` | Environmental (n = 209) |
| `abaumannii_animal.csv` | Animal (n = 83) |

### `quality_control/`
Genome quality assessment performed before the analyses.

| Subdirectory | Content |
|---|---|
| `out_checkm/` | CheckM output (completeness and contamination), one file per group: `{group}_checkm.tsv` |
| `out_fastani/` | FastANI output (average nucleotide identity, used to confirm species identity), one file per group: `{group}_ANI.csv` |

Filtering criteria:
* Assembly: N50 ≥ 10,000 bp, ≤ 2,000 contigs, total size between 3.5 and 5.0 Mb, and sequenced on Illumina or with hybrid approaches.
* CheckM: completeness > 95% and contamination < 5%.
* FastANI: ANI > 95% relative to the *A. baumannii* ATCC 19060 reference genome (GCF_009035845.1).

### `genome_annotations_by_group/`
Pan-genome gene annotations organized by isolation source. Genomes were annotated with Prokka, the pan-genome was built with Roary, and functional annotation was performed with eggNOG-mapper. Each folder (`animal_annotations/`, `environmental_annotations/`, `hospital_annotations/`, `human_annotations/`) contains one file per pan-genome partition. Each file lists the genes of the partition with their Clusters of Orthologous Groups (COG) class (eggNOG-mapper) and the sequence of each annotated gene.

| File | Partition | Definition |
|---|---|---|
| `{group}_core_annotations.csv` | Core genes | Present in 95% to 100% of the genomes (minimum BLASTp identity of 95%) |
| `{group}_shell_annotations.csv` | Shell genes | Present in 15% to < 95% of the genomes |
| `{group}_cloud_annotations.csv` | Cloud genes | Present in 0% to < 15% of the genomes |

The pan-genome analysis was run for all genomes combined and separately for each isolation source.

### `phylogenetic_tree/`
Files for the phylogenomic analysis and sequence typing.

| Path | Description |
|---|---|
| `tree.nwk` | Phylogenetic tree (Newick), built from the core-genome alignment with FastTree |
| `out_mlst/mlst_{group}.csv` | MLST results (sequence type per genome, Pasteur seven-gene scheme), one file per group |
| `tree_annotation/st_annotation.txt` | iTOL annotation: sequence type |
| `tree_annotation/tree_group_annotation.txt` | iTOL annotation: isolation source |
| `tree_annotation/oxa_23_tree_annotation.txt` | iTOL annotation: presence of *bla*<sub>OXA-23</sub> |
| `tree_annotation/oxa_24_tree_annotation.txt` | iTOL annotation: presence of *bla*<sub>OXA-24</sub> |

The tree and annotation files can be loaded directly in [iTOL](https://itol.embl.de/).

### `rgi_output_tables/`
Antimicrobial resistance genes detected by comparing the annotated protein sequences against CARD with RGI, one file per group: `rgi_{group}_table.txt`. Each row is one detection in one genome. Only genes annotated as Perfect or Strict hits were kept; Loose hits were not included.

### `vfdb_output_tables/`
Virulence genes detected by comparing protein sequences against VFDB with ABRicate, one file per group: `vfdb_{group}_table.csv`. Both the VFDB core dataset (experimentally validated genes) and the full dataset (known and predicted genes) were used.

### `gene_grouping/`
Grouping of genes into categories before the statistical tests.

| File | Description |
|---|---|
| `resistance_gene_grouping.csv` | Grouping of the resistance genes identified by RGI |
| `virulence_gene_grouping.csv` | Grouping of the virulence genes identified in VFDB |

### `statistical_tests/`
Comparison of gene frequencies between isolation sources using Fisher's exact test with FDR correction (R).

**`resistance_genes/`**

| File | Description |
|---|---|
| `statistical_input_args.csv` | Input: count of each resistance gene in each group |
| `resistance_statistical_analysis.R` | R script with the statistical tests |
| `resistance_results_fisher_test.xlsx` | Results of the tests |

**`virulence_genes/`**

| File | Description |
|---|---|
| `statistical_input_virulence.csv` | Input: count of each virulence gene in each group |
| `virulence_statistical_analysis.R` | R script with the statistical tests |
| `virulence_results_fisher_test.xlsx` | Results of the tests |

The presence or absence of each resistance or virulence gene was compared between human isolates and each of the other isolation sources using Fisher's exact test. Genes exclusive to or absent from the human group were excluded from each comparison. P-values were adjusted with the false discovery rate (FDR) correction, and associations were considered significant when the adjusted p-value was < 0.05. Odds ratios and 95% confidence intervals were estimated for the significant genes.

## Software

| Step | Tool | Version |
|---|---|---|
| Genome retrieval | BV-BRC | v3.53.3 |
| Genome retrieval | NCBI Pathogen Detection | – |
| Genome quality | CheckM | v1.2.3 |
| Species confirmation | FastANI | v1.34 |
| Genome annotation | Prokka | v1.14.6 |
| Pan-genome | Roary | v3.13.0 |
| Functional annotation | eggNOG-mapper | v2.1.13 |
| Phylogeny | FastTree | v2.1.11 |
| Tree visualization | iTOL | v7 |
| MLST | mlst | v2.23.0 |
| Resistance genes | RGI / CARD | v6.0.4 / v4.0.1 |
| Virulence genes | ABRicate / VFDB | v1.0.1 |
| Statistics | R | v4.6.2 |
| Statistics | openxlsx, rstatix | v4.2.8, v0.7.2 |
