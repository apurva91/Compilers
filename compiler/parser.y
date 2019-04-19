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
%}

%union{
	Node * node;
}

%token<node> SEMI EQUAL ADD SUB MUL DIV MOD GT LT GE LE EQ NE OR AND LP RP LB RB LS RS COMMA MAIN INT VOID FLOAT FOR WHILE IF ELSE SWITCH CASE DEFAULT BREAK CONTINU RETURN INTEGERS FLOATING_POINTS IDENTIFIER

%type<node> start dlist d t l id_arr dimlist num_id

%start start


%define parse.error verbose;

%%

start			:	statements 
					{ $$ = new Node("start",""); $$->children.push_back($1); root = $$; };

statements		:	statement
					{ $$ = new Node("statements","");$$->children.push_back($1);} 
					|
					statement statements
					{$$ = new Node("statements","");$$->children.push_back($1);$$->children.push_back($2);};
statement		:	var_decl
					{ $$ = new Node("statement","");$$->children.push_back($1);} 
					|
					expression SEMI
					{ $$ = new Node("statement","");$$->children.push_back($1);$$->children.push_back($2);};
var_decl		: 	dlist SEMI
					{ $$ = new Node("var_decl",""); $$->children.push_back($1);};
dlist			:	d
					{ $$ = new Node("dlist",""); $$->children.push_back($1);}
					|
					dlist SEMI d 
					{ $$ = new Node("dlist","");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);};
d				:	t l 
					{ $$ = new Node("d","");$$->children.push_back($1);$$->children.push_back($2);};
t				:	INT
					{$$ = new Node("t",$1->value);$$->children.push_back($1);} 
					|
					FLOAT 
					{$$ = new Node("t",$1->value);$$->children.push_back($1);} ;
l				:	id_arr
					{ $$ = new Node("l",""); $$->children.push_back($1);}
					|
					id_arr COMMA l;
					{ $$ = new Node("l","");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);};
id_arr			: 	IDENTIFIER
					{ $$ = new Node("id_arr",""); $$->children.push_back($1);} 
					|
					IDENTIFIER LS dimlist RS
					{ $$ = new Node("id_arr",""); $$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);$$->children.push_back($4);};
dimlist			:	num_id
					{ $$ = new Node("dimlist",""); $$->children.push_back($1);} 
					| 
					num_id COMMA dimlist
					{ $$ = new Node("dimlist",""); $$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);};
num_id			:	INTEGERS
					{ $$ = new Node("num_id",$1->value); $$->children.push_back($1);} 
					|
					IDENTIFIER
					{ $$ = new Node("dimlist",$1->value); $$->children.push_back($1);};
					
//expression		:						


%%

bool syntax_success = true;

void yyerror(string s){
	cerr<<"Line Number " << yylineno <<" : "<<s<<endl;
	syntax_success = false;
}

int yywrap(){}

int main(){
	yyparse();
	return 0;
}
