#!/bin/bash

# Submit this script with: sbatch <this-filename>
# 2025 Quiz 1B pattern: (re)generate ONE channel's Waveform object.
# Run sbatch from INSIDE the target channel dir, e.g. /data/picasso/20181101/session01/array01/channel002
# (submit with the env1 conda env active -- sbatch passes your shell env to the job)
# No SNS line on purpose: this runs once per channel (100+ jobs) and would flood your inbox.
# NOTE: this only reads existing spike-sorting output. If firings.mda is missing for the
#       channel, use tmpl_sort-waveform-slurm.sh instead (2023 pattern).

#SBATCH --time=24:00:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --cpus-per-task=1   # number of CPUs for this task
#SBATCH -J "waveform"   # job name

## /SBATCH -p general # partition (queue)
#SBATCH -o waveform-slurm.%N.%j.out # STDOUT
#SBATCH -e waveform-slurm.%N.%j.err # STDERR

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
python -u -c "import PyHipp as pyh; \
pyh.Waveform(saveLevel=1);"
