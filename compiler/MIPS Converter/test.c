#include <stdio.h>

int a;

int fib(int x){
	int k;
	if(x==1){
		k = 1;
	}
	if(x==0){
		k= 0;
	}
	else{
		k= fib(x-1) + fib(x-2);	
	}
	return k;
}


int main(){
	int i,j;
	i=5;
	j = fib(i);
}