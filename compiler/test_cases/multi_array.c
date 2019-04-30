int main(){
	int n,m; 
	n = m = 7;

	int ar[7][7];
	int i,j;
	for(i = 0; i<n; i=i+1){
		for(j = 0; j<m; j=j+1){
			ar[i][j] = i * j;
		}
	}
	int c;
	c = ar[1][2];
	c = ar[6][6];

}
