#!/usr/bin/env bash
set -euo pipefail

CUDA_VISIBLE_DEVICES=0 python3 /home/durrlab/Desktop/Anthony/UGVSM/UVCGANv2_vHE/scripts/20260207_Inverted_MUSE_BIT2HE_crypts_lieberkuhn_newHE_data/pretrain.py \
  --root_data_path /home/durrlab/Desktop/Anthony/data/duodenum_crypts_lieberkuhn_MUSE_BIT \
  --batch-size 4
