import matplotlib.pyplot as plt
import xarray as xr
import numpy as np

ds = xr.Dataset('file')
ds.precipitation.sum(['time']).plot(vmax=50)
plt.title('Accumulated precipitation between\n'
                  '2000-03-01T12 and 2000-03-06T09 (mm)')
plt.show()
