#!/bin/bash
#SBATCH --account=<YOURLAB>
#SBATCH --mem=120G
#SBATCH --cpus-per-task=6
#SBATCH --gres=gpu:1
#SBATCH --time=18:00:00
#SBATCH --mail-user=<YOUREMAIL>
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# Copyright 2020-2022, Ben Cardoen

set -euo pipefail

NOW=$(date +"%m_%d_%Y_HH%I_%M")
echo "Starting setup at $NOW"

## Setup Singularity
echo "Configuring Singularity"
module load singularity
module load cuda
export SINGULARITY_CACHEDIR="$SLURM_TMPDIR/singularity/cache"
export SINGULARITY_TMPDIR="$SLURM_TMPDIR/singularity/tmp"
mkdir -p $SINGULARITY_TMPDIR
mkdir -p $SINGULARITY_CACHEDIR



## Ensure the singularity image is in place
IMAGE_LOCATION="WHERE YOU SAVED THE SIF FILE"
echo "Copying Singularity image"
cp $IMAGE_LOCATION $SLURM_TMPDIR

echo "Running image"
srun singularity exec --nv $SLURM_TMPDIR/image.sif python -c 'import tensorflow as tf; assert(tf.test.is_gpu_available())'
## Note that if this fails, the job fails, so it's a sanity check that everything works as is

NOW=$(date +"%m_%d_%Y_HH%I_%M")

echo "DONE at ${NOW}"
