#!/bin/bash

# Submit ONE job that waits for every job currently in the queue.
# Usage (head node, from the directory the target job should run in):
#   bash /data/src/PyHipp/consol_dep.sh <slurm-script> [afterok|afterany]
#
#   afterok  (default) = target runs only if ALL listed jobs succeed. One failure => target sits PD forever.
#                        This is what 2023 consol_wfjobs.sh and 2025 used.
#   afterany           = target runs when all listed jobs have ended, success or not.
#                        This is what 2022 consol_fsjobs.sh used, and what your fork's consol_jobs.sh uses.
#
# Run it IMMEDIATELY after submitting the batch and before submitting anything else:
# it depends on every job in your queue at that moment, not just the ones you meant.

target=${1:?usage: bash consol_dep.sh <slurm-script> [afterok|afterany]}
dep=${2:-afterok}

ids=$(squeue -h -u "$USER" -o "%i" | paste -sd: -)
if [ -z "$ids" ]; then
    echo "queue is empty - nothing to wait for. Submit the batch first."
    exit 1
fi

cmd="sbatch --dependency=${dep}:${ids} ${target}"
echo $cmd
eval $cmd
