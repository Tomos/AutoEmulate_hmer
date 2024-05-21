#!/bin/bash

#SBATCH --job-name=hmer_intro
#SBATCH --output=./logs_overall/%x_%A.log
#SBATCH --time=1-12:00:00
#SBATCH -N 1  #(number of nodes requested)
#SBATCH -n 1 #(number of cores requested)
#SBATCH --partition=standard
#SBATCH --qos=standard
#SBATCH --account=ec232
#SBATCH --mem=1G
#SBATCH --chdir='.'

export HOME="/home/ec232/ec232/${USER}"

# Run the non-default version of anaconda (this needs to be in the /work/ directory, rather than /home/):
. "/work/ec232/ec232/tomosprysjones/anaconda3/etc/profile.d/conda.sh"

# Initialize the conda environment
eval "$(conda shell.bash hook)"
conda activate $1

#### PLEASE KEEP JOB NAMES TO LENGTH 8 CHARACTERS
#### PLEASE DONT PUT DATE/TIME INFORMATION IN JOBNAMES
#### PLEASE DONT USE SPACES OR EXOTIC CHARACTERS IN JOBNAMES - ONLY ALPHANUMERIC

# Initial set up
RLD=${SLURM_JOB_NAME}
ARID=${SLURM_ARRAY_TASK_ID}

# Change working directory, create other required directories
cd "${PWD}" || exit
mkdir -p "${PWD}"/console_output || exit
mkdir -p "${PWD}"/runlogs || exit

# Select country and export as environment variable

# Capture date-time
SDT=$(date --utc +%Y-%m-%d-%H%M)

# Runlog directory and path
# A new directory with the same name as the cluster job is made to contain the runlogs
mkdir -p "${PWD}"/runlogs/"${RLD}"
RLP="${PWD}/runlogs/${RLD}/${SDT}_${RLD}_${ARID}_IND_RUNLOG.log"

# Console output directory and names
mkdir -p "${PWD}"/console_output/"${RLD}"
CON="${PWD}/console_output/${RLD}/${SDT}_${RLD}_${ARID}_IND_CO.log"

# Construct RUNID_TS
RUNID_TS="${SDT}_${RLD}_${ARID}_IND"
export RUNID_TS

# Log start
echo "${SDT} - ${RLD} - IND - START" >> "${RLP}"

# Run Rscript; redirect stdout and stderr to CO file
Rscript AutoEmulateRerun.R -c "IND" -n 20 -p "input_all.csv" -x "XMLinput_target.xml"  -t "target_count.csv" >& "${CON}" || echo "$(date --utc +%Y-%m-%d-%H%M) - IND - RSCRIPT FAILURE" >> "${RLP}"

# Signal end of script
echo "$(date --utc +%Y-%m-%d-%H%M) - IND - END SCRIPT" >> "${RLP}"
