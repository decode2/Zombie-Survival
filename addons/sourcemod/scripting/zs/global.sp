enum EngineOS{
	
	OS_Unknown,
	OS_Windows,
	OS_Linux
};
/**
 * @endsection
 **/
 
/**
 * @section Struct of operation types for server arrays.
 **/
enum struct ServerData{
	
	/* Globals */
	bool RoundNew;
	bool RoundEnd;
	bool RoundStart;
	int RoundNumber;
	int RoundMode;
	int RoundLast;
	int RoundCount;
	ArrayList Clients;
	ArrayList LastZombies;
	
	/* Map */
	bool MapLoaded;
	ArrayList Spawns;
	ArrayList Particles;
	StringMap Entities;
	
	/* OS */
	Address Engine;
	EngineOS Platform;
	
	/* Timer */
	Handle CounterTimer;
	Handle TVirusReleasedTimer;
	
	/* Sounds */
	Handle EndTimer; 
	Handle BlastTimer;
	
	/* Gamedata */
	GameData Config;
	GameData SDKHooks;
	GameData SDKTools;
	GameData CStrike;

	/* Database */
	Database DBI;
	StringMap Cols;
	StringMapSnapshot Columns;
	
	/* Synchronizers */
	Handle LevelSync;
	Handle AccountSync;
	Handle GameSync;
	
	/* Configs */
	ArrayList ExtraItems;
	ArrayList HitGroups;
	ArrayList GameModes;
	ArrayList Cvars;
	ArrayList Classes;
	ArrayList Types;
	ArrayList Costumes;
	ArrayList Menus;
	ArrayList Logs;
	ArrayList Weapons;
	ArrayList Downloads;
	ArrayList Sounds;
	ArrayList Levels;
	StringMap Configs;
	StringMap Modules;
	
	/* Weapons */
	int Melee;
	StringMap Market;

	/**
	 * @brief Clear all timers.
	 **/
	void PurgeTimers(/*void*/)
	{
		this.TVirusReleasedTimer = null;
		this.CounterTimer = null;
		this.EndTimer     = null;
		this.BlastTimer   = null;
	}
}
/**
 * @endsection
 **/

/**
 * Array to store the server data.
 **/
ServerData gServerData;

enum PlayerType{
	PT_NONE = -1,
	PT_HUMAN,
	PT_SURVIVOR,
	PT_GUNSLINGER,
	PT_SNIPER,
	PT_SUPERSURVIVOR,
	PT_CHAINSAW,
	PT_MEOW,
	PT_MAX_HUMANS,
	PT_ZOMBIE,
	PT_NEMESIS,
	PT_ASSASSIN,
	PT_FEV,
	PT_MAX_ZOMBIES
}

/**
 * @section Struct of operation types for client arrays.
 **/
enum struct ClientData{
	
	/* ported from zplayer */
	int id;
	int iPiuPoints;
	bool bVip;
	int iAccessLevel;
	bool bAdmin;
	bool bStaff;
	bool bStopSound;
	bool bAlive;
	bool bChatBanned;
	bool bVoiceChatBanned;
	bool bLadder;
    int iRoundDeaths;
	int iHp;
    int iMaxHp;
	int iArmor;
    bool bChangedName;
    bool bAFK;
    int iTimesAFKed;
    bool bLogged;
    bool bLoaded;
    int iSteamAccountID;
    
    // Refeer code
    char sRefeerCode[12];
    
    // Hud timer
    Handle hHudTimer;
	
	// Tags
	int iTag;
	int iNextTag;
	bool bInTagCreation;
	
	// Rank tags
	int iRankTag;
	
	float flExpBoost;
	
	// Model index
	//property int iModelIndex;
	
	// Combos
	int iDamageDealt;
	int iCombo;
	int iComboType;
	float fComboTime;
	Handle hComboHandle;
	
	// AP gain per X damage dealt
	int iDamageDealtCounter;
	
	// 
	bool bCanLeap;
	bool bAutoWeaponsBuy;
	bool bAutoWeaponUpgrade;
	bool bAutoGrenadeUpgrade;
	bool bAutoHClass;
	bool bAutoZClass;
	
	int iPjSeleccionado;
	int iPjEnMenu;
	int iIdPjSlot[MAXCHARACTERS_LEGACY];
	bool bIsSlotEmpty[MAXCHARACTERS_LEGACY];
	/*
	void TeleportPlayer(float origin[3] = NULL_VECTOR, float angles[3] = NULL_VECTOR, float velocity[3] = NULL_VECTOR){
		TeleportEntity(this.id, origin, angles, velocity);
	}
	void flGetOrigin(float x[3]){
		GetClientAbsOrigin(this.id, x);
	}
	void flGetEyePosition(float x[3]){
		GetClientEyePosition(this.id, x);
	}
	void flGetEyeAngles(float x[3]){
		GetClientEyeAngles(this.id, x);
	}
	void lVelocity(float x[3]){
		GetEntPropVector(this.id, Prop_Data, "m_vecVelocity", x);
	}*/
	int iAntidotes;
	int iMadness;
	
	// Idle sounds handle
	Handle hIdleSound;	
	bool bEnableHurtSound;
	
	// Points
	int iHPoints;
	int iZPoints;
	
	// Next attack
	float fNextAttack;
	
	bool bRecentlyRegistered;
	
	// Golden points
	int iHGoldenPoints;
	int iZGoldenPoints;
	
	// Hat points
	int iHatPoints;
	
	// Human upgrades
	int iHDamageLevel;
	int iHResistanceLevel;
	int iHDexterityLevel;
	
	// Zombie upgrades
	int iZDamageLevel;
	int iZHealthLevel;
	int iZDexterityLevel;
	
	// Golden upgrades
	int iGoldenZUpgradeLevel[4];
	int iGoldenHUpgradeLevel[4];
	
	// Human golden upgrades
	/*int iLmHpLevel;
	int iCritChanceLevel;
	int iItemChanceLevel;
	int iAuraTimeLeve;
	
	// Zombie golden upgrades
	int iMadnessTimeLevel;
	int iDamageToLmLevel;
	int iLeechLevel;
	int iMadnessChanceLevel;*/
	float fMadnessChanceTime;
	//
	int iExp;
	int iLevel;
	int iReset;
	
	int iTier;
	//
	bool bRecentlyInfected;
	bool bInvulnerable;
	bool bReceivePartyInv;
    
    // Player type
	PlayerType iType;
    
    // Classes
	int iHumanClass;
	int iZombieClass;
	int iNextHumanClass;
	int iNextZombieClass;
	
	// Alignments
	int iHumanAlignment;
	int iZombieAlignment;
	int iNextHumanAlignment;
	int iNextZombieAlignment;
	
	// Weapons
	int iSelectedPrimaryWeapon;
	int iSelectedSecondaryWeapon;
    int iWeaponBought;
	int iPrimaryWeapon;
	int iSecondaryWeapon;
	int iNextPrimaryWeapon;
	int iNextSecondaryWeapon;
	
	int iActiveWeapon;
	int iActiveWeaponIndex;
	
	// Grenades
	int iGrenadePack;
	int iNextGrenadePack;
	int bBoughtWeapons;
	bool bInfiniteAmmo;
	bool bFlashlight;
	int iLasermines;
	int iLaserminesHP[3]; // ammount of deployeable lasermines
	bool bInLmAction;
	Handle hFreezeTimer;
	
	// Hud colors
	int iHudColor;
    
	// Extra Items buy count
	int iItemsCount[5];
	
	// Track how many times the user can buy an item
	int iRemainingPurchases;
	
	// Madness cooldown
	float flMadnessTime;
	
	// Glow support
	bool bGlowing;
	int iModel;
	int iModelIndex;
	
	// Nightvision
	int iNvEntity;
	bool bNightvision;
	bool bNightvisionOn;
	int iNvColor;
	
	// Bosses aura
	bool bAura;
	int iAuraEntity;
	
	// Hat
	int iHat;
	int iNextHat;
	int iHatRef;
	
	// Infection heritage
	int iInfectorId;
	int iInfectedId;
	
	// Mutation timer
	Handle hMutationTimer;
	
	// <party>
	int iPartyUID;
	bool bInParty;
	// </party>
	
	int iIgniterId;
	
	// Menus vars
	bool bUseMyName;
	bool bInRenameMenu;
	bool bPartyMenuKicks;
	int InfoMenuPage;
	
	///////////////////
	// NEW
	///////////////////
	
	/* Globals */
	int AccountID;
	bool Zombie;
	bool Loaded;
	bool Skill;
	float SkillCounter;
	int Class;
	int HumanClassNext;
	int ZombieClassNext;
	int Respawn;
	int RespawnTimes;
	int Money;
	int LastPurchase;
	int Level;
	int Exp;
	int Costume;
	int Time;
	bool Vision;
	int DataID;
	int LastID;
	int LastAttacker;
	int TeleTimes;
	int TeleCounter;
	float TeleOrigin[3];
	float HealthDuration;
	int AttachmentCostume;
	int AttachmentHealth;
	int AttachmentController;
	int AttachmentBits;
	int AttachmentAddons[12]; /* Amount of weapon back attachments */
	
	/* Weapons */
	int ViewModels[2];
	int IndexWeapon;
	int CustomWeapon;
	int LastWeapon;
	int LastGrenade;
	int LastKnife;
	int SwapWeapon;
	int LastSequence;
	int LastSequenceParity;
	bool ToggleSequence;
	bool RunCmd;
	
	/* Timers */
	Handle LevelTimer;
	Handle AccountTimer;
	Handle RespawnTimer;
	Handle SkillTimer;
	Handle CounterTimer;
	Handle HealTimer;
	Handle SpriteTimer;
	Handle MoanTimer;
	Handle AmbientTimer;
	Handle BuyTimer;
	Handle TeleTimer;
	
	/* Arrays */
	ArrayList ShoppingCart;
	ArrayList DefaultCart;
	StringMap ItemLimit;
	StringMap WeaponLimit;
	
	/**
	 * @brief Resets all variables.
	 **/
	void ResetVars(/*void*/)
	{
		this.AccountID            = 0;                
		this.Zombie               = false;
		this.Loaded               = false;
		this.Skill                = false;
		this.SkillCounter         = 0.0;
		this.Class                = 0;
		this.HumanClassNext       = 0;
		this.ZombieClassNext      = 0;
		this.Respawn              = TEAM_HUMAN;
		this.RespawnTimes         = 0;
		this.Money                = 0;
		this.LastPurchase         = 0;
		this.Level                = 1;
		this.Exp                  = 0;
		this.Costume              = -1;
		this.Time                 = 0;
		this.Vision               = true;
		this.DataID               = -1;
		this.LastID               = -1;
		this.LastAttacker         = 0;
		this.TeleTimes            = 0;
		this.TeleCounter          = 0;
		this.TeleOrigin           = NULL_VECTOR;
		this.HealthDuration       = 0.0;
		this.AttachmentCostume    = -1;
		this.AttachmentHealth     = -1;
		this.AttachmentController = -1;
		this.AttachmentBits       = 0;
		this.AttachmentAddons[0]  = -1;
		this.AttachmentAddons[1]  = -1; 
		this.AttachmentAddons[2]  = -1; 
		this.AttachmentAddons[3]  = -1; 
		this.AttachmentAddons[4]  = -1;
		this.AttachmentAddons[5]  = -1; 
		this.AttachmentAddons[6]  = -1; 
		this.AttachmentAddons[7]  = -1; 
		this.AttachmentAddons[8]  = -1; 
		this.AttachmentAddons[9]  = -1;
		this.AttachmentAddons[10] = -1;
		this.AttachmentAddons[11] = -1;
		this.ViewModels[0]        = -1;
		this.ViewModels[1]        = -1;
		this.IndexWeapon          = -1;
		this.CustomWeapon         = -1;
		this.LastWeapon           = -1;
		this.LastGrenade          = -1;
		this.LastKnife            = -1;
		this.SwapWeapon           = -1;
		this.LastSequence         = -1;
		this.LastSequenceParity   = -1;
		this.ToggleSequence       = false;
		this.RunCmd               = false;
	   
		delete this.ShoppingCart;
		delete this.DefaultCart;
		delete this.ItemLimit;
		delete this.WeaponLimit;
	}
	
	/**
	 * @brief Delete all timers.
	 **/
	void ResetTimers(/*void*/)
	{
		delete this.LevelTimer;
		delete this.AccountTimer;
		delete this.RespawnTimer;
		delete this.SkillTimer;
		delete this.CounterTimer;
		delete this.HealTimer;
		delete this.SpriteTimer;
		delete this.MoanTimer;
		delete this.AmbientTimer;
		delete this.BuyTimer;
		delete this.TeleTimer;
	}
	
	/**
	 * @brief Clear all timers.
	 **/
	void PurgeTimers(/*void*/)
	{
		this.LevelTimer   = null;
		this.AccountTimer = null;
		this.RespawnTimer = null;
		this.SkillTimer   = null;
		this.CounterTimer = null;
		this.HealTimer    = null;
		this.SpriteTimer  = null;
		this.MoanTimer    = null; 
		this.AmbientTimer = null; 
		this.BuyTimer     = null;
		this.TeleTimer     = null;
	}
}
/**
 * @endsection
 **/
 
/**
 * Array to store the client data.
 **/
ClientData gClientData[MAXPLAYERS+1];

/**
 * @section Core useful functions.
 **/
#define _call.%0(%1)  RequestFrame(%0, GetClientUserId(%1))
#define _exec.%0(%1)  RequestFrame(%0, EntIndexToEntRef(%1))
/**
 * @endsection
 **/
 
/**
 * @brief Called when an entity is created.
 *
 * @param entity            The entity index.
 * @param sClassname        The string with returned name.
 **/
public void OnEntityCreated(int entity, const char[] sClassname){
	
	// Forward event to modules
	
	// ZGrenades module forward
	ZGrenades_OnEntityCreated(entity, sClassname);
	
	// Weapons module forward
	Weapons_OnEntityCreated(entity, sClassname);
}

//////////////////////////////////////////////////////////////