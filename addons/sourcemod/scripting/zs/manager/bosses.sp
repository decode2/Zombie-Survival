
#if defined bosses_included
	#endinput
#endif
#define bosses_included

#define BOSSES_MODULE_VERSION "0.1"


//=====================================================
//				BOSSES DEFINES
//=====================================================

// Survivor
#define SURVIVOR_HEALTH 		200
#define SURVIVOR_BASE_HEALTH 	900
#define SURVIVOR_DAMAGE 		2.5
#define SURVIVOR_SPEED 			1.6
#define SURVIVOR_GRAVITY 		0.86
#define SURVIVOR_MODEL 			"models/player/custom_player/voikanaa/rehd/jill.mdl"
#define SURVIVOR_MODEL_ARMS 	"models/player/custom_player/kuristaja/cso2/emma/emma_arms.mdl"

/*#define SURVIVOR_MODEL 		"models/player/custom_player/kuristaja/cso2/natalie_santagirl/natalie.mdl"
#define SURVIVOR_MODEL_ARMS	"models/player/custom_player/kuristaja/cso2/natalie_santagirl/natalie_arms.mdl"*/
#define SURVIVOR_VMODEL_WEAPON 	"models/weapons/v_mach_m60.mdl"
#define SURVIVOR_WMODEL_WEAPON 	"models/weapons/w_mach_m60para.mdl"

// SUPER Survivor
#define SUPERSURV_HEALTH 		215
#define SUPERSURV_BASE_HEALTH 	1300
#define SUPERSURV_DAMAGE 		1.7
#define SUPERSURV_SPEED 		1.8
#define SUPERSURV_GRAVITY 		0.84
//#define SUPERSURV_MODEL 		"models/player/custom_player/voikanaa/rehd/jill.mdl"
//#define SUPERSURV_MODEL_ARMS 	"models/player/custom_player/kuristaja/cso2/emma/emma_arms.mdl"

// GUNSLINGER
#define GUNSLINGER_HEALTH 		150
#define GUNSLINGER_BASE_HEALTH 	1100
#define GUNSLINGER_DAMAGE 		2.75
#define GUNSLINGER_SPEED 		1.8
#define GUNSLINGER_GRAVITY 		0.9
#define GUNSLINGER_MODEL 		"models/player/custom_player/caleon1/gunslinger/gunslinger_red.mdl"
#define GUNSLINGER_MODEL_ARMS 	"models/player/custom_player/caleon1/gunslinger/gunslinger_red_arms.mdl"

// SNIPER
#define SNIPER_HEALTH 			300
#define SNIPER_BASE_HEALTH 		1100
#define SNIPER_DAMAGE 			4.0
#define SNIPER_SPEED 			2.0
#define SNIPER_GRAVITY 			0.9
#define SNIPER_MODEL 			"models/player/custom_player/voikanaa/mw2/shadowcompany.mdl"
#define SNIPER_MODEL_ARMS 		"models/player/custom_player/kuristaja/mkx/jason/jason_arms.mdl"
#define SNIPER_VMODEL_WEAPON 	"models/weapons/eminem/dsr_50/v_dsr_50_2.mdl"
#define SNIPER_WMODEL_WEAPON 	"models/weapons/eminem/dsr_50/w_dsr_50_2.mdl"

// MEOW
#define MEOW_HEALTH 			325
#define MEOW_BASE_HEALTH 		20000
#define MEOW_DAMAGE 			40.0
#define MEOW_SPEED 				3.0
#define MEOW_GRAVITY 			0.4
#define MEOW_MODEL 				"models/player/custom_player/voikanaa/rehd/jill.mdl"
#define MEOW_MODEL_ARMS 		"models/player/custom_player/kuristaja/cso2/emma/emma_arms.mdl"

///////////////////////////////////////////////////////

// Assassin
#define ASSASSIN_HEALTH 		8500
#define ASSASSIN_BASE_HEALTH 	90000
#define ASSASSIN_DAMAGE 		10.0
#define ASSASSIN_DAMAGE_TOLM 	7.0
#define ASSASSIN_SPEED 			2.2
#define ASSASSIN_GRAVITY 		0.75
#define ASSASSIN_MODEL 			"models/player/custom_player/kuristaja/trager/tragerv2.mdl"
#define ASSASSIN_MODEL_ARMS 	"models/player/custom_player/kuristaja/trager/trager_arms.mdl"

// Nemesis
#define NEMESIS_HEALTH 			12000
#define NEMESIS_BASE_HEALTH 	180000
#define NEMESIS_DAMAGE 			7.0
#define NEMESIS_DAMAGE_TOLM 	7.0
#define NEMESIS_SPEED 			1.9
#define NEMESIS_GRAVITY 		0.8

#define NEMESIS_MODEL_OLD 		"models/player/custom_player/ventoz/zombies/neme/neme.mdl"
#define NEMESIS_MODEL_ARMS_OLD 	"models/player/custom_player/kuristaja/mkx/jason/jason_arms.mdl"

#define NEMESIS_MODEL 			"models/player/custom_player/owston/re3/nemesis/nemesis_v0.mdl"
#define NEMESIS_MODEL_ARMS 		"models/player/custom_player/owston/re3/nemesis/arms_nemesis.mdl"

/*#define NEMESIS_MODEL		"models/player/custom_player/kodua/xmas_gorefiend/xmas_gorefiend.mdl"
#define NEMESIS_MODEL_ARMS	"models/player/custom_player/kuristaja/mkx/jason/jason_arms.mdl"*/

#define ZOMBIE_BOSSES_KNIFE_MODEL_V "models/weapons/eminem/old_cleaver/v_old_cleaver.mdl"
#define ZOMBIE_BOSSES_KNIFE_MODEL_W "models/weapons/eminem/old_cleaver/w_old_cleaver.mdl"

// FEV
/*#define FEV_HEALTH 			10500
#define FEV_BASE_HEALTH 	170000
#define FEV_DAMAGE			5.0
#define FEV_DAMAGE_TOLM 	3.25
#define FEV_SPEED 			1.1
#define FEV_GRAVITY 		0.7*/
#define FEV_MODEL 			"models/player/custom_player/kodua/ffs/fev_failed_subj.mdl"
#define FEV_MODEL_ARMS 		"models/player/custom_player/kodua/ffs/arms.mdl"

//////////////////////////////

// Nemesis aura
#define BOSSES_AURA_COLOR_NEMESIS_R 	100
#define BOSSES_AURA_COLOR_NEMESIS_G 	0
#define BOSSES_AURA_COLOR_NEMESIS_B 	0
#define BOSSES_AURA_COLOR_NEMESIS_A 	30

// Survivor aura
#define BOSSES_AURA_COLOR_SURVIVOR_R 	64
#define BOSSES_AURA_COLOR_SURVIVOR_G 	64
#define BOSSES_AURA_COLOR_SURVIVOR_B 	64
#define BOSSES_AURA_COLOR_SURVIVOR_A 	30

// FEV aura
#define BOSSES_AURA_COLOR_FEV_R 	20
#define BOSSES_AURA_COLOR_FEV_G 	220
#define BOSSES_AURA_COLOR_FEV_B 	20
#define BOSSES_AURA_COLOR_FEV_A 	150

#define UNIQUE_ZOMBIE_BOSS_HP_MULTIPLIER 2.25

#define HAZMAT_MODEL 		"models/player/custom_player/owston/l4d2/survivor.mdl"

//=====================================================
//				BOSSES VARIABLES
//=====================================================

ArrayList ZBosses;

//=====================================================
//					METHOD
//=====================================================

enum struct ZBoss{
	
	int id;
	int iType;
	int iHealthAdditive;
	int iHealthBase;
	float flDamage;
	float flSpeed;
	float flGravity;
	float flDamageToLm;
	int iTeamNum;
	char name[32];
	char model[255];
	char arms[255];
	
	
	void GetName(char[] buffer, int maxlength){
		strcopy(buffer, maxlength, this.name);
	}
	
	void GetModel(char[] buffer, int maxlength){
		strcopy(buffer, maxlength, this.model);
	}
	
	void GetArms(char[] buffer, int maxlength){
		strcopy(buffer, maxlength, this.arms);
	}
}

// Create boss
int CreateBoss(char[] name, char[] model, char[] armsModel, PlayerType type, int healthAdditive, int healthBase, float damageMul, float speedMul, float gravityMul, float damageToLm, int team){
	
	ZBoss boss;
	boss.id = ZBosses.Length;
	strcopy(boss.name, sizeof(boss.name), name);
	strcopy(boss.model, sizeof(boss.model), model);
	strcopy(boss.arms, sizeof(boss.arms), armsModel);
	boss.iType = view_as<int>(type);
	boss.iHealthAdditive = healthAdditive;
	boss.iHealthBase = healthBase;
	boss.flDamage = damageMul;
	boss.flSpeed = speedMul;
	boss.flGravity = gravityMul;
	boss.flDamageToLm = damageToLm;
	boss.iTeamNum = team;
	
	return ZBosses.PushArray(boss);
}

///////////////////////////////////////////////////////

void Bosses_OnPluginStart(){
	
	ZBosses = new ArrayList(sizeof(ZBoss));
	
	// Register bosses
	LoadBosses();
}

void Bosses_OnPluginEnd(){
	
	ZBosses.Clear();
	delete ZBosses;
}

// Gets the array number where the type is found
int GetBossIndex(PlayerType type){
	
	int bossIndex = -1;
	
	ZBoss boss;
	for (int i = 0; i < ZBosses.Length; i++){
		ZBosses.GetArray(i, boss);
		
		if (boss.iType == view_as<int>(type)){
			bossIndex = i;
			break;
		}
	}
	
	return bossIndex;
}

// Bosses
public void LoadBosses(){

	ZBosses.Clear();

	CreateBoss("Survivor", 		SURVIVOR_MODEL, 	SURVIVOR_MODEL_ARMS, 	PT_SURVIVOR, 		SURVIVOR_HEALTH, 	SURVIVOR_BASE_HEALTH, 	SURVIVOR_DAMAGE, 	SURVIVOR_SPEED, 	SURVIVOR_GRAVITY, 		0.0, 					CS_TEAM_CT);
	CreateBoss("Gunslinger", 	GUNSLINGER_MODEL, 	GUNSLINGER_MODEL_ARMS, 	PT_GUNSLINGER, 		GUNSLINGER_HEALTH, 	GUNSLINGER_BASE_HEALTH, GUNSLINGER_DAMAGE, 	GUNSLINGER_SPEED, 	GUNSLINGER_GRAVITY, 	0.0, 					CS_TEAM_CT);
	CreateBoss("Sniper", 		SNIPER_MODEL, 		SNIPER_MODEL_ARMS, 		PT_SNIPER, 			SNIPER_HEALTH, 		SNIPER_BASE_HEALTH, 	SNIPER_DAMAGE, 		SNIPER_SPEED, 		SNIPER_GRAVITY, 		0.0, 					CS_TEAM_CT);
	CreateBoss("Super Survivor", SURVIVOR_MODEL, 	SURVIVOR_MODEL_ARMS, 	PT_SUPERSURVIVOR,	SUPERSURV_HEALTH, 	SUPERSURV_BASE_HEALTH, 	SUPERSURV_DAMAGE, 	SUPERSURV_SPEED, 	SUPERSURV_GRAVITY, 		0.0, 					CS_TEAM_CT);
	CreateBoss("Chainsaw", 		SURVIVOR_MODEL, 	SURVIVOR_MODEL_ARMS, 	PT_CHAINSAW,		SUPERSURV_HEALTH, 	SUPERSURV_BASE_HEALTH, 	1.0, 				SUPERSURV_SPEED, 	SUPERSURV_GRAVITY, 		0.0, 					CS_TEAM_CT);
	CreateBoss("MEOW", 			MEOW_MODEL, 		MEOW_MODEL_ARMS, 		PT_MEOW, 			MEOW_HEALTH, 		MEOW_BASE_HEALTH, 		MEOW_DAMAGE, 		MEOW_SPEED, 		MEOW_GRAVITY, 			0.0, 					CS_TEAM_CT);
	
	CreateBoss("Nemesis", 		NEMESIS_MODEL, 		NEMESIS_MODEL_ARMS, 	PT_NEMESIS, 		NEMESIS_HEALTH, 	NEMESIS_BASE_HEALTH, 	NEMESIS_DAMAGE, 	NEMESIS_SPEED, 		NEMESIS_GRAVITY, 		NEMESIS_DAMAGE_TOLM, 	CS_TEAM_T);
	CreateBoss("Assassin", 		ASSASSIN_MODEL, 	ASSASSIN_MODEL_ARMS, 	PT_ASSASSIN, 		ASSASSIN_HEALTH, 	ASSASSIN_BASE_HEALTH, 	ASSASSIN_DAMAGE, 	ASSASSIN_SPEED, 	ASSASSIN_GRAVITY, 		ASSASSIN_DAMAGE_TOLM, 	CS_TEAM_T);
//	CreateBoss("FEV", 			FEV_MODEL, 			FEV_MODEL_ARMS, 		PT_FEV, 			FEV_HEALTH, 		FEV_BASE_HEALTH, 		FEV_DAMAGE, 		FEV_SPEED, 			FEV_GRAVITY, 			FEV_DAMAGE_TOLM, 		CS_TEAM_T);
}