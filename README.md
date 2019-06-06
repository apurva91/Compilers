# Compilers

### Salient Features

 - Basic Arithmetic
 - Nested If Else
 - Short Circuiting in Conditional Statements
 - Nested Loops (Both For and While)
 - Recursive Function Calling
 - Multidimensional Arrays

### How to run the compiler?

The below command will generate the intermediate code 

``` 
bison -d -v parser.y && flex lex.l && g++ -ggdb lex.yy.c parser.tab.c main.cpp -ll && ./a.out < test.c
```

The generated intermediate code is then translated to MIPS code which can be run on SPIM.

``` 
bison -d -v comp.y; flex comp.l; g++  lex.yy.c comp.tab.c;  ./a.out < inp.txt
```