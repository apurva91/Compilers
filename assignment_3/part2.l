
%{
	#include <stdlib.h>
	#include <string.h>
	#include "q2.tab.h"
	extern int count_line;
%}
b				[ ]*
table_name		{b}[0-9a-zA-Z_]*{b}
compare			{b}"="{b}|{b}"<"{b}|{b}">"{b}|{b}"!="{b}|{b}"<="{b}|{b}">="{b}
operator   		{b}"AND"{b}|{b}"and"{b}|{b}"OR"{b}|{b}"or"{b}
attribute		[0-9a-zA-Z]+|[0-9a-zA-Z]+\.[0-9a-zA-Z]+
equi_condition	{b}{attribute}{b}={b}{attribute}{b}

%%
{b}"PROJECT"{b}				{return PROJECT;}
{b}"SELECT"{b}				{printf("select\n");return SELECT;}
{b}"CARTESIAN_PRODUCT"{b}	{return CARTESIAN_PRODUCT;}
{b}"EQUI_JOIN"{b}			{printf("equi_join\n");return EQUI_JOIN;}
{b}"NOT"{b}					{return NOT;}
{b}"<"{b}					{return LT;}
{b}">"{b}					{return GT;}
\'[^\']*\'					{printf("string %s\n",yytext);return STR;}
\"[^\"]*\"					{return STR;}
{compare}					{printf("compare %s\n",yytext);return COMPARE;}
{operator}					{printf("operator %s\n",yytext);return OPERATOR;}
{equi_condition}			{printf("equi_condition %s\n",yytext);return EQUI_CONDITION;}
{table_name}				{printf("table %s\n",yytext);return TABLE;}
{b}","{b}					{return COMMA;}
{b}"("{b}					{return LB;}
{b}")"{b}					{return RB;}
\n							{count_line++; return NEWLINE;}
{b}";"{b}					{return COLON;}
.							{return ERR;}
%%						

