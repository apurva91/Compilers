#include <bits/stdc++.h>
using namespace std;

extern int yylineno;

struct Node{
	string type; 	//token class
	string value;	//token value
	vector <Node *> children;
	Node(string type, string value) : type(type), value(value) {}
};