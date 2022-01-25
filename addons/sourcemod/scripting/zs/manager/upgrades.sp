#if defined upgrades_included
	#endinput
#endif
#define upgrades_included

#define UPGRADES_MODULE_VERSION "0.1"

//=====================================================
//					UPGRADES VARIABLES
//=====================================================
#define RESET_BONUS_COST 3

// HUMAN UPGRADES
#define BOSSES_UPGRADE_PERCENTAGE 0.10 // (0.X = X0%)

// Damage
#define MAX_HUMAN_DAMAGE_LEVEL 100
#define HUMAN_DAMAGE_BONUS 0.05 // (0.0X = X%)
#define HUMAN_DAMAGE_COST 7

// Resistance
#define MAX_HUMAN_RESISTANCE_LEVEL 70
#define HUMAN_RESISTANCE_HEALTH_BONUS 20
#define HUMAN_RESISTANCE_ARMOR_BONUS  4
#define HUMAN_RESISTANCE_COST 6

// Dexterity
#define MAX_HUMAN_DEXTERITY_LEVEL 40
#define HUMAN_DEXTERITY_SPEED_BONUS 0.018 // (0.0X = X%)
#define HUMAN_DEXTERITY_GRAVITY_BONUS 0.01 // (0.0X = X%)
#define HUMAN_DEXTERITY_COST 5

// ZOMBIE UPGRADES
// Damage
#define MAX_ZOMBIE_DAMAGE_LEVEL 45
#define ZOMBIE_DAMAGE_BONUS 0.032 // (0.0X = X%)
#define ZOMBIE_DAMAGE_COST 5

//Health
#define MAX_ZOMBIE_HEALTH_LEVEL 70
#define ZOMBIE_HEALTH_BONUS 0.075 // (0.0X = X%)
#define ZOMBIE_HEALTH_COST 7

// Dexterity
#define MAX_ZOMBIE_DEXTERITY_LEVEL 36
#define ZOMBIE_DEXTERITY_SPEED_BONUS 0.020 // (0.0X = X%)
#define ZOMBIE_DEXTERITY_GRAVITY_BONUS 0.015 // (0.0X = X%)
#define ZOMBIE_DEXTERITY_COST 6

enum HMEJORAS{
	//Human
	H_DAMAGE,
	H_RESISTANCE,
	H_DEXTERITY,
	H_RESET
};

enum ZMEJORAS{
	Z_HEALTH,
	Z_DAMAGE,
	Z_DEXTERITY,
	Z_RESET
};

public int getCommonHumanUpgradeCost(HMEJORAS upgrade, int upgradeLevel){
	
	int cost = 0;
	switch (upgrade){
		case H_DAMAGE: cost = (HUMAN_DAMAGE_COST * (upgradeLevel+1));
		case H_RESISTANCE: cost = (HUMAN_RESISTANCE_COST * (upgradeLevel+1));
		case H_DEXTERITY: cost = (HUMAN_DEXTERITY_COST * (upgradeLevel+1));
	}
	return cost;
}

public int getCommonZombieUpgradeCost(ZMEJORAS upgrade, int upgradeLevel){
	
	int cost = 0;
	switch (upgrade){
		case Z_HEALTH: cost = (ZOMBIE_HEALTH_COST * (upgradeLevel+1));
		case Z_DAMAGE: cost = (ZOMBIE_DAMAGE_COST * (upgradeLevel+1));
		case Z_DEXTERITY: cost = (ZOMBIE_DEXTERITY_COST * (upgradeLevel+1));
	}
	return cost;
}