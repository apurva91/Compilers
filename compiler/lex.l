%{
	#include <bits/stdc++.h>
	using namespace std;
	#include "main.h"
	#include "parser.tab.h"
	extern bool syntax_success; 
%}

%option yylineno

%%

";"			{ yylval.node = new Node("SEMI",yytext); return SEMI; }
":"			{ yylval.node = new Node("COLON",yytext); return COLON; }
"="			{ yylval.node = new Node("EQUAL",yytext); return EQUAL; }
"+"			{ yylval.node = new Node("ADD",yytext); return ADD; }
"-"			{ yylval.node = new Node("SUB",yytext); return SUB; }
"*"			{ yylval.node = new Node("MUL",yytext); return MUL; }
"/"			{ yylval.node = new Node("DIV",yytext); return DIV; }
"%"			{ yylval.node = new Node("MOD",yytext); return MOD; }
">"			{ yylval.node = new Node("GT",yytext); return GT; }
"<"			{ yylval.node = new Node("LT",yytext); return LT; }
">="		{ yylval.node = new Node("GE",yytext); return GE; }
"<="		{ yylval.node = new Node("LE",yytext); return LE; }
"=="		{ yylval.node = new Node("EQ",yytext); return EQ; }
("!="|"<>") { yylval.node = new Node("NE",yytext); return NE; }
"||"		{ yylval.node = new Node("OR",yytext); return OR; } 	
"&&"		{ yylval.node = new Node("AND",yytext); return AND; } 
"("			{ yylval.node = new Node("LP",yytext); return LP; }

")"			{ yylval.node = new Node("RP",yytext); return RP; }	
"{"			{ yylval.node = new Node("LB",yytext); return LB; }	
"}"			{ yylval.node = new Node("RB",yytext); return RB; }	
"!"			{ yylval.node = new Node("NOT",yytext); return NOT; }	
"["			{ yylval.node = new Node("LS",yytext); return LS; }
"]"			{ yylval.node = new Node("RS",yytext); return RS; }	
","			{ yylval.node = new Node("COMMA",yytext); return COMMA; } 
"int"		{ yylval.node = new Node("INT",yytext); return INT; }	
"void"		{ yylval.node = new Node("VOID",yytext); return VOID; }
"main"		{ yylval.node = new Node("MAIN",yytext); return MAIN; }
"float"		{ yylval.node = new Node("FLOAT",yytext); return FLOAT; } 
"for"		{ yylval.node = new Node("FOR",yytext); return FOR; }	
"while"		{ yylval.node = new Node("WHILE",yytext); return WHILE; }
"if"		{ yylval.node = new Node("IF",yytext); return IF; } 	
"else"		{ yylval.node = new Node("ELSE",yytext); return ELSE; }
"switch"	{ yylval.node = new Node("SWITCH",yytext); return SWITCH; }
"case"		{ yylval.node = new Node("CASE",yytext); return CASE; }
"default"	{ yylval.node = new Node("DEFAULT",yytext); return DEFAULT; }
"break"		{ yylval.node = new Node("BREAK",yytext); return BREAK; }  
"continue"	{ yylval.node = new Node("CONTINUE",yytext); return CONTINUE; }
"return"	{ yylval.node = new Node("RETURN",yytext); return RETURN; } 

([0-9]+)			{ yylval.node = new Node("INTEGERS",yytext); return INTEGERS; }
([0-9]+\.[0-9]+)	{ yylval.node = new Node("FLOATING_POINTS",yytext); return FLOATING_POINTS; }
([A-Za-z_]([A-Za-z0-9_])*) { yylval.node = new Node("IDENTIFIER",yytext); return IDENTIFIER; }
([ \t]+) 			{ }
([\r\n]) 				{    }
"#"[ \t]*"include"[ \t]+(\<[A-za-z_\.\/0-9]+\>|\"[A-za-z_\.\/0-9]+\")	{yylval.node = new Node("LIBRARIES",yytext); return LIBRARIES; }
.					{cerr<< "TOKEN CANNOT BE MATCHED :\t"<< yytext <<"\t"<<"\t"<<endl; syntax_success = false;}

%%

//Todos 
// #include
// printf("")
// #define
