#define EOI		0	/* End of input			*/
#define SEMI		1	/* ; 				*/
#define PLUS 		2	/* + 				*/
#define TIMES		3	/* * 				*/
#define LP		4	/* (				*/
#define RP		5	/* )				*/
#define NUM_OR_ID	6	/* Decimal Number or Identifier */
#define DIV		7	/* /				*/
#define MINUS		8	/* -				*/
#define IF			9	/*	< 				*/
#define THEN			10	/*	> 				*/
#define WHILE		11	/*	= 				*/
#define DO			12   /*	if              */
#define LT 		13   /* then            */
#define GT 		14   /* while           */
#define EQUAL 			15   /* do              */
#define BEGIN 		16   /* begin           */
#define END			17   /* end				*/
#define ID 			18   /* Identifier		*/
#define COL 		19   /*	:				*/

extern char *yytext;		/* in lex.c			*/
extern int yyleng;
extern yylineno;