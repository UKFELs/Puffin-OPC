
# OPC Full Setup & Run Guide on LANTA HPC

## 📌 Introduction
This guide provides detailed instructions for building, installing, and running the Optical Propagation Code (OPC) simulation on the LANTA supercomputing cluster using Intel Classic compilers and Cray’s MPI environment.

---

## ✅ Step 1: Load Required Modules

LANTA uses environment modules to manage compilers and libraries. Load the necessary modules with:

```bash
module purge
module load PrgEnv-intel
module load intel-classic
module load craype-x86-rome
module load cray-fftw/3.3.10.5
module load Perl
```

---

## 📥 Step 2: Clone the OPC Repository

```bash
git clone https://gitlab.utwente.nl/tnw/ap/lpno/public-projects/Physics-OPC.git ~/OPC
cd ~/OPC
```

### Modify `Make.PL` for FFTW path on LANTA

Edit the file using a text editor (e.g., `vi`):

```bash
vi optics/Make.PL
```

Find the platform-specific `if` statement block:

```perl
# set platform specific options for using FFTW3
if ($OS eq "MSWin32") {
  ...
} elsif ($^O eq 'darwin') {
  ...
} else {
  $mk_param{LD_OPTIONS} .= " -L/usr/local/lib";
  $mk_param{LD_LIB} = "-lfftw3";
}
```

Update the final `else` clause to use the correct FFTW path for LANTA:

```perl
$mk_param{LD_OPTIONS} .= " -L/opt/cray/pe/fftw/3.3.10.5/x86_rome/lib";
```

> 🔍 To verify the correct path, run:
> ```bash
> module show cray-fftw/3.3.10.5
> ```
> Look for a line like: `CRAY_LD_LIBRARY_PATH="/opt/cray/pe/fftw/3.3.10.5/x86_rome/lib"`

---

## 🛠️ Step 3: Configure and Build OPC

From the main OPC directory:

```bash
./configure
make
```

This builds the single-core version of OPC.

### Build MPI Version

To enable parallel (MPI) support for frequency-domain simulations:

```bash
cd optics
perl Make.PL mpi=openmpi compiler=ifort compiler_mpi=mpif90
```

> 🛠 Note: Check the loaded compilers:
> ```bash
> which ifort
> which mpif90
> ```

---

### 🐞 Patch Note

Fix a known typo in `~/OPC/lib/Physics/OPC.pm` at line 87:

**Original:**
```perl
unless ref $obj and $old->UNIVERSAL::can($AUTOLOAD);
```

**Fix:**
```perl
unless ref $obj and $obj->UNIVERSAL::can($AUTOLOAD);
```

---

## 🧪 Step 4: Test OPC

Before running examples, export the OPC base directory:

```bash
export OPC_HOME=~/OPC
```

In `~/OPC/examples/spectrum/spectrum.pl`, replace:

```perl
$USE_MPI{optics} = "/opt/intel/openmpi/bin/mpiexec -n 8";
```

With SLURM-compatible syntax:

```perl
$USE_MPI{optics} = "srun -n 8";
```

---

## 🚀 Step 5: Submit a SLURM Job

Create a script file `opc_run.sh`:

```bash
#!/bin/bash
#SBATCH -p compute
#SBATCH -N 1
#SBATCH --ntasks-per-node=8
#SBATCH -t 02:00:00
#SBATCH -A <your_project_code>
#SBATCH -J RunOPC
#SBATCH --output=log_%x.out
#SBATCH --error=log_%x.err

module purge
module load PrgEnv-intel
module load intel-classic
module load craype-x86-rome
module load cray-fftw/3.3.10.5
module load cray-hdf5-parallel
module load Perl

export OPC_HOME=~/OPC

perl diffraction.pl
```

Submit the job with:

```bash
sbatch opc_run.sh
```

> Output and error logs will be named based on job name via `%x`.

---

## 📊 Job Monitoring & Quota

Check job queue:
```bash
myqueue
```

Check project balance:
```bash
sbalance
```

Check output logs:
```bash
cat log_<job_name>.out
```

Cancel a job:
```bash
scancel <jobID>
```

---

## 🔗 References

- [OPC Source Code](https://gitlab.utwente.nl/tnw/ap/lpno/public-projects/Physics-OPC.git)
- [LANTA HPC Documentation](https://thaisc.atlassian.net/wiki/spaces/LANTA)

---

## 👤 Author
**Racha Pongchalee** – Synchrotron Light Research Institute (SLRI)

> Feel free to adapt this guide for similar software builds on LANTA.
