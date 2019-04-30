int fib(int x){
	int b,p,q;
	if(x==1){
		b=1;
	}
	else{
		b= fib(x-1);
		b=b*x;
	}
	return b;
}
int main(){
	int y,r;
	y = 5;
	r = fib(y);
}
