int main(){
	int x; 
	x = 3;
	int ans;
	ans = 4;
	switch(x){
		case 1:{
			int i;
			for(i=0;i<1;i=i+1){
				ans = ans + i;
			}
		}
		case 2:{
			int i;
			for(i=0;i<2;i=i+1){
				ans = ans + i;
			}
			break;
		}
		case 3:{
			int i;
			for(i=0;i<3;i=i+1){
				ans = ans + i;
			}
			break;
		}
		default:{
			int i;
			ans = -10;
			break;
		}
	}
	int b;
	b=ans;
}
