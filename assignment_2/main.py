import sys, re

if len(sys.argv) != 3:
	print("Usage: python main.py <input_filename> <output_filename>", file=sys.stderr)
	exit()

out_file = open(sys.argv[2],'w')

f = open(sys.argv[1]).read()

lines = f.splitlines()
num_of_lines = len(lines)
num_of_blank_lines = 0
num_of_comments = 0

# Counting the number of blank lines

for x in lines:
    if x == "" :
        num_of_blank_lines += 1
    
if f.endswith("\n"): 
    num_of_blank_lines += 1


# Replcaing existing \n from the code and replcing them with ' ' because newline is also interpretted as \n in python

lines = [ x.replace("\\n","") for x in lines ]
f = "\n".join(lines)
f = f.replace("\\\n"," ")

def comment_remover(text):
    def replacer(match):
        s = match.group(0)
        if s.startswith('/'):
            return " "
        else:
            return s
    pattern = re.compile(
        r'//.*?$|/\*.*?\*/|\'(?:\\.|[^\\\'])*\'|"(?:\\.|[^\\"])*"',
        re.DOTALL | re.MULTILINE
    )
    return re.sub(pattern, replacer, text), len([ x for x in re.findall(pattern,text) if x.startswith('/')])

f , num_of_comments = comment_remover(f)

# Removed the comments from the existing file and stripped the whitespaces in the new file.

# Removing the strings as they could contain text which will interrupt
f = re.sub(re.compile(r'\".*\"',re.DOTALL|re.MULTILINE),"\" \"",f)

f = re.sub(re.compile(r'\'.\'',re.DOTALL|re.MULTILINE),"\' \'",f)

# Removing the removed code from here.
lines = [x.strip() for x in f.splitlines() if len(x.strip())>0]
f = "\n".join(lines)


# Generating the output

out_file.write(f)
out_file.write("\n\n\n\n")
out_file.write("1) Source code statements : " + str(num_of_lines) + "\n")
out_file.write("2) Comments               : " + str(num_of_comments) + "\n")
out_file.write("3) Blank Lines            : " + str(num_of_blank_lines) + "\n")
out_file.write("4) Macro Definitions      : " + str(num_of_lines) + "\n")
out_file.write("5) Variable Declarations  : " + str(num_of_lines) + "\n")
out_file.write("6) Function Declarations  : " + str(num_of_lines) + "\n")
out_file.write("7) Function Definitions   : " + str(num_of_lines) + "\n")
out_file.close()


'''

Notes on comments [Source Stackoverflow]:

Strings needs to be included, because comment-markers inside them does not start a comment.

Edit: re.sub didn't take any flags, so had to compile the pattern first.

Edit2: Added character literals, since they could contain quotes that would otherwise be recognized as string delimiters.

Edit3: Fixed the case where a legal expression int/**/x=5; would become intx=5; which would not compile, by replacing the comment with a space rather then an empty string.

'''