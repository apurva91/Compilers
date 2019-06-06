#include <stdlib.h>
#include <stdio.h>
#include <bits/stdc++.h>
#include <string.h>

// #define INTER 0
// #define STRG 1
// #define CONDS 2
// #define COND 3
// #define TEMP 4
// #define EQUI_COND 5
// #define ATTR 6

struct node {
	struct node * child[100];
	int identifier;
	int type;
	int intdata;
	char* stringdata;
};