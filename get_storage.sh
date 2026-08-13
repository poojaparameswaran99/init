#!/bin/bash
#SBATCH --partition=singhlab-gpu
#SBATCH --account=singhlab
#SBATCH --job-name=get_storage
#SBATCH --mem=200G
#SBATCH --time=12-00:00:00
#SBATCH --output=slurm_output/%x.%j.out
#SBATCH --error=slurm_output/%x.%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=pooja.parameswaran@duke.edu

echo "========================================"
echo "Storage Analysis for soderlinglab"
echo "Started: $(date)"
echo "========================================"

BASE_DIR="/hpc/group/soderlinglab"

echo ""
echo "TOP-LEVEL DIRECTORIES:"
echo "----------------------------------------"
du -h --max-depth=0 "$BASE_DIR"/* 2>/dev/null | sort -hr

echo ""
echo "SECOND-LEVEL BREAKDOWN:"
echo "----------------------------------------"
du -h --max-depth=1 "$BASE_DIR"/* 2>/dev/null | sort -hr

echo ""
echo "THIRD-LEVEL BREAKDOWN (Top 50):"
echo "----------------------------------------"
du -h --max-depth=2 "$BASE_DIR"/* 2>/dev/null | sort -hr | head -50

echo ""
echo "========================================"
echo "Completed: $(date)"
echo "========================================"
