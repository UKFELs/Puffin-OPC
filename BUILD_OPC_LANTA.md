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
use the text editor to open Make.PL file. In this case, we use vi text editor
```bash
vi optics/Make.PL
```
loking for the set platform specific `if` statement
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
at the last `else` statement then change
```perl
$mk_param{LD_OPTIONS} .= " -L/usr/local/lib";
```
to
```perl
$mk_param{LD_OPTIONS} .= " -L/opt/cray/pe/fftw/3.3.10.5/x86_rome/lib";
```
Note: to see where the `fftw` on LANTA is, use `module show cray-fftw/3.3.10.5`
looking for something like ... `"CRAY_LD_LIBRARY_PATH","/opt/cray/pe/fftw/3.3.10.5/x86_rome/lib"` this is the path to be specified in Make.PL file before build the OPC.
 
## 🛠️ Step 3: Configure, Build, and Install OPC
at the main directory of `OPC` do
```bash
./configure
```
```bash
make
```
This should be finised for the single-core OPC.
For MPI use i.e. Frequency domain, parraller programing , do the following:
Note: to see the MPI module those have been loaded correctly run.
```bash
which ifort
which mpif90
```
```bash
cd optics
```
```bash
perl Make.PL mpi=openmpi compiler=ifort compiler_mpi=mpif90
```

PS: Found some typo on the code: `~/OPC/lib/Physics/OPC.pm` at `line 87`:
```bash
unless ref $obj and $old->UNIVERSAL::can($AUTOLOAD);
```
It should be changed to:
```bash
unless ref $obj and $obj->UNIVERSAL::can($AUTOLOAD);
```
---

## 🧪 Step 4: Test OPC
Before excuting the OPC from the examples, make sure to set the OPC environment name as:
```bash
export OPC_HOME=~/OPC
```
Note: `~/` is the home directory for the user.
In `~/OPC/examples/spectrum/spectrum.pl`, the line:
```perl
$USE_MPI{optics} ="/opt/intel/openmpi/bin/mpiexec -n 8";
```
Can be changed to match with the mpirun in LANTA as:
```perl
$USE_MPI{optics} ="srun -n 8";
```
---

## 🚀 Step 5: SLURM Job Submission

Save this to a file: `opc_run.sh`

```bash
#!/bin/bash
#SBATCH -p compute
#SBATCH -N 1
#SBATCH --ntasks-per-node=8
#SBATCH -t 02:00:00
#SBATCH -A <your_project_code>
#SBATCH -J RunOPC # job name
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
export BASENAME=test1

# the mpi run is being called in the perl script
perl diffraction.pl
```

Submit it with:

```bash
sbatch opc_run.sh
```

- Output and error logs named using job name via `%x`

---

📊 Checking Job Status and Quota Limits
```bash
myqueue
```
```bash
sbalance
```
Checking on log file
```bash
cat log_<job_name>.out
```
Cancel Job
```bash
scancel [jobID]
```

## 🔗 References
- [OPC source](https://gitlab.utwente.nl/tnw/ap/lpno/public-projects/Physics-OPC.git)
- [LANTA HPC Docs](https://thaisc.atlassian.net/wiki/spaces/LANTA)

---

## 👤 Author
Racha Pongchalee – [SLRI]

---

Feel free to adapt this guide for other codes or build environments on LANTA.
