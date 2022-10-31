
// EXPERIMENTAL
//#include <CustomPlayerSkins>

#include "zs/manager/player/zclasses.sp"
#include "zs/manager/player/hclasses.sp"
#include "zs/manager/player/zalignments.sp"
#include "zs/manager/player/halignments.sp"
#include "zs/manager/player/tools.sp"

#define ZPLAYER_MODULE_VERSION "0.1"

// Exp & points gain

// Allow gain
bool bAllowGain;

#define ZOMBIES_BASE_HEALTH_PER_DEATH 37500
#define RESET_AMOUNT_TO_REDUCE_HP_BUFF 50

#define RESET_AMOUNT_TO_ALLOW_ALL_WEAPONS 50

#define RESET_HUMAN_DAMAGE_BONUS_PCT 0.005
#define RESET_ZOMBIE_HP_BONUS_PCT  	0.03

#define WARMUP_ZBOSSES_MAX_HP 195000
#define WARMUP_HBOSSES_MAX_HP 1250

// Zombie default arms
#define ZOMBIE_DEFAULT_ARMS "models/player/colateam/zombie1/arms.mdl"

#define FIRST_ZOMBIE_MULTIPLIER 2.5
#define UNIQUE_HUMAN_MULTIPLIER	2.0
#define ZOMBIES_NEEDED_TO_RESPAWN_ZOMBIE 1/5
#define CHANCE_TO_RESPAWN_HUMAN 10

#define INFECTNADE_MIN_PLAYERS_TO_GIVE	10

// PIU Points 
#define PIUPOINTS_HUMAN_MAX_CHANCES 25.0
#define PIUPOINTS_HUMAN_MIN_CHANCES 8.0

#define PIUPOINTS_ZOMBIE_MAX_CHANCES 25.0
#define PIUPOINTS_ZOMBIE_MIN_CHANCES 10.0
#define PIUPOINTS_CHANCES_REDUCTION_PER_RESET 0.5

// Mutation
#define ZOMBIES_AMOUNT_TO_RAISE_CHANCES_TO_MUTATE 1/3
#define MUTATION_CHANCES_RAISED 20
#define MUTATION_CHANCES_STANDARD 5

// Infection heritage
#define INFECTION_HERITAGE_DURATION 5.0
#define INFECTION_HERITAGE_OINFECTOR_PCT 7/10
#define INFECTION_HERITAGE_INFECTOR_PCT 3/10

// Sound section
char InfectionSounds[][] = {
	"*/MassiveInfection/zombie_infection_female.mp3",
	"*/MassiveInfection/zombie_infection_male.mp3", 
	"*/MassiveInfection/zombie_voice_idle6.mp3", 
	"*/MassiveInfection/fz_scream1.mp3",
	"*/MassiveInfection/zombie_infec1.wav",
	"*/MassiveInfection/zombie_infec2.wav",
	"*/MassiveInfection/zombie_infec3.wav",
	"*/MassiveInfection/c1a0_sci_catscream.wav",
	"*/MassiveInfection/scream01.wav",
	"*/MassiveInfection/scream05.wav",
	"*/MassiveInfection/scream20.wav",
	"*/MassiveInfection/scream22.wav"
};
char ZPainSounds[][] = {
	"*/MassiveInfection/zombie_pain1.mp3",
	"*/MassiveInfection/zombie_pain2.mp3",
	"*/MassiveInfection/zombie_pain3.mp3",
	"*/MassiveInfection/zombi_hurt_1.mp3",
	"*/MassiveInfection/zombi_hurt_2.mp3"
};
char ZDieSounds[][] = {
	"*/MassiveInfection/zombie_die1.mp3",
	"*/MassiveInfection/zombie_die2.mp3",
	"*/MassiveInfection/zombie_die3.mp3",
	"*/MassiveInfection/zombie_pain4.mp3",
	"*/MassiveInfection/zombie_pain5.mp3",
	"*/MassiveInfection/zombi_death_1.mp3",
	"*/MassiveInfection/zombi_death_2.mp3"
};
char sZombieIdleSounds[][] = {
	"*/MassiveInfection/nil_alone.wav",
	"*/MassiveInfection/nil_now_die.wav",
	"*/MassiveInfection/nil_slaves.wav",
	"*/MassiveInfection/zombie_brains1.wav",
	"*/MassiveInfection/zombie_brains2.wav"
};

// AccessLevels
#define BANNED_ACCESS 	1
#define USER_ACCESS 	2
#define ADMIN_ACCESS 	3
#define STAFF_ACCESS 	4
#define MODES_ACCESS	5

// Weapons buy
#define WEAPONS_BOUGHT_NOTHING 		(1<<0)
#define WEAPONS_BOUGHT_PRIMARY 		(1<<1)
#define WEAPONS_BOUGHT_SECONDARY 	(1<<2)
#define WEAPONS_BOUGHT_GRENADES		(1<<3)

#define LASERMINE_QUANTITY 	3

//=====================================================
//					METHOD
//=====================================================

// ZPLAYER
methodmap ZPlayer < Player{
	public ZPlayer(int value){
		return view_as<ZPlayer>(value);
	}
	property int iPiuPoints{
		public get(){
			return gClientData[this.id].iPiuPoints;
		}
		public set(int value){
			gClientData[this.id].iPiuPoints = value;
		}
	}
	property bool bVip{
    	public get() {
    		return gClientData[this.id].bVip;
    	}
    	public set(bool value){
    		gClientData[this.id].bVip = value;
    	}
    }
	property int iAccessLevel{
    	public get() {
    		return gClientData[this.id].iAccessLevel;
    	}
    	public set(int value){
    		gClientData[this.id].iAccessLevel = value;
    	}
    }
	property bool bAdmin{
    	public get() {
    		//return this.iAccessLevel == ADMIN_ACCESS;
    		return view_as<bool>(GetUserFlagBits(this.id) & ADMFLAG_CHANGEMAP);
    	}
    }
	property bool bStaff{
    	public get() {
    		return this.iAccessLevel == STAFF_ACCESS;
    	}
    }
	property bool bStopSound{
    	public get(){
    		return gClientData[this.id].bStopSound;
    	}
    	public set(bool value){
    		gClientData[this.id].bStopSound = value;
    	}
    }
	property bool bAlive{
    	public get(){
    		return IsPlayerExist(this.id, true);
    	}
    }
	property bool bChatBanned{
    	public get(){
    		return gClientData[this.id].bChatBanned;
    	}
    	public set(bool value){
    		gClientData[this.id].bChatBanned = value;
    	}
    }
	property bool bVoiceChatBanned{
    	public get(){
    		return gClientData[this.id].bVoiceChatBanned;
    	}
    	public set(bool value){
    		gClientData[this.id].bVoiceChatBanned = value;
    	}
    }
	property bool bLadder{
    	public get(){
    		return gClientData[this.id].bLadder;
    	}
    	public set(bool value){
    		gClientData[this.id].bLadder = value;
    	}
    }
    property int iRoundDeaths{
        public get(){
			return gClientData[this.id].iRoundDeaths; 
		}
		
        public set(int value){
			gClientData[this.id].iRoundDeaths = value;
		}
    }
	property int iHp{
        public get(){ 
			return gClientData[this.id].iHp; 
		}
		
        public set(int value){ 
			gClientData[this.id].iHp = value;
		}
    }
    property int iMaxHp{
        public get(){
			return gClientData[this.id].iMaxHp;
		}
		
        public set(int value){
			gClientData[this.id].iMaxHp = value;
		}
    }
	property int iArmor{
        public get(){
        	return gClientData[this.id].iArmor;
        }
        public set(int value){
        	gClientData[this.id].iArmor = value;
        }
    }
    
    property bool bChangedName{
    	public get(){
    		return gClientData[this.id].bChangedName;
    	}
    	public set(bool value){
    		gClientData[this.id].bChangedName = value;
    	}
    }
    
    property bool bAFK{
    	public get(){
    		return gClientData[this.id].bAFK;
    	}
    	public set(bool value){
    		gClientData[this.id].bAFK = value;
    	}
    }
    
    property bool bLoaded{
    	public get(){
    		return gClientData[this.id].bLoaded;
    	}
    	public set(bool value){
    		gClientData[this.id].bLoaded = value;
    	}
    }
    
    property int iSteamAccountID{
    	public get(){
    		return gClientData[this.id].iSteamAccountID;
    	}
    	public set(int value){
    		gClientData[this.id].iSteamAccountID = value;
    	}
    }
    
    // Refeer code
    public void getRefeerCode(char[] buffer, int size){
    	strcopy(buffer, size, gClientData[this.id].sRefeerCode);
    }
    public void setRefeerCode(char[] source){
    	strcopy(gClientData[this.id].sRefeerCode, 12, source);
    }
    
    // Hud timer
    property Handle hHudTimer{
    	public get(){
    		return gClientData[this.id].hHudTimer;
    	}
    	public set(Handle value){
    		gClientData[this.id].hHudTimer = value;
    	}
    }
	
	// Tags
	property int iTag{
    	public get() {
			return gClientData[this.id].iTag; 
		}
        public set(int value) { 
			gClientData[this.id].iTag = value;
		}
    }
	property int iNextTag{
    	public get() {
			return gClientData[this.id].iNextTag; 
		}
		
        public set(int value){ 
			gClientData[this.id].iNextTag = value;
		}
    }
	property bool bInTagCreation{
		public get(){
			return gClientData[this.id].bInTagCreation;
		}
		public set(bool value){
			gClientData[this.id].bInTagCreation = value;
		}
	}
	
	// Rank tags
	property int iRankTag{
    	public get() {
			return gClientData[this.id].iRankTag; 
		}
		
        public set(int value) { 
			gClientData[this.id].iRankTag = value;
		}
    }
	
	property float flExpBoost{
		public get(){
			return gClientData[this.id].flExpBoost;
		}
		public set(float value){
			gClientData[this.id].flExpBoost = value;
		}
	}
	
	// Model index
	/*property int iModelIndex{
		public get(){
			return gModelIndex[this.id];
		}
		public set(int value){
			gModelIndex[this.id] = value;
		}
	}*/
	
	// Combos
	property int iDamageDealt{
		public get(){
			return gClientData[this.id].iDamageDealt;
		}
		public set(int value){
			gClientData[this.id].iDamageDealt = value;
		}
	}
	property int iCombo{
		public get(){
			return gClientData[this.id].iCombo;
		}
		public set(int value){
			gClientData[this.id].iCombo = value;
		}
	}
	property int iComboType{
		public get(){ return gClientData[this.id].iComboType; }
		public set(int value){ gClientData[this.id].iComboType = value; }
	}
	property float fComboTime{
		public get(){ return gClientData[this.id].fComboTime; }
		public set(float value){ gClientData[this.id].fComboTime = value; }
	}
	property Handle hComboHandle{
		public get(){ return gClientData[this.id].hComboHandle; }
		public set(Handle value){ gClientData[this.id].hComboHandle = value; }
	}
	// 
	property bool bCanLeap{
		public get(){
			return gClientData[this.id].bCanLeap;
		}
		public set(bool value){
			gClientData[this.id].bCanLeap = value;
		}
	}
	property bool bAutoWeaponsBuy{
		public get(){
			return gClientData[this.id].bAutoWeaponsBuy;
		}
		public set(bool value){
			gClientData[this.id].bAutoWeaponsBuy = value;
		}
	}
	property bool bAutoWeaponUpgrade{
		public get(){
			return gClientData[this.id].bAutoWeaponUpgrade;
		}
		public set(bool value){
			gClientData[this.id].bAutoWeaponUpgrade = value;
		}
	}
	property bool bAutoGrenadeUpgrade{
		public get(){
			return gClientData[this.id].bAutoGrenadeUpgrade;
		}
		public set(bool value){
			gClientData[this.id].bAutoGrenadeUpgrade = value;
		}
	}
	property bool bAutoHClass {
		public get(){
			return gClientData[this.id].bAutoHClass;
		}
		public set(bool value){
			gClientData[this.id].bAutoHClass = value;
		}
	}
	property bool bAutoZClass {
		public get(){
			return gClientData[this.id].bAutoZClass;
		}
		public set(bool value){
			gClientData[this.id].bAutoZClass = value;
		}
	}
	property int iPjSeleccionado{
		public get(){
			return gClientData[this.id].iPjSeleccionado;
		}
		public set(int value) {
			gClientData[this.id].iPjSeleccionado = value;
		}
	}
	property int iPjEnMenu{
		public get(){
			return gClientData[this.id].iPjEnMenu;
		}
		public set(int value) {
			gClientData[this.id].iPjEnMenu = value;
		}
	}
	public int getIdPjInSlot(int slot){
		return gClientData[this.id].iIdPjSlot[slot];
	}
	public void setIdPjInSlot(int slot, int value){
		gClientData[this.id].iIdPjSlot[slot] = value;
	}
	public bool isSlotEmpty(int slot){
		return gClientData[this.id].bIsSlotEmpty[slot];
	}
	public void setSlotEmpty(int slot, bool value){
		gClientData[this.id].bIsSlotEmpty[slot] = value;
	}
	public void TeleportPlayer(float origin[3] = NULL_VECTOR, float angles[3] = NULL_VECTOR, float velocity[3] = NULL_VECTOR){
		TeleportEntity(this.id, origin, angles, velocity);
	}
	public void flGetOrigin(float x[3]){
		GetClientAbsOrigin(this.id, x);
	}
	public void flGetEyePosition(float x[3]){
		GetClientEyePosition(this.id, x);
	}
	public void flGetEyeAngles(float x[3]){
		GetClientEyeAngles(this.id, x);
	}
	public void lVelocity(float x[3]){
		GetEntPropVector(this.id, Prop_Data, "m_vecVelocity", x);
	}
	property int iAntidotes{
		public get(){
			return gClientData[this.id].iAntidotes;
		}
		public set(int value){
			gClientData[this.id].iAntidotes = value;
		}
	}
	property int iMadness{
		public get(){
			return gClientData[this.id].iMadness;
		}
		public set(int value){
			gClientData[this.id].iMadness = value;
		}
	}
	
	// Idle sounds handle
	property Handle hIdleSound{
		public get(){
			return gClientData[this.id].hIdleSound;
		}
		public set(Handle value){
			gClientData[this.id].hIdleSound = value;
		}
	}
	
	property bool bHearHurtSounds{
		public get(){
			return gClientData[this.id].bEnableHurtSound;
		}
		public set(bool value){
			gClientData[this.id].bEnableHurtSound = value;
		}
	}
	
	// Points
	property int iHPoints{
		public get(){
			return gClientData[this.id].iHPoints;
		}
		public set(int value){
			gClientData[this.id].iHPoints = value;
		}
	}
	property int iZPoints{
		public get(){
			return gClientData[this.id].iZPoints;
		}
		public set(int value){
			gClientData[this.id].iZPoints = value;
		}
	}
	
	// Next attack
	property float fNextAttack{
		public get(){ return gClientData[this.id].fNextAttack; }
		public set(float value){ gClientData[this.id].fNextAttack = value; }
	}
	
	property bool bRecentlyRegistered{
		public get(){
			return gClientData[this.id].bRecentlyRegistered;
		}
		public set(bool value){
			gClientData[this.id].bRecentlyRegistered = value;
		}
	}
	
	// Golden points
	property int iHGoldenPoints{
		public get(){
			return gClientData[this.id].iHGoldenPoints;
		}
		public set(int value){
			gClientData[this.id].iHGoldenPoints = value;
		}
	}
	property int iZGoldenPoints{
		public get(){
			return gClientData[this.id].iZGoldenPoints;
		}
		public set(int value){
			gClientData[this.id].iZGoldenPoints = value;
		}
	}
	
	// Hat points
	property int iHatPoints{
		public get(){
			return gClientData[this.id].iHatPoints;
		}
		public set(int value){
			gClientData[this.id].iHatPoints = value;
		}
	}
	
	// Human upgrades
	property int iHDamageLevel{
		public get(){
			return gClientData[this.id].iHDamageLevel;
		}
		public set(int value){
			gClientData[this.id].iHDamageLevel = value;
		}
	}
	property int iHResistanceLevel{
		public get(){
			return gClientData[this.id].iHResistanceLevel;
		}
		public set(int value){
			gClientData[this.id].iHResistanceLevel = value;
		}
	}
	property int iHDexterityLevel{
		public get(){
			return gClientData[this.id].iHDexterityLevel;
		}
		public set(int value){
			gClientData[this.id].iHDexterityLevel = value;
		}
	}
	
	// Zombie upgrades
	property int iZDamageLevel{
		public get(){
			return gClientData[this.id].iZDamageLevel;
		}
		public set(int value){
			gClientData[this.id].iZDamageLevel = value;
		}
	}
	property int iZHealthLevel{
		public get(){
			return gClientData[this.id].iZHealthLevel;
		}
		public set(int value){
			gClientData[this.id].iZHealthLevel = value;
		}
	}
	property int iZDexterityLevel{
		public get(){
			return gClientData[this.id].iZDexterityLevel;
		}
		public set(int value){
			gClientData[this.id].iZDexterityLevel = value;
		}
	}
	
	// Human golden upgrades
	property int iLmHpLevel{
		public get(){
			return gClientData[this.id].iGoldenHUpgradeLevel[0];
		}
		public set(int value){
			gClientData[this.id].iGoldenHUpgradeLevel[0] = value;
		}
	}
	property int iCritChanceLevel{
		public get(){
			return gClientData[this.id].iGoldenHUpgradeLevel[1];
		}
		public set(int value){
			gClientData[this.id].iGoldenHUpgradeLevel[1] = value;
		}
	}
	property int iItemChanceLevel{
		public get(){
			return gClientData[this.id].iGoldenHUpgradeLevel[2];
		}
		public set(int value){
			gClientData[this.id].iGoldenHUpgradeLevel[2] = value;
		}
	}
	property int iAuraTimeLevel{
		public get(){
			return gClientData[this.id].iGoldenHUpgradeLevel[3];
		}
		public set(int value){
			gClientData[this.id].iGoldenHUpgradeLevel[3] = value;
		}
	}
	
	// Zombie golden upgrades
	property int iMadnessTimeLevel{
		public get(){
			return gClientData[this.id].iGoldenZUpgradeLevel[0];
		}
		public set(int value){
			gClientData[this.id].iGoldenZUpgradeLevel[0] = value;
		}
	}
	property int iDamageToLmLevel{
		public get(){
			return gClientData[this.id].iGoldenZUpgradeLevel[1];
		}
		public set(int value){
			gClientData[this.id].iGoldenZUpgradeLevel[1] = value;
		}
	}
	property int iLeechLevel{
		public get(){
			return gClientData[this.id].iGoldenZUpgradeLevel[2];
		}
		public set(int value){
			gClientData[this.id].iGoldenZUpgradeLevel[2] = value;
		}
	}
	property int iMadnessChanceLevel{
		public get(){
			return gClientData[this.id].iGoldenZUpgradeLevel[3];
		}
		public set(int value){
			gClientData[this.id].iGoldenZUpgradeLevel[3] = value;
		}
	}
	property float fMadnessChanceTime{
		public get(){
			return gClientData[this.id].fMadnessChanceTime;
		}
		public set(float value){
			gClientData[this.id].fMadnessChanceTime = value;
		}
	}
	//
	property int iExp{
		public get(){
			return gClientData[this.id].iExp;
		}
		public set(int value){
			gClientData[this.id].iExp = value;
		}
	}
	property int iLevel{
		public get(){
			return gClientData[this.id].iLevel;
		}
		public set(int value){
			gClientData[this.id].iLevel = value;
		}
	}
	property int iReset{
		public get(){
			return gClientData[this.id].iReset;
		}
		public set(int value){
			gClientData[this.id].iReset = value;
		}
	}
	
	property int iTier{
		public get(){
			return gClientData[this.id].iTier;
		}
		public set(int value){
			gClientData[this.id].iTier = value;
		}
	}
	//
	property bool bRecentlyInfected{
        public get() { 
			return gClientData[this.id].bRecentlyInfected; 
		}
        public set(bool value){ 
			gClientData[this.id].bRecentlyInfected = value; 
		}
    }
	property bool bInvulnerable {
	    public get(){ 
			return gClientData[this.id].bInvulnerable; 
		}
        public set(bool value){ 
			gClientData[this.id].bInvulnerable = value; 
		}
    }
	property bool bReceivePartyInv {
	    public get() { 
			return gClientData[this.id].bReceivePartyInv; 
		}
        public set(bool value) { 
			gClientData[this.id].bReceivePartyInv = value; 
		}
    }
    
    // Player type
	property PlayerType iType{
    	public get() { 
			return gClientData[this.id].iType; 
		}
		public set(PlayerType value) { 
			gClientData[this.id].iType = value;
		}
    }
    
    public bool isHuman(){
    	bool res = false;
    	
    	if (this.iTeamNum == CS_TEAM_CT && PT_HUMAN <= this.iType < PT_MAX_HUMANS)
    		res = true;
    	
    	return res;
    }
	public bool isZombie(){
    	bool res = false;
    	
    	if (this.iTeamNum == CS_TEAM_T && PT_ZOMBIE <= this.iType < PT_MAX_ZOMBIES)
    		res = true;
    	
    	return res;
    }
	public bool isType(PlayerType type){
		bool ret = false;
		if(this.iType == type) ret = true;
		return ret;
	}
	public bool isBoss(bool humanBoss = false){
		bool res = false;
		if (humanBoss){
			if (PT_HUMAN < this.iType < PT_MAX_HUMANS)
				res = true;
		}
		else{
			if (PT_ZOMBIE < this.iType < PT_MAX_ZOMBIES)
				res = true;
		}
		return res;
	}
    
    // Classes
	property int iHumanClass{
		public get(){ 
			return gClientData[this.id].iHumanClass; 
		}
        public set(int value){ 
			gClientData[this.id].iHumanClass = value; 
		}
    }
	property int iZombieClass{
        public get() { 
			return gClientData[this.id].iZombieClass; 
		}
        public set(int value) { 
			gClientData[this.id].iZombieClass = value;
		}
    }
	property int iNextHumanClass{
		public get() { 
			return gClientData[this.id].iNextHumanClass; 
		}
        public set(int value) { 
			gClientData[this.id].iNextHumanClass = value; 
		}
    }
	property int iNextZombieClass{
        public get(){ 
			return gClientData[this.id].iNextZombieClass; 
		}
		public set(int value){
			gClientData[this.id].iNextZombieClass = value; 
		}
	}
	
	// Alignments
	property int iHumanAlignment{
		public get(){
			return gClientData[this.id].iHumanAlignment;
		}
		public set(int value){
			gClientData[this.id].iHumanAlignment = value;
		}
	}
	property int iZombieAlignment{
		public get(){
			return gClientData[this.id].iZombieAlignment;
		}
		public set(int value){
			gClientData[this.id].iZombieAlignment = value;
		}
	}
	property int iNextHumanAlignment{
		public get(){
			return gClientData[this.id].iNextHumanAlignment;
		}
		public set(int value){
			gClientData[this.id].iNextHumanAlignment = value;
		}
	}
	property int iNextZombieAlignment{
		public get(){
			return gClientData[this.id].iNextZombieAlignment;
		}
		public set(int value){
			gClientData[this.id].iNextZombieAlignment = value;
		}
	}
	
	// Weapons
	property int iSelectedPrimaryWeapon{
    	public get(){
    		return gClientData[this.id].iSelectedPrimaryWeapon;
    	}
    	public set(int value){
    		gClientData[this.id].iSelectedPrimaryWeapon = value;
    	}
    }
    property int iSelectedSecondaryWeapon{
    	public get(){
    		return gClientData[this.id].iSelectedSecondaryWeapon;
    	}
    	public set(int value){
    		gClientData[this.id].iSelectedSecondaryWeapon = value;
    	}
    }
    
    property int iWeaponBought{
    	public get(){
    		return gClientData[this.id].iWeaponBought;
    	}
    	public set(int value){
    		gClientData[this.id].iWeaponBought = value;
    	}
    }
	property int iPrimaryWeapon{
    	public get(){
    		return gClientData[this.id].iPrimaryWeapon;
    	}
    	public set(int value){
    		gClientData[this.id].iPrimaryWeapon = value;
    	}
    }
	property int iSecondaryWeapon{
    	public get(){
    		return gClientData[this.id].iSecondaryWeapon;
    	}
    	public set(int value){
    		gClientData[this.id].iSecondaryWeapon = value;
    	}
    }
	property int iNextPrimaryWeapon{
		public get(){
    		return gClientData[this.id].iNextPrimaryWeapon;
    	}
		public set(int value){
    		gClientData[this.id].iNextPrimaryWeapon = value;
    	}
	}
	property int iNextSecondaryWeapon{
		public get(){
    		return gClientData[this.id].iNextSecondaryWeapon;
    	}
		public set(int value){
    		gClientData[this.id].iNextSecondaryWeapon = value;
    	}
	}
	
	property int iActiveWeapon{
		public get(){
			return GetEntPropEnt(this.id, Prop_Send, "m_hActiveWeapon");
		}
	}
	property int iActiveWeaponIndex{
		public get(){
			int pWeap = GetPlayerWeaponSlot(this.id, CS_SLOT_PRIMARY);
			int sWeap = GetPlayerWeaponSlot(this.id, CS_SLOT_SECONDARY);
			int iActiveWeapon = this.iActiveWeapon;
			
			if (iActiveWeapon == pWeap)
				return this.iPrimaryWeapon;
			else if (iActiveWeapon == sWeap)
				return this.iSecondaryWeapon;
			else return -1;
		}
	}
	
	// Grenades
	property int iGrenadePack{
    	public get(){
    		return gClientData[this.id].iGrenadePack;
    	}
    	public set(int value){
    		gClientData[this.id].iGrenadePack = value;
    	}
    }
	property int iNextGrenadePack{
    	public get(){
    		return gClientData[this.id].iNextGrenadePack;
    	}
    	public set(int value){
    		gClientData[this.id].iNextGrenadePack = value;
    	}
    }
	property int bBoughtWeapons{
    	public get(){
    		return gClientData[this.id].bBoughtWeapons;
    	}
    	public set(int value){
    		gClientData[this.id].bBoughtWeapons = value;
    	}
    }
	property bool bInfiniteAmmo{
        public get(){ 
			return gClientData[this.id].bInfiniteAmmo; 
		}
        public set(bool value){ 
			gClientData[this.id].bInfiniteAmmo = value;
		}
    }
	property bool bFlashlight{
		public get(){
			return gClientData[this.id].bFlashlight;
		}
		public set(bool value){
			gClientData[this.id].bFlashlight = value;
			SetEntProp(this.id, Prop_Send, "m_fEffects", value ? (GetEntProp(this.id, Prop_Send, "m_fEffects") ^ 4) : (4 ^ 4));
		}
	}
	property int iLasermines{
		public get(){
			return gClientData[this.id].iLasermines;
		}
		public set(int value){
			gClientData[this.id].iLasermines = value;
		}
	}
	property int iLasermineDefused0{
		public get(){
			return gClientData[this.id].iLaserminesHP[0];
		}
		public set(int value){
			gClientData[this.id].iLaserminesHP[0] = value;
		}
	}
	property int iLasermineDefused1{
		public get(){
			return gClientData[this.id].iLaserminesHP[1];
		}
		public set(int value){
			gClientData[this.id].iLaserminesHP[1] = value;
		}
	}
	property int iLasermineDefused2{
		public get(){
			return gClientData[this.id].iLaserminesHP[2];
		}
		public set(int value){
			gClientData[this.id].iLaserminesHP[2] = value;
		}
	}
	property bool bInLmAction{
		public get(){
			return gClientData[this.id].bInLmAction;
		}
		public set(bool value){
			gClientData[this.id].bInLmAction = value;
		}
	}
	property Handle hFreezeTimer{
		public get(){
			return gClientData[this.id].hFreezeTimer;
		}
		public set(Handle value){
			gClientData[this.id].hFreezeTimer = value;
		}
	}
	
	// Hud colors
	property int iHudColor{
    	public get(){
    		return gClientData[this.id].iHudColor;
    	}
    	public set(int value){
    		gClientData[this.id].iHudColor = value;
    	}
    }
    
	// Extra Items buy count
	property int iAntidoteCount{
    	public get(){
    		return gClientData[this.id].iItemsCount[0];
    	}
    	public set(int value){
    		 gClientData[this.id].iItemsCount[0] = value;
    	}
    }
	property int iMadnessCount{
    	public get(){
    		return gClientData[this.id].iItemsCount[1];
    	}
    	public set(int value){
    		 gClientData[this.id].iItemsCount[1] = value;
    	}
    	
    }
    property int iInfammoCount{
    	public get(){
    		return gClientData[this.id].iItemsCount[2];
    	}
    	public set(int value){
    		 gClientData[this.id].iItemsCount[2] = value;
    	}
    }
	property int iNightvisionCount{
    	public get(){
    		return gClientData[this.id].iItemsCount[3];
    	}
    	public set(int value){
    		 gClientData[this.id].iItemsCount[3] = value;
    	}
    }
    property int iArmorCount{
    	public get(){
    		return gClientData[this.id].iItemsCount[4];
    	}
    	public set(int value){
    		 gClientData[this.id].iItemsCount[4] = value;
    	}
    }
	
	// Madness cooldown
	property float flMadnessTime{
		public get(){
			return gClientData[this.id].flMadnessTime;
		}
		public set (float value){
			gClientData[this.id].flMadnessTime = value;
		}
	}
	
	// Glow support
	property bool bGlowing{
    	public get(){
			return gClientData[this.id].bGlowing;
		}
		public set(bool value){
			gClientData[this.id].bGlowing = value;
		}
	}
	property int iModel{
		public get(){
			return gClientData[this.id].iModel;
		}
		public set(int value){
			gClientData[this.id].iModel = value;
		}
	}
	property int iModelIndex{
		public get(){
			return gClientData[this.id].iModelIndex;
		}
		public set(int value){
			gClientData[this.id].iModelIndex = value;
		}
	}
	public void applyGlow(int colors[3]){
		if (IsPlayerExist(this.id, true)){
			SetupGlowSkin(this.id, colors);
		}
	}
	public void removeGlow(){
		if (IsPlayerExist(this.id, true)){
			RemoveSkin(this.id);
		}
	}
	
	// Nightvision
	property int iNvEntity{
    	public get(){
    		return gClientData[this.id].iNvEntity;
    	}
    	public set(int value){
    		gClientData[this.id].iNvEntity = value;
    	}
    }
	property bool bNightvision{
		public get(){
			return gClientData[this.id].bNightvision;
		}
        public set(bool value){
			gClientData[this.id].bNightvision = value;
		}
    }
	public bool hasNightvision(){
		return (this.iNvEntity > MaxClients && IsValidEdict(this.iNvEntity));
	}
	property bool bNightvisionOn{
		public get(){
			return gClientData[this.id].bNightvisionOn;
		}
		public set(bool value){
		
			if (this.hasNightvision()){
				if (value == true){
					DispatchDistanceAndColor(this.id);
					AcceptEntityInput(this.iNvEntity, "TurnOn");
				}
				else
					AcceptEntityInput(this.iNvEntity, "TurnOff");
			}
			gClientData[this.id].bNightvisionOn = value;
		}
	}
	property int iNvColor{
    	public get(){
    		return gClientData[this.id].iNvColor;
    	}
    	public set(int value){
    		gClientData[this.id].iNvColor = value;
    	}
    }
	public void RemoveNightvision(){
		this.bNightvisionOn = false;
		if (this.hasNightvision()){
			SDKUnhook(this.iNvEntity, SDKHook_SetTransmit, OnTransmitNightvisionEntity);
			//AcceptEntityInput(this.iNvEntity, "kill");
			RemoveEntity(this.iNvEntity);
		}
		this.iNvEntity = -1;
	}
	public void toggleNv(bool on = true){
		 if (this.isZombie() || this.bNightvision){
		 	if (this.hasNightvision())
		 		this.bNightvisionOn = on;
		 	else
		 		CreateNightvisionLight(this.id);
		 }
	}
	
	// Bosses aura
	property bool bAura{
		public get(){
			return gClientData[this.id].bAura;
		}
		public set(bool value){
			gClientData[this.id].bAura = value;
		}
	}
	property int iAuraEntity{
		public get(){
			return gClientData[this.id].iAuraEntity;
		}
		public set(int value){
			gClientData[this.id].iAuraEntity = value;
		}
	}
	
	// Hat
	property int iHat{
		public get(){
			return gClientData[this.id].iHat;
		}
		public set(int value){
			gClientData[this.id].iHat = value;
		}
	}
	property int iNextHat{
		public get(){
			return gClientData[this.id].iNextHat; 
		}
		public set(int value) {
			gClientData[this.id].iNextHat = value;
		}
	}
	property int iHatRef{
		public get(){
			return gClientData[this.id].iHatRef;
		}
		public set(int value){
			gClientData[this.id].iHatRef = value;
		}
	}
	
	// Infection heritage
	property int iInfectorId{
		public get(){
			return gClientData[this.id].iInfectorId;
		}
		public set(int value){
			gClientData[this.id].iInfectorId = value;
		}
	}
	property int iInfectedId{
		public get(){
			return gClientData[this.id].iInfectedId;
		}
		public set(int value){
			gClientData[this.id].iInfectedId = value;
		}
	}
	
	// Mutation timer
	property Handle hMutationTimer{
		public get(){
			return gClientData[this.id].hMutationTimer;
		}
		public set(Handle value){
			gClientData[this.id].hMutationTimer = value;
		}
	}
	
	property int iIgniterId{
		public get(){
			return gClientData[this.id].iIgniterId;
		}
		public set(int value){
			gClientData[this.id].iIgniterId = value;
		}
	}
	
	// Flashlight
	public void bFlashLightOn(bool value) {
		SetEntProp(this.id, Prop_Send, "m_fEffects", value ? (GetEntProp(this.id, Prop_Send, "m_fEffects") ^ 4) : (4 ^ 4));
	}
	
    public void resetExtraItemsCount(){
    	// Reset extra items count
    	for (int i; i < view_as<int>(EXTRA_ITEMS_COUNT); i++){
    		gClientData[this.id].iItemsCount[i] = 0;
    	}
    }
    
	// Upgrades
	public float getHumanDamage(bool boss=false){
		float ret = 1.0;
		
		if(this.iHDamageLevel > 0){
			ret += (HUMAN_DAMAGE_BONUS*this.iHDamageLevel) * (boss ? BOSSES_UPGRADE_PERCENTAGE : 1.0);
		}
		
		ret += (RESET_HUMAN_DAMAGE_BONUS_PCT*this.iReset) * (boss ? BOSSES_UPGRADE_PERCENTAGE : 1.0);
		
		return ret;
	}
	public int getHumanResistance(bool armor=false, bool boss=false){
		int ret = 0;
		if(!armor){
			if(this.iHResistanceLevel > 0) ret += RoundToZero( float(HUMAN_RESISTANCE_HEALTH_BONUS * this.iHResistanceLevel) * (boss ? BOSSES_UPGRADE_PERCENTAGE : 1.0) );
		}
		else {
			if(this.iHResistanceLevel > 0) ret += RoundToZero( float(HUMAN_RESISTANCE_ARMOR_BONUS * this.iHResistanceLevel) * (boss ? BOSSES_UPGRADE_PERCENTAGE : 1.0) );
		}
		return ret;
	}
	public float getHumanDexterity(bool speed=false, bool boss=false){
		float ret = 0.0;
		if(!speed){
			if(this.iHDexterityLevel > 0)  ret += (HUMAN_DEXTERITY_GRAVITY_BONUS * this.iHDexterityLevel) * (boss ? BOSSES_UPGRADE_PERCENTAGE : 1.0);
		}
		else {
			if(this.iHDexterityLevel > 0)  ret += (HUMAN_DEXTERITY_SPEED_BONUS * this.iHDexterityLevel) * (boss ? BOSSES_UPGRADE_PERCENTAGE : 1.0);
		}
		return ret;
	}
	public float getZombieDamage(bool boss=false){
		float ret = 1.0;
		if(this.iZDamageLevel > 0) ret += ZOMBIE_DAMAGE_BONUS* this.iZDamageLevel * (boss ? BOSSES_UPGRADE_PERCENTAGE : 1.0);
		return ret;
	}
	public int getZombieUpgradedHP(int hp, bool boss=false){
		int total = hp;
		
		if (this.iReset){
			total = RoundToZero( float(hp) * (1+(RESET_ZOMBIE_HP_BONUS_PCT * float(this.iReset)))  * (boss ? BOSSES_UPGRADE_PERCENTAGE : 1.0) );
		}
		
		if (this.iZHealthLevel){
			total += RoundToZero( float(hp) * (ZOMBIE_HEALTH_BONUS * float(this.iZHealthLevel)) * (boss ? BOSSES_UPGRADE_PERCENTAGE : 1.0) );
		}
		
		return total;
	}
	public float getZombieDexterity(bool speed=false, bool boss=false){
		float ret = 0.0;
		if(!speed) {
			if(this.iZDexterityLevel > 0) ret += ZOMBIE_DEXTERITY_GRAVITY_BONUS * this.iZDexterityLevel * (boss ? BOSSES_UPGRADE_PERCENTAGE : 1.0);
		}
		else {
			if(this.iZDexterityLevel > 0)  ret += ZOMBIE_DEXTERITY_SPEED_BONUS * this.iZDexterityLevel * (boss ? BOSSES_UPGRADE_PERCENTAGE : 1.0);
		}
		return ret;
	} 
	public int applyInfectionLeech(){
		
		if (!this.isType(PT_ZOMBIE))
			return 0;
		
		// If player has leech
		if (!this.iLeechLevel)
			return 0;
			
		ZClass class;
		ZClasses.GetArray(this.iZombieClass, class);
		ZAlignment alignment;
		ZAlignments.GetArray(this.iZombieAlignment, alignment);
		
		int iMaxHp = RoundToFloor(this.getZombieUpgradedHP(class.health) * alignment.flHealthMul);
		
		float iMul = GoldenUpgrade(getUpgradeIndexByUpgradeId(Z_LEECH)).getBuffAmount(this.iLeechLevel);
		
		int totalLeech = getLeechAmount(iMaxHp, iMul);
		this.iHp += (totalLeech > GOLDEN_LEECH_HP_LIMIT) ? GOLDEN_LEECH_HP_LIMIT : totalLeech;
		
		if (this.iHp > GOLDEN_LEECH_MAXHP){
			this.iMaxHp = this.iHp = GOLDEN_LEECH_MAXHP;
		}
		
		
		return totalLeech;
	}
	public void setGravity(){
		/*if (this.iTeamNum == CS_TEAM_CT){
			if (this.iHDexterityLevel == 0)
				return;
		}
		else if (this.iTeamNum == CS_TEAM_T){
			if (this.iZDexterityLevel == 0)
				return;
		}*/
		
		switch(this.iType){
			case PT_ZOMBIE: {
				ZClass class;
				ZClasses.GetArray(this.iZombieClass, class);
				this.flGravity = class.gravity - ((this.iZDexterityLevel == 0) ? 0.0 : this.getZombieDexterity());
			}
			case PT_NEMESIS, PT_ASSASSIN:{
				
				ZBoss boss;
				ZBosses.GetArray(GetBossIndex(this.iType), boss);
				
				this.flGravity = boss.flGravity - ( (this.iZDexterityLevel == 0) ? 0.0 : (this.getZombieDexterity(false, true)) );
				//PrintToChatAll("iBossType: %d", GetBossIndex(this.iType));
			}
			case PT_HUMAN:{
				HClass class;
				HClasses.GetArray(this.iHumanClass, class);
				this.flGravity = class.gravity - ( (this.iHDexterityLevel == 0) ? 0.0 : (this.getHumanDexterity()) );
			}
			case PT_SURVIVOR, PT_GUNSLINGER, PT_SNIPER, PT_MEOW: {
				
				ZBoss boss;
				ZBosses.GetArray(GetBossIndex(this.iType), boss);
				
				this.flGravity = boss.flGravity - ( (this.iHDexterityLevel == 0) ? 0.0 : (this.getHumanDexterity(false, true)/*/1.5*/) );
				//PrintToChatAll("iBossType: %d", GetBossIndex(this.iType));
			}
		}
		//PrintToChatAll("ClientGravity: %f, iType: %d", this.flGravity, this.iType);
	}
	
	// Reset knife entity to avoid bugs
	public void ResetKnife(){
		
		int knife = GetPlayerWeaponSlot(this.id, CS_SLOT_KNIFE);
		if (knife != -1 && IsValidEntity(knife)){
			RemovePlayerItem(this.id, knife);
			//AcceptEntityInput(knife, "Kill");
			RemoveEntity(knife);
		}
		GivePlayerItem(this.id, "weapon_knife");
	}
	
	// Reset player index values
	public void Reset(){
		
		// IMPORTANT
		this.iAccessLevel = USER_ACCESS;
		
		this.bLoaded = false;
		this.bLogged = false;
		this.bInGame = false;
		this.bInUser = false;
		this.bInPassword = false;
		this.bInCreatingCharacter = false;
		this.bHasMail = false;
		this.bHasPassword = false;
		this.bInTagCreation = false;
		this.bVip = false;
		this.bCanChangeName = false;
		this.bRecentlyRegistered = false;
		this.iMaxHp = this.iHp = 100;
		this.flExpBoost = 1.0;
		
		// Hud timer
		this.hHudTimer = null;
		
		// Tier
		this.iTier = 0;
		
		// Combos
		this.iDamageDealt = 0;
		this.iCombo = 1;
		this.iComboType = 0;
		this.fComboTime = 0.0;
		this.hComboHandle  = null;
		//this.hComboHandle = null;
		
		this.bCanLeap = false;
		this.bStopSound = true;
		//this.iFlags = 0;
		this.iPjSeleccionado = -1;
		this.iPjEnMenu = -1;
		//this.iTeamNum = CS_TEAM_NONE;
		this.iZPoints = 0;
		this.iHPoints = 0;
		//
		this.iZDamageLevel = 0;
		this.iZHealthLevel = 0;
		this.iZDexterityLevel = 0;
		this.iHDamageLevel = 0;
		this.iHResistanceLevel = 0;
		this.iHDexterityLevel = 0;
		
		// GOLDEN UPGRADES
		this.iLmHpLevel = 0;
		this.iCritChanceLevel = 0;
		this.iItemChanceLevel = 0;
		this.iAuraTimeLevel = 0;
		this.iMadnessTimeLevel = 0;
		this.iDamageToLmLevel = 0;
		this.iLeechLevel = 0;
		this.iMadnessChanceLevel = 0;
		this.fMadnessChanceTime = 0.0;
		
		//
		this.iExp = 0;
		this.iLevel = 0;
		this.iReset = 0;
		this.bRecentlyInfected = false;
		this.iType = PT_NONE;
		this.bInvulnerable = false;
		this.iHumanClass = 0;
		this.iZombieClass = 0;
		this.iNextHumanClass = 0;
		this.iNextZombieClass = 0;
		this.iHumanAlignment = 0;
		this.iZombieAlignment = 0;
		this.iNextHumanAlignment = -1;
		this.iNextZombieAlignment = -1;
		this.iPrimaryWeapon = 0;
		this.iSecondaryWeapon = 0;
		this.iSelectedPrimaryWeapon = 0;
		this.iSelectedSecondaryWeapon = 0;
		this.iWeaponBought = 0;
		this.iNextPrimaryWeapon = 0;
		this.iNextSecondaryWeapon = 0;
		this.iGrenadePack = 0;
		this.iNextGrenadePack = 0;
		this.iPredictedViewModelIndex = INVALID_ENT_REFERENCE;
		this.bInfiniteAmmo = false;
		this.iLasermines = 0;
		this.iLasermineDefused0 = 0;
		this.iLasermineDefused1 = 0;
		this.iLasermineDefused2 = 0;
		this.iHGoldenPoints = 0;
		this.iZGoldenPoints = 0;
		
		// Auto upgrade
		this.bAutoWeaponsBuy = false;
		this.bAutoWeaponUpgrade = false;
		this.bAutoGrenadeUpgrade = false;
		
		// Reset party data
		gClientData[this.id].iPartyUID = -1;
		gClientData[this.id].bInParty = false;
		
		// Glow support
		this.removeGlow();
		
		// Nightvision
		this.RemoveNightvision();
		this.iNvColor = 0;
		this.bNightvision = false;
		this.iNvEntity = -1;
		
		// Freeze timer
		this.hFreezeTimer = null;
		//this.hFreezeTimer = INVALID_HANDLE;
		
		// Hat
		RemoveHat(this.id);
		this.iHat = 0;
		this.iNextHat = 0;
		this.iHatRef = INVALID_ENT_REFERENCE;
		
		// Infection heritage
		this.iInfectorId = -1;
		this.iInfectedId = -1;
		
		ExtraItemsOnResetVariables(this.id);
		
		for(int i; i < MAXCHARACTERS_LEGACY; i++){
			this.setSlotEmpty(i, true);
		}
		
		// Igniter
		this.iIgniterId = -1;
		
		// Mutation timer
		this.hMutationTimer = null;
		
		this.bAFK = false;
		
		this.bLoaded = false;
		
		if (!IsFakeClient(this.id)){
			this.iSteamAccountID = GetSteamAccountID(this.id);
		}
	}
	
	// Players' option to reset upgrade points
	public void resetPoints(bool zombie=false){
		int ret = 0;
		if(zombie){
			for(int i; i < this.iZDamageLevel+1; 	i++) ret += (ZOMBIE_DAMAGE_COST*i);
			for(int i; i < this.iZHealthLevel+1; 	i++) ret += (ZOMBIE_HEALTH_COST*i);
			for(int i; i < this.iZDexterityLevel+1; 	i++) ret += (ZOMBIE_DEXTERITY_COST*i);
			this.iZPoints += ret;
			this.iZDamageLevel = 0;
			this.iZHealthLevel = 0;
			this.iZDexterityLevel = 0;
		}
		else{
			for(int i; i < this.iHDamageLevel+1; 	i++) ret += (HUMAN_DAMAGE_COST*i);
			for(int i; i < this.iHDexterityLevel+1; 	i++) ret += (HUMAN_DEXTERITY_COST*i);
			for(int i; i < this.iHResistanceLevel+1; 	i++) ret += (HUMAN_RESISTANCE_COST*i);
			this.iHPoints += ret;
			this.iHDamageLevel = 0;
			this.iHDexterityLevel = 0;
			this.iHResistanceLevel = 0;
		}
	}
	
	// CUSTOM WEAPONS UTILS
	public void removeWeapons(){
		
		////////////////////
		// Remove primary
		int weapon;
		weapon = GetPlayerWeaponSlot(this.id, CS_SLOT_PRIMARY);
		
		if(weapon != -1 && IsValidEntity(weapon)){
			
			/*if (this.bStaff)
				PrintToChat(this.id, " \x09REMOVING WEAPON\x01 | index %d | PRIMARY SLOT", weapon);*/
			
			RemovePlayerItem(this.id, weapon);
			//AcceptEntityInput(weapon1, "Kill");
			RemoveEntity(weapon);
		}
		
		if (this.isType(PT_HUMAN)){
			this.iPrimaryWeapon = 0;
		}
		
		// Remove secondary
		weapon = GetPlayerWeaponSlot(this.id, CS_SLOT_SECONDARY);
		if(weapon != -1 && IsValidEntity(weapon)){
			
			/*if (this.bStaff)
				PrintToChat(this.id, " \x09REMOVING WEAPON\x01 | index %d | SECONDARY SLOT", weapon);*/
			
			RemovePlayerItem(this.id, weapon);
			RemoveEntity(weapon);
		}
		
		if (this.isType(PT_HUMAN)){
			this.iSecondaryWeapon = 0;
		}
		
		
		// Remove grenades	
		for (int i; i <= 4; i++){
			weapon = GetPlayerWeaponSlot(this.id, CS_SLOT_GRENADE);
			if(weapon != -1 && IsValidEntity(weapon)){
				RemovePlayerItem(this.id, weapon);
				RemoveEntity(weapon);
			}
		}
		////////////////////
		
		//Gets weapon index
		int weaponIndex2 = GetPlayerWeaponSlot(this.id, view_as<int>(SlotType_Melee));
		
		// Validate weapon
		if(weaponIndex2 != INVALID_ENT_REFERENCE){
			
			// Gets weapon classname
			static char sClassname[SMALL_LINE_LENGTH];
			GetEdictClassname(weaponIndex2, sClassname, sizeof(sClassname));
			
			// Switch the weapon
			FakeClientCommand(this.id, "use %s", sClassname);
		}
		
	}
	public int GiveNetworkedWeapon(int weapon){
		
		if (weapon < 0 || !IsPlayerExist(this.id, true))
			return -1;
		
		ZWeapon Weapon = ZWeapon(weapon);
		
		// Load data from arrays
		char sWeaponEnt[32];
		Weapon.GetEnt(sWeaponEnt,  sizeof(sWeaponEnt));
		/*LogToFile("/addons/sourcemod/logs/WEAPONINDEX_LOG.txt", "---------------");
		LogToFile("/addons/sourcemod/logs/WEAPONINDEX_LOG.txt", "Weapon ENT: %s", sWeaponEnt);*/
		
		// Store to weapon id
		int iWeaponIndex = GivePlayerItem(this.id, sWeaponEnt);
		
		//LogToFile("/addons/sourcemod/logs/WEAPONINDEX_LOG.txt", "Weapon index: %d | weaponid IN ARRAY: %d", iWeaponIndex, weapon);
		
		// Change m_iName of the entity
		Weapon.SetNetworkedName(iWeaponIndex);
		
		return iWeaponIndex;
	}
	public void giveNade(GrenadeType type, int count){
		switch (type){
			case FIRE_GRENADE:{
				for (int i; i < count; i++)
					GivePlayerItem(this.id, "weapon_hegrenade");
			}
			case FREEZE_GRENADE:{
				for (int i; i < count; i++)
					GivePlayerItem(this.id, "weapon_flashbang");
			}
			case MOLOTOV_GRENADE:{
				for (int i; i < count; i++)
					GivePlayerItem(this.id, "weapon_molotov");
			}
			case AURA_GRENADE, LIGHT_GRENADE:{
				for (int i; i < count; i++)
					GivePlayerItem(this.id, "weapon_smokegrenade");
			}
			case VOID_GRENADE:{
				for (int i; i < count; i++)
					GivePlayerItem(this.id, "weapon_decoy");
			}
		}
	}
	
	// Weapon and grenade pack buy
	public bool buyWeapons(){
		
		// Give primary weapon
		if (!(this.bBoughtWeapons & WEAPONS_BOUGHT_PRIMARY)){
			
			// Prevent overflow
			if (this.iSelectedPrimaryWeapon < 0 || this.iSelectedPrimaryWeapon >= WeaponsEnt.Length){
				this.iSelectedPrimaryWeapon = this.iNextPrimaryWeapon = 0;
			}
			
			// Now we can proceed
			this.iSelectedPrimaryWeapon = this.iNextPrimaryWeapon;
			
			// Assign needed data to the weapon
			//ZWeapon primaryWeapon = ZWeapon(this.iSelectedPrimaryWeapon);
			this.iPrimaryWeapon = this.iSelectedPrimaryWeapon;
			/*if (Weapon.iType == view_as<int>(WEAPON_PRIMARY)){
				this.iPrimaryWeapon = this.iSelectedPrimaryWeapon;
			}
			else{
				this.iSecondaryWeapon = this.iSelectedPrimaryWeapon;
			}*/
			
			// Give networked weapon
			this.GiveNetworkedWeapon(this.iSelectedPrimaryWeapon);
		}
		
		// Give secondary weapon
		if (!(this.bBoughtWeapons & WEAPONS_BOUGHT_SECONDARY)){
			// Prevent overflow
			if (this.iSelectedSecondaryWeapon < 0 || this.iSelectedSecondaryWeapon >= WeaponsEnt.Length){
				this.iSelectedSecondaryWeapon = this.iNextSecondaryWeapon = 0;
			}
			
			// Now we can proceed
			this.iSelectedSecondaryWeapon = this.iNextSecondaryWeapon;
			
			this.iSecondaryWeapon = this.iSelectedSecondaryWeapon;
			
			// Give networked weapon
			this.GiveNetworkedWeapon(this.iSelectedSecondaryWeapon);
		}
		
		
		this.iWeaponBought = this.iSelectedPrimaryWeapon;
		
		return true;
	}
	public bool buyGrenadePack(){
		
		if (this.bBoughtWeapons & WEAPONS_BOUGHT_GRENADES)
			return false;
		
		// Prevent overflow
		if (this.iGrenadePack < 0 || this.iGrenadePack >= gGrenadePackLevel.Length){
			this.iGrenadePack = this.iNextGrenadePack = 0;
		}
		
		// Now we can proceed
		this.iGrenadePack = this.iNextGrenadePack;
		
		// Give him some grenades
		ZGrenadePack pack = ZGrenadePack(this.iGrenadePack);
		
		for (int i; i < view_as<int>(END_GRENADES); i++){
			if (pack.hasGrenade(view_as<GrenadeType>(i))){
				this.giveNade(view_as<GrenadeType>(i), pack.getGrenadeCount(view_as<GrenadeType>(i)));
			}
		}
		
		return true;
	}
	public void giveWeapons(){
		
		if (this.buyWeapons())
			this.bBoughtWeapons |= WEAPONS_BOUGHT_PRIMARY&WEAPONS_BOUGHT_SECONDARY;
		
		if (this.buyGrenadePack())
			this.bBoughtWeapons |= WEAPONS_BOUGHT_GRENADES;
	}
	
	// Update next primary weapon & grenade pack
	public void updateNextWeapons(){

		if (!IsPlayerExist(this.id))
			return;
		
		if (this.iSelectedPrimaryWeapon != this.iNextPrimaryWeapon && this.iNextPrimaryWeapon > 0){
			this.iSelectedPrimaryWeapon = this.iNextPrimaryWeapon;
		}
		
		if (this.iSelectedSecondaryWeapon != this.iNextSecondaryWeapon && this.iNextSecondaryWeapon > 0){
			this.iSelectedSecondaryWeapon = this.iNextSecondaryWeapon;
		}

		if (this.iGrenadePack != this.iNextGrenadePack && this.iNextGrenadePack > 0){
			this.iGrenadePack = this.iNextGrenadePack;
		}
	}
	
	// Update next classes
	public void updateNextClasses(){

		if (!IsPlayerExist(this.id))
			return;
		
		if (this.iZombieClass != this.iNextZombieClass && this.iNextZombieClass != -1){
			this.iZombieClass = this.iNextZombieClass;
		}

		if (this.iHumanClass != this.iNextHumanClass && this.iNextHumanClass != -1){
			this.iHumanClass = this.iNextHumanClass;
		}
	}
	
	// Update next alignments
	public void updateNextAlignments(){

		if (!IsPlayerExist(this.id))
			return;
		
		if (this.iZombieAlignment != this.iNextZombieAlignment && this.iNextZombieAlignment != -1){
			this.iZombieAlignment = this.iNextZombieAlignment;
		}

		if (this.iHumanAlignment != this.iNextHumanAlignment && this.iNextHumanAlignment != -1){
			this.iHumanAlignment = this.iNextHumanAlignment;
		}
	}
	
	// Fix overflows on zombiefy
	public void OnZombiefyFixOverflows(){

		// Check if class is over the limit
		if(this.iZombieClass >= ZClasses.Length || this.iZombieClass < 0){
			this.iZombieClass = 0;
		}

		// Check if next class is over the limit
		if (this.iNextZombieClass >= ZClasses.Length || this.iNextZombieClass < 0){
			this.iNextZombieClass = 0;
		}

		// Check if alignment is over the limit
		if (this.iZombieAlignment >= ZAlignments.Length || this.iZombieAlignment < 0){
			this.iZombieAlignment = 0;
		}

		// Check if next alignment is over the limit
		if (this.iNextZombieAlignment >= ZAlignments.Length || this.iNextZombieAlignment < 0){
			this.iNextZombieAlignment = 0;
		}
	}
	
	// Zombiefy
	public void Zombiefy(bool firstZombie = false){
		
		if (!IsPlayerExist(this.id, true))
			return;
		
		if (this.hMutationTimer != null){
			delete this.hMutationTimer;
		}
		
		this.OnZombiefyFixOverflows();
		
		// Apply new selected zombie class
		if (this.iZombieClass != this.iNextZombieClass){
			this.iZombieClass = this.iNextZombieClass;
		}
		
		// Apply new selected human alignment
		if (this.iZombieAlignment != this.iNextZombieAlignment){
			this.iZombieAlignment = this.iNextZombieAlignment;
		}
		
		// Turn off flashlight
		this.bFlashlight = false;
		
		// Clear any glow
		this.removeGlow();
		
		// Remove boss aura
		RemoveAura(this.id);
		
		// Remove any weapon
		this.removeWeapons();
		
		// Play infection sound
		EmitInfectSound(this.id);
		
		/////////////////////////////////////
		
		// Read class data
		ZClass class;
		ZClasses.GetArray(this.iZombieClass, class);
		
		ZAlignment alignment;
		ZAlignments.GetArray(this.iZombieAlignment, alignment);
		
		// Apply stats
		this.iType = PT_ZOMBIE;
		this.bCanLeap = false;
		this.iMaxHp = this.iHp = RoundToFloor(this.getZombieUpgradedHP(class.health) * alignment.flHealthMul);
		
		// Buff health every time a zombie dies
		/*if(this.iRoundDeaths-((this.iReset+1)/2) > 0){
			this.iHp += (ZOMBIES_BASE_HEALTH_PER_DEATH*(this.iRoundDeaths-((this.iReset+1)/2)));
		}*/
		if(this.iRoundDeaths){
			int hpBoost = 0;
			if (this.iReset > RESET_AMOUNT_TO_REDUCE_HP_BUFF)
				hpBoost = (ZOMBIES_BASE_HEALTH_PER_DEATH*this.iRoundDeaths*fnGetPlaying(true)/(this.iReset/8));
			else{
				hpBoost =  ZOMBIES_BASE_HEALTH_PER_DEATH*this.iRoundDeaths;
			}
			
			this.iMaxHp += hpBoost; 
			this.iHp += hpBoost;
			
			TranslationPrintToChat(this.id, "Zombie hp per death received", hpBoost);
			
			if (this.iRoundDeaths >= 5){
				PrintToChat(this.id, "%s \x05RECOMENDACIÓN\x01: Utiliza furia zombie para ser imparable por varios segundos!", SERVERSTRING);
				PrintToChat(this.id, "%s \x05Escribe !menu\x01 ingresa a la opción Items Extra y comprala con AP!", SERVERSTRING);
			}
		}
		
		this.iArmor = 0;
		this.flSpeed = (class.speed + this.getZombieDexterity(true)) * alignment.flSpeedMul;
		
		// test
		this.ResetKnife();
		
		// Set models
		this.setModel(ActualMode.is(MODE_MUTATION) ? FEV_MODEL : class.model, ZOMBIE_DEFAULT_ARMS);
		
		// Set proper class efects
		SetEntityRenderMode(this.id, (alignment.iAlpha < 255) ? RENDER_TRANSCOLOR : RENDER_NORMAL);
		SetEntityRenderColor(this.id, 255, 255, 255, alignment.iAlpha);
		
		if (alignment.id == iRadAlignment){
			this.applyGlow({ 40, 200, 40 });
			
			// Check if his class is radioactive
			SetEntProp(this.id, Prop_Send, "m_nSkin", (class.id == iRadioactiveZombie) ? 1 : 0);
		}
		
		// Apply in case he is designed first zombie
		if(firstZombie) {
			this.iMaxHp = this.iHp = RoundToFloor(this.iHp * FIRST_ZOMBIE_MULTIPLIER);
			//this.bCanLeap = true;
			
			if (iPlayersQuantity >= INFECTNADE_MIN_PLAYERS_TO_GIVE){
				GivePlayerItem(this.id, "weapon_flashbang");
				TranslationPrintToChat(this.id, "You are first zombie");
			}
			
			if (IsFakeClient(this.id)){
				this.iMaxHp = this.iHp = RoundToFloor(this.iHp * FIRST_ZOMBIE_MULTIPLIER)*3;
			}
		}
		
		if (ActualMode.is(MODE_WARMUP)){
			if (this.iHp > WARMUP_ZOMBIES_MAX_HP)
				this.iMaxHp = this.iHp = WARMUP_ZOMBIES_MAX_HP;
		}
		
		if (ActualMode.is(MODE_HORDE)){
			if (IsFakeClient(this.id)){
				if (this.iRoundDeaths <= 10){
					this.iHp = this.iMaxHp = this.iMaxHp/15;
				}
				else if (this.iRoundDeaths >= 20){
					this.iHp = this.iMaxHp = this.iMaxHp/10;
				}
				else if (this.iRoundDeaths >= 50){
					this.iHp = this.iMaxHp = this.iMaxHp/5;
				}
				
				this.flSpeed = class.speed;
			}
		}
		else if (ActualMode.bRespawn){
			
			if (IsFakeClient(this.id)){
				if (!firstZombie){
					if (this.iRoundDeaths <= 10){
						this.iHp = this.iMaxHp = this.iMaxHp/5;
					}
				}
				this.flSpeed = class.speed;
			}
			
			
			
		}
		
		// Replace knife ent
		//CSGO_ReplaceWeapon(this.id, CS_SLOT_KNIFE, "weapon_knife");
		////////////////////////////////////
		
		// Apply gravity
		this.setGravity();
		
		// Move to terrorist
		this.iTeamNum = CS_TEAM_T;
		
		// Reset knife entity
		//this.ResetKnife();
		FakeClientCommandEx(this.id, "use weapon_knife");
		
		// Emit an infect aura effect
		StartInfectionEffect(this.id);
		
		// Enable nightvision
		this.toggleNv(true);
		
		// Remove planted lasermines
		RemoveLasermines(this.id);
		
		gClientData[this.id].Zombie = true;
		
		delete this.hIdleSound;
		CreateTimer(45.0, TimerStartIdleSounds, this.id, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}

	public void OnHumanizeFixOverflows(){

		// Check if class is over the limit
		if(this.iHumanClass >= HClasses.Length || this.iHumanClass < 0){
			this.iHumanClass = 0;
		}

		// Check if next class is over the limit
		if (this.iNextHumanClass >= HClasses.Length || this.iNextHumanClass < 0){
			this.iNextHumanClass = 0;
		}

		// Check if alignment is over the limit
		if (this.iHumanAlignment >= HAlignments.Length || this.iHumanAlignment < 0){
			this.iHumanAlignment = 0;
		}

		// Check if next alignment is over the limit
		if (this.iNextHumanAlignment >= HAlignments.Length || this.iNextHumanAlignment < 0){
			this.iNextHumanAlignment = 0;
		}
	}

	public void Humanize(bool uniqueHuman = false){
		
		if (!IsPlayerExist(this.id, true))
			return;
		
		this.OnHumanizeFixOverflows();
		
		// Apply new selected human class
		if (this.iHumanClass != this.iNextHumanClass){
			this.iHumanClass = this.iNextHumanClass;
		}
		
		// Apply new selected human alignment
		if (this.iHumanAlignment != this.iNextHumanAlignment){
			this.iHumanAlignment = this.iNextHumanAlignment;
		}
		
		// Clear any glow
		this.removeGlow();
		
		// Remove boss aura
		RemoveAura(this.id);
		
		// Remove any weapon
		this.bBoughtWeapons &= ~(WEAPONS_BOUGHT_PRIMARY|WEAPONS_BOUGHT_SECONDARY|WEAPONS_BOUGHT_GRENADES);
		this.removeWeapons();
		
		//=====================================================
		//					HUMANIZE
		//=====================================================
		// Apply selected next weapons
		if (this.iNextPrimaryWeapon != this.iSelectedPrimaryWeapon) this.iSelectedPrimaryWeapon = this.iNextPrimaryWeapon;
		if (this.iNextSecondaryWeapon != this.iSelectedSecondaryWeapon) this.iSelectedSecondaryWeapon = this.iNextSecondaryWeapon;
		if (this.iNextGrenadePack != this.iGrenadePack) this.iGrenadePack = this.iNextGrenadePack;
		
		// Read class data
		HClass class;
		HClasses.GetArray(this.iHumanClass, class);
		
		HAlignment alignment;
		HAlignments.GetArray(this.iHumanAlignment, alignment);
		
		// Apply stats
		this.iType = PT_HUMAN;
		this.bCanLeap = false;
		this.iMaxHp = this.iHp = RoundToZero((class.health + this.getHumanResistance()) * alignment.flHealthMul);
		this.iArmor = class.armor + this.getHumanResistance(true) + alignment.iArmorAdd;
		this.flSpeed = (class.speed + this.getHumanDexterity(true)) * alignment.flSpeedMul;
		
		if (alignment.id == iMutantAlignment){
			CreateMutationTimer(this.id);
		}
		
		// test
		this.ResetKnife();
		
		this.setModel(ActualMode.is(MODE_MUTATION) ? HAZMAT_MODEL : class.model, class.arms);
		
		FakeClientCommandEx(this.id, "use weapon_knife");
		
		this.iLasermines = LASERMINE_QUANTITY;
		this.iLasermineDefused0 = 0;
		this.iLasermineDefused1 = 0;
		this.iLasermineDefused2 = 0;
		
		this.giveWeapons();
		//SDKHook(this.id, SDKHook_WeaponCanUse, OnWeaponCanUse);
		
		/////////////////////////////////////
		
		this.setGravity();
		this.iTeamNum = CS_TEAM_CT;
		
		//this.ResetKnife();
		
		// Normalize player's render
		SetEntityRenderMode(this.id, RENDER_NORMAL);
		SetEntityRenderColor(this.id, 255, 255, 255, 255);
		SetEntProp(this.id, Prop_Send, "m_nSkin", 0);
		
		// Enable/disable nightvision
		if (!this.bNightvision)
			this.bNightvisionOn = false;
		
		// Deploy hat
		//ReDeployHat(this.id);
		
		gClientData[this.id].Zombie = false;
		
		delete this.hIdleSound;
	}
	
	// Respawn player
	public void iRespawnPlayer(bool zombie = false){
		
		if (!IsPlayerExist(this.id, false))
			return;
		
		if (!IsFakeClient(this.id) && !this.bLoaded)
			return;
		
		if (this.bAlive || this.iTeamNum < CS_TEAM_T)
			return;
		
		//this.removeWeapons();
		CS_RespawnPlayer(this.id);
		zombie ? this.Zombiefy() : this.Humanize();
	}
	
	// DO NOT USE MANUALLY DOWNGRADE CHECKS, UPGRADE-CHECK TRIGGERS DOWNGRADES TOO
	// Check auto downgrade upon level down
	public void checkPrimaryWeaponDowngrade(bool notify = true){
		
		int length = WeaponsName.Length-1;
		if (this.iSelectedPrimaryWeapon > length){
			this.iSelectedPrimaryWeapon = length;
		}
		
		if (this.iNextPrimaryWeapon > length){
			this.iNextPrimaryWeapon = length;
		}
		
		if (this.iSelectedPrimaryWeapon < 1){
			return;
		}

		ZWeapon actualWeapon = ZWeapon(this.iSelectedPrimaryWeapon);
		
		if (this.iLevel >= actualWeapon.iLevel){
			return;
		}
		
		bool down = false;
	
		for (int i = this.iSelectedPrimaryWeapon; i >= 0; i--){
			
			if (this.iLevel >= actualWeapon.iLevel)
				break;
				
			if (ZWeapon(i).iType != WEAPON_PRIMARY)
				continue;
				
			if (ZWeapon(i).iTier != this.iTier){
				continue;
			}
			
			if (this.iLevel >= ZWeapon(i).iLevel){
				if (this.iReset >= ZWeapon(i).iReset){
					this.iSelectedPrimaryWeapon = this.iNextPrimaryWeapon = i;
					down = true;
					break;
				}
				else continue;
			}
			else continue;
		}
		
		if(notify && down){
			char sBuff[32];
			actualWeapon.GetName(sBuff, sizeof(sBuff));
			TranslationPrintToChat(this.id, "Your next primary weapon will be", sBuff);
		}
	}
	public void checkSecondaryWeaponDowngrade(bool notify = true){
		
		int length = WeaponsName.Length-1;
		if (this.iSelectedSecondaryWeapon > length){
			this.iSelectedSecondaryWeapon = length;
		}
		
		if (this.iNextSecondaryWeapon > length){
			this.iNextSecondaryWeapon = length;
		}
		
		if (this.iSelectedSecondaryWeapon < 1){
			return;
		}

		ZWeapon actualWeapon = ZWeapon(this.iSelectedSecondaryWeapon);
		
		if (this.iLevel >= actualWeapon.iLevel){
			return;
		}
		
		bool down = false;
	
		for (int i = this.iSelectedSecondaryWeapon; i >= 0; i--){
			
			if (this.iLevel >= actualWeapon.iLevel)
				break;
			
			if (ZWeapon(i).iType != WEAPON_SECONDARY)
				continue;
				
			if (ZWeapon(i).iTier != this.iTier){
				continue;
			}
			
			if (this.iLevel >= ZWeapon(i).iLevel){
				if (this.iReset >= ZWeapon(i).iReset){
					this.iSelectedSecondaryWeapon = this.iNextSecondaryWeapon = i;
					down = true;
					break;
				}
				else continue;
			} else continue;
		}
		
		if(notify && down){
			char sBuff[32];
			actualWeapon.GetName(sBuff, sizeof(sBuff));
			TranslationPrintToChat(this.id, "Your next secondary weapon will be", sBuff);
		}
	}
	public void checkGrenadePackDowngrade(bool notify = true){
		
		int length = gGrenadePackLevel.Length-1;
		if (this.iGrenadePack > length){
			this.iGrenadePack = length;
		}
		
		if (this.iNextGrenadePack > length){
			this.iNextGrenadePack = length;
		}
		
		if (this.iGrenadePack < 1){
			return;
		}
		
		ZGrenadePack actualPack = ZGrenadePack(this.iGrenadePack);
		
		if (this.iLevel >= actualPack.iLevel){
			return;
		}
		
		bool down = false;
	
		for (int i = this.iGrenadePack; i >= 0; i--){
			
			actualPack = ZGrenadePack(this.iGrenadePack);

			if (this.iLevel >= actualPack.iLevel)
				break;
			
			if (this.iReset >= ZGrenadePack(i).iReset && this.iLevel >= ZGrenadePack(i).iLevel){
				this.iGrenadePack = this.iNextGrenadePack = i;
				down = true;
			}
		}
		
		if(notify && down){
			TranslationPrintToChat(this.id, "Your next grenade pack will be", this.iNextGrenadePack+1);
		}
	}
	public void checkHumanClassDowngrade(bool notify = true){
		
		int length = HClasses.Length-1;
		if (this.iHumanClass > length){
			this.iHumanClass = length;
		}
		
		if (this.iNextHumanClass > length){
			this.iNextHumanClass = length;
		}
		
		if (this.iHumanClass < 1){
			return;
		}
		
		HClass actualClass;
		HClasses.GetArray(this.iHumanClass, actualClass);
		
		if (this.iLevel >= actualClass.level){
			return;
		}
		
		bool down = false;
	
		HClass iClass;
		for (int i = this.iHumanClass; i >= 0; i--){
			
			HClasses.GetArray(this.iHumanClass, actualClass);
			
			if (this.iLevel >= actualClass.level)
				break;

			HClasses.GetArray(i, iClass);
			
			if (this.iReset >= iClass.reset && this.iLevel >= iClass.level){
				this.iHumanClass = this.iNextHumanClass = i;
				down = true;
			}
		}
		
		if(notify && down){
			HClasses.GetArray(this.iHumanClass, actualClass);
			TranslationPrintToChat(this.id, "Your next human class will be", actualClass.name);
		}
	}
	public void checkZombieClassDowngrade(bool notify = true){
		
		int length = ZClasses.Length-1;
		if (this.iZombieClass > length){
			this.iZombieClass = length;
		}
		
		if (this.iNextZombieClass > length){
			this.iNextZombieClass = length;
		}
		
		if (this.iZombieClass < 1){
			return;
		}
		
		ZClass actualClass;
		ZClasses.GetArray(this.iZombieClass, actualClass);
		
		if (this.iLevel >= actualClass.level){
			return;
		}
		
		bool down = false;
		
		ZClass iClass;
		for (int i = this.iZombieClass; i >= 0; i--){
			
			ZClasses.GetArray(this.iZombieClass, actualClass);

			if (this.iLevel >= actualClass.level)
				break;

			ZClasses.GetArray(i, iClass);
			
			if (this.iReset >= iClass.reset && this.iLevel >= iClass.level){
				this.iZombieClass = this.iNextZombieClass = i;
				down = true;
			}
		}
		
		if(notify && down){
			ZClasses.GetArray(this.iZombieClass, actualClass);
			TranslationPrintToChat(this.id, "Your next zombie class will be", actualClass.name);
		}
	}
	
	// All auto downgrades in one simple call
	public void checkAutoDowngrade(bool notify = true){
		
		if (!IsPlayerExist(this.id))
			return;
			
		this.checkPrimaryWeaponDowngrade(notify);
		this.checkSecondaryWeaponDowngrade(notify);
		this.checkGrenadePackDowngrade(notify);
		this.checkHumanClassDowngrade(notify);
		this.checkZombieClassDowngrade(notify);
	}
	// DO NOT USE MANUALLY DOWNGRADE CHECKS, UPGRADE-CHECK TRIGGERS DOWNGRADES TOO
	
	// Check auto upgrade upon level up
	public void checkPrimaryWeaponUpgrade(bool notify = true){
		
		int length = WeaponsName.Length-1;
		
		if (this.iSelectedPrimaryWeapon > length){
			this.iSelectedPrimaryWeapon = 0;
			this.iNextPrimaryWeapon = 0;
		}
		
		if (this.iSelectedPrimaryWeapon == length) return;
		
		if (this.iNextPrimaryWeapon == length) return;
		
		if(!this.bAutoWeaponUpgrade) return;
		
		ZWeapon weap = ZWeapon(this.iSelectedPrimaryWeapon);
		if (this.iLevel < weap.iLevel || this.iReset < weap.iReset){
			this.checkPrimaryWeaponDowngrade();
			return;
		}
		
		// Halloween
		/*if (this.iPrimaryWeapon == iVipWeapon)
			return;*/
		
		/*ZWeapon weap = ZWeapon(this.iNextWeapon+1);
		while(this.iLevel >= weap.iLevel && this.iReset >= weap.iReset){
			if(this.iNextWeapon+1 >= length) break;
			this.iNextWeapon++;
			primaryWeaponsName.GetString(weap.id, buff, sizeof(buff));
			change = true;
			weap = ZWeapon(this.iNextWeapon+1);
		}*/
		
		char buff[32];
		bool change = false;
		
		int startpoint = this.iNextPrimaryWeapon+1;
		ZWeapon weapon;
		for (int i = startpoint; i <= length; i++){
			
			weapon = ZWeapon(i);
			if (!weapon.bInMenu)
				continue;
				
			if (weapon.iType != WEAPON_PRIMARY)
				continue;
			
			if (weapon.iTier != this.iTier){
				continue;
			}
			
			if (this.iLevel >= weapon.iLevel){
				if (this.iReset >= weapon.iReset){
						
					this.iNextPrimaryWeapon = i;
					weapon.GetName(buff, sizeof(buff));
					/*
					if (this.bStaff)
						PrintToChat(this.id, "Next weapon debug | next index = %d | next name: %s", i, buff);*/
					change = true;
				}
				else continue;
				/*ZWeapon nextweapon = ZWeapon(i+1);
				if (this.iLevel >= nextweapon.iLevel || this.iReset >= nextweapon.iReset)*/
			}
			else break;
		}
		
		if(change && notify) TranslationPrintToChat(this.id, "Your next primary weapon will be", buff);
	}
	public void checkSecondaryWeaponUpgrade(bool notify = true){
		
		int length = WeaponsName.Length-1;
		
		if (this.iSelectedSecondaryWeapon > length){
			this.iSelectedSecondaryWeapon = 0;
			this.iNextSecondaryWeapon = 0;
		}
		
		if (this.iSelectedSecondaryWeapon == length) return;
		
		if (this.iNextSecondaryWeapon == length) return;
		
		if(!this.bAutoWeaponUpgrade) return;
		
		ZWeapon weap = ZWeapon(this.iSelectedSecondaryWeapon);
		if (this.iLevel < weap.iLevel || this.iReset < weap.iReset){
			this.checkPrimaryWeaponDowngrade();
			return;
		}
		
		// Halloween
		/*if (this.iPrimaryWeapon == iVipWeapon)
			return;*/
		
		/*ZWeapon weap = ZWeapon(this.iNextWeapon+1);
		while(this.iLevel >= weap.iLevel && this.iReset >= weap.iReset){
			if(this.iNextWeapon+1 >= length) break;
			this.iNextWeapon++;
			primaryWeaponsName.GetString(weap.id, buff, sizeof(buff));
			change = true;
			weap = ZWeapon(this.iNextWeapon+1);
		}*/
		
		char buff[32];
		bool change = false;
		
		int startpoint = this.iNextSecondaryWeapon+1;
		ZWeapon weapon;
		for (int i = startpoint; i <= length; i++){
			
			weapon = ZWeapon(i);
			if (!weapon.bInMenu)
				continue;
				
			if (weapon.iType != WEAPON_SECONDARY)
				continue;
			
			if (weapon.iTier != this.iTier){
				continue;
			}
			
			if (this.iLevel >= weapon.iLevel){
				if (this.iReset >= weapon.iReset){
						
					this.iNextSecondaryWeapon = i;
					weapon.GetName(buff, sizeof(buff));
					/*
					if (this.bStaff)
						PrintToChat(this.id, "Next weapon debug | next index = %d | next name: %s", i, buff);*/
					change = true;
				}
				else continue;
				/*ZWeapon nextweapon = ZWeapon(i+1);
				if (this.iLevel >= nextweapon.iLevel || this.iReset >= nextweapon.iReset)*/
			}
			else break;
		}
		
		if(change && notify) TranslationPrintToChat(this.id, "Your next secondary weapon will be", buff);
	}
	public void checkGrenadePackUpgrade(bool notify = true){
		
		int length = gGrenadePackLevel.Length-1;
		
		if (this.iGrenadePack > length){
			this.iGrenadePack = 0;
			this.iNextGrenadePack = 0;
		}
		
		if (this.iGrenadePack == length) return;
		
		if (this.iNextGrenadePack == length) return;
		
		ZGrenadePack zpack = ZGrenadePack(this.iGrenadePack);
		
		if (this.iLevel < zpack.iLevel || this.iReset < zpack.iReset){
			this.checkGrenadePackDowngrade();
			return;
		}
		
		bool change = false;
		
		
		int startpoint = this.iNextGrenadePack+1;
		for (int i = startpoint; i <= length; i++){
			
			if(this.iNextGrenadePack+1 > length) break;
			
			ZGrenadePack pack = ZGrenadePack(i);
			if (this.iLevel >= pack.iLevel){
				if (this.iReset >= pack.iReset){
					this.iNextGrenadePack = i;
					change = true;
				}
				else continue;
			}
			else break;
		}
		
		if (change && notify) TranslationPrintToChat(this.id, "Your next grenade pack will be", this.iNextGrenadePack+1);
	}
	public void checkHumanClassUpgrade(bool notify = true){
		
		int length = HClasses.Length-1;
		
		if (this.iHumanClass > length){
			this.iHumanClass = 0;
			this.iNextHumanClass = 0;
		}
		
		if (this.iHumanClass == length) return;
		
		if (this.iNextHumanClass == length) return;
		
		HClass hclass;
		HClasses.GetArray(this.iHumanClass, hclass);
		
		if (this.iLevel < hclass.level || this.iReset < hclass.reset){
			this.checkHumanClassDowngrade();
			return;
		}
		
		bool change = false;
		
		int startpoint = this.iNextHumanClass+1;
		for (int i = startpoint; i <= length; i++){
			
			HClass class;
			HClasses.GetArray(i, class);
			
			if (this.iLevel >= class.level){
				if (this.iReset >= class.reset){
						
					
					this.iNextHumanClass = i;
					change = true;
				}
				else continue;
			}
			else break;
		}
		if (change && notify) {
			HClasses.GetArray(this.iNextHumanClass, hclass);
			TranslationPrintToChat(this.id, "Your next human class will be", hclass.name);
		}
	}
	public void checkZombieClassUpgrade(bool notify = true){
		
		int length = ZClasses.Length-1;
		
		if (this.iZombieClass > length){
			this.iZombieClass = 0;
			this.iNextZombieClass = 0;
		}
		
		if (this.iZombieClass == length) return;
		
		if (this.iNextZombieClass == length) return;
		
		ZClass zclass;
		ZClasses.GetArray(this.iZombieClass, zclass);
		
		if (this.iLevel < zclass.level || this.iReset < zclass.reset){
			
			this.checkZombieClassDowngrade();
			return;
		}
		
		bool change = false;
		
		int startpoint = this.iNextZombieClass+1;
		for (int i = startpoint; i <= length; i++){
			ZClass class;
			ZClasses.GetArray(i, class);
			
			if (this.iLevel >= class.level){
				if (this.iReset >= class.reset){
						
					
					this.iNextZombieClass = i;
					change = true;
				}
				else continue;
			}
			else break;
		}
		if (change && notify) {
			ZClass class;
			ZClasses.GetArray(this.iNextZombieClass, class);
			TranslationPrintToChat(this.id, "Your next zombie class will be", class.name);
		}
	}
	
	// All auto upgrades in one simple call
	public void checkAutoUpgrade(bool notify = true){
	
		if (!IsPlayerExist(this.id))
			return;
			
		if (this.bAutoWeaponUpgrade){
			this.checkPrimaryWeaponUpgrade(notify);
			this.checkSecondaryWeaponUpgrade(notify);
		}
		
		if (this.bAutoGrenadeUpgrade) this.checkGrenadePackUpgrade(notify);
		
		if (this.bAutoZClass){
			this.checkHumanClassUpgrade(notify);
			this.checkZombieClassUpgrade(notify);
		}
	}
	
	// Check level up
	public void checkLevelUp(){
		
		if (!IsPlayerExist(this.id))
			return;
		
		if (this.iLevel >= RESET_LEVEL){
			if (this.iExp > NextLevel(RESET_LEVEL-1, this.iReset)){
				this.iExp == NextLevel(RESET_LEVEL-1, this.iReset);
			}
			//return;
		}
		
		///////////////////////////
		// Check if leveled up
		bool upped = false;
		int nextLevel = NextLevel(this.iLevel, this.iReset);
		
		do{
			if (this.iLevel < NextLevel(RESET_LEVEL-1, this.iReset) && this.iExp >= nextLevel){
				this.iLevel++;
				upped = true;
			}
			
			nextLevel = NextLevel(this.iLevel, this.iReset);
		}
		while (this.iExp >= nextLevel);
	
		if(upped){
			TranslationPrintToChat(this.id, "You leveled up to", this.iLevel);
			this.checkAutoUpgrade();
			return;
		}
		
		// Now check if leveled down
		bool down = false;
		int previousLevel = NextLevel(this.iLevel-1, this.iReset);
		do{
			if (this.iExp < previousLevel && this.iLevel > 1){
				this.iLevel--;
				down = true;
			}
			
			previousLevel = NextLevel(this.iLevel-1, this.iReset);
		}
		while (this.iExp < NextLevel(this.iLevel-1, this.iReset) && this.iLevel > 1);
		
		if (down){
			TranslationPrintToChat(this.id, "You leveled down to", this.iLevel);
			this.checkAutoDowngrade();
		}
	}
	
	// Apply exp gain according to conditions
	public int applyGain(int gain){
		
		if (this.iLevel >= RESET_LEVEL){
			if (this.iExp > NextLevel(RESET_LEVEL-1, this.iReset)){
				this.iExp == NextLevel(RESET_LEVEL-1, this.iReset);
			}
			return 0;
		}
		
		////////////////////////////////
		
		int base = 0;
		
		// HappyHours, AfterHours and VIP boosts
		float multiplier = this.flExpBoost;
		
		if (multiplier > 1.0){
			if(gHappyHour) multiplier += HAPPY_HOUR_MULTIPLIER-1;
			else if(gAfterHour) multiplier += AFTER_HOUR_MULTIPLIER-1;
		}
		else{
			if(gHappyHour) multiplier *= HAPPY_HOUR_MULTIPLIER;
			else if(gAfterHour) multiplier *= AFTER_HOUR_MULTIPLIER;
		}
		
		// BONUS - EXP GAIN IS HIGHER WHEN ABOVE X QUANTITY OF PLAYERS ONLINE ANYTIME
		/*
		if (iPlayersQuantity >= BONUSTIME_MIN_PLAYERS){
			multiplier *= BONUSTIME_MULTIPLIER;
		}*/
		
		base = RoundToCeil(float(gain)*multiplier);
		
		if (iPlayersQuantity < PLAYERS_TO_GAIN || ActualMode.is(MODE_WARMUP))
			base /= 4;
		
		base = RoundToZero(float(base)*SERVER_EXP_MULTIPLIER);
		
		if (gain >= 1 && base >= 1){
			if (this.iLevel < RESET_LEVEL){
				if (this.iExp+base > NextLevel(RESET_LEVEL-1, this.iReset)) // if exp bypasses limit
					this.iExp = NextLevel(RESET_LEVEL-1, this.iReset); // make it BE the limit and not bypass it
				else
					this.iExp += base;
			
				// Check level
				this.checkLevelUp();
			}
		}
		
		return base;
	}
	
	// Points
	public int applyPoints(bool humanpoints = false){
		
		int x;
		if (bAllowGain){
			// Get values according to vip chances
			/*switch (this.flExpBoost){
				case 1.0: x = calculateChances(5, 2, 1);
				case 2.0: x = calculateChances(40, 2, 1);
				case 3.0: x = calculateChances(60, 2, 1);
				case 4.0: x = calculateChances(80, 2, 1);
				case 5.0: x = calculateChances(35, 3, 2);
				default: x = calculateChances(50, 3, 2);
			}
			*/
			if (!this.flExpBoost)
				return 0;
			
			/*if (this.flExpBoost == 1.0){
				x = 1;
			}
			else{
				ZVip maxVip;
				ZVips.GetArray(getTotalVips(), maxVip);
				
				if (this.flExpBoost <= maxVip.expBoost){ // if player's flExpBoost is lower or equal to the best VIP available
					ZVip vip;
					ZVips.GetArray(RoundToZero(this.flExpBoost)-2, vip); // as we dont register normal gain in array, we remove 2 indexes instead of 1.
					
					x = vip.pointsBonus;
				}
				else{
					x = 5;
				}
			}*/
			
			x = RoundToZero(this.flExpBoost);
			
			
			if (humanpoints == true){
				this.iHPoints += x;
			}
			else{
				this.iZPoints += x;
			}
			
			UTIL_CreateFadeScreen(this.id, 0.25, 0.1, FFADE_IN, {200, 200, 200, 200});
			
			char sBuffer[32];
			
			if (x == 1){
				
				Format(sBuffer, sizeof(sBuffer), "Obtained %s points", (humanpoints) ? "human" : "zombie");
				TranslationPrintToChat(this.id, sBuffer, x);
			}
			else{
				if (ActualMode.is(MODE_WARMUP) && fnGetPlayingLogged() < PLAYERS_TO_GAIN_IN_WARMUP){
					x = GetRandomInt(1, x);
				}
				
				Format(sBuffer, sizeof(sBuffer), "Obtained %s points vip", (humanpoints) ? "human" : "zombie");
				TranslationPrintToChat(this.id, sBuffer, x);
			}
		}
		
		return x;
	}
	
	// Update tags
	public void updateTag(){
		
		if (this.iTag != 0){
			char nam[48];
			tags.GetString(this.iTag, nam, sizeof(nam));
			CS_SetClientClanTag(this.id, nam);
		}
		else{
			RankTag rank;
			RankTags.GetArray(RankTags_FindForReset(this.iReset), rank);
			CS_SetClientClanTag(this.id, rank.name);
			
			this.iRankTag = rank.id;
		}
	}
	
	// Turn into bosses
	public void TurnInto(PlayerType type, bool unique = false){
	
		if(!IsPlayerExist(this.id, true))
			return;
			
		if (GetBossIndex(type) == -1)
			return;
		
		if (this.hMutationTimer != null){
			delete this.hMutationTimer;
		}
		
		// Clear any glow
		this.removeGlow();
		
		// Remove boss aura
		RemoveAura(this.id);
		
		// Remove any weapon
		this.bBoughtWeapons &= ~(WEAPONS_BOUGHT_PRIMARY|WEAPONS_BOUGHT_SECONDARY|WEAPONS_BOUGHT_GRENADES);
		this.removeWeapons();
		
		this.iType = type;
		
		ZBoss boss;
		ZBosses.GetArray(GetBossIndex(type), boss);
		
		//PrintToChat(this.id, "Bossindex %d, playertype %d", iBossIndex, view_as<int>(type));
		
		this.iArmor = 0;
		this.bCanLeap = true;
		
		// test
		this.ResetKnife();
		
		char sModel[256];
		char sArmsModel[256];
		boss.GetModel(sModel, sizeof(sModel));
		boss.GetArms(sArmsModel, sizeof(sArmsModel));
		
		// Old model because multiple nemesis with new model will break some pcs
		if (type == PT_NEMESIS && !ActualMode.is(MODE_NEMESIS)){
			this.setModel(NEMESIS_MODEL_OLD, NEMESIS_MODEL_ARMS_OLD);
		}
		else this.setModel(sModel, sArmsModel);
		
		if (boss.iTeamNum == CS_TEAM_CT){
			
			this.iMaxHp = this.iHp = boss.iHealthBase + (boss.iHealthAdditive * fnGetZombies()) + this.getHumanResistance(true);
			if (unique)
				this.iMaxHp = this.iHp = RoundToCeil(this.iHp*UNIQUE_HUMAN_MULTIPLIER);
				
			this.iHp = RoundToNearest(float(this.iHp)*ActualMode.humanBossBuffHp);
			
			this.flSpeed = boss.flSpeed + this.getHumanDexterity(true, true);
			this.bInfiniteAmmo = true;
			
			// Prepare to give weapon
			int iWeapon;
			switch (type){
				case PT_SURVIVOR:{
					// Modded weapon
					iWeapon = iWeaponSurvivor;
					this.iPrimaryWeapon = iWeapon;
					GivePlayerItem(this.id, "weapon_elite");
					
					CreateAura(this.id, { BOSSES_AURA_COLOR_SURVIVOR_R, BOSSES_AURA_COLOR_SURVIVOR_G, BOSSES_AURA_COLOR_SURVIVOR_B, BOSSES_AURA_COLOR_SURVIVOR_A });
				}
				case PT_GUNSLINGER:{
					// Modded weapon
					iWeapon = iWeaponGunslinger;
					this.iSecondaryWeapon = iWeapon;
					
					CreateAura(this.id, { BOSSES_AURA_COLOR_SURVIVOR_R, BOSSES_AURA_COLOR_SURVIVOR_G, BOSSES_AURA_COLOR_SURVIVOR_B, BOSSES_AURA_COLOR_SURVIVOR_A });
				}
				case PT_SNIPER:{
					// Modded weapon
					iWeapon = iWeaponSniper;
					this.iPrimaryWeapon = iWeapon;
					
					CreateAura(this.id, { BOSSES_AURA_COLOR_SURVIVOR_R, BOSSES_AURA_COLOR_SURVIVOR_G, BOSSES_AURA_COLOR_SURVIVOR_B, BOSSES_AURA_COLOR_SURVIVOR_A });
				}
				case PT_MEOW:{
					// Modded weapon
					iWeapon = iWeaponMeow;
					this.iPrimaryWeapon = iWeapon;
					
					CreateAura(this.id, { BOSSES_AURA_COLOR_SURVIVOR_R, BOSSES_AURA_COLOR_SURVIVOR_G, BOSSES_AURA_COLOR_SURVIVOR_B, BOSSES_AURA_COLOR_SURVIVOR_A });
				}
				case PT_SUPERSURVIVOR:{
					// Modded weapon
					iWeapon = iWeaponSuperSurvivor;
					this.iPrimaryWeapon = iWeapon;
					GivePlayerItem(this.id, "weapon_elite");
					this.applyGlow({ 244, 221, 25 });
					CreateAura(this.id, { 0, 50, 255, 160 }, false);
				}
				case PT_CHAINSAW:{
					// Modded weapon
					iWeapon = iWeaponChainsaw;
					this.iPrimaryWeapon = iWeapon;
					GivePlayerItem(this.id, "weapon_elite");
					this.applyGlow({ 50, 50, 255 });
					CreateAura(this.id, { 0, 50, 255, 160 }, false);
				}
			}
			
			// Give weapon
			this.GiveNetworkedWeapon(iWeapon);
			
			this.iTeamNum = CS_TEAM_CT;
			
			if (ActualMode.is(MODE_WARMUP)){
				if (this.iHp > WARMUP_HBOSSES_MAX_HP)
					this.iMaxHp = this.iHp = WARMUP_HBOSSES_MAX_HP;
			}
			
			//this.ResetKnife();
			
			// Normalize player's render
			SetEntityRenderMode(this.id, RENDER_NORMAL);
			SetEntityRenderColor(this.id, 255, 255, 255, 255);
			SetEntProp(this.id, Prop_Send, "m_nSkin", 0);
			
			gClientData[this.id].Zombie = false;
			
			// Enable/disable nightvision
			if (!this.bNightvision)
				this.bNightvisionOn = false;
		}
		else if (boss.iTeamNum == CS_TEAM_T){
			
			this.iMaxHp = this.iHp = this.getZombieUpgradedHP(boss.iHealthBase + (boss.iHealthAdditive * fnGetHumans()), true);
			//PrintToChatAll("HP DEL PUTO: %d, gbosshealthbase: %d + gbosshealthadditive: %d * gethumans: %D + zombieresis: %f", this.iHp, gBossHealthBase.Get(iBossIndex), gBossHealthAdditive.Get(iBossIndex), fnGetHumans(), this.getZombieResistance());
			if(unique){
				this.iMaxHp = this.iHp = RoundToCeil(this.iHp*(UNIQUE_ZOMBIE_BOSS_HP_MULTIPLIER));
			}
			//PrintToChatAll("HP DEL PUTO: %d", this.iHp);
			
			this.iHp = RoundToNearest(float(this.iHp)*ActualMode.zombieBossBuffHp);
			
			this.flSpeed = boss.flSpeed + this.getZombieDexterity(true, true);
			SetEntProp(this.id, Prop_Send, "m_nSkin", 0);
			
			// Turn off flashlight
			this.bFlashlight = false;
			
			switch(type){
				case PT_NEMESIS: {
					this.applyGlow({ 255, 20, 20 });
					CreateAura(this.id, { BOSSES_AURA_COLOR_NEMESIS_R, BOSSES_AURA_COLOR_NEMESIS_G, BOSSES_AURA_COLOR_NEMESIS_B, BOSSES_AURA_COLOR_NEMESIS_A });
					
					if (iPlayersQuantity >= BAZOOKA_MIN_PLAYERS_TO_GIVE && ActualMode.is(MODE_NEMESIS)){
						// Bazooka
						/*int weapon = this.GiveNetworkedWeapon(iWeaponBazooka);
						RemovePlayerItem(this.id, weapon);
						RemoveEdict(weapon);
						this.GiveNetworkedWeapon(iWeaponBazooka);*/
						
						CreateNetworkedWeaponEnt(this.id, iWeaponBazooka);
						
						TranslationPrintToChat(this.id, "You have a bazooka");
					}
				}
				case PT_ASSASSIN: {}
//				case PT_FEV: {
//					this.applyGlow({ 20, 255, 20 });
//					CreateBossAura(this.id);
//				}
			}
			
			// Move to terrorist
			this.iTeamNum = CS_TEAM_T;
			
			if (ActualMode.is(MODE_WARMUP)){
				if (this.iHp > WARMUP_ZBOSSES_MAX_HP)
					this.iMaxHp = this.iHp = WARMUP_ZBOSSES_MAX_HP;
			}
			
			// Reset knife entity
			FakeClientCommandEx(this.id, "use weapon_knife");
			
			// Display visual effects
			float clientloc[3];
			float direction[3] = {0.0, 0.0, 0.0};
			
			// Get client's position.
			GetClientAbsOrigin(this.id, clientloc);
			clientloc[2] += 30;
			
			CreateEnergySplash(clientloc, direction, true);
			/*int flags;
			flags = flags | EXP_NOSMOKE | EXP_NOSOUND;
			CreateExplosion(clientloc, flags);*/
			ShakeClientScreen(this.id, 60.0, 1.0, 1.0);
			
			// Enable nightvision
			this.toggleNv(true);
			
			// Remove planted lasermines
			RemoveLasermines(this.id);
			
			gClientData[this.id].Zombie = true;
		}
		
		// Apply gravity
		this.setGravity();
		
		delete this.hIdleSound;
	}
}

//=====================================================
//					UTILITIES
//=====================================================

void ZPlayerOnInit(){
	
	// Forward event to sub-modules
	ToolsOnInit();
}

void ZPlayerOnClientConnect(int client){
	
	// Forward event to sub-modules
	ToolsOnClientConnect(client);
}

void ZPlayerOnUnload(){
	
	// Forward event to sub-modules
	ToolsOnUnload();
}

void ZPlayerOnPurge(){
	
	// Forward event to sub-modules
	ToolsOnPurge();
}

void ZPlayerOnClientDeath(int client){
	
	ZPlayer(client).removeWeapons();
}

// Get random user
stock int GetRandomUser(PlayerType type = PT_NONE, bool cantRepeat = false){
	
	int[] clients = new int[MaxClients+1];
	int clientCount;
	
	static int cachedselected;
	int selected;
	
	for (int i = 1; i <= MaxClients; i++){
		ZPlayer player = ZPlayer(i);
		
		if (!IsPlayerExist(i, true))
			continue;
		
		// Prevent multiple times being the selected one
		if (i == cachedselected && cachedselected != 0)
			continue;
		
		if (type != PT_NONE && !player.isType(type)) // If player is the desired type or type is PT_NONE (means we only need an alive player)
			continue;
		
		clients[clientCount++] = i;
	}
	
	selected = clients[GetRandomInt(0, clientCount-1)];
	
	if (selected == cachedselected){
		for (int i = 0; i < clientCount; i++){    // cycle through the numbers
			if (clients[i] == cachedselected) { // number matches
				for (int j = i+1; j < clientCount; j++) {  // cycle through remaining numbers
					clients[j-1] = clients[j]; // shift remaining numbers back 1
				}
				clientCount--;  // Decrement number of random numbers stored.
			}
		}
	}
	
	cachedselected = selected;
	
	return (clientCount == 0) ? -1 : selected;
}

// Get random user
stock int GetRandomUserNoBots(PlayerType type = PT_NONE, bool cantRepeat = false){
	
	int[] clients = new int[MaxClients+1];
	int clientCount;
	
	static int cachedselected;
	int selected;
	
	for (int i = 1; i <= MaxClients; i++){
		ZPlayer player = ZPlayer(i);
		
		if (!IsPlayerExist(i, true))
			continue;
		
		if (IsFakeClient(i))
			continue;
		
		// Prevent multiple times being the selected one
		if (i == cachedselected && cachedselected != 0 && cantRepeat)
			continue;
		
		if (type != PT_NONE && !player.isType(type)) // If player is the desired type or type is PT_NONE (means we only need an alive player)
			continue;
		
		clients[clientCount++] = i;
	}
	
	selected = clients[GetRandomInt(0, clientCount-1)];
	
	if (selected == cachedselected){
		for (int i = 0; i < clientCount; i++){    // cycle through the numbers
			if (clients[i] == cachedselected) { // number matches
				for (int j = i+1; j < clientCount; j++) {  // cycle through remaining numbers
					clients[j-1] = clients[j]; // shift remaining numbers back 1
				}
				clientCount--;  // Decrement number of random numbers stored.
			}
		}
	}
	
	cachedselected = selected;
	
	return (clientCount == 0) ? -1 : selected;
}

stock int fnGetHumans(){
	int nHumans;
	
	ZPlayer player;
	for (int i = 1; i <= MaxClients; i++){
		player = ZPlayer(i);
		
		if(!IsPlayerExist(player.id, true))
			continue;
		
		if(!player.isHuman())
			continue;
		
		nHumans++;
	}
	return nHumans;
}
stock int fnGetZombies(){
	int nZombies;
	
	ZPlayer player;
	for (int i = 1; i <= MaxClients; i++){
		player = ZPlayer(i);
		
		if(!IsPlayerExist(player.id))
			continue;
		
		if(!player.isZombie())
			continue;
		
		nZombies++;
	}
	return nZombies;
}
stock int GetValidPlaying(bool alive = false){
	int iPlaying;
	
	ZPlayer player;
	for (int i = 1; i <= MaxClients; i++){
		player = ZPlayer(i);
		
		if (!IsPlayerExist(player.id, alive))
			continue;
		
		iPlaying++;
	}
	return iPlaying;
}
stock int GetValidPlayingHumans(bool alive = true){
	
	int iPlaying;
	ZPlayer player;
	
	for (int i = 1; i <= MaxClients; i++){
		player = ZPlayer(i);
		
		if (!IsPlayerExist(player.id, alive) || !player.isType(PT_HUMAN))
			continue;
		
		iPlaying++;
	}
	return iPlaying;
}

stock int GetValidPlayingZombies(bool alive = true){
	
	int iPlaying;
	ZPlayer player;
	
	for (int i = 1; i <= MaxClients; i++){
		player = ZPlayer(i);
		
		if (!IsPlayerExist(player.id, alive) || !player.isType(PT_ZOMBIE))
			continue;
		
		iPlaying++;
	}
	return iPlaying;
}

// Interactive sounds
stock void EmitHurtSound(int client){
	
	ZPlayer p = ZPlayer(client);
	switch(p.iType){
		case PT_ZOMBIE: {
			int chance = GetRandomInt(0, 10);
			if(chance == 5){
				float ori[3];
				GetClientAbsOrigin(client, ori);
				int sound = GetRandomInt(0, sizeof(ZPainSounds)-1);
				SelectiveEmitSoundToAll(ZPainSounds[sound], ori);
			}
		}
		case PT_NEMESIS, PT_ASSASSIN: {
			int chance = GetRandomInt(0, 10);
			if(chance == 5){
				float ori[3];
				GetClientAbsOrigin(client, ori);
				char buf[64];
				int sound = GetRandomInt(1, 3);
				FormatEx(buf, 64, "*/MassiveInfection/nemesis_pain%d.mp3", sound);
				SelectiveEmitSoundToAll(buf, ori);
			}
		}
	}
}
stock void EmitDeathSound(int client){
	
	ZPlayer p = ZPlayer(client);
	switch(p.iType){
		case PT_ZOMBIE: {
			float ori[3];
			GetClientAbsOrigin(client, ori);
			int sound = GetRandomInt(0, sizeof(ZDieSounds)-1);
			EmitAmbientSound(ZDieSounds[sound], ori, client, SNDLEVEL_NORMAL, _, 0.5);
		}
	}
}
stock void EmitInfectSound(int client){
	
	float ori[3];
	GetClientAbsOrigin(client, ori);
	int sound = GetRandomInt(0, sizeof(InfectionSounds)-1);
	EmitAmbientSound(InfectionSounds[sound], ori, client, SNDLEVEL_NORMAL, _, 0.3);
}
stock void EmitIdleSound(int client){
	
	float ori[3];
	GetClientAbsOrigin(client, ori);
	int sound = GetRandomInt(0, sizeof(sZombieIdleSounds)-1);
	EmitAmbientSound(sZombieIdleSounds[sound], ori, client, SNDLEVEL_NORMAL, _, 0.2);
}

stock void SelectiveEmitSoundToAll(const char[] sound, const float origin[3] = NULL_VECTOR){
	
	ZPlayer player;
	for (int i=1; i<=MaxClients; i++){
		if (IsClientInGame(i)){
			
			player = ZPlayer(i);
			
			if (!player.bHearHurtSounds)
				continue;
			
			EmitSoundToClient(i, sound, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.2, _, _, origin, _, true, 0.0);
		}
	}
}

//=====================================================
//					NIGHTVISION
//=====================================================
#pragma unused sNvgColors
#define NVGCOLORS_NUMBER	8
char sNvgColors[NVGCOLORS_NUMBER][] = { "Color white", "Color red", "Color yellow", "Color blue", "Color light blue", "Color orange", "Color green", "Color purple" };
int iNvgColors[NVGCOLORS_NUMBER][3] = {
	{ 200, 200, 200 },
	{ 220, 10, 10 },
	{ 220, 200, 51 },
	{ 35, 35, 210 },
	{ 30, 229, 240 },
	{ 240, 150, 30 },
	{ 10, 220, 10 },
	{ 177, 71, 242 }
};

void CreateNightvisionLight(int client){

	ZPlayer player = ZPlayer(client);
	
	if (!IsPlayerExist(player.id, true))
		return;
	
	if (player.hasNightvision())
		return;
	
	float ClientsPos[3];
	GetClientAbsOrigin(client, ClientsPos);
	ClientsPos[2] += 60.0;
	
	char tName[128];
	Format(tName, sizeof(tName), "target_%i", client);
	DispatchKeyValue(client, "targetname", tName);
	
	char light_name[128];
	Format(light_name, sizeof(light_name), "light_%i", client);
	
	player.iNvEntity = CreateEntityByName("light_dynamic");
	DispatchKeyValue(player.iNvEntity,"targetname", light_name);
	DispatchKeyValue(player.iNvEntity, "parentname", tName);
	DispatchKeyValue(player.iNvEntity, "inner_cone", "0");
	DispatchKeyValue(player.iNvEntity, "cone", "80");
	DispatchKeyValue(player.iNvEntity, "brightness", "0");
	DispatchKeyValueFloat(player.iNvEntity, "spotlight_radius", 230.0);
	DispatchKeyValue(player.iNvEntity, "pitch", "90");
	DispatchKeyValue(player.iNvEntity, "style", "5");
	DispatchSpawn(player.iNvEntity);
	
	SDKHook(player.iNvEntity, SDKHook_SetTransmit, OnTransmitNightvisionEntity);
	
	TeleportEntity(player.iNvEntity, ClientsPos, NULL_VECTOR, NULL_VECTOR);
	
	SetVariantString(tName);
	AcceptEntityInput(player.iNvEntity, "SetParent", player.iNvEntity, player.iNvEntity, 0);
	
	/*SetVariantString("forward");
	AcceptEntityInput(player.iNvEntity, "SetParentAttachmentMaintainOffset", player.iNvEntity, player.iNvEntity, 0);*/
	
	//SetEntProp(player.iNvEntity, Prop_Data, "m_Flags", 8);
	SetEntProp(player.iNvEntity, Prop_Data, "m_Flags", 2);
	SetEntPropEnt(player.iNvEntity, Prop_Data, "m_hOwnerEntity", client);
	
	player.toggleNv(true);
}
bool DispatchDistanceAndColor(int client){
	
	ZPlayer player = ZPlayer(client);
	
	if (!IsPlayerExist(client) || !IsValidEntity(player.iNvEntity))
		return false;
	
	float distance = (player.iTeamNum == CS_TEAM_CT) ? NIGHTVISION_DISTANCE_HUMANS : NIGHTVISION_DISTANCE_ZOMBIES;

	char color[24];
	if (player.bLoaded)
		//FormatEx(color, sizeof(color), "%d %d %d 255", iNvgColors[player.iNvColor][0], iNvgColors[player.iNvColor][1], iNvgColors[player.iNvColor][2]);
		FormatEx(color, sizeof(color), "%d %d %d 255", iNvgColors[player.iNvColor][0], iNvgColors[player.iNvColor][1], iNvgColors[player.iNvColor][2]);
	else
		FormatEx(color, sizeof(color), "255 255 255 255");
	
	DispatchKeyValueFloat(player.iNvEntity, "distance", distance);
	DispatchKeyValue(player.iNvEntity, "_light", color);
	
	return distance != 0.0;
}
public Action OnTransmitNightvisionEntity(int entity, int client){
	
	ZPlayer player = ZPlayer(client);
	ZPlayer owner = ZPlayer(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"));
	
	/*if (owner.iNvEntity == entity){
		return Plugin_Continue;
	}*/
	
	if (owner.id == client)
		return Plugin_Continue;
	
	if (!IsPlayerAlive(player.id)){
		// Is our player spectating someone?
		int iSpecMode = GetEntProp(player.id, Prop_Send, "m_iObserverMode");
		
		if (iSpecMode == SPECMODE_FIRSTPERSON || iSpecMode == SPECMODE_3RDPERSON){
			int iTarget = GetEntPropEnt(player.id, Prop_Send, "m_hObserverTarget");
			
			if (!IsPlayerExist(iTarget, true))
				return Plugin_Handled;
			
			ZPlayer target = ZPlayer(iTarget);
			
			if (entity == target.iNvEntity)
				return Plugin_Continue;
		}
	}
	return Plugin_Handled;
}
 
public Action TimerStartIdleSounds(Handle hTimer, int client){
	
	ZPlayer player = ZPlayer(client);
	
	if (!player.bAlive || !player.isType(PT_ZOMBIE))
		return Plugin_Stop;
	
	if (calculateChances(35, 1, 0) == 1)
		EmitIdleSound(client);
	
	return Plugin_Continue;
}


////////////////////////
void StartInfectionEffect(int client){
	
	// Display visual effects
	/*float clientloc[3];
	float direction[3] = {0.0, 0.0, 0.0};
	
	// Get client's position.
	GetClientAbsOrigin(client, clientloc);
	clientloc[2] += 30;
	
	CreateEnergySplash(clientloc, direction, true);
	ShakeClientScreen(client, 60.0, 1.0, 1.0);
	
	// Emit an infect effect
	ParticlesCreate(client, "", "fire_vixr_final", 1.0);*/

	CreateAura(client, { 0, 90, 0, 60 }, false);
	CreateTimer(1.2, RemoveInfectionEffect, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action RemoveInfectionEffect(Handle hTimer, int client){
	
	RemoveAura(client);
}

// EXTRA ITEMS PERSIST ON DISCONNECT
void ExtraItems_PersistOnPlayer(int client){
	
	if (!IsClientConnected(client))
		return;
	
	int steamid = GetSteamAccountID(client);
	
	gPersistantAntidotesId.Push(steamid);
	gPersistantAntidotesCount.Push(ZPlayer(client).iAntidoteCount);
}

void ExtraItems_UpdateFromPersistance(int client){
	
	if (!IsClientConnected(client))
		return;
	
	int steamid = GetSteamAccountID(client);
	
	int historicId = gPersistantAntidotesId.FindValue(steamid);
	
	if (historicId <= -1)
		return;
	ZPlayer player = ZPlayer(client);
	
	player.iAntidoteCount = gPersistantAntidotesCount.Get(historicId);
	player.iAntidotes = MAX_ANTIDOTES - ZPlayer(client).iAntidoteCount;
}

//=====================================================
//					LEAP
//=====================================================

public void JumpBoostOnClientJumpPost(int userID){
	
	// Gets client index from the user ID
	int client = GetClientOfUserId(userID);
	
	// Validate client
	if (client){
		// Gets client velocity
		static float vVelocity[3];
		ToolsGetVelocity(client, vVelocity);
		
		// Only apply horizontal multiplier if it not a bhop
		if (GetVectorLength(vVelocity) < 300.0){
			
		    // Apply horizontal multipliers to jump vector
		    vVelocity[0] *= 1.1;
		    vVelocity[1] *= 1.1;
		}
		
		// Apply height multiplier to jump vector
		vVelocity[2] *= 1.1;
		
		// Sets new velocity
		ToolsSetVelocity(client, vVelocity, true, false);
	}
}

stock void JumpBoostOnClientLeapJump(int client){
	
	if (IsOnCooldown(client, 0.3))
		return;
	
	if (!(GetEntityFlags(client) & FL_ONGROUND)){
		return;
	}
	
	// Initialize some floats
	static float vAngle[3];
	static float vPosition[3]; static float vVelocity[3];
	
	// Gets client location and view direction
	ToolsGetAbsOrigin(client, vPosition);
	GetClientEyeAngles(client, vAngle);
	
	// Store zero angle
	//float flAngleZero = vAngle[0];    
	
	// Gets location angles
	vAngle[0] = -30.0;
	GetAngleVectors(vAngle, vVelocity, NULL_VECTOR, NULL_VECTOR);
	
	// Scale vector for the boost
	ScaleVector(vVelocity, 460.0);
	
	// Restore eye angle
	//vAngle[0] = flAngleZero;
	
	// Push the player
	TeleportEntity(client, vPosition, NULL_VECTOR, vVelocity);
}