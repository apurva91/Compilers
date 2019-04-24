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

	Variable * Function::enter_param(string name, Type type, Type eletype){
		parameters.push_back(new Variable(name,type,eletype,1));
		symtab.variables[1][name] = parameters.back()	;
		num_param++;
		return parameters.back();
	}

// Variable * Function::search_var(string id, int level){
// 	for(int i=level; i>=2; i--){
// 		if(variables[i].count(id)!=0) return variables[i][id];
// 	}
// 	Variable * ptr = search_param(id);
// 	if(ptr) return ptr;
// 	if(symtab.variables.count(id)!=0) return symtab.variables[id];
	
// 	return NULL;
// }
// 
// extern vector < pair < int , vector <int > > > patch_list;
extern map <int , int> patch_list;
extern map <int , int> patch_listf;

void patch_quad(int a, vector <int> b){
	for(int i=0; i<b.size(); i++){
		patch_list[b[i]] = a;
	}
	// patch_list.push_back(make_pair(a,b));
}

std::vector<std::string> split(std::string str,std::string sep){
    char* cstr=const_cast<char*>(str.c_str());
    char* current;
    std::vector<std::string> arr;
    current=strtok(cstr,sep.c_str());
    while(current!=NULL){
        arr.push_back(current);
        current=strtok(NULL,sep.c_str());
    }
    return arr;
}

string backpatch_quad(string s){
		vector <string> p = split(s,"\n");
		for(auto it=patch_list.begin(); it!=patch_list.end(); it++){
			int j = it->second;
			while(patch_list.count(j)!=0){
				j = patch_list[j];
			}
			p[it->first] = p[it->first] + to_string(j+1);
		}
		// for(int i=0; i<patch_list.size(); i++){
		// 	for(int j=0; j<patch_list[i].second.size(); j++){
		// 		p[patch_list[i].second[j]] = p[patch_list[i].second[j]] + to_string(patch_list[i].first+1);
		// 	}
		// }
		stringstream tmp;
		for(int i=0; i<p.size(); i++){
			tmp<<i+1<<": "<<p[i]<<endl;
		}
		return tmp.str();
}

string backpatch_force(string s){
		vector <string> p = split(s,"\n");
		for(auto it=patch_listf.begin(); it!=patch_listf.end(); it++){
			int j = it->second;
			p[it->first] = p[it->first] + to_string(j+1);
		}

		stringstream tmp;
		for(int i=0; i<p.size(); i++){
			tmp<<p[i]<<endl;
		}
		return tmp.str();

}

void ReplaceStringInPlace(std::string& subject, const std::string& search,const std::string& replace) {
    size_t pos = 0;
    while ((pos = subject.find(search, pos)) != std::string::npos) {
         subject.replace(pos, search.length(), replace);
         pos += replace.length();
    }
}