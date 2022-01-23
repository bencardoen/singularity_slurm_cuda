# A quick example on how to get up and running with singularity on a cluster with CUDA

## Required
- HPC cluster account

## Walkthrough
### Login to the cluster
```bash
ssh you@cluster.country
```
### Get the image
We'll use a tensorflow image from NVidia.
We'll assume for now there's a temporary directory on a fast local disk at $SLURM_TMPDIR. This may not be the case, so please adjust to your setting.
If you don't set these variables, singularity will write to $HOME, which you never want.
```bash
module load singularity
mkdir -p $SLURM_TMPDIR/singularity/{cache,tmp}
export SINGULARITY_TMPDIR="$SLURM_TMPDIR/singularity/tmp"
export SINGULARITY_CACHEDIR="$SLURM_TMPDIR/singularity/cache"
cd $SINGULARITY_TMPDIR
singularity pull tensorflow-19.11-tf1-py3.sif docker://nvcr.io/nvidia/tensorflow:19.11-tf1-py3
cp tensorflow-19.11-tf1-py3.sif $HOME/scratch
```

### Get an interactive node
```bash
salloc --time=3:0:0 --ntasks=1 --cpus-per-task=4 --mem-per-cpu=4G --account=<YOURGROUP> --gres=gpu:1
```
After getting the node
```bash
module purge
module load singularity
module load cuda
mkdir -p $SLURM_TMPDIR/singularity/{cache,tmp}
export SINGULARITY_TMPDIR="$SLURM_TMPDIR/singularity/tmp"
export SINGULARITY_CACHEDIR="$SLURM_TMPDIR/singularity/cache"
cd $SINGULARITY_TMPDIR
cp tensorflow-19.11-tf1-py3.sif .
singularity shell --nv tensorflow-19.11-tf1-py3.sif
```
Now you can execute code inside the container
```
Singularity> python
>>> import tensorflow as tf
>>> tf.test.is_gpu_available()
```

## SBATCH mode
Check singularitysbatch.sh as an example. Make sure you modify the account, email, and image location entries.
```
sbatch singularitysbatch.sh
```

### Notes
#### Own images
- Creating your own images requires singularity, or you can build on Sylabs.io's cloud builder.
#### Accessing data
```
singularity shell --nv -B <somedir>:<mountpoint> tensorflow-19.11-tf1-py3.sif
```
Now <somedir> will appear inside the container as <mountpoint>.
