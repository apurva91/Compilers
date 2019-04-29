int a;

int fib(int x){
	int b;
	if(x == 0){
		b=0;
	}
	else{
		b=x+fib(x-1);
	}
	return b;
}
int main()
{
	int y,r;
	y = 4;
	r = fib(y);
}