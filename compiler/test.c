#include <stdlib.h>
#include "stdio.h"
int c,g;
float f;

float p[20];
int a[10], b;
int main(){
	int i ;
	while(i>5){
		i=i+1;	
		switch(i){
			case 1: b = 4;
			break;
			case 2: case 3:
			break;
			default:
			continue;
		}
		i=i-1;	
	}
	i = 60;
}