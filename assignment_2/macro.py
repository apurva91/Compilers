import sys, re

f = open(sys.argv[1]).read()

lines = f.splitlines()

macroline = 0

vardec = 0

pattern  = re.compile(r'\b(?:(?:auto\s*|const\s*|unsigned\s*|extern\s*|signed\s*|register\s*|volatile\s*|static\s*|void\s*|short\s*|long\s*|char\s*|int\s*|float\s*|double\s*|_Bool\s*|complex\s*)+)(?:\s+\*?\*?\s*)([a-zA-Z_][a-zA-Z0-9_]*)\s*[\[;,=)]')

func_pattern = re.compile(r'^\s*(?:(?:inline|static)\s+){0,2}(?!else|typedef|return)\w+\s+\*?\s*(\w+)\s*\([^0]+\)\s*;?')
fundec = 0

func2= 'int main(){return 0;}'

if(re.match(func_pattern,func2)):
    print("LFG!!!!!")



for x in lines:
    #print(x)
    if re.match(r'^#define',x) or re.match(r'^# define',x) :
        #print(x)
        macroline += 1
    if re.match(pattern,x):
        #print(x)
        vardec += 1
    if re.match(func_pattern,x):
        print(x)
        fundec += 1

f = "\n".join(lines)

if re.match(func_pattern,f):
    print('Found a function declaration')

print(macroline)
print(vardec)
print(fundec)
