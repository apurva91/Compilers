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

bool is_number(string s){
	return (!s.empty() && s.find_first_not_of("0123456789") == std::string::npos);
}

extern SymbolTable symtab;

Variable * Function::search_var(string id, int level){
	for(int i=level; i>=2; i--){
		if(variables[i].count(id)!=0) return variables[i][id];
	}
	Variable * ptr = search_param(id);
	if(ptr) return ptr;
	if(symtab.variables.count(id)!=0) return symtab.variables[id];
	
	return NULL;
}