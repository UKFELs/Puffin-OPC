# -*- coding: utf-8 -*-
"""
Latest update on: 27/09/2023

@author: P. Pongchalee
"""

import numpy as np
import sys, tables, gc

# usage: python /code-directory/OPC-to-Puffin_xy.py "fileprefix"

fx = sys.argv[1] + "_x.dfl"
px = sys.argv[1] + "_x.param"
fy = sys.argv[1] + "_y.dfl"
py = sys.argv[1] + "_y.param"
h5name = sys.argv[1] + ".h5"

def read_namelist_from_file(file_obj):
    result = {}
    current_section = None
    for line in file_obj:
        line = line.strip()
        if line.startswith("$"):
            current_section = line[1:]
            result[current_section] = {}
        elif line == "/":
            current_section = None
        elif current_section:
            key, value = line.split("=", 1)
            key = key.strip()
            value = value.strip()
            if value.startswith("'") and value.endswith("'"):
                value = value[1:-1]
            else:
                try:
                    # First, try to convert the value to a float
                    value_float = float(value)
                    # If the float value is an integer, convert it to int
                    if value_float.is_integer():
                        value = int(value_float)
                    else:
                        value = value_float
                except ValueError:
                    pass
            result[current_section][key] = value
    return result

print ("Reading parameter from .param file ..." + px + "\n")
with open(px, "r") as file:
    dictionaries = read_namelist_from_file(file)
    optics_dict = dictionaries['optics']
    runInfo_dict = dictionaries['runInfo']
    
    Mx = optics_dict.get('Mx', None)
    My = optics_dict.get('My', None)
    
    nslices = optics_dict.get('nslices', None)
    npoints_x = optics_dict.get('npoints_x', None) 
    npoints_y = optics_dict.get('npoints_y', None)
    
    # scalling the grid size of puffin field when running with OPC magnification factor in Modified Fresnel Integral
    runInfo_dict['sLengthOfElmX'] = Mx * runInfo_dict.get('sLengthOfElmX', None)
    runInfo_dict['sLengthOfElmY'] = My * runInfo_dict.get('sLengthOfElmY', None)

print ("Reading binary file_x ..." + fx + "\n")
field_x = np.fromfile(fx, dtype='f8') # don't need to open the binary file numpy will haddle this
print ("Reading binary file_y ..." + fy + "\n")
field_y = np.fromfile(fy, dtype='f8') # don't need to open the binary file numpy will haddle this

print ("Converting to Puffin format xy ...\n")
Aperp_x = field_x[0:][::2] # even index represents real number in OPC format
Aperp_y = field_y[0:][::2] # even index represents real number in OPC format
aperp = np.concatenate((Aperp_x,Aperp_y))
aperp = np.reshape(aperp, (2, int(nslices), int(npoints_y), int(npoints_x)))

del(Aperp_x,Aperp_y)
gc.collect()

print ("Saving to h5 file ...\n")
a = tables.Float64Atom()
shape = (2, nslices, npoints_y, npoints_x)
with tables.open_file(h5name, 'w') as hf:
    saperp = hf.create_array('/','aperp', obj = aperp)
    saperp.attrs['iCsteps'] = 0
    # Create a group for runInfo
    runInfo_group = hf.create_group('/', 'runInfo', 'Run Information')
    
    # Add each key-value pair from the runInfo dictionary as an attribute to the runInfo group
    for key, value in runInfo_dict.items():
        runInfo_group._v_attrs[key] = value
        
print ("Saving done ...." + h5name +"\n" )