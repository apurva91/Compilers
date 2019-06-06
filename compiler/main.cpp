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
	return to_string(var_num);
}

string get_curr_var(){
	
	return  to_string(var_num);
}

string gfv(){
	for(int i=0; i<float_pool.size(); i++){
		if(float_pool[i].second){
			float_pool_curr = i;
			float_pool[i].second = false;
			return float_pool[i].first;
		}
	}
	return "Exceeds";
}

string gfcv(){
	return "f" + to_string(float_pool_curr);  
}

void rfv(string name){
	for(int i=0; i<float_pool.size(); i++){
		if(!float_pool[i].second&&float_pool[i].first==name){
			float_pool[i].second = true;
			float_pool_curr = -1;
		}
	}
}

string giv(){
	for(int i=0; i<int_pool.size(); i++){
		if(int_pool[i].second){
			int_pool_curr = i;
			int_pool[i].second = false;
			return int_pool[i].first;
		}
	}
	return "Exceeds";
}

string gicv(){
	return "it" + to_string(int_pool_curr);  
}

void itv(string s){
	string p = s;
	ReplaceStringInPlace(p,"_term","");
	if(p[1]=='t'||p[1]=='i'){
	cout<<p<<endl;
		riv(p);
	}
	if(p[0]=='f'&&isdigit(p[1])){
		rfv(p);
	}
	if(p.back()==']'){		
		itv(split(p,"[")[0]);
		itv(split(split(p,"[")[1],"]")[0]);
	}

}

bool itcv(string s){
		string p = s;
	ReplaceStringInPlace(p,"_term","");
	if(p[1]=='t'||p[1]=='i'){
		return true;
	}
	if(p[0]=='f'&&isdigit(p[1])){
		return true;
	}
	return false;
}

void riv(string name){
	for(int i=0; i<int_pool.size(); i++){
		// cout<<name<<"''"<<endl;
		if(int_pool[i].second == false && int_pool[i].first==name){
		cout<<int_pool<<endl;
			int_pool[i].second = true;
			int_pool_curr = -1;
		}
	}
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

void patch_quad_force(int a, vector <int> b){
	for(int i=0; i<b.size(); i++){
		patch_listf[b[i]] = a;
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
map <int,int> quads;

string backpatch_quad(string s){
		vector <string> p = split(s,"\n");
		for(auto it=patch_list.begin(); it!=patch_list.end(); it++){
			int j = it->second;
			while(patch_list.count(j)!=0){
				j = patch_list[j];
			}
			p[it->first] = p[it->first] + to_string(j+1);
			quads[j] = 1;
		}
		// for(int i=0; i<patch_list.size(); i++){
		// 	for(int j=0; j<patch_list[i].second.size(); j++){
		// 		p[patch_list[i].second[j]] = p[patch_list[i].second[j]] + to_string(patch_list[i].first+1);
		// 	}
		// }
		stringstream tmp;
		for(int i=0; i<p.size(); i++){
			// tmp<<i+1<<": "<<p[i]<<endl;
			tmp<<p[i]<<endl;
		}
		return tmp.str();
}

string backpatch_force(string s){
		vector <string> p = split(s,"\n");
		for(auto it=patch_listf.begin(); it!=patch_listf.end(); it++){
			int j = it->second;
			p[it->first] = p[it->first] + to_string(j+1);
			quads[j] = 1;
		}

		stringstream tmp;
		for(int i=0; i<p.size(); i++){
			if(quads.count(i)!=0){
				tmp<<i+1<<": \n";
			}
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

void SymtabReader(){
	ifstream in_sym("symtab.txt");
	string s;
	in_sym>>s;
	in_sym.close();
	vector <string> g = split(s,"@");
	vector <string> f = split(g[3],"$");
	f = vector <string> (f.begin()+1,f.begin()+f.size()-1);
	vector <string> p = split(g[5],"$");
	p = vector <string> (p.begin()+1,p.begin()+p.size()-1);
	vector < vector < vector < string > > > functions (f.size(), vector < vector <string> > (1));
	for(int i=0; i<f.size(); i++){
		functions[i][0] = split(string(f[i].begin()+1,f[i].begin()+f[i].size()-1),",");
		vector <string> params = split(p[i],"#");
		params = vector <string> (params.begin()+1,params.begin()+params.size()-1);
		for(int j=0; j<params.size(); j++){
			functions[i].push_back(split(string(params[j].begin()+1,params[j].begin()+params[j].size()-1),","));
		} 
	}
	// cout<<functions<<endl;
}