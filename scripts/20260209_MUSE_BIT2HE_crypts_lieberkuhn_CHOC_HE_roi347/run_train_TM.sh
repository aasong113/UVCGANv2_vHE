#!/usr/bin/env bash
set -euo pipefail

ROOT_DATA_PATH="/home/durrlab/Desktop/Anthony/data/20260210_duodenum_crypts_lieberkuhn_MUSE_BIT"
if [[ -z "${ROOT_DATA_PATH}" ]]; then
  echo "Usage: $(basename "$0") /path/to/root_data_path" >&2
  echo "Expected folders under root: BIT/ and FFPE_HE/" >&2
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRAIN_PY="/home/durrlab/Desktop/Anthony/UGVSM/UVCGANv2_vHE/scripts/20260209_MUSE_BIT2HE_crypts_lieberkuhn_CHOC_HE_roi347/train.py"
REPO_ROOT="/home/durrlab/Desktop/Anthony/UGVSM/UVCGANv2_vHE"

GPU="${GPU:-0}"
BATCH_SIZE="${BATCH_SIZE:-4}"
GEN="${GEN:-uvcgan2}"
HEAD="${HEAD:-bn}"
LAMBDA_GP="${LAMBDA_GP:-0.01}"
LAMBDA_CYCLE="${LAMBDA_CYCLE:-10.0}"
LR_GEN="${LR_GEN:-5e-5}"

# Where training artifacts are written. train.py uses:
#   outdir = os.path.join(ROOT_OUTDIR, '20260112_Inverted_combined_BIT2HE_muscularis-submucosa_train')
UVCGAN2_OUTDIR="/home/durrlab/Desktop/Anthony/UGVSM/UVCGANv2_vHE/scripts/20260209_MUSE_BIT2HE_crypts_lieberkuhn_CHOC_HE_roi347/outdir"

cmd=(
  python3 "${TRAIN_PY}"
  --root_data_path "${ROOT_DATA_PATH}"
  --batch-size "${BATCH_SIZE}"
  --gen "${GEN}"
  --head "${HEAD}"
  --lambda-gp "${LAMBDA_GP}"
  --lambda-cycle "${LAMBDA_CYCLE}"
  --lr-gen "${LR_GEN}"
)

echo "Using train.py: ${TRAIN_PY}"
echo "ROOT_DATA_PATH: ${ROOT_DATA_PATH}"
echo "CUDA_VISIBLE_DEVICES: ${GPU}"
echo "UVCGAN2_OUTDIR: ${UVCGAN2_OUTDIR}"
echo "GEN: ${GEN} | HEAD: ${HEAD} | BATCH_SIZE: ${BATCH_SIZE}"

PYTHONPATH="${REPO_ROOT}${PYTHONPATH:+:${PYTHONPATH}}" \
  CUDA_VISIBLE_DEVICES="${GPU}" UVCGAN2_OUTDIR="${UVCGAN2_OUTDIR}" "${cmd[@]}"
