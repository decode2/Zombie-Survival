#define GOLDENUPGRADES_MODULE_VERSION "0.1"

//=====================================================
//				GOLDEN UPGRADES DEFINES
//=====================================================

// Golden upgrades
#define GOLDEN_LEECH_HP_LIMIT	120000
#define GOLDEN_LEECH_MAXHP		10000000

#define GOLDEN_MADNESS_CHANCE_MIN_HP_PCT 50

// Crit damage
#define CRIT_DAMAGE_MULTIPLIER	1.5

#define GOLDEN_UPGRADES_MAXLEVEL	12

enum GoldenUpgradesTypes{
	UPGRADE_TYPE_HUMANS,
	UPGRADE_TYPE_ZOMBIES,
	
	MAX_GOLDEN_UPGRADES_TYPES
};

enum GoldenUpgrades{
	H_LMHP,
	H_CRITCHANCE,
	H_ITEMCHANCE,
	H_AURATIME,
	
	HG_RESET,
	
	Z_MADNESSTIME,
	Z_DAMAGETOLM,
	Z_LEECH,
	Z_MADNESSCHANCE,
	
	ZG_RESET
};

int iMadnessColors[GOLDEN_UPGRADES_MAXLEVEL+1][4] = { 
	{ 100, 0, 0, 100 },
	{ 0, 255, 0, 100 },
	{ 51, 255, 202, 100 },
	{ 51, 255, 202, 100 },
	{ 245, 223, 7, 100 },
	{ 245, 223, 7, 100 },
	{ 255, 255, 255, 100 },
	{ 255, 255, 255, 100 },
	{ 93, 0, 75, 100 },
	{ 93, 0, 75, 100 },
	{ 1, 13, 160, 100 },
	{ 1, 13, 160, 100 },
	{ 51, 160, 216, 100 }
};

ArrayList gUpgradesName;
ArrayList gUpgradesType;
ArrayList gUpgradesId;
ArrayList gUpgradesBuffAmount;

void GoldenUpgrades_OnPluginStart(){
	
	gUpgradesName = new ArrayList(ByteCountToCells(64));
	gUpgradesType = new ArrayList(1);
	gUpgradesId = new ArrayList(1);
	gUpgradesBuffAmount = new ArrayList(GOLDEN_UPGRADES_MAXLEVEL+1);
	
	LoadGoldenUpgrades();
}

void GoldenUpgrades_OnPluginEnd(){
	
	gUpgradesName.Clear();
	delete gUpgradesName;
	
	gUpgradesType.Clear();
	delete gUpgradesType;
	
	gUpgradesId.Clear();
	delete gUpgradesId;
	
	gUpgradesBuffAmount.Clear();
	delete gUpgradesBuffAmount;
}

void LoadGoldenUpgrades(){
	
	// Human golden upgrades
	CreateGoldenUpgrade("Human golden upgrade 1", UPGRADE_TYPE_HUMANS, 	H_LMHP,				{ 0.0, 0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40, 0.45, 0.50, 0.55, 0.60 });
	CreateGoldenUpgrade("Human golden upgrade 2", UPGRADE_TYPE_HUMANS, 	H_CRITCHANCE, 		{ 0.0, 7.5, 12.5, 17.5, 22.5, 27.5, 32.5, 37.5, 45.0, 55.0, 65.0, 75.0, 85.0 });
	CreateGoldenUpgrade("Human golden upgrade 3", UPGRADE_TYPE_HUMANS, 	H_ITEMCHANCE, 		{ 0.0, 10.0, 15.0, 20.0, 22.5, 25.0, 27.5, 32.5, 37.5, 40.0, 45.0, 50.0, 55.0 });
	CreateGoldenUpgrade("Human golden upgrade 4", UPGRADE_TYPE_HUMANS, 	H_AURATIME, 		{ 0.0, 0.20, 0.30, 0.40, 0.50, 0.60, 0.70, 0.80, 0.90, 1.0, 1.10, 1.20, 1.30 });
	
	// Zombie golden upgrades
	CreateGoldenUpgrade("Zombie golden upgrade 1", UPGRADE_TYPE_ZOMBIES, Z_MADNESSTIME, 	{ 0.0, 0.20, 0.25, 0.30, 0.35, 0.40, 0.45, 0.50, 0.55, 0.60, 0.65, 0.70, 0.75 });
	CreateGoldenUpgrade("Zombie golden upgrade 2", UPGRADE_TYPE_ZOMBIES, Z_DAMAGETOLM, 		{ 0.0, 0.12, 0.20, 0.29, 0.38, 0.47, 0.56, 0.64, 0.73, 0.82, 0.91, 1.0, 1.05 });
	CreateGoldenUpgrade("Zombie golden upgrade 3", UPGRADE_TYPE_ZOMBIES, Z_LEECH, 			{ 0.0, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40, 0.45, 0.50, 0.55, 0.60, 0.65 });
	CreateGoldenUpgrade("Zombie golden upgrade 4", UPGRADE_TYPE_ZOMBIES, Z_MADNESSCHANCE, 	{ 0.0, 0.10, 0.15, 0.25, 0.30, 0.35, 0.45, 0.50, 0.60, 0.65, 0.70, 0.75, 0.80 });
}

stock int getUpgradeIndexByUpgradeId(GoldenUpgrades upgradeIndex){
	return gUpgradesId.FindValue(upgradeIndex);
}

methodmap GoldenUpgrade{
	
	public GoldenUpgrade(int value){
		return view_as<GoldenUpgrade>(value);
	}
	
	property int id{
		public get(){
			return view_as<int>(this);
		}
	}
	
	property GoldenUpgradesTypes type{
		public get(){
			return gUpgradesType.Get(this.id);
		}
		public set(GoldenUpgradesTypes type){
			gUpgradesType.Set(this.id, type);
		}
	}
	
	property GoldenUpgrades upgradeId{
		public get(){
			return view_as<GoldenUpgrades>(gUpgradesId.Get(this.id));
		}
		public set(GoldenUpgrades type){
			gUpgradesId.Set(this.id, type);
		}
	}
	
	public float getBuffAmount(int upgradeLevel){
		
		float fArray[GOLDEN_UPGRADES_MAXLEVEL+1] = { 0.0, ...};
		gUpgradesBuffAmount.GetArray(getUpgradeIndexByUpgradeId(this.upgradeId), fArray);
		
		return fArray[upgradeLevel];
	}
	
	public float getBuffPercentage(int upgradeLevel){
		
		float amount = this.getBuffAmount(upgradeLevel);
	
		switch (this.upgradeId){
			
			case H_LMHP, H_AURATIME, Z_MADNESSTIME, Z_DAMAGETOLM, Z_LEECH, Z_MADNESSCHANCE: amount *= 100.0;
		}
		
		return amount;
	}
	
	public int getCost(int upgradeLevel){
		
		return upgradeLevel+1;
	}
	
}

// Create golden upgrade
void CreateGoldenUpgrade(char[] name, GoldenUpgradesTypes type, GoldenUpgrades upgradeId, any[] buffAmount){
	
	gUpgradesName.PushString(name);
	gUpgradesType.Push(type);
	gUpgradesId.Push(upgradeId);
	gUpgradesBuffAmount.PushArray(buffAmount);
}

// Applies percentage to a base
stock float applyPercentage(float base, float percentage){
	return base*(1+percentage);
}

// Gets leech amount
stock int getLeechAmount(int base, float multiplier){
	return RoundToZero(base*multiplier);
}

// Gets if all h/z upgrades are zero
stock bool GoldenUpgradesAreZero(int client, bool human){
		
	bool value = true;
	
	//int size = human ? sizeof(gClientData[client].iGoldenHUpgradeLevel[]) : sizeof(gClientData[client].iGoldenZUpgradeLevel[]);
	int size = 4;
	
	for (int i; i < size; i++){
		
		if (human){
			
			if (gClientData[client].iGoldenHUpgradeLevel[i] > 0){
				
				value = false;
				break;
			}
		}
		else{
			if (gClientData[client].iGoldenZUpgradeLevel[i] > 0){
				
				value = false;
				break;
			}
		}
	}
	
	return value;
}