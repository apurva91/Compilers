#include <stdio.h>

unsigned long ack(unsigned long m, unsigned long n);



int main(){
int i,j;
int ans = 5;
int a[5] = {1,2,3,4,5};
for (i=0;i<6;i++)
for (j=0;j<6;j++)
printf ("Ackerman of (%d, %d) is %d\n", i, j, ack(i, j));
break;
return 0;
}

unsigned long ack(unsigned long m, unsigned long n)
{
unsigned long ans;
if(m==0){	
ans = n + 1;
}
else if (n==0) 
ans = ack(m -1 , 1);
else ans = ack(m-1, ack(m , n -1));
return ans;
}