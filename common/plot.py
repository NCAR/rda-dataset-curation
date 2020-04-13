#!/usr/bin/env python
import xarray
import argparse
import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import sys


def get_arguments():
    """Parses arguments and returns arguments.
    """
    description = "Plot variable, create animation, etc."
    parser = argparse.ArgumentParser(prog=sys.argv[0], description=description)
    parser.add_argument('--var', required=False, help="variable_name")
    parser.add_argument('--skip_errors', required=False, help="Errors do not end program.", action='store_true')
    parser.add_argument('--animate', required=False, help="Whether to animate", action='store_true')
    parser.add_argument('--proj', required=False, default='Mercator', help="Type of projection")
    parser.add_argument('--title', required=False, help="Specify Title.")
    parser.add_argument('--out', required=False, default='foo.png', help="output file")
    parser.add_argument('--time', required=False, default=0, type=int, help="Index of time slice")
    parser.add_argument('files', nargs="+", help="File(s) from which to plot")
    return parser.parse_args()

def get_projection(proj):
    """Returns projection assosiated with proj
    """
    proj = proj.lower()
    proj = proj.strip()
    projections = {
            "mercator" : ccrs.Mercator()
            }
    if proj in projections:
        return projections[proj]
    print("Can't find projection")
    exit(1)

if __name__ == "__main__":
    args = get_arguments()
    ds = xarray.open_dataset(args.files[0])
    proj = get_projection(args.proj)
    ax = plt.axes(projection=proj)

    # Slice data
    data_slice = ds.prmsl.isel(time=args.time)
    data_slice.plot.contourf(ax=ax, transform=ccrs.PlateCarree())
    ax.set_global()
    ax.coastlines()
    plt.savefig(args.out, dpi=200)




