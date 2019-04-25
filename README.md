# Compilers

### How to run the compiler?

``` 
bison -d -v parser.y && flex lex.l && g++ -ggdb lex.yy.c parser.tab.c main.cpp -ll && ./a.out < test.c
```
