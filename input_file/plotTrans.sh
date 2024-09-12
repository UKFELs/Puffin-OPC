#!/bin/bash
#BSUB -o stdout.plotTrans.txt
#BSUB -e stderr.plotTrans.txt
#BSUB -R "span[ptile=4]"
#BSUB -q scafellpikeSKL
#BSUB -n 8 
#BSUB -J plotTrans
#BSUB -W 2:00

export PUFFDIR=$HCBASE/puffin/bin
export MYSCRIPT=$HCBASE/rafel-script
export MYHOME=`pwd`
export OMP_NUM_THREADS=1
export OPC_HOME=$HCBASE/OPC/Physics-OPC-0.7.10.3
export RAFEL=$HCBASE/OPC/Physics-OPC-0.7.10.3/opc-puffin
# setup simulation parameters
. /etc/profile.d/modules.sh
# module load intel_mpi > /dev/null 2>&1
# module load intel
module load python3/anaconda

export LD_LIBRARY_PATH=/lustre/scafellpike/local/HCP098/jkj01/pxp52-jkj01/hdf5/lib:$LD_LIBRARY_PATH
# for i in $(ls 6microns_ap_41_P_*.h5); do python $PUFFDIR/post/reduceField.py $i; done
for i in {90..102}; do
    fileM1="M1_$i"
    python3 $HCBASE/plot-script/plotTransProfile.py $fileM1
    fileM2="M2_$i"
    python3 $HCBASE/plot-script/plotTransProfile.py $fileM2
    fileFar="far_$i"
    python3 $HCBASE/plot-script/plotTransProfile.py $fileFar
    fileHole="hole_$i"
    python3 $HCBASE/plot-script/plotTransProfile.py $fileHole
    fileExit="pcell_ap_41_P_$i"
    python3 $HCBASE/plot-script/plotTransProfile.py $fileExit
    fileEnt="pcell_ap_0_P_$i"
    python3 $HCBASE/plot-script/plotTransProfile.py $fileEnt
done
