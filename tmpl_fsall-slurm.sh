#!/bin/bash

# Submit this script with: sbatch --dependency=afterany:<ids> <this-filename>
#   (or: bash /data/src/PyHipp/consol_dep.sh /data/src/PyHipp/fsall-slurm.sh afterany)
# 2022 Quiz II pattern: cumulative LOW-frequency and HIGH-frequency FreqSpectrum objects.
# Run from the directory the cumulative objects should live in (e.g. /data/picasso/20181101/session01/array02).
#
# exclude below is the UNION of what the 2022 key needed from each start directory
# (array02 dir: none needed; session01 dir: array01/03/04; day dir: also eye + mountains).
# Extra patterns that match nothing are harmless. EDIT for the scope in the prompt.
# The 2022 paper's own script used the instructor's account in the SNS ARN -- this one uses yours.

#SBATCH --time=24:00:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --cpus-per-task=1   # number of processors per task
#SBATCH -J "fsall"   # job name

## /SBATCH -p general # partition (queue)
#SBATCH -o fsall-slurm.%N.%j.out # STDOUT
#SBATCH -e fsall-slurm.%N.%j.err # STDERR

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
python -u -c "import PyHipp as pyh; \
import DataProcessingTools as DPT; \
lfall = DPT.objects.processDirs(dirs=None, exclude=['*array01*','*array03*','*array04*','*eye*','*mountains*'], objtype=pyh.FreqSpectrum, saveLevel=1); \
lfall.save(); \
hfall = DPT.objects.processDirs(dirs=None, exclude=['*array01*','*array03*','*array04*','*eye*','*mountains*'], objtype=pyh.FreqSpectrum, loadHighPass=True, pointsPerWindow=3000, saveLevel=1); \
hfall.save();"
rc=$?   # keep python's exit status. A script that ends in "aws sns publish" would otherwise report the SNS
        # command's status, so --dependency=afterok could not tell that python failed (primer Appendix F1).

aws sns publish --topic-arn arn:aws:sns:ap-southeast-1:337909757612:awsnotify --message "JobDone"
exit $rc
