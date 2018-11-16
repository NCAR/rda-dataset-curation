#!/usr/bin/env python
import sys, os
sys.path.append(os.path.dirname(os.path.realpath(__file__)) +"/../")
import common.collateByDimension as cbd
import create_test_nc_file as create_nc


cbd.collate(, ['test1.nc','test2.nc'], varname=None, output_filename="out.nc" ):
