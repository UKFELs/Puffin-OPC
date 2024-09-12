example input files and bash script to run Puffin-OPC FEL oscillator simulation

The main bash file that control every scripts sequentially is `cavity.sh`
The first pass of Puffin run requires these input file `pcell.in`, `beam_file.in`, and `pcell.latt`
After the first run the field translation is needed before running OPC
```
python \path\to\python-scripts\Puffin-to-OPC_xy.py pcell_aperp_41
```
(`41` here indicates the last file number)

To set up the optical components in the oscillator please edit OPC `perl` script `pcell_cavity.pl`
The output field from OPC should be `entrance_x.dfl`, `entrance_y.dfl`, `entrance_x.param`, `entrance_y.param` before translating to puffin format:
```
python \path\to\python-scripts\OPC-to-Puffin_xy.py entrance
```
(The name should also be matched to the seed in the input file `pcell.ins` for the upcoming puffin run)

The upcoming pass of Puffin run requires these input file `pcell.ins`, `beam_file.in`, and `pcell.latt`
