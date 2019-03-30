%{
	#include <stdlib.h>
	#include <stdio.h>
	int count_line = 1;
	void yyerror(char *s)
	{
		fprintf(stderr,"INVALID SYNTAX at line %d\n",count_line);
		exit(1);
	}
	int yywrap()
	{
		return 1;
	}
%}

%token PROJECT
%token SELECT
%token CARTESIAN_PRODUCT
%token EQUI_JOIN
%token NOT
%token LT
%token GT
%token LB
%token RB
%token NEWLINE
%token COLON
%token TABLE
%token OPERATOR
%token COMPARE
%token EQUI_CONDITION
%token COMMA
%token STR
%token ERR


%%
statements 			: statements NEWLINE statement COLON | statement COLON ;
statement 			: SELECT LT conditions GT LB TABLE RB | 
					  PROJECT LT attribute_lists GT LB TABLE RB |
					  LB TABLE RB CARTESIAN_PRODUCT LB TABLE RB |
					  LB TABLE RB EQUI_JOIN LT equi_conditions GT LB TABLE RB ;
attribute_lists		: attribute_lists COMMA TABLE |
					  TABLE;
conditions 			: conditions OPERATOR condition |
			 		  condition;
condition 			: EQUI_CONDITION | NOT temp | temp;
temp 				: TABLE COMPARE TABLE | TABLE COMPARE STR | TABLE LT TABLE | TABLE LT STR | TABLE GT TABLE | TABLE GT STR;
equi_conditions		: equi_conditions OPERATOR EQUI_CONDITION |
					  EQUI_CONDITION;

%%

int main()
{
	yyparse();
	printf("VALID\n");
}