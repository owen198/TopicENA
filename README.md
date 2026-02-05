# TopicENA
TopicENA is a lightweight, open-source pipeline for scalable Epistemic Network Analysis, combining neural topic modeling with automated semantic coding and human-in-the-loop interpretation.



## Project Structure

```text
TopicENA/
├─ demo/
│  ├── README.md
│  ├── asap20_preprocess.py
│  └── run_topicena.sh
├── topicena/
│   ├── __init__.py
│   ├── bertopic_runner.py
│   ├── ena_script.R
│   ├── cli.py
│   └── rena_executor.py
├── pyproject.toml
└─ README.md
```


## Installation

Install the following packages in Ubuntu

```bash
sudo apt update
sudo apt install -y \
  build-essential pkg-config \
  libcurl4-openssl-dev libssl-dev \
  libxml2-dev \
  libfontconfig1-dev libfreetype6-dev \
  libharfbuzz-dev libfribidi-dev \
  libpng-dev libjpeg-dev
```

Clone this repository and install TopicENA in editable mode:

```bash
git clone https://github.com/owen198/topicena.git
cd topicena

# create virtual environment
python -m venv .venv

# activate virtual environment
# macOS / Linux
source .venv/bin/activate

# Windows
# .venv\Scripts\activate

# install TopicENA and Python dependencies
python -m pip install -e .
```

Install the required R packages as a normal user (not root):

```bash
R -q -e 'install.packages(
  c("rENA", "htmlwidgets", "htmltools", "devtools", "pkgload", "webshot2"),
  repos = "https://cloud.r-project.org"
)'
```

Check whether TopicENA is installed and where it is loaded from:

```bash
python -m pip show topicena

topicena --help  
```


## Executing TopicENA

```bash
topicena 
```



## Removing TopicENA

To remove TopicENA from your environment:

```bash
python -m pip uninstall topicena
```

## Command-Line Parameters

This section summarizes the main command-line parameters used in TopicENA, along with their default values and purposes.

### Core TopicENA Parameters

|Comp. | Parameter | Type | Default | Description |
|---------|---------|------|---------|-------------|
|Core TopicENA | `--input`        | string  | **required** | Path to the input CSV file (e.g., `data/sample/sample_students.csv`) |
|         | `--output`            | string  | `output` | Directory to store all BERTopic and rENA outputs |
|         | `--topic_file`        | string  | `ena_input.csv` | File name used to record document–topic assignments as input to the ENA script |
|         | `--prob_th`           | float   | `0.01` | Probability threshold for multi-topic assignment |
|         | `--text_col`          | string  | `reflection` | Name of the column containing text |
|         | `--id_col`            | string  | `id` | Name of the column containing user/document id  |
|         | `--group_col`         | string  | `group` | Name of the column containing group/condition labels |
|         | `--number_of_keywords`| int     | `2` | "Number of keywords used to represent each topic in ENA visualization |
|UMAP     | `--n_neighbors`       | int     | `10` | UMAP parameter controlling local neighborhood size |
|         | `--n_components`      | int     | `5` | Number of embedding dimensions produced by UMAP |
|         | `--min_dist`          | float   | `0.0` | Minimum distance between embedded points |
|HDBSCAN  | `--min_cluster_size`  | int     | `20` | Minimum size of topic clusters |
|         | `--min_samples`       | int     | `5` | Controls cluster robustness and noise sensitivity |
|BERTopic | `--min_topic_size`    | int     | `5` | Minimum number of documents per topic |
|rENA     | `--window_size_back`  | int     | `20` | rENA `window.size.back` parameter controlling temporal co-occurrence |

## Troubleshooting

### Too few valid topics detected

If you see the following message during execution:

```
[TopicENA] Abort: only N valid topics found 
(<= 2). Skip visualization and ENA.
```
This means that **BERTopic detected too few topics (two or fewer)**, and TopicENA stops the topic detection process before running visualization and ENA. This usually happens when the topic clustering is **too coarse**, causing many documents to be merged into a small number of topics. Try adjusting the topic modeling parameters and rerun the analysis. In particular, you may try adjusting the parameter: `--n_neighbors`, `--min_cluster_size`, `--min_topic_size` and `--min_dist`.



### Duplicate keyword columns detected

If you encounter the following warning during execution:
```
[TopicENA] Abord: Duplicate keyword columns detected
This usually indicates that the topic configuration is too fine-grained.
```

This means that BERTopic has produced topics with overlapping or identical keywords, which can lead to duplicated semantic codes in the ENA input and cause issues in downstream analysis. This situation typically occurs when the topic modeling configuration is too fine-grained, resulting in multiple topics sharing very similar top keywords. One practical solution is to **increase the number of keywords used to represent each topic**. TopicENA uses a limited number of keywords to construct semantic codes by default. You may try adjusting the parameter: `--number_of_keywords`


