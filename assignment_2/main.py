import sys

if len(sys.argv) != 3:
	print("Usage: python main.py <input_filename> <output_filename>", file=sys.stderr)
	exit()

file = open(sys.argv[1]).read()
lines = file.splitlines()
num_of_lines = len(lines)
num_of_blank_lines = 0

for x in lines:
	if x == "" :
		num_of_blank_lines += 1
	
if file.endswith("\n"): 
	num_of_blank_lines += 1

# new_file = ""

out_file = open(sys.argv[2],'w')

# out_file.write(new_file)
# out_file.write("\n\n\n\n")
out_file.write("1) Source code statements : " + str(num_of_lines) + "\n")
out_file.write("2) Comments               : " + str(num_of_lines) + "\n")
out_file.write("3) Blank Lines            : " + str(num_of_blank_lines) + "\n")
out_file.write("4) Macro Definitions      : " + str(num_of_lines) + "\n")
out_file.write("5) Variable Declarations  : " + str(num_of_lines) + "\n")
out_file.write("6) Function Declarations  : " + str(num_of_lines) + "\n")
out_file.write("7) Function Definitions   : " + str(num_of_lines) + "\n")
out_file.close()