#!/usr/bin/env python
import sys,os


def usage():
    print("Usage: isGrib1 [file]\n");
    print("Prints True (return code 0)");
    print("Prints False (return code 1)");
    print("Return code 99 if neither, or error")
    exit(99)


def is_grib1(in_file):
    pass

if __name__ == '__main__':
    if len(sys.argv) <= 1:
        usage()

