#!/bin/bash
#########
#
# Given a grib file, this program will attempt create/append each parameter to an individual file.
#
########
#
# Usage : ./subsetGrib [grib_file] [--nolevel] [-o/--outdir out-dir]
#            grib_file    :  file to process. Can be grib 1 or 2
#           --nolevel     :
#
#########

opts=$((getopt -
