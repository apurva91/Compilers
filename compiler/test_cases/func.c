int fib(int x){
	int b,p,q;
	if(x==1){
		b=1;
	}
	else{
		if(x==0){
			b=1;
		}
		else{
			p = fib(x-1);
			q = fib(x-2);
			b=p+q;
		}
	}
	return b;
}
int main(){
	int y,r
	y = 4;
	r = fib(y);
}
