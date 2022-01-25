#define TIERS_MODULE_VERSION "0.1"

// TIERS
int tierByReset[6] = { 0, 25, 50, 100, 150, 200 };


int tiersFindTierForReset(int reset){
	
	static int value = 0;
	
	for (int i = 0; i < sizeof(tierByReset); i++){
		
		// In case his resets aren't enought, cancel
		if (reset < tierByReset[i]){
			break;
		}
		
		// Else
		value = i;
	}
	
	return value;
}

void tiersOnPlayerUpdateTier(int client){
	
	gClientData[client].iTier = tiersFindTierForReset(gClientData[client].iReset);
}