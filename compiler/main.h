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
bool is_number(string s);

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
		cout<<"| "<< id <<" | "<< _type[type] <<" | "<<_type[eletype]<<" | " << level <<" | "<< dimlist<<" | "<<endl;
	}
	// ostream &operator <<(ostream &os){
	// 	os<<"| "<< id <<" | "<< type <<" | "<<eletype<<" | " << level <<" | "<< dimlist<<" |";
	// }
};

struct Function{
	int num_param;
	string id;
	vector <Variable * > parameters;

	Type return_type;

	Function(string id, Type return_type): id(id), return_type(return_type){
		num_param = 0;
	};
	void print(){
		cout<<"| "<< id <<" | "<< _type[return_type] <<" | "<<num_param <<" | "<<endl;
		if(parameters.size()>0) cout<<"Parameters: "<<endl;
		for(int i=0; i<parameters.size(); i++){
			parameters[i]->print();
		}
	}
	Variable * search_param(string name){
		for(int i=0; i<parameters.size(); i++){
			if(parameters[i]->id==name) return parameters[i];
		}
		return NULL;
	}
	Variable * enter_param(string name, Type type, Type eletype);
	bool check_param_type(int pno, Type type){
		return parameters[pno-1]->type==type;
	}
};

struct SymbolTable{
	// map <string, Variable * > variables; // level 0 variables
	vector < map <string, Variable * > > variables;  //scope and id give Type 
	map <string, Function *> functions;
	Function * search_function(string id){
		if(functions.count(id)!=0) return functions[id];
		return NULL;	
	}
	Function * enter_func(string id, Type return_type){
		functions[id] = new Function(id,return_type);
		return functions[id];
	}
	Variable * search_var(string id, int level){
		for(int i=level; i>=0; i--){
			if(variables[i].count(id)!=0) return variables[i][id];
		}
		return NULL;
	}
	Variable * enter_var(string id, Type type, Type eletype){
		variables[level][id] = new Variable(id,type,eletype,level);
		return variables[level][id];
	}
	void increase_level(){
		level++;
		map <string, Variable *> tm;
		tm.clear();
		variables.push_back(tm);
	}
	void decrease_level(){
		level--;
		variables.pop_back();
	}
	void print(){
		cout<<"Printing Symbol Table: "<<endl;
		cout<<"Variables: "<<endl;
		cout<<"| id | type | element type  | level | dimlist |"<<endl;
		for(int i=0; i<=level; i++){			
			for(auto it=variables[i].begin(); it!= variables[i].end(); it++){
				it->second->print();
			}
		}
		cout<<"Functions: "<<endl;
		cout<<"| id | type | num_param |"<<endl;
		for(auto it=functions.begin(); it!= functions.end(); it++){
			it->second->print();
		}
	}
	SymbolTable(){increase_level();};
};