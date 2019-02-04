#include <stdio.h>
#include "lex.h"
#include "lex.c"
#include "name.c"
#include <stdbool.h>

#include <stdarg.h>

#define MAXFIRST 16
#define SYNCH    SEMI

char    *factor     ( void );
char    *term       ( void );
char    *expression ( void );

extern char *newname( void       );
extern void freename( char *name );
char * expression1();
int legal_lookahead( int first_arg  , ...);

void statements(){
    while(!match(EOI))
        statement();
}

void statement()
{
    /*  statements -> expression SEMI  |  expression SEMI statements  */
        char *tempvar;
        if(match(ID))
        {
            char identifier[100];
            for(int i=0;i<yyleng;i++)
                identifier[i]=*(yytext+i);
            identifier[yyleng]='\0';

            advance();
            if(!legal_lookahead( COL, 0 ) ){
                printf("%d: Inserting missing colon\n", yylineno );
                goto check_SEMI;
            }
            else{
                advance();
                if( !legal_lookahead( EQUAL, 0 ) ){
                    printf("%d: Inserting missing equal\n", yylineno );
                    goto check_SEMI;
                }
                else{
                    advance();
                    tempvar = expression1();
                    printf("_%s <- %s\n",identifier,tempvar);
                }
            }
        }
        else if(match(IF)){
            advance();
            printf("if (\n");
            tempvar = expression1();
            if( !legal_lookahead( THEN, 0 ) )
            {
                freename(tempvar);
                printf("%d: Inserting missing then\n", yylineno );
                goto check_SEMI;
            }
            else{
                printf("%s)\nthen {\n", tempvar);
                advance();
                freename(tempvar);
                statement();
                printf("}\n");
                return;
            }
        }
        else if(match(WHILE))
        {
            advance();
            printf("while (\n");
            tempvar = expression1();
            if( !legal_lookahead( DO, 0 ) )
            {
                freename(tempvar);
                printf("%d: Inserting missing do\n", yylineno );
                goto check_SEMI;
            }
            else
            {
                printf("%s)\n do {\n", tempvar);
                advance();
                freename(tempvar);
                statement();
                printf("}\n");
                return;
            }
        }
        else if(match(BEGIN))
        {
            printf("BEGIN{\n");
            advance();
            stmt_list();
            if(!legal_lookahead(END,0))
            {
                printf("%d: Inserting missing END\n", yylineno );
                goto check_SEMI;
            } 
            else 
            {
                printf("} END\n");
                advance();
            }
            return;
        }
        else{
            tempvar = expression1();
        }

        if(tempvar!=NULL){
            freename( tempvar );
        } 
        else{
            exit(1);
        }
        // tempvar = expression();
        check_SEMI:
            if( match( SEMI ) )
                advance();
            else
                printf("%d: Inserting missing semicolon\n", yylineno );

        // freename( tempvar );
}

void stmt_list()
{

    /*
        stmt_list -> statement stmt_list | epsilon
    */

    while(!match(END)&&!match(EOI))
        statement();
    if(match(EOI)){
        fprintf( stderr, "%d: End of file reached no END found\n", yylineno );
    }
}

char *expression1(){
    char *tempvar3;
    char * tempvar=expression();
    if(match(GT))
    {
        freename(tempvar);
        tempvar3=newname();
        tempvar=newname();
        printf("%s <- %s\n", tempvar, tempvar3);

        advance();
        char *tempvar2=expression();
        printf("%s <-  %s > %s\n",tempvar3,tempvar,tempvar2);
        
        freename(tempvar2);
        freename(tempvar);
        return tempvar3;
    }
    else if(match(LT))
    {
        freename(tempvar);
        tempvar3=newname();
        tempvar=newname();
        printf("%s <- %s\n", tempvar, tempvar3);

        advance();
        char *tempvar2=expression();
        printf("%s <-  %s < %s\n",tempvar3,tempvar,tempvar2);
        freename(tempvar);
        freename(tempvar2);
        return tempvar3;
    }
    else if(match(EQUAL))
    {
        freename(tempvar);
        tempvar3=newname();
        tempvar=newname();
        printf("%s <- %s\n", tempvar, tempvar3);

        advance();
        char *tempvar2=expression();
        printf("%s <-  %s == %s\n",tempvar3,tempvar,tempvar2);
        freename(tempvar);
        freename(tempvar2);
        return tempvar3;
    }
    return tempvar;
}
char    *expression()
{
    /* expression -> term expression'
     * expression' -> PLUS term expression' |  epsilon
     */

    char  *tempvar, *tempvar2;

    tempvar = term();
    bool flag=true;
    while(flag)
    {
        if(match( PLUS )){
            advance();
            tempvar2 = term();
            printf("%s += %s\n", tempvar, tempvar2 );
            freename( tempvar2 );
        }
        else if(match( MINUS )){
            advance();
            tempvar2 = term();
            printf("%s -= %s\n", tempvar, tempvar2 );
            freename( tempvar2 );
        }
        else{
            flag=false;
        }
    }

    return tempvar;
}

char    *term()
{
    char  *tempvar, *tempvar2 ;

    tempvar = factor();
    bool flag=true; 
    while(flag)
    {
        if(match( TIMES )){
            advance();
            tempvar2 = factor();
            printf("%s *= %s\n", tempvar, tempvar2 );
            freename( tempvar2 );
        }
        else if(match( DIV )){
            advance();
            tempvar2 = factor();
            printf("%s /= %s\n", tempvar, tempvar2 );
            freename( tempvar2 );
        }
        else{
            flag=false;
        }
    }

    return tempvar;
}

char    *factor()
{
    char *tempvar=NULL;

    if( match(NUM_OR_ID))
    {
	/* Print the assignment instruction. The %0.*s conversion is a form of
	 * %X.Ys, where X is the field width and Y is the maximum number of
	 * characters that will be printed (even if the string is longer). I'm
	 * using the %0.*s to print the string because it's not \0 terminated.
	 * The field has a default width of 0, but it will grow the size needed
	 * to print the string. The ".*" tells printf() to take the maximum-
	 * number-of-characters count from the next argument (yyleng).
	 */
        if(isalpha(yytext[0]))
            printf("%s = _%.*s\n", tempvar = newname(), yyleng, yytext );
        else
            printf("%s = %.*s\n", tempvar = newname(), yyleng, yytext );
        advance();
    }
    else if( match(LP) )
    {
        advance();
        tempvar = expression();
        if( match(RP) )
            advance();
        else
            printf("%d: Mismatched parenthesis\n", yylineno );
    }
    else
	printf("%d: Number or identifier expected\n", yylineno );

    return tempvar;
}

int legal_lookahead( int first_arg, ... )
// int first_arg;
{
    
    /* Simple error detection and recovery. Arguments are a 0-terminated list of
     * those tokens that can legitimately come next in the input. If the list is
     * empty, the end of file must come next. Print an error message if
     * necessary. Error recovery is performed by discarding all input symbols
     * until one that's in the input list is found
     *
     * Return true if there's no error or if we recovered from the error,
     * false if we can't recover.
     */

    va_list     args;
    int     tok;
    int     lookaheads[MAXFIRST], *p = lookaheads, *current;
    int     error_printed = 0;
    int     rval          = 0;

    va_start( args, first_arg );

    if( !first_arg )
    {
        if( match(EOI) )
            rval = 1;
    }
    else
    {
        *p++ = first_arg;
        while( (tok = va_arg(args, int)) && p < &lookaheads[MAXFIRST] )
            *p++ = tok;

        while( !match( SYNCH ) ) {
            for( current = lookaheads; current < p ; ++current )
            if( match( *current ) )
            {
                rval = 1;
                goto exit;
            }

            if( !error_printed ){
                fprintf( stderr, "Line %d: Syntax error\n", yylineno );
                error_printed = 1;
            }
            advance();
       }
    }

exit:
    va_end( args );
    return rval;
}