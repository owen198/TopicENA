#!/usr/bin/env bash
set -euo pipefail
set +e

INPUT="./asap20.csv"
NUM_KEYWORDS=2
PROB_TH=(0.01 0.03 0.05 0.1 0.2 0.3)
WBS=10

echo "Input: ${INPUT}"
echo "[MEDIUM baseline] nn=35 md=0.12 mcs=30 mts=25"

# 10 candidate window_size_back values (co-occurrence range, from tight to wide)


# i=1
# total=${#WBS[@]}

# for wb in "${WBS[@]}"; do
#   tag=$(printf "wb%02d" "$wb")
#   echo "[$i/$total] MEDIUM_WB ${tag} (window_size_back=${wb})"

#   topicena --input "$INPUT" \
#     --n_neighbors 35 --min_dist 0.12 \
#     --min_cluster_size 30 --min_topic_size 25 \
#     --number_of_keywords "$NUM_KEYWORDS" --prob_th "$PROB_TH" \
#     --window_size_back "$wb" \
#     --output "case2_medium_${tag}"

#   i=$((i+1))
# done

i=1
total=${#PROB_TH[@]}

for prob_th in "${PROB_TH[@]}"; do
  prob_int=$(awk -v p="$prob_th" 'BEGIN { printf "%03d", p*100 }')
  tag="prob_th${prob_int}"
  echo "[$i/$total] MEDIUM_PROB ${tag} (prob_th=${prob_th})"

  topicena --input "$INPUT" \
    --n_neighbors 35 --min_dist 0.12 \
    --min_cluster_size 30 --min_topic_size 25 \
    --number_of_keywords "$NUM_KEYWORDS" --prob_th "$prob_th" \
    --window_size_back "$WBS" \
    --output "case2_medium_${tag}"

  i=$((i+1))
done

echo
echo "Done."
