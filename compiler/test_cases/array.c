int main(){
	int n,m; 
	n = 7;
	m = 7;

	int arr[7];
	int i,j;
	arr[0]=2;
	for(i = 1; i<n; i=i+1){
		arr[i] = arr[i-1]+i;
	}
	int c;
	c = arr[6];
}
