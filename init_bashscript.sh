#!/bin/bash
# Generates a SLURM job-script skeleton. This file is auto-sourced by the lab
# .bashrc, so after setup you can just run:
#   init_bashscript my_job.sh
# It writes my_job.sh and opens it in vim. Edit the partition, resources, email,
# and the python line before submitting with: sbatch my_job.sh

init_bashscript() {
	SCRIPTNAME=${1-untitled.sh}   # arg1, or untitled.sh
	JOBNAME=${SCRIPTNAME%.sh}

	cat > "$SCRIPTNAME" <<EOF
#!/bin/bash
#SBATCH --partition=cellbio-dgx            # change to a partition you can use
#SBATCH --account=soderlinglab
#SBATCH --job-name=$JOBNAME
#SBATCH --gres=gpu:1
#SBATCH --mem=40G
#SBATCH --time=12-00:00:00                 # 12 days max — lower this for most jobs
#SBATCH --output=slurm_output/%x.%j.out    # %x=job name, %j=job ID
#SBATCH --error=slurm_output/%x.%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=<your_netid>@duke.edu  # <-- CHANGE to your Duke email

echo "Job Name: $JOBNAME"

export TORCH_HOME=/cwork/\$USER
mkdir -p slurm_output
python src/<SOMEFILE>.py "\$@"
EOF

	chmod +wx "$SCRIPTNAME"
	vim "$SCRIPTNAME"
}
