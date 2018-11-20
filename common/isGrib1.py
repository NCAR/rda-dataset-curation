#!/usr/bin/env python
import sys,os


def usage():
    print("Usage: isGrib1 [file]\n");
    print("Prints True (return code 0)");
    print("Prints False (return code 1)");
    print("Return code 99 if neither, or error")
    exit(99)


def is_grib1(in_file):
    with open(in_file, 'rb') as f:
        first8 = f.read()[:8]

    if first8[:4] != b'GRIB':
        exit(99)

    if first8[-1] == 1:
        print('True')
        exit(0)
    elif first8[-1] == 2:
        print('False')
        exit(1)

    exit(99)

if __name__ == '__main__':
    if len(sys.argv) <= 1:
        usage()
    is_grib1(sys.argv[1])

