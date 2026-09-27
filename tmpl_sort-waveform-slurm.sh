#!/bin/bash

# Submit this script with: sbatch <this-filename>
# 2023 Quiz II pattern: spike-sort ONE channel (mountain_batch -> export_mountain_cells),
# then build its Waveform object. NO RPLHighPass call (it already ran).
# Run sbatch from INSIDE the target channel dir, e.g. /data/picasso/20181101/session01/array01/channel002
# Needs the cenv0..cenv63 clones + /data/picasso/envlist.hkl (see quiz-primer.md Appendix B).
# Each job checks out its own conda env from the pool, so MountainSort jobs don't fight over one file lock.

#SBATCH --time=24:00:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --cpus-per-task=1   # number of CPUs for this task
#SBATCH -J "sortwf"   # job name

## /SBATCH -p general # partition (queue)
#SBATCH -o sortwf-slurm.%N.%j.out # STDOUT
#SBATCH -e sortwf-slurm.%N.%j.err # STDERR

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
/data/miniconda3/bin/conda init
source ~/.bashrc
envarg=`/data/src/PyHipp/envlist.py`
conda activate $envarg

python -u -c "import PyHipp as pyh; \
import time; \
from PyHipp import mountain_batch; \
mountain_batch.mountain_batch(); \
from PyHipp import export_mountain_cells; \
export_mountain_cells.export_mountain_cells(); \
pyh.Waveform(saveLevel=1); \
print(time.localtime());"

conda deactivate
/data/src/PyHipp/envlist.py $envarg
