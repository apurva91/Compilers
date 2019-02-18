import sys, re

if len(sys.argv) != 3:
	print("Usage: python main.py <input_filename> <output_filename>", file=sys.stderr)
	exit()

def wtf(name, text):
    fi = open(name,'w');
    fi.write(text)
    fi.close()

def get_line_num(f, index):
    c = len(f.splitlines())
    for x in range(0,c):
        if len("\n".join(f.splitlines()[0:x+1])) >= index:
            return x
    return 0

out_file = open(sys.argv[2],'w')
keyword = ['else','goto','return','typedef']
f = open(sys.argv[1]).read()

lines = f.splitlines()
num_of_lines = len(lines)
num_of_blank_lines = 0
num_of_comments = 0
num_of_macro_definitions = 0
num_of_var_declaration = 0
num_of_func_declaration = 0
num_of_func_definition = 0
# Counting the number of blank lines

for x in lines:
    if x.strip() == "" :
        num_of_blank_lines += 1

if f.endswith("\n"):
    num_of_blank_lines += 1
    num_of_lines += 1


# Replcaing existing \n from the code and replcing them with ' ' because newline is also interpretted as \n in python

lines = [ x.replace("\\n","") for x in lines ]
f = "\n".join(lines)
f = f.replace("\\\n"," ")

def comment_remover(text):
    def replacer(match):
        s = match.group(0)
        if s.startswith('/*'):
            return "\n"
        elif s.startswith('/'):
            return " "
        else:
            return s
    pattern = re.compile(
        r'\/\/.*?$|\/\*.*?\*\/|\'(?:\\.|[^\\\'])*\'|\"(?:\\.|[^\\\"])*\"',
        re.DOTALL | re.MULTILINE
    )
    z = re.findall(pattern,text)
    count = sum([ len(x.split("\n")) for x in z if x.startswith('/')])
    pattern2 = re.compile(
        r'\*\/[^\n]*\/\/.*?$|\'(?:\\.|[^\\\'])*\'|\"(?:\\.|[^\\\"])*\"',
         re.MULTILINE
    )
    z = re.findall(pattern2,text)
    count2 = sum([ len(x.split("\n")) for x in z if x.startswith('*')])
    return re.sub(pattern, replacer, text), count - count2

f , num_of_comments = comment_remover(f)
# Removed the comments from the existing file and stripped the whitespaces in the new file.


wtf("test_comment.c",f)

# Removing the strings as they could contain text which will interrupt
f = re.sub(re.compile(r'\".*?\"',re.DOTALL|re.MULTILINE),"\" \"",f)

f = re.sub(re.compile(r'\'.\'',re.DOTALL|re.MULTILINE),"\' \'",f)

# Removing the removed code from here.
lines = [x.strip() for x in f.splitlines() if len(x.strip())>0]
f = "\n".join(lines)

wtf("test_comment_string.c",f)

#regex for VARIABLE DECLARATION
# pattern  = re.compile(r'\b(?:(?:auto\s*|const\s*|unsigned\s*|extern\s*|signed\s*|register\s*|volatile\s*|static\s*|void\s*|short\s*|long\s*|char\s*|int\s*|float\s*|double\s*|_Bool\s*|complex\s*)+)(?:\s+\*?\*?\s*)([a-zA-Z_][a-zA-Z0-9_]*)\s*[\[;,=)]')
pattern  = re.compile(r'((([a-zA-Z_][a-zA-Z_0-9]*( )*?){1,}))([\*\s]*)([a-zA-Z_][a-zA-Z0-9_]*)\s*[\[;,=)]',re.MULTILINE|re.DOTALL)

for x in lines:
    if re.match(r'^#[\ \t]*define',x):
        num_of_macro_definitions += 1

for x in lines:
    if (re.match(pattern,x)):
        bo = 0
        for y in keyword:
            if y in re.match(pattern,x).group().split(" "):
                bo = 1
        if bo == 0:
            num_of_var_declaration += 1
            print(re.match(pattern,x).group())


#regex for FUNCTION DECLARATION
# func_pattern_dec = re.compile(r'^\s*(?:(?:inline|static)\s+){0,2}(?!else|typedef|return)\w+\s+\*?\s*(\w+)\s*\([^0]+\)\s*;?')
# func_pattern_dec = re.compile(r'^([\w\*]+( )*?){2,}\(([^!@#$+%^;]*?)\)(\ )*;')
# if(re.match(func_pattern_dec,x)):
#     print(x)
#     num_of_func_declaration += 1

#regex for FUNCTION DEFINITION
# func_pattern_def = re.compile(r'([\w\*]+( )*?){2,}\([^!@#$+%^;]*?\)(?!\s*;)', re.MULTILINE|re.DOTALL)
func_pattern_def = re.compile(r'(([a-zA-Z_][a-zA-Z_0-9]*[\ \*]*?){2,}\(([^!@#$+%^;{}]*?)\)(?!\s*;))[\s]*{', re.MULTILINE|re.DOTALL)

spans = [x.span() for x  in func_pattern_def.finditer(f)]
spans.sort()
spans.reverse()

for x in spans:
    curl = 0
    c_start = x[0]
    start = -1
    while(1):
        if f[c_start] == '{':
            if start == -1:
                start = c_start 
            curl += 1
        elif f[c_start] == '}':
            curl -= 1
        c_start+=1
        if start!= -1 and curl == 0:
            break
    f = f[0:x[1]] + '\n'*(len(f[start:c_start].split("\n"))-1) +  "}" + f[c_start:]

func_pattern_def = re.compile(r'(([a-zA-Z_][a-zA-Z_0-9]*[\ \*]*?){2,}\(([^!@#$+%^;\{\}]*?)\)(?!\s*;))', re.MULTILINE|re.DOTALL)
lol = []
for x in func_pattern_def.finditer(f):
    for y in range(get_line_num(f,x.start()),get_line_num(f,x.end())+1):
        lol.append(y)

num_of_func_definition = len(set(lol))

func_pattern_dec = re.compile(r'(([a-zA-Z_][a-zA-Z_0-9]*[\ \*]*?){2,}\(([^!@#$+%^;\{\}]*?)\)\s*?;)', re.MULTILINE| re.DOTALL)
lol = []
for x in func_pattern_dec.finditer(f):
    for y in range(get_line_num(f,x.start()),get_line_num(f,x.end())+1):
        lol.append(y)

num_of_func_declaration = len(set(lol))
# print(set(lol))

# Generating the output

out_file.write(f)
out_file.write("\n\n/*\n")

out_file.write("1) Source code statements : " + str(num_of_lines) + "\n")
out_file.write("2) Comments               : " + str(num_of_comments) + "\n")
out_file.write("3) Blank Lines            : " + str(num_of_blank_lines) + "\n")
out_file.write("4) Macro Definitions      : " + str(num_of_macro_definitions) + "\n")
out_file.write("5) Variable Declarations  : " + str(num_of_var_declaration) + "\n")
out_file.write("6) Function Declarations  : " + str(num_of_func_declaration) + "\n")
out_file.write("7) Function Definitions   : " + str(num_of_func_definition) + "\n")
out_file.write("*/")
out_file.close()


'''
Notes on comments [Source Stackoverflow]:

Strings needs to be included, because comment-markers inside them does not start a comment.

Edit: re.sub didn't take any flags, so had to compile the pattern first.

Edit2: Added character literals, since they could contain quotes that would otherwise be recognized as string delimiters.

Edit3: Fixed the case where a legal expression int/**/x=5; would become intx=5; which would not compile, by replacing the comment with a space rather then an empty string.
'''
