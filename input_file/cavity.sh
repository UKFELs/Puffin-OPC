#!/bin/bash
#BSUB -o stdout.pcell_0.5L.txt
#BSUB -e stderr.pcell_0.5L.txt
#BSUB -R "span[ptile=8]"
#BSUB -q scafellpikeSKL
#BSUB -n 128 
#BSUB -J pcell0.5L
#BSUB -W 48:00

export PUFFDIR=$HCBASE/puffin/bin
export MYSCRIPT=$HCBASE/rafel-script
export MYHOME=`pwd`
export OMP_NUM_THREADS=1
export OPC_HOME=$HCBASE/OPC/Physics-OPC-0.7.10.3
export RAFEL=$HCBASE/OPC/Physics-OPC-0.7.10.3/opc-puffin
# setup simulation parameters
# basename of the input file
BASENAME=pcell
LFN=41
detune_factor=0.5
R1=0.99
R2=0.99

# setup modules
. /etc/profile.d/modules.sh
module load intel_mpi > /dev/null 2>&1
module load intel
module load python3/anaconda

export LD_LIBRARY_PATH=/lustre/scafellpike/local/HCP098/jkj01/pxp52-jkj01/hdf5/lib:$LD_LIBRARY_PATH
date
mpiexec.hydra -np 128 $PUFFDIR/puffin ${BASENAME}.in
date
python3 $HCBASE/rafel-script/Puffin-to-OPC_xy.py ${BASENAME}_aperp_${LFN}
date
perl $RAFEL/pcell_cavity.pl ${BASENAME}_aperp_${LFN}_x.dfl ${detune_factor} ${R1} ${R2}
perl $RAFEL/pcell_cavity.pl ${BASENAME}_aperp_${LFN}_y.dfl ${detune_factor} ${R1} ${R2}
date
python3 $HCBASE/rafel-script/OPC-to-Puffin_xy.py entrance
python3 $HCBASE/rafel-script/OPC-to-Puffin_xy.py M1
python3 $HCBASE/rafel-script/OPC-to-Puffin_xy.py M2
python3 $HCBASE/rafel-script/OPC-to-Puffin_xy.py far
python3 $HCBASE/rafel-script/OPC-to-Puffin_xy.py hole
date
mkdir 0_pass
cp ${BASENAME}_integrated_* 0_pass
zip -r 0_pass.zip 0_pass
mv M1.h5 M1_0.h5
mv M2.h5 M2_0.h5
mv far.h5 far_0.h5
mv hole.h5 hole_0.h5
mv ${BASENAME}_aperp_${LFN}.h5 ${BASENAME}_ap_${LFN}_P_0.h5
mv ${BASENAME}_aperp_0.h5 ${BASENAME}_ap_0_P_0.h5
mv ${BASENAME}_electrons_0.h5 ${BASENAME}_elec_0_P_0.h5
mv ${BASENAME}_integrated_${LFN}.h5 ${BASENAME}_int_${LFN}_P_0.h5
mv ${BASENAME}_integrated_0.h5 ${BASENAME}_int_0_P_0.h5

for loop in {1..200}
do
	date
        mpiexec.hydra -np 128 $PUFFDIR/puffin ${BASENAME}.ins
	date
	python3 $HCBASE/rafel-script/Puffin-to-OPC_xy.py ${BASENAME}_aperp_${LFN}
	date        
	perl $RAFEL/pcell_cavity.pl ${BASENAME}_aperp_${LFN}_x.dfl ${detune_factor} ${R1} ${R2}
	perl $RAFEL/pcell_cavity.pl ${BASENAME}_aperp_${LFN}_y.dfl ${detune_factor} ${R1} ${R2}
	date
	python3 $HCBASE/rafel-script/OPC-to-Puffin_xy.py entrance
	python3 $HCBASE/rafel-script/OPC-to-Puffin_xy.py M1
	python3 $HCBASE/rafel-script/OPC-to-Puffin_xy.py M2
	python3 $HCBASE/rafel-script/OPC-to-Puffin_xy.py far
	python3 $HCBASE/rafel-script/OPC-to-Puffin_xy.py hole
        date
	mkdir ${loop}_pass
	cp ${BASENAME}_integrated_* ${loop}_pass
	zip -r ${loop}_pass.zip ${loop}_pass
	mv hole.h5 hole_${loop}.h5
	mv M1.h5 M1_${loop}.h5
	mv M2.h5 M2_${loop}.h5
	mv far.h5 far_${loop}.h5
	mv ${BASENAME}_aperp_${LFN}.h5 ${BASENAME}_ap_${LFN}_P_${loop}.h5
	mv ${BASENAME}_aperp_0.h5 ${BASENAME}_ap_0_P_${loop}.h5
	mv ${BASENAME}_electrons_0.h5 ${BASENAME}_electrons_0_P_${loop}.h5
	mv ${BASENAME}_integrated_${LFN}.h5 ${BASENAME}_int_${LFN}_P_${loop}.h5
	mv ${BASENAME}_integrated_0.h5 ${BASENAME}_int_0_P_${loop}.h5
	echo pass ${loop} done
done
mkdir ${detune_factor}L
cp ${BASENAME}_int_${LFN}_P_* ${detune_factor}L
zip -r ${detune_factor}L.zip ${detune_factor}L
echo all given passes done
