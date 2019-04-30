%{
	#include <bits/stdc++.h>
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	#include "struct.h"
	using namespace std;
	int count_line;
	map <string,int> M;
	vector <int> start_pos;
	map < string, vector<char*> > param_list;
	vector<char*> call_list;
	vector<char*> refparam_list;
	char* func_name;
	map<string,int> func_no_params;
	map<string,int> func_mem_size;
	int float_lab_count=0;
	int mem;
	int count=0;
	void yyerror(char *s)
	{
		fprintf(stderr,"INVALID SYNTAX at line %d\n",count_line);
		exit(1);
	}
	int yywrap()
	{
		return 1;
	}
	int yylex();

	FILE *fp,*fp1;
%}
%{
	void strip_first_char(char* a);
%}

%union
{
	int intValue;
	float floatValue;
	char *stringValue;
	struct node *N;
}
%token FUNC
%token GOTO
%token BEGI
%token RETURN
%token PARAM
%token REFPARAM
%token END
%token CALL
%token COMMA
%token ASSIGN
%token <N> TEMP
%token <N> INT_VAR
%token <N> FUNC_NAME
%token <N> COMPARE
%token <N> OPERATOR
%token <N> NUM
%token NEWLINE
%token COLON
%token IF
%token SQR
%token SQL
%token LB
%token RB
%token HASH
%token ADDR
%token <N> ARRAY_DECL
%token <N> FLOAT_VAR
%token <N> FLOAT_TEMP
%token <N> FLOAT_NUM



%%
statements 			: statements NEWLINE statement | statement ;

statement 			: NUM COLON
{
	fprintf(fp, "L%s :\n", $1->stringdata);
} ;  
statement 			: FUNC BEGI FUNC_NAME 
{
	fprintf(fp, "%s :\n", $3->stringdata);
	// string str($3->stringdata);
	func_name=$3->stringdata;
	if(strcmp(func_name,"main")==0){
		fprintf(fp, "addiu $sp, $sp, -3000\n");	
		mem=3000;
	}
	else{
		fprintf(fp, "addiu $sp, $sp, -%d\n",func_mem_size[$3->stringdata]);	
		mem=func_mem_size[$3->stringdata];	
	}
	mem=mem-4;
	fprintf(fp, "sw $ra,%d($sp)\n",mem);
	mem=mem-4;
	start_pos.push_back(mem);
	fprintf(fp, "sw $fp,%d($sp)\n",mem);
	fprintf(fp, "move $fp,$sp\n");
}; 
statement 			: FUNC END 
{
	fprintf(fp, "move $sp,$fp\n");
	int n = start_pos[start_pos.size()-1];
	start_pos.pop_back();
	fprintf(fp, "lw $fp,%d($sp)\n",n);
	n=n+4;
	fprintf(fp, "lw $ra,%d($sp)\n",n);
	n=n+4;
	// if(strcmp(func_name,"main")==0)
	fprintf(fp, "addiu $sp, $sp, %d\n",n);
	fprintf(fp, "j $ra\n");
}; 
statement 			: INT_VAR ASSIGN NUM
{
	if(M.find($1->stringdata)==M.end()){
		mem=mem-4;
		M[$1->stringdata]=mem;
	}
	printf("%s,offset done: %d \n",$1->stringdata,M[$1->stringdata]);
	fprintf(fp,"li $a0,%s\n",$3->stringdata);
	fprintf(fp, "sw $a0,%d($fp)\n",M[$1->stringdata]);
};
statement 			: INT_VAR ASSIGN INT_VAR
{
	if(M.find($1->stringdata)==M.end()){
		mem=mem-4;
		M[$1->stringdata]=mem;
	}
	// printf("%s,offset done: %d \n",$1->stringdata,M[$1->stringdata]);
	fprintf(fp,"lw $a0,%d($fp)\n",M[$3->stringdata]);
	fprintf(fp, "sw $a0,%d($fp)\n",M[$1->stringdata]);
};
statement : INT_VAR ASSIGN HASH NUM
{
	//param_list[func_name].push_back($1->stringdata);
	int off = func_mem_size[func_name]+ (func_no_params[func_name]- atoi($4->stringdata))*4;
	if(M.find($1->stringdata)==M.end()){
		mem=mem-4;
		M[$1->stringdata]=mem;
	}
	fprintf(fp,"lw $a0,%d($fp)\n",off);
	fprintf(fp, "sw $a0,%d($fp)\n",M[$1->stringdata]);
};
statement : TEMP ASSIGN HASH NUM
{
	strip_first_char($1->stringdata);
	int off = func_mem_size[func_name]+ (func_no_params[func_name]- atoi($4->stringdata))*4;
	fprintf(fp,"lw $a0,%d($fp)\n",off);
	fprintf(fp, "move $%s,$a0\n",$1->stringdata);
};
statement 			: FLOAT_VAR ASSIGN FLOAT_NUM
{
	if(M.find($1->stringdata)==M.end()){
		mem=mem-4;
		M[$1->stringdata]=mem;
	}
	// printf("%s,offset done: %d \n",$1->stringdata,M[$1->stringdata]);
	fprintf(fp,"li.s $f30,%s\n",$3->stringdata);
	fprintf(fp, "s.s $f30,%d($fp)\n",M[$1->stringdata]);
};

statement : HASH NUM ASSIGN NUM
{
	// int off=atoi($2->stringdata);
	int off = func_mem_size[func_name]+ (func_no_params[func_name]- atoi($2->stringdata))*4;
	fprintf(fp, "li $a0,%s\n",$4->stringdata);
	fprintf(fp, "sw $a0,%d($fp)\n", off);
};

statement : HASH NUM ASSIGN FLOAT_NUM
{
	int off = func_mem_size[func_name]+ (func_no_params[func_name]- atoi($2->stringdata))*4;
	fprintf(fp, "li.s $f30,%s\n",$4->stringdata);
	fprintf(fp, "s.s $f30,%d($fp)\n", off);
};

statement : HASH NUM ASSIGN TEMP
{
	// int off=atoi($2->stringdata);
	int off = func_mem_size[func_name]+ (func_no_params[func_name]- atoi($2->stringdata))*4;
	strip_first_char($4->stringdata);
	// fprintf(fp, "li $a0,%s\n",$4->stringdata);
	fprintf(fp, "sw $%s,%d($fp)\n",$4->stringdata, off);
};
statement : HASH NUM ASSIGN FLOAT_TEMP
{
	// int off=atoi($2->stringdata);
	int off = func_mem_size[func_name]+ (func_no_params[func_name]- atoi($2->stringdata))*4;
	// strip_first_char($4->stringdata);
	// fprintf(fp, "li $a0,%s\n",$4->stringdata);
	fprintf(fp, "s.s $%s,%d($fp)\n",$4->stringdata, off);
};
statement : HASH NUM ASSIGN INT_VAR
{
	// int off=atoi($2->stringdata);
	int off = func_mem_size[func_name]+ (func_no_params[func_name]- atoi($2->stringdata))*4;
	// strip_first_char($4->stringdata);
	fprintf(fp, "lw $a0,%d($fp)\n", M[$4->stringdata]);
	fprintf(fp, "sw $a0,%d($fp)\n", off);
};
statement : HASH NUM ASSIGN FLOAT_VAR
{
	// int off=atoi($2->stringdata);
	int off = func_mem_size[func_name]+ (func_no_params[func_name]- atoi($2->stringdata))*4;
	// strip_first_char($4->stringdata);
	fprintf(fp, "l.s $f30,%d($fp)\n", M[$4->stringdata]);
	fprintf(fp, "s.s $f30,%d($fp)\n", off);
};
statement : TEMP ASSIGN INT_VAR
{
	strip_first_char($1->stringdata);
	fprintf(fp, "lw $%s,%d($fp)\n",$1->stringdata, M[$3->stringdata]);
};
statement : FLOAT_TEMP ASSIGN FLOAT_VAR
{
	// strip_first_char($1->stringdata);
	fprintf(fp, "l.s $%s,%d($fp)\n",$1->stringdata, M[$3->stringdata]);
};
statement 			: INT_VAR ASSIGN TEMP
{
	// $3->stringdata.erase($3->stringdata[0]);
	strip_first_char($3->stringdata);
	if(M.find($1->stringdata)==M.end()){
		mem=mem-4;
		M[$1->stringdata]=mem;
	}
	fprintf(fp, "sw $%s,%d($fp)\n",$3->stringdata, M[$1->stringdata]);
};

statement 			: FLOAT_VAR ASSIGN FLOAT_TEMP
{
	// $3->stringdata.erase($3->stringdata[0]);
	// strip_first_char($3->stringdata);
	if(M.find($1->stringdata)==M.end()){
		mem=mem-4;
		M[$1->stringdata]=mem;
	}
	fprintf(fp, "s.s $%s,%d($fp)\n",$3->stringdata, M[$1->stringdata]);
};

statement 			: TEMP ASSIGN TEMP
{
	strip_first_char($1->stringdata);
	strip_first_char($3->stringdata);
	fprintf(fp, "move $%s,$%s\n",$1->stringdata, $3->stringdata);
};
statement 			: FLOAT_TEMP ASSIGN FLOAT_TEMP
{
	// strip_first_char($1->stringdata);
	// strip_first_char($3->stringdata);
	fprintf(fp, "mov.s $%s,$%s\n",$1->stringdata, $3->stringdata);
};
statement 			: TEMP ASSIGN NUM
{
	strip_first_char($1->stringdata);
	fprintf(fp,"li $%s,%s\n",$1->stringdata,$3->stringdata);
};
statement 			: FLOAT_TEMP ASSIGN FLOAT_NUM
{
	// strip_first_char($1->stringdata);
	fprintf(fp,"li.s $%s,%s\n",$1->stringdata,$3->stringdata);
};
statement 			: GOTO NUM
{
	fprintf(fp, "j L%s\n", $2->stringdata);
}; 

statement 			: TEMP ASSIGN INT_VAR COMPARE NUM
{
	// $1->stringdata.erase($1->stringdata[0]);
	strip_first_char($1->stringdata);
	printf("%s,offset : %d \n",$3->stringdata,M[$3->stringdata]);
	fprintf(fp,"lw $a0,%d($fp)\n",M[$3->stringdata]);
	fprintf(fp,"li $a1,%s\n",$5->stringdata);
	// fprintf(fp,"slt $%s,$a0,$a1\n",$1->stringdata);
	if(strcmp($4->stringdata,"==")==0){
		fprintf(fp,"seq $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"!=")==0){
		fprintf(fp,"sne $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,">")==0){
		fprintf(fp,"sgt $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,">=")==0){
		fprintf(fp,"sge $%s,$a0,$a1\n",$1->stringdata);	
	}
	else if(strcmp($4->stringdata,"<")==0){
		fprintf(fp,"slt $%s,$a0,$a1\n",$1->stringdata);	
	}
	else if(strcmp($4->stringdata,"<=")==0){
		fprintf(fp,"sle $%s,$a0,$a1\n",$1->stringdata);
	}
};

statement : TEMP ASSIGN FLOAT_VAR COMPARE FLOAT_NUM
{
	strip_first_char($1->stringdata);
	// printf("%s,offset : %d \n",$3->stringdata,M[$3->stringdata]);
	fprintf(fp,"l.s $f29,%d($fp)\n",M[$3->stringdata]);
	fprintf(fp,"li.s $f30,%s\n",$5->stringdata);
	if(strcmp($4->stringdata,"==")==0){
		fprintf(fp,	"c.eq.s $f29,$f30\n");
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
		// fprintf(fp,"seq $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"!=")==0){
		fprintf(fp,	"c.eq.s $f29,$f30\n");
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}
	else if(strcmp($4->stringdata,">")==0){
		fprintf(fp,	"c.lt.s $f30,$f29\n");
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}
	else if(strcmp($4->stringdata,">=")==0){
		fprintf(fp,	"c.le.s $f30,$f29\n");
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;	
	}
	else if(strcmp($4->stringdata,"<")==0){
		fprintf(fp,	"c.lt.s $f29,$f30\n");
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;	
	}
	else if(strcmp($4->stringdata,"<=")==0){
		fprintf(fp,	"c.le.s $f29,$f30\n");
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}
};

statement : TEMP ASSIGN HASH NUM COMPARE NUM
{
	strip_first_char($1->stringdata);
	// int off=atoi($4->stringdata);
	int off = func_mem_size[func_name]+ (func_no_params[func_name]- atoi($4->stringdata))*4;
	// printf("%s,offset : %d \n",$3->stringdata,M[$3->stringdata]);
	fprintf(fp,"lw $a0,%d($fp)\n",off);
	fprintf(fp,"li $a1,%s\n",$6->stringdata);
	// fprintf(fp,"slt $%s,$a0,$a1\n",$1->stringdata);
	if(strcmp($5->stringdata,"==")==0){
		fprintf(fp,"seq $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($5->stringdata,"!=")==0){
		fprintf(fp,"sne $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($5->stringdata,">")==0){
		fprintf(fp,"sgt $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($5->stringdata,">=")==0){
		fprintf(fp,"sge $%s,$a0,$a1\n",$1->stringdata);	
	}
	else if(strcmp($5->stringdata,"<")==0){
		fprintf(fp,"slt $%s,$a0,$a1\n",$1->stringdata);	
	}
	else if(strcmp($5->stringdata,"<=")==0){
		fprintf(fp,"sle $%s,$a0,$a1\n",$1->stringdata);
	}	
};

statement : TEMP ASSIGN HASH NUM COMPARE FLOAT_NUM
{
	strip_first_char($1->stringdata);
	// int off=atoi($4->stringdata);
	int off = func_mem_size[func_name]+ (func_no_params[func_name]- atoi($4->stringdata))*4;
	// printf("%s,offset : %d \n",$3->stringdata,M[$3->stringdata]);
	fprintf(fp,"l.s $f29,%d($fp)\n",off);
	fprintf(fp,"li.s $f30,%s\n",$6->stringdata);
	// fprintf(fp,"slt $%s,$a0,$a1\n",$1->stringdata);
	if(strcmp($5->stringdata,"==")==0){
		fprintf(fp,	"c.eq.s $f29,$f30\n");
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
		// fprintf(fp,"seq $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($5->stringdata,"!=")==0){
		fprintf(fp,	"c.eq.s $f29,$f30\n");
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}
	else if(strcmp($5->stringdata,">")==0){
		fprintf(fp,	"c.lt.s $f30,$f29\n");
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}
	else if(strcmp($5->stringdata,">=")==0){
		fprintf(fp,	"c.le.s $f30,$f29\n");
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;	
	}
	else if(strcmp($5->stringdata,"<")==0){
		fprintf(fp,	"c.lt.s $f29,$f30\n");
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;	
	}
	else if(strcmp($5->stringdata,"<=")==0){
		fprintf(fp,	"c.le.s $f29,$f30\n");
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}	
};

statement : TEMP ASSIGN HASH NUM COMPARE TEMP
{
	strip_first_char($1->stringdata);
	strip_first_char($6->stringdata);
	// int off=atoi($4->stringdata);
	int off = func_mem_size[func_name]+ (func_no_params[func_name]- atoi($4->stringdata))*4;
	fprintf(fp,"lw $a0,%d($fp)\n",off);
	if(strcmp($5->stringdata,"==")==0){
		fprintf(fp,"seq $%s,$a0,$%s\n",$1->stringdata,$6->stringdata);
	}
	else if(strcmp($5->stringdata,"!=")==0){
		fprintf(fp,"sne $%s,$a0,$%s\n",$1->stringdata,$6->stringdata);
	}
	else if(strcmp($5->stringdata,">")==0){
		fprintf(fp,"sgt $%s,$a0,$%s\n",$1->stringdata,$6->stringdata);
	}
	else if(strcmp($5->stringdata,">=")==0){
		fprintf(fp,"sge $%s,$a0,$%s\n",$1->stringdata,$6->stringdata);	
	}
	else if(strcmp($5->stringdata,"<")==0){
		fprintf(fp,"slt $%s,$a0,$%s\n",$1->stringdata,$6->stringdata);	
	}
	else if(strcmp($5->stringdata,"<=")==0){
		fprintf(fp,"sle $%s,$a0,$%s\n",$1->stringdata,$6->stringdata);
	}	
};
statement : TEMP ASSIGN HASH NUM COMPARE FLOAT_TEMP
{
	strip_first_char($1->stringdata);
	// strip_first_char($6->stringdata);
	// int off=atoi($4->stringdata);
	int off = func_mem_size[func_name]+ (func_no_params[func_name]- atoi($4->stringdata))*4;
	fprintf(fp,"lw $f30,%d($fp)\n",off);
	if(strcmp($5->stringdata,"==")==0){
		fprintf(fp,	"c.eq.s $f30,$%s\n",$6->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
		// fprintf(fp,"seq $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($5->stringdata,"!=")==0){
		fprintf(fp,	"c.eq.s $f30,$%s\n",$6->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}
	else if(strcmp($5->stringdata,">")==0){
		fprintf(fp,	"c.lt.s $%s,$f30\n",$6->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}
	else if(strcmp($5->stringdata,">=")==0){
		fprintf(fp,	"c.le.s $%s,$f30\n",$6->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;	
	}
	else if(strcmp($5->stringdata,"<")==0){
		fprintf(fp,	"c.lt.s $f30,$%s\n",$6->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;	
	}
	else if(strcmp($5->stringdata,"<=")==0){
		fprintf(fp,	"c.le.s $f30,$%s\n",$6->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}	
};

statement 			: TEMP ASSIGN TEMP COMPARE NUM
{
	strip_first_char($1->stringdata);
	strip_first_char($3->stringdata);
	fprintf(fp,"li $a0,%s\n",$5->stringdata);
	if(strcmp($4->stringdata,"==")==0){
		fprintf(fp,"seq $%s,$%s,$a0\n",$1->stringdata,$3->stringdata);
	}
	else if(strcmp($4->stringdata,"!=")==0){
		fprintf(fp,"sne $%s,$%s,$a0\n",$1->stringdata,$3->stringdata);
	}
	else if(strcmp($4->stringdata,">")==0){
		fprintf(fp,"sgt $%s,$%s,$a0\n",$1->stringdata,$3->stringdata);
	}
	else if(strcmp($4->stringdata,">=")==0){
		fprintf(fp,"sge $%s,$%s,$a0\n",$1->stringdata,$3->stringdata);	
	}
	else if(strcmp($4->stringdata,"<")==0){
		fprintf(fp,"slt $%s,$%s,$a0\n",$1->stringdata,$3->stringdata);	
	}
	else if(strcmp($4->stringdata,"<=")==0){
		fprintf(fp,"sle $%s,$%s,$a0\n",$1->stringdata,$3->stringdata);
	}
}; 

statement 			: TEMP ASSIGN FLOAT_TEMP COMPARE FLOAT_NUM
{
	strip_first_char($1->stringdata);
	// strip_first_char($3->stringdata);
	fprintf(fp,"li.s $f30,%s\n",$5->stringdata);
	if(strcmp($4->stringdata,"==")==0){
		fprintf(fp,	"c.eq.s $%s,$f30\n",$3->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
		// fprintf(fp,"seq $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"!=")==0){
		fprintf(fp,	"c.eq.s $%s,$f30\n",$3->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}
	else if(strcmp($4->stringdata,">")==0){
		fprintf(fp,	"c.lt.s $f30,$%s\n",$3->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}
	else if(strcmp($4->stringdata,">=")==0){
		fprintf(fp,	"c.le.s $f30,$%s\n",$3->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;	
	}
	else if(strcmp($4->stringdata,"<")==0){
		fprintf(fp,	"c.lt.s $%s,$f30\n",$3->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;	
	}
	else if(strcmp($4->stringdata,"<=")==0){
		fprintf(fp,	"c.le.s $%s,$f30\n",$3->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}
}; 

statement 			: TEMP ASSIGN INT_VAR COMPARE TEMP
{
	strip_first_char($1->stringdata);
	strip_first_char($5->stringdata);
	fprintf(fp,"lw $a0,%d($fp)\n",M[$3->stringdata]);
	if(strcmp($4->stringdata,"==")==0){
		fprintf(fp,"seq $%s,$a0,$%s\n",$1->stringdata,$5->stringdata);
	}
	else if(strcmp($4->stringdata,"!=")==0){
		fprintf(fp,"sne $%s,$a0,$%s\n",$1->stringdata,$5->stringdata);
	}
	else if(strcmp($4->stringdata,">")==0){
		fprintf(fp,"sgt $%s,$a0,$%s\n",$1->stringdata,$5->stringdata);
	}
	else if(strcmp($4->stringdata,">=")==0){
		fprintf(fp,"sge $%s,$a0,$%s\n",$1->stringdata,$5->stringdata);	
	}
	else if(strcmp($4->stringdata,"<")==0){
		fprintf(fp,"slt $%s,$a0,$%s\n",$1->stringdata,$5->stringdata);	
	}
	else if(strcmp($4->stringdata,"<=")==0){
		fprintf(fp,"sle $%s,$a0,$%s\n",$1->stringdata,$5->stringdata);
	}
};
statement 			: TEMP ASSIGN FLOAT_VAR COMPARE FLOAT_TEMP
{
	strip_first_char($1->stringdata);
	fprintf(fp,"l.s $f30,%d($fp)\n",M[$3->stringdata]);
	if(strcmp($4->stringdata,"==")==0){
		fprintf(fp,	"c.eq.s $f30,$%s\n",$5->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
		// fprintf(fp,"seq $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"!=")==0){
		fprintf(fp,	"c.eq.s $f30,$%s\n",$5->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}
	else if(strcmp($4->stringdata,">")==0){
		fprintf(fp,	"c.lt.s $%s,$f30\n",$5->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}
	else if(strcmp($4->stringdata,">=")==0){
		fprintf(fp,	"c.le.s $%s,$f30\n",$5->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;	
	}
	else if(strcmp($4->stringdata,"<")==0){
		fprintf(fp,	"c.lt.s $f30,$%s\n",$5->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;	
	}
	else if(strcmp($4->stringdata,"<=")==0){
		fprintf(fp,	"c.le.s $f30,$%s\n",$5->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}
}; 
statement 			: TEMP ASSIGN TEMP COMPARE TEMP
{
	strip_first_char($1->stringdata);
	strip_first_char($3->stringdata);
	strip_first_char($5->stringdata);
	if(strcmp($4->stringdata,"==")==0){
		fprintf(fp,"seq $%s,$%s,$%s\n",$1->stringdata,$3->stringdata,$5->stringdata);
	}
	else if(strcmp($4->stringdata,"!=")==0){
		fprintf(fp,"sne $%s,$%s,$%s\n",$1->stringdata,$3->stringdata,$5->stringdata);
	}
	else if(strcmp($4->stringdata,">")==0){
		fprintf(fp,"sgt $%s,$%s,$%s\n",$1->stringdata,$3->stringdata,$5->stringdata);
	}
	else if(strcmp($4->stringdata,">=")==0){
		fprintf(fp,"sge $%s,$%s,$%s\n",$1->stringdata,$3->stringdata,$5->stringdata);	
	}
	else if(strcmp($4->stringdata,"<")==0){
		fprintf(fp,"slt $%s,$%s,$%s\n",$1->stringdata,$3->stringdata,$5->stringdata);	
	}
	else if(strcmp($4->stringdata,"<=")==0){
		fprintf(fp,"sle $%s,$%s,$%s\n",$1->stringdata,$3->stringdata,$5->stringdata);
	}
};
statement 			: TEMP ASSIGN FLOAT_TEMP COMPARE FLOAT_TEMP
{
	strip_first_char($1->stringdata);
	// strip_first_char($3->stringdata);
	// strip_first_char($5->stringdata);
	// printf("HELLLO\n");
	if(strcmp($4->stringdata,"==")==0){
		fprintf(fp,	"c.eq.s $%s,$%s\n",$3->stringdata,$5->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}
	else if(strcmp($4->stringdata,"!=")==0){
		fprintf(fp,	"c.eq.s $%s,$%s\n",$3->stringdata,$5->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}
	else if(strcmp($4->stringdata,">")==0){
	    fprintf(fp,	"c.lt.s $%s,$%s\n",$5->stringdata,$3->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}
	else if(strcmp($4->stringdata,">=")==0){
		fprintf(fp,	"c.le.s $%s,$%s\n",$5->stringdata,$3->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}
	else if(strcmp($4->stringdata,"<")==0){
		fprintf(fp,	"c.lt.s $%s,$%s\n",$3->stringdata,$5->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;	
	}
	else if(strcmp($4->stringdata,"<=")==0){
		fprintf(fp,	"c.le.s $%s,$%s\n",$3->stringdata,$5->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "li $%s,0\n",$1->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "li $%s,1\n",$1->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1 );
		float_lab_count+=2;
	}
}; 
statement 			: IF TEMP COMPARE NUM GOTO NUM
{
	// $2->stringdata.erase($2->stringdata[0]);
	strip_first_char($2->stringdata);

	fprintf(fp, "li $a0,%s\n",$4->stringdata);
	if(strcmp($3->stringdata,"==")==0){
		fprintf(fp, "beq $%s,$a0,L%s\n",$2->stringdata,$6->stringdata);
	}
	else if(strcmp($3->stringdata,"!=")==0){
		fprintf(fp, "bne $%s,$a0,L%s\n",$2->stringdata,$6->stringdata);
	}
	else if(strcmp($3->stringdata,">")==0){
		fprintf(fp, "bgt $%s,$a0,L%s\n",$2->stringdata,$6->stringdata);
	}
	else if(strcmp($3->stringdata,">=")==0){
		fprintf(fp, "bge $%s,$a0,L%s\n",$2->stringdata,$6->stringdata);
	}
	else if(strcmp($3->stringdata,"<")==0){
		fprintf(fp, "blt $%s,$a0,L%s\n",$2->stringdata,$6->stringdata);
	}
	else if(strcmp($3->stringdata,"<=")==0){
		fprintf(fp, "ble $%s,$a0,L%s\n",$2->stringdata,$6->stringdata);
	}
};
statement 			: IF TEMP COMPARE TEMP GOTO NUM
{
	// $2->stringdata.erase($2->stringdata[0]);
	strip_first_char($2->stringdata);
	strip_first_char($4->stringdata);

	// fprintf(fp, "li $a0,%s\n",$4->stringdata);
	if(strcmp($3->stringdata,"==")==0){
		fprintf(fp, "beq $%s,$%s,L%s\n",$2->stringdata,$4->stringdata,$6->stringdata);
	}
	else if(strcmp($3->stringdata,"!=")==0){
		fprintf(fp, "bne $%s,$%s,L%s\n",$2->stringdata,$4->stringdata,$6->stringdata);
	}
	else if(strcmp($3->stringdata,">")==0){
		fprintf(fp, "bgt $%s,$%s,L%s\n",$2->stringdata,$4->stringdata,$6->stringdata);
	}
	else if(strcmp($3->stringdata,">=")==0){
		fprintf(fp, "bge $%s,$%s,L%s\n",$2->stringdata,$4->stringdata,$6->stringdata);
	}
	else if(strcmp($3->stringdata,"<")==0){
		fprintf(fp, "blt $%s,$%s,L%s\n",$2->stringdata,$4->stringdata,$6->stringdata);
	}
	else if(strcmp($3->stringdata,"<=")==0){
		fprintf(fp, "ble $%s,$%s,L%s\n",$2->stringdata,$4->stringdata,$6->stringdata);
	}
}; 
statement 			: IF INT_VAR COMPARE NUM GOTO NUM
{
	fprintf(fp, "lw $a0,%d($fp)\n",M[$2->stringdata]);
	fprintf(fp, "li $a1,%s\n",$4->stringdata);
	if(strcmp($3->stringdata,"==")==0){
		fprintf(fp, "beq $a0,$a1,L%s\n",$6->stringdata);
	}
	else if(strcmp($3->stringdata,"!=")==0){
		fprintf(fp, "bne $a0,$a1,L%s\n",$6->stringdata);
	}
	else if(strcmp($3->stringdata,">")==0){
		fprintf(fp, "bgt $a0,$a1,L%s\n",$6->stringdata);
	}
	else if(strcmp($3->stringdata,">=")==0){
		fprintf(fp, "bge $a0,$a1,L%s\n",$6->stringdata);
	}
	else if(strcmp($3->stringdata,"<")==0){
		fprintf(fp, "blt $a0,$a1,L%s\n",$6->stringdata);
	}
	else if(strcmp($3->stringdata,"<=")==0){
		fprintf(fp, "ble $a0,$a1,L%s\n",$6->stringdata);
	}	
};
statement 			: IF FLOAT_TEMP COMPARE FLOAT_TEMP GOTO NUM
{
	// $2->stringdata.erase($2->stringdata[0]);
	// strip_first_char($2->stringdata);
	// strip_first_char($4->stringdata);

	// fprintf(fp, "li $a0,%s\n",$4->stringdata);
	if(strcmp($3->stringdata,"==")==0){
		fprintf(fp,	"c.eq.s $%s,$%s\n",$2->stringdata,$4->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "j L%s\n",$6->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1);
		float_lab_count+=2;
	}
	else if(strcmp($3->stringdata,"!=")==0){
		fprintf(fp,	"c.eq.s $%s,$%s\n",$2->stringdata,$4->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "j L%s\n",$6->stringdata );
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "FFL%d:\n",float_lab_count+1);
		float_lab_count+=2;
	}
	else if(strcmp($3->stringdata,">")==0){
		fprintf(fp,	"c.lt.s $%s,$%s\n",$4->stringdata,$2->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "j L%s\n",$6->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1);
		float_lab_count+=2;	
	}
	else if(strcmp($3->stringdata,">=")==0){
		fprintf(fp,	"c.le.s $%s,$%s\n",$4->stringdata,$2->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "j L%s\n",$6->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1);
		float_lab_count+=2;
	}
	else if(strcmp($3->stringdata,"<")==0){
		fprintf(fp,	"c.lt.s $%s,$%s\n",$2->stringdata,$4->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "j L%s\n",$6->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1);
		float_lab_count+=2;
	}
	else if(strcmp($3->stringdata,"<=")==0){
		fprintf(fp,	"c.le.s $%s,$%s\n",$2->stringdata,$4->stringdata);
		fprintf(fp, "bc1t FFL%d\n",float_lab_count);
		fprintf(fp, "j FFL%d\n",float_lab_count+1);
		fprintf(fp, "FFL%d:\n",float_lab_count);
		fprintf(fp, "j L%s\n",$6->stringdata );
		fprintf(fp, "FFL%d:\n",float_lab_count+1);
		float_lab_count+=2;
	}
}; 
statement : TEMP ASSIGN HASH NUM OPERATOR NUM
{
	strip_first_char($1->stringdata);
	int off = func_mem_size[func_name]+ (func_no_params[func_name]- atoi($4->stringdata))*4;
	fprintf(fp, "lw $a0,%d($fp)\n",off);
	fprintf(fp, "li $a1,%s\n",$6->stringdata);
	if(strcmp($5->stringdata,"+")==0){
		fprintf(fp, "add $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($5->stringdata,"-")==0){
		fprintf(fp, "sub $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($5->stringdata,"*")==0){
		fprintf(fp, "mul $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($5->stringdata,"/")==0){
		fprintf(fp, "div $a0,$a1\n");
		fprintf(fp, "move $%s,$lo\n",$1->stringdata);
	}
};
statement : TEMP ASSIGN HASH NUM OPERATOR TEMP
{
	strip_first_char($1->stringdata);
	strip_first_char($6->stringdata);
	int off = func_mem_size[func_name]+ (func_no_params[func_name]- atoi($4->stringdata))*4;
	fprintf(fp, "lw $a0,%d($fp)\n",off);
	// fprintf(fp, "li $a1,%s\n",$6->stringdata);
	if(strcmp($5->stringdata,"+")==0){
		fprintf(fp, "add $%s,$a0,$%s\n",$1->stringdata,$6->stringdata);
	}
	else if(strcmp($5->stringdata,"-")==0){
		fprintf(fp, "sub $%s,$a0,$%s\n",$1->stringdata,$6->stringdata);
	}
	else if(strcmp($5->stringdata,"*")==0){
		fprintf(fp, "mul $%s,$a0,$%s\n",$1->stringdata,$6->stringdata);
	}
	else if(strcmp($5->stringdata,"/")==0){
		fprintf(fp, "div $a0,$%s\n",$6->stringdata);
		fprintf(fp, "move $%s,$lo\n",$1->stringdata);
	}
};
statement : TEMP ASSIGN HASH NUM OPERATOR HASH NUM
{
	strip_first_char($1->stringdata);
	int off = func_mem_size[func_name]+ (func_no_params[func_name]- atoi($4->stringdata))*4;
	int off1 = func_mem_size[func_name]+ (func_no_params[func_name]- atoi($7->stringdata))*4;
	fprintf(fp, "lw $a0,%d($fp)\n",off);
	fprintf(fp, "lw $a1,%d($fp)\n",off1);
	// fprintf(fp, "li $a1,%s\n",$6->stringdata);
	if(strcmp($5->stringdata,"+")==0){
		fprintf(fp, "add $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($5->stringdata,"-")==0){
		fprintf(fp, "sub $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($5->stringdata,"*")==0){
		fprintf(fp, "mul $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($5->stringdata,"/")==0){
		fprintf(fp, "div $a0,$a1\n");
		fprintf(fp, "move $%s,$lo\n",$1->stringdata);
	}	
};
statement 			: TEMP ASSIGN INT_VAR OPERATOR NUM
{
	// $1->stringdata.erase($1->stringdata[0]);
	strip_first_char($1->stringdata);
	fprintf(fp, "lw $a0,%d($fp)\n",M[$3->stringdata]);
	fprintf(fp, "li $a1,%s\n",$5->stringdata);
	if(strcmp($4->stringdata,"+")==0){
		fprintf(fp, "add $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"-")==0){
		fprintf(fp, "sub $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"*")==0){
		fprintf(fp, "mul $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"/")==0){
		fprintf(fp, "div $a0,$a1\n");
		fprintf(fp, "move $%s,$lo\n",$1->stringdata);
	}
}; 
statement 			: TEMP ASSIGN INT_VAR OPERATOR INT_VAR
{
	strip_first_char($1->stringdata);
	fprintf(fp, "lw $a0,%d($fp)\n",M[$3->stringdata]);
	fprintf(fp, "lw $a1,%d($fp)\n",M[$5->stringdata]);
	if(strcmp($4->stringdata,"+")==0){
		fprintf(fp, "add $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"-")==0){
		fprintf(fp, "sub $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"*")==0){
		fprintf(fp, "mul $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"/")==0){
		fprintf(fp, "div $a0,$a1\n");
		fprintf(fp, "move $%s,$lo\n",$1->stringdata);
	}
}; 
statement 			: FLOAT_TEMP ASSIGN FLOAT_VAR OPERATOR FLOAT_VAR
{
	// strip_first_char($1->stringdata);
	fprintf(fp, "l.s $f29,%d($fp)\n",M[$3->stringdata]);
	fprintf(fp, "l.s $f30,%d($fp)\n",M[$5->stringdata]);
	if(strcmp($4->stringdata,"+")==0){
		fprintf(fp, "add.s $%s,$f29,$f30\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"-")==0){
		fprintf(fp, "sub.s $%s,$f29,$f30\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"*")==0){
		fprintf(fp, "mul.s $%s,$f29,$f30\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"/")==0){
		fprintf(fp, "div.s $%s,$f29,$f30\n",$1->stringdata);
	}
};
statement 			: TEMP ASSIGN INT_VAR OPERATOR TEMP
{
	strip_first_char($1->stringdata);
	strip_first_char($5->stringdata);
	fprintf(fp, "lw $a0,%d($fp)\n",M[$3->stringdata]);
	if(strcmp($4->stringdata,"+")==0){
		fprintf(fp, "add $%s,$a0,$%s\n",$1->stringdata,$5->stringdata);
	}
	else if(strcmp($4->stringdata,"-")==0){
		fprintf(fp, "sub $%s,$a0,$%s\n",$1->stringdata,$5->stringdata);
	}
	else if(strcmp($4->stringdata,"*")==0){
		fprintf(fp, "mul $%s,$a0,$%s\n",$1->stringdata,$5->stringdata);
	}
	else if(strcmp($4->stringdata,"/")==0){
		fprintf(fp, "div $a0,$%s\n",$5->stringdata);
		fprintf(fp, "move $%s,$lo\n",$1->stringdata);
	}
}; 
statement 			: TEMP ASSIGN TEMP OPERATOR NUM
{
	strip_first_char($1->stringdata);
	strip_first_char($3->stringdata);
	fprintf(fp, "li $a0,%s\n",$5->stringdata);	
	if(strcmp($4->stringdata,"+")==0){
		fprintf(fp, "add $%s,$%s,$a0\n",$1->stringdata,$3->stringdata);
	}
	else if(strcmp($4->stringdata,"-")==0){
		fprintf(fp, "sub $%s,$%s,$a0\n",$1->stringdata,$3->stringdata);
	}
	else if(strcmp($4->stringdata,"*")==0){
		fprintf(fp, "mul $%s,$%s,$a0\n",$1->stringdata,$3->stringdata);
	}
	else if(strcmp($4->stringdata,"/")==0){
		fprintf(fp, "div $%s,$a0\n",$3->stringdata);
		fprintf(fp, "move $%s,$lo\n",$1->stringdata);
	}
}; 
statement 			: TEMP ASSIGN TEMP OPERATOR INT_VAR
{
	strip_first_char($1->stringdata);
	strip_first_char($3->stringdata);
	fprintf(fp, "lw $a0,%d($fp)\n",M[$5->stringdata]);	
	if(strcmp($4->stringdata,"+")==0){
		fprintf(fp, "add $%s,$%s,$a0\n",$1->stringdata,$3->stringdata);
	}
	else if(strcmp($4->stringdata,"-")==0){
		fprintf(fp, "sub $%s,$%s,$a0\n",$1->stringdata,$3->stringdata);
	}
	else if(strcmp($4->stringdata,"*")==0){
		fprintf(fp, "mul $%s,$%s,$a0\n",$1->stringdata,$3->stringdata);
	}
	else if(strcmp($4->stringdata,"/")==0){
		fprintf(fp, "div $%s,$a0\n",$3->stringdata);
		fprintf(fp, "move $%s,$lo\n",$1->stringdata);
	}
}; 
statement 			: TEMP ASSIGN TEMP OPERATOR TEMP
{
	strip_first_char($1->stringdata);
	strip_first_char($3->stringdata);
	strip_first_char($5->stringdata);
	if(strcmp($4->stringdata,"+")==0){
		fprintf(fp, "add $%s,$%s,$%s\n",$1->stringdata,$3->stringdata,$5->stringdata);
	}
	else if(strcmp($4->stringdata,"-")==0){
		fprintf(fp, "sub $%s,$%s,$%s\n",$1->stringdata,$3->stringdata,$5->stringdata);
	}
	else if(strcmp($4->stringdata,"*")==0){
		fprintf(fp, "mul $%s,$%s,$%s\n",$1->stringdata,$3->stringdata,$5->stringdata);
	}
	else if(strcmp($4->stringdata,"/")==0){
		fprintf(fp, "div $%s,$%s\n",$3->stringdata,$5->stringdata);
		fprintf(fp, "move $%s,$lo\n",$1->stringdata);
	}
}; 
statement : FLOAT_TEMP ASSIGN FLOAT_TEMP OPERATOR FLOAT_TEMP
{
	if(strcmp($4->stringdata,"+")==0){
		fprintf(fp, "add.s $%s,$%s,$%s\n",$1->stringdata,$3->stringdata,$5->stringdata);
	}
	else if(strcmp($4->stringdata,"-")==0){
		fprintf(fp, "sub.s $%s,$%s,$%s\n",$1->stringdata,$3->stringdata,$5->stringdata);
	}
	else if(strcmp($4->stringdata,"*")==0){
		fprintf(fp, "mul.s $%s,$%s,$%s\n",$1->stringdata,$3->stringdata,$5->stringdata);
	}
	else if(strcmp($4->stringdata,"/")==0){
		fprintf(fp, "div.s $%s,$%s,$%s\n",$1->stringdata,$3->stringdata,$5->stringdata);
	}
};
statement 			: TEMP ASSIGN NUM OPERATOR NUM
{
	strip_first_char($1->stringdata);
	
	printf("li $a0,%s\n",$3->stringdata);	
	printf("li $a1,%s\n",$5->stringdata);
	fprintf(fp, "li $a0,%s\n",$3->stringdata);	
	fprintf(fp, "li $a1,%s\n",$5->stringdata);	
	if(strcmp($4->stringdata,"+")==0){
		fprintf(fp, "add $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"-")==0){
		fprintf(fp, "sub $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"*")==0){
		fprintf(fp, "mul $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"/")==0){
		fprintf(fp, "div $a0,$a1\n");
		fprintf(fp, "mov %s,$lo\n",$1->stringdata);
	}
}; 
statement 			: TEMP ASSIGN NUM OPERATOR INT_VAR
{
	strip_first_char($1->stringdata);
	fprintf(fp, "li $a0,%s\n",$3->stringdata);	
	fprintf(fp, "lw $a1,%d($fp)\n",M[$5->stringdata]);	
	if(strcmp($4->stringdata,"+")==0){
		fprintf(fp, "add $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"-")==0){
		fprintf(fp, "sub $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"*")==0){
		fprintf(fp, "mul $%s,$a0,$a1\n",$1->stringdata);
	}
	else if(strcmp($4->stringdata,"/")==0){
		fprintf(fp, "div $a0,$a1\n");
		fprintf(fp, "mov %s,$lo\n",$1->stringdata);
	}
}; 
statement 			: TEMP ASSIGN NUM OPERATOR TEMP
{
	strip_first_char($1->stringdata);
	strip_first_char($5->stringdata);
	fprintf(fp, "li $a0,%s\n",$3->stringdata);	
	if(strcmp($4->stringdata,"+")==0){
		fprintf(fp, "add $%s,$a0,$%s\n",$1->stringdata,$5->stringdata);
	}
	else if(strcmp($4->stringdata,"-")==0){
		fprintf(fp, "sub $%s,$a0,$%s\n",$1->stringdata,$5->stringdata);
	}
	else if(strcmp($4->stringdata,"*")==0){
		fprintf(fp, "mul $%s,$a0,$%s\n",$1->stringdata,$5->stringdata);
	}
	else if(strcmp($4->stringdata,"/")==0){
		fprintf(fp, "div $a0,$%s\n",$5->stringdata);
		fprintf(fp, "mov %s,$lo\n",$1->stringdata);
	}
};
statement : PARAM TEMP
{
	strip_first_char($2->stringdata);
	mem=mem-4;
	fprintf(fp, "addiu $sp,$sp,-4\n");
	fprintf(fp, "sw $%s,%d($sp)\n",$2->stringdata,0);
};
statement : PARAM FLOAT_TEMP
{
	mem=mem-4;
	fprintf(fp, "addiu $sp,$sp,-4\n");
	fprintf(fp, "s.s $%s,%d($sp)\n",$2->stringdata,0);
};

statement : PARAM INT_VAR
{
	mem=mem-4;
	fprintf(fp, "lw $a0,%d($fp)\n",M[$2->stringdata]);
	fprintf(fp, "addiu $sp,$sp,-4\n");
	fprintf(fp, "sw $a0,%d($sp)\n",0);
};
statement : REFPARAM TEMP
{
	strip_first_char($2->stringdata);
	call_list.push_back($2->stringdata);
	mem=mem-4;
	fprintf(fp, "addiu $sp,$sp,-4\n");
	fprintf(fp, "sw $%s,%d($sp)\n",$2->stringdata,0);	
};
statement : REFPARAM FLOAT_TEMP
{
	// strip_first_char($2->stringdata);
	call_list.push_back($2->stringdata);
	mem=mem-4;
	fprintf(fp, "addiu $sp,$sp,-4\n");
	fprintf(fp, "s.s $%s,%d($sp)\n",$2->stringdata,0);	
};
statement : CALL FUNC_NAME COMMA NUM
{
	fprintf(fp, "jal %s\n", $2->stringdata);
	if(call_list[0][0]=='f'){
		fprintf(fp,"move.s $%s,$f30\n",call_list[0]);
	}
	else
		fprintf(fp,"move $%s,$v0\n",call_list[0]);
	call_list.clear();
};
statement : RETURN TEMP
{
	strip_first_char($2->stringdata);
	fprintf(fp, "move $v0,$%s\n",$2->stringdata);
};
statement : RETURN FLOAT_TEMP
{
	fprintf(fp, "move.s $f30,$%s\n",$2->stringdata);
};
statement : RETURN INT_VAR
{
	fprintf(fp,"lw $v0,%d($fp)\n",M[$2->stringdata]);
};
statement : RETURN NUM
{
	fprintf(fp, "li $v0,%s\n",$2->stringdata);
};

statement : ARRAY_DECL
{
	
	bool go = false;
	int temp = 0;
	for(int i=0;$1->stringdata[i]!='\0';i++)
	{
		// cout<<$1->stringdata[i];
		if($1->stringdata[i]==']')
			go = false;
		if(go)
		{
			int x = $1->stringdata[i]-'0';
			temp = 10*temp + x;
		}
		if($1->stringdata[i]=='[')
			go = true;
	
	}
	bool k=true;
	string var="";
	printf("name _decl %s\n",$1->stringdata);

	for(int j=0;$1->stringdata[j]!='\0';j++){
		if($1->stringdata[j]=='[')
			k=false;
		if(k){
			printf("** %c\n",$1->stringdata[j]);			
			var=var+$1->stringdata[j];
		}
		if($1->stringdata[j]==']')
			k=true;
	}
	cout<<var<<endl;
	printf("array _decl %d,%s\n",temp,var.c_str());
	int num = temp;
	mem = mem - 4*num;
	M[var]=mem;
};
statement : TEMP ASSIGN ADDR LB INT_VAR RB
{
	strip_first_char($1->stringdata);
	fprintf(fp, "li $%s,%d\n", $1->stringdata,M[$5->stringdata]);
};
statement : TEMP SQL TEMP SQR ASSIGN TEMP
{
	strip_first_char($1->stringdata);
	strip_first_char($3->stringdata);
	strip_first_char($6->stringdata);
	// fprintf(fp, "li $a0,4\n");
	// fprintf(fp, "mul $%s,$%s,$a0\n",$3->stringdata,$3->stringdata);
	fprintf(fp, "add $%s,$%s,$%s\n",$1->stringdata,$1->stringdata,$3->stringdata);
	fprintf(fp, "add $a0,$fp,$%s\n",$1->stringdata);
	fprintf(fp, "sw $%s,0($a0)\n",$6->stringdata);
};
statement : TEMP ASSIGN TEMP SQL TEMP SQR
{
	strip_first_char($1->stringdata);
	strip_first_char($3->stringdata);
	strip_first_char($5->stringdata);
	// fprintf(fp, "li $a0,4\n");
	// fprintf(fp, "mul $%s,$%s,$a0\n",$5->stringdata,$5->stringdata);
	fprintf(fp, "add $%s,$%s,$%s\n",$3->stringdata,$3->stringdata,$5->stringdata);
	fprintf(fp, "add $a0,$fp,$%s\n",$3->stringdata);
	fprintf(fp, "lw $%s,0($a0)\n",$1->stringdata);
};
%%

void strip_first_char(char* a){
	for(int i=0;a[i]!='\0';i++){
		a[i]=a[i+1];
	}
}
int main()
{
	fp=fopen("mips.asm","w");
	fprintf(fp, ".text\n");
	
	ifstream infile("symtab.txt");
	string a;
	int b,c;
	while (infile >> a >> b >>c)
	{

	    cout<<a<<" "<<b<<" "<<c<<endl;
	    func_no_params[a] = b;
	    func_mem_size[a]=c;
	}
	// fp1 = fopen("size.txt","r");
	// string str;
	// while (getline(fp1, str)) {
	//     char* token = strtok(str," ");
	//     func_no_params[token[0]]=atoi(token[1]);
	// }
	yyparse();
	// printf("VALID\n");
}
