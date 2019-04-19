#include <bits/stdc++.h>
using namespace std;

extern int yylineno;
extern int level;

enum ElemType{
	e_int,
	e_real,
	e_error
};

enum Type{
	t_simple,
	t_array
};

struct Node{
	string type; 	//token class
	string value;	//token value
	vector <Node *> children;
	int line_number;
	Node(string type, string value) : type(type), value(value), line_number(yylineno) {};
};

struct Variable{
	string id;
	Type type;
	ElemType eletype;
	vector <int> dimlist;
	int level;
	Variable(string id, Type type, ElemType eletype, int level): id(id), type(type), eletype(eletype), level(level){};
};

struct Function{
	int num_param;
	string id;
	vector <Variable * > parameters;
	vector < map <string, Variable * > > variables;  //scope and id give ElemType 
	ElemType return_type;

	Function(string id, ElemType return_type): id(id), return_type(return_type){
		num_param = 0;
	};
	Variable * search_param(string name){
		for(int i=0; i<parameters.size(); i++){
			if(parameters[i]->id==name) return parameters[i];
		}
		return NULL;
	}
	Variable * enter_param(string name, Type type, ElemType eletype){
		parameters.push_back(new Variable(name,type,eletype,1));
		return parameters.back();
		num_param++;
	}
	Variable * search_var(string id, int level){
		for(int i=0; i<=level; i++){
			if(variables[i].count(id)!=0) return variables[i][id];
		}
		return NULL;
	}
	Variable * enter_var(string id, Type type, ElemType eletype, int level){
		variables[level][id] = new Variable(id,type,eletype,level);
		return variables[level][id];
	}
	void increase_level(){
		map <string, Variable *> tm;
		tm.clear();
		variables.push_back(tm);
	}
	void decrease_level(){
		variables.pop_back();
	}
	bool check_param_type(int pno, Type type){
		return parameters[pno-1]->type==type;
	}
};

struct SymbolTable{
	map <string, Variable * > variables; // level 0 variables
	map <string, Function *> functions;
	Function * search_function(string id){
		if(functions.count(id)!=0) return functions[id];
		return NULL;	
	}
	Function * enter_func(string id, ElemType return_type){
		functions[id] = new Function(id,return_type);
		return functions[id];
	}
	Variable * search_var(string id){
			if(variables.count(id)!=0) return variables[id];
		return NULL;
	}
	Variable * enter_var(string id, Type type, ElemType eletype){
		variables[id] = new Variable(id,type,eletype,level);
		return variables[id];
	}

};


