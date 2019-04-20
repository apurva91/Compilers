%{ 
	#include <bits/stdc++.h>
	#include "main.h"
	using namespace std;

	extern int yylex();
	extern int yyparse();
	extern int yylineno;
	void yyerror(string s);

	Node * root;
	int level = 0;
	SymbolTable symtab;

	vector <Variable *> patch;
	Function * active_func_ptr = NULL;
	vector <string> dimlist;
	int error_count = 0;
%}

%union{
	Node * node;
}

%token<node> SEMI EQUAL ADD SUB MUL DIV MOD GT LT GE LE EQ NE OR AND LP RP LB RB LS RS COMMA MAIN INT VOID FLOAT FOR WHILE IF ELSE SWITCH CASE DEFAULT BREAK CONTINU RETURN INTEGERS FLOATING_POINTS IDENTIFIER

%type<node> start dlist  d t l id_arr dimlist 

%start start


%define parse.error verbose;

%%

start			:	dlist
					{ $$ = new Node("start",""); $$->children.push_back($1);}
dlist			:	d	
					{ $$ = new Node("dlist",""); $$->children.push_back($1);}
					|
					d dlist  
					{ $$ = new Node("dlist","");$$->children.push_back($1);$$->children.push_back($2);};
d				:	t l SEMI
					{
						$$ = new Node("d","");
						$$->children.push_back($1);
						$$->children.push_back($2);
						$$->children.push_back($3);
						for(int i=0; i<patch.size(); i++){
							patch[i]->eletype = $1->data_type;
						}
						patch.clear();
					};
t				:	INT
					{
						$$ = new Node("t",$1->value);
						$$->children.push_back($1);
						$$->data_type = _integer;
					} 
					|
					FLOAT 
					{
						$$ = new Node("t",$1->value);
						$$->children.push_back($1);
						$$->data_type = _real;
					};
l				:	id_arr
					{
						$$ = new Node("l","");
						$$->children.push_back($1);
					}
					|
					id_arr COMMA l
					{
						$$ = new Node("l","");
						$$->children.push_back($1);
						$$->children.push_back($2);
						$$->children.push_back($3);
					};
id_arr			: 	IDENTIFIER
					{
						$$ = new Node("id_arr",$1->value);
						$$->children.push_back($1);
						if(active_func_ptr==NULL){
							if(symtab.search_var($1->value)){
								yyerror("Variable \033[1;31m" + $1->value + "\033[0m already declared.");
								error_count++;
							}
							else{
								Variable * t = symtab.enter_var($1->value,_simple,_none);
								patch.push_back(t);
							}
						}						
					} 
					|
					IDENTIFIER LS dimlist RS
					{
						$$ = new Node("id_arr",$1->value);
						$$->children.push_back($1);
						$$->children.push_back($2);
						$$->children.push_back($3);
						$$->children.push_back($4);
						if(active_func_ptr==NULL){
							if(symtab.search_var($1->value)){
								yyerror("Variable \033[1;31m" + $1->value + "\033[0m already declared.");
								error_count++;
							}
							else{
								Variable * t = symtab.enter_var($1->value,_array,_none);
								t->dimlist = dimlist;
								dimlist.clear();
								patch.push_back(t);
							}
						}
					};
dimlist			:	INTEGERS
					{ 
						$$ = new Node("dimlist","");
						$$->children.push_back($1);
						dimlist.insert(dimlist.begin(),($1->value));
					} 
					| 
					INTEGERS COMMA dimlist
					{
						$$ = new Node("dimlist",""); 
						$$->children.push_back($1);
						$$->children.push_back($2);
						$$->children.push_back($3);
						dimlist.insert(dimlist.begin(),($1->value));
					};
// num_id			:	INTEGERS
// 					{ $$ = new Node("num_id",$1->value); $$->children.push_back($1);} 
// 					|
// 					IDENTIFIER
// 					{ $$ = new Node("dimlist",$1->value); $$->children.push_back($1);};

%%

bool syntax_success = true;

void yyerror(string s){
	cerr<<"Line Number \033[1;31m" << yylineno <<"\033[0m : "<<s<<endl;
	syntax_success = false;
}


int yywrap(){}

int main(){
	yyparse();
	// cout<<"Total Errors: "<<error_count<<endl;
	if(syntax_success) symtab.print();
	return 0;
}
