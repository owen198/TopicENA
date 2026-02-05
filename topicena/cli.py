# topicena/cli.py
import argparse
import os
import sys
from pathlib import Path

from topicena.bertopic_runner import BERTopicConfig, fit_transform_docs, multi_topic_assignment, get_topic_keywords
from topicena.rena_executor import RENAConfig, run_rena_rscript

import pandas as pd


def ensure_dir(path: str) -> None: 
    os.makedirs(path, exist_ok=True)

def try_write_png(fig, out_png: str) -> None:
    try:
        fig.write_image(out_png, scale=2)
    except Exception as e:
        print(f"[SKIP] PNG export failed (install kaleido?): {out_png}\n  Reason: {e}")

def main():


    # Stage 0: Load config
    parser = argparse.ArgumentParser(prog="topicena", description="TopicENA: Topic-based Epistemic Network Analysis")


    # TopicENA
    parser.add_argument("--prob_th", type=float, default=0.01, help="Probability threshold for multi-topic assignment (default: 0.01)")
    parser.add_argument("--input", type=str, required=True, help="Path to input CSV file (e.g., data/asap20.csv)")
    parser.add_argument("--topic_file", type=str, default="ena_input.csv", help="File to record doc topic, as the input to ENA script (e.g., ena_input.csv)")
    parser.add_argument("--output", type=str, default="output", help="Path to output BERTopic and rENA results (e.g., output)")
    parser.add_argument("--number_of_keywords", type=int, default=2, help="Number of keywords used to represent each topic in ENA visualization (default: 2)")

    # UMAP
    parser.add_argument("--n_neighbors", type=int, default=10, help="UMAP n_neighbors parameter (default: 10)")
    parser.add_argument("--n_components", type=int, default=5, help="UMAP n_components parameter (default: 5)")
    parser.add_argument("--min_dist", type=float, default=0.0, help="UMAP min_dist parameter (default: 0.0)")

    # HDBSCAN
    parser.add_argument("--min_cluster_size", type=int, default=20, help="HDBSCAN min_cluster_size parameter (default: 20)")
    parser.add_argument("--min_samples", type=int, default=5, help="HDBSCAN min_samples parameter (default: 5)")

    # BERTopic
    parser.add_argument("--min_topic_size", type=int, default=5, help="BERTopic min_topic_size parameter (default: 5)")

    # rENA
    parser.add_argument("--window_size_back", type=int, default=20, help="rENA window.size.back parameter (default: 20)")

    #1/29 Tiffany
    # Input column names (make CLI dataset-agnostic)
    parser.add_argument("--text_col", type=str, default="reflection",
                        help="Name of the column containing text (default: reflection)")
    parser.add_argument("--id_col", type=str, default="id",
                        help="Name of the column containing user/document id (default: id)")
    parser.add_argument("--group_col", type=str, default="group",
                        help="Name of the column containing group/condition labels (default: group)")


    args = parser.parse_args()


    # Stage 1: Load dataset
    input_path = Path(args.input)
    input_pd = pd.read_csv(input_path) 
    # if not input_path.exists():
    #     raise FileNotFoundError(f"Input file not found: {input_path}")

    #input_pd = pd.read_csv(input_path)
    #docs = input_pd["reflection"].astype("str").to_list()
    #input_pd = pd.read_csv(input_path)

    # Validate required columns
    missing = [c for c in [args.text_col, args.id_col, args.group_col] if c not in input_pd.columns]
    if missing:
        raise ValueError(
            f"Missing column(s): {missing}. "
            f"Available columns: {list(input_pd.columns)}. "
            f"Use --text_col/--id_col/--group_col to specify."
        )

    docs = input_pd[args.text_col].astype("str").to_list()




    # Stage 2: BERTopic
    bertopic_cfg = BERTopicConfig(
        prob_th=args.prob_th,
        n_neighbors=args.n_neighbors,
        n_components=args.n_components,
        min_dist=args.min_dist,
        min_cluster_size=args.min_cluster_size,
        min_samples=args.min_samples,
        min_topic_size=args.min_topic_size,
    )

    model, topics, probs = fit_transform_docs(
        docs=docs,
        cfg=bertopic_cfg,
        embeddings=None,  
    )

    info = model.get_topic_info()
    n_valid_topics = (info.Topic != -1).sum()

    if n_valid_topics <= 2:
        print(f"[TopicENA] Abort: only {n_valid_topics} valid topics found "
                "(<= 2). Skip visualization and ENA. \n")
        sys.exit(1)




    # Stage 2: Create BERTopic output, as the input of rENA
    top_keywords_dict = get_topic_keywords(model)
    # print(top_keywords_dict)

    new_columns = [
        ".".join(top_keywords_dict[i][:args.number_of_keywords])
        for i in range(len(top_keywords_dict))
    ]
    # print(new_columns)

    topic_df = multi_topic_assignment(probs, prob_th=args.prob_th)
    topic_df.columns = new_columns
    topic_df.insert(0, "doc_id", range(len(topic_df)))
    
    topic_df.insert(0, "text", docs)

    #topic_df["UserName"] = input_pd["id"].values
    #topic_df["Condition"] = input_pd["group"].values
    topic_df["UserName"] = input_pd[args.id_col].values
    topic_df["Condition"] = input_pd[args.group_col].values

    topic_df = topic_df.reset_index().rename(columns={"index": "ActivityNumber"})

    topic_df["text"] = topic_df["text"].str.split(".")

    if topic_df.columns.duplicated().any():
        dup = topic_df.columns[topic_df.columns.duplicated()].tolist()
        print(f"[TopicENA] Abort: Duplicate keyword columns detected: {dup}\n"
                "This usually indicates that the topic configuration is too fine-grained.\n")
        sys.exit(1)

    topic_df = topic_df.explode("text")

    topic_df["text"] = topic_df["text"].str.strip()
    topic_df = topic_df[topic_df["text"] != ""]

    topic_df['text'] = topic_df['text'].str.split('.')
    topic_df = topic_df.explode("text")

    ensure_dir(args.output)
    topic_df.to_csv(args.output + "/" + args.topic_file, index=False, encoding="utf-8")


    # Stage 3: Plot BERTopic results
    # (A) Topic overview
    fig_topics = model.visualize_topics()
    out_html = os.path.join(args.output, "fig_topics_overview.html")
    fig_topics.write_html(out_html)
    try_write_png(fig_topics, os.path.join(args.output, "fig_topics_overview.png"))

    # (B) Keywords
    fig_barchart = model.visualize_barchart(top_n_topics=10, n_words=5)
    out_html = os.path.join(args.output, "fig_topic_keywords_barchart.html")
    fig_barchart.write_html(out_html)
    try_write_png(fig_barchart, os.path.join(args.output, "fig_topic_keywords_barchart.png"))


    # Stage 4: ENA
    rena_cfg = RENAConfig(window_size_back=args.window_size_back, 
                          ena_input=args.output + "/" + args.topic_file,
                          ena_output=args.output)

    result = run_rena_rscript(
        cfg=rena_cfg,
        extra_args=None
    )
    print(result.stdout)

if __name__ == "__main__":
    main()
