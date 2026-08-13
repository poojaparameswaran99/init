#!/bin/bash
#SBATCH --partition=singhlab-gpu # partition
#SBATCH --account=singhlab
#SBATCH --job-name=check_storage    # job -name , change from command line 
#SBATCH --mem=200G
#SBATCH --time=12-00:00:00 # you have asked for 12 days
#SBATCH --output=slurm_output/%x.%j.out # Standard output log, %x is the job name, %j is the job ID, y is custom time stamp
#SBATCH --error=slurm_output/%x.%j.err      # Standard error log, %x is the job name, %j is the job ID
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=pooja.parameswaran@duke.edu

echo Job Name: check_storage

du -sh /hpc/group/soderlinglab/* | sort -hr
#gdu -n -shx /hpc/group/soderlinglab/* | sort -hr

echo "=== Depth 2 (subdirs) ==="
du -h --max-depth=2 /hpc/group/soderlinglab/ | sort -hr | head -50
