#!/usr/bin/python
# -*- coding: UTF-8 -*-

########################################
# Dawei Sun
# ucom.py
# Run this in command line by
#   py ucom.py fileNameArg
########################################

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("fileNameArg", help =
        "set the input file name as \"note_foo.txt\" replacing \"foo\" with your input")
args = parser.parse_args()


fileNameCore = args.fileNameArg

fileNameIn = "note_" + fileNameCore + ".txt"
fileNameOut = "ucom_" + fileNameCore + ".txt"

hexData = []

with open(fileNameIn, mode = "r", encoding = "UTF-8") as fileIn:
    for line in fileIn:
        hexData.append(line[0:2])

with open(fileNameOut, mode = "w", encoding = "UTF-8") as fileOut:
    for nLine in range(255):
        fileOut.write(hexData[nLine] + "\n")

print("Uncommented file generated.")
