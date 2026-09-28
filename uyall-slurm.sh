#!/bin/bash

#SBATCH --time=24:00:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --cpus-per-task=1   # number of CPUs for this task
#SBATCH -J "uyall"   # job name

#SBATCH -o uyall-slurm.%N.%j.out # STDOUT
#SBATCH -e uyall-slurm.%N.%j.err # STDERR

python -u -c "import PyHipp as pyh; \
import DataProcessingTools as DPT; \
import pickle; \
uyall = DPT.objects.processDirs(level='session', exclude=['*eye*','*mountains*','*20180[7-9]*','*201810*','*201811*'], objtype=pyh.Unity); \
uyall.save(); \
f = open('uyallTimePerformance.pkl', 'wb'); \
pickle.dump(uyall.timePerformance, f); \
f.close()"
rc=$?

aws sns publish --topic-arn arn:aws:sns:ap-southeast-1:337909757612:awsnotify --message "UyallDone"
exit $rc
