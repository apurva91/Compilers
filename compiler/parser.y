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

%type<node> start dlist d t l id_arr dimlist num_id expression sim_exp un_exp dm_exp log_exp and_exp rel_exp

%start start


%define parse.error verbose;

%%

start			:	statements 
					{ $$ = new Node("start",""); $$->children.push_back($1); root = $$; }
					;

statements		:	statement
					{ $$ = new Node("statements","");$$->children.push_back($1);} 
					|
					statement statements
					{$$ = new Node("statements","");$$->children.push_back($1);$$->children.push_back($2);}
					;
statement		:	var_decl
					{ $$ = new Node("statement","");$$->children.push_back($1);} 
					|
					expression SEMI
					{ $$ = new Node("statement","");$$->children.push_back($1);$$->children.push_back($2);}
					;
var_decl		: 	dlist SEMI
					{ $$ = new Node("var_decl",""); $$->children.push_back($1);}
					;
dlist			:	d
					{ $$ = new Node("dlist",""); $$->children.push_back($1);}
					|
					dlist SEMI d 
					{ $$ = new Node("dlist","");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);}
					;
d				:	t l 
					{ $$ = new Node("d","");$$->children.push_back($1);$$->children.push_back($2);}
					;
t				:	INT
					{$$ = new Node("t",$1->value);$$->children.push_back($1);} 
					|
					FLOAT 
					{$$ = new Node("t",$1->value);$$->children.push_back($1);} 
					;
l				:	id_arr
					{ $$ = new Node("l",""); $$->children.push_back($1);}
					|
					id_arr COMMA l;
					{ $$ = new Node("l","");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);}
					;
id_arr			: 	IDENTIFIER
					{ $$ = new Node("id_arr",""); $$->children.push_back($1);} 
					|
					IDENTIFIER LS dimlist RS
					{ $$ = new Node("id_arr",""); $$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);$$->children.push_back($4);}
					;
dimlist			:	num_id
					{ $$ = new Node("dimlist",""); $$->children.push_back($1);} 
					| 
					num_id COMMA dimlist
					{ $$ = new Node("dimlist",""); $$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);}
					;
num_id			:	INTEGERS
					{ $$ = new Node("num_id",$1->value); $$->children.push_back($1);} 
					|
					IDENTIFIER
					{ $$ = new Node("dimlist",$1->value); $$->children.push_back($1);}
					;

//variable or an array element assigned an expression					
expression		:	id_arr EQUAL expression
					{$$ = new Node("expression","=");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);}					
					|
					log_exp
					{ $$ = new Node("expression","");$$->children.push_back($1);}
					;

log_exp 	:	log_exp OR and_exp
						{$$ = new Node("log_exp","or");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);}
					| 	and_exp
						{$$ = new Node("log_exp","");$$->children.push_back($1);}
					;

and_exp 	:	and_exp AND rel_exp
					{$$ = new Node("and_exp","and");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);}
				|	rel_exp
					{$$ = new Node("and_exp","");$$->children.push_back($1);}
				;

rel_exp 	:	rel_exp op3 sim_exp
							{$$ = new Node("rel_exp","op");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);}
						|	sim_exp
							{$$ = new Node("rel_exp","");$$->children.push_back($1);}
						;

sim_exp 		:	sim_exp op1 dm_exp{ $$ = new Node("dimlist",""); $$->children.push_back($1);}
							{$$ = new Node("sim_exp",$1->value + $2->value + $3->value);$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);}
						|	dm_exp
							{$$ = new Node("sim_exp",$1->value);$$->children.push_back($1);}
						;

dm_exp 	: 	dm_exp op2 un_exp
						{$$ = new Node("dm_exp",$1->value + $2->value + $3->value);$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);}
					| 	un_exp
						{$$ = new Node("dm_exp",$1->value);$$->children.push_back($1);}
					;

un_exp 	: 	unop term
						{$$ = new Node("un_exp",$1->value + $2->value);$$->children.push_back($1);$$->children.push_back($2);}
					| 	term
						{$$ = new Node("un_exp",$1->value);$$->children.push_back($1);}
					;

op1 	: 	ADD
				{$$ = new Node("op1", "+");$$->children.push_back($1);}
			| 	SUB
				{$$ = new Node("op1", "-");$$->children.push_back($1);}
			;

op2 	: 	MUL
				{$$ = new Node("op2", "*");$$->children.push_back($1);}
			| 	DIV
				{$$ = new Node("op2", "/");$$->children.push_back($1);}
			| 	MOD
				{$$ = new Node("op2", "%");$$->children.push_back($1);}
			;

op3 	: 	GT
				{$$ = new Node("op3", ">");$$->children.push_back($1);}
			| 	LT
				{$$ = new Node("op3", "<");$$->children.push_back($1);}
			| 	GE
				{$$ = new Node("op3", ">=");$$->children.push_back($1);}
			| 	LE
				{$$ = new Node("op3", "<=");$$->children.push_back($1);}
			| 	EQ
				{$$ = new Node("op3", "==");$$->children.push_back($1);}
			| 	NE
				{$$ = new Node("op3", "!=");$$->children.push_back($1);}
			;

unop 	:	SUB
					{$$ = new Node("unop", "-");$$->children.push_back($1);}
				|	ADD
					{$$ = new Node("unop", "+");$$->children.push_back($1);}
				;

term 	:	LB_ROUND expression RB_ROUND
			{$$ = new Node("term","");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);}
		// | 	function_call
		// 	{$$ = new Node("term",$1->getValue(), $1, NULL, NULL);}
		|	INTEGERS
			{$$ = new Node("term",$1->value);$$->children.push_back($1);}
		|	id_arr
			{$$ = new Node("term",$1->value);$$->children.push_back($1);}
		;
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
