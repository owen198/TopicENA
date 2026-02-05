#!/usr/bin/env bash
set -euo pipefail
set +e

INPUT="./asap20.csv"
NUM_KEYWORDS=2
PROB_TH=0.05

echo "Input: ${INPUT}"
echo "Fixed: number_of_keywords=${NUM_KEYWORDS}, prob_th=${PROB_TH}"
echo

# -------------------------
# COARSE (粗) : 更少 topic、更大群
# -------------------------
echo "[1/5] COARSE_1 (very coarse)"
topicena --input "$INPUT" \
  --n_neighbors 60 --min_dist 0.30 \
  --min_cluster_size 120 --min_topic_size 80 \
  --number_of_keywords "$NUM_KEYWORDS" --prob_th "$PROB_TH" \
  --output t_coarse_1

echo "[2/5] COARSE_2 (coarse)"
topicena --input "$INPUT" \
  --n_neighbors 45 --min_dist 0.20 \
  --min_cluster_size 80 --min_topic_size 50 \
  --number_of_keywords "$NUM_KEYWORDS" --prob_th "$PROB_TH" \
  --output t_coarse_2


# -------------------------
# MEDIUM (中) : 平衡
# -------------------------
echo "[3/5] MEDIUM_1 (balanced, close to your baseline but safer)"
topicena --input "$INPUT" \
  --n_neighbors 35 --min_dist 0.12 \
  --min_cluster_size 30 --min_topic_size 25 \
  --number_of_keywords "$NUM_KEYWORDS" --prob_th "$PROB_TH" \
  --output t_medium_1


# -------------------------
# FINE (細) : 更多 topic、更小群
# -------------------------
echo "[4/5] FINE_1 (fine)"
topicena --input "$INPUT" \
  --n_neighbors 25 --min_dist 0.08 \
  --min_cluster_size 15 --min_topic_size 12 \
  --number_of_keywords "$NUM_KEYWORDS" --prob_th "$PROB_TH" \
  --output t_fine_1

echo "[5/5] FINE_2 (very fine, might get fragmented)"
topicena --input "$INPUT" \
  --n_neighbors 18 --min_dist 0.05 \
  --min_cluster_size 10 --min_topic_size 10 \
  --number_of_keywords "$NUM_KEYWORDS" --prob_th "$PROB_TH" \
  --output t_fine_2

echo
echo "Done."
