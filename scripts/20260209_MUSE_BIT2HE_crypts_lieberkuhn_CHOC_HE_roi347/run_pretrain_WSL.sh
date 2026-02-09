#!/usr/bin/env bash
set -euo pipefail

# Runs the autoencoder pretraining for:
#   20260207_Inverted_MUSE_BIT2HE_crypts_lieberkuhn_pretrain_CHOC_HE_roi347
#
# Example:
#   bash run_pretrain_WSL.sh /home/durrlab-asong/Anthony/duodenum_crypts_lieberkuhn_MUSE_BIT
#
# Optional overrides:
#   GPU=0 BATCH_SIZE=4 GEN=uvcgan2 UVCGAN2_OUTDIR=/some/outdir bash run_pretrain_WSL.sh <ROOT_DATA_PATH>

ROOT_DATA_PATH="${1:-/home/durrlab-asong/Anthony/duodenum_crypts_lieberkuhn_MUSE_BIT}"
if [[ -z "${ROOT_DATA_PATH}" ]]; then
  echo "Usage: $(basename "$0") /path/to/root_data_path" >&2
  echo "Expected folders under root: BIT/ and FFPE_HE/" >&2
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRETRAIN_PY="/home/durrlab-asong/Anthony/UVCGANv2_vHE/scripts/20260209_MUSE_BIT2HE_crypts_lieberkuhn_CHOC_HE_roi347/pretrain.py"

GPU="${GPU:-0}"
BATCH_SIZE="${BATCH_SIZE:-4}"
GEN="${GEN:-uvcgan2}"

# Where training artifacts are written (ROOT_OUTDIR). Override if desired.
UVCGAN2_OUTDIR="${UVCGAN2_OUTDIR:-/home/durrlab-asong/Anthony/UVCGANv2_vHE/scripts/20260209_MUSE_BIT2HE_crypts_lieberkuhn_CHOC_HE_roi347/outdir}"

cmd=(
  python3 "${PRETRAIN_PY}"
  --root_data_path "${ROOT_DATA_PATH}"
  --batch-size "${BATCH_SIZE}"
  --gen "${GEN}"
)

echo "Using pretrain.py: ${PRETRAIN_PY}"
echo "ROOT_DATA_PATH: ${ROOT_DATA_PATH}"
echo "CUDA_VISIBLE_DEVICES: ${GPU}"
echo "UVCGAN2_OUTDIR: ${UVCGAN2_OUTDIR}"
echo "GEN: ${GEN} | BATCH_SIZE: ${BATCH_SIZE}"

CUDA_VISIBLE_DEVICES="${GPU}" UVCGAN2_OUTDIR="${UVCGAN2_OUTDIR}" "${cmd[@]}"

