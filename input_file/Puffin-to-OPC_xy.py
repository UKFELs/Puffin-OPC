# -*- coding: utf-8 -*-
"""
Created first version on Wed May 15 10:38:37 2019 

@author: Racha Pongchalee
"""
# noted only x polarization of the Aperp field will be converted to OPC format
import numpy as np
import time
import tables, gc
from scipy.signal import hilbert
from scipy.fftpack import next_fast_len
import sys

filename = sys.argv[1] # retreive the base name
# filename = "D://Puffin_results//New_RAFEL//rafel_aperp_150"
h5name = filename + ".h5"
binname_x = filename + "_x.dfl"
paramname_x = filename + "_x.param"
binname_y = filename + "_y.dfl"
paramname_y = filename + "_y.param"

print ("Reading aperp file ..." + h5name + "\n")
h5f = tables.open_file(h5name, mode='r')

# Read the HDF5 file (Puffin_aperp file)
aperps = h5f.root.aperp.read()
Aperp_x = np.array(aperps[0]) # x-polarised field
Aperp_y = np.array(aperps[1]) # y-polarised field
print ("Getting file attributes ... \n")
# Dictionary to store the attributes
runInfo_dict = {}

# Loop through attributes and store them in the dictionary
for attr in h5f.root.runInfo._v_attrs._f_list():
    runInfo_dict[attr] = getattr(h5f.root.runInfo._v_attrs, attr)

wavelength = runInfo_dict.get('lambda_r', None)
nx = runInfo_dict.get('nX', None)
ny = runInfo_dict.get('nY', None)
nz = runInfo_dict.get('nZ2', None)
Lc = runInfo_dict.get('Lc', None)
Lg = runInfo_dict.get('Lg', None)
rho = runInfo_dict.get('rho', None)
meshsizeX = runInfo_dict.get('sLengthOfElmX', None)
meshsizeY = runInfo_dict.get('sLengthOfElmY', None)
meshsizeZ2 = runInfo_dict.get('sLengthOfElmZ2', None)
meshsizeXSI = meshsizeX*np.sqrt(Lc*Lg)
meshsizeYSI = meshsizeY*np.sqrt(Lc*Lg)
meshsizeZSI = meshsizeZ2*Lc
zsep = meshsizeZSI/wavelength

print("Getting the complex envelope from x-field ...")
print("Processing the Hilbert transform ..")
start = time.time()
fast_len = next_fast_len(len(Aperp_x))
Aperp_x_complex = hilbert(Aperp_x, fast_len, 0)[:len(Aperp_x),:,:]
# Aperp_x_complex = np.real(Aperp_x_complex) - 1j*np.imag(Aperp_x_complex)
end = time.time()

# Aperp_x_hilbert = Hilbertfromfft(Aperp_x)
print("Hilbert transform x ... DONE ...   " + str(end - start) + " seconds" +"\n")
del(Aperp_x)

start = time.time()
fast_len = next_fast_len(len(Aperp_y))
Aperp_y_complex = hilbert(Aperp_y, fast_len, 0)[:len(Aperp_y),:,:]
# Aperp_y_complex = np.real(Aperp_y_complex) - 1j*np.imag(Aperp_y_complex)
end = time.time()

# Aperp_x_hilbert = Hilbertfromfft(Aperp_x)
print("Hilbert transform y ... DONE ...   " + str(end - start) + " seconds" +"\n")
del(Aperp_y)
h5f.close()
gc.collect()

def interleave_real_imag(complex_array):
    stacked = np.dstack((complex_array.real, complex_array.imag)) # note the "negative" on imaginary part
    return stacked.flatten()

def interArray(A, B):
    C = np.empty((A.size + B.size,), dtype=np.float64)
    C[0::2] = A
    C[1::2] = B
    return C


print("Re-ordering/correcting the phase of the complex field into the OPC format")
start = time.time()
bin_x = np.reshape(Aperp_x_complex, nx*ny*nz)
bin_x = interArray(np.real(bin_x), -np.imag(bin_x)) # note: the "negative" sign must be assigned to the imaginary part !!!
# bin_x = interleave_real_imag(Aperp_x_complex)
del(Aperp_x_complex)
end = time.time()

print("Re-order the complex field x ... DONE ...   " + str(end - start) + " seconds" +"\n")

start = time.time()
bin_y = np.reshape(Aperp_y_complex, nx*ny*nz)
bin_y = interArray(np.real(bin_y), -np.imag(bin_y)) # note: the "negative" sign must be assigned to the imaginary part !!!
# bin_y = interleave_real_imag(Aperp_y_complex)
del(Aperp_y_complex)
end = time.time()
print("Re-order the complex field y ... DONE ...   " + str(end - start) + " seconds" +"\n")
gc.collect()


print("Saving x-field to binary file ..." + " binary data length = "+ str(len(bin_x)))
start = time.time()
with open(binname_x, "wb") as f:
        bin_x.tofile(f)
del(bin_x)
f.close()
end = time.time()
print("Save file x ... DONE ...   " + str(end - start) + " seconds" +"\n")

gc.collect()

print("Saving y-field to binary file ..." + " binary data length = "+ str(len(bin_y)))
start = time.time()
with open(binname_y, "wb") as f:
        bin_y.tofile(f)
del(bin_y)
f.close()
end = time.time()
print("Save file y ... DONE ...   " + str(end - start) + " seconds" +"\n")

# save binary file
# write the parameter file for physical interpretation

optics_params = {
    'nslices': nz,
    'zsep': zsep,
    'mesh_x': 1 if nx-1 == 0 else meshsizeXSI,
    'mesh_y': 1 if nx-1 == 0 else meshsizeYSI,
    'npoints_x': nx,
    'npoints_y': ny,
    'Mx': 1,
    'My': 1,
    'lambda': wavelength,
    'field_next': 'none'
}

def write_namelist_to_file(file_obj, namelist_name, params_dict):
    file_obj.write(" $" + namelist_name + "\n")
    for key, value in params_dict.items():
        # Check and decode bytes to string
        if isinstance(value, bytes):
            value = value.decode('utf-8')
        
        file_obj.write(" " + key + " = " + str(value) + "\n")
        # print(f" {key} = {value}")
    file_obj.write(" /\n")

print("writing OPC parameter file x ... ")    
with open(paramname_x, 'w') as param_x:
    write_namelist_to_file(param_x, 'optics', optics_params)
    write_namelist_to_file(param_x, 'runInfo', runInfo_dict)
    
print("writing OPC parameter file y ... ")    
with open(paramname_y, 'w') as param_y:
    write_namelist_to_file(param_y, 'optics', optics_params)
    write_namelist_to_file(param_y, 'runInfo', runInfo_dict)


print("DONE\n")