#include <bits/stdc++.h>
using namespace std;

extern int yylineno;
extern int level;
extern int var_num;

enum Type{
	_integer,
	_real,
	_error,
	_none,
	_simple,
	_array,
	_function,
	_boolean
};

const vector <string> _type = {"integer ", "real    ", "error   ", "none    ", "simple  ", "array   ", "function","boolean "};

template <class A> ostream& operator << (ostream& out, const vector<A> &v) {
out << "[";
for(int i=0;i<v.size(); i++) {
	if(i) out << ", ";
	out << v[i];
}
return out << "]";
}
Type get_type(Type a, Type b);
string get_var();
string get_curr_var();
struct Node{
	string type; 	//token class
	string value;	//token value
	vector <Node *> children;
	int line_number;
	string var;
	Type data_type;
	Node(string type, string value) : type(type), value(value), line_number(yylineno) {
		data_type = _none;
		var = "";
	};
};

struct Variable{
	string id;
	Type type;
	Type eletype;
	vector <string> dimlist;
	int level;
	Variable(string id, Type type, Type eletype, int level): id(id), type(type), eletype(eletype), level(level){};
	void print(){
		cout<<"| "<< id <<" | "<< _type[type] <<" | "<<_type[eletype]<<" | " << level <<" | "<< dimlist<<endl;
	}
	// ostream &operator <<(ostream &os){
	// 	os<<"| "<< id <<" | "<< type <<" | "<<eletype<<" | " << level <<" | "<< dimlist<<" |";
	// }
};

struct Function{
	int num_param;
	string id;
	vector <Variable * > parameters;
	vector < map <string, Variable * > > variables;  //scope and id give Type 
	Type return_type;

	Function(string id, Type return_type): id(id), return_type(return_type){
		num_param = 0;
	};
	Variable * search_param(string name){
		for(int i=0; i<parameters.size(); i++){
			if(parameters[i]->id==name) return parameters[i];
		}
		return NULL;
	}
	Variable * enter_param(string name, Type type, Type eletype){
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
	Variable * enter_var(string id, Type type, Type eletype, int level){
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
	Function * enter_func(string id, Type return_type){
		functions[id] = new Function(id,return_type);
		return functions[id];
	}
	Variable * search_var(string id){
		if(variables.count(id)!=0) return variables[id];
		return NULL;
	}
	Variable * enter_var(string id, Type type, Type eletype){
		variables[id] = new Variable(id,type,eletype,level);
		return variables[id];
	}
	void print(){
		cout<<"Printing Symbol Table: "<<endl;
		cout<<"Variables: "<<endl;
		cout<<"| id | type | element type  | level | dimlist |"<<endl;

		for(auto it=variables.begin(); it!= variables.end(); it++){
			it->second->print();
		}
		// cout<<"Functions: "<<endl;
		// for(auto it=functions.begin(); it!= functions.end(); it++){
		// 	it->second->print();
		// }
	}
};

// vector <string> var_list(Node * node){
// 	if(node->children.size()==3){

// 	}
// 	else{
// 		return node->children
// 	}
// }

// // void parse_tree(Node * node){
// 	if(node==NULL) return;
// 	if(node->type=="start"){
// 		parse_tree(node->children[0]);
// 	}
// 	else if(node->type=="dlist"){
// 		if(node->children.size()==2){
// 			parse_tree(node->children[0]);
// 			parse_tree(node->children[1]);
// 		}
// 		else{
// 			parse_tree(node->children[0]);
// 		}
// 	}
// 	else if(node->type=="d"){
// 			get_var_list
// 			parse_tree(node->children[0]);
// 			parse_tree(node->children[1]);
// 			parse_tree(node->children[2]);
// 	} 
// 	return;
// }
