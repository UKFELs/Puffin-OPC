# OPC Full Setup & Run Guide on LANTA HPC

## 📌 Introduction
This guide walks you through the complete process of building, installing, and running the Optical Propagation Code (OPC) simulation code on the LANTA supercomputing cluster using Intel Classic compilers and Cray's MPI environment.

---

## ✅ Step 1: Load Required Modules for OPC

LANTA uses environment modules to manage compilers and libraries. Run the following:

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
```
We are going to edit the Make.PL file to specy the path to LANRA's fftw library.
---
```bash
cd OPC
```
```perl
# set platform specific options for using FFTW3
if ($OS eq "MSWin32") {
  $mk_param{OBJ} = ".o" if $mk_param{COMPILER} =~ /gfortran/;
  $mk_param{LD_OPTIONS} .= "";
  $mk_param{LD_LIB} = "libfftw3-3.lib ";
} elsif ($^O eq 'darwin') {
  $mk_param{LD_OPTIONS} .= " -L/opt/lib -L/opt/fftw/lib -L/opt/openmpi/lib" if $mk_param{COMPILER} =~ /gfortran/;
  $mk_param{LD_OPTIONS} .= " -L/opt/lib -L/opt/fftw/lib -L/opt/openmpi/lib" if $mk_param{COMPILER} =~ /ifort/;
  $mk_param{LD_LIB} = "-lfftw3";
} else {
  $mk_param{LD_OPTIONS} .= " -L/usr/local/lib";
  $mk_param{LD_LIB} = "-lfftw3";
}
```

## 🛠️ Step 3: Configure, Build, and Install Puffin

```bash
mkdir -p ~/puffin-build
cd ~/puffin-build
```
```bash
cmake -DENABLE_PARALLEL=TRUE -DCMAKE_INSTALL_PREFIX=~/puffin-install ~/puffin-src
```
```bash
make -j
make install
```

### 📚 Explanation:
- `ENABLE_PARALLEL=TRUE` enables MPI parallelism
- `CMAKE_INSTALL_PREFIX` sets install location
- `make -j` compiles using multiple threads
- `make install` puts `puffin` binary in `~/puffin-install/bin`

---

## 🧪 Step 4: Test Puffin

```bash
export PATH=~/puffin-install/bin:$PATH
which puffin
```

---

## 🚀 Step 5: SLURM Job Submission

Save this to a file: `job_submit.sh`

```bash
#!/bin/bash
#SBATCH -p compute
#SBATCH -N 2
#SBATCH --ntasks-per-node=16
#SBATCH -t 02:00:00
#SBATCH -A <your_project_code>
#SBATCH -J RunPuffin
#SBATCH --output=log_%x.out
#SBATCH --error=log_%x.err

module purge
module load PrgEnv-intel
module load intel-classic
module load craype-x86-rome
module load cray-fftw/3.3.10.5
module load cray-hdf5-parallel

export OMP_NUM_THREADS=1
export PATH=~/puffin-install/bin:$PATH
export BASENAME=test1

srun -n $SLURM_NTASKS puffin ${BASENAME}.in
```

Submit it with:

```bash
sbatch job_submit.sh
```

### 📚 Explanation:
- `SLURM_NTASKS` auto-calculates MPI rank count
- `OMP_NUM_THREADS=1` since Puffin is MPI-only
- Output and error logs named using job name via `%x`

---

📊 Checking Job Status and Quota Limits
```bash
myqueue
```
```bash
sbalance
```

Cancel Job
```bash
scancel [jobID]
```

## 🔗 References
- [Puffin GitHub](https://github.com/UKFELs/Puffin)
- [Puffin Documentation](https://ukfels.github.io/puffinDocs/)
- [LANTA HPC Docs](https://thaisc.atlassian.net/wiki/spaces/LANTA)

---

## 👤 Author
Racha Pongchalee – [SLRI]

---

Feel free to adapt this guide for other codes or build environments on LANTA.
