# -*- coding: utf-8 -*-
"""
Created on Wed May  5 16:18:55 2021

@author: seb18121
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
import matplotlib.ticker
import numpy as np
import tables
import sys
             
basename = sys.argv[1] # retreive the base name
filename = basename + ".h5"

h5 = tables.open_file(filename, 'r')
fieldin = h5.root.aperp.read()

nx = h5.root.runInfo._v_attrs.nX
ny = h5.root.runInfo._v_attrs.nY
nz = h5.root.runInfo._v_attrs.nZ2
Lc = h5.root.runInfo._v_attrs.Lc
Lg = h5.root.runInfo._v_attrs.Lg
# gamma_0 = h5.root.runInfo._v_attrs.gamma_r
# kappa = h5.root.runInfo._v_attrs.kappa
c = 299792458 # [m/s] speed of light in vacuum
eps0 = 8.8541878128e-12 # [F/m] vacuum permittivity
qe = 1.60217662e-19 # [C] electron charge
me = 9.10938356e-31 # kg
pi = np.pi

dxbar = h5.root.runInfo._v_attrs.sLengthOfElmX
dybar = h5.root.runInfo._v_attrs.sLengthOfElmY
dz2 = h5.root.runInfo._v_attrs.sLengthOfElmZ2
lenz2 = (nz-1)*dz2
xaxis = np.arange(0,nx)*dxbar
xaxisplot = np.linspace((1-nx)/2*dxbar*np.sqrt(Lc*Lg)*1000,(nx-1)/2*dxbar*np.sqrt(Lc*Lg)*1000,nx)
yaxis = np.arange(0,ny)*dybar
yaxisplot = np.linspace((1-ny)/2*dybar*np.sqrt(Lc*Lg)*1000,(ny-1)/2*dybar*np.sqrt(Lc*Lg)*1000,ny)
z2axis = np.arange(0,nz)*dz2
taxis = z2axis*Lc/c
xn = np.round(nx/2)
yn = np.round(ny/2)
zn = np.round(nz/2)

aperp_x = np.array(fieldin[0])
aperp_y = np.array(fieldin[1])
mean_int = np.transpose(np.trapz(aperp_x**2+aperp_y**2, x=z2axis, axis=0)/(nz*dz2))


# Create a figure and axis
fig = plt.figure(dpi=300, facecolor=None)
ax = fig.add_subplot(111)
contour = ax.contourf(xaxisplot, yaxisplot, np.flipud(mean_int), 512, cmap='jet')
cbar = fig.colorbar(contour)
cbar.formatter.set_powerlimits((0, 0))
cbar.formatter.set_useMathText(True)
cbar.update_ticks()

ax.set_xlabel(r'$x (mm)$')
ax.set_ylabel(r'$y (mm)$')
ax.set_aspect('equal', adjustable='box')

# Save the figure
opname = basename + "-trans_profile.png"
plt.savefig(opname, transparent=True)
plt.show()