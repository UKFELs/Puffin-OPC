#!/bin/bash

# This bash script is the Puffin/OPC simulation
# It is also suitable to modify to use in HPC
export PUFFDIR=/mnt/d/Puffin_BUILD/Puffin_BIN/bin
export MYSCRIPT=/mnt/d/My_python_script/Modified_script

# filename prefix in puffin
BASENAME=rafel
# last file number from Puffin run
LFN=201

mpirun -np 4 $PUFFDIR/puffin ${BASENAME}.in
python $MYSCRIPT/Puffin-to-OPC_xy.py ${BASENAME}_aperp_${LFN}
# this is how to run OPC using perl script
# run both polarisation field seperately
perl propagate.pl ${BASENAME}_aperp_${LFN}_x.dfl
perl propagate.pl ${BASENAME}_aperp_${LFN}_y.dfl
# OPC-to-Puffin_xy.py will combine x and y polarisation as one puffin field format
python $MYSCRIPT/OPC-to-Puffin_xy.py outhole
python $MYSCRIPT/OPC-to-Puffin_xy.py M1
python $MYSCRIPT/OPC-to-Puffin_xy.py M2
python $MYSCRIPT/OPC-to-Puffin_xy.py entrance

# move files for dignotics
mv ${BASENAME}_aperp_${LFN}.h5 ${BASENAME}_ap_${LFN}_P_0.h5
mv ${BASENAME}_integrated_${LFN}.h5 ${BASENAME}_int_${LFN}_P_0.h5
mv ${BASENAME}_aperp_0.h5  ${BASENAME}_ap_0_P_0.h5
mv ${BASENAME}_integrated_0.h5  ${BASENAME}_int_0_P_0.h5

mv outhole.h5 outhole_0.h5
mv M1.h5 M1_0.h5
mv M2.h5 M2_0.h5
# this should be the file for the next pass and be seeding to Puffin input
cp entrance.h5 entrance_0.h5

# plot the transverse profile
python $MYSCRIPT/plotTransProfile.py outhole_0
python $MYSCRIPT/plotTransProfile.py M1_0
python $MYSCRIPT/plotTransProfile.py M2_0
python $MYSCRIPT/plotTransProfile.py entrance_0
python $MYSCRIPT/plotTransProfile.py ${BASENAME}_ap_${LFN}_P_0
python $MYSCRIPT/plotTransProfile.py ${BASENAME}_ap_0_P_0

# number of pass number
for loop in {1..10}
do
	# noted that this is run puffin using the ".ins" input file
	# ".ins" file should specific the seedfile as *.h5 in puffin format  
	mpirun -np 4 $PUFFDIR/puffin ${BASENAME}.ins
	python $MYSCRIPT/Puffin-to-OPC_xy.py ${BASENAME}_aperp_${LFN}
	# this is how to run OPC using perl script
	perl propagate.pl ${BASENAME}_aperp_${LFN}_x.dfl
	perl propagate.pl ${BASENAME}_aperp_${LFN}_y.dfl
	python $MYSCRIPT/OPC-to-Puffin_xy.py outhole
	python $MYSCRIPT/OPC-to-Puffin_xy.py M1
	python $MYSCRIPT/OPC-to-Puffin_xy.py M2
	python $MYSCRIPT/OPC-to-Puffin_xy.py entrance

 	mv ${BASENAME}_aperp_${LFN}.h5 ${BASENAME}_ap_${LFN}_P_${loop}.h5
    mv ${BASENAME}_integrated_${LFN}.h5 ${BASENAME}_int_${LFN}_P_${loop}.h5
    mv ${BASENAME}_aperp_0.h5  ${BASENAME}_ap_0_P_${loop}.h5
    mv ${BASENAME}_integrated_0.h5  ${BASENAME}_int_0_P_${loop}.h5

	mv outhole.h5 outhole_${loop}.h5
    mv M1.h5 M1_${loop}.h5
    mv M2.h5 M2_${loop}.h5
    cp entrance.h5 entrance_${loop}.h5

	# plot the transverse profile
	python $MYSCRIPT/plotTransProfile.py outhole_${loop}
	python $MYSCRIPT/plotTransProfile.py M1_${loop}
	python $MYSCRIPT/plotTransProfile.py M2_${loop}
	python $MYSCRIPT/plotTransProfile.py entrance_${loop}
	python $MYSCRIPT/plotTransProfile.py ${BASENAME}_ap_${LFN}_P_${loop}
	python $MYSCRIPT/plotTransProfile.py ${BASENAME}_ap_0_P_${loop}
    echo pass ${loop} done
done
