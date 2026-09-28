#!/bin/bash

#SBATCH --time=24:00:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --cpus-per-task=1   # number of CPUs for this task
#SBATCH -J "uydall"   # job name

#SBATCH -o uydall-slurm.%N.%j.out # STDOUT
#SBATCH -e uydall-slurm.%N.%j.err # STDERR

python -u -c "import PyHipp as pyh; \
import DataProcessingTools as DPT; \
import pickle; \
uydall = DPT.objects.processDirs(level='day', exclude=['*eye*','*mountains*','*20180[7-9]*','*201810*','*201811*'], objtype=pyh.UnityDay); \
uydall.save(); \
f = open('uydallTimePerformance.pkl', 'wb'); \
pickle.dump(uydall.timePerformance, f); \
f.close()"
rc=$?

aws sns publish --topic-arn arn:aws:sns:ap-southeast-1:337909757612:awsnotify --message "UydallDone"
exit $rc
