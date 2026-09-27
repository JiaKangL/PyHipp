#!/bin/bash

# Submit this script with: sbatch <this-filename>
# 2022 Quiz II pattern: ONE channel's low-frequency RPLLFP + its FreqSpectrum.
# Run sbatch from INSIDE the target channel dir, e.g. /data/picasso/20181101/session01/array02/channel033
# (submit with the env1 conda env active -- sbatch passes your shell env to the job)

#SBATCH --time=24:00:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --cpus-per-task=1   # number of processors per task
#SBATCH -J "rpllfpfs"   # job name

## /SBATCH -p general # partition (queue)
#SBATCH -o rpllfpfs-slurm.%N.%j.out # STDOUT
#SBATCH -e rpllfpfs-slurm.%N.%j.err # STDERR

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
python -u -c "import PyHipp as pyh; \
pyh.RPLLFP(saveLevel=1,lowFreq=0.1,highFreq=250); \
pyh.FreqSpectrum(saveLevel=1);"
