#! /usr/bin/python2.2

import os, os.path, sys

total = float(0) # total seconds for sync
prefix = sys.argv[1]
input_name = sys.argv[2]
process_name = sys.argv[3] # addition or deletion

input_file = open(os.path.join(prefix, process_name, "-", input_name), 'r')
output_file = open(os.path.join(prefix, output_name), 'a')

for value in input_file:
	total = total + float(value)

input_file.close()

output_file.write(total)
output_file.write("\n")
output_file.close()
