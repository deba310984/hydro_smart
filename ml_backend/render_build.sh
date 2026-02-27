#!/usr/bin/env bash
# Render build script — installs deps and trains model
set -e

pip install --no-cache-dir -r requirements.txt
python train_model.py --output .
