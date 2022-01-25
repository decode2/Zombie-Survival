#define RESETS_MODULE_VERSION "0.1"

// Reset
#define RESET_LEVEL 400
#define RESET_MAX_QUANTITY 	220 // max resets quantity
#define RESET_AMMOUNT_TO_START_PAYING_POINTS 80 // ammount of resets to start paying for them
#define RESET_AMMOUNT_TO_START_PAYING_DOUBLE 100 // ammount of resets to start paying DOUBLE
#define RESET_POINTS_AMMOUNT_TO_PAY_FEE 25 // ammount of points the user has to pay to make a reset
//#define RESET_POINTS_BONUS_AMOUNT 	100

int resetsCalculateFeeByResets(int resetsAmmount){
	
	int value = 0;
	/*
	if (RESET_AMMOUNT_TO_START_PAYING_POINTS-1 < resetsAmmount < RESET_AMMOUNT_TO_START_PAYING_DOUBLE){
		value = RESET_POINTS_AMMOUNT_TO_PAY_FEE;
	}
	else if (resetsAmmount >= RESET_AMMOUNT_TO_START_PAYING_DOUBLE){
		value = RESET_POINTS_AMMOUNT_TO_PAY_FEE*2;
		
		if (RESET_AMMOUNT_TO_START_PAYING_DOUBLE < resetsAmmount < 150){
			value = RESET_POINTS_AMMOUNT_TO_PAY_FEE*3;
		}
		else{
			value = RESET_POINTS_AMMOUNT_TO_PAY_FEE*4;
		}
	}*/
	
	if (resetsAmmount >= RESET_AMMOUNT_TO_START_PAYING_POINTS){
		
		value = RESET_POINTS_AMMOUNT_TO_PAY_FEE;
		
		if (resetsAmmount >= RESET_AMMOUNT_TO_START_PAYING_DOUBLE){
			
			value = RESET_POINTS_AMMOUNT_TO_PAY_FEE*2;
			
			if (resetsAmmount >= 150){
				
				value = RESET_POINTS_AMMOUNT_TO_PAY_FEE*3;
				
				if (resetsAmmount >= 175){
					value = RESET_POINTS_AMMOUNT_TO_PAY_FEE*4;
					
					if (resetsAmmount >= 200){
						value = RESET_POINTS_AMMOUNT_TO_PAY_FEE*5;
					}
				}
			}
		}
	}
	
	return value;
}