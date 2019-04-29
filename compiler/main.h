#include <bits/stdc++.h>
using namespace std;
#define int_size 4
#define float_size 4

enum Type{
	_integer,
	_real,
	_error,
	_none,
	_simple,
	_array,
	_function,
	_boolean,
	_void
};

extern int level;
extern int var_num;
extern stringstream xyz;
extern int yylineno;
const vector <string> _type = {"integer", "real", "error", "none", "simple", "array", "function","boolean","void"};


string get_var();
string get_curr_var();
bool is_number(string s);
Type get_type(Type a, Type b);
string backpatch_quad(string str);
string backpatch_force(string str);
void patch_quad(int a, vector <int> b);
void patch_quad_force(int a, vector <int> b);
vector<string> split(string str,string sep);
void ReplaceStringInPlace(string& subject, const string& search,const string& replace);
void SymtabReader();


template <class A> ostream& operator << (ostream& out, const vector<A> &v) {
	out << "[";
	for(int i=0;i<v.size(); i++) {
		if(i) out << ", ";
		out << v[i];
	}
	return out << "]";
}

struct Node{
	string type; 	//token class
	string value;	//token value
	vector <Node *> children;
	vector <int> quadlist;
	vector <int> falselist;
	vector <int> truelist;
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
		xyz<<"\t#{"<< id <<","<< _type[type] <<","<<_type[eletype]<<"," << level <<","<< dimlist<<"}\n";
	}
	// ostream &operator <<(ostream &os){
	// 	os<<"| "<< id <<" | "<< type <<" | "<<eletype<<" | " << level <<" | "<< dimlist<<" |";
	// }
};

struct Function{
	int num_param;
	string id;
	vector <Variable * > parameters;
	int size;
	Type return_type;

	Function(string id, Type return_type): id(id), return_type(return_type){
		num_param = 0;
		size = 0;
	};
	void print(){
		xyz<<"{"<< id <<","<< _type[return_type] <<","<<num_param <<","<<size<<"}";
	}
	void print_params(){
		xyz<<"\t${"<<id<<": "<<endl;
		for(int i=0; i<parameters.size(); i++){
			xyz<<"\t";parameters[i]->print();

		}
		xyz<<"\t#}";
	}
	Variable * search_param(string name){
		for(int i=0; i<parameters.size(); i++){
			if(parameters[i]->id==name) return parameters[i];
		}
		return NULL;
	}
	Variable * enter_param(string name, Type type, Type eletype);
	bool check_param_type(int pno, Type type){
		return parameters[pno]->type==type;
	}
	int get_param_num(string name){
		for(int i=0; i<parameters.size(); i++){
			if(parameters[i]->id==name) return i+1;
		}
		return -1;
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
	string print(){
		xyz.str("");
		cout<<"Printing Symbol Table: "<<endl;
		cout<<"Format for variables and parameters: {id,type,element_type,level,dimlist}"<<endl;
		cout<<"Format for functions:                {id,return_type,num_param,size}"<<endl;
		xyz<<"@Variables: @{"<<endl;
		for(int i=0; i<=level; i++){			
			for(auto it=variables[i].begin(); it!= variables[i].end(); it++){
				it->second->print();
			}
		}
		xyz<<"#}"<<endl;
		xyz<<"@Functions: @{"<<endl;
		for(auto it=functions.begin(); it!= functions.end(); it++){
			xyz<<"\t$";
			it->second->print();
				xyz<<endl;
		}
		xyz<<"$}"<<endl;
				xyz<<"@Parameters: @{"<<endl;
		for(auto it=functions.begin(); it!= functions.end(); it++){
			it->second->print_params();
				xyz<<endl;
		}
		xyz<<"$}"<<endl;
		string s2 = xyz.str();
		ReplaceStringInPlace(s2,"$","");
		ReplaceStringInPlace(s2,"@","");
		ReplaceStringInPlace(s2,"#","");
		cout<<s2<<endl;
		// string s1 = xyz.str();
		// ReplaceStringInPlace(s1,"\n","");
		// ReplaceStringInPlace(s1,"\t","");
		// ReplaceStringInPlace(s1," ","");
		// return s1;
		xyz.str("");
		for(auto it=functions.begin(); it!= functions.end(); it++){
			Function * fn = it->second;
			xyz<<fn->id<<" "<<fn->num_param<<" "<<fn->size<<endl;
		}
		return xyz.str();

	}
	SymbolTable(){increase_level();};
};

