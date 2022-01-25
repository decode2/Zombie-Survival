#pragma semicolon 1
#pragma newdecls required

#define DEBUG

/*#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>*/
#include <gamemodes_stats>

#if defined zgamemodes_included
	#endinput
#endif
#define zgamemodes_included

#define ZGAMEMODES_MODULE_VERSION "0.1"

//#define DEBUG_GAMEMODES

// WARM UP
#define WARMUP_DURATION 		60.0
#define WARMUP_ZOMBIES_MAX_HP 	400000

// Disable gain when players < PLAYERS_TO_GAIN
#define PLAYERS_TO_GAIN 			1
#define PLAYERS_TO_GAIN_IN_WARMUP 	5

// Modes' sounds
#define MODE_NEMESIS_SOUND "*/MassiveInfection/nemesis1.mp3"
#define MODE_SURVIVOR_SOUND "*/MassiveInfection/survivor1.mp3"
#define MODE_SWARM_SOUND "*/MassiveInfection/the_horror2.mp3"
#define AMBIENT_SOUND "*/MassiveInfection/ambiente.mp3"
#define AMBIENT_SOUND_INFECTION "*/MassiveInfection/infection.mp3"
#define AMBIENT_SOUND_ARMAGEDON "*/MassiveInfection/plague.mp3"
#define AMBIENT_SOUND_ZBOSS "*/MassiveInfection/survivor.mp3"
#define AMBIENT_SOUND_HBOSS "*/MassiveInfection/nemesis.mp3"
#define AMBIENT_SOUND_SWARM "*/MassiveInfection/swarm.mp3"
#define AMBIENT_SOUND_MEOW "*/MassiveInfection/catEvent2.mp3"

#define ANNOUNCER_HUD_Y_POSITION 	0.15

// Countdown defines
#define ROUND_START_COUNTDOWN 10

// Variables creation
bool bWarmupStarted = false;
bool bWarmupEnded = false;
Handle hWarmupTimer = null;
int iWarmupTime;

bool eventmode;

//=====================================================
//				GAMEMODES VARIABLES
//=====================================================
int iTotalProbabilities = 0;

enum GameModes {
	NO_MODE = 0,
	IN_WAIT,
	MODE_WARMUP,
	MODE_HORDE,
	MODE_INFECTION,
	MODE_MULTIPLE_INFECTION,
	MODE_ANIHHILATION,
	MODE_MASSIVE_INFECTION,
	MODE_SWARM,
	MODE_PLAGUE,
	MODE_NEMESIS,
	MODE_SURVIVOR,
	MODE_GUNSLINGER,
	MODE_ASSASSIN,
	MODE_SNIPER,
	MODE_CHAINSAW,
//	MODE_FEV,
	MODE_SYNAPSIS,
	MODE_MULTIPLE_NEMESIS,
	MODE_ARMAGEDDON,
	MODE_APOCALYPSIS,
	MODE_SUPERSURVIVOR,
	MODE_MUTATION,
	MODE_HYPERNEMESIS,
	MODE_PANDEMIC,
	MODE_MEOW
};

//=====================================================
//					ENUM STRUCT
//=====================================================

// Gamemodes
ArrayList ZGameModes;

enum struct ZGameMode{
	int id;
	char name[32];
	bool bInfection;
	bool bKill;
	bool bRespawn;
	bool bRespawnZombieOnly;
	bool bAntidoteAvailable;
	bool bZombieMadnessAvailable;
	
	float humanBossBuffHp;
	float zombieBossBuffHp;
	
	int minUsers;
	int probability;
	
	bool is(GameModes mode){
		if (this.id == view_as<int>(mode))
			return true;
		
		return false;
	}
	
	void GetName(char[] buffer, int maxlength){
		strcopy(buffer, maxlength, this.name);
	}
	
}

ZGameMode ActualMode;

// Functions
void GameModesOnInit(){
	
	// Gamemodes array
	ZGameModes = new ArrayList(sizeof(ZGameMode));
	
	// Register gamemodes
	LoadGamemodes();
	
	// Start gamemodes stats
	GamemodesStats_OnPluginStart();
	
	// Hook server events
	HookEvent("round_prestart",     GameModesOnStartPre,  EventHookMode_Pre);
	HookEvent("round_start",        GameModesOnStart,     EventHookMode_Post);
	///HookEvent("round_poststart", GameModesOnStartPost, EventHookMode_Post);
	HookEvent("cs_win_panel_round", GameModesOnPanel,     EventHookMode_Pre);
	
	// Creates a HUD synchronization object
	gServerData.GameSync = CreateHudSynchronizer();
	
	// Initialize an eligible client array
	/*gServerData.Clients = CreateArray();
	gServerData.LastZombies = CreateArray();*/
}

void GameModesOnCommandInit(/*void*/){
	
	// Hook commands
	//RegConsoleCmd("zp_mode_menu", GameModesOnCommandCatched, "Opens the modes menu.");
	
	// Hook listeners
	AddCommandListener(GameModesOnCommandListened, "mp_warmup_start");
	///AddCommandListener(GameModesOnCommandListened, "mp_warmup_end");
}

/**
 * @brief Hook gamemodes cvar changes.
 **/
 /*
void GameModesOnCvarInit(){
	
	// Creates cvars
	gCvarList.GAMEMODE                = FindConVar("zp_gamemode");
	gCvarList.GAMEMODE_BLAST_TIME     = FindConVar("zp_blast_time");
	gCvarList.GAMEMODE_WEAPONS_REMOVE = FindConVar("zp_weapons_remove");
	gCvarList.GAMEMODE_TEAM_BALANCE   = FindConVar("mp_autoteambalance"); 
	gCvarList.GAMEMODE_LIMIT_TEAMS    = FindConVar("mp_limitteams");
	gCvarList.GAMEMODE_WARMUP_TIME    = FindConVar("mp_warmuptime");
	gCvarList.GAMEMODE_WARMUP_PERIOD  = FindConVar("mp_do_warmup_period");
	gCvarList.GAMEMODE_ROUNDTIME_ZP   = FindConVar("mp_roundtime");
	gCvarList.GAMEMODE_ROUNDTIME_CS   = FindConVar("mp_roundtime_hostage");
	gCvarList.GAMEMODE_ROUNDTIME_DE   = FindConVar("mp_roundtime_defuse");
	gCvarList.GAMEMODE_ROUND_RESTART  = FindConVar("mp_restartgame");
	gCvarList.GAMEMODE_RESTART_DELAY  = FindConVar("mp_round_restart_delay");
	
	// Sets locked cvars to their locked value
	gCvarList.GAMEMODE_TEAM_BALANCE.IntValue  = 0;
	gCvarList.GAMEMODE_LIMIT_TEAMS.IntValue   = 0;
	gCvarList.GAMEMODE_WARMUP_TIME.IntValue   = 0;
	gCvarList.GAMEMODE_WARMUP_PERIOD.IntValue = 0;
	
	// Hook locked cvars to prevent it from changing
	HookConVarChange(gCvarList.GAMEMODE_TEAM_BALANCE,  CvarsLockOnCvarHook);
	HookConVarChange(gCvarList.GAMEMODE_LIMIT_TEAMS,   CvarsLockOnCvarHook);
	HookConVarChange(gCvarList.GAMEMODE_WARMUP_TIME,   CvarsLockOnCvarHook);
	HookConVarChange(gCvarList.GAMEMODE_WARMUP_PERIOD, CvarsLockOnCvarHook);
	HookConVarChange(gCvarList.GAMEMODE_ROUNDTIME_ZP,  GameModesTimeOnCvarHook);
	HookConVarChange(gCvarList.GAMEMODE_ROUNDTIME_CS,  GameModesTimeOnCvarHook);
	HookConVarChange(gCvarList.GAMEMODE_ROUNDTIME_DE,  GameModesTimeOnCvarHook);
	HookConVarChange(gCvarList.GAMEMODE_ROUND_RESTART, GameModesRestartOnCvarHook);
	HookConVarChange(gCvarList.GAMEMODE,               GameModesOnCvarHook);
}*/

void Gamemodes_OnPluginEnd(){
	
	ZGameModes.Clear();
	delete ZGameModes;
	
	// End gamemodes stats
	GamemodesStats_OnPluginEnd();
}


//=====================================================
//					GAMEMODES
//=====================================================
stock int CreateGameMode(const char[] name, bool infection, bool kill, bool respawn, bool respawnOnlyZombie, bool antidoteAvailable, bool zombiemadnessAvailable, float humanBossBuffHp = 1.0, float zombieBossBuffHp = 1.0, int minUsers = 0, int prob = 0){
	ZGameMode mode;
	mode.id = ZGameModes.Length;
	strcopy(mode.name, sizeof(mode.name), name);
	mode.bInfection = infection;
	mode.bKill = kill;
	mode.bRespawn = respawn;
	mode.bRespawnZombieOnly = respawnOnlyZombie;
	mode.bAntidoteAvailable = antidoteAvailable;
	mode.bZombieMadnessAvailable = zombiemadnessAvailable;
	
	mode.humanBossBuffHp = humanBossBuffHp;
	mode.zombieBossBuffHp = zombieBossBuffHp;
	
	mode.minUsers = minUsers;
	mode.probability = prob;
	
	if (prob)
		iTotalProbabilities += prob;
	
	return ZGameModes.PushArray(mode);
}

stock void SetProbabilities(){
	
	ZGameMode mode;
	ZGameMode premode;
	
	char name[32];
	for (int i = view_as<int>(MODE_INFECTION); i < ZGameModes.Length; i++){
		
		ZGameModes.GetArray(i, mode);
		mode.GetName(name, sizeof(name));
		
		if (!mode.probability){
			#if defined DEBUG_GAMEMODES
			LogToFile("addons/sourcemod/logs/DEBUG_MODES.txt", "[MODES] -----------------------------------------------");
			LogToFile("addons/sourcemod/logs/DEBUG_MODES.txt", "[MODES] SetProb, AVOIDING MODE WITH NO CHANCES: %s, mode.prob = %d", name, mode.probability);
			#endif
			continue;
		}
		
		if (i == view_as<int>(MODE_INFECTION)){
			#if defined DEBUG_GAMEMODES
			LogToFile("addons/sourcemod/logs/DEBUG_MODES.txt", "[MODES] -----------------------------------------------");
			//mode.probability = (mode.probability*100)/iTotalProbabilities;
			LogToFile("addons/sourcemod/logs/DEBUG_MODES.txt", "[MODES] SetProb, MODE IS INFECTION \t| CHANCES FROM 0 TO %d", mode.probability);
			#endif
		}
		else{
			
			ZGameModes.GetArray(i-1, premode);
			
			//mode.probability = premode.probability + (mode.probability*100/iTotalProbabilities);
			mode.probability += premode.probability;
			
			// Update array
			ZGameModes.SetArray(i, mode);
			
			#if defined DEBUG_GAMEMODES
			LogToFile("addons/sourcemod/logs/DEBUG_MODES.txt", "[MODES] SetProb, MODE IS %s \t| CHANCES FROM %d TO %d |", name, premode.probability+1, mode.probability);
			#endif
		}
	}
	
	#if defined DEBUG_GAMEMODES
	LogToFile("addons/sourcemod/logs/DEBUG_MODES.txt", "[MODES] TOTAL PROBABILITIES: %d", iTotalProbabilities);
	LogToFile("addons/sourcemod/logs/DEBUG_MODES.txt", "[MODES] -----------------------------------------------");
	#endif
}

// Gamemodes
public void LoadGamemodes(){

	ZGameModes.Clear();

	//	CreateGameMode(name, 			infection, kill, respawn, respawnOnlyZombie, antidoteAvailable, zombiemadnessAvailable, minUsers, probabilities)

	// Modes that won't get sorted
	CreateGameMode("Esperando amenaza.", false, false, 		true, 	false, 					false, 			false);
	CreateGameMode("Esperando usuarios", false, false, 		false, 	false, 					false, 			false);
	CreateGameMode("Warm Up", 			false, 	true, 		true, 	false, 					false, 			false);
	CreateGameMode("HORDE", 			false, 	true, 		true, 	false, 					false, 			false);
	
	// Allowed modes
	CreateGameMode("Infección", 		true, 	false, 		true, 	false, 					true, 			true, 	_, _, 		2, 15);
	CreateGameMode("Infección Múltiple", true, 	false, 		true, 	false, 					true, 			true, 	_, _, 		2, 10);
	CreateGameMode("Aniquilación", 		true, 	false, 		true, 	true, 					false, 			true, 	_, _, 		2, 14);
	CreateGameMode("Infección Masiva", 	true, 	false, 		true, 	true, 					true, 			true, 	_, _, 		4, 7);
	CreateGameMode("Swarm", 			false, 	true, 		false, 	false, 					false, 			true, 	_, _, 		4, 4);
	CreateGameMode("Plague", 			false, 	true, 		false, 	false, 					false, 			true, 	1.0, 0.5, 		4, 4);
	CreateGameMode("Nemesis", 			false, 	true, 		false, 	false, 					false, 			false, 	_, _, 		4, 5);
	CreateGameMode("Survivor", 			false, 	true, 		false, 	false, 					false, 			false, 	_, _,	 	4, 4);
	CreateGameMode("Gunslinger", 		false, 	true, 		false, 	false, 					false, 			false, 	_, _, 		4, 4);
	CreateGameMode("Assassin", 			false, 	true,		false, 	false, 					false, 			false,	_, _, 		4, 3);
	CreateGameMode("Sniper", 			false, 	true, 		false, 	false, 					false, 			false,	_, _, 		4, 3);
	CreateGameMode("CHAINSAW", 			false, 	true, 		false, 	false, 					false, 			false,	_, _, 		4, 3);
//	CreateGameMode("FEV", 				false, 	true, 		false, 	false, 					false, 			false,	10, 4);
	CreateGameMode("Synapsis", 			false, 	true, 		false, 	false, 					false, 			false,	1.5, 1.2, 	10, 4);
	CreateGameMode("Multinemesis",		false, 	true, 		true, 	true, 					false, 			true,	1.5, 1.5, 	4, 4);
	CreateGameMode("Armageddon", 		false, 	true, 		false, 	false, 					false, 			false,	1.6, 1.2, 	4, 3);
	CreateGameMode("Apocalypsis", 		false, 	true, 		false, 	false, 					false, 			false,	1.0, 1.4, 	4, 3);
	CreateGameMode("SUPER Survivor", 	false, 	true, 		false, 	false, 					false, 			false, 	_, _, 		4, 5);
	CreateGameMode("MUTACIÓN", 			true, 	false, 		true, 	false, 					false, 			true,	_, _, 		4, 4);
	
	// Modes that won't get sorted (EVENTS)
	CreateGameMode("Hypernemesis", 		false, 	true, 		true, 	true, 					false, 			false,	_, _, 		10);
	CreateGameMode("Pandemia", 			true, 	false, 		true, 	true, 					false, 			false,	_, _, 		10);
	CreateGameMode("MEOOOOOOW!", 		true, 	false, 		true, 	true, 					false, 		 	false,	_, _, 		10);
	
	// Update probabilities according to gamemodes count
	SetProbabilities();
}

/**
 * Listener command callback (mp_warmup_start)
 * @brief Blocks the warmup period.
 *
 * @param entity            The entity index. (Client, or 0 for server)
 * @param commandMsg        Command name, lower case. To get name as typed, use GetCmdArg() and specify argument 0.
 * @param iArguments        Argument count.
 **/
public Action GameModesOnCommandListened(int entity, char[] commandMsg, int iArguments){
	
	// Validate server
	if (!entity){
		
		// Block warmup
		GameRules_SetProp("m_bWarmupPeriod", false); 
		GameRules_SetPropFloat("m_fWarmupPeriodStart", 0.0);
	}
	
	// Block commands
	return Plugin_Handled;
}

/**
 * Event callback (cs_win_panel_round)
 * @brief The win panel was been created.
 * 
 * @param gEventHook        The event handle.
 * @param gEventName        The name of the event.
 * @param dontBroadcast     If true, event is broadcasted to all clients, false if not.
 **/
public Action GameModesOnPanel(Event hEvent, char[] sName, bool dontBroadcast){
	
	// Sets whether an event broadcasting will be disabled
	if (!dontBroadcast){
		
		// Disable broadcasting
		hEvent.BroadcastDisabled = true;
	}
}

/**
 * Event callback (round_prestart)
 * @brief The round is starting.
 * 
 * @param gEventHook        The event handle.
 * @param gEventName        The name of the event.
 * @param dontBroadcast     If true, event is broadcasted to all clients, false if not.
 **/
public Action GameModesOnStartPre(Event hEvent, char[] sName, bool dontBroadcast){
	
	// If warmup didn't start yet
	if (!bWarmupEnded){
		if (bWarmupStarted){
			WarmupTurnIntoRandomAll();
		}
		else{
			StartMode(view_as<int>(MODE_WARMUP));
		}
	}
	else{
		// Resets server global variables
		gServerData.RoundNew   = true;
		gServerData.RoundEnd   = false;
		gServerData.RoundStart = false;
		
		// Update server grobal variables
		gServerData.RoundMode  = view_as<int>(NO_MODE);
		gServerData.RoundNumber++;
		
		PrintToServer("Ronda %d", gServerData.RoundNumber);
		//gServerData.RoundCount = gCvarList.GAMEMODE.IntValue;
		gServerData.RoundCount = ROUND_START_COUNTDOWN;
		
		// Send t-virus message
		CreateTimer(1.0, TVirusReleasedTimer, _, TIMER_FLAG_NO_MAPCHANGE);
		
		// Start timer's counter
		delete gServerData.TVirusReleasedTimer;
		gServerData.TVirusReleasedTimer = CreateTimer(3.5, CounterOnGameModesStartPre, _,  TIMER_FLAG_NO_MAPCHANGE);
		
		// Clear server sounds
		/*delete gServerData.EndTimer;
		delete gServerData.BlastTimer;*/
	}
}

//=====================================================
//					COUNTER
//=====================================================
public Action TVirusReleasedTimer(Handle timer){
	
	// Send t-virus message
	TranslationPrintHudTextAll(gServerData.GameSync, -1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, 0, 45, 255, 255, 1, 1.0, 1.0, 1.0, "T Virus has been released");
}

public Action CounterOnGameModesStartPre(Handle timer){
	
	// Clear server counter
	delete gServerData.CounterTimer;
	if (gServerData.RoundCount){
		
		// Creates timer for starting gamemodes
		gServerData.CounterTimer = CreateTimer(1.0, GameModesOnCounter, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
	
	gServerData.TVirusReleasedTimer = null;
	return Plugin_Stop;
}

public Action GameModesOnCounter(Handle timer){
	
	// When counter is active
	if(gServerData.RoundCount){
		
		TranslationPrintHudTextAll(gServerData.GameSync, -1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, 20, 20, 200, 255, 1, 1.0, 1.0, 1.0, "Threat in seconds", gServerData.RoundCount);
		
		if(gServerData.RoundCount <= 10 && gServerData.RoundCount > 0) {
			char buf[128];
			FormatEx(buf, sizeof(buf), "*/MassiveInfection/round/%d.mp3", gServerData.RoundCount);
			EmitSoundToAll(buf, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
		}
	}
	else{
		// When counter finishes
		gServerData.CounterTimer = null;
		StartMode(CalculateModeByChances());
		return Plugin_Stop;
	}
	
	gServerData.RoundCount--;
	return Plugin_Continue;
}

/**
 * Event callback (round_start)
 * @brief The round is start.
 * 
 * @param gEventHook        The event handle.
 * @param gEventName        The name of the event.
 * @param dontBroadcast     If true, event is broadcasted to all clients, false if not.
 **/
public Action GameModesOnStart(Event hEvent, char[] sName, bool dontBroadcast){
	
	// Remove func entities
	ModesKillEntities();
	
	// Forward event to modules
	//SoundsOnRoundStart();
}

/*
 * Game modes main functions.
 */

/**
 * @brief Kills all objective entities.
 * 
 * @param bDrop             (Optional) If true will removed dropped entities, false all 'func_' entities.
 **/
void ModesKillEntities(bool bDrop = false){
	
	// Initialize name char
	static char sClassname[NORMAL_LINE_LENGTH];

	// Is removal mode of dropped ents ?
	if (bDrop)
	{
		// If removing is disabled, then stop
		/*if (!gCvarList.GAMEMODE_WEAPONS_REMOVE.BoolValue)
		{
			return;
		}*/
  
		// i = entity index
		int MaxEntities = GetMaxEntities();
		for (int i = MaxClients; i <= MaxEntities; i++)
		{
			// Validate entity
			if (IsValidEdict(i))
			{
				// Gets valid edict classname
				GetEdictClassname(i, sClassname, sizeof(sClassname));

				// Validate weapon
				if (sClassname[0] == 'w' && sClassname[1] == 'e' && sClassname[6] == '_')
				{
					// Gets weapon owner
					int client = WeaponsGetOwner(i);
					
					// Validate owner
					if (!IsPlayerExist(client))
					{
						// Validate non map weapons, then remove
						if (!WeaponsGetMap(i))
						{
							AcceptEntityInput(i, "Kill"); /// Destroy
						}
					}
				}
			}
		}
	}
	else
	{
		// i = entity index
		int MaxEntities = GetMaxEntities();
		for (int i = MaxClients; i <= MaxEntities; i++)
		{
			// Validate entity
			if (IsValidEdict(i))
			{
				// Gets valid edict classname
				GetEdictClassname(i, sClassname, sizeof(sClassname));

				// Validate objectives
				if ((sClassname[0] == 'h' && sClassname[7] == '_' && sClassname[8] == 'e') || // hostage_entity
				   (sClassname[0] == 'f' && // func_
				   (sClassname[5] == 'h' || // _hostage_rescue
				   (sClassname[5] == 'b' && (sClassname[7] == 'y' || sClassname[7] == 'm'))))) // _buyzone , _bomb_target
				{
					AcceptEntityInput(i, "Kill"); /// Destroy
				}
				// Validate weapon
				else if (sClassname[0] == 'w' && sClassname[1] == 'e' && sClassname[6] == '_')
				{
					// Gets weapon owner
					int client = WeaponsGetOwner(i);
					
					// Validate owner
					if (!IsPlayerExist(client))
					{
						// Validate spawn, if allowed sets custom properties, otherwise remove
						/*if (!WeaponsValidateByMap(i, sClassname))
						{*/
							AcceptEntityInput(i, "Kill"); /// Destroy
						//}
					}
				}
			}
		}
	}
}

/**
 * @brief Gamemodes module purge function.
 **/
void GameModesOnPurge(/*void*/){
	
	// Purge server timers
	gServerData.PurgeTimers();
}