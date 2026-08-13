#!/bin/bash
#SBATCH --partition=cellbio-dgx # partition
#SBATCH --account=soderlinglab
#SBATCH --job-name=find    # job -name , change from command line 
#SBATCH --mem=40G
#SBATCH --time=12-00:00:00 # you have asked for 12 days
#SBATCH --output=slurm_output/%x.%j.out # Standard output log, %x is the job name, %j is the job ID, y is custom time stamp
#SBATCH --error=slurm_output/%x.%j.err      # Standard error log, %x is the job name, %j is the job ID
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=pooja.parameswaran@duke.edu

echo Job Name: find


export TORCH_HOME='/cwork/pkp14'
## don't otuput warnings
find . -type f -iname "*mapped_20250331_Src_substrate_candidates*" 2>/dev/null
