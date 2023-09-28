# Conversion scripts between Puffin and OPC field formats

Conversion scripts between Puffin and Optical Propagation Code (OPC) field formats for an unaveraged cavity-based FEL simulation.

[OPC available here](https://gitlab.utwente.nl/tnw/ap/lpno/public-projects/Physics-OPC)


__How to run: Puffin-to-OPC__

For example. If the `Puffin` simulation has been setup with `40` undulator periods then running with `test.in`, and the field data is dumped at every period. 
The last file number from puffin would be `41`. This is the field at the undulator exit.
```
python \path\to\python-scripts\Puffin-to-OPC_xy.py test_aperp_41
```
The script will provide `test_aperp_41_x.dfl`, `test_aperp_41_x.param`, `test_aperp_41_y.dfl`, and  `test_aperp_41_y.param` in the OPC field format.


__How to run: OPC-to-Puffin__

The script requires the OPC field format in both x and y poralisation.
For example. the output files from OPC are `entrance_x.dfl`, `entrance_x.param`, `entrance_y.dfl`, and  `entrance_y.param`.
To execute the python script, it is simple to pass just the file prefix `entrance` without extension.
```
python \path\to\python-scripts\OPC-to-Puffin_xy.py entrance
```
The script will provide `entrance.h5` field file as the Puffin format. You can now used this field as a seed to the Puffin simulation.
