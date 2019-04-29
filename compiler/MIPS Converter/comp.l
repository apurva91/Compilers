
%{

	#include <bits/stdc++.h>
	#include <stdlib.h>
	#include <string.h>
	#include "struct.h"
	#include "comp.tab.h"
	using namespace std;
	extern int count_line;
%}
b				[ ]*
int_var_name	"i."[a-zA-Z][0-9a-zA-Z_]*"."[0-9]+"."[0-9a-zA-Z_]+
float_var_name	"f."[a-zA-Z][0-9a-zA-Z_]*"."[0-9]+"."[0-9a-zA-Z_]+
func_name		[a-zA-Z][0-9a-zA-Z_]*
number			[0-9]+
compare			"=="|"<"|">"|"!="|"<="|">="
operator			"+"|"-"|"*"|"/"
array_decl		"i."[a-zA-Z][0-9a-zA-Z_]*"["[0-9]+"]."[0-9]+"."[0-9a-zA-Z_]+

%option noyywrap
%%
{b}
":"{b}				{printf("COLON %s\n ",yytext); return COLON;}
"func"				{return FUNC;}
"if"				{return IF;}
"goto"				{return GOTO;}
"begin"				{return BEGI;}
"return"			{return RETURN;}
"param"				{return PARAM;}
"refparam"			{return REFPARAM;}
"end"				{return END;}
"call"				{return CALL;}
","					{return COMMA;}
"="					{return ASSIGN;}
"["					{return SQL;}
"]"					{return SQR;}
"("					{return LB;}
")"					{return RB;}
"#"					{return HASH;}
"addr"				{return ADDR;}
{array_decl}		{yylval.N=new node; yylval.N->stringdata = strdup(yytext); return ARRAY_DECL;}
"it"[0-9]+			{yylval.N=new node; yylval.N->stringdata = strdup(yytext); return TEMP;}
"f"[0-9]+			{yylval.N=new node; yylval.N->stringdata = strdup(yytext); printf("fx -> %s\n",yytext); return FLOAT_TEMP;}
{int_var_name}		{yylval.N=new node; yylval.N->stringdata = strdup(yytext); return INT_VAR;}
{float_var_name}	{yylval.N=new node; yylval.N->stringdata = strdup(yytext); return FLOAT_VAR;}
{func_name}			{yylval.N=new node; yylval.N->stringdata = strdup(yytext); return FUNC_NAME;}
{compare}			{yylval.N=new node; yylval.N->stringdata = strdup(yytext); return COMPARE;}
{operator}			{yylval.N=new node; yylval.N->stringdata = strdup(yytext); return OPERATOR;}
{number}			{yylval.N=new node; yylval.N->stringdata = strdup(yytext); return NUM;}
{number}"."{number}	{yylval.N=new node; yylval.N->stringdata = strdup(yytext); printf("N.N -> %s\n",yytext);return FLOAT_NUM;}
\n 					{count_line++; return NEWLINE;}
[.^ \n]*			{printf("others %s",yytext);}
%%			
