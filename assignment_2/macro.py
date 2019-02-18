import sys, re

f = open(sys.argv[1]).read()

lines = f.splitlines()

macroline = 0

vardec = 0

pattern  = re.compile(r'\b(?:(?:auto\s*|const\s*|unsigned\s*|extern\s*|signed\s*|register\s*|volatile\s*|static\s*|void\s*|short\s*|long\s*|char\s*|int\s*|float\s*|double\s*|_Bool\s*|complex\s*)+)(?:\s+\*?\*?\s*)([a-zA-Z_][a-zA-Z0-9_]*)\s*[\[;,=)]')

func_pattern = re.compile(r'^\s*(?:(?:inline|static)\s+){0,2}(?!else|typedef|return)\w+\s+\*?\s*(\w+)\s*\([^0]+\)\s*;?')
fundec = 0

func2= 'void same(int b);'

func_definition_pattern = re.compile(r'^([\w\*]+( )*?){2,}\(([^!@#$+%^;]+?)\)(?!\s*;)')


if(re.match(func_definition_pattern,func2)):
    print("Function Definition")



for x in lines:
    #print(x)
    if re.match(r'^#define',x) or re.match(r'^# define',x) :
        #print(x)
        macroline += 1
    if re.match(pattern,x):
        #print(x)
        vardec += 1
    if re.match(func_definition_pattern,x):
        print(x)
        fundec += 1




print(macroline)
print(vardec)
print(fundec)


# brac = 0
# nl = 0
# _start = -1
# _end = -1
# for idx,x in enumerate(f):
#     if x == '(':
#         if _start == -1:
#             _start = idx
#         brac += 1
#     if brac > 0 and x == '\n':
#         nl += 1
#     if x == ')':
#         brac -= 1
#     if brac==0:
#         if _start != -1:
#             print(f[_start:idx])
#             _start

