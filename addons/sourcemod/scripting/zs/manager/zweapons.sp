#include <weapons_utils>
#include "zs/manager/bazooka.sp"
#include "zs/manager/chainsaw.sp"

#define ZWEAPONS_MODULE_VERSION 	"0.1"

#define WEAPONS_MODELS_MAXPATH		256
#define WEAPONS_DAMAGE_DESVIATION	0.07

#define FREEZE_AWP_STUN_TIME 		0.33
#define KNIFE_DEFAULT_DAMAGE_MUL	60.0


// Special weapons
int iWeaponMeow;
int iWeaponSurvivor;
int iWeaponSuperSurvivor;
int iWeaponGunslinger;
int iWeaponSniper;
//int iWeaponMinigun;

enum WeaponsHitTypes{
	HIT_TYPE_NONE = 0,
	HIT_TYPE_FREEZE,
	HIT_TYPE_BURN
}

//=====================================================
//				WEAPONS VARIABLES
//=====================================================
#define WEAPONS 256
int gWeaponsLevel[WEAPONS];
int gWeaponsReset[WEAPONS];
float gWeaponsDamageMin[WEAPONS];
float gWeaponsDamageMax[WEAPONS];
float gWeaponsKnockback[WEAPONS];
WeaponType gWeaponsType[WEAPONS];
int gWeaponsTier[WEAPONS];
bool gWeaponsVisibility[WEAPONS];
WeaponsHitTypes gWeaponsHitType[WEAPONS];

ArrayList WeaponsName;
ArrayList WeaponsEnt;
ArrayList WeaponsModel;
ArrayList WeaponsWorldModel;
ArrayList WeaponsDroppedModel;

enum WeaponType{
	WEAPON_PRIMARY,
	WEAPON_SECONDARY
};

void WeaponsOnMapEnd(){
	
	ChainsawOnMapEnd();
}

// On plugin start
stock void WeaponsOnPluginStart(){
	
	// Primary weapons arrays
	WeaponsName = CreateArray(ByteCountToCells(32));
	WeaponsEnt = CreateArray(ByteCountToCells(32));
	WeaponsModel = CreateArray(ByteCountToCells(WEAPONS_MODELS_MAXPATH));
	WeaponsWorldModel = CreateArray(ByteCountToCells(WEAPONS_MODELS_MAXPATH));
	WeaponsDroppedModel = CreateArray(ByteCountToCells(WEAPONS_MODELS_MAXPATH));
	
	HookEvent("weapon_fire", EventWeaponFire, EventHookMode_Post);
	
	// Register weapons
	LoadWeapons();
}

// On plugin end
stock void WeaponsOnPluginEnd(){
	WeaponsName.Clear();
	WeaponsEnt.Clear();
	WeaponsModel.Clear();
	WeaponsWorldModel.Clear();
}

// Initialize client Weapons SDK Hooks
void WeaponsOnClientPutInServer(int client){
	SDKHook(client, SDKHook_WeaponCanUse, 	WeaponsOnCanUse);
	SDKHook(client, SDKHook_WeaponEquip, 	WeaponsOnEquip);
	SDKHook(client, SDKHook_WeaponDropPost,	WeaponsOnDropPost);
	SDKHook(client, SDKHook_PostThinkPost, 	WeaponsOnAnimationFix);
}

void WeaponsOnClientPostAdminCheck(int client){
	
	SDKHook(client, SDKHook_WeaponSwitch, 		OnClientWeaponSwitch);
	SDKHook(client, SDKHook_WeaponSwitchPost, 	OnClientWeaponSwitchPost);
	SDKHook(client, SDKHook_WeaponDropPost, 	OnClientWeaponDropPost);
}

#pragma unused WeaponsOnClientDisconnect
void WeaponsOnClientDisconnect(int client){
	
	// OnPutInServer unhooks
	SDKUnhook(client, SDKHook_WeaponCanUse, 	WeaponsOnCanUse);
	SDKUnhook(client, SDKHook_WeaponEquip, 		WeaponsOnEquip);
	SDKUnhook(client, SDKHook_WeaponDropPost, 	WeaponsOnDropPost);
	SDKUnhook(client, SDKHook_PostThinkPost, 	WeaponsOnAnimationFix);
	
	// Post admin check unhooks
	SDKUnhook(client, SDKHook_WeaponSwitchPost, OnClientWeaponSwitchPost);
	SDKUnhook(client, SDKHook_WeaponSwitch, 	OnClientWeaponSwitch);
	SDKUnhook(client, SDKHook_WeaponDropPost, 	OnClientWeaponDropPost);
	
	ChainsawOnClientDisconnect(client);
}

//=====================================================
//					METHOD
//=====================================================

// Weapons
methodmap ZWeapon{
	public ZWeapon(int value){
		return view_as<ZWeapon>(value);
	}
	
	// Index
	property int id{
		public get(){
			return view_as<int>(this);
		}
	}
	
	// Requirements
	property int iLevel{
		public get(){
			return gWeaponsLevel[this.id];
		}
		public set(int value){
			gWeaponsLevel[this.id] = value;
		}
	}
	property int iReset{
		public get(){
			return gWeaponsReset[this.id];
		}
		public set(int value){
			gWeaponsReset[this.id] = value;
		}
	}
	
	// Weapons attributes
	property float flDamageMin{
		public get(){
			return gWeaponsDamageMin[this.id];
		}
		public set(float value){
			gWeaponsDamageMin[this.id] = value;
		}
	}
	property float flDamageMax{
		public get(){
			return gWeaponsDamageMax[this.id];
		}
		public set(float value){
			gWeaponsDamageMax[this.id] = value;
		}
	}
	property float flDamage{
		public get(){
			return GetRandomFloat(this.flDamageMin, this.flDamageMax);
		}
	}
	property float flKnockback{
		public get(){
			return gWeaponsKnockback[this.id];
		}
		public set(float value){
			gWeaponsKnockback[this.id] = value;
		}
	}
	
	// Weapon type
	property WeaponType iType{
		public get(){
			return view_as<WeaponType>(gWeaponsType[this.id]);
		}
		public set(WeaponType value){
			view_as<WeaponType>(gWeaponsType[this.id]) = value;
		}
	}
	
	// Weapon tier
	property int iTier{
		public get(){
			return gWeaponsTier[this.id];
		}
		public set(int value){
			gWeaponsTier[this.id] = value;
		}
	}
	
	// Available in menu?
	property bool bInMenu{
		public get(){
			return gWeaponsVisibility[this.id];
		}
		public set(bool value){
			gWeaponsVisibility[this.id] = value;
		}
	}
	
	property WeaponsHitTypes HitType{
		public get(){
			return gWeaponsHitType[this.id];
		}
		public set(WeaponsHitTypes value){
			gWeaponsHitType[this.id] = value;
		}
	}
	
	// Funcs
	public void GetName(char[] buffer, int maxlength){
		
		WeaponsName.GetString(this.id, buffer, maxlength);
	}
	public void GetEnt(char[] buffer, int maxlength){
		
		WeaponsEnt.GetString(this.id, buffer, maxlength);
	}
	public void GetViewModel(char[] buffer, int maxlength){
		
		WeaponsModel.GetString(this.id, buffer, maxlength);
	}
	public void GetWorldModel(char[] buffer, int maxlength){
		
		WeaponsWorldModel.GetString(this.id, buffer, maxlength);
	}
	public void GetDroppedModel(char[] buffer, int maxlength){
		
		WeaponsDroppedModel.GetString(this.id, buffer, maxlength);
	}
	
	public void SetNetworkedName(int weaponIndex){
		
		static char sWeaponNetworkedName[32];
		FormatEx(sWeaponNetworkedName, sizeof(sWeaponNetworkedName), (this.iType == WEAPON_PRIMARY) ? "primary_%d" : "secondary_%d", this.id);
		SetEntPropString(weaponIndex, Prop_Data, "m_iName", sWeaponNetworkedName);
		
		static int IDHigh = 16384;
		SetEntProp(weaponIndex, Prop_Send, "m_iItemIDLow", -1);
		SetEntProp(weaponIndex, Prop_Send, "m_iItemIDHigh", IDHigh++);
		SetEntProp(weaponIndex, Prop_Send, "m_iEntityQuality", 9);
		
		static char sWeaponName[64];
		this.GetName(sWeaponName, sizeof(sWeaponName));
		SetEntDataString(weaponIndex, FindSendPropInfo("CBaseAttributableItem", "m_szCustomName"), sWeaponName, 128);
	}
	public void SetWorldModel(int weaponIndex){
		
		// World model
		char sWeapWorldModel[WEAPONS_MODELS_MAXPATH];
		this.GetWorldModel(sWeapWorldModel, sizeof(sWeapWorldModel));
		
		if (!StrEqual(sWeapWorldModel, "")){
			SetWorldModel(weaponIndex, GetModelIndex(sWeapWorldModel));
		}
	}
	public void SetDroppedModel(int weaponIndex){
		
		// World model
		char sWeapDroppedModel[WEAPONS_MODELS_MAXPATH];
		this.GetDroppedModel(sWeapDroppedModel, sizeof(sWeapDroppedModel));
		
		if (!StrEqual(sWeapDroppedModel, "")){
			SetWorldModel(weaponIndex, GetModelIndex(sWeapDroppedModel));
		}
	}
}

//=====================================================
//					WEAPONS CREATION
//=====================================================
stock int CreateWeapon(const char[] name, const char[] entityName, const char[] vModel, const char[] wModel, const char[] droppedModel, int level, int reset, float dmg, float knockback, WeaponType type, int tier, bool inMenu = true, WeaponsHitTypes hitType = HIT_TYPE_NONE){
	ZWeapon weap = ZWeapon(WeaponsName.Length);
	
	static char sName[64];
	FormatEx(sName, sizeof(sName), "%s (T%d)", name, tier);
	WeaponsName.PushString(sName);
	
	WeaponsEnt.PushString(entityName);
	
	WeaponsModel.PushString(vModel);
	WeaponsWorldModel.PushString(wModel);
	WeaponsDroppedModel.PushString(droppedModel);
	
	weap.iLevel = level;
	weap.iReset = reset;
	weap.flDamageMin = dmg-(dmg*WEAPONS_DAMAGE_DESVIATION);
	weap.flDamageMax = dmg+(dmg*WEAPONS_DAMAGE_DESVIATION);
	weap.flKnockback = knockback;
	weap.iType = type;
	weap.iTier = tier;
	weap.bInMenu = inMenu;
	weap.HitType = hitType;
	
	return weap.id;
}

//============================================
// 				FUNCTIONS
//============================================
//**********************************************
//* Item (weapon) hooks.					   *
//**********************************************

public void Weapons_OnEntityCreated(int entity, const char[] classname){
	
	// Validate entity
	if (entity > -1){
		
		// Forward event to sub-modules
		Weapons_OnWeaponCreated(entity);
	}
	
}


/**
 * @brief Called after a custom weapon is created.
 *
 * @param client			The client index.
 * @param weapon			The weapon index.
 * @param weaponID		  	The weapon id.
 **/
public void Weapons_OnWeaponCreated(int weapon){
	
	static int weaponID; weaponID = -1;
	
	weaponID = readWeaponNetworkedIndex(weapon);
	
	// Validate custom weapon
	Bazooka_OnWeaponCreated(-1, weapon, weaponID);
	Chainsaw_OnWeaponCreated(-1, weapon, weaponID);
	
	if (weaponID != -1){
		ZWeapon zweapon = ZWeapon(weaponID);
		
		// World model
		zweapon.SetWorldModel(weapon);
	}
}

/**
 * @brief Find the index at which the weapon name is at.
 * 
 * @param sName             The weapon name.
 * @return                  The array index containing the given weapon name.
 **/
/*
stock int WeaponsNameToIndex(char[] sName){
	
	// Initialize name char
	static char sWeaponName[SMALL_LINE_LENGTH];
	
	// i = weapon index
	int iSize = WeaponsName.Length;
	for (int i = 0; i < iSize; i++){
	
		// Gets weapon name 
		WeaponsGetName(i, sWeaponName, sizeof(sWeaponName));
		
		// If names match, then return index
		if(!strcmp(sName, sWeaponName, false)){
			// Return this index
			return i;
		}
	}
	
	// Name doesn't exist
	return -1;
}*/

stock int CreateNetworkedWeaponEnt(int client, int weaponArrayID){
	int iEntWeapon;
	static float vecPos[3];
	
	ZWeapon weapon = ZWeapon(weaponArrayID);
	
	char sBuffer[24];
	weapon.GetEnt(sBuffer, sizeof(sBuffer));
	
	iEntWeapon = CreateEntityByName(sBuffer);
	//DispatchKeyValue(iEntWeapon, "classname", "weapon_awp");
	
	char sTargetName[32];
	
	if (weapon.iType == WEAPON_PRIMARY){
		FormatEx(sTargetName, sizeof(sTargetName), "primary_%d", weaponArrayID);
	}
	else{
		FormatEx(sTargetName, sizeof(sTargetName), "secondary_%d", weaponArrayID);
	}
	
	DispatchKeyValue(iEntWeapon, "targetname", sTargetName);
	
	if (weaponArrayID == iWeaponBazooka){
		DispatchKeyValue(iEntWeapon, "ammo", "1");
	}
	
	GetClientEyePosition(client, vecPos);
	DispatchSpawn(iEntWeapon);
	
	weapon.SetNetworkedName(iEntWeapon);
	TeleportEntity(iEntWeapon, vecPos, NULL_VECTOR, NULL_VECTOR);

	return iEntWeapon;
}
void ZWeapons_OnMapStart(){
	
	// Weapons OnMapStart
	PrecacheEffect(BAZOOKA_PARTICLES_PCF1);
	PrecacheEffect(BAZOOKA_PARTICLES_PCF2);
	PrecacheEffect(BAZOOKA_PARTICLES_PCF3);
	
	// Precache weapons particles
	PrecacheParticleEffect(BAZOOKA_MODEL_MUZZLE);
	PrecacheParticleEffect(BAZOOKA_ROCKET_EFFECT_PARTICLE);
	PrecacheParticleEffect(BAZOOKA_EXPLOSION_EFFECT_PARTICLE);
}

// Register weapons
void LoadWeapons(){
	
	// WEAPONS DATA BUFFERS
	char sWV[52][WEAPONS_MODELS_MAXPATH];
	char sWW[52][WEAPONS_MODELS_MAXPATH];
	char sWD[52][WEAPONS_MODELS_MAXPATH];
	
	FormatEx(sWV[0], WEAPONS_MODELS_MAXPATH, "models/weapons/ak117/v_rif_ak117.mdl");
	FormatEx(sWW[0], WEAPONS_MODELS_MAXPATH, "models/weapons/ak117/w_rif_ak117.mdl");
	
	FormatEx(sWV[1], WEAPONS_MODELS_MAXPATH, "models/weapons/mp5/v_smg_mp5.mdl");
	FormatEx(sWW[1], WEAPONS_MODELS_MAXPATH, "models/weapons/mp5/w_smg_mp5.mdl");
	
	FormatEx(sWV[2], WEAPONS_MODELS_MAXPATH, "models/weapons/m98/v_snip_m98.mdl");
	FormatEx(sWW[2], WEAPONS_MODELS_MAXPATH, "models/weapons/m98/w_snip_m98.mdl");
	
	FormatEx(sWV[3], WEAPONS_MODELS_MAXPATH, "models/weapons/eminem/crysis3_predator_bow/v_crysis3_predator_bow.mdl");
	FormatEx(sWW[3], WEAPONS_MODELS_MAXPATH, "models/weapons/eminem/crysis3_predator_bow/w_crysis3_predator_bow_dropped.mdl");
	
	FormatEx(sWV[4], WEAPONS_MODELS_MAXPATH, "models/weapons/eminem/gold_fararm_atf_12/v_gold_fararm_atf_12.mdl");
	FormatEx(sWW[4], WEAPONS_MODELS_MAXPATH, "models/weapons/eminem/gold_fararm_atf_12/w_gold_fararm_atf_12_dropped.mdl");
	
	FormatEx(sWV[5], WEAPONS_MODELS_MAXPATH, "models/weapons/v_shot_freedom.mdl");
	FormatEx(sWW[5], WEAPONS_MODELS_MAXPATH, "models/weapons/w_shot_freedom.mdl");
	FormatEx(sWD[5], WEAPONS_MODELS_MAXPATH, "models/weapons/w_shot_freedom_dropped.mdl");
	
	FormatEx(sWV[6], WEAPONS_MODELS_MAXPATH, "models/weapons/eminem/cat_gun/v_cat_gun.mdl");
	FormatEx(sWW[6], WEAPONS_MODELS_MAXPATH, "models/weapons/eminem/cat_gun/w_cat_gun.mdl");
	
	FormatEx(sWV[7], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_m14ebr.mdl");
	FormatEx(sWW[7], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_m14ebr.mdl");
	FormatEx(sWD[7], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_m14ebr_dropped.mdl");
	
	FormatEx(sWV[8], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_spas12.mdl");
	FormatEx(sWW[8], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_spas12.mdl");
	
	FormatEx(sWV[9], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_smg_krissvector.mdl");
	FormatEx(sWW[9], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_smg_krissvector.mdl");
	
	FormatEx(sWV[10], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_shot_bulkcannon.mdl");
	FormatEx(sWW[10], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_shot_bulkcannon.mdl");
	
	FormatEx(sWV[11], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_smg_g21c.mdl");
	FormatEx(sWW[11], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_smg_g21c.mdl");
	
	FormatEx(sWV[12], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_rif_aac_honey_v2.mdl");
	FormatEx(sWW[12], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_aac_honey_v3.mdl");
	
	FormatEx(sWV[13], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_rif_ak74u.mdl");
	FormatEx(sWW[13], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_ak74u.mdl");
	
	FormatEx(sWV[14], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_snip_g3sg1_v2.mdl");
	FormatEx(sWW[14], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_snip_g3sg1_v2.mdl");
	
	FormatEx(sWV[15], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_rif_scar_h.mdl");
	FormatEx(sWW[15], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_scar_h.mdl");
	
	FormatEx(sWV[16], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_rif_fn-fal.mdl");
	FormatEx(sWW[16], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_fn-fal.mdl");
	
	FormatEx(sWV[17], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_rif_g36_v2.mdl");
	FormatEx(sWW[17], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_g36_v2.mdl");
	
	FormatEx(sWV[18], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_shot_ithaca.mdl");
	FormatEx(sWW[18], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_shot_ithaca.mdl");
	
	FormatEx(sWV[19], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_shot_ksg.mdl");
	FormatEx(sWW[19], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_shot_ksg.mdl");
	
	FormatEx(sWV[20], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_smg_dualmp5.mdl"); // BORRAR
	//FormatEx(sWW[20], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_smg_dualmp5.mdl"); // FALTA
	
	FormatEx(sWV[21], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_rif_fatex.mdl");
	FormatEx(sWW[21], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_fatex.mdl");
	
	FormatEx(sWV[22], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_pist_92fs_v2.mdl");
	//FormatEx(sWW[22], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_pist_a01r.mdl");
	
	FormatEx(sWV[23], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_pist_a01r_f.mdl");
	FormatEx(sWW[23], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_pist_a01r.mdl");
	
	FormatEx(sWV[24], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_fk14ak_fix.mdl");
	FormatEx(sWW[24], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_fk14ak.mdl");
	
	FormatEx(sWV[25], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_rif_galil89.mdl");
	FormatEx(sWW[25], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_galil89.mdl");
	
	FormatEx(sWV[26], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_rif_bo1famas.mdl");
	FormatEx(sWW[26], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_bo1famas.mdl");
	
	FormatEx(sWV[27], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_rif_acr.mdl");
	FormatEx(sWW[27], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_acr.mdl");
	
	FormatEx(sWV[28], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_smg_fhr40.mdl");
	//FormatEx(sWW[28], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_galil89.mdl"); // FALTA
	
	FormatEx(sWV[29], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_snip_m200.mdl");
	//FormatEx(sWW[29], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_galil89.mdl"); // FALTA
	
	FormatEx(sWV[30], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_rifle_nv4.mdl");
	FormatEx(sWW[30], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rifle_nv4.mdl");
	
	FormatEx(sWV[31], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_rif_r3k.mdl");
	FormatEx(sWW[31], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rifle_r3k.mdl");
	
	FormatEx(sWV[32], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_shot_winchester_m1897.mdl");
	FormatEx(sWW[32], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_shot_winchester_m1897.mdl");
	
	FormatEx(sWV[33], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_shot_reaver.mdl");
	FormatEx(sWW[33], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_shot_reaver.mdl");
	
	FormatEx(sWV[34], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_shot_m45.mdl");
	FormatEx(sWW[34], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_shot_m45.mdl");
	
	FormatEx(sWV[35], WEAPONS_MODELS_MAXPATH, SURVIVOR_VMODEL_WEAPON);
	FormatEx(sWW[35], WEAPONS_MODELS_MAXPATH, SURVIVOR_WMODEL_WEAPON);
	
	FormatEx(sWV[36], WEAPONS_MODELS_MAXPATH, SNIPER_VMODEL_WEAPON);
	FormatEx(sWW[36], WEAPONS_MODELS_MAXPATH, SNIPER_WMODEL_WEAPON);
	
	FormatEx(sWV[37], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_mach_m134.mdl");
	FormatEx(sWW[37], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_mach_m134.mdl");
	
	FormatEx(sWV[38], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_rif_qbz89.mdl");
	FormatEx(sWW[38], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_qbz89.mdl");
	
	FormatEx(sWV[39], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_rif_tesla.mdl");
	FormatEx(sWW[39], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_tesla.mdl");
	
	FormatEx(sWV[40], WEAPONS_MODELS_MAXPATH, BAZOOKA_MODEL_V);
	FormatEx(sWW[40], WEAPONS_MODELS_MAXPATH, BAZOOKA_MODEL_W);
	
	FormatEx(sWV[41], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_rif_eel1.mdl");
	FormatEx(sWW[41], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_eel1.mdl");
	FormatEx(sWD[41], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_eel_dropped.mdl");
	
	FormatEx(sWV[42], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_smg_psd9.mdl");
	FormatEx(sWW[42], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_smg_psd9.mdl");
	
	FormatEx(sWV[43], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_smg_rk7.mdl");
	FormatEx(sWW[43], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_smg_rk7.mdl");
	
	FormatEx(sWV[44], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_smg_daemon.mdl");
	FormatEx(sWW[44], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_smg_daemon.mdl");
	FormatEx(sWD[44], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_smg_daemon_dropped.mdl");
	
	FormatEx(sWV[45], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_snip_outlaw_test.mdl");
	FormatEx(sWW[45], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_snip_outlaw_test.mdl");
	
	FormatEx(sWV[46], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_rif_helios.mdl");
	FormatEx(sWW[46], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_helios_1.mdl");
	FormatEx(sWD[46], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_helios_dropped.mdl");
	
	FormatEx(sWV[47], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_rif_val_black.mdl");
	FormatEx(sWW[47], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_val_black_1.mdl");
	FormatEx(sWD[47], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_rif_val_black_dropped.mdl");
	
	FormatEx(sWV[48], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/v_smg_codol.mdl");
	FormatEx(sWW[48], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_smg_codol.mdl");
	FormatEx(sWD[48], WEAPONS_MODELS_MAXPATH, "models/weapons/csstocsgo/w_smg_codol_dropped.mdl");
	
	FormatEx(sWV[49], WEAPONS_MODELS_MAXPATH, "models/weapons/julcito/v_m7bc54.mdl");
	FormatEx(sWW[49], WEAPONS_MODELS_MAXPATH, "models/weapons/julcito/w_m7bc54.mdl");
	
	FormatEx(sWV[50], WEAPONS_MODELS_MAXPATH, "models/weapons/julcito/v_crysis_rifle.mdl");
	FormatEx(sWW[50], WEAPONS_MODELS_MAXPATH, "models/weapons/julcito/w_crysis_rifle.mdl");
	
	FormatEx(sWV[51], WEAPONS_MODELS_MAXPATH, CHAINSAW_MODEL_V);
	FormatEx(sWW[51], WEAPONS_MODELS_MAXPATH, CHAINSAW_MODEL_W);
	FormatEx(sWD[51], WEAPONS_MODELS_MAXPATH, CHAINSAW_MODEL_DROPPED);
	
	//============================================================================
	//								WEAPONS
	//============================================================================
	//CreateWeapon(const char[] name, const char[] entityName, const char[] modelName, const char[] worldModelName, int level, int reset, float dmg, float knockback, int type)
	
	
	
	// 1
	CreateWeapon("Glock-18", 				"weapon_glock", 		"", 		"", 	"", 	1, 		0, 		 	110.0, 		0.1, 	WEAPON_SECONDARY, 0);
	
	// 2
	CreateWeapon("USP-S", 					"weapon_usp_silencer", 	"", 		"", 	"",		25, 	0, 		 	130.0, 		0.1, 	WEAPON_SECONDARY, 0);
	
	// 3
	CreateWeapon("P250", 					"weapon_p250", 			"", 		"", 	"",		50, 	0, 		 	150.0, 		0.1, 	WEAPON_SECONDARY, 0);
	
	// 4
	CreateWeapon("Five-SeveN", 				"weapon_fiveseven", 	"", 		"", 	"",		75, 	0, 		 	180.0, 		0.1, 	WEAPON_SECONDARY, 0);
	
	// 8
	CreateWeapon("Dual Berettas", 			"weapon_elite", 		"", 		"", 	"",		100, 	0, 		 	200.0, 		0.1, 	WEAPON_SECONDARY, 0);
	
	// 9
	CreateWeapon("CZ75-Auto", 				"weapon_cz75a", 		"", 		"", 	"",		200, 	0, 		 	215.0, 		0.1, 	WEAPON_SECONDARY, 0);
	
	// 12
	CreateWeapon("Tec-9", 					"weapon_tec9", 			"", 		"", 	"",		250, 	0, 		 	240.0, 		0.1, 	WEAPON_SECONDARY, 0);
	
	// 13
	CreateWeapon("Desert Eagle", 			"weapon_deagle", 		"", 		"", 	"",		300, 	0, 			340.0, 		0.1, 	WEAPON_SECONDARY, 0);
	
	// Weapons
	
	// MENU ORIGINAL
	/*CreateWeapon("RK7 Garrison", 			"weapon_mac10", 		sWV[43], 	sWW[43], 	1, 		0, 		 	154.25, 	8.5, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Bizon", 					"weapon_bizon", 		"", 		"", 		12, 	0, 		 	157.3, 		8.5, 	WEAPON_PRIMARY, 0);
	CreateWeapon("MP7", 					"weapon_mp7",			"", 		"", 		27, 	0, 		 	159.5, 		8.5, 	WEAPON_PRIMARY, 0);
	CreateWeapon("UMP-45", 					"weapon_ump45", 		"", 		"", 		38, 	0, 		 	163.3, 		8.51, 	WEAPON_PRIMARY, 0);
	CreateWeapon("SD-MP5 Navy", 			"weapon_mp5sd", 		"", 		"", 		52, 	0, 		 	172.7, 		8.52, 	WEAPON_PRIMARY, 0);
	CreateWeapon("P90", 					"weapon_p90", 			"", 		"", 		64, 	0, 			186.1, 		8.53, 	WEAPON_PRIMARY, 0);
	CreateWeapon("EO-T G21-C", 				"weapon_mp7", 			sWV[11], 	sWW[11], 	77, 	1, 			228.6, 		9.6, 	WEAPON_PRIMARY, 0); // 1 rr
	CreateWeapon("Vector A9", 				"weapon_p90", 			sWV[9], 	sWW[9], 	79, 	0, 		 	202.5, 		8.6, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Shotgun XM1014", 			"weapon_xm1014", 		"", 		"", 		88, 	0, 		 	174.5, 		10.1, 	WEAPON_PRIMARY, 0);
	//CreateWeapon("Black Ithaca", 			"weapon_nova", 			sWV[18], 	sWW[18], 	97, 	0, 		 	w5, 		1.2, 	WEAPON_PRIMARY);
	CreateWeapon("Golden ATF-12", 			"weapon_xm1014", 		sWV[4], 	sWW[4], 	109, 	11, 		198.0, 		10.2, 	WEAPON_PRIMARY, 0); // 11 rr
	CreateWeapon("Galil AR", 				"weapon_galilar", 		"", 		"", 		113, 	0, 			226.9, 		7.6, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Daemon 3XB", 				"weapon_mp5sd", 		sWV[44], 	sWW[44], 	115, 	37, 		398.25, 	7.6, 	WEAPON_PRIMARY, 0); // 58 rr
	CreateWeapon("Micro AK-74U", 			"weapon_ak47", 			sWV[13], 	sWW[13], 	117, 	0, 			270.0, 		8.8, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Military NV4",			"weapon_m4a1", 			sWV[30], 	sWW[30], 	121, 	10, 	 	401.0, 		8.6, 	WEAPON_PRIMARY, 0); // 10 rr
	CreateWeapon("Sig 556", 				"weapon_sg556", 		"", 		"", 		126, 	0, 			280.0, 		8.0, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Augmented G36", 			"weapon_famas", 		sWV[17], 	sWW[17], 	133, 	3, 	 		335.5, 		8.8, 	WEAPON_PRIMARY, 0); // 3 rr
	CreateWeapon("M4A4", 					"weapon_m4a1", 			"", 		"", 		139, 	0, 		 	290.1, 		8.9, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Dominator R3K",			"weapon_ak47", 			sWV[31], 	sWW[31], 	145, 	6, 	 		380.5, 		8.9, 	WEAPON_PRIMARY, 0); // 6 rr
	CreateWeapon("Val Black", 				"weapon_m4a1", 			sWV[47], 	sWW[47], 	147, 	85, 		744.25, 	8.1, 	WEAPON_PRIMARY, 0); // 85 rr
	CreateWeapon("AUG", 					"weapon_aug", 			"", 		"", 		148, 	0, 		 	340.2, 		8.1, 	WEAPON_PRIMARY, 0);
	CreateWeapon("BO1 Famas",				"weapon_famas", 		sWV[26], 	sWW[26], 	155, 	20, 	 	470.21, 	8.2, 	WEAPON_PRIMARY, 0); // 20 rr
	CreateWeapon("AK-47", 					"weapon_ak47", 			"", 		"", 		157, 	0, 		 	480.3, 		10.2, 	WEAPON_PRIMARY, 0);
	CreateWeapon("RIF Galil 89",			"weapon_galilar", 		sWV[25], 	sWW[25], 	162, 	8, 	 		450.12, 	8.3, 	WEAPON_PRIMARY, 0); // 8 rr
	CreateWeapon("M4A1-S",					"weapon_m4a1_silencer", "", 		"", 		168, 	0, 		 	460.4, 		8.3, 	WEAPON_PRIMARY, 0);
	CreateWeapon("SCAR-H", 					"weapon_m4a1", 			sWV[15], 	sWW[15], 	177, 	13, 		490.5, 		8.3, 	WEAPON_PRIMARY, 0); // 13 rr
	CreateWeapon("Machine Gun", 			"weapon_m249", 			"", 		"", 		181, 	0, 			355.0, 		7.0, 	WEAPON_PRIMARY, 0);
	iWeaponSurvivor = CreateWeapon("Minigun", "weapon_negev", 		sWV[37], 	sWW[37], 	198, 	145, 		610.2, 		1.6, 	WEAPON_PRIMARY, 0); // 145 rr
	CreateWeapon("FK14 AK",					"weapon_ak47", 			sWV[24], 	sWW[24], 	199, 	7, 	 		510.8, 		10.5, 	WEAPON_PRIMARY, 0); // 7 rr
	CreateWeapon("BO1 Famas",				"weapon_famas", 		sWV[26], 	sWW[26], 	155, 	20, 	 	470.21, 	8.2, 	WEAPON_PRIMARY, 0); // 20 rr
	CreateWeapon("AK-47", 					"weapon_ak47", 			"", 		"", 		157, 	0, 		 	480.3, 		10.2, 	WEAPON_PRIMARY, 0);
	CreateWeapon("RIF Galil 89",			"weapon_galilar", 		sWV[25], 	sWW[25], 	162, 	8, 	 		450.12, 	8.3, 	WEAPON_PRIMARY, 0); // 8 rr
	CreateWeapon("M4A1-S",					"weapon_m4a1_silencer", "", 		"", 		168, 	0, 		 	460.4, 		8.3, 	WEAPON_PRIMARY, 0);
	CreateWeapon("SCAR-H", 					"weapon_m4a1", 			sWV[15], 	sWW[15], 	177, 	13, 		490.5, 		8.3, 	WEAPON_PRIMARY, 0); // 13 rr
	CreateWeapon("Machine Gun", 			"weapon_m249", 			"", 		"", 		181, 	0, 			355.0, 		7.0, 	WEAPON_PRIMARY, 0);
	CreateWeapon("FK14 AK",					"weapon_ak47", 			sWV[24], 	sWW[24], 	199, 	7, 	 		510.8, 		10.5, 	WEAPON_PRIMARY, 0); // 7 rr
	CreateWeapon("AK-117",					"weapon_ak47", 			sWV[0], 	sWW[0], 	208, 	28, 	 	890.9, 		11.2, 	WEAPON_PRIMARY, 0); // 28 rr
	CreateWeapon("Scout SSG08",				"weapon_ssg08", 		"", 		"", 		219, 	0, 		 	6640.6, 	15.0, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Assault QBZ", 			"weapon_aug", 			sWV[38], 	sWW[38], 	225, 	41, 		1015.2, 	11.1, 	WEAPON_PRIMARY, 0); // 41 rr
	CreateWeapon("Predator Bow",			"weapon_awp", 			sWV[3], 	sWW[3], 	230, 	15, 	 	8400.0, 	40.0, 	WEAPON_PRIMARY, 0); // 15 rr
	CreateWeapon("Semi G3SG1",				"weapon_g3sg1", 		"", 		"", 		241, 	0, 		 	690.6, 		10.1, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Vulk Cannon", 			"weapon_xm1014", 		sWV[10], 	sWW[10], 	256, 	25, 		480.0, 		10.5, 	WEAPON_PRIMARY, 0); // 25 rr
	CreateWeapon("Semi SCAR20",				"weapon_scar20", 		"", 		"", 		263, 	0, 		 	760.6, 		10.5, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Tactical SG31", 			"weapon_g3sg1", 		sWV[14], 	sWW[14], 	274, 	5, 		 	970.1, 		10.5, 	WEAPON_PRIMARY, 0); // 5 rr
	CreateWeapon("Tactical ACR",			"weapon_galilar", 		sWV[27], 	sWW[27], 	285, 	45, 	 	1090.27, 	7.6, 	WEAPON_PRIMARY, 0); // 45 rr
	CreateWeapon("M60 Para", 				"weapon_m249", 			sWV[35], 	sWW[35], 	282, 	0, 			580.0, 		6.0, 	WEAPON_PRIMARY, 0);
	CreateWeapon("M14", 					"weapon_scar20", 		sWV[7], 	sWW[7], 	291, 	32, 	 	1900.5, 	6.0, 	WEAPON_PRIMARY, 0); // 32 rr
	CreateWeapon("Ice DSR-50", 				"weapon_awp", 			sWV[2], 	sWW[2], 	303, 	0, 			7680.0, 	5.0, 	WEAPON_PRIMARY, 0, _, HIT_TYPE_FREEZE);
	CreateWeapon("Fire DSR-50", 			"weapon_awp", 			sWV[2], 	sWW[2], 	317, 	17, 		9580.6, 	11.0, 	WEAPON_PRIMARY, 0, _, HIT_TYPE_BURN); // 17 rr
	CreateWeapon("M4 TESLA", 				"weapon_m4a1", 			sWV[39], 	sWW[39],	321, 	51, 		1210.2, 	7.1, 	WEAPON_PRIMARY, 0); // 51 rr
	CreateWeapon("Striker FN FAL", 			"weapon_galilar", 		sWV[16], 	sWW[16], 	330, 	0, 		 	780.5, 		7.5, 	WEAPON_PRIMARY, 0);
	CreateWeapon("FATE M4A1S", 				"weapon_m4a1_silencer", sWV[21], 	sWW[21], 	346, 	55, 		1360.0, 	7.5, 	WEAPON_PRIMARY, 0); // 55 rr
	CreateWeapon("SPAS-12", 				"weapon_nova", 			sWV[8], 	sWW[8], 	355, 	0, 		 	680.8, 		7.5, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Mutant KSG", 				"weapon_nova", 			sWV[19], 	sWW[19], 	364, 	60, 	 	1080.5, 	7.5, 	WEAPON_PRIMARY, 0); // 60 rr
	CreateWeapon("Tesla EEL", 				"weapon_famas", 		sWV[41], 	sWW[41], 	372, 	95, 		1400.25, 	7.0, 	WEAPON_PRIMARY, 0); // 95 rr
	CreateWeapon("The Reaver",				"weapon_mag7", 			sWV[33], 	sWW[33], 	373, 	65, 	 	1000.5, 	8.5, 	WEAPON_PRIMARY, 0); // 65 rr
	CreateWeapon("HELIOS Deleter", 			"weapon_galilar", 		sWV[46], 	sWW[46], 	373, 	115, 		1500.25, 	8.3, 	WEAPON_PRIMARY, 0); // 115 rr*/
	// MENU ORIGINAL
	
	// Tier 0: 0-24 RR
	CreateWeapon("RK7 Garrison", 			"weapon_mac10", 		sWV[43], 	sWW[43], 	sWD[43], 	1, 		0, 		 	154.25, 	1.5, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Bizon", 					"weapon_bizon", 		"", 		"", 		"",			12, 	0, 		 	157.3, 		1.5, 	WEAPON_PRIMARY, 0);
	CreateWeapon("MP7", 					"weapon_mp7",			"", 		"", 		"", 		27, 	0, 		 	159.5, 		1.5, 	WEAPON_PRIMARY, 0);
	CreateWeapon("UMP-45", 					"weapon_ump45", 		"", 		"", 		"", 		38, 	0, 		 	163.3, 		1.51, 	WEAPON_PRIMARY, 0);
	CreateWeapon("SD-MP5 Navy", 			"weapon_mp5sd", 		"", 		"", 		"",  		52, 	0, 		 	172.7, 		1.52, 	WEAPON_PRIMARY, 0);
	CreateWeapon("P90", 					"weapon_p90", 			"", 		"",  		"", 		64, 	0, 			186.1, 		1.53, 	WEAPON_PRIMARY, 0);
	CreateWeapon("EO-T G21-C", 				"weapon_mp7", 			sWV[11], 	sWW[11], 	sWD[11],	77, 	1, 			228.6, 		3.6, 	WEAPON_PRIMARY, 0); // 1 rr
	CreateWeapon("Vector A9", 				"weapon_p90", 			sWV[9], 	sWW[9], 	sWD[9],		79, 	0, 		 	202.5, 		3.6, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Shotgun XM1014", 			"weapon_xm1014", 		"", 		"", 		"",			88, 	0, 		 	174.5, 		10.1, 	WEAPON_PRIMARY, 0);
	//CreateWeapon("Black Ithaca", 			"weapon_nova", 			sWV[18], 	sWW[18], 	97, 	0, 		 	w5, 		1.2, 	WEAPON_PRIMARY);
	CreateWeapon("Golden ATF-12", 			"weapon_xm1014", 		sWV[4], 	sWW[4], 	sWD[4],		109, 	6, 			198.0, 		10.2, 	WEAPON_PRIMARY, 0); // 11 rr
	CreateWeapon("Galil AR", 				"weapon_galilar", 		"", 		"", 		"",			113, 	0, 			260.9, 		7.6, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Micro AK-74U", 			"weapon_ak47", 			sWV[13], 	sWW[13], 	sWD[13], 	117, 	0, 			270.0, 		8.8, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Military NV4",			"weapon_m4a1", 			sWV[30], 	sWW[30], 	sWD[30], 	126, 	10, 	 	401.0, 		8.6, 	WEAPON_PRIMARY, 0); // 10 rr
	CreateWeapon("Sig 556", 				"weapon_sg556", 		"", 		"", 		"",			130, 	0, 			300.0, 		8.0, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Augmented G36", 			"weapon_famas", 		sWV[17], 	sWW[17], 	sWD[17], 	138, 	3, 	 		335.5, 		8.8, 	WEAPON_PRIMARY, 0); // 3 rr
	CreateWeapon("M4A4", 					"weapon_m4a1", 			"", 		"", 		"",			142, 	0, 		 	350.1, 		8.9, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Dominator R3K",			"weapon_ak47", 			sWV[31], 	sWW[31], 	sWD[31], 	146, 	6, 	 		380.5, 		8.9, 	WEAPON_PRIMARY, 0); // 6 rr
	CreateWeapon("AUG", 					"weapon_aug", 			"", 		"", 		"", 		152, 	0, 		 	390.2, 		8.1, 	WEAPON_PRIMARY, 0);
	CreateWeapon("BO1 Famas",				"weapon_famas", 		sWV[26], 	sWW[26], 	sWD[26], 	155, 	18, 	 	490.21, 	8.2, 	WEAPON_PRIMARY, 0); // 20 rr
	CreateWeapon("AK-47", 					"weapon_ak47", 			"", 		"", 		"", 		159, 	0, 		 	480.3, 		10.2, 	WEAPON_PRIMARY, 0);
	CreateWeapon("RIF Galil 89",			"weapon_galilar", 		sWV[25], 	sWW[25], 	sWD[25], 	162, 	8, 	 		450.12, 	8.3, 	WEAPON_PRIMARY, 0); // 8 rr
	CreateWeapon("M4A1-S",					"weapon_m4a1_silencer", "", 		"", 		"",			168, 	0, 		 	460.4, 		8.3, 	WEAPON_PRIMARY, 0);
	CreateWeapon("SCAR-H", 					"weapon_m4a1", 			sWV[15], 	sWW[15], 	sWD[15], 	177, 	11, 		490.5, 		8.3, 	WEAPON_PRIMARY, 0); // 13 rr
	CreateWeapon("Machine Gun", 			"weapon_m249", 			"", 		"", 		"", 		181, 	0, 			355.0, 		7.0, 	WEAPON_PRIMARY, 0);
	CreateWeapon("FK14 AK",					"weapon_ak47", 			sWV[24], 	sWW[24], 	sWD[24], 	199, 	7, 	 		530.8, 		10.5, 	WEAPON_PRIMARY, 0); // 7 rr
	CreateWeapon("Scout SSG08",				"weapon_ssg08", 		"", 		"", 		"", 		219, 	0, 		 	6640.6, 	15.0, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Predator Bow",			"weapon_awp", 			sWV[3], 	sWW[3], 	sWD[3], 	230, 	13, 	 	8400.0, 	40.0, 	WEAPON_PRIMARY, 0); // 15 rr
	CreateWeapon("Semi SCAR20",				"weapon_scar20", 		"", 		"", 		"", 		263, 	0, 		 	1100.6, 	10.5, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Tactical SG31", 			"weapon_g3sg1", 		sWV[14], 	sWW[14], 	sWD[14], 	274, 	5, 		 	1400.1, 	10.5, 	WEAPON_PRIMARY, 0); // 5 rr
	CreateWeapon("M60 Para", 				"weapon_m249", 			sWV[35], 	sWW[35], 	sWD[35], 	282, 	0, 			580.0, 		6.0, 	WEAPON_PRIMARY, 0);
	CreateWeapon("Ice DSR-50", 				"weapon_awp", 			sWV[2], 	sWW[2], 	sWD[2], 	303, 	0, 			7680.0, 	5.0, 	WEAPON_PRIMARY, 0, _, HIT_TYPE_FREEZE);
	CreateWeapon("Fire DSR-50", 			"weapon_awp", 			sWV[2], 	sWW[2], 	sWD[2],		317, 	21, 		9580.6, 	11.0, 	WEAPON_PRIMARY, 0, _, HIT_TYPE_BURN); // 17 rr
	CreateWeapon("Striker FN FAL", 			"weapon_galilar", 		sWV[16], 	sWW[16], 	sWD[16], 	330, 	0, 		 	780.5, 		7.5, 	WEAPON_PRIMARY, 0);
	CreateWeapon("SPAS-12", 				"weapon_nova", 			sWV[8], 	sWW[8], 	sWD[8], 	355, 	0, 		 	790.8, 		7.5, 	WEAPON_PRIMARY, 0);
	
	// Tier 1: 25-49 RR
	CreateWeapon("Bizon", 					"weapon_bizon", 		"", 		"", 		"",	 		1, 		0,		 	220.3, 		2.5, 	WEAPON_PRIMARY, 1);
	CreateWeapon("MP7", 					"weapon_mp7",			"", 		"", 		"", 		18, 	0, 	 		245.5, 		2.5, 	WEAPON_PRIMARY, 1);
	CreateWeapon("UMP-45", 					"weapon_ump45", 		"", 		"", 		"", 		38, 	0, 		 	286.3, 		2.51, 	WEAPON_PRIMARY, 1);
	CreateWeapon("SD-MP5 Navy", 			"weapon_mp5sd", 		"", 		"", 		"", 		52, 	0, 		 	300.7, 		2.52, 	WEAPON_PRIMARY, 1);
	CreateWeapon("RK7 Garrison", 			"weapon_mac10", 		sWV[43], 	sWW[43], 	sWD[43], 	78, 	0, 			330.25, 	2.5, 	WEAPON_PRIMARY, 1);
	CreateWeapon("P90", 					"weapon_p90", 			"", 		"", 		"", 		86, 	0, 			360.1, 		2.53, 	WEAPON_PRIMARY, 1);
	CreateWeapon("EO-T G21-C", 				"weapon_mp7", 			sWV[11], 	sWW[11], 	sWD[11], 	105, 	0, 			415.6, 		4.6, 	WEAPON_PRIMARY, 1); // 1 rr
	
	CreateWeapon("Vector A9", 				"weapon_p90", 			sWV[9], 	sWW[9], 	sWD[9], 	121, 	27, 		410.5, 		4.6, 	WEAPON_PRIMARY, 1);
	CreateWeapon("Shotgun XM1014", 			"weapon_xm1014", 		"", 		"", 		"", 		133, 	0, 			270.5, 		10.1, 	WEAPON_PRIMARY, 1);
	CreateWeapon("Micro AK-74U", 			"weapon_ak47", 			sWV[13], 	sWW[13], 	sWD[13], 	152, 	28, 		510.0, 		4.8, 	WEAPON_PRIMARY, 1);
	CreateWeapon("Military NV4",			"weapon_m4a1", 			sWV[30], 	sWW[30], 	sWD[30], 	177, 	0, 	 		560.0, 		4.6, 	WEAPON_PRIMARY, 1); // 10 rr
	CreateWeapon("Sig 556", 				"weapon_sg556", 		"", 		"", 		"", 		189, 	0, 			590.0, 		4.0, 	WEAPON_PRIMARY, 1);
	CreateWeapon("M4A4", 					"weapon_m4a1", 			"", 		"", 		"", 		211, 	0, 		 	640.1, 		4.9, 	WEAPON_PRIMARY, 1);
	CreateWeapon("Semi G3SG1",				"weapon_g3sg1", 		"", 		"", 		"", 		220, 	0, 	 		1420.6, 	10.1, 	WEAPON_PRIMARY, 1);
	CreateWeapon("Augmented G36", 			"weapon_famas", 		sWV[17], 	sWW[17], 	sWD[17], 	233, 	26,	  		760.5, 		8.8, 	WEAPON_PRIMARY, 1); // 3 rr
	
	CreateWeapon("Dominator R3K",			"weapon_ak47", 			sWV[31], 	sWW[31], 	sWD[31], 	269, 	0, 			830.5, 		8.9, 	WEAPON_PRIMARY, 1); // 6 rr
	CreateWeapon("AK-117",					"weapon_ak47", 			sWV[0], 	sWW[0], 	sWD[0],		298, 	31, 	 	950.9, 		11.2, 	WEAPON_PRIMARY, 1); // 28 rr
	CreateWeapon("Scout SSG08",				"weapon_ssg08", 		"", 		"", 		"", 		304, 	0, 	 		8850.6, 	15.0, 	WEAPON_PRIMARY, 1);
	CreateWeapon("Assault QBZ", 			"weapon_aug", 			sWV[38], 	sWW[38], 	sWD[38], 	328, 	0, 			1015.2, 	11.1, 	WEAPON_PRIMARY, 1); // 41 rr
	CreateWeapon("Vulk Cannon", 			"weapon_xm1014", 		sWV[10], 	sWW[10], 	sWD[10], 	351, 	0, 			570.0, 		10.5, 	WEAPON_PRIMARY, 1); // 25 rr
	CreateWeapon("Tactical ACR",			"weapon_galilar", 		sWV[27], 	sWW[27], 	sWD[27], 	371, 	0, 	 		1090.27, 	7.6, 	WEAPON_PRIMARY, 1); // 45 rr
	CreateWeapon("M14", 					"weapon_scar20", 		sWV[7], 	sWW[7], 	sWD[7], 	382, 	40, 	 	2300.5, 	6.0, 	WEAPON_PRIMARY, 1); // 32 rr
	
	
	// Tier 2: 50-99 RR
	CreateWeapon("MP7", 					"weapon_mp7",			"", 		"", 		"", 		1, 		0, 	 		230.5, 		2.5, 	WEAPON_PRIMARY, 2);
	CreateWeapon("UMP-45", 					"weapon_ump45", 		"", 		"", 		"", 		27, 	0, 			250.3, 		2.51, 	WEAPON_PRIMARY, 2);
	CreateWeapon("SD-MP5 Navy", 			"weapon_mp5sd", 		"", 		"", 		"", 		49, 	0, 	 		290.7, 		2.52, 	WEAPON_PRIMARY, 2);
	CreateWeapon("P90", 					"weapon_p90", 			"", 		"", 		"", 		64, 	0, 			320.1, 		2.53, 	WEAPON_PRIMARY, 2);
	
	CreateWeapon("RK7 Garrison", 			"weapon_mac10", 		sWV[43], 	sWW[43], 	sWD[43], 	78, 	0, 			340.25, 	2.5, 	WEAPON_PRIMARY, 2);
	CreateWeapon("Vector A9", 				"weapon_p90", 			sWV[9], 	sWW[9], 	sWD[9], 	79, 	0, 			360.5, 		2.6, 	WEAPON_PRIMARY, 2);
	CreateWeapon("Shotgun XM1014", 			"weapon_xm1014", 		"", 		"", 		"", 		88, 	0, 			290.5, 		10.1, 	WEAPON_PRIMARY, 2);
	CreateWeapon("EO-T G21-C", 				"weapon_mp7", 			sWV[11], 	sWW[11], 	sWD[11], 	103, 	0, 			418.6, 		3.6, 	WEAPON_PRIMARY, 2); // 1 rr
	
	CreateWeapon("Galil AR", 				"weapon_galilar", 		"", 		"", 		"", 		128, 	0, 			460.9, 		7.6, 	WEAPON_PRIMARY, 2);
	CreateWeapon("Micro AK-74U", 			"weapon_ak47", 			sWV[13], 	sWW[13], 	sWD[13], 	142, 	0, 			500.0, 		8.8, 	WEAPON_PRIMARY, 2);
	CreateWeapon("Augmented G36", 			"weapon_famas", 		sWV[17], 	sWW[17], 	sWD[17], 	161, 	0, 	 		530.5, 		8.8, 	WEAPON_PRIMARY, 2); // 3 rr
	CreateWeapon("M4A4", 					"weapon_m4a1", 			"", 		"", 		"", 		186, 	0, 			580.1, 		8.9, 	WEAPON_PRIMARY, 2);
	CreateWeapon("Military NV4",			"weapon_m4a1", 			sWV[30], 	sWW[30], 	sWD[30], 	207, 	0, 	 		640.0, 		8.6, 	WEAPON_PRIMARY, 2); // 10 rr
	
	CreateWeapon("AUG", 					"weapon_aug", 			"", 		"", 		"", 		221, 	0, 			668.2, 		8.1, 	WEAPON_PRIMARY, 2);
	CreateWeapon("Dominator R3K",			"weapon_ak47", 			sWV[31], 	sWW[31], 	sWD[31], 	240, 	0, 	 		700.5, 		8.9, 	WEAPON_PRIMARY, 2); // 6 rr
	CreateWeapon("Golden ATF-12", 			"weapon_xm1014", 		sWV[4], 	sWW[4], 	sWD[4], 	269, 	0, 			389.0, 		10.2, 	WEAPON_PRIMARY, 2); // 11 rr
	CreateWeapon("BO1 Famas",				"weapon_famas", 		sWV[26], 	sWW[26], 	sWD[26], 	288, 	0, 	 		720.21, 	8.2, 	WEAPON_PRIMARY, 2); // 20 rr
	CreateWeapon("Precision 3XB", 			"weapon_mp5sd", 		sWV[44], 	sWW[44], 	sWD[44], 	307, 	0, 			810.25, 	7.6, 	WEAPON_PRIMARY, 2); // 58 rr
	CreateWeapon("Tactical SG31", 			"weapon_g3sg1", 		sWV[14], 	sWW[14], 	sWD[14], 	321, 	0, 			1480.1, 	10.5, 	WEAPON_PRIMARY, 2); // 5 rr
	
	CreateWeapon("M4 TESLA", 				"weapon_m4a1", 			sWV[39], 	sWW[39],	sWD[39], 	347, 	65, 		1310.2, 	7.1, 	WEAPON_PRIMARY, 2); // 51 rr
	CreateWeapon("FATE M4A1S", 				"weapon_m4a1_silencer", sWV[21], 	sWW[21], 	sWD[21], 	363, 	52, 		1400.0, 	7.5, 	WEAPON_PRIMARY, 2); // 55 rr
	CreateWeapon("Mutant KSG", 				"weapon_nova", 			sWV[19], 	sWW[19], 	sWD[19], 	379, 	60, 	 	1080.5, 	7.5, 	WEAPON_PRIMARY, 2); // 60 rr
	
	
	// Tier 3: 100-149 RR
	CreateWeapon("SD-MP5 Navy", 			"weapon_mp5sd", 		"", 		"", 		"", 		1, 		0, 			260.7, 		2.52, 	WEAPON_PRIMARY, 3);
	CreateWeapon("P90", 					"weapon_p90", 			"", 		"", 		"", 		35, 	0, 			280.1, 		2.53, 	WEAPON_PRIMARY, 3);
	CreateWeapon("Vector A9", 				"weapon_p90", 			sWV[9], 	sWW[9], 	sWD[9], 	67, 	0, 			320.5, 		2.6, 	WEAPON_PRIMARY, 3);
	CreateWeapon("RK7 Garrison", 			"weapon_mac10", 		sWV[43], 	sWW[43], 	sWD[43], 	87, 	0, 			370.25, 	2.5, 	WEAPON_PRIMARY, 3);
	CreateWeapon("Shotgun XM1014", 			"weapon_xm1014", 		"", 		"", 		"", 		103, 	0, 			340.5, 		10.1, 	WEAPON_PRIMARY, 3);
	
	CreateWeapon("EO-T G21-C", 				"weapon_mp7", 			sWV[11], 	sWW[11], 	sWD[11], 	129, 	0, 			440.6, 		3.6, 	WEAPON_PRIMARY, 3); // 1 rr
	CreateWeapon("Micro AK-74U", 			"weapon_ak47", 			sWV[13], 	sWW[13], 	sWD[13], 	148, 	0, 			530.0, 		8.8, 	WEAPON_PRIMARY, 3);
	CreateWeapon("Augmented G36", 			"weapon_famas", 		sWV[17], 	sWW[17], 	sWD[17], 	166, 	0, 	 		587.5, 		8.8, 	WEAPON_PRIMARY, 3); // 3 rr
	CreateWeapon("M4A4", 					"weapon_m4a1", 			"", 		"", 		"", 		186, 	0, 			650.1, 		8.9, 	WEAPON_PRIMARY, 3);
	CreateWeapon("AUG", 					"weapon_aug", 			"", 		"", 		"", 		207, 	0, 			680.2, 		8.1, 	WEAPON_PRIMARY, 3);
	
	CreateWeapon("Military NV4",			"weapon_m4a1", 			sWV[30], 	sWW[30], 	sWD[30], 	221, 	0, 	 		730.0, 		8.6, 	WEAPON_PRIMARY, 3); // 10 rr
	CreateWeapon("Dominator R3K",			"weapon_ak47", 			sWV[31], 	sWW[31], 	sWD[31], 	240, 	0, 	 		780.5, 		8.9, 	WEAPON_PRIMARY, 3); // 6 rr
	CreateWeapon("Golden ATF-12", 			"weapon_xm1014", 		sWV[4], 	sWW[4], 	sWD[4], 	269, 	0, 			520.0, 		10.2, 	WEAPON_PRIMARY, 3); // 11 rr
	CreateWeapon("BO1 Famas",				"weapon_famas", 		sWV[26], 	sWW[26], 	sWD[26], 	288, 	0, 	 		860.21, 	8.2, 	WEAPON_PRIMARY, 3); // 20 rr
	CreateWeapon("Val Black", 				"weapon_m4a1", 			sWV[47], 	sWW[47], 	sWD[47], 	300, 	0, 			910.25, 	8.1, 	WEAPON_PRIMARY, 3); // 85 rr
	CreateWeapon("Reinforced SG31", 		"weapon_g3sg1", 		sWV[14], 	sWW[14], 	sWD[14], 	326, 	0, 			1900.1, 	10.5, 	WEAPON_PRIMARY, 3); // 5 rr
	
	CreateWeapon("M4 TESLA Amp", 			"weapon_m4a1", 			sWV[39], 	sWW[39],	sWD[39], 	335, 	0, 			1540.2, 	7.1, 	WEAPON_PRIMARY, 3); // 51 rr
	CreateWeapon("FATE M4A1S Amp", 			"weapon_m4a1_silencer", sWV[21], 	sWW[21], 	sWD[21], 	345, 	0, 			1620.0, 	7.5, 	WEAPON_PRIMARY, 3); // 55 rr
	
	CreateWeapon("Crysis carabin",			"weapon_m4a1", 			sWV[50], 	sWW[50], 	sWD[50], 	352, 	115, 	 	1790.5, 	3.6, 	WEAPON_PRIMARY, 3);
	CreateWeapon("The Reaver",				"weapon_mag7", 			sWV[33], 	sWW[33], 	sWD[33], 	377, 	0, 	 		1450.5, 	8.5, 	WEAPON_PRIMARY, 3); // 65 rr
	
	
	// Tier 4:  150-199 RR
	CreateWeapon("Vector A9", 				"weapon_p90", 			sWV[9], 	sWW[9], 	sWD[9], 	1, 		0, 		 	390.5, 		3.6, 	WEAPON_PRIMARY, 4);
	CreateWeapon("RK7 Garrison", 			"weapon_mac10", 		sWV[43], 	sWW[43], 	sWD[43],	36, 	0, 		 	420.25, 	3.5, 	WEAPON_PRIMARY, 4);
	CreateWeapon("EO-T G21-C", 				"weapon_mp7", 			sWV[11], 	sWW[11], 	sWD[11], 	59, 	0, 			490.6, 		4.6, 	WEAPON_PRIMARY, 4); // 1 rr
	CreateWeapon("3XB Amp", 				"weapon_mp5sd", 		sWV[44], 	sWW[44], 	sWD[44], 	89, 	0, 			510.25, 	3.6, 	WEAPON_PRIMARY, 4); // 58 rr
	CreateWeapon("Golden ATF-12", 			"weapon_xm1014", 		sWV[4], 	sWW[4], 	sWD[4], 	119, 	0, 			380.0, 		10.2, 	WEAPON_PRIMARY, 4); // 11 rr
	CreateWeapon("Micro AK-74U", 			"weapon_ak47", 			sWV[13], 	sWW[13], 	sWD[13], 	117, 	0, 			600.0, 		8.8, 	WEAPON_PRIMARY, 4);
	
	CreateWeapon("Military NV4",			"weapon_m4a1", 			sWV[30], 	sWW[30], 	sWD[30], 	135, 	0, 	 		615.0, 		8.6, 	WEAPON_PRIMARY, 4); // 10 rr
	CreateWeapon("Val Black", 				"weapon_m4a1", 			sWV[47], 	sWW[47], 	sWD[47], 	158, 	0, 			625.25, 	8.1, 	WEAPON_PRIMARY, 4); // 85 rr
	CreateWeapon("BO1 Famas Elite",			"weapon_famas", 		sWV[26], 	sWW[26], 	sWD[26], 	180, 	0, 	 		650.21, 	8.2, 	WEAPON_PRIMARY, 4); // 20 rr
	CreateWeapon("AK-117",					"weapon_ak47", 			sWV[0], 	sWW[0], 	sWD[0], 	208, 	0, 	 		890.9, 		11.2, 	WEAPON_PRIMARY, 4); // 28 rr
	CreateWeapon("Assault QBZ", 			"weapon_aug", 			sWV[38], 	sWW[38], 	sWD[38], 	225, 	152, 		1060.2, 	11.1, 	WEAPON_PRIMARY, 4); // 41 rr
	
	CreateWeapon("Vulk Cannon", 			"weapon_xm1014", 		sWV[10], 	sWW[10], 	sWD[10], 	256, 	0, 			680.0, 		10.5, 	WEAPON_PRIMARY, 4); // 25 rr
	CreateWeapon("Reinforced SG31", 		"weapon_g3sg1", 		sWV[14], 	sWW[14], 	sWD[14], 	274, 	0, 		 	1960.1, 	10.5, 	WEAPON_PRIMARY, 4); // 5 rr
	CreateWeapon("Tactical ACR",			"weapon_galilar", 		sWV[27], 	sWW[27], 	sWD[27], 	288, 	0, 	 		1090.7, 	7.6, 	WEAPON_PRIMARY, 4); // 45 rr
	CreateWeapon("Destroyer Fire Bow",		"weapon_awp", 			sWV[3], 	sWW[3], 	sWD[3], 	300, 	0, 	 		15400.0, 	40.0, 	WEAPON_PRIMARY, 4, _, HIT_TYPE_BURN); // 15 rr
	CreateWeapon("M7B-C54",					"weapon_mp9", 			sWV[49], 	sWW[49], 	sWD[49], 	305, 	170, 	 	1700.5, 	6.6, 	WEAPON_PRIMARY, 4);
	CreateWeapon("M14 Amp", 				"weapon_scar20", 		sWV[7], 	sWW[7], 	sWD[7], 	327, 	175,	 	2500.5, 	6.0, 	WEAPON_PRIMARY, 4); // 32 rr
	
	CreateWeapon("Tesla EEL", 				"weapon_famas", 		sWV[41], 	sWW[41], 	sWD[41], 	355, 	0, 			2000.25, 	7.0, 	WEAPON_PRIMARY, 4); // 95 rr
	CreateWeapon("FreeDOM", 				"weapon_mag7", 			sWV[5], 	sWW[5], 	sWD[5], 	381, 	0, 			1750.0, 	8.5, 	WEAPON_PRIMARY, 4); // 70 rr
	
	// Tier 5: +200 RR
	CreateWeapon("FULL RK7 Garrison", 		"weapon_mac10", 		sWV[43], 	sWW[43], 	sWD[43],	1, 		0, 		 	420.25, 	4.5, 	WEAPON_PRIMARY, 5);
	CreateWeapon("EO-T G21-N", 				"weapon_mp7", 			sWV[11], 	sWW[11], 	sWD[11], 	45, 	0, 			460.6, 		4.6, 	WEAPON_PRIMARY, 5);
	CreateWeapon("3XB Amp", 				"weapon_mp5sd", 		sWV[44], 	sWW[44], 	sWD[44], 	89, 	0, 			480.25, 	4.6, 	WEAPON_PRIMARY, 5);
	CreateWeapon("Shotgun XM1014", 			"weapon_xm1014", 		"", 		"", 		"", 		111, 	0, 		 	400.5, 		10.1, 	WEAPON_PRIMARY, 5);
	CreateWeapon("Golden ATF-12", 			"weapon_xm1014", 		sWV[4], 	sWW[4], 	sWD[4], 	133, 	0, 			450.0, 		10.2, 	WEAPON_PRIMARY, 5);
	CreateWeapon("Vulk Cannon", 			"weapon_xm1014", 		sWV[10], 	sWW[10], 	sWD[10], 	166, 	0, 			520.0, 		10.5, 	WEAPON_PRIMARY, 5);
	
	CreateWeapon("Military NV4",			"weapon_m4a1", 			sWV[30], 	sWW[30], 	sWD[30], 	187, 	0, 	 		615.0, 		8.6, 	WEAPON_PRIMARY, 5);
	CreateWeapon("Val Black", 				"weapon_m4a1", 			sWV[47], 	sWW[47], 	sWD[47], 	203, 	0, 			660.25, 	8.1, 	WEAPON_PRIMARY, 5);
	CreateWeapon("BO1 Famas Elite",			"weapon_famas", 		sWV[26], 	sWW[26], 	sWD[26], 	180, 	0, 	 		680.21, 	8.2, 	WEAPON_PRIMARY, 5);
	CreateWeapon("Supreme AK-117",			"weapon_ak47", 			sWV[0], 	sWW[0], 	sWD[0], 	208, 	0, 	 		990.9, 		11.2, 	WEAPON_PRIMARY, 5);
	CreateWeapon("Assault QBZ", 			"weapon_aug", 			sWV[38], 	sWW[38], 	sWD[38], 	225, 	0, 			1100.2, 	11.1, 	WEAPON_PRIMARY, 5);
	
	CreateWeapon("Marksman Tactical ACR",	"weapon_galilar", 		sWV[27], 	sWW[27], 	sWD[27], 	253, 	0, 	 		1190.7, 	7.6, 	WEAPON_PRIMARY, 5);
	CreateWeapon("Destroyer Fire Rifle",	"weapon_awp", 			sWV[2], 	sWW[2], 	sWD[2], 	280, 	0, 	 		18800.0, 	10.0, 	WEAPON_PRIMARY, 5, _, HIT_TYPE_BURN);
	CreateWeapon("MAXIMUS M14", 			"weapon_scar20", 		sWV[7], 	sWW[7], 	sWD[7], 	300, 	0, 	 		2680.5, 	6.0, 	WEAPON_PRIMARY, 5);
	CreateWeapon("M7B-C54",					"weapon_mp9", 			sWV[49], 	sWW[49], 	sWD[49], 	315, 	201, 	 	1880.5, 	6.6, 	WEAPON_PRIMARY, 5);
	
	CreateWeapon("Tesla EEL", 				"weapon_famas", 		sWV[41], 	sWW[41], 	sWD[41], 	325, 	0, 			2100.25, 	7.0, 	WEAPON_PRIMARY, 5);
	CreateWeapon("Crysis carabin",			"weapon_m4a1", 			sWV[50], 	sWW[50], 	sWD[50], 	332, 	0, 	 		2250.5, 	3.6, 	WEAPON_PRIMARY, 5);
	CreateWeapon("Helios MELTER", 			"weapon_galilar", 		sWV[46], 	sWW[46], 	sWD[46], 	345, 	0, 			2300.25, 	8.3, 	WEAPON_PRIMARY, 5);
	CreateWeapon("SMG Codol", 				"weapon_bizon", 		sWV[48], 	sWW[48], 	sWD[48],	360, 	205, 		2400.25, 	0.1, 	WEAPON_PRIMARY, 5);
	CreateWeapon("M45",						"weapon_nova", 			sWV[34], 	sWW[34], 	sWD[34], 	380, 	0, 	 		1900.5, 	15.6, 	WEAPON_PRIMARY, 5);
	
	
	// Aditional
	iWeaponMeow = 			CreateWeapon("MEOW!", 		"weapon_p90", 		sWV[6], 	sWW[6], 	sWD[6], 	1, 		999, 		2000.0, 	1.0, 	WEAPON_PRIMARY, 	6, false); 
	iWeaponSniper = 		CreateWeapon("DSR-50", 		"weapon_awp", 		sWV[36], 	sWW[36], 	sWD[36], 	1, 		999, 		6600.0, 	30.0, 	WEAPON_PRIMARY, 	6, false);
	iWeaponGunslinger =		CreateWeapon("BOSS DK", 	"weapon_deagle", 	"", 		"", 		"", 		1, 		999, 		2900.0, 	1.0, 	WEAPON_SECONDARY, 	6, false);
	iWeaponSurvivor = 		CreateWeapon("Minigun", 	"weapon_negev", 	sWV[37], 	sWW[37], 	sWD[37], 	198, 	145, 		610.2, 		1.6, 	WEAPON_PRIMARY, 	6, false); 
	iWeaponSuperSurvivor = 	CreateWeapon("FreeDOM", 	"weapon_mag7", 		sWV[5], 	sWW[5], 	sWD[5], 	381, 	70, 		1450.0, 	8.5, 	WEAPON_PRIMARY, 	6, false);
	
	iWeaponBazooka = 		CreateWeapon("BAZOOKA", 	"weapon_awp", 		sWV[40], 	sWW[40], 	sWD[40], 	1, 		0, 			4650.6, 	5.0, 	WEAPON_PRIMARY, 	6, false);
	iWeaponChainsaw = 		CreateWeapon("CHAINSAW", 	"weapon_negev",		sWV[51], 	sWW[51], 	sWD[51], 	1, 		0, 			2050.6, 	5.0, 	WEAPON_PRIMARY, 	6, false);
	
	//
	CreateWeapon("01R", 					"weapon_fiveseven", 	sWV[23], 	sWW[23], 	sWD[23],	1, 		0, 		 	4300.25, 	0.1, 	WEAPON_SECONDARY, 5, false);
	
	//CreateWeapon("PK-PSD9", 				"weapon_mp9", 			sWV[42], 	sWW[42], 	1, 		0, 		 	4300.25, 	0.1, 	WEAPON_PRIMARY, 5, false); // bug de model
	
	//CreateWeapon("Agile Outlaw", 			"weapon_ssg08", 		sWV[45], 	sWW[45], 	1, 		0, 		 	4300.25, 	0.1, 	WEAPON_PRIMARY, 5, false); // error de texturas en consola
	
	//CreateWeapon("92fs", 					"weapon_fiveseven", 	sWV[22], 	"", 		1, 		0, 		 	1.25, 		0.1, 	WEAPON_SECONDARY); // model bug
	
	
	/*
	
	CreateWeapon("FHR-40",				"weapon_p90", 				sWV[28], 	"", 		86, 	0, 	 			7.5, 	9.6, 	WEAPON_PRIMARY); // anim de disparo bug
	
	CreateWeapon("M2000",				"weapon_awp", 				sWV[29], 	"", 		86, 	0, 	 			7.5, 	9.6, 	WEAPON_PRIMARY); // anim de disparo bug
	
	CreateWeapon("Winchester",			"weapon_sawedoff", 			sWV[32], 	sWW[32], 	86, 	0, 	 			7.5, 	9.6, 	WEAPON_PRIMARY); // reload anim bugeada
	
	*/
}