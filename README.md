# A quick example on how to get up and running with singularity on a cluster with CUDA

**Note: if you copy paste these examples, at a minimum verify you know what they do. These are listed only as examples, without any warranty, you should know if and how they apply to your use case and cluster**

## Required
- HPC cluster account
  - You know your account/group info
  - You've configured ssh key access
- Basic Linux CLI interaction

You do not need Singularity on your own machine, though for more advanced use cases you probably will want to.

If you do not have Linux to work with Singularity on your home machine, try a VM using VirtualBox or similar software, or WSL2.

## Walkthrough
### Login to the cluster
```bash
ssh you@cluster.country
```
### Get the image
We'll use a tensorflow image from NVidia.
We'll assume for now there's a temporary directory on a fast local disk at $SLURM_TMPDIR. This may not be the case, so please adjust to your setting.
If you don't set these variables, singularity will write to $HOME, which you never want.

**Do NOT copy paste if $SLURM_TMPDIR is not set**. On Cedar, first get an interactive node.

```bash
module load singularity
export $STMP=$SLURM_TMPDIR
# or if not in interactive node
# export $STMP=/scratch/$USER
mkdir -p $STMP/singularity/{cache,tmp}
export SINGULARITY_TMPDIR="STMP/singularity/tmp"
export SINGULARITY_CACHEDIR="$STMP/singularity/cache"
cd $SINGULARITY_TMPDIR
singularity pull tensorflow-19.11-tf1-py3.sif docker://nvcr.io/nvidia/tensorflow:19.11-tf1-py3
```
The pull image can take ~20 mins or depending on network, disk, ... .

#### Pull is too slow ...
In that case, run the pull command locally, and copy the resulting image to the cluster.

### Store the image where compute nodes can access it
For example:
```
cp tensorflow-19.11-tf1-py3.sif /scratch/$USER
# or
cp tensorflow-19.11-tf1-py3.sif /project/$USER
```
**Filesystems on clusters specialize usually for 2 orthogonal use cases: fast and temporary, slow and permanent. Your cluster documentation will tell you which is which.**

### Get an interactive node
```bash
salloc --time=3:0:0 --ntasks=1 --cpus-per-task=4 --mem-per-cpu=4G --account=<YOURGROUP> --gres=gpu:1
```
After getting the node
```bash
## Make sure environment is clean
module purge

module load singularity
module load cuda

mkdir -p $SLURM_TMPDIR/singularity/{cache,tmp}
export SINGULARITY_TMPDIR="$SLURM_TMPDIR/singularity/tmp"
export SINGULARITY_CACHEDIR="$SLURM_TMPDIR/singularity/cache"
cd $SINGULARITY_TMPDIR

cp /scratch/$USER/tensorflow-19.11-tf1-py3.sif .  # Change if needed

singularity shell --nv tensorflow-19.11-tf1-py3.sif
```
Now you can execute code inside the container
```
Singularity> python
>>> import tensorflow as tf
>>> tf.test.is_gpu_available()
```
This should print a lot of info on CUDA version, GPU type etc, and evaluate to True.

## SBATCH mode
Check singularitysbatch.sh as an example. Make sure you modify the account, email, and image location entries.
```
sbatch singularitysbatch.sh
```

### Notes
#### Own images
- Creating your own images requires singularity, or you can build on Sylabs.io's cloud builder.
-
#### Accessing data
```
singularity shell --nv -B <somedir>:<mountpoint> tensorflow-19.11-tf1-py3.sif
```
Now <somedir> will appear inside the container as <mountpoint>.


## Extra resources
[Compute Canada Wiki on Singularity](https://docs.computecanada.ca/wiki/Singularity)

[Singularity documentation](https://sylabs.io/docs)

[Sylabs cloud builder](https://cloud.sylabs.io/library)

### But I want PyTorch
```
singularity pull image.sif docker://nvcr.io/nvidia/pytorch:21.12-py3
```
More tags at [NVidia NVCR][https://catalog.ngc.nvidia.com/containers]
