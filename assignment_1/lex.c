#include "lex.h"
#include <stdio.h>
#include <ctype.h>


char* yytext = ""; /* Lexeme (not '\0'
                      terminated)              */
int yyleng   = 0;  /* Lexeme length.           */
int yylineno = 0;  /* Input line number        */

int lex(void){

   static char input_buffer[1024];
   char        *current;

   current = yytext + yyleng; /* Skip current
                                 lexeme        */

   while(1){       /* Get the next one         */
      while(!*current ){
         /* Get new lines, skipping any leading
         * white space on the line,
         * until a nonblank line is found.
         */

         current = input_buffer;
         if(!gets(input_buffer)){
            *current = '\0' ;

            return EOI;
         }
         ++yylineno;
         while(isspace(*current))
            ++current;
      }
      for(; *current; ++current){
         /* Get the next token */
         yytext = current;
         yyleng = 1;
         switch( *current ){
           case ';':
            return SEMI;
           case '+':
            return PLUS;
           case '-':
            return MINUS;
           case '*':
            return TIMES;
           case '/':
            return DIV;
           case '(':
            return LP;
           case ')':
            return RP;
           case '>':
            return GT;
           case '<':
            return LT;
           case '=':
            return EQUAL;
           case ':':
            return COL;
           case '\n':
           case '\t':
           case ' ' :
            break;
           default:
            if(!isalnum(*current))
               fprintf(stderr, "Not alphanumeric <%c>\n", *current);
            else{
               while(isalnum(*current))
                  ++current;
               yyleng = current - yytext;
               //Comparing the lexemes with length more than 1,we use temporary buffer
               
               if (yyleng==2 && yytext[0]=='i' && yytext[1]=='f'){
                 return IF;
               }
               if (yyleng==2 && yytext[0]=='d' && yytext[1]=='o'){
                 return DO;
               }
               if (yyleng==3 && yytext[0]=='e' && yytext[1]=='n' && yytext[2]=='d' ){
                 return END;
               }
               if (yyleng==4 && yytext[0]=='t' && yytext[1]=='h' && yytext[2]=='e' && yytext[3]=='n'){
                 return THEN;
               }
               if (yyleng==5 && yytext[0]=='b' && yytext[1]=='e' && yytext[2]=='g' && yytext[3]=='i' && yytext[4]=='n'){
                 return BEGIN;
               }
               if (yyleng==5 && yytext[0]=='w' && yytext[1]=='h' && yytext[2]=='i' && yytext[3]=='l' && yytext[4]=='e'){
                 return WHILE;
               }
               if(yyleng>0 && isalpha(yytext[0]))
               {
                 while(isalnum(*current) || isspace(*current))
                  current++;
                if(*current==':')
                 return ID;
               }

               return NUM_OR_ID;
            }
            break;
         }
      }
   }
}


static int Lookahead = -1; /* Lookahead token  */

int match(int token){
   /* Return true if "token" matches the
      current lookahead symbol.                */

   if(Lookahead == -1)
      Lookahead = lex();
    // if(token==ID && Lookahead==NUM_OR_ID){
    //   return 1;
    // }
    // else
    //   return 0;
    return token==Lookahead;
}

void advance(void){
/* Advance the lookahead to the next
   input symbol.                               */

    Lookahead = lex();
}
// #include "lex.h"
// #include <stdio.h>
// #include <ctype.h>


// char* yytext = ""; /* Lexeme (not '\0'
//                       terminated)              */
// int yyleng   = 0;  /* Lexeme length.           */
// int yylineno = 0;  /* Input line number        */

// int lex(void){

//    static char input_buffer[1024];
//    char        *current;

//    current = yytext + yyleng; /* Skip current
//                                  lexeme        */

//    while(1){       /* Get the next one         */
//       while(!*current ){
//          /* Get new lines, skipping any leading
//          * white space on the line,
//          * until a nonblank line is found.
//          */

//          current = input_buffer;
//          if(!gets(input_buffer)){
//             *current = '\0' ;

//             return EOI;
//          }
//          ++yylineno;
//          while(isspace(*current))
//             ++current;
//       }
//       for(; *current; ++current){
//          /* Get the next token */
//          yytext = current;
//          yyleng = 1;
//          switch( *current ){
//            case ';':
//             return SEMI;
//            case '+':
//             return PLUS;
//            case '-':
//             return MINUS;
//            case '*':
//             return TIMES;
//            case '/':
//             return DIV;
//            case '(':
//             return LP;
//            case ')':
//             return RP;
//            case '\n':
//            case '\t':
//            case ' ' :
//             break;
//            default:
//             if(!isalnum(*current))
//                fprintf(stderr, "Not alphanumeric <%c>\n", *current);
//             else{
//                while(isalnum(*current))
//                   ++current;
//                yyleng = current - yytext;
//                return NUM_OR_ID;
//             }
//             break;
//          }
//       }
//    }
// }


// static int Lookahead = -1; /* Lookahead token  */

// int match(int token){
//    /* Return true if "token" matches the
//       current lookahead symbol.                */

//    if(Lookahead == -1)
//       Lookahead = lex();

//    return token == Lookahead;
// }

// void advance(void){
// /* Advance the lookahead to the next
//    input symbol.                               */

//     Lookahead = lex();
// }
