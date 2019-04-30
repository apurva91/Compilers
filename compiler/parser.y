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
	vector < pair < string , Type > > params;
	Function * active_func_ptr = NULL;
	Function * call_func_ptr = NULL;
	vector <string> dimlist;
	int error_count = 0;
	stringstream ic;
	int var_num = 0;
	map < int , int > patch_list;
	map <int , int> patch_listf;
	// vector <pair <int , vector <  int > > > patch_list;
	int loop_count = 0;
	vector < vector <int>  > breaks;
	vector < vector <int>  > continues;
	vector < vector <string>  > case_lists;
	vector < int  > case_defs;
	int loopc = 0;
	int bytes = 0;
	int bytes_g = 0; 
	stringstream xyz;
	vector < pair < string , bool > > int_pool = {make_pair("it0",true),make_pair("it1",true),make_pair("it2",true),make_pair("it3",true),make_pair("it4",true),make_pair("it5",true),make_pair("it6",true),make_pair("it7",true),make_pair("it8",true),make_pair("it9",true)};
	vector < pair < string , bool > > float_pool = {make_pair("f0",true),make_pair("f1",true),make_pair("f2",true),make_pair("f3",true),make_pair("f4",true),make_pair("f5",true),make_pair("f6",true),make_pair("f7",true),make_pair("f8",true),make_pair("f9",true)};
	int int_pool_curr = -1;
	int float_pool_curr = -1;
%}

%union{
	Node * node;
}

%token<node> SEMI EQUAL ADD SUB MUL DIV MOD GT LT GE LE EQ NE OR NOT  NEWLINE AND LP RP MAIN LB RB LS RS COLON LIBRARIES COMMA  INT VOID FLOAT FOR WHILE IF ELSE SWITCH CASE DEFAULT BREAK CONTINUE RETURN INTEGERS FLOATING_POINTS IDENTIFIER 

%type<node> start statements statement decl body intializer libraries switchexp dimlist_var switch_body case_st case_list case_label case_labels INIT paramslist_main paramslist condition post_loop forexp level_increase whileexp ifexp N M function_declaration res_id func_head param_list param param_list_main declaration_list d t l id_arr id_arr_asg dimlist expression sim_exp un_exp dm_exp log_exp and_exp rel_exp op1 op2 op3 term unop

%start start


%define parse.error verbose;

%%

start			:	libraries declaration_list INT MAIN LP RP INIT body
					{
						$$ = new Node("start","");  
						$$->children.push_back($2); 
						// $$->children.push_back($3); 
						// $$->children.push_back($4); 
						// $$->children.push_back($5); 
						// $$->children.push_back($6); 
						// $$->children.push_back($7); 
						$$->children.push_back($8); 
						root = $$; 
						string s = ic.str();
						patch_quad(count(s.begin(),s.end(),'\n'),$8->quadlist);
						symtab.decrease_level();
						active_func_ptr->size = bytes;
						bytes = bytes_g;
						active_func_ptr = NULL;
						ic<<"func end"<<endl;

					};
INIT			: 	{
						$$ = new Node("INIT","");
						Function * fnptr = symtab.search_function("main");
						if(fnptr){
							yyerror("Function main Already Declared");
						}
						else{
							active_func_ptr = symtab.enter_func("main",_integer);
						}
						symtab.increase_level();
						bytes_g = bytes;
						bytes = 0;
						ic<<"func begin main"<<endl;
					};

libraries		:	{}
					|
					LIBRARIES libraries
					{};
statements		:	statement
					{ $$ = new Node("statements","");$$->children.push_back($1); 
					// $$->quadlist = $1->quadlist; 
					} 
					|
					statement statements
					{$$ = new Node("statements","");$$->children.push_back($1);$$->children.push_back($2);
						// string s = ic.str();
						// patch_quad(count(s.begin(),s.end(),'\n'), $1->quadlist);
						// $$->quadlist = $1->quadlist;
						// patch_quad(*min_element($2->quadlist.begin(),$2->quadlist.end()), $1->quadlist);
						// $$->quadlist.insert($$->quadlist.end(), $2->quadlist.begin(), $2->quadlist.end());
					};
statement		:	d
					{
						$$ = new Node("statement","");$$->children.push_back($1);
					} 
					|
					expression SEMI
					{

						$$ = new Node("statement","");$$->children.push_back($1);$$->children.push_back($2);
						if($1->var.rfind("_term",0)==0){
							yyerror("Invalid syntax, just a term mentioned");
						}
						itv($1->var);
						if($1->var.back()==']'){		
							itv(split($1->var,"[")[0]);
							itv(split(split($1->var,"[")[1],"]")[0]);
						}
					}
					|
					ifexp body N ELSE M body
					{ 
						$$ = new Node("statement","");
						$$->children.push_back($1);
						$$->children.push_back($2);
						$$->children.push_back($3);
						$$->children.push_back($4);
						$$->children.push_back($5);
						$$->children.push_back($6);
						// $$->quadlist = $2->quadlist;
						// $$->quadlist.insert($$->quadlist.end(), $3->quadlist.begin(), $3->quadlist.end());
						// $$->quadlist.insert($$->quadlist.end(), $6->quadlist.begin(), $6->quadlist.end());
						patch_quad($5->quadlist[0],$1->falselist);
						string s = ic.str();
						patch_quad(count(s.begin(),s.end(),'\n'),$3->quadlist);
					}
					|
					ifexp body
					{
						$$ = new Node("statement","");
						$$->children.push_back($1);
						$$->children.push_back($2);
						$$->quadlist = $2->quadlist;
						$$->quadlist.insert($$->quadlist.end(), $1->falselist.begin(), $1->falselist.end());
						string s = ic.str();
						patch_quad_force(count(s.begin(),s.end(),'\n'),$1->falselist);
						// patch_quad_force(count(s.begin(),s.end(),'\n'),$1->quadlist);
						// $$->falselist = $3->falselist;

					}
					|
					BREAK SEMI
					{
						$$ = new Node("statement","");
						$$->children.push_back($1);
						$$->children.push_back($2);
						if(loop_count==0){
							yyerror("Illegal use of break statement.");
						}
						else{
							string s = ic.str();
							breaks[loop_count-1].push_back(count(s.begin(),s.end(),'\n'));
							ic<<"goto "<<endl;
						}
					}
					|
					CONTINUE SEMI
					{
						$$ = new Node("statement","");
						$$->children.push_back($1);
						$$->children.push_back($2);
						if(loopc==0){
							yyerror("Illegal use of continue statement.");
						}
						else{
							string s = ic.str();
							continues[loop_count-1].push_back(count(s.begin(),s.end(),'\n'));
							ic<<"goto "<<endl;
						}
					}
					|
					body
					{
						$$ = new Node("statement","");$$->children.push_back($1);
					}
					|
					RETURN expression SEMI
					{
						$$ = new Node("statement","");$$->children.push_back($1);$$->children.push_back($2);
						if(active_func_ptr->return_type==$2->data_type){
							if(!itcv($2->var)){
								if(active_func_ptr->return_type==_integer){
									ic<<giv()<<" = "<<$2->var<<endl;
									$2->var =gicv();
								}
								if(active_func_ptr->return_type==_real){
									ic<<gfv()<<" = "<<$2->var<<endl;
									$2->var =gfcv();
								}
							}
							ic<<"return " + $2->var<<endl;
							itv($2->var);
						}
						else if(active_func_ptr->return_type==_real&&$2->data_type==_integer){
							ic<<gfv()<<" = cnvrt_to_float(" + $2->var + ")"<<endl;
							ic<<"return " + gfcv()<<endl;
							itv($2->var);
						}
						else if(active_func_ptr->return_type==_integer&&$2->data_type==_real){
							ic<<giv()<<" = cnvrt_to_int(" + $2->var + ")"<<endl;
							ic<<"return " + gicv()<<endl;
							itv($2->var);
						}
						else{
							yyerror("Returning illegal data type");
						}
					}
					|
					whileexp body
					{
						$$ = new Node("statement","");$$->children.push_back($1);$$->children.push_back($2);
						string s = ic.str();
						int x = count(s.begin(),s.end(),'\n');
						patch_list[x] = stoi($1->var);
						ic<<"goto "<<endl;
						s = ic.str();
						patch_quad(count(s.begin(),s.end(),'\n'),$1->falselist);
						loop_count--;
						patch_quad(count(s.begin(),s.end(),'\n'),breaks.back());
						patch_quad(patch_list[x],continues.back());
						breaks.pop_back();
						continues.pop_back();
						case_defs.pop_back();
						case_lists.pop_back();
						loopc--;
					}
					|
					forexp body
					{
						$$ = new Node("statement","");$$->children.push_back($1);$$->children.push_back($2);

						vector <int> temp (1);
						string s = ic.str();
						temp[0] = count(s.begin(),s.end(),'\n');
						ic<<"goto "<<endl;
						patch_quad($1->quadlist[0],temp);
						// temp[0] = $1->quadlist[0]; 
						patch_quad(count(s.begin(),s.end(),'\n')+1,$1->falselist);
						patch_quad(count(s.begin(),s.end(),'\n')+1,breaks.back());
						patch_quad($1->quadlist[0],continues.back());
						breaks.pop_back();
						continues.pop_back();
						loop_count--;
						case_defs.pop_back();
						case_lists.pop_back();
						loopc--;
					}
					|
					switchexp switch_body
					{
						$$ = new Node("statement","");$$->children.push_back($1);$$->children.push_back($2);
						$$->quadlist = $1->quadlist;
						$$->quadlist.insert($$->quadlist.end(), $2->quadlist.begin(), $2->quadlist.end());

						string s = ic.str();
						// cout<<$$->quadlist<<endl;
						// cout<<case_lists[loop_count-1]<<endl;
						for(int i=0; i<$$->quadlist.size()-1; i++){
							vector <string> tk = split(case_lists[loop_count-1][i],"&");
							for(int j=0; j<tk.size(); j++){
								s = ic.str();
								if(i==0&&j==0) patch_listf[$$->quadlist[0]-1] = count(s.begin(),s.end(),'\n');		
								patch_listf[count(s.begin(),s.end(),'\n')] = $$->quadlist[i];
								if(tk[j]!="default")ic<<"if "<<$1->var<<" == "<<tk[j]<<" goto "<<endl;
								else ic<<"goto "<<endl;
							}
						}
						if(continues[loop_count-1].size()!=0) {
							continues[loop_count-1-1].insert(continues[loop_count-1-1].end(),continues[loop_count-1].begin(), continues[loop_count-1].end());
						}
						s = ic.str();
						patch_quad(count(s.begin(),s.end(),'\n'),breaks[loop_count-1]);
						symtab.decrease_level();
						breaks.pop_back();
						continues.pop_back();
						loop_count--;
						case_defs.pop_back();
						case_lists.pop_back();
						itv($1->var);

					}
					|
					error SEMI
					{
						$$ = new Node("statement","");$$->children.push_back($2);
					};
switchexp		:	SWITCH LP expression RP
					{
						breaks.push_back(vector <int> (0));
						continues.push_back(vector <int> (0));
						loop_count++;
						case_defs.push_back(0);
						case_lists.push_back(vector <string> (0));
						symtab.increase_level();
						ic<<"goto "<<endl;
						string s = ic.str();

						$$->quadlist.push_back(count(s.begin(),s.end(),'\n'));
						$$->var = $3->var;

					};
switch_body		:	LB case_list RB
					{
						$$ = new Node("switch_body","");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);
						string s = ic.str();
						$$->quadlist = $2->quadlist;

					};
case_list		:	case_st case_list
					{
						$$ = new Node("case_list","");$$->children.push_back($1);$$->children.push_back($2);;
						$$->quadlist = $1->quadlist;
						$$->quadlist.insert($$->quadlist.end(), $2->quadlist.begin(), $2->quadlist.end());
					}
					|
					case_st
					{
						$$ = new Node("case_list","");$$->children.push_back($1);;
						$$->quadlist = $1->quadlist;
					};
case_st			:	case_labels statements
					{
						$$ = new Node("case_st","");$$->children.push_back($1);$$->children.push_back($2);;
						case_lists[loop_count-1].push_back($1->var);
						string s = ic.str();

						$$->quadlist.push_back(count(s.begin(),s.end(),'\n'));

					};
case_labels		:	case_label
					{

						$$ = new Node("case_labels","");$$->children.push_back($1);
						$$->var = $1->var;
					}
					|
					case_label case_labels
					{
						$$ = new Node("case_labels","");$$->children.push_back($1);$$->children.push_back($2);;
						$$->var = $1->var + "&" + $2->var;
					};
case_label		:	CASE INTEGERS COLON
					{
						$$ = new Node("case_label","");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);
						$$->var = $2->value;
					}
					|
					DEFAULT COLON
					{
						$$ = new Node("case_label","");$$->children.push_back($1);$$->children.push_back($2);
						$$->var = $1->value;
						case_defs[loop_count-1]++;

						if(case_defs[loop_count-1]>1){
							yyerror("cannot use multiple defaults");
						}
						// $$->var
						// if(case_def){
						// 	yyerror("Already a default case declared.");
						// }
						// else case_def = true;
					};


forexp			:	FOR LP intializer condition post_loop RP
					{
						$$ = new Node("forexp","");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);$$->children.push_back($4);$$->children.push_back($5);		
						vector <int> temp (1);
						temp[0] = $5->quadlist[0];
						


						$$->falselist = $4->falselist;
						$$->quadlist = $4->quadlist;
						
						string s = ic.str(); 
						// temp[0] = $4->quadlist[1];
						patch_quad(count(s.begin(),s.end(),'\n'),$4->truelist);

						temp[0] = $5->quadlist[0];
						patch_quad($3->quadlist[0],temp);
						breaks.push_back(vector <int> (0));
						continues.push_back(vector <int> (0));
						case_defs.push_back(0);
						case_lists.push_back(vector <string> (0));
						loop_count++;
						loopc++;

					};

intializer		:	expression SEMI
					{
						$$ = new Node("intializer","");$$->children.push_back($1);$$->children.push_back($2);
						string s = ic.str();
						$$->quadlist.push_back(count(s.begin(),s.end(),'\n'));
						if($1->var.rfind("_term",0)==0){
							yyerror("Invalid syntax, just a term mentioned");
						}
						itv($1->var);

					};
condition		:	expression SEMI
					{

						$$ = new Node("condition","");$$->children.push_back($1);$$->children.push_back($2);
						// string s = ic.str();
						// $$->quadlist.push_back(count(s.begin(),s.end(),'\n'));
						// ic<<"if "<<$1->var<<" <= 0 goto "<<endl;
						// s = ic.str();
						// $$->quadlist.push_back(count(s.begin(),s.end(),'\n'));
						// ic<<"goto "<<endl;
						$$->falselist = $1->falselist;
						$$->truelist = $1->truelist;
						string s = ic.str();
						$$->quadlist.push_back(count(s.begin(),s.end(),'\n'));
						if($1->data_type!=_boolean){
							yyerror("expecting boolean in the condition got " + $1->data_type);
						}
					};
post_loop		:	expression
					{
						$$ = new Node("post_loop","");$$->children.push_back($1);
						string s = ic.str();
						$$->quadlist.push_back(count(s.begin(),s.end(),'\n'));
						ic<<"goto "<<endl;
						if($1->var.rfind("_term",0)==0){
							yyerror("Invalid syntax, just a term mentioned");
						}
						itv($1->var);


					};
whileexp		:	WHILE M LP expression RP
					{
						$$ = new Node("whileexp","");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);$$->children.push_back($4);$$->children.push_back($5);					
							if($4->data_type == _boolean){
								string s = ic.str();
								$$->quadlist.push_back(count(s.begin(),s.end(),'\n'));
								$$->falselist = $4->falselist;
								patch_quad_force($$->quadlist.back(), $4->truelist);
								$$->var = to_string($2->quadlist[0]);
								// ic<<"if "<<$4->var<<" <= 0 goto "<<endl;
							}
							else{
								yyerror("expecting boolean in the condition got " + $4->data_type);
							}
							breaks.push_back(vector <int> (0));
							continues.push_back(vector <int> (0));
							loop_count++;
							case_defs.push_back(0);
							case_lists.push_back(vector <string> (0));
							loopc++;



					};
ifexp			:	IF LP expression RP
					{
						$$ = new Node("ifexp","");$$->children.push_back($1);
						$$->children.push_back($2);
						$$->children.push_back($3);
						$$->children.push_back($4);
						if($3->data_type == _boolean){
							string s = ic.str();
							$$->quadlist.push_back(count(s.begin(),s.end(),'\n'));
							// cout<<$$->quadlist.back()<<endl;
							// ic<<"if "<<$3->var<<" <= 0 goto "<<endl;
							patch_quad_force($$->quadlist.back(), $3->truelist);
							$$->falselist = $3->falselist;
						}
						else{
							yyerror("expecting boolean in the condition got " + $2->data_type);
						}
					};
N				:	{
						$$ = new Node("N","");
						string s = ic.str();
						$$->quadlist.push_back(count(s.begin(),s.end(),'\n'));
						ic<<"goto "<<endl;

					};
M				:	{
						$$ = new Node("M","");
						string s = ic.str();
						$$->quadlist.push_back(count(s.begin(),s.end(),'\n'));
					};

body			:	level_increase LB statements RB
					{
						$$ = new Node("body","");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);$$->children.push_back($4);	
												// symtab.print();
						symtab.decrease_level();
					};
level_increase	:	{
						$$ = new Node("level_increase","");
						symtab.increase_level();
					};
declaration_list:	declaration_list decl
					{
						$$ = new Node("declaration_list","");
						$$->children.push_back($1);
						$$->children.push_back($2);
					};
					|
					
					{
						$$ = new Node("declaration_list","");
						// $$->children.push_back($1);
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
							$$ = new Node("function_declaration","");
							$$->children.push_back($1);
							$$->children.push_back($2);
							string s = ic.str();
							// cout<<$2->quadlist;
							patch_quad(count(s.begin(),s.end(),'\n'),$2->quadlist);
							active_func_ptr->size = bytes;
							bytes = bytes_g;
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
						bytes_g = bytes;
						bytes = 0;
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
						// if($1->data_type==_integer) bytes+=int_size;
						// else if($1->data_type==_real) bytes+=float_size;
					};
d				:	t l SEMI
					{
						$$ = new Node("d","");
						$$->children.push_back($1);
						$$->children.push_back($2);
						$$->children.push_back($3);
						for(int i=0; i<patch.size(); i++){
							if(patch[i]->type==_array){
								if($1->data_type==_real) ic<<"f.";
								if($1->data_type==_integer) ic<<"i.";
									int prod = 1;
									for(int j=0; j<patch[i]->dimlist.size(); j++){
										prod*=stoi(patch[i]->dimlist[j]);
									}
									if($1->data_type==_integer) bytes+=prod*int_size;
									else if($1->data_type==_real) bytes+=prod*float_size;

									ic<<patch[i]->id<<"["<<prod<<"]";
								if(level!=0) ic<<"." + to_string(level) + "." + active_func_ptr->id;
								else ic<<".0.0";
								ic<<endl;
							}
							else{
								if($1->data_type==_integer) bytes+=int_size;
								else if($1->data_type==_real) bytes+=float_size;
							}
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
							ptr = symtab.enter_var($1->value,_array,_none);
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
						// dimlist.insert(dimlist.begin(),$1->value);
						dimlist.push_back($1->value);

					} 
					| 
					dimlist RS LS INTEGERS
					{
						$$ = new Node("dimlist",""); 
						$$->children.push_back($1);
						// $$->children.push_back($2);
						$$->children.push_back($4);
						// if($1->data_type!=_integer){
						// 	yyerror("Arrays can only be indexed using integers.");
						// }
						// ic<<get_var()<<" = "<<$1->var<<endl;
						// dimlist.insert(dimlist.begin(),(get_curr_var()));
						dimlist.push_back($4->value);
					};

dimlist_var			:	expression
					{ 
						$$ = new Node("dimlist","");
						$$->children.push_back($1);
						if($1->data_type!=_integer){
							yyerror("Arrays can only be indexed using integers.");
						}
						// ic<<get_var()<<" = "<<$1->var<<endl;
						// dimlist.insert(dimlist.begin(),(get_curr_var()))
						dimlist.push_back($1->var);
						// 
						// dimlist.insert(dimlist.begin(),$1->value);

					} 
					| 
					dimlist_var RS LS expression
					{
						$$ = new Node("dimlist",""); 
						$$->children.push_back($1);
						// $$->children.push_back($2);
						$$->children.push_back($4);
						if($4->data_type!=_integer){
							yyerror("Arrays can only be indexed using integers.");
						}
						// ic<<get_var()<<" = "<<$1->var<<endl;
						// dimlist.insert(dimlist.begin(),(get_curr_var()));
						dimlist.push_back($4->var);
						// itv()
						// dimlist.insert(dimlist.begin(),$1->value);
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
								if(get_type(ptr->eletype, $3->data_type)==_error){
									yyerror("Mismatching datatypes of LHS and RHS: " + _type[$1->data_type] + " and " + _type[$3->data_type]);
									$$->data_type = _error;
								}
								else{
									if($3->var.rfind("_term",0)==0){
										$3->var = $3->var.replace(0,5,"");
									}

									string v = $3->var;
									if(ptr->eletype != $3->data_type){
										if($3->data_type==_real){
											ic<<giv()<<" = cnvrt_to_int(" + $3->var + ")"<<endl;
											v = gicv();
											rfv($3->var);
										}
										else if($3->data_type==_integer){
											ic<<gfv()<<" = cnvrt_to_float(" + $3->var + ")"<<endl;
											v = gfcv();
											riv($3->var);
										}
									}
									if($1->var.back()==']'){										
										if(!itcv(v)||v.back()==']'){
											if($1->data_type==_integer){
												ic<<giv()<<" = "<<v<<endl;
												v = gicv();
											}
											if($1->data_type==_real){
												ic<<gfv()<<" = "<<v<<endl;
												v = gfcv();
											}
										}
									}

									ic<<$1->var<<" = "<<v<<endl;
									itv($1->var);
									if($1->var.back()==']'){
										itv(split($1->var,"[")[0]);
										itv(split(split($1->var,"[")[1],"]")[0]);
									}
									$$->var = v; 
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
						$$->var = "_term" + $1->var;
						$$->truelist = $1->truelist;
						$$->falselist = $1->falselist;
			
					};

id_arr_asg			: 	IDENTIFIER
					{
						$$ = new Node("id_arr",$1->value);
						$$->children.push_back($1);
						$$->var = $1->value;						
						Variable * ptr = symtab.search_var($1->value, level);
						if(ptr==NULL){
							yyerror("Variable \033[1;31m" + $1->value + "\033[0m not declared.");
							$$->data_type = _error;
						}
						else{
							if(ptr->eletype==_real){
								$$->var ="f." + $$->var;
							}
							else{
								$$->var ="i." + $$->var;
							}
							if(ptr->type==_array){
								yyerror("The variable " + ptr->id + " is an array, cant use array directly.");
							}
							else{	
							$$->data_type = ptr->eletype;
							if(ptr->level!=0){
								$$->var+= "." + to_string(ptr->level) + "." + active_func_ptr->id;
								if(ptr->level==1){
									$$->var = "#" + to_string(active_func_ptr->get_param_num(ptr->id));
								}
							}
							else $$->var+=".0.0";
							}
						}

					} 
					|
					IDENTIFIER LS dimlist_var RS
					{
						$$ = new Node("id_arr",$1->value);
						$$->children.push_back($1);
						$$->children.push_back($2);
						$$->children.push_back($3);
						$$->children.push_back($4);
						Variable * ptr;
						string ht = "";

						ptr = symtab.search_var($1->value,level);
						if(ptr&&ptr->level!=0) ht +=  "." + to_string(ptr->level) + "." + active_func_ptr->id;
						else	ht+=".0.0";

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
								string tv = giv();
								// string tv = "it" + get_var();
								string addr = tv;
								if(ptr->level!=1){									
									if(ptr->eletype==_real){
										ic<<tv<<" = addr(f." + $1->value +ht +")"<<endl;
									}
									else{
										ic<<tv<<" = addr(i." + $1->value +ht +")"<<endl;
									}
								}
								else{
									ic<<tv<<" = addr(#" + to_string(active_func_ptr->get_param_num(ptr->id))<<endl;
								}

								tv = dimlist[0];
								string x = giv();
								// itv(dimlist[0]);
								itv(dimlist[0]);
								string curr = x;
								for(int i=1; i<ptr->dimlist.size(); i++){
									ic<<x<<" = "<< tv <<" * "<<ptr->dimlist[i]<<endl;
									tv = x;
									ic<<x<<" = "<<x<<" + "<<dimlist[i]<<endl;
									tv = x;
									itv(dimlist[i]);
								}
								int size = 4;
								if(ptr->eletype==_real) size = 4;
								
								ic<<tv + " = " + tv + " * " + to_string(size)<<endl;
								// ic<<tv<<" = "<<addr + "[" + tv + "]"<<endl;
								// riv(addr);
								$$->var = addr + "[" + tv + "]";
							}
							dimlist.clear();
						}
					};

log_exp 		:	log_exp OR M and_exp
					{
						$$ = new Node("log_exp","or");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($4);
						if($1->data_type!=_error&&$4->data_type!=_error){	
							if(get_type($1->data_type,$4->data_type)==_error){
								yyerror("Mismatch in datatype while comparision " + $$->value);
								$$->data_type = _error;
							}
							else{
								$$->data_type = _boolean;
								// $$->var =  "it" + get_var();
								// ic<<$$->var<<" = "<<$1->var<<" "<<$2->value<<" "<<$4->var<<endl;	

							}
							patch_quad_force($3->quadlist[0], $1->falselist);
							$$->truelist = $1->truelist;
							$$->truelist.insert($$->truelist.end(), $4->truelist.begin(), $4->truelist.end());
							$$->falselist = $4->falselist;
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
												$$->truelist = $1->truelist;
						$$->falselist = $1->falselist;

					};

and_exp 		:	and_exp AND M rel_exp
					{
						$$ = new Node("and_exp","and");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($4);
						if($1->data_type!=_error&&$4->data_type!=_error){	
							if(get_type($1->data_type,$4->data_type)==_error){
								yyerror("Mismatch in datatype while comparision " + $$->value);
								$$->data_type = _error;
							}
							else{
								$$->data_type = _boolean;
								// $$->var = "it" + get_var();
								// ic<<$$->var<<" = "<<$1->var<<" "<<$2->value<<" "<<$4->var<<endl;
							}
							patch_quad_force($3->quadlist[0], $1->truelist);
							$$->falselist = $1->falselist;
							$$->falselist.insert($$->falselist.end(), $4->falselist.begin(), $4->falselist.end());
							$$->truelist = $4->truelist;
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
												$$->truelist = $1->truelist;
						$$->falselist = $1->falselist;


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
								// cout<<"OK"
								$$->data_type = _boolean;
								Type tt = get_type($1->data_type, $3->data_type);
								if(tt == _integer || tt == _real){
									if($1->data_type==$3->data_type){
										itv($1->var);
										itv($3->var);
										if($1->data_type==_real){
											$$->var = gfv();
										}
										if($1->data_type==_integer){
											$$->var = giv();
										}
										ic<<$$->var<<" = "<<$1->var<<" "<<$2->value<<" "<<$3->var<<endl;
									}
									else{
										if($1->data_type==_real){
											string tv = gfv();
											ic<<tv<<" = cnvrt_to_float("<<$1->var<<")\n";
											$$->var = tv;
											ic<<$$->var<<" = "<<tv<<" "<<$2->value<<" "<<$3->var<<endl;
										}
										else{
											string tv = gfv();
											ic<<tv<<" = cnvrt_to_float("<<$3->var<<")\n";
											$$->var = tv;
											ic<<tv<<" = "<<$1->var<<" "<<$2->value<<" "<<tv<<endl;
										}
									}
									string s = ic.str();
									$$->falselist.push_back(count(s.begin(),s.end(),'\n'));
									ic<<"if "<<$$->var<<" <= 0 goto "<<endl;
									itv($$->var);
									s = ic.str();
									$$->truelist.push_back(count(s.begin(),s.end(),'\n'));
									ic<<"goto "<<endl;
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
						$$->truelist = $1->truelist;
						$$->falselist = $1->falselist;
						
					};

sim_exp 		:	sim_exp op1 dm_exp
					{
						$$ = new Node("sim_exp",$1->value + $2->value + $3->value);$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);
						if($1->data_type!=_error&&$3->data_type!=_error){	
							Type tt = get_type($1->data_type, $3->data_type);
							if(tt == _integer || tt == _real){
								$$->data_type = tt;
								if($1->data_type==$3->data_type){
										itv($1->var);
										itv($3->var);
										if($1->data_type==_real){
											$$->var = gfv();
										}
										if($1->data_type==_integer){
											$$->var = giv();
										}
									ic<<$$->var<<" = "<<$1->var<<" "<<$2->value<<" "<<$3->var<<endl;
								}
								else{
									if($1->data_type==_real){
										string tv = gfv();
										ic<<tv<<" = cnvrt_to_float("<<$1->var<<")\n";
										$$->var = tv;
										ic<<$$->var<<" = "<<tv<<" "<<$2->value<<" "<<$3->var<<endl;
									}
									else{
										string tv = gfv();
										ic<<tv<<" = cnvrt_to_float("<<$3->var<<")\n";
										$$->var = tv;
										ic<<tv<<" = "<<$1->var<<" "<<$2->value<<" "<<tv<<endl;
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
						 $$->data_type = $1->data_type;
						 						$$->truelist = $1->truelist;
						$$->falselist = $1->falselist;


					};

dm_exp 			: 	dm_exp op2 un_exp
					{
						$$ = new Node("dm_exp",$1->value + $2->value + $3->value);$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);
						if($1->data_type!=_error&&$3->data_type!=_error){	
							Type tt = get_type($1->data_type, $3->data_type);
							if(tt == _integer || tt == _real){
								$$->data_type = tt;
								if($1->data_type==$3->data_type){
										itv($1->var);
										itv($3->var);
										if($1->data_type==_real){
											$$->var = gfv();
										}
										if($1->data_type==_integer){
											$$->var = giv();
										}
									ic<<$$->var<<" = "<<$1->var<<" "<<$2->value<<" "<<$3->var<<endl;
								}
								else{
									if($1->data_type==_real){
										string tv = gfv();
										ic<<tv<<" = cnvrt_to_float("<<$1->var<<")\n";
										$$->var = tv;
										ic<<$$->var<<" = "<<tv<<" "<<$2->value<<" "<<$3->var<<endl;
									}
									else{
										string tv = gfv();
										ic<<tv<<" = cnvrt_to_float("<<$3->var<<")\n";
										$$->var = tv;
										ic<<tv<<" = "<<$1->var<<" "<<$2->value<<" "<<tv<<endl;
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
							$$->data_type = $1->data_type;
						$$->truelist = $1->truelist;
						$$->falselist = $1->falselist;

					};

un_exp 			: 	unop term
					{
						$$ = new Node("un_exp",$1->value + $2->value);$$->children.push_back($1);$$->children.push_back($2);
						itv($2->var);
						if($2->data_type==_real){
							$$->var = gfv();
							ic<<gfv()<<" = 0.0"<<endl;
							ic<<$$->var<<" = " + gfcv() + " "<<$1->value<<" "<<$2->var<<endl;
							itv(gfcv());
						}
						if($2->data_type==_integer){
							$$->var = giv();
							ic<<giv()<<" = 0"<<endl;
							ic<<$$->var<<" = " + gicv() + " "<<$1->value<<" "<<$2->var<<endl;
							itv(gicv());
						}
						// ic<<$2->var<<" = "<<$$->var<<endl;;
						// $$->var = $2->var;
						if($2->data_type == _integer || $2->data_type == _real){
							$$->data_type = $2->data_type;
						}
						else if($2->data_type == _boolean){
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
						$$->data_type = $1->data_type;
												$$->truelist = $1->truelist;
						$$->falselist = $1->falselist;

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
						$$->truelist = $2->truelist;
						$$->falselist = $2->falselist;
					}
					|
					NOT LP expression RP
					{
						$$ = new Node("term","");$$->children.push_back($1);$$->children.push_back($2);$$->children.push_back($3);$$->children.push_back($4);
						if($3->data_type==_boolean){
							$$->data_type = $3->data_type;
						}
						else{
							yyerror("'!' operation is valid only on boolean expressions.");
							$$->data_type = _error;
						}
						// ic<<"it" + get_var()<<" = ! "<<$3->var<<endl;
						$$->var = $3->var;
						$$->falselist = $3->truelist;
						$$->truelist = $3->falselist;
					}
					|
					INTEGERS
					{	
						$$ = new Node("term",$1->value);$$->children.push_back($1);
						$$->data_type = _integer;
						$$->var = $1->value;
						ic<<giv()<<" = "<<$1->value<<endl;
						$$->var = gicv();
					}
					|
					FLOATING_POINTS
					{
						$$ = new Node("term",$1->value);$$->children.push_back($1);
						$$->data_type = _real;
						$$->var = $1->value;

						ic<<gfv()<<" = "<<$1->value<<endl;
						$$->var = gfcv();
				

					}
					|
					IDENTIFIER LP paramslist RP
					{
						$$ = new Node("term",$1->value);
						$$->children.push_back($1);
						$$->children.push_back($2);
						$$->children.push_back($3);
						$$->children.push_back($4);
						call_func_ptr = symtab.search_function($1->value);
						// ic<<int_pool<<endl;
						if(call_func_ptr){
							if(call_func_ptr->num_param==params.size()){
								for(int i=0; i<params.size(); i++){
									if(params[i].second!=call_func_ptr->parameters[i]->eletype){
										if(params[i].second == _real&&call_func_ptr->parameters[i]->eletype == _integer){
											itv(params[i].first);
											ic<<giv()<<" = cnvrt_to_int("+params[i].first+")"<<endl;
											params[i].first = gicv();
										}
										else if(params[i].second == _integer&&call_func_ptr->parameters[i]->eletype == _real){
											itv(params[i].first);
											ic<<gfv()<<" = cnvrt_to_float("+params[i].first+")"<<endl;
											params[i].first = gfcv();										
										}
										else{
											yyerror("Function's " + to_string(i+1) + " parameter is " + _type[call_func_ptr->parameters[i]->eletype] + " while passed is " + _type[params[i].second]);
										}
									}									
								}
								for(int i=0; i<params.size(); i++){
									if(!itcv(params[i].first)){
										if(params[i].second==_integer){
											ic<<giv()<<" = "<<params[i].first<<endl;
											params[i].first =gicv();
										}
										if(params[i].second==_real){
											ic<<gfv()<<" = "<<params[i].first<<endl;
											params[i].first =gfcv();
										}
									}
								}
								for(int i=0; i<params.size(); i++){
									ic<<"param "<<params[i].first<<endl;
								}
								if(call_func_ptr->return_type==_real){
									$$->var = gfv();
								}
								if(call_func_ptr->return_type==_integer){
									$$->var = giv();
								}
								ic<<"refparam "<<$$->var<<endl;
								ic<<"call "<<call_func_ptr->id<<", "<<params.size()+1<<endl;
								for(int i=0; i<params.size(); i++){
									itv(params[i].first);
								}
								$$->data_type = call_func_ptr->return_type;
							}
							else{
								$$->data_type = _error;
								yyerror("Function " + call_func_ptr->id + " expects " + to_string(call_func_ptr->num_param) + " but got " + to_string(params.size()));
							}
						}
						else{
								$$->data_type = _error;
							yyerror("Function " + $1->value + " not declared.");
						}
						// ic<<int_pool<<endl;

						call_func_ptr = NULL;	
						params.clear();
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
						if($1->var.back()==']'){
							string va = $1->var;
							if(ptr->eletype==_integer){
								ic<<giv()<<" = "<<$1->var<<endl;
								$1->var = gicv();
							}
							if(ptr->eletype==_real){
								ic<<gfv()<<" = "<<$1->var<<endl;
								$1->var = gfcv();
							}
							itv(split(va,"[")[0]);
							itv(split(split(va,"[")[1],"]")[0]);
						}
						else{
							if(ptr->eletype==_integer){
								ic<<giv()<<" = "<<$1->var<<endl;
								$1->var = gicv();
							}
							if(ptr->eletype==_real){
								ic<<gfv()<<" = "<<$1->var<<endl;
								$1->var = gfcv();
							}
						}
						$$->var = $1->var;
					};

paramslist			:	{ 
							$$ = new Node("paramslist","");
						}
						|
						paramslist_main
						{
							$$ = new Node("paramslist","");
							$$->children.push_back($1);
							
						};
paramslist_main		:	expression COMMA paramslist_main
						{
							$$ = new Node("paramslist_main","");
							$$->children.push_back($1);
							$$->children.push_back($2);
							$$->children.push_back($3);
							params.push_back(make_pair($1->var,$1->data_type));
						}
						|
						expression
						{
							$$ = new Node("paramslist_main","");
							$$->children.push_back($1);
							params.push_back(make_pair($1->var,$1->data_type));
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
		// tree_file << "[" << tree->value << "]";
	}
		tree_file<<tree->quadlist;
		tree_file<<tree->truelist;
		tree_file<<tree->falselist;
		// tree_file << "[" << tree->quadlist << "]";
	tree_file << endl;
	if(tree->children.size() > 6){
		tree_line.push_back(true);
		printTree(tree->children[6], term);
		tree_line.pop_back();
	}	if(tree->children.size() > 5){
		tree_line.push_back(true);
		printTree(tree->children[5], term);
		tree_line.pop_back();
	}	if(tree->children.size() > 4){
		tree_line.push_back(true);
		printTree(tree->children[4], term);
		tree_line.pop_back();
	}
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
	string s = ic.str();
	ReplaceStringInPlace(s,"_term","");
	ic.str(s);
	if(syntax_success){
		// for(auto it=patch_list.begin(); it!=patch_list.end(); it++){
		// 	cout<<it->first<<" "<<it->second<<endl;
		// }
		ic.str(backpatch_quad(ic.str()));
		ic.str(backpatch_force(ic.str()));
		ofstream out("inter.txt");
		string st = ic.str();
		ic.str(string(st.begin(), st.begin() + st.size()-1));
		out<<ic.str();
		out.close();
		cout<<ic.str();
		ofstream out_sym("symtab.txt");
		st = symtab.print();
		out_sym<<string(st.begin(), st.begin() + st.size()-1);
		// out_sym<<symtab.print();
		// out_sym<<"0 0 "<<bytes_g;
		out_sym.close();
		// cout<<"Global Memory: "<<bytes_g<<endl;
		cout<<int_pool<<endl;
		cout<<float_pool<<endl;	
		// SymtabReader();
	}
	tree_file.open("tree.txt",fstream::out);
	printTree(root,"\\___");
	tree_file.close();
	return 0;
}
