#!/bin/bash

# Auto-terminate only (primer Appendix A). Runs as a Slurm job via consol_jobs.sh.
# Same as your fork's ec2snapshot.sh, but the four values that were baked into it are at the top.
# Edit them for THIS cluster before you submit consol_jobs.sh.

EC2_IP=47.129.169.227     # controller public IP. Verified 2026-09-27; only changes if the instance is stopped/started
CLUSTER=MyCluster01       # the cluster you created for the quiz
DESC=quiz1                # unique snapshot description. NEVER "data": update_snapshot.sh deletes older snapshots with the same description
KEEP=2                    # snapshots to keep for that description
KEY=/data/MyKeyPair.pem   # must exist on the head node's /data (primer Appendix E-B) with chmod 400

ssh -o StrictHostKeyChecking=no -i $KEY ec2-user@$EC2_IP "source ~/.bash_profile; pcluster update-compute-fleet --status STOP_REQUESTED -n $CLUSTER; ~/update_snapshot.sh $DESC $KEEP $CLUSTER"
