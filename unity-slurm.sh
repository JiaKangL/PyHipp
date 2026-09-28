#!/bin/bash

# Submit this script with: sbatch <this-filename>
# 2024 Quiz 1 pattern: build ONE session's Unity object.
# Run sbatch from INSIDE the target session dir, e.g. /data/picasso/20180702/session01
# (submit with the env1 conda env active -- sbatch passes your shell env to the job)

#SBATCH --time=24:00:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --cpus-per-task=1   # number of CPUs for this task
#SBATCH -J "unity"   # job name

## /SBATCH -p general # partition (queue)
#SBATCH -o unity-slurm.%N.%j.out # STDOUT
#SBATCH -e unity-slurm.%N.%j.err # STDERR

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
python -u -c "import PyHipp as pyh; \
import DataProcessingTools as DPT; \
DPT.objects.processDirs(dirs=None, objtype=pyh.Unity, saveLevel=1);"
        # command's status, so --dependency=afterok could not tell that python failed (primer Appendix F1).

exit $rc
