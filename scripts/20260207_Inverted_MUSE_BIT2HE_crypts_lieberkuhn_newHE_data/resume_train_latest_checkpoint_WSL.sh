#!/usr/bin/env bash
set -euo pipefail

# Resumes the most recent training run (by mtime) from the latest checkpoint.
# UVCGANv2's train loop automatically loads the last checkpoint found in
#   <savedir>/checkpoints/
# and continues training.
#
# Usage:
#   bash resume_train_latest_checkpoint_WSL.sh [ROOT_DATA_PATH]
#
# Optional overrides:
#   RUN_OUTDIR=/path/to/..._train          # folder that contains model_m(...)/ dirs
#   SAVEDIR=/path/to/model_m(...)/         # pick a specific run directory
#   GPU=0                                  # CUDA_VISIBLE_DEVICES
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRAIN_PY="${SCRIPT_DIR}/train.py"

GPU="${GPU:-0}"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  sed -n '1,80p' "$0"
  exit 0
fi

TRAIN_OUTDIR_NAME="20260207_Inverted_MUSE_BIT2HE_crypts_lieberkuhn_newHE_data_train"

if [[ -z "${RUN_OUTDIR:-}" ]]; then
  if [[ -d "${SCRIPT_DIR}/outdir/${TRAIN_OUTDIR_NAME}" ]]; then
    RUN_OUTDIR="${SCRIPT_DIR}/outdir/${TRAIN_OUTDIR_NAME}"
  elif [[ -d "/home/durrlab-asong/Anthony/UVCGANv2_vHE/outdir/${TRAIN_OUTDIR_NAME}" ]]; then
    RUN_OUTDIR="/home/durrlab-asong/Anthony/UVCGANv2_vHE/outdir/${TRAIN_OUTDIR_NAME}"
  else
    echo "Error: Could not find run outdir automatically." >&2
    echo "Set RUN_OUTDIR=/path/to/${TRAIN_OUTDIR_NAME} and re-run." >&2
    exit 2
  fi
fi

if [[ -z "${SAVEDIR:-}" ]]; then
  # Pick most recently modified matching run.
  shopt -s nullglob
  candidates=( "${RUN_OUTDIR}"/model_m\(uvcgan2\)_d\(basic\)_g\(*\)_* )
  shopt -u nullglob

  if (( ${#candidates[@]} == 0 )); then
    echo "Error: No run directories found under: ${RUN_OUTDIR}" >&2
    exit 2
  fi

  # Sort by mtime (descending) and take the first.
  SAVEDIR="$(ls -1td "${candidates[@]}" | head -n 1)"
fi

CONFIG_JSON="${SAVEDIR}/config.json"
[[ -f "$CONFIG_JSON" ]] || { echo "Error: Missing config: $CONFIG_JSON" >&2; exit 2; }

BASE_OUTDIR="$(dirname "$RUN_OUTDIR")"

LABEL_FILE="${SAVEDIR}/label"
if [[ -f "$LABEL_FILE" ]]; then
  label="$(tr -d '\r\n' < "$LABEL_FILE")"
else
  # Fallback: parse from directory name (may be wrong if label contains underscores).
  basename_dir="$(basename "$SAVEDIR")"
  label="${basename_dir##*_}"
fi

[[ -n "$label" ]] || { echo "Error: Could not determine label for: $SAVEDIR" >&2; exit 2; }

gen="${label%%-*}"
rest="${label#*-}"              # e.g. bn_False-10.0-0.01-5e-05
head="${rest%%_*}"              # bn
rest="${rest#*_}"               # False-10.0-0.01-5e-05
IFS='-' read -r no_pretrain lambda_cycle lambda_gp lr_gen <<< "$rest"

batch_size="$(
  python3 - <<PY
import json
with open(r"$CONFIG_JSON","r") as f:
  conf = json.load(f)
print(conf.get("batch_size", ""))
PY
)"

root_from_config="$(
  python3 - <<PY
import json, os
with open(r"$CONFIG_JSON","r") as f:
  conf = json.load(f)
paths = []
for d in conf["data"]["datasets"]:
  p = d["dataset"]["path"]
  paths.append(p)
print(os.path.commonpath(paths))
PY
)"

ROOT_DATA_PATH="${1:-${root_from_config}}"
if [[ -z "$ROOT_DATA_PATH" ]]; then
  echo "Error: ROOT_DATA_PATH not provided and could not infer from config." >&2
  exit 2
fi

latest_ckpt="-1"
if [[ -d "${SAVEDIR}/checkpoints" ]]; then
  latest_ckpt="$(
    ls -1 "${SAVEDIR}/checkpoints" 2>/dev/null \
      | sed -n 's/^\([0-9]\+\)_.*/\1/p' \
      | sort -n \
      | tail -n 1 \
      || true
  )"
fi

echo "Run outdir:  ${RUN_OUTDIR}"
echo "Savedir:     ${SAVEDIR}"
echo "Label:       ${label}"
echo "Latest ckpt: ${latest_ckpt}"
echo "GPU:         ${GPU}"
echo "UVCGAN2_OUTDIR (base): ${BASE_OUTDIR}"

cmd=(
  python3 "${TRAIN_PY}"
  --root_data_path "${ROOT_DATA_PATH}"
  --batch-size "${batch_size}"
  --gen "${gen}"
  --head "${head}"
  --lambda-gp "${lambda_gp}"
  --lambda-cycle "${lambda_cycle}"
  --lr-gen "${lr_gen}"
)

if [[ "${no_pretrain}" == "True" ]]; then
  cmd+=(--no-pretrain)
fi

CUDA_VISIBLE_DEVICES="${GPU}" UVCGAN2_OUTDIR="${BASE_OUTDIR}" "${cmd[@]}"
