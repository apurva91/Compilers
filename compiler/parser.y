%{ 
	#include <bits/stdc++.h>
	#include "main.h"
	using namespace std;

	extern int yylex();
	extern int yyparse();
	extern int yylineno;
	void yyerror(string s);

	Node * root;
	int level = -1;
	SymbolTable symtab;

	vector <Variable *> patch;
	Function * active_func_ptr = NULL;
	vector <string> dimlist;
	int error_count = 0;
	stringstream ic;
	int var_num = 0;
%}

%union{
	Node * node;
}

%token<node> SEMI EQUAL ADD SUB MUL DIV MOD GT LT GE LE EQ NE OR AND LP RP LB RB LS RS COMMA  INT VOID FLOAT FOR WHILE IF ELSE SWITCH CASE DEFAULT BREAK CONTINU RETURN INTEGERS FLOATING_POINTS IDENTIFIER

%type<node> start statements statement decl body ifexp N M function_declaration res_id func_head param_list param param_list_main declaration_list d t l id_arr id_arr_asg dimlist expression sim_exp un_exp dm_exp log_exp and_exp rel_exp op1 op2 op3 term unop

%start start


%define parse.error verbose;

%%

start			:	declaration_list 
					{
						$$ = new Node("start",""); 
						$$->children.push_back($1); 
						root = $$; 
					};

statements		:	statement
					{ $$ = new Node("statements","");$$->children.push_back($1);} 
					|
					statement statements
					{$$ = new Node("statements","");$$->children.push_back($1);$$->children.push_back($2);}
					;

statement		:	d
					{ $$ = new Node("statement","");$$->children.push_back($1);} 
					|
					expression SEMI
					{ $$ = new Node("statement","");$$->children.push_back($1);$$->children.push_back($2);}
					|
					ifexp body N ELSE M body
					|
					ifexp body
					|
					body
					{ $$ = new Node("statement","");$$->children.push_back($1); }
					|
					RETURN id_arr_asg SEMI
					{
						$$ = new Node("statement","");$$->children.push_back($1);$$->children.push_back($2);
						ic<<"return " + $2->var<<endl;
					}
					|
					RETURN INTEGERS SEMI
					{
						$$ = new Node("statement","");$$->children.push_back($1);$$->children.push_back($2);
						ic<<"return " + $2->value<<endl;
					};
ifexp			:	IF expression
					{
						// $$ = new Node("ifexp","");$$->children.push_back($1);$$->children.push_back($2);
						// if($2->data_type == _boolean){

						// }
						// else{
						// 	yyerror("expecting boolean in the condition got " + $2->data_type);
						// }
					};
N				:	{};
M				:	{};

body			:	level_increase LB statements RB
					{
						$$ = new Node("statement","");$$->children.push_back($2);$$->children.push_back($3);$$->children.push_back($4);	
												// symtab.print();
						symtab.decrease_level();
					};
level_increase	:	{
						symtab.increase_level();
					};
declaration_list:	declaration_list decl
					{
						$$ = new Node("declaration_list","");
						$$->children.push_back($1);
						$$->children.push_back($2);
					};
					|
					decl
					{
						$$ = new Node("declaration_list","");
						$$->children.push_back($1);
					};

decl			:	d
					{
						$$ = new Node("decl","");
						$$->children.push_back($1);
					}
					|
					function_declaration					
					{
						$$ = new Node("decl","");
						$$->children.push_back($1);
					};

function_declaration:	func_head body
						{

							symtab.decrease_level();
							active_func_ptr = NULL;
							ic<<"func end"<<endl;

						};

func_head		:	res_id LP param_list_main RP
					{
						$$ = new Node("func_head","");
						$$->children.push_back($1);
						$$->children.push_back($2);
						$$->children.push_back($3);
						$$->children.push_back($4);
					};
param_list_main	:	param_list 
					{
						$$ = new Node("param_list_main","");
						$$->children.push_back($1);
					}
					|
					{
						$$ = new Node("param_list_main","");
					};
param_list 		:	param 
					{
						$$ = new Node("param_list","");
						$$->children.push_back($1);
					}
					| 
					param COMMA param_list
					{
						$$ = new Node("param_list","");
						$$->children.push_back($1);
						$$->children.push_back($2);
						$$->children.push_back($3);
					};

res_id			:	t IDENTIFIER
					{
						$$ = new Node("res_id","");
						$$->children.push_back($1);
						$$->children.push_back($2);
						Function * fnptr = symtab.search_function($2->value);
						if(fnptr){
							yyerror("Function Already Declared");
						}
						else{
							active_func_ptr = symtab.enter_func($2->value,$1->data_type);
						}
						symtab.increase_level();
						ic<<"func begin "<<$2->value<<endl;
					};
param			:	t IDENTIFIER
					{
						$$ = new Node("param","");
						$$->children.push_back($1);
						$$->children.push_back($2);
						if(active_func_ptr!=NULL){
							if(active_func_ptr->search_param($2->value)){
								yyerror("Parameter already declared");
							}
							else{
								active_func_ptr->enter_param($2->value,_simple,$1->data_type);
							}
						}
					};
d				:	t l SEMI
					{
						$$ = new Node("d","");
						$$->children.push_back($1);
						$$->children.push_back($2);
						$$->children.push_back($3);
						for(int i=0; i<patch.size(); i++){
							patch[i]->eletype = $1->data_type;
						}
						patch.clear();
					};
t				:	INT
					{
						$$ = new Node("t",$1->value);
						$$->children.push_back($1);
						$$->data_type = _integer;
					} 
					|
					FLOAT 
					{
						$$ = new Node("t",$1->value);
						$$->children.push_back($1);
						$$->data_type = _real;
					};
l				:	id_arr
					{
						$$ = new Node("l","");
						// $$->children.push_back($1);
					}
					|
					id_arr COMMA l
					{
						$$ = new Node("l","");
						$$->children.push_back($1);
						$$->children.push_back($2);
						$$->children.push_back($3);
					};
id_arr			: 	IDENTIFIER
					{
						$$ = new Node("id_arr",$1->value);
						$$->children.push_back($1);
						Variable * ptr = symtab.search_var($1->value, level);
						if(ptr&&ptr->level==level){
							yyerror("Variable already declared in current scope");
						}
						else if(ptr&&level==2&&ptr->level==1){
							yyerror("Cant redeclare parameter in this scope");
						}
						else{
							ptr = symtab.enter_var($1->value,_simple,_none);
							patch.push_back(ptr);
						}
					} 
					|
					IDENTIFIER LS dimlist RS
					{
						$$ = new Node("id_arr",$1->value);
						$$->children.push_back($1);
						$$->children.push_back($2);
						$$->children.push_back($3);
						$$->children.push_back($4);
						Variable * ptr = symtab.search_var($1->value, level);
						if(ptr&&ptr->level==level){
							yyerror("Variable already declared in current scope");
						}
						else if(ptr&&level==2&&ptr->level==1){
							yyerror("Cant redeclare parameter in this scope");
						}
						else{
							ptr = symtab.enter_var($1->value,_simple,_none);
							ptr->dimlist = dimlist;
							dimlist.clear();
							patch.push_back(ptr);
						}
					};
dimlist			:	INTEGERS
					{ 
						$$ = new Node("dimlist","");
						$$->children.push_back($1);
						// if($1->data_type!=_integer){
						// 	yyerror("Arrays can only be indexed using integers.");
						// }
						// ic<<get_var()<<" = "<<$1->var<<endl;
						// dimlist.insert(dimlist.begin(),(get_curr_var()));
						dimlist.insert(dimlist.begin(),$1->value);

					} 
					| 
					INTEGERS COMMA dimlist
					{
						$$ = new Node("dimlist",""); 
						$$->children.push_back($1);
						$$->children.push_back($2);
						$$->children.push_back($3);
						// if($1->data_type!=_integer){
						// 	yyerror("Arrays can only be indexed using integers.");
						// }
						// ic<<get_var()<<" = "<<$1->var<<endl;
						// dimlist.insert(dimlist.begin(),(get_curr_var()));
						dimlist.insert(dimlist.begin(),$1->value);
					};
//variable or an array element assigned an expression
//						
expression		:	id_arr_asg EQUAL expression
					{
						$$ = new Node("expression","=");
						$$->children.push_back($1);
						$$->children.push_back($2);
						$$->children.push_back($3);
						if($1->data_type==_error || $3->data_type==_error){
								$$->data_type = _error;
						}
						else{
							Variable * ptr = symtab.search_var($1->value,level);
							if(ptr){
								$$->data_type = ptr->eletype;
								ic<<$1->var<<" = "<<$3->var<<endl;
								$$->var = $3->var; 
								if(get_type(ptr->eletype, $3->data_type)==_error){
									yyerror("Mismatching datatypes of LHS and RHS: " + _type[$1->data_type] + " and " + _type[$3->data_type]);
									$$->data_type = _error;
								}
							}
						}
					}					
					|
					log_exp
					{
						$$ = new Node("expression","");
						$$->data_type = $1->data_type;
						$$->children.push_back($1);		
						$$->var = $1->var;				
					};

id_arr_asg			: 	IDENTIFIER
					{
						$$ = new Node("id_arr",$1->value);
						$$->children.push_back($1);
						$$->var = "$" + $1->value;						
						Variable * ptr = symtab.search_var($1->value, level);
						if(ptr==NULL){
							yyerror("Variable \033[1;31m" + $1->value + "\033[0m not declared.");
							$$->data_type = _error;
						}
						else{
							$$->data_type = ptr->eletype;
							if(ptr->level!=0) $$->var+="$" + active_func_ptr->id + "$" + to_string(ptr->level);
						}

					} 
					|
					IDENTIFIER LS dimlist RS
					{
						$$ = new Node("id_arr",$1->value);
						$$->children.push_back($1);
						$$->children.push_back($2);
						$$->children.push_back($3);
						$$->children.push_back($4);
						Variable * ptr;
						string ht = "";

						ptr = symtab.search_var($1->value,level);
						if(ptr&&ptr->level!=0) ht += "$" + active_func_ptr->id + "$" + to_string(ptr->level);

						if(ptr==NULL){
							yyerror("Variable \033[1;31m" + $1->value + "\033[0m not declared.");							
							$$->data_type = _error;
						}
						else{
							$$->data_type = ptr->eletype;
							if(ptr->dimlist.size()!=dimlist.size()){
								yyerror("Variable \033[1;31m" + $1->value + "\033[0m unmatching dimensions.");
								
								$$->data_type = _error;
							}
							else{	
								string tv = get_var();
								string addr = tv;
								ic<<tv<<" = addr($" + $1->value +ht +")"<<endl;
								tv = dimlist[0];
								for(int i=1; i<ptr->dimlist.size(); i++){
									ic<<get_var()<<" = "<< tv <<" * "<<ptr->dimlist[i]<<endl;
									tv = get_curr_var();
									ic<<get_var()<<" = "<<tv<<" + "<<dimlist[i]<<endl;
									tv = get_curr_var();
								}
								int size = 4;
								if(ptr->eletype==_real) size = 8;
								
								ic<<get_var() + " = " + tv + " * " + to_string(size)<<endl;
								tv = get_curr_var();
								$$->var = addr + "[" + tv + "]";
							}
							dimlist.clear();
						}
					};

log_exp 		:	log_exp OR and_exp
					{
						$$ = new Node("log_exp","or");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);
						if($1->data_type!=_error&&$3->data_type!=_error){	
							if(get_type($1->data_type,$3->data_type)==_error){
								yyerror("Mismatch in datatype while comparision " + $$->value);
								$$->data_type = _error;
							}
							else{
								$$->data_type = _boolean;
								$$->var = get_var();
								ic<<$$->var<<" = "<<$1->var<<" "<<$2->value<<" "<<$3->var<<endl;	
							}
						}
						else{
								$$->data_type = _error;
						}

					}
					| 
					and_exp
					{
						$$ = new Node("log_exp","");$$->children.push_back($1);
						$$->data_type = $1->data_type;
						$$->var = $1->var;
					};

and_exp 		:	and_exp AND rel_exp
					{
						$$ = new Node("and_exp","and");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);
						if($1->data_type!=_error&&$3->data_type!=_error){	
							if(get_type($1->data_type,$3->data_type)==_error){
								yyerror("Mismatch in datatype while comparision " + $$->value);
								$$->data_type = _error;
							}
							else{
								$$->data_type = _boolean;
								$$->var = get_var();
								ic<<$$->var<<" = "<<$1->var<<" "<<$2->value<<" "<<$3->var<<endl;
							}
						}
						else{
								$$->data_type = _error;
						}
						
					}
					|
					rel_exp
					{
						$$ = new Node("and_exp","");$$->children.push_back($1);
						$$->data_type = $1->data_type;
						$$->var = $1->var;

					};

rel_exp 		:	rel_exp op3 sim_exp
					{
						$$ = new Node("rel_exp","op");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);
						if($1->data_type!=_error&&$3->data_type!=_error){	
							if(get_type($1->data_type,$3->data_type)==_error){
								yyerror("Mismatch in datatype while comparision " + $$->value);
								$$->data_type = _error;
							}
							else{
								$$->data_type = _boolean;
								Type tt = get_type($1->data_type, $3->data_type);
								if(tt == _integer || tt == _real){
									$$->data_type = tt;
									if($1->data_type==$3->data_type){
										$$->var = get_var();
										ic<<$$->var<<" = "<<$1->var<<" "<<$2->value<<" "<<$3->var<<endl;
									}
									else{
										if($1->data_type==_real){
											string tv = get_var();
											ic<<tv<<" = cnvrt_float("<<$1->var<<")\n";
											$$->var = get_var();
											ic<<$$->var<<" = "<<tv<<" "<<$2->value<<" "<<$3->var<<endl;
										}
										else{
											string tv = get_var();
											ic<<tv<<" = cnvrt_float("<<$3->var<<")\n";
											$$->var = get_var();
											ic<<$$->var<<" = "<<$1->var<<" "<<$2->value<<" "<<tv<<endl;
										}
									}
								}

							}
						}
						else{
								$$->data_type = _error;
						}
					}
					|
					sim_exp
					{
						$$ = new Node("rel_exp","");$$->children.push_back($1);
						$$->data_type = $1->data_type;
						$$->var = $1->var;
						
					};

sim_exp 		:	sim_exp op1 dm_exp
					{
						$$ = new Node("sim_exp",$1->value + $2->value + $3->value);$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);
						if($1->data_type!=_error&&$3->data_type!=_error){	
							Type tt = get_type($1->data_type, $3->data_type);
							if(tt == _integer || tt == _real){
								$$->data_type = tt;
								if($1->data_type==$3->data_type){
									$$->var = get_var();
									ic<<$$->var<<" = "<<$1->var<<" "<<$2->value<<" "<<$3->var<<endl;
								}
								else{
									if($1->data_type==_real){
										string tv = get_var();
										ic<<tv<<" = cnvrt_float("<<$1->var<<")\n";
										$$->var = get_var();
										ic<<$$->var<<" = "<<tv<<" "<<$2->value<<" "<<$3->var<<endl;
									}
									else{
										string tv = get_var();
										ic<<tv<<" = cnvrt_float("<<$3->var<<")\n";
										$$->var = get_var();
										ic<<$$->var<<" = "<<$1->var<<" "<<$2->value<<" "<<tv<<endl;
									}
								}
							}
							else{
								yyerror("Mismatch in datatype while operation " + $$->value);
								$$->data_type = _error;
							} 
						}
						else{
								$$->data_type = _error;
						}

					}
					|
					dm_exp
					{
						$$ = new Node("sim_exp",$1->value);$$->children.push_back($1);
						$$->var = $1->var;
						if($1->data_type == _integer || $1->data_type == _real) $$->data_type = $1->data_type;
						else $$->data_type = _error; 

					};

dm_exp 			: 	dm_exp op2 un_exp
					{
						$$ = new Node("dm_exp",$1->value + $2->value + $3->value);$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);
						if($1->data_type!=_error&&$3->data_type!=_error){	
							Type tt = get_type($1->data_type, $3->data_type);
							if(tt == _integer || tt == _real){
								$$->data_type = tt;
								if($1->data_type==$3->data_type){
									$$->var = get_var();
									ic<<$$->var<<" = "<<$1->var<<" "<<$2->value<<" "<<$3->var<<endl;
								}
								else{
									if($1->data_type==_real){
										string tv = get_var();
										ic<<tv<<" = cnvrt_float("<<$1->var<<")\n";
										$$->var = get_var();
										ic<<$$->var<<" = "<<tv<<" "<<$2->value<<" "<<$3->var<<endl;
									}
									else{
										string tv = get_var();
										ic<<tv<<" = cnvrt_float("<<$3->var<<")\n";
										$$->var = get_var();
										ic<<$$->var<<" = "<<$1->var<<" "<<$2->value<<" "<<tv<<endl;
									}
								}
							}
							else{
								yyerror("Mismatch in datatype while operation " + $$->value);
								$$->data_type = _error;
							} 
						}
						else{
								$$->data_type = _error;
						}

					}
					|
				 	un_exp
					{
						$$ = new Node("dm_exp",$1->value);$$->children.push_back($1);
							$$->var = $1->var;
						if($1->data_type == _integer || $1->data_type == _real){
							$$->data_type = $1->data_type;
						}
						else $$->data_type = _error; 

					};

un_exp 			: 	unop term
					{
						$$ = new Node("un_exp",$1->value + $2->value);$$->children.push_back($1);$$->children.push_back($2);
						$$->var = get_var();
						ic<<$$->var<<" = "<<$1->value<<" "<<$2->var<<endl;
						if($1->data_type == _integer || $1->data_type == _real){
							$$->data_type = $1->data_type;
						}
						else if($1->data_type == _boolean){
							yyerror("Mismatch in datatype expecting integer or real got boolean. " + $$->value);
							$$->data_type = _error;
						}
						else $$->data_type = _error; 

					}
					|
					term
					{
						$$ = new Node("un_exp",$1->value);$$->children.push_back($1);
						$$->var = $1->var;
						
						if($1->data_type == _integer || $1->data_type == _real){
							$$->data_type = $1->data_type;
						}
						else if($1->data_type == _boolean){
							yyerror("Mismatch in datatype expecting integer or real got boolean. " + $$->value);
							$$->data_type = _error;
							
						}
						else $$->data_type = _error; 
					};

op1 			: 	ADD
					{
						$$ = new Node("op1", "+");$$->children.push_back($1);
					}
					| 
					SUB
					{
						$$ = new Node("op1", "-");$$->children.push_back($1);
					};

op2 			: 	MUL
						{$$ = new Node("op2", "*");$$->children.push_back($1);}
					|
					DIV
					{
						$$ = new Node("op2", "/");$$->children.push_back($1);
					}
					|
					MOD
					{
						$$ = new Node("op2", "%");$$->children.push_back($1);
					};

op3 			: 	GT
					{
						$$ = new Node("op3", ">");$$->children.push_back($1);
					}
					|
					LT
					{
						$$ = new Node("op3", "<");$$->children.push_back($1);
					}
					|
					GE
					{
						$$ = new Node("op3", ">=");$$->children.push_back($1);
					}
					|
					LE
					{
						$$ = new Node("op3", "<=");$$->children.push_back($1);
					}
					|
					EQ
					{
						$$ = new Node("op3", "==");$$->children.push_back($1);
					}
					|
					NE
					{
						$$ = new Node("op3", "!=");$$->children.push_back($1);
					};

unop 			:	SUB
					{
						$$ = new Node("unop", "-");$$->children.push_back($1);
					}
					|
					ADD
					{
						$$ = new Node("unop", "+");$$->children.push_back($1);
					};

term 			:	LP expression RP
					{
						$$ = new Node("term","");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);
						$$->data_type = $2->data_type;
						$$->var = $2->var;
					}
					|
					INTEGERS
					{	
						$$ = new Node("term",$1->value);$$->children.push_back($1);
						$$->data_type = _integer;
						$$->var = $1->value;
					}
					|
					id_arr_asg
					{
						$$ = new Node("term",$1->value);$$->children.push_back($1);
						Variable * ptr = symtab.search_var($1->value,level);
						if(ptr){
							$$->data_type = ptr->eletype;
						}
						else{
							$$->data_type = _error;
						}
						$$->var = $1->var;	
					};
%%

bool syntax_success = true;

void yyerror(string s){
	cerr<<"Line Number \033[1;31m" << yylineno <<"\033[0m : "<<s<<endl;
	error_count++;
	syntax_success = false;
}


vector<bool> tree_line;
fstream tree_file;
void printTree(Node *tree, string term) {
	if(tree == NULL){
		return;
	}
	for(int j = 1; j <= 2 ; j++){
		for (int i = 0; i < (int)(tree_line.size() - 1); i++) {
			if(tree_line.at(i)){
				tree_file << "|\t\t";
			} else {
				tree_file << "\t\t";
			}
		}
		if(j == 1){
			tree_file<<"|"<<endl;
		}
	}
	if(!tree_line.empty()){
		tree_file << term;
	}
	tree_file << tree->type;
	if(tree->value != "") {
		tree_file << "[" << tree->value << "]";
	}
		tree_file << "[" << _type[tree->data_type] << "]";
		tree_file << "[" << tree->var << "]";
	tree_file << endl;
	if(tree->children.size() > 3){
		tree_line.push_back(true);
		printTree(tree->children[3], term);
		tree_line.pop_back();
	}
	if(tree->children.size() > 2){
		tree_line.push_back(true);
		printTree(tree->children[2], term);
		tree_line.pop_back();
	}
	if(tree->children.size() > 1){
		tree_line.push_back(true);
		printTree(tree->children[1], term);
		tree_line.pop_back();
	}
	if(tree->children.size() > 0){
		tree_line.push_back(false);
		printTree(tree->children[0], term);
		tree_line.pop_back();
	}
}

int yywrap(){}

int main(){
	yyparse();
	cout<<"Total Errors: "<<error_count<<endl;
	if(syntax_success){
		symtab.print();
		cout<<ic.str();
	}
	tree_file.open("tree.txt",fstream::out);
	printTree(root,"\\___");
	tree_file.close();
	return 0;
}
