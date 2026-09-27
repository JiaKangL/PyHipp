#!/bin/bash

# Submit this script with: sbatch --dependency=afterok:<ids> <this-filename>
#   (or: bash /data/src/PyHipp/consol_dep.sh /data/src/PyHipp/wfall-slurm.sh  -- see quiz-primer.md)
# 2023 + 2025 pattern: build and save the CUMULATIVE Waveform object.
# Run from the directory the cumulative object should live in and sweep (usually /data/picasso, or a day dir).
#
# EDIT THE exclude LIST FOR THE SCOPE IN THE PROMPT. processDirs BUILDS any missing object it finds,
# so every out-of-scope day/array must be excluded or the job does far more work than asked.
#   2023: ['*eye*','*mountains*']
#   2025: ['*eye*','*mountains*','*array04*','*20181105*']   (arrays 1-3, days 20181101/20181102 only)
# To make a cumulative Unity / FreqSpectrum instead: change pyh.Waveform to pyh.Unity / pyh.FreqSpectrum.

#SBATCH --time=24:00:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --cpus-per-task=1   # number of CPUs for this task
#SBATCH -J "wfall"   # job name

## /SBATCH -p general # partition (queue)
#SBATCH -o wfall-slurm.%N.%j.out # STDOUT
#SBATCH -e wfall-slurm.%N.%j.err # STDERR

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
python -u -c "import PyHipp as pyh; \
import DataProcessingTools as DPT; \
wfall = DPT.objects.processDirs(dirs=None, exclude=['*eye*','*mountains*','*array04*','*20181105*'], objtype=pyh.Waveform, saveLevel=1); \
wfall.save();"
rc=$?   # keep python's exit status. A script that ends in "aws sns publish" would otherwise report the SNS
        # command's status, so --dependency=afterok could not tell that python failed (primer Appendix F1).

aws sns publish --topic-arn arn:aws:sns:ap-southeast-1:337909757612:awsnotify --message "WFJobDone"
exit $rc
