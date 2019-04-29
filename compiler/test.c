int main()
{
	float y;
	y  = 2.0;
	int x;
	x = 5;
	float ans;
	ans = 0.0;
	if(x < 4)
	{
		int i;
		for(i=0;i<5;i=i+1)
		{
			ans = ans + y;
		}
	}
	else
	{
		int i;
		i = 0;
		while(i < 5)
		{
			ans = ans + y;
			i = i + 1 ;
		}
	}
}