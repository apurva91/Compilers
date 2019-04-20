#include <bits/stdc++.h>
#include "main.h"
using namespace std;

Type get_type(Type a, Type b){
	if(a==_integer&&b==_integer) return _integer;
	if((a==_integer || a== _real) && (b==_integer || b==_real )) return _real;
	if(a==_boolean && b== _boolean) return _boolean;
	return _error;
}

string get_var(){
	var_num++;
	return "t" + to_string(var_num);
}

string get_curr_var(){
	
	return "t" + to_string(var_num);
}