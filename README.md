# Compilers

### How to run the compiler?

``` 
bison -d -v parser.y && flex lex.l && g++ -ggdb lex.yy.c parser.tab.c main.cpp -ll && ./a.out < test.c
```

### Type of Statements in intermediate Language

```
var = var op var
it0 = cnvrt_to_int(f0) 
f0 = cnvrt_to_float(it0) 
op in (+-*/ == < <= >= > != <>)
var could be float int temp_var or declared_var
if temp_var == int goto L1
goto L1
if temp_var <= int goto L1
t1 = t1[t0]
t1 = t5
t1 = addr(i.i.2.main)
param x
refparam y
call fib, 2
func begin name
func end
f.a.0.main[20]
return var

```