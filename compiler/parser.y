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

start			:	dlist SEMI;
dlist			:	d
					|
					dlist SEMI d {cout<<"+1"<<endl;};
d				:	t l ;
t				:	INT 
					|
					FLOAT ;
l				:	id_arr 
					|
					id_arr COMMA l;
id_arr			: 	IDENTIFIER 
					|
					IDENTIFIER LS dimlist RS;
dimlist			:	num_id 
					| 
					num_id COMMA dimlist;
num_id			:	INTEGERS
					|
					IDENTIFIER;

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
