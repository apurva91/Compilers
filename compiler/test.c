#include <stdio.h>

int a[10][25];

int fib(int x){
	if(x==1){
		return 1;
	}
	if(x==0){
		return 0;
	}
	else{
		return fib(x-1) + fib(x-2);	
	}
}


int main(){
	int i,j;
	for(i=0; i<10; i=i+1){
		for(j=0; j<25; j=j+1){
			a[i][j] = i*j;
		}
	}
}