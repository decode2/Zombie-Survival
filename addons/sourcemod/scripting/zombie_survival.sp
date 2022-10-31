// Extension
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <entity>
#include <dhooks>

// Helper
#include <utils>
#include <mapchooser>
#pragma semicolon 1
#pragma newdecls required

#define DEBUG

#define MAXCHARACTERS_LEGACY 5
#define MAXCHARACTERS_NEW 1

#define SERVERSTRING "\x01 \x04[ZS]\x01"

// Own includes
#include <main>

// Main
#include "zs/global.sp"
#include "zs/versioninfo.sp"

// Core
#include "zs/core/paramparser.sp"
#include "zs/core/config.sp"
#include "zs/core/commands.sp"
#include "zs/core/translations.sp"
#include "zs/core/database.sp"
#include "zs/core/zombieplague.sp"

// Manager
#include "zs/manager/tiers.sp"
#include "zs/manager/zgamemodes.sp"
#include "zs/manager/bosses.sp"
#include "zs/manager/upgrades.sp"
#include "zs/manager/goldenupgrades.sp"
#include "zs/manager/ranktags.sp"
#include "zs/manager/hats.sp"
#include "zs/manager/tags.sp"
#include "zs/manager/vips.sp"
#include "zs/manager/zweapons.sp"
#include "zs/manager/zgrenades.sp"
#include "zs/manager/happyhours.sp"
#include "zs/manager/combos.sp"
//#include "zp/manager/sounds.sp"

#include "zs/manager/extraitems.sp"
#include "zs/manager/resets.sp"
#include "zs/manager/zplayer.sp"
#include "zs/manager/player/death.sp"
#include "zs/manager/lasermines.sp"
#include "zs/manager/weapons.sp"
#include "zs/core/db_accounts.sp"
#include "zs/manager/party.sp"
#include "zs/manager/menus.sp"

#include "zs/manager/player/antistick.sp"
#include "zs/manager/player/spawn.sp"

#include <global>
#include <mercenary>

#define DISCORD_LINK_PIU "your-discord-here"
#define WHATSAPP_LINK_PIU "your-whatsapp-group-link-here"
#define INSTAGRAM_LINK_PIU "your-instagram-here"

// Each time a human deals X dmg, gets Y AP
#define DAMAGE_DEALT_DAMAGE_REQUIRED_TO_EARN_AP 5000
#define DAMAGE_DEALT_AP_PER_DAMAGE_DEALT 		5

// Sniper lightning effect
#define TASER "weapon_tracers_taser"
#define GLOW "weapon_taser_glow_impact"
#define SOUND_IMPACT "weapons/taser/taser_hit.wav"
#define SOUND_SHOOT "weapons/taser/taser_shoot.wav"
float g_fLastAngles[MAXPLAYERS+1][3];

// ASDASSDADSADSADSASDDSDAS
int decalSmoke;
int decalBloodDecal;

// Map selector
#define ROUNDS_TO_END_MAP 	15

// Fog
int iFog = -1;
float mapFogStart = 0.0;
float mapFogEnd = 1800.0;
float mapFogDensity = 0.90;

ArrayList Players;

Handle hSetModel;

int Collision_Offsets;

public Plugin myinfo ={
	
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

public void OnPluginStart(){
	
	CreateConVar("zs_version", PLUGIN_VERSION, "Standard plugin version ConVar. Please don't change it!", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	// MOVER A ZPLAYER ON INIT (CLASSES ON INIT EN REALIDAD)
	ToolsOnCvarInit();
	
	Players = CreateArray(2);
	
	// Accounts arrays
	users = CreateArray(ByteCountToCells(32), MAXPLAYERS+1);
	passwords = CreateArray(ByteCountToCells(32), MAXPLAYERS+1);
	characterNames = CreateArray(ByteCountToCells(32), MAXPLAYERS+1);
	
	//=====================================================
	//		INIT MODULES' ARRAYS & STORE ITS DATA
	//=====================================================
	// Translations
	TranslationOnInit();
	ConfigOnInit();
	CommandsOnInit();
	GameEngineOnInit();
	ZPlayerOnInit();
	DeathOnInit();
	
	// Init database
	DataBaseOnInit();
	
	// Init hats
	HatsOnInit();
	
	// Init tags
	TagsOnInit();
	
	// Init hclasses
	HClassesOnInit();
	
	// Init zclasses
	ZClassesOnInit();
	
	// Spawn detection and storing (NEED TO CALL THIS BEFORE ANTISTICK MODULE!!!)
	Spawn_OnPluginStart();
	// Antistick - uses spawn include info (that's why we first start spawn module)
	AntiStick_OnPluginStart();
	
	// Weapons
	WeaponsOnPluginStart();
	
	// Grenades
	ZGrenades_OnPluginStart();
	
	// HAligments
	HAlignments_OnPluginStart();
	
	// ZAligments
	ZAlignments_OnPluginStart();
	
	// Bosses
	Bosses_OnPluginStart();
	
	// Gamemodes
	GameModesOnInit();
	
	// Combos
	CombosOnInit();
	
	// ExtraItems
	ExtraItems_OnPluginStart();
	
	// VIPs
	Vips_OnPluginStart();
	
	// Party
	PartyOnInit();
	
	// Antiretry
	AntiRetry_OnPluginStart();
	
	// Unstuck
	//Unstuck_OnPluginStart();
	
	// Golden Upgrades
	GoldenUpgrades_OnPluginStart();
	
	// Lasermines
	Lasermines_OnPluginStart();
	
	// Rank tags
	RankTags_OnPluginStart();
	
	MercenaryOnInit();
	
	// Create hud synchronizers
	hHudSynchronizer = CreateHudSynchronizer();
	
	// Init weapons SDK calls
	WeaponSDKOnInit();
	
	Collision_Offsets = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	g_iToolsRagdoll = FindSendPropInfo("CCSPlayer", "m_hRagdoll");
	
	for (int i = 1; i <= MaxClients; i++){
		charactersNames[i] = CreateArray(6, MAXCHARACTERS_LEGACY);
		charactersLevels[i] = CreateArray(3, MAXCHARACTERS_LEGACY);
		charactersResets[i] = CreateArray(3, MAXCHARACTERS_LEGACY);
		charactersAccessLevels[i] = CreateArray(3, MAXCHARACTERS_LEGACY);
	}
	
	Handle hGameConf;
	hGameConf = LoadGameConfigFile("sdktools.games");
	
	if(hGameConf == INVALID_HANDLE)
		SetFailState("Gamedata file sdktools.games.txt is missing.");

	int iOffset = GameConfGetOffset(hGameConf, "SetEntityModel");
	delete hGameConf;
	
	if(iOffset == -1)
		SetFailState("Gamedata is missing the \"SetEntityModel\" offset.");
	
	hSetModel = DHookCreate(iOffset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, SetModel);
	DHookAddParam(hSetModel, HookParamType_CharPtr);
	
	// Events on plugin init
	EventsOnInit();
	
	AddCommandListener(TeamMenuCmd, "teammenu");
	
	// User commands //
	
	// Help
	RegConsoleCmd("ayuda", infoCommands);
	RegConsoleCmd("help", infoCommands);
	
	// NVG & flashlight
	RegConsoleCmd("flashlight", flashLight);
	RegConsoleCmd("nightvision", nightVision);
	
	// Mode info
	RegConsoleCmd("modo", infoMode);
	RegConsoleCmd("mode", infoMode);
	
	// Mute bullets
	RegConsoleCmd("mutebullets", muteBullets);
	
	// Vip info
	RegConsoleCmd("vip", infoVip);
	RegConsoleCmd("vencimiento", getVencimientoTime);
	
	// Vip test
	RegConsoleCmd("pruebavip", showPruebaVipMenu);
	RegConsoleCmd("testvip", showPruebaVipMenu);
	
	// Top info
	RegConsoleCmd("top", GetTop50);
	
	// Rules
	RegConsoleCmd("reglas", infoRules);
	
	// Discord link
	RegConsoleCmd("discord", infoDiscord);
	RegConsoleCmd("ds", infoDiscord);
	RegConsoleCmd("disc", infoDiscord);
	
	// Whatsapp link
	RegConsoleCmd("wsp", infoWhatsapp);
	RegConsoleCmd("whatsapp", infoWhatsapp);
	
	// Instagram link
	RegConsoleCmd("ig", infoInstagram);
	RegConsoleCmd("instagram", infoInstagram);
	RegConsoleCmd("insta", infoInstagram);
	
	// Admin list
	RegConsoleCmd("admins", showAdminList);
	RegConsoleCmd("mods", showAdminList);
	
	// Refeer code
	//RegConsoleCmd("testRCode", associateRefeerCode);
	
	// Extra items binds
	RegConsoleCmd("item1", buyItems);
	RegConsoleCmd("item2", buyItems);
	RegConsoleCmd("item3", buyItems);
	RegConsoleCmd("item4", buyItems);
	RegConsoleCmd("item5", buyItems);
	
	// AFK
	//RegConsoleCmd("afk", commandAfk);

	// Promo codes
	RegConsoleCmd("piu_code", commandPromoCode);
	RegConsoleCmd("zs_code", commandPromoCode);
	RegConsoleCmd("code", commandPromoCode);
	
	RegAdminCmd("dropchest", ForceDropChest, ADMFLAG_ROOT);
	//RegAdminCmd("givemepiupoints", givemepoints, ADMFLAG_ROOT);
	//RegConsoleCmd("aura", givemeaura);
	
	//RegConsoleCmd("saveme", saveme);
	
	// Server cmds
	RegServerCmd("getTime", time);
	RegServerCmd("give_zpoints", givezpoints);
	RegServerCmd("give_hpoints", givehpoints);
	RegServerCmd("make_player", makePlayer);
	RegServerCmd("give_exp", givexp);
	RegServerCmd("adminto", adminMe);
	RegConsoleCmd("saveAll", saveAllcmd);
	RegServerCmd("serverSaveAll", serverDataBaseOnSaveAllDatacmd);
	
		// Mod cmds
	RegAdminCmd("mi_removelasermines", AimRemoveLasermines, ADMFLAG_CHANGEMAP, "Remueve las lasermines de un usuario");
	RegAdminCmd("mi_aimremovelasermine", AimRemoveLasermine, ADMFLAG_CHANGEMAP, "Remueve lasermines apuntandoles");
	RegAdminCmd("respawn", makeAlive, ADMFLAG_CHANGEMAP, "Revive un usuario muerto");
	
	// Staff cmds
	RegAdminCmd("makemezombie", makemeZombie, ADMFLAG_ROOT);
	RegAdminCmd("meow", meow, ADMFLAG_ROOT);
	RegAdminCmd("makemenemesis", makemeNemesis, ADMFLAG_ROOT);
	RegAdminCmd("makemehuman", makemeHuman, ADMFLAG_ROOT);
	RegAdminCmd("makemesurvivor", makemeSurvivor, ADMFLAG_ROOT);
	RegAdminCmd("makemesupersurvivor", makemeSuperSurvivor, ADMFLAG_ROOT);
	RegAdminCmd("makemegunslinger", makemeGunslinger, ADMFLAG_ROOT);
	RegAdminCmd("makemesniper", makemeSniper, ADMFLAG_ROOT);
	RegAdminCmd("makemeassassin", makemeAssassin, ADMFLAG_ROOT);
//	RegAdminCmd("makemefev", makemeFev, ADMFLAG_ROOT);
	RegAdminCmd("givemenades", givemenades, ADMFLAG_ROOT);
	RegAdminCmd("aiminfect", AimInfect, ADMFLAG_ROOT);
	RegAdminCmd("aimhumanize", AimHumanize, ADMFLAG_ROOT);
	RegAdminCmd("lightlevel", lightLevel, ADMFLAG_ROOT);
	RegAdminCmd("fog", valveFog, ADMFLAG_ROOT);
	RegAdminCmd("lightsoff", lightSwitch, ADMFLAG_ROOT);
	RegAdminCmd("zpoints", staffzpoints, ADMFLAG_ROOT);
	RegAdminCmd("hpoints", staffhpoints, ADMFLAG_ROOT);
	RegAdminCmd("make", staffmake, ADMFLAG_ROOT);
	RegAdminCmd("exp", staffexp, ADMFLAG_ROOT);
	RegAdminCmd("banchat", staffbanchat, ADMFLAG_ROOT);
	RegAdminCmd("banchatvoice", staffbanchatvoice, ADMFLAG_ROOT);
	RegAdminCmd("allowParty", setAllowParty, ADMFLAG_ROOT);
	RegAdminCmd("test", VAmbienceTest, ADMFLAG_ROOT);
	RegAdminCmd("reloadhat", reloadhat, ADMFLAG_ROOT);
	RegAdminCmd("vfx", testEffects, ADMFLAG_ROOT);
	RegAdminCmd("zm_lvl", stafflvl, ADMFLAG_ROOT);
	RegAdminCmd("givemeweapon", givemeWeapon, ADMFLAG_ROOT);
	RegAdminCmd("endwarmup", FinishWarmup, ADMFLAG_ROOT);
	
	RegAdminCmd("poison", cmdPoisonThrow, ADMFLAG_ROOT);
	
	// Hook command to prevent data loss
	RegAdminCmd("sm_map", Command_Map, ADMFLAG_CHANGEMAP, "sm_map <map>");
	
	RegAdminCmd("asd", asd, ADMFLAG_ROOT);
	RegAdminCmd("debug", infServerNow, ADMFLAG_CHANGEMAP, "all|basic|gamemodes|players|zclasses|hclasses|pweapons|sweapons|gpacks|hats|tags|lasermines");
	
	AddNormalSoundHook(NormalSHook);
	
	//RegConsoleCmd("resetpoints", rpoints);
}
public void OnPluginEnd(){
	
	ZPlayerOnUnload();
	
	// Delete hud synchronizers
	delete hComboSynchronizer;
	delete hComboSynchronizer2;
	delete hHudSynchronizer;
	delete gServerData.GameSync;
	
	// Execute a module data cleanse
	// Database
	DataBaseOnPluginEnd();
	
	// Hats
	HatsOnPluginEnd();
	
	// Tags
	TagsOnPluginEnd();
	
	// HClasses
	HClassesOnPluginEnd();
	
	// ZClasses
	ZClassesOnPluginEnd();
	
	// Weapons
	WeaponsOnPluginEnd();
	
	// Grenades
	ZGrenades_OnPluginEnd();
	
	// Combos
	CombosOnPluginEnd();
	
	// HAlignments
	HAlignments_OnPluginEnd();
	
	// ZAlignments
	ZAlignments_OnPluginEnd();
	
	// Bosses
	Bosses_OnPluginEnd();
	
	// Party
	Party_OnPluginEnd();
	
	//ExtraItems
	ExtraItems_OnPluginEnd();
	
	// VIPs
	Vips_OnPluginEnd();
	
	// Gamemodes
	Gamemodes_OnPluginEnd();
	
	// AntiRetry
	AntiRetry_OnPluginEnd();
	
	// Golden upgrades
	GoldenUpgrades_OnPluginEnd();
	
	// Lasermines
	Lasermines_OnPluginEnd();
	
	// Rank tags
	RankTags_OnPluginEnd();
}

public Action CP_OnChatMessage(int& author, ArrayList recipients, char[] flagstring, char[] name, char[] message, bool& processcolors, bool& removecolors){
	
	ZPlayer player = ZPlayer(author);
	if (player.bStaff){
		Format(name, 128, "{darkred}[STAFF] %s (TIER %d | Lv. %d){default}", name, player.iTier, player.iLevel);
	}
	else if (player.bAdmin){
		Format(name, 128, "{orchid}[MOD] %s (TIER %d | Lv. %d){default}", name, player.iTier, player.iLevel);
	}
	else if (player.bVip){
		Format(name, 128, "{lime}%s (TIER %d | Lv. %d){default}", name, player.iTier, player.iLevel);
	}
	else{
		Format(name, 96, "%s (TIER %d | Lv. %d)", name, player.iTier, player.iLevel);
	}
	
	//Format(message, 256, "{blue}%s", message);
	return Plugin_Changed;
}


// Player reset
public void resetear(int client){
	
	if (!IsPlayerExist(client)) return;
	
	if (!playerCheckCanReset(client)) return;
	
	// Clear igniter id so he won't obtain any remaining profit from igniting
	for (int i = 1; i <= MaxClients; i++){
		if (gClientData[i].iIgniterId == client){
			gClientData[i].iIgniterId = -1;
		}
	}
	
	// End any active combo
	SafeEndPlayerCombo(client);
	
	if (gClientData[client].bInParty){
		
		int ptId = findPartyByUID(gClientData[client].iPartyUID);
		
		if (ptId != -1){
			ZParty pt = ZParty(ptId);
			SafeEndComboParty(pt.id);
		}
	}
	
	ZPlayer p = ZPlayer(client);
	
	// Remove weapons
	p.removeWeapons();
	
	if (IsPlayerAlive(p.id)) ForcePlayerSuicide(p.id);
	
	// Restart user values
	p.iLevel = 1;
	p.iExp = 1;
	
	p.iSelectedPrimaryWeapon = 8; // 8 is the index of the first PRIMARY WEAPON
	p.iSelectedSecondaryWeapon = 0;
	p.iPrimaryWeapon = 0;
	p.iSecondaryWeapon = 0;
	p.iNextPrimaryWeapon = 8; // 8 is the index of the first PRIMARY WEAPON
	p.iNextSecondaryWeapon = 0;
	p.iGrenadePack = 0;
	p.iNextGrenadePack = 0;	
	
	p.iZombieClass = 0;
	p.iHumanClass = 0;
	p.iNextHumanClass = 0;
	p.iNextZombieClass = 0;
	
	p.iCombo = 1;
	p.bInfiniteAmmo = false;
	
	p.bAutoWeaponUpgrade = true;
	TranslationPrintToChat(p.id, "Weapon auto upgrade enabled");
	
	p.bAutoGrenadeUpgrade = true;
	TranslationPrintToChat(p.id, "Grenade pack auto upgrade enabled");
	
	p.bAutoZClass = true;
	
	p.checkAutoUpgrade(false);
	
	// Print some motivation bullshit
	TranslationPrintToChat(p.id, p.iReset ? "Common reset" : "First reset");
	TranslationPrintToChat(p.id, "Common reset bonus 1");
	TranslationPrintToChat(p.id, "Common reset bonus 2");
	
	int newRank = RankTags_FindForReset(p.iReset+1);
	if (newRank > p.iRankTag){
		RankTag rank;
		RankTags.GetArray(newRank, rank);
		PrintToChatAll("%s \x03%N\x01 ha desbloqueado el rango \x08%s\x01 con su reset \x04%d\x01!", SERVERSTRING, p.id, rank.name, p.iReset+1);
	}
	
	int newHat = Hats_FindForReset(p.iReset+1);
	if (newHat > p.iHat){
		Hat hat;
		Hats.GetArray(newHat, hat);
		PrintToChatAll("%s \x03%N\x01 ha desbloqueado el hat \x08%s\x01 con su reset \x04%d\x01!", SERVERSTRING, p.id, hat.name, p.iReset+1);
	}
	
	
	/*if (gClientData[client].iReset >= RESET_AMMOUNT_TO_START_PAYING_POINTS){
		gClientData[client].iHPoints -= RESET_POINTS_AMMOUNT_TO_PAY_FEE;
		gClientData[client].iZPoints -= RESET_POINTS_AMMOUNT_TO_PAY_FEE;
	}*/
	
	// Take payment
	int feeAmmount = resetsCalculateFeeByResets(gClientData[client].iReset);
	gClientData[client].iHPoints -= feeAmmount;
	gClientData[client].iZPoints -= feeAmmount;
	
	// Give the rewards
	p.iReset++;
	p.iHGoldenPoints++;
	p.iZGoldenPoints++;
	
	// Update rank tag & tier
	p.updateTag();
	int currentTier = p.iTier;
	if (currentTier < tiersFindTierForReset(gClientData[client].iReset)){
		tiersOnPlayerUpdateTier(client);
		PrintToChatAll("%s \x03%N\x01 ha ascendido a \x08TIER %d\x01 con su reset \x04%d\x01!", SERVERSTRING, p.id, p.iTier, p.iReset);
	}
	
	
	/*
	#if defined RESET_POINTS_BONUS_AMOUNT
	TranslationPrintToChat(p.id, "Common reset bonus 2", RESET_POINTS_BONUS_AMOUNT);
	p.iHPoints += RESET_POINTS_BONUS_AMOUNT;
	p.iZPoints += RESET_POINTS_BONUS_AMOUNT;
	#endif*/
	
	LogToFile("addons/sourcemod/logs/RESET_HISTORIC.txt", "%N reseteado: actual %d RR, GoldenH %d, GoldenZ %d, HPoints %d, ZPoints %d", p.id, p.iReset, p.iHGoldenPoints, p.iZGoldenPoints, p.iHPoints, p.iZPoints);
	
	// Respawn the guy
	if (ActualMode.bRespawn)
		p.iRespawnPlayer(ActualMode.bRespawnZombieOnly);
}
/*
public void CP_OnChatMessagePost(int author, ArrayList recipients, const char[] flagstring, const char[] formatstring, const char[] name, const char[] message, bool processcolors, bool removecolors)
{
	PrintToServer("[TEST] %s: %s [%b/%b]", name, message, bProcessColors, bRemoveColors);
}*/

public void MoveToSpectator(any client){
	
	if (!IsPlayerExist(client))
		return;
	
	ChangeClientTeam(client, CS_TEAM_SPECTATOR);
	showMainMenu(client, 0);
	hideHUD(client);
}

// Dispatch map variables
public void DispatchFog(){
	int ent; 
	ent = FindEntityByClassname(-1, "env_fog_controller");
	if (ent != -1) 
		iFog = ent;
	else{
		iFog = CreateEntityByName("env_fog_controller");
		DispatchSpawn(iFog);
	}
	CreateFog();
	AcceptEntityInput(iFog, "TurnOff");
}
public void CreateFog(){
	if(iFog != -1) {
		DispatchFogValues(mapFogEnd, mapFogDensity);
	}
}
void DispatchFogValues(float fogEnd, float fogDensity){
	
	DispatchKeyValue(iFog, "fogblend", "0");
	DispatchKeyValue(iFog, "fogcolor", "0 0 0");
	DispatchKeyValue(iFog, "fogcolor2", "0 0 0");
	DispatchKeyValueFloat(iFog, "fogstart", mapFogStart);
	DispatchKeyValueFloat(iFog, "fogend", fogEnd);
	DispatchKeyValueFloat(iFog, "fogmaxdensity", fogDensity);
}

//=====================================================
//				KEYVALUES
//=====================================================

// Adjust lightlevel and skyname for each map
public void LoadKvMapConfig(){
	KeyValues MyKv = CreateKeyValues("lighting");
	
	// Read file if it exist
	if (!MyKv.ImportFromFile("mapconfigs.txt")){
		PrintToServer("[MAPCONFIG] No mapconfigs file, applying default darkness");
		
		// Apply ambience effects
		VAmbienceApplySunDisable();
		VAmbienceApplyLightStyle();
		SetLightStyle(0, "c");
		
		delete MyKv;
		return;
	}
	
	// Parse mapname
	char sMapname[PLATFORM_MAX_PATH];
	GetCurrentMap(sMapname, sizeof(sMapname));
	
	// No data for this map
	if(!MyKv.JumpToKey(sMapname, false)){
		PrintToServer("[MAPCONFIG] No records in \"%s\" section, creating default keyvalues", sMapname);
		SaveKvMapConfig();
		delete MyKv;
		return;
	}
	
	char sDefault[6];
	MyKv.GetString("default", sDefault, sizeof(sDefault), "no");
	
	if (StrEqual(sDefault, "yes")){
		PrintToServer("[MAPCONFIG] Map config is entirely default, guachin");
		delete MyKv;
		return;
	}
	
	// Parse lightlevel
	char sLightLevel[64];
	MyKv.GetString("lightlevel", sLightLevel, sizeof(sLightLevel), "c");
	
	// Parse skyname
	char sSkyname[32];
	MyKv.GetString("skyname", sSkyname, sizeof(sSkyname), "default"); // sky_csgo_night02b
	
	/********************************************
	/			ENABLE AMBIENTAL EFFECTS
	*********************************************/
	
	// Apply ambience effects
	VAmbienceApplySunDisable();
	VAmbienceApplyLightStyle();
	
	
	// Now apply lightlevel & sky
	if (!StrEqual(sSkyname, "") && !StrEqual(sSkyname, "default")){
		ConVar cvar = FindConVar("sv_skyname");
		cvar.SetString(sSkyname, true);
	}
	
	if (!StrEqual(sLightLevel, "") && !StrEqual(sLightLevel, "default"))
	SetLightStyle(0, sLightLevel);
	
	PrintToServer("[MAPCONFIG] Map %s adjusted to %s lightlevel and %s skyname", sMapname, StrEqual(sLightLevel, "") ? "default" : sLightLevel, StrEqual(sSkyname, "") ? "default" : sSkyname);
	
	//bMapConfigLoaded = true;
	MyKv.GoBack();
	delete MyKv;
}

// Save data in kv file
void SaveKvMapConfig(){
	KeyValues MyKv = CreateKeyValues("lighting");
	
	// Read file if it exist
	if (!MyKv.ImportFromFile("mapconfigs.txt")){
		PrintToServer("[MAPCONFIG] No mapconfigs file");
		delete MyKv;
	}
	
	// Parse mapname
	char sMapname[PLATFORM_MAX_PATH];
	GetCurrentMap(sMapname, sizeof(sMapname));
	
	// No data for this map
	MyKv.JumpToKey(sMapname, true);
	
	// Create keyvalues
	PrintToServer("[MAPCONFIG] No records in \"%s\" section, creating default keyvalues", sMapname);
	MyKv.SetString("default", "no");
	MyKv.SetString("lightlevel", "b");
	MyKv.SetString("skyname", "default");
	MyKv.Rewind();
	MyKv.ExportToFile("mapconfigs.txt");
	delete MyKv;
	
	LoadKvMapConfig();
}

//=====================================================
//				NATIVE FORWARDS
//=====================================================

// Map start
public void OnMapStart(){
	
	ServerCommand("mp_do_warmup_period 0");
	
	CreateTimer(5.0, Timer_CheckIfBotsStuck, INVALID_HANDLE, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	for (int i = 1; i <= MAXPLAYERS; i++){
		users.SetString(i, "");
		passwords.SetString(i, "");
		characterNames.SetString(i, "");
		
		gClientData[i].iTimesAFKed = 0;
	}
	
	// Adjust map lighting level
	LoadKvMapConfig();
	
	// Create fog entity so we can turn it on or off
	DispatchFog();
	//switchFog(true);
	
	// Antistick
	Spawn_OnMapStart();
	AntiStick_OnMapStart();
	
	// Anti retry
	AntiRetry_OnMapStart();
	
	// Rank tags
	RankTags_OnMapStart();
	
	// Reset important variables
	ResetVars();
	
	PrecacheModel(LASERMINE_MODEL_BEAM, true);
	
	BeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	GlowSprite = PrecacheModel("materials/sprites/blueglow1.vmt");
	g_halosprite = PrecacheModel("materials/sprites/halo01.vmt");
	
	PrecacheModel("materials/overlays/friends2.vmt");
	
	// Sniper lightning effect
	PrecacheEffect("ParticleEffect");
	
	// Sniper lightning effect particles precache
	PrecacheParticleEffect(TASER);
	PrecacheParticleEffect(GLOW);
	
	// ZGrenades
	ZGrenades_OnMapStart();
	
	// ZWeapons
	ZWeapons_OnMapStart();
	
	//PrecacheSound(SOUND_IMPACT);
	//PrecacheSound(SOUND_SHOOT);
	
	////////////////////////////////////////////////
	// Precache smoke model
	decalSmoke = PrecacheModel("sprites/steam1.vmt");
	// Precache blood decals
	decalBloodDecal = PrecacheDecal("decals/bloodstain_001.vtf");
	////////////////////////////////////////////////
	
	//PrecacheSound(SOUND_FREEZE);
	////PrecacheSound(SOUND_FREEZE_EXPLODE);	
	
	ConVar cvar;
	cvar = FindConVar("mp_do_warmup_period");
	cvar.IntValue = 0;
	
	cvar = FindConVar("mp_warmuptime");
	cvar.IntValue = 0;
	
	cvar = FindConVar("sv_hibernate_when_empty");
	cvar.IntValue = 0;
	
	cvar = FindConVar("host_players_show");
	cvar.IntValue = 2;
	
	cvar = FindConVar("host_info_show");
	cvar.IntValue = 2;
	
	cvar = FindConVar("mp_drop_grenade_enable");
	cvar.IntValue = 0;
	
	cvar = FindConVar("sv_hibernate_when_empty");
	cvar.IntValue = 0;
	
	cvar = FindConVar("sv_hibernate_postgame_delay");
	cvar.IntValue = 999999;
	
	delete cvar;
	
	ConfigOnLoad();
	GameEngineOnLoad();
	
	// Resources
	Resources_OnMapStart();
}

// Map end
public void OnMapEnd(){
	
	DataBaseOnSaveAllData();
	
	ZPlayer player;
	for (int i = 1; i <= MaxClients; i++){
		player = ZPlayer(i);
		
		users.SetString(i, "");
		passwords.SetString(i, "");
		characterNames.SetString(i, "");
		
		if (!player.bLogged) continue;
		
		player.RemoveNightvision();
	}
	
	Players.Clear();
	
	AntiRetry_OnPluginEnd();
	
	// Clear party arrays
	Party_OnMapEnd();
	
	if (hModeStats!= null)
		delete hModeStats;
	
	WeaponsOnMapEnd();
	
	ZPlayerOnPurge();
	GameModesOnPurge();	
	GameEngineOnPurge();
}

// Reset important variables
void ResetVars(){
	
	// Reset important variables
	gServerData.RoundNumber = 0;
	eventmode = false;
	bWarmupStarted = false;
	bWarmupEnded = false;
	iWarmupTime = 0;
	
	// Reset important variables
	hWarmupTimer = null;
	iWarmupTime = 0;
	
	// Clear party arrays
	Party_OnMapEnd();
}

public void FinishCSGOWarmup(){
	if (!bWarmupStarted && !bWarmupEnded){
		
		ServerCommand("mp_warmup_end");
		CS_TerminateRound(0.1, CSRoundEnd_GameStart);
		
		//TranslationPrintToChatAll("Starting match");
		PrintToServer("[INFO] CSGO warmup ended successfully.");
		
		//LogError("[WARMUP] Ha finalizado el warmup de CSGO.");
		if(WARMUP_DURATION > 1.0)
			StartMode(view_as<int>(MODE_WARMUP));
	}
}

public void OnClientPostAdminFilter(int client){
	if(bAllowGain){
		CheckIfRetry(client);
	}
}

// When client enters the server
public void OnClientPutInServer(int client){
	
	MenusOnClientInit(client);
	PartyOnClientInit(client);
	DeathOnClientInit(client);
	
	ZPlayer player = ZPlayer(client);
	player.iTeamNum = 3;
	
	gClientData[client].iTimesAFKed = 0;
	
	users.SetString(client, "");
	passwords.SetString(client, "");
	characterNames.SetString(client, "");
	
	for(int i; i < MAXCHARACTERS_LEGACY; i++){
		player.setSlotEmpty(i, true);
	}
	
	DHookEntity(hSetModel, true, client);
	
	if(IsPlayerExist(client)){
		player.Reset();
		ExtraItems_UpdateFromPersistance(client);
		player.hHudTimer = CreateTimer(0.3, PrintMsg, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
	
	// Hook client events
	SDKHooks_OnClientPutInServer(client);
}

// Initialize client SDK Hooks
void SDKHooks_OnClientPutInServer(int client){
	
	// Initialize clients hooks
	WeaponsOnClientPutInServer(client);
	
	SDKHook(client, SDKHook_PreThink, PreThink);
	SDKHook(client, SDKHook_TraceAttack, OnDamageTraceAttack);
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamage);
}

stock bool IsBurstMode(int iWeapon){
	return view_as<bool>(GetEntProp(iWeapon, Prop_Send, "m_bBurstMode"));
}

//=====================================================
//				HOOK CLIENT CONNECT
//=====================================================
public void OnClientConnected(int client){
	
	// Forward event to modules
	ZPlayerOnClientConnect(client);
}

//=====================================================
//				HOOK CLIENT DISCONNECT
//=====================================================
public void OnClientDisconnect(int client){
	ZPlayer player = ZPlayer(client);
	
	// Remove from party
	leaveParty(client, 0);
	
	// Kill hud timer
	if (player.hHudTimer != null){
		delete player.hHudTimer;
	}

	// Update next weapons & grenades before saving
	player.updateNextWeapons();
	// Update next classes before saving
	player.updateNextClasses();
	// Update next alignments before saving
	player.updateNextAlignments();
	
	// Execute gamemodes stats check
	GamemodeStatsOnPlayerDisconnectPre(client);
	
	// Add to retry list if player not staff
	if(GetValidPlaying() > 1 && !player.bStaff){
		AddToRetrysList(client);
	}
	
	// Persist items by steamid on disconnection
	ExtraItems_PersistOnPlayer(client);
	
	// Remove nvg entity
	player.RemoveNightvision();
	
	// Lasermines
	Lasermines_OnClientDisconnect(client);
	
	// Extinguish entity if it was on fire
	if (IsClientInGame(client))
		ExtinguishEntity(client);
	
	// Unhook damage detection on this entity
	SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnTakeDamage);
	SDKUnhook(client, SDKHook_TraceAttack, OnDamageTraceAttack);
	
	// Unhook prethink
	SDKUnhook(client, SDKHook_PreThink, PreThink);
	
	// Weapons
	WeaponsOnClientDisconnect(client);
}
public void OnClientDisconnect_Post(int client){
	
	ToolsOnClientDisconnectPost(client);
	
	// Save user data
	saveCharacterData(client);
	
	// Log off
	ZPlayer(client).bLoaded = false;
	
	// Remove from players array
	int playerArrayID = Players.FindValue(client);
	if (playerArrayID != -1){
		Players.Erase(playerArrayID);
	}
	
	// Reset cache
	users.SetString(client, "");
	passwords.SetString(client, "");
	characterNames.SetString(client, "");
	
	// Check how many users are playing
	CheckQuantityPlaying();
	
	// End round if needed
	RoundEndOnClientDisconnect();
}
void RoundEndOnClientDisconnect(){
	if (gServerData.RoundNew || gServerData.RoundEnd || !gServerData.RoundStart){
		return;
	}
	
	if (ActualMode.is(MODE_PANDEMIC) || ActualMode.is(MODE_MUTATION))
		return;
	
	// End warmup when people disconnects BUGFIX
	/*if (ActualMode.is(MODE_WARMUP) && fnGetPlaying(true) <= 1){
		FinishWarmup(0, 0);
	}*/
	
	if (!fnGetInTeam(CS_TEAM_CT) && !fnGetInTeam(CS_TEAM_T)){
		return;
	}
	
	int nHumans  = fnGetAliveInTeam(CS_TEAM_CT);
	int nZombies = fnGetAliveInTeam(CS_TEAM_T);
	
	if (!nZombies && nHumans){
		
		int humanId = GetRandomUser(PT_HUMAN);
		
		if (humanId < 1){
				
			return;
		}
		
		ZPlayer player = ZPlayer(humanId);
		
		switch(ActualMode.id){
			case MODE_ANIHHILATION, MODE_INFECTION, MODE_MULTIPLE_INFECTION, MODE_MULTIPLE_NEMESIS:{
				
				player.Zombiefy(true);
				return;
			}
			case MODE_NEMESIS:{
				
				player.TurnInto(PT_NEMESIS, true);
				return;
			}
//			case MODE_FEV:{
//				
//				player.TurnInto(PT_FEV, true);
//				return;
//			}
			case MODE_ASSASSIN:{
				
				player.TurnInto(PT_ASSASSIN, true);
				return;
			}
			default:{
				CS_TerminateRound(3.0, CSRoundEnd_CTWin, false);
				return;
			}
		}
	}
	else if (!nHumans && nZombies){
		
		int zombieId = GetRandomUser(PT_ZOMBIE);
		
		if (zombieId < 1){
				
			return;
		}
		
		ZPlayer player = ZPlayer(zombieId);
		
		switch(ActualMode.id){
			case MODE_SURVIVOR:{
				
				player.TurnInto(PT_SURVIVOR, true);
				return;
			}
			case MODE_SNIPER:{
				
				player.TurnInto(PT_SNIPER, true);
				return;
			}
			case MODE_GUNSLINGER:{
				
				player.TurnInto(PT_GUNSLINGER, true);
				return;
			}
			case MODE_SUPERSURVIVOR:{
				
				player.TurnInto(PT_SUPERSURVIVOR, true);
				return;
			}
			default:{
				CS_TerminateRound(3.0, CSRoundEnd_TerroristWin, false);
				return;
			}
		}
	}
	else if (!nZombies && !nHumans){
		CS_TerminateRound(3.0, CSRoundEnd_TerroristWin, false);
		return;
	}
}

void RoundEndOnClientLogin(){
	
	if (gServerData.RoundEnd)
		return;
	
	int nHumans  = fnGetAliveInTeam(CS_TEAM_CT);
	int nZombies = fnGetAliveInTeam(CS_TEAM_T);
	
	if (!nZombies && !nHumans){
		CS_TerminateRound(1.0, CSRoundEnd_TerroristWin, false);
		return;
	}
}

//=====================================================
//				HOOK CLIENT COMMANDS
//=====================================================

// Hook client commands
public Action OnClientCommand(int client, int args){
	
	if (!IsPlayerExist(client))
		return Plugin_Changed;
	
	ZPlayer player = ZPlayer(client);
	char cmd[16];
	
	GetCmdArg(0, cmd, sizeof(cmd));
	
	if ( StrEqual(cmd, "jointeam") || StrEqual(cmd, "chooseteam")){
		if(player.iTeamNum == CS_TEAM_NONE || player.iTeamNum == CS_TEAM_SPECTATOR){
			showMainMenu(player.id, 0);
		}
		return Plugin_Handled;
	}
	else if(StrEqual(cmd, "buy")){
		PrintHintText(player.id,"You cant buy");
		return Plugin_Handled;
	}
	else if(StrEqual(cmd, "name")) return Plugin_Handled;
	else if(StrEqual(cmd, "kill")) return Plugin_Handled;
	
	return Plugin_Continue;
}
public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs){
	ZPlayer player = ZPlayer(client);
	
	if (!IsPlayerExist(player.id))
		return Plugin_Handled;
	
	if(player.bChatBanned){
		TranslationPrintToChat(client, "Chat banned");
		return Plugin_Handled;
	}
	
	if(player.bInUser){
		static char name[64];
		strcopy(name, sizeof(name), sArgs);
		switch(isValidInput(name, 10, 50)){
			case INPUT_SHORT:{
				TranslationPrintHintText(client, "Register email short");
				showMenuAddOptionalData(client, UserAction_AddEmail, false);
			}
			case INPUT_LARGE:{
				TranslationPrintHintText(client, "Register email long");
				showMenuAddOptionalData(client, UserAction_AddEmail, false);
			}
			case INPUT_INVALID_SIMBOL:{
				TranslationPrintHintText(client, "Register email contains symbols");
				showMenuAddOptionalData(client, UserAction_AddEmail, false);
			}
			case INPUT_INVALID_SPACE:{
				TranslationPrintHintText(client, "Register email contains spaces");
				showMenuAddOptionalData(client, UserAction_AddEmail, false);
			}
			case INPUT_OK: {//makeValidToSQL(name, namev, DATA_NAME);
				users.SetString(client, name);
				
				TranslationPrintHintText(client, "Register email valid", name);
				showMenuAddOptionalData(client, UserAction_AddEmail, true);
			}
		}
		return Plugin_Handled;
	}
	else if(player.bInPassword) {
		static char pass[32];
		strcopy(pass, sizeof(pass), sArgs);
		switch(isValidInput(pass, 5, 16)){
			case INPUT_SHORT:{
				TranslationPrintHintText(client, "Register password short");
				showMenuAddOptionalData(client, UserAction_AddPassword, false);
			}
			case INPUT_LARGE:{
				TranslationPrintHintText(client, "Register password long");
				showMenuAddOptionalData(client, UserAction_AddPassword, false);
			}
			case INPUT_INVALID_SIMBOL:{
				TranslationPrintHintText(client, "Register password contains symbols");
				showMenuAddOptionalData(client, UserAction_AddPassword, false);
			}
			case INPUT_INVALID_SPACE:{
				TranslationPrintHintText(client, "Register password contains spaces");
				showMenuAddOptionalData(client, UserAction_AddPassword, false);
			}
			case INPUT_OK: {
				passwords.SetString(client, pass);
				
				TranslationPrintHintText(client, "Register password valid", pass);
				showMenuAddOptionalData(client, UserAction_AddPassword, true);
			}
		}
		return Plugin_Handled;
	}
	else if(player.bInCreatingCharacter){
		static char name[32];
		strcopy(name, sizeof(name), sArgs);
		switch(isValidInput(name)){
			case INPUT_SHORT:{
				TranslationPrintHintText(client, "Register name short");
				showCrearCharacter(client, false);
			}
			case INPUT_LARGE:{
				TranslationPrintHintText(client, "Register name long");
				showCrearCharacter(client, false);
			}
			case INPUT_INVALID_SIMBOL:{
				TranslationPrintHintText(client, "Register name contains symbols");
				showCrearCharacter(client, false);
			}
			case INPUT_INVALID_SPACE:{
				TranslationPrintHintText(client, "Register name contains spaces");
				showCrearCharacter(client, false);
			}
			case INPUT_OK: {//makeValidToSQL(name, namev, DATA_NAME);
				characterNames.SetString(client, name);
				TranslationPrintHintText(client, "Register name valid", name);
				showCrearCharacter(client, true);
			}
		}
		return Plugin_Handled;
	}
	/*
	if (player.bInTagCreation){
		char sTag[TAGS_MAXLEN];
		char sError[64];
		if (!Tags_isEntryValid(sArgs, sError)){
			TranslationPrintToChat(client, sError);
		}
		else{
			// Aca creamos el tag, lo metemos en el SQL, lo metemos al array de tags y se lo damos al men
			if (player.iPiuPoints < TAGS_PRICE_FOR_CREATING_TAG){
				player.iPiuPoints -= TAGS_PRICE_FOR_CREATING_TAG;
			}
		}
	}*/
	
	// Vip chat
	static char msg[VIP_SAY_MAXLEN];
	strcopy(msg, sizeof(msg), sArgs);
	if (VipChatOnSayCommand(client, msg, sizeof(msg))){
		return Plugin_Handled;
	}
	else if (Party_OnSayCommand(client, msg, sizeof(msg))){
		return Plugin_Handled;
	}
	/*
	char date[16], filename[64], log[256];
	strcopy(log, sizeof(log), sArgs);
	FormatTime(date, sizeof(date), "%d-%m-%y");
	Format(filename, sizeof(filename), "addons/sourcemod/chat-log/log-%s.txt",date);
	
	LogToFile(filename, log);*/
	return Plugin_Continue;
}

//=====================================================
//				VIP CHAT
//=====================================================

stock bool VipChatOnSayCommand(int client, char[] msg, int maxsize){
	
	ZPlayer player = ZPlayer(client);
	
	if(player.bStaff || /*player.bVip ||*/ player.bAdmin){
		
		if(msg[0] == '@' && msg[1] == '@'){
			
			ReplaceStringEx(msg, maxsize, "@", "");
			ReplaceStringEx(msg, maxsize, "@", "");
			ReplaceString(msg, maxsize, "%", "%%");
			
			printVipSay(client, msg, maxsize);
			
			return true;
		}
	}
	
	return false;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon){
	ZPlayer player = ZPlayer(client);
	
	// Crucial condition - disable using bots
	if (!IsPlayerAlive(player.id)){
		buttons &= (~IN_USE);
		return Plugin_Changed;
	}
	
	static int iLastButton;
	iLastButton = buttons;
	
	WeaponsOnRunCmd(client, buttons, iLastButton, player.iActiveWeaponIndex);
	
	// Enable players totem / tower
	int ent = GetEntPropEnt(client, Prop_Send, "m_hGroundEntity");
	if(ent > 0)
		SetEntPropEnt(client, Prop_Send, "m_hGroundEntity", 0);
	
	// BUGFIX: Gravity resetting when touching a ladder
	if (GetEntityMoveType(client) == MOVETYPE_LADDER) 
		player.bLadder = true; 
	else{
		if(player.bLadder){
			player.setGravity();
			player.bLadder = false; 
		} 
	}
	
	// Lasermines check
	if (buttons & IN_DUCK){
		// Cooldown? return
		if (buttons & IN_USE || buttons & IN_RELOAD)
			if (IsOnCooldown(player.id, LASERMINE_PLANT_COOLDOWN))
				return Plugin_Continue;
		
		// Plant with CTRL+E
		if (buttons & IN_USE){
			if (gServerData.RoundNew || !gServerData.RoundStart){
				PrintHintText(client, "Aún no puedes plantar minas");
				return Plugin_Continue;
			}
				
			
			if (player.iTeamNum != CS_TEAM_CT || player.bInLmAction){
				PrintHintText(client, "Debes ser <span style='color:blue;'>HUMANO</span> para plantar minas");
				return Plugin_Continue;
			}
				
			
			if (!player.iLasermines){
				PrintHintText(client, "No tienes lasermines <span style='color:red;'>restantes</span> ");
				return Plugin_Continue;
			}
				
			
			PlantLasermine(GetClientUserId(player.id));
		}
		// Defuse with CTRL+R
		else if (buttons & IN_RELOAD){
			if (player.iTeamNum != CS_TEAM_CT || player.bInLmAction)
				return Plugin_Continue;
			
			DefuseLasermine(GetClientUserId(player.id));
		}
	}
	
	// Detect "USE" in the Mercenary
	MercenaryOnRunCmd(client, buttons);
	
	// If user can leap
	if (player.bCanLeap && gServerData.RoundStart){
		
		// Autobhop
		if (buttons & IN_DUCK && buttons & IN_JUMP){
			if(!(GetEntityMoveType(client) & MOVETYPE_LADDER) && !(GetEntityFlags(client) & FL_ONGROUND)){
				
				if(waterCheck(player.id) < 2)
					buttons &= ~IN_JUMP;
			}
		}
		
		if (buttons & IN_DUCK && buttons & IN_JUMP){
			
			if (GetEntityFlags(client) & FL_ONGROUND){
				
				JumpBoostOnClientLeapJump(client);
			}
			//DoLeap(player.id);
		}
	}
	return Plugin_Continue;
}

stock int waterCheck(int client){
	return GetEntProp(client, Prop_Data, "m_nWaterLevel");
}
/*
void DoLeap(int client){
	ZPlayer player = ZPlayer(client);
	
	if (!IsPlayerExist(player.id, true))
		return;
	
	if (IsOnCooldown(player.id, LEAP_DELAY))
		return;
	
	float x, y;
	if (player.isBoss(false)){
		x = -40.0;
		y = 650.0;
	}
	else if (player.isBoss(true)){
		x = -25.0;
		y = 650.0;
	}
	else{
		x = -27.0;
		y = 630.0;
	}
	
	float ClientEyeAngle[3], ClientAbsOrigin[3], Velocity[3];
	
	GetClientAbsOrigin(player.id, ClientAbsOrigin);
	GetClientEyeAngles(player.id, ClientEyeAngle);
	
	float EyeAngleZero = ClientEyeAngle[0];
	
	ClientEyeAngle[0] = x;
	GetAngleVectors(ClientEyeAngle, Velocity, NULL_VECTOR, NULL_VECTOR);
	
	ScaleVector(Velocity, y);
	
	ClientEyeAngle[0] = EyeAngleZero;
	
	TeleportEntity(player.id, ClientAbsOrigin, ClientEyeAngle, Velocity);
}*/

// Damage hooks
public Action OnDamageTraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup){
	
	if (!IsPlayerExist(attacker, true))
		return Plugin_Handled;
	
	ZPlayer Victim = ZPlayer(victim);
	ZPlayer Attacker = ZPlayer(attacker);
	
	if (Attacker.iTeamNum == Victim.iTeamNum)
		return Plugin_Handled;
		
	/*if (Attacker.isHuman() && Victim.isHuman())
		return Plugin_Handled;
	
	if (Attacker.isZombie() && Victim.isZombie())
		return Plugin_Handled;*/
	
	if (Victim.bInvulnerable)
		return Plugin_Handled;
	
	return Plugin_Continue;
}
public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype){
	
	if (!IsPlayerExist(victim, true))
		return Plugin_Handled;
	
	if (damagetype & CS_DMG_HEADSHOT){
		SetEntPropVector(victim, Prop_Send, "m_viewPunchAngle", NULL_VECTOR);
		SetEntPropVector(victim, Prop_Send, "m_aimPunchAngle", NULL_VECTOR);
		SetEntPropVector(victim, Prop_Send, "m_aimPunchAngleVel", NULL_VECTOR);
	}
	
	if (victim == attacker)
		return Plugin_Handled;
	
	// Avoid damages whenever it should not be possible to get hurt
	if (damagetype & DMG_FALL) return Plugin_Handled;
	if (gServerData.RoundNew || gServerData.RoundEnd) return Plugin_Handled;
	
	// Initialize variables
	ZPlayer Attacker = ZPlayer(attacker);
	ZPlayer Victim = ZPlayer(victim);
	
	if (Victim.bInvulnerable)
		return Plugin_Handled;
	
	// Emit hurt sounds
	EmitHurtSound(Victim.id);
	
	// Initialize another damage variable
	float dmg;
	
	// Hooking different types of damage
	if (Victim.iTeamNum == CS_TEAM_T && damagetype & DMG_DIRECT){
		dmg = (Victim.iHp*BURN_DAMAGE_PER_HIT)/100.0;
		//PrintToChat(Victim.id, "%s Daño traducido por ignición: \x09%d\x01.", SERVERSTRING, RoundToZero(dmg));
		if (Victim.iHp <= RoundToZero(dmg))	Victim.iHealth = 0;
		else	Victim.iHp -= RoundToZero(dmg);
		
		// Apply dmg dealt to the combos
		if (IsPlayerExist(Victim.iIgniterId)) UpdateComboInfo(Victim.iIgniterId, dmg*0.5, false);
		
		return Plugin_Handled;
	}
	
	if (!IsPlayerExist(attacker))
		return Plugin_Handled;
	
	bool bCrit = false;
	
	// Initialize another damage variable
	dmg = damage;
	
	if (Attacker.isType(PT_ZOMBIE) && inflictor == attacker){
		
		ZClass class; 
		ZClasses.GetArray(Attacker.iZombieClass, class);
		ZAlignment alignment;
		ZAlignments.GetArray(Attacker.iZombieAlignment, alignment);
		
		dmg *= (Attacker.getZombieDamage() * class.damage) * alignment.flDamageMul;
		
		if(Victim.iArmor > 0){
			if(RoundToZero(dmg) > Victim.iArmor) Victim.iArmor = 0;
			else Victim.iArmor -= RoundToZero(dmg);
		}
		else{
			
			if(ActualMode.bInfection && GetValidPlayingHumans() > 1){
				FireInfectionEvent(attacker, victim);
			}
			else{
				if((Victim.iHp) <= dmg) Victim.iHealth = 0;
				else Victim.iHp -= RoundToZero(dmg);
			}
		}
		/*
		if(ActualMode.bKill){
			if((Victim.iHp+Victim.iArmor) <= dmg) Victim.iHealth = 0;
			else Victim.iHp -= (RoundToZero(dmg) - Victim.iArmor);
		}*/
	}
	else if (Attacker.isType(PT_HUMAN)){
		
		// Read the ZWeapon index in player's hands
		if (Attacker.iActiveWeaponIndex != -1){
			
			ZWeapon weap = ZWeapon(Attacker.iActiveWeaponIndex); // if is ZWeapon
			dmg = weap.flDamage; // apply ZWeapon's damage
			
			DamageOnClientKnockBack2(Victim.id, Attacker.id, weap.flKnockback); // apply knockback
			
			if (IsPlayerExist(Victim.id, true)){
				switch (weap.HitType){
					case HIT_TYPE_BURN:{
						IgniteEntity(Victim.id, Victim.isBoss() ? 1.0 : 3.0);
						Victim.iIgniterId = Attacker.id;
					}
					case HIT_TYPE_FREEZE:{
						Freeze(Victim.id, Attacker.id, FREEZE_AWP_STUN_TIME);
					}
				}
			}
		}
		else{
			char classname[32];
			GetEdictClassname(Attacker.iActiveWeapon, classname, sizeof(classname));
			
			if (StrContains(classname, "weapon_knife") != -1){
				dmg *= KNIFE_DEFAULT_DAMAGE_MUL;
			}
		}
		
		// Read alignments damage
		HAlignment hAlignment;
		HAlignments.GetArray(Attacker.iHumanAlignment, hAlignment);
		
		// Apply alignments damage
		dmg *= hAlignment.flDamageMul;
		
		// Apply upgrades damage
		dmg *= Attacker.getHumanDamage();
		
		// Detect headshot
		if (damagetype & CS_DMG_HEADSHOT)
			dmg *= HEADSHOT_DAMAGE_MULTIPLIER; // apply damage
		
		// Apply crit damage if lucky
		if (Attacker.iCritChanceLevel){
			if (GetUpgradeChance(Attacker.id, 1)){
				dmg *= CRIT_DAMAGE_MULTIPLIER;
				bCrit = true;
			}
		}
		
		// AP PER X DAMAGE DEALT
		DamageDealtOnTakeDamage(attacker, RoundToZero(dmg));
		
		// Deal damage to the victim
		if (Victim.iHp <= dmg)	Victim.iHealth = 0;
		else	Victim.iHp -= RoundToZero(dmg);
	}
	// Else, attacker is boss
	else if (Attacker.isBoss(true) || Attacker.isBoss(false)){
		// If human boss
		if (Attacker.isHuman()){
			
			// Read the ZWeapon index in player's hands
			if (Attacker.iActiveWeaponIndex != -1){
				ZWeapon weap = ZWeapon(Attacker.iActiveWeaponIndex); // if is ZWeapon
				dmg = weap.flDamage; // apply ZWeapon's damage
				
				DamageOnClientKnockBack2(Victim.id, Attacker.id, weap.flKnockback); // apply knockback
			}
			else{
				char classname[32];
				GetEdictClassname(Attacker.iActiveWeapon, classname, sizeof(classname));
				if (StrContains(classname, "weapon_knife") != -1) dmg *= KNIFE_DEFAULT_DAMAGE_MUL;
			}
			
			// Detect headshot
			if (damagetype & CS_DMG_HEADSHOT) dmg *= HEADSHOT_DAMAGE_MULTIPLIER; // apply damage
			
			// Apply crit damage if lucky
			if (Attacker.iCritChanceLevel){
				if (GetUpgradeChance(Attacker.id, 1)){
					dmg *= CRIT_DAMAGE_MULTIPLIER;
					bCrit = true;
				}
			}
			
			if(IsFakeClient(Attacker.id)){
				dmg /= 3.0;
			}
			else{
				if (Attacker.iReset <= 20){
					dmg *= 2.0;
				} // cambiar esto
			}
			
			// AP PER X DAMAGE DEALT
			DamageDealtOnTakeDamage(attacker, RoundToZero(dmg));
			
		}
		else if (Attacker.isType(PT_NEMESIS) && Attacker.iActiveWeaponIndex == iWeaponBazooka){
			
			// Read the ZWeapon index in player's hands
			ZWeapon weap = ZWeapon(Attacker.iActiveWeaponIndex); // if is ZWeapon
			dmg = weap.flDamage; // apply ZWeapon's damage
			
			// Deal damage to the victim 
			if(Victim.iHp <= dmg) Victim.iHealth = 0;
			else Victim.iHp -= RoundToZero(dmg);
			
			TranslationPrintHintText(Attacker.id, "Zombie damage dealt", RoundToZero(dmg));
			
			DamageOnClientKnockBack2(Victim.id, Attacker.id, weap.flKnockback); // apply knockback
			return Plugin_Handled;
		}
		
		// Read boss damage
		ZBoss boss;
		ZBosses.GetArray(GetBossIndex(Attacker.iType), boss);
		
		if (boss.id == -1)
			return Plugin_Handled;
		
		// Apply boss damage
		dmg *= boss.flDamage;
		
		// Apply human/zombie upgrades damage
		dmg *= Attacker.isBoss() ? Attacker.getZombieDamage(true) : Attacker.getHumanDamage(true);
		
		// Deal damage to the victim 
		if(Victim.iHp <= dmg) Victim.iHealth = 0;
		else Victim.iHp -= RoundToZero(dmg);
	}
	
	// Stack combo if attacker is any type of human
	if (!IsFakeClient(Attacker.id)){
		
		// Cooldown to show the HUD
		if (Attacker.iTeamNum == CS_TEAM_CT){
			
			// Update combo parameters
			UpdateComboInfo(attacker, dmg, bCrit);
		}
		else if (Attacker.iTeamNum == CS_TEAM_T){
			// Depending on the victim's type
			TranslationPrintHintText(Attacker.id, "Zombie damage dealt", RoundToZero(dmg));
		}
	}
	
	// Apply zombie madness if lucky
	if (Victim.iHealth){ // client is alive
	
		// Victim = zombie, Attacker = human
		if (Victim.isType(PT_ZOMBIE) && Attacker.isHuman()){
			
			// Client has the upgrade & madness is not in cooldown
			if (!IsMadnessInCooldown(Victim.id) && Victim.iMadnessChanceLevel){
				
				// Victim's HP is equal or lower
				if (Victim.iHp <= (Victim.iMaxHp * GOLDEN_MADNESS_CHANCE_MIN_HP_PCT) / 100){
					fEngineTime = GetEngineTime();
					
					if (Victim.fMadnessChanceTime < fEngineTime){
						Victim.fMadnessChanceTime = fEngineTime+0.3;
						
						if (GetUpgradeChance(Victim.id, 0)){
							applyExtraItemEffect(Victim.id, view_as<int>(EXTRA_ITEM_MADNESS));
							//PrintToChat(Victim.id, "GOLDEN UPGRADE: ZOMBIE MADNESS APPLIED");
						}
					}
				}
			}
		}
	}
	
	// Deny the original damage
	return Plugin_Handled;
}

void DamageDealtOnTakeDamage(int attacker, int dmg){
	
	gClientData[attacker].iDamageDealtCounter += dmg;
	if (gClientData[attacker].iDamageDealtCounter >= DAMAGE_DEALT_DAMAGE_REQUIRED_TO_EARN_AP){
		gClientData[attacker].iDamageDealtCounter = 0;
		gClientData[attacker].iExp += DAMAGE_DEALT_AP_PER_DAMAGE_DEALT;
	}
}

stock bool hasAccessToWeapon(int client, int weaponId){
	
	// If not nemesis and weapon is bazooka, deny
	if (weaponId == iWeaponBazooka){
		
		if (gClientData[client].iType == PT_NEMESIS){
			return true;
		}
		
		return false;
	}
	
	if (weaponId == iWeaponChainsaw){
		
		if (gClientData[client].iType == PT_CHAINSAW){
			return true;
		}
		
		return false;
	}
	
	if (weaponId == iWeaponGunslinger){
		
		if (gClientData[client].iType == PT_GUNSLINGER){
			return true;
		}
		
		return false;
	}
	
	if (weaponId == iWeaponSurvivor){
		
		if (gClientData[client].iType == PT_SURVIVOR){
			return true;
		}
		
		return false;
	}
	
	if (weaponId == iWeaponSuperSurvivor){
		
		if (gClientData[client].iType == PT_SUPERSURVIVOR){
			return true;
		}
		
		return false;
	}
	
	if (weaponId == iWeaponSniper){
		
		if (gClientData[client].iType == PT_SNIPER){
			return true;
		}
		
		return false;
	}
	
	// If weapon isn't modified or the first one in menu, or player's resets are lower than minimal restriction
	if (weaponId <= 0 || ZPlayer(client).iReset <= RESET_AMOUNT_TO_ALLOW_ALL_WEAPONS){
		return true;
	}
	
	// Declare variables to cast player and weapon modules
	ZPlayer player = ZPlayer(client);
	ZWeapon weapon = ZWeapon(weaponId);
	
	// If doesnt	
	if (player.iTier < weapon.iTier){
		return false;
	}
	
	// If doesnt accomplish resets
	if (player.iReset < weapon.iReset)
		return false;
	
	// If doesnt accomplish level and isn't the weapon he could buy (BUGFIX to leveling down)
	if (player.iWeaponBought != weaponId && player.iLevel < weapon.iLevel)
		return false;
	
	/*if (!value){
		LogError("Not corresponding weapon: weapon level: %d, weapon rr: %d / player lvl: %d, player rr: %d / wpn id: %d, ultima arma id: %d", weapon.iLevel, weapon.iReset, player.iLevel, player.iReset, weaponId, player.iWeaponBought);
		return false;
	}*/
	
	// Player must have the needed resets, but we check if this player leveled down OR has the according level to prevent bugs
	return true;
}

void FireInfectionEvent(int &attacker, int &victim){
	
	ZPlayer Attacker = ZPlayer(attacker);
	ZPlayer Victim = ZPlayer(victim);
	
	Victim.bRecentlyInfected = true;
	
	Event event = CreateEvent("player_death");
	if (event == null) return;
	
	// Dispatch event data
	event.SetInt("userid", GetClientUserId(Victim.id));
	event.SetInt("attacker", (IsPlayerExist(Attacker.id)) ? GetClientUserId(Attacker.id) : GetClientUserId(Victim.id));
	event.SetString("weapon", "knife");
	event.SetBool("headshot", true);
	event.Fire();
	
	// Prepare heritage
	#if defined ENABLE_INFECTION_HERITAGE
	DispatchInfectionHeritage(attacker, victim);
	#endif
	
	// If player has leech
	Attacker.applyInfectionLeech();
	
	// Calculate gain
	int value = Attacker.iLevel * INFECTION_SCALAR_REWARD;
	//PrintToChat(Attacker.id, "PREVALUE IS %d", value);
	
	int diff = Attacker.iLevel - Victim.iLevel;
	//PrintToChat(Attacker.id, "DIFF IS %d", diff);
	if (diff < 0){
		value += AbsValue(diff) * (INFECTION_SCALAR_REWARD / 4);
		//PrintToChat(Attacker.id, "VALUE IS %d", value);
	}
	
	int base = INFECTION_BASE_REWARD + value;
	
	// Start infection heritage detection & gains
	int iTotal;
	char sPointed[32];
	ZPlayer iOriginalInfector = ZPlayer(Attacker.iInfectorId);
	
	if (!IsPlayerExist(iOriginalInfector.id) || !iOriginalInfector.isType(PT_ZOMBIE)){
		iTotal = Attacker.applyGain(base);
		//AddPoints(iTotal, sPointed, sizeof(sPointed));
		//TranslationPrintToChat(Attacker.id, "Infected someone chat", sPointed);
		printZombieComboHUD(Attacker.id, iTotal, true);
	}
	else{
		// Give gain to the infector
		iTotal = Attacker.applyGain(base*INFECTION_HERITAGE_INFECTOR_PCT);
		AddPoints(iTotal, sPointed, sizeof(sPointed));
		TranslationPrintToChat(Attacker.id, "Inherited infection chat", sPointed);
		
		// Give gain to the original infector
		iTotal = iOriginalInfector.applyGain(base*INFECTION_HERITAGE_OINFECTOR_PCT);
		AddPoints(iTotal, sPointed, sizeof(sPointed));
		TranslationPrintToChat(iOriginalInfector.id, "Inherited infection chat", sPointed);
	}
	
	// Infect victim
	Victim.Zombiefy();
}

void DispatchInfectionHeritage(int &attacker, int &victim){
	
	ZPlayer Attacker = ZPlayer(attacker);
	ZPlayer Victim = ZPlayer(victim);
	
	// if infector has a valid timer, set the original infector as infector
	if (IsPlayerExist(Attacker.iInfectorId) && ZPlayer(Attacker.iInfectorId).isType(PT_ZOMBIE)){
		Victim.iInfectorId = Attacker.iInfectorId;
	}
	else // this is the new original infector
	Victim.iInfectorId = Attacker.id;
	
	// Store victim's id to attacker's variable
	Attacker.iInfectedId = Victim.id;
	
	// Set a timer to finish the heritage
	CreateTimer(INFECTION_HERITAGE_DURATION, FinishInfectionHeritage, Victim.id, TIMER_FLAG_NO_MAPCHANGE);
}
public Action FinishInfectionHeritage(Handle hTimer, int victim){
	
	ZPlayer Victim = ZPlayer(victim);
	
	Victim.iInfectorId = -1;
	
	return Plugin_Stop;
}

// INDIVIDUAL combo functions
public void UpdateComboInfo(int client, float dmg, bool bCrit){
	fEngineTime = GetEngineTime();
	
	ZPlayer Attacker = ZPlayer(client);
	
	if (gClientData[client].bInParty){
		ZParty pt = ZParty(findPartyByUID(gClientData[client].iPartyUID));
		if(pt.id != -1){
			pt.iDamageDealt += RoundToFloor(dmg);
			
			//int difficulty = NextComboPt(pt.iCombo, pt.avgLevel(), pt.avgReset());
			
			//PrintToChatAll("difficulty normal: %d dmg", difficulty);
			
			//int partyDifficulty = (NextComboPt(pt.iCombo, pt.avgLevel(), pt.avgReset()) - RoundToZero(float(NextComboPt(pt.iCombo, pt.avgLevel(), pt.avgReset())) * pt.getTotalBoost());
			
			//PrintToChatAll("difficulty party: %d partydmg, difficulty %d, fDiff %0.2f, totalBoost %02.f", partyDifficulty, difficulty, float(difficulty), pt.getTotalBoost());*/
			
			while ( pt.iDamageDealt >= (NextComboPt(pt.iCombo, pt.avgLevel(), pt.avgReset()) - RoundToZero(float(NextComboPt(pt.iCombo, pt.avgLevel(), pt.avgReset())) * pt.getTotalBoost())) )
				pt.iCombo++;
			
			if (pt.fComboTime < fEngineTime){
				
				// Show the info & update cooldown
				pt.fComboTime = fEngineTime+0.2;
				ShowComboInfoParty(findPartyByUID(pt.iUID), RoundToZero(dmg));
			}
			
			return;
		}
	}
	
	Attacker.iDamageDealt += RoundToZero(dmg);
	
	//int nextCombo;
	
	// Update combos according to previously processed info
	
	
	if (Attacker.iReset <= 15){
		while (Attacker.iDamageDealt >= NextComboLowReset( (Attacker.isBoss(true) ? Attacker.iCombo*2 : Attacker.iCombo),  Attacker.iLevel, Attacker.iReset))
			Attacker.iCombo++;
	}
	else{
		if (Attacker.isBoss(true)){
			while (Attacker.iDamageDealt >= NextCombo(Attacker.iCombo*2, Attacker.iLevel, Attacker.iReset))
				Attacker.iCombo++;
		}
		else{
			while (Attacker.iDamageDealt >= NextCombo(Attacker.iCombo, Attacker.iLevel, Attacker.iReset))
				Attacker.iCombo++;
		}
	}
	/*else{
		nextCombo = NextCombo( (Attacker.isBoss(true) ? Attacker.iCombo*2 : Attacker.iCombo),  Attacker.iLevel, Attacker.iReset);
	}*/
	
	if (Attacker.fComboTime < fEngineTime){
		
		// Show the info & update cooldown
		Attacker.fComboTime = fEngineTime+0.1;
		ShowComboInfo(Attacker.id, RoundToZero(dmg), bCrit);
	}
}
public void ShowComboInfo(int client, int damagehit, bool bCrit){
	
	if (!IsPlayerExist(client)){
		PrintToServer("[DEBUG] Usuario no válido (index: %i)", client);
		LogError("[DEBUG] Usuario no válido (index: %i)", client);
		return;
	}
	
	ClearSyncHud(client, hComboSynchronizer);
	
	ZPlayer player = ZPlayer(client);
	
	// Adjust combo type
	ZCombo combo = ZCombo(player.iComboType);
	
	if (combo.AdjustType(player.id)){
		combo = ZCombo(player.iComboType);
	}
	
	// String buffer
	char msg[512];
	
	// Format the hud
	formatComboHUD(player.id, msg, damagehit, bCrit);
	
	// Set parameters
	if (combo.id >= view_as<int>(COMBO_MASSIVE))
		SetHudTextParams(GetRandomFloat(0.42, 0.38), GetRandomFloat(0.67, 0.63), COMBO_DURATION, GetRandomInt(100, 255), GetRandomInt(150, 255), GetRandomInt(150, 255), 1, 1, COMBO_DURATION, 0.01, COMBO_DURATION);
	else
		SetHudTextParams(0.42, 0.65, COMBO_DURATION, combo.iRed, combo.iGreen, combo.iBlue, 1, 1, 0.5, 0.01, 0.8);
	
	ShowSyncHudText(player.id, hComboSynchronizer, msg);
	
	// Reset handles
	if (player.hComboHandle != null){
		delete player.hComboHandle;
		player.hComboHandle = null;
	}
	
	// Set a timer to finish the combo
	player.hComboHandle = CreateTimer(COMBO_DURATION, FinishCombo, player.id, TIMER_FLAG_NO_MAPCHANGE);
}
public Action FinishCombo(Handle hTimer, any client){
	ZPlayer player = ZPlayer(client);
	
	// Not valid? Kill timer
	if (!IsPlayerExist(player.id)) {
		player.hComboHandle = null;
		return Plugin_Stop;
	}
	
	if(player.hComboHandle == null){
		return Plugin_Stop;
	}
	
	// Initialize combo method
	ZCombo combo = ZCombo(player.iComboType);
	
	if (combo.AdjustType(player.id)){
		combo = ZCombo(player.iComboType);
	}
	
	///////////////////////////////////////////
	
	int rawgain;
	// Calculate gain
	rawgain = RoundToCeil(player.iCombo * COMBO_REWARD_BASE * combo.fBonusExpGain);
	
	// Apply gain according to VIP & happyhour levels
	int totalgain = player.applyGain(rawgain);
	
	// Initialize vars
	char msg[512];
	
	// Format HUD
	formatComboHUD(player.id, msg, totalgain, false, true);
	
	// Set parameters
	SetHudTextParams(-1.0, 0.20, COMBO_HUD_FINISH_HOLDTIME, combo.iRed, combo.iGreen, combo.iBlue, COMBO_HUD_FINISH_ALPHA, COMBO_HUD_FINISH_EFFECT, COMBO_HUD_FINISH_FXTIME, COMBO_HUD_FINISH_FADEIN, COMBO_HUD_FINISH_FADEOUT);
	
	// Print the info to the user
	ShowSyncHudText(client, hComboSynchronizer2, msg);
	
	// Reset vars
	player.iCombo = 1;
	player.iComboType = view_as<int>(COMBO_DEFAULT);
	player.iDamageDealt = 0;
	
	combo = ZCombo(player.iComboType);
	combo.AdjustType(player.id);
	
	player.hComboHandle = null;
	
	return Plugin_Stop;
}
void SafeEndPlayerCombo(int client){
	
	if (IsPlayerExist(client))
		ClearSyncHud(client, hComboSynchronizer);
	
	ZPlayer player = ZPlayer(client);
	
	if (player.hComboHandle != null){
		if (player.iCombo > 1)
			FinishCombo(player.hComboHandle, player.id);
		else
			player.hComboHandle = null;
	}
}

// PARTY combo functions
public void ShowComboInfoParty(int pid, int damagehit){
	
	if (pid < 0)
		return;
	
	// Adjust combo type
	ZCombo combo = ZCombo(0);
	
	// String buffer
	char msg[512];
	
	SetHudTextParams(-1.0, 0.65, COMBO_DURATION, combo.iRed, combo.iGreen, combo.iBlue, 1, 1, 0.5, 0.01, 0.8);
	
	ZParty pt = ZParty(pid);
	ZPlayer ptPlayer;
	for(int i; i < pt.length(); i++){
		ptPlayer = ZPlayer(pt.getMemberByArrayId(i));
		
		if(!IsPlayerExist(ptPlayer.id)) continue;
		
		if(ptPlayer.iTeamNum != CS_TEAM_CT) continue;
		
		// Format the hud
		formatComboHUD(ptPlayer.id, msg, damagehit);
		ShowSyncHudText(ptPlayer.id, hComboSynchronizer, msg);
	}
	
	// Reset handles
	if (pt.hComboHandle != null){
		delete pt.hComboHandle;
		pt.hComboHandle = null;
	}
	
	// Set a timer to finish the combo
	pt.hComboHandle = CreateTimer(COMBO_DURATION, FinishComboParty, pid, TIMER_FLAG_NO_MAPCHANGE);
}
public Action FinishComboParty(Handle hTimer, any pid){
	ZParty pt = ZParty(pid);
	
	if(pt.hComboHandle == null){
		return Plugin_Handled;
	}
	
	// Initialize vars
	char msg[512];
	
	// Calculate gain
	//int rawgain = RoundToCeil( pt.iCombo * (COMBO_PARTY_REWARD_PU * (pt.Length()/pt.GetHumans())) );
	//int rawgain = RoundToNearest((pt.iCombo * (1+pt.getTotalBoost())));
	int validMembers = (pt.getValidPlayers() >= 1) ? pt.getValidPlayers() : 1;
	int rawgain = pt.iCombo/validMembers;
	
	ZCombo combo = ZCombo(0);
	
	// Set parameters
	SetHudTextParams(-1.0, 0.20, 2.5, combo.iRed, combo.iGreen, combo.iBlue, 1, 1, 1.2, 0.02, 0.6);
	
	ZPlayer ptPlayer;
	for(int i; i < pt.length(); i++){
		ptPlayer = ZPlayer(pt.getMemberByArrayId(i));
		
		if(ptPlayer.iTeamNum != CS_TEAM_CT) continue;
		
		ClearSyncHud(ptPlayer.id, hComboSynchronizer);
		
		// Apply gain according to VIP & happyhour levels
		int totalgain = ptPlayer.applyGain(rawgain);
		
		// Format HUD
		formatComboHUD(ptPlayer.id, msg, totalgain, false, true);
		
		// Print the info to the user
		ShowSyncHudText(ptPlayer.id, hComboSynchronizer2, msg);
	}
	
	// Reset vars to the entire party
	pt.iCombo = 1;
	pt.iDamageDealt = 0;
	pt.hComboHandle = null;
	//delete pt.hComboHandle;
	
	// Kill timer
	return Plugin_Stop;
}
void SafeEndComboParty(int partyId){
	
	if (partyId < 0)
		return;
	
	ZParty party = ZParty(partyId);
	
	if (party.hComboHandle != null){
		if (party.iCombo > 1)
			FinishComboParty(party.hComboHandle, party.id);
		else
			party.hComboHandle = null;
	}
}

// Combo HUD formatting
stock void formatComboHUD(int client, char buffer[512], int value, bool bCrit = false, bool bFinish = false){
	ZPlayer player = ZPlayer(client);
	
	// Initialize buffers
	char sCombo[16], sDamage[16];
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	if (gClientData[client].bInParty){
		int partyID = findPartyByUID(gClientData[client].iPartyUID);
		if (partyID < 0){
			return;
		}
		
		ZParty pt = ZParty(partyID);
		
		AddPoints(pt.iCombo, sCombo, sizeof(sCombo));
		AddPoints(pt.iDamageDealt, sDamage, sizeof(sDamage));
		
		if (!bFinish){
			FormatEx(buffer, sizeof(buffer), "COMBO PARTY\nGanancias acumuladas: %s AP\nDaño acumulado: %s\n", sCombo, sDamage);
		}
		else{
			char sGain[15];
			if(!pt.getValidPlayers()) return; 
			
			AddPoints(value, sGain, sizeof(sGain));
			
			// Format hud message depending on the gain
			if (player.flExpBoost > 1.0){
				FormatEx(buffer, sizeof(buffer), "COMBO FINALIZADO\nGanancias totales: %s AP\nDaño total: %s\nRecibes: %s AP (VIP x%i)", sCombo, sDamage, sGain, RoundToZero(player.flExpBoost));
			}
			else{
				FormatEx(buffer, sizeof(buffer), "COMBO FINALIZADO\nGanancias totales: %s AP\nDaño total: %s\nRecibes: %s AP", sCombo, sDamage, sGain);
			}
		}
	}
	else{
		AddPoints(player.iCombo, sCombo, sizeof(sCombo));
		AddPoints(player.iDamageDealt, sDamage, sizeof(sDamage));
		
		///////////////////////////////////////////////////////////
		//ZCombo combo = ZCombo(player.iComboType);
		///////////////////////////////////////////////////////////
		
		char sName[32];
		gComboName.GetString(player.iComboType, sName, sizeof(sName));
		
		if (!bFinish){
			char sDamageHit[16];
			AddPoints(value, sDamageHit, sizeof(sDamageHit));
			
			FormatEx(buffer, sizeof(buffer), "%t", "Single combo info", sCombo, sName, sDamage, sDamageHit, bCrit ? "CRIT!" : "");
		}
		else{
			// Add "." to potentially large numbers
			char sGain[24];
			AddPoints(value, sGain, sizeof(sGain));
			
			// Calculate additional bonus AP
			int iBonus = (value-player.iCombo);
			char sBonus[24];
			AddPoints((player.iLevel == RESET_LEVEL) ? 0 : iBonus, sBonus, sizeof sBonus);
			
			// Format hud message depending on the gain
			if (player.flExpBoost > 1.0){
				FormatEx(buffer, sizeof(buffer), "%t (VIP x%i)", "Single combo finished", sName, sCombo, sDamage, sBonus, sGain, RoundToZero(player.flExpBoost));
			}
			else{
				// Standard user
				FormatEx(buffer, sizeof(buffer), "%t", "Single combo finished", sName, sCombo, sDamage, sBonus, sGain);
			}
			
			///////////////////////////////////////////////////////////
			
			///////////////////////////////////////////////////////////
			
			//Format(buffer, sizeof(buffer), "%t: %s %s\n", "Combo finished", sCombo, buffer);
		}
	}
}

// Combo HUD formatting
stock void printZombieComboHUD(int client, int ap, bool infection = true){
	
	ClearSyncHud(client, hComboSynchronizer);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
		
	char sGain[16];
	// Add "." to potentially large numbers
	AddPoints(ap, sGain, sizeof(sGain));
	
	///////////////////////////////////////////////////////////
	char buffer[128];
	FormatEx(buffer, sizeof(buffer), "%t%t", infection ? "Infection" : "Assassination", "Zombie combo hud", sGain);
	
	SetHudTextParams(-1.0, 0.55, 3.0, GetRandomInt(100, 255), GetRandomInt(60, 255), GetRandomInt(60, 255), 60, 2, 0.5, 0.01, 0.8);
	ShowSyncHudText(client, hComboSynchronizer, buffer);
}

// OnCient functions
public void OnClientPostAdminCheck(int client){
	EmitSoundToClient(client, WELCOME_SOUND, SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NORMAL, _, 0.5, _, _, _, _, _, 5.0);
	
	// Antistick
	AntiStickOnClientInit(client);
	
	// Execute weapons hook functions
	WeaponsOnClientPostAdminCheck(client);
}

//=====================================================
//					SERVER COMMANDS
//=====================================================
public Action givezpoints(int args){
	char player[16];
	char cPoints[16];
	GetCmdArg(1, player, 16);
	GetCmdArg(2, cPoints, 16);
	int points = StringToInt(cPoints);
	
	char name[32];
	for (int i = 1; i <= MaxClients; i++){
		if(IsPlayerExist(i)){
			GetClientName(i,name, 32);
			if(StrEqual(name, player) && IsPlayerExist(i)){
				ZPlayer p = ZPlayer(i);
				p.iZPoints += points;
			}
		}
	}
	return Plugin_Handled;
}
public Action givexp(int args){
	char player[16];
	char cPoints[16];
	GetCmdArg(1, player, 16);
	GetCmdArg(2, cPoints, 16);
	int points = StringToInt(cPoints);
	
	char name[32];
	for (int i = 1; i <= MaxClients; i++){
		if(IsPlayerExist(i)){
			GetClientName(i,name, 32);
			if(StrEqual(name, player)){
				ZPlayer p = ZPlayer(i);
				p.iExp += points;
				p.checkLevelUp();
			}
		}
	}
	return Plugin_Handled;
}
public Action makePlayer(int args){
	char player[16];
	char type[16];
	char what[32];
	GetCmdArg(1, player, 16);
	GetCmdArg(2, type, 16);
	for(int i = 1; i<= MaxClients; i++){
		if(IsPlayerExist(i)){
			char name[32];
			GetClientName(i,name, 32);
			if(StrEqual(name, player)){
				ZPlayer p = ZPlayer(i);
				if(StrEqual(type, "human")){
					p.Humanize();
					FormatEx(what, 32, "Humano");
				}
				else if(StrEqual(type, "zombie")){
					p.Zombiefy();
					FormatEx(what, 32, "Zombie");
					GivePlayerItem(p.id, "weapon_flashbang");
				}
				else if (StrEqual(type, "assassin")){
					p.TurnInto(PT_ASSASSIN);
					FormatEx(what, 32, "Assassin");
				}
				else if(StrEqual(type, "gunslinger")){
					p.TurnInto(PT_GUNSLINGER);
					FormatEx(what, 32, "gunslinger");
				}
				else if(StrEqual(type, "survivor")){
					p.TurnInto(PT_SURVIVOR);
					FormatEx(what, 32, "Survivor");
				}
				else if(StrEqual(type, "supersurvivor")){
					p.TurnInto(PT_SUPERSURVIVOR);
					FormatEx(what, 32, "SUPER Survivor");
				}
				else if (StrEqual(type, "sniper")){
					p.TurnInto(PT_SNIPER);
					FormatEx(what, 32, "Sniper");
				}
				else if(StrEqual(type, "nemesis")){
					p.TurnInto(PT_NEMESIS);
					FormatEx(what, 32, "Nemesis");
				}
				else if(StrEqual(type, "alive")){
					p.iRespawnPlayer();
					FormatEx(what, 32, "Vivo");
				}
				else if(StrEqual(type, "invulnerable")){
					p.bInvulnerable = !p.bInvulnerable;
					FormatEx(what, 32, "Invulnerable");
				}
				else{
					PrintToServer("%s no encontrado", type);
					return Plugin_Handled;
				}
			}
		}		
	}
	return Plugin_Handled;
}
public Action givehpoints(int args){
	char player[16];
	char cPoints[16];
	GetCmdArg(1, player, 16);
	GetCmdArg(2, cPoints, 16);
	int points = StringToInt(cPoints);
	for(int i=1; i <= MaxClients; i++){
		if(IsPlayerExist(i)){
			char name[32];
			GetClientName(i,name, 32);
			if(StrEqual(name, player)){
				ZPlayer p = ZPlayer(i);
				p.iHPoints += points;
			}
		}
		
	}
	return Plugin_Handled;
}
public Action adminMe(int args){
	char player[16];
	GetCmdArg(1, player, 16);
	for(int i=1; i < GetClientCount(); i++){
		if(IsPlayerExist(i)){
			char name[32];
			GetClientName(i,name, 32);
			if(StrEqual(name, player)){
				ZPlayer p = ZPlayer(i);
				p.bVip = true;
			}
		}
	}
	return Plugin_Handled;
}

//=====================================================
//					USER COMMANDS
//=====================================================
public Action infoCommands(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	TranslationPrintToChat(player.id, "Info message 1");
	TranslationPrintToChat(player.id, "Info message 2");
	TranslationPrintToChat(player.id, "Info message 3");
	TranslationPrintToChat(player.id, "Info message 4");
	TranslationPrintToChat(player.id, "Info message 5");
	TranslationPrintToChat(player.id, "Info message 6");
	TranslationPrintToChat(player.id, "Info message 7");
	TranslationPrintToChat(player.id, "Info message 8");
	
	return Plugin_Handled;
}
public Action infoMode(int client, int args){
	ZPlayer player = ZPlayer(client);
	// Get mode name
	static char name[32];
	ActualMode.GetName(name, sizeof(name));
	
	TranslationPrintToChat(player.id, "Current mode", (ActualMode.id > view_as<int>(IN_WAIT)) ? name : "None");
	return Plugin_Handled;
}
public Action time(int args){
	char times[32];
	FormatTime(times, 32, "%H:%M:%S", GetTime());
	PrintToServer("%s", times);
	return Plugin_Handled;
}
public Action serverDataBaseOnSaveAllDatacmd(int args){
	DataBaseOnSaveAllData();
	PrintToServer("[DATABASE] Saving all users' data!");
	return Plugin_Handled;
}
public Action saveme(int client, int args){
	
	saveCharacterData(client);
	return Plugin_Handled;
}
public Action flashLight(int client, int args){
	ZPlayer player = ZPlayer(client);
	if(player.iType >= PT_HUMAN && player.iType < PT_MAX_HUMANS && IsPlayerExist(player.id, true)) player.bFlashlight = !player.bFlashlight;
	return Plugin_Handled;
}
public Action infoVip(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	TranslationPrintToChat(player.id, "Advertisement 1");
	TranslationPrintToConsole(player.id, "Advertisement 1");
	TranslationPrintToChat(player.id, "Advertisement 2");
	TranslationPrintToConsole(player.id, "Advertisement 2");
	TranslationPrintToChat(player.id, "Advertisement 3");
	TranslationPrintToConsole(player.id, "Advertisement 3");
	TranslationPrintToChat(player.id, "Advertisement 4");
	TranslationPrintToConsole(player.id, "Advertisement 4");
	TranslationPrintToChat(player.id, "Advertisement 5");
	TranslationPrintToConsole(player.id, "Advertisement 5");
	
	return Plugin_Handled;
}
public Action infoRules(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	TranslationPrintToChat(player.id, "Against the rules");
	TranslationPrintToChat(player.id, "Rule 1");
	TranslationPrintToChat(player.id, "Rule 2");
	TranslationPrintToChat(player.id, "Rule 3");
	TranslationPrintToChat(player.id, "Rule 4");
	TranslationPrintToChat(player.id, "Rule 5");
	TranslationPrintToChat(player.id, "Rule 6");
	TranslationPrintToChat(player.id, "Rule 7");
	TranslationPrintToChat(player.id, "Rule 8");
	TranslationPrintToChat(player.id, "Rule 9");
	TranslationPrintToChat(player.id, "Rule 10");
	PrintToChat(player.id, " \x09------------------------------------------------\x01");
	TranslationPrintToChat(player.id, "Not complying the rules");
	
	TranslationPrintToConsole(player.id, "Against the rules");
	TranslationPrintToConsole(player.id, "Rule 1");
	TranslationPrintToConsole(player.id, "Rule 2");
	TranslationPrintToConsole(player.id, "Rule 3");
	TranslationPrintToConsole(player.id, "Rule 4");
	TranslationPrintToConsole(player.id, "Rule 5");
	TranslationPrintToConsole(player.id, "Rule 6");
	TranslationPrintToConsole(player.id, "Rule 7");
	TranslationPrintToConsole(player.id, "Rule 8");
	TranslationPrintToConsole(player.id, "Rule 9");
	TranslationPrintToConsole(player.id, "Rule 10");
	PrintToConsole(player.id, " \x09------------------------------------------------\x01");
	TranslationPrintToConsole(player.id, "Not complying the rules");
	
	return Plugin_Handled;
}
public Action infoDiscord(int client, int args){
	
	PrintToChat(client, "%s Ingresa al siguiente enlace para ingresar a nuestro servidor de \x09Discord\x01!", SERVERSTRING);
	PrintToChat(client, "%s \x09Discord ZOMBIE SURVIVAL & MULTIMOD\x01: \x03%s\x01", SERVERSTRING, DISCORD_LINK_PIU);
	PrintToChat(client, "%s Este mensaje también será enviado a tu consola para que puedas copiar y pegar.", SERVERSTRING);
	
	PrintToConsole(client, "[PIU] Discord ZOMBIE SURVIVAL & MULTIMOD: %s", DISCORD_LINK_PIU);
	PrintToConsole(client, "[PIU] TE ESPERAMOS!");
}

public Action infoWhatsapp(int client, int args){
	
	PrintToChat(client, "%s Ingresa al siguiente enlace para ingresar a nuestro grupo de \x09WhatsApp\x01!", SERVERSTRING);
	PrintToChat(client, "%s \x09WhatsApp ZOMBIE SURVIVAL\x01: \x03%s\x01", SERVERSTRING, WHATSAPP_LINK_PIU);
	PrintToChat(client, "%s Este mensaje también será enviado a tu consola para que puedas copiar y pegar.", SERVERSTRING);
	
	PrintToConsole(client, "[PIU] Whatsapp ZOMBIE SURVIVAL: %s", WHATSAPP_LINK_PIU);
	PrintToConsole(client, "[PIU] TE ESPERAMOS!");
}

public Action infoInstagram(int client, int args){
	
	PrintToChat(client, "%s Ingresa al siguiente enlace y seguinos en nuestra página de \x09INSTAGRAM\x01!", SERVERSTRING);
	PrintToChat(client, "%s \x09Instagram ZOMBIE SURVIVAL\x01: \x03%s\x01", SERVERSTRING, INSTAGRAM_LINK_PIU);
	PrintToChat(client, "%s Este mensaje también será enviado a tu consola para que puedas copiar y pegar.", SERVERSTRING);
	
	PrintToConsole(client, "[PIU] Instagram ZOMBIE SURVIVAL: %s", INSTAGRAM_LINK_PIU);
	PrintToConsole(client, "[PIU] TE ESPERAMOS!");
}

public Action showAdminList(int client, int args){
	
	char AdminNames[MAXPLAYERS+1][MAX_NAME_LENGTH+1];
	int count = 0;
	
	for (int i = 1; i <= MaxClients; i++){
		
		if (IsClientInGame(i) && ZPlayer(i).bInGame){
			
			AdminId AdminID = GetUserAdmin(i); 
			if (AdminID != INVALID_ADMIN_ID){
				
				GetClientName(i, AdminNames[count], sizeof(AdminNames[]));
				count++;
			}
		}
	}
	
	char buffer[1024];
	ImplodeStrings(AdminNames, count, ", ", buffer, sizeof(buffer));
	
	PrintToChat(client, " \x0B%s\x01 Admins online:\n %s", TRANSLATION_PHRASE_PREFIX, buffer);
}
public Action nightVision(int client, int args){
	
	if (!IsPlayerExist(client))
		return Plugin_Handled;
	
	ZPlayer player = ZPlayer(client);
	
	player.toggleNv(!player.bNightvisionOn);
	
	return Plugin_Handled;
}

// Extra items binds
public Action buyItems(int client, int args){
	
	ZPlayer player = ZPlayer(client);
	char sBuffer[16];
	GetCmdArg(0, sBuffer, sizeof(sBuffer));
	
	if (StrEqual(sBuffer, "item1")){
		buyExtraItem(player.id, view_as<int>(EXTRA_ITEM_ANTIDOTE));
	}
	else if (StrEqual(sBuffer, "item2")){
		buyExtraItem(player.id, view_as<int>(EXTRA_ITEM_MADNESS));
	}
	else if (StrEqual(sBuffer, "item3")){
		buyExtraItem(player.id, view_as<int>(EXTRA_ITEM_INFAMMO));
	}
	else if (StrEqual(sBuffer, "item4")){
		buyExtraItem(player.id, view_as<int>(EXTRA_ITEM_NIGHTVISION));
	}
	else if (StrEqual(sBuffer, "item5")){
		buyExtraItem(player.id, view_as<int>(EXTRA_ITEM_ARMOR));
	}
	
	return Plugin_Handled;
}

// AFK command
public Action commandAfk(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	if (!player.bAFK){
		
		if (gClientData[client].iTimesAFKed >= 1){
			PrintToChat(client, "%s Solo puedes usar este comando \x051 vez por mapa\x01.", SERVERSTRING);
			return Plugin_Handled;
		}
		
		leaveParty(client, 0);
		
		saveCharacterData(client);
		
		charactersLevels[client].Set(player.iPjEnMenu, player.iLevel);
		charactersResets[client].Set(player.iPjEnMenu, player.iReset);
		//charactersNames[client].SetString(player.iPjSeleccionado, name);
		
		
		gClientData[client].iTimesAFKed++;
		player.bAFK = true;
		
		if (player.bAlive){
			ForcePlayerSuicide(client);
		}
	
		player.bInGame = false;		
		RequestFrame(MoveToSpectator, client);
		
		PrintToChatAll("%s \x04%N\x01 está ahora AFK.", SERVERSTRING, client);
		
		RoundEndOnClientDisconnect();
	}
	else{
		showMainMenu(client, 0);
	}
	
	return Plugin_Handled;
}

// Promo codes command
public Action commandPromoCode(int client, int args){
	
	char code[32];
	GetCmdArg(1, code, sizeof(code));
	
	if(gServerData.DBI == null)
		return Plugin_Handled;
	
	ZPlayer player = ZPlayer(client);
	if (!player.bLogged || !player.bInGame)
		return Plugin_Handled;
	
	PromoCodeOnCheckExistance(client, code);
	
	return Plugin_Handled;
}

// MySQL data check
void PromoCodeOnCheckExistance(int client, char code[32]){
	
	bool invalid = false;
	
	for (int i = 0; i < sizeof(code); i++){
		
		if (code[i] == ' ' || code[i] == '*' || code[i] == '(' || code[i] == ')'){
			invalid = true;
			break;
		}
	}
	
	if (invalid){
		PrintToConsole(client, "[PIU] Este código no es válido.");
		PrintToChat(client, "%s Este código no es válido.", SERVERSTRING);
		return;
	}
	
	static char scapedCode[64];
	gServerData.DBI.Escape(code, scapedCode, sizeof(scapedCode));
	
	char query[256];
	FormatEx(query, sizeof(query), "SELECT `id`, `piupoints`, `used` FROM `promo_codes` WHERE `code`='%s'", scapedCode);
	gServerData.DBI.Query(PromoCodeOnCheckCallback, query, client, DBPrio_Low);
}
public void PromoCodeOnCheckCallback(Database db, DBResultSet results, const char[] error, any data){
	
	if(results == null) {
		PrintToConsole(data, "[PIU] Se produjo un error al verificar el código.");
		PrintToChat(data, "%s Se produjo un error al verificar el código.", SERVERSTRING);
		return;
	}
	
	if(!results.RowCount){
		PrintToConsole(data, "[PIU] Este código no existe.");
		PrintToChat(data, "%s Este código no existe.", SERVERSTRING);
		return;
	}
	
	// Initialize variables
	int id;
	int piuPoints;
	bool used;
	
	while(results.FetchRow()){
		id = results.FetchInt(0);
		piuPoints = results.FetchInt(1);
		used = view_as<bool>(results.FetchInt(2));
	}
	
	if (used){
		PrintToConsole(data, "[PIU] Este código ya fue utilizado.");
		PrintToChat(data, "%s Este código ya fue utilizado.", SERVERSTRING);
		return;
	}
	else{
		
		ZPlayer player = ZPlayer(data);
		player.iPiuPoints += piuPoints;
		PrintToConsole(data, "[PIU] FELICITACIONES! Reclamaste %d PIU-POINTS!", piuPoints);
		PrintToChat(data, "%s FELICITACIONES! Reclamaste \x09%d PIU-POINTS\x01!", SERVERSTRING, piuPoints);
		
		char query[128];
		FormatEx(query, sizeof(query), "UPDATE promo_codes SET used = 1, redeemer = %d WHERE id = %d", player.iPjSeleccionado, id, DBPrio_Low);
		
		gServerData.DBI.Query(DoNothingCallback, query, data);
	}
}

/* "CREATE TABLE IF NOT EXISTS `promo_codes` (`id` int(32) NOT NULL AUTO_INCREMENT, \
							`code` varchar(64) NOT NULL, \
							`piupoints` int(32) NOT NULL DEFAULT 0, \
							`used` int(32) NOT NULL DEFAULT 0, \
							`redeemer` int(32), \
							PRIMARY KEY (`id`), \
							UNIQUE KEY `code_UNIQUE` (`code`), \
							FOREIGN KEY (`redeemer`) REFERENCES characters(`id`));"
  							KEY `fk_PromoCodes_idx` (`idPlayer`)
*/

public bool FilterStuck(int client, int contentsMask, any victim){
	return (client != victim);
}

public Action TeamMenuCmd(int client, const char[] command, int args){
	
	showMainMenu(client, 0);
	return Plugin_Handled;
}

public Action OnClientCommandKeyValues(int client, KeyValues kv){
	
	char sCmd[64];
	
	if (kv.GetSectionName(sCmd, sizeof(sCmd)) && StrEqual(sCmd, "ClanTagChanged", false)){
		
		ZPlayer player = ZPlayer(client);
		
		if (!player.bCanChangeName)
			return Plugin_Handled;
	}
	
	return Plugin_Continue;
}
//=====================================================
//					ROUND EVENTS
//=====================================================
void BalanceTeams(int team = -1){
	int nPlayers = fnGetPlaying();
	
	if (!nPlayers){
		return;
	}
	
	ZPlayer player;
	for (int i = 1; i <= MaxClients; i++){
		player = ZPlayer(i);
		
		if(!IsPlayerExist(player.id, false))
			continue;
		
		if (!IsFakeClient(i)){
			if(!player.bInGame)
				continue;
		
			if (!player.bLogged)
				continue;
		}
		
		if (team < 0)
			player.iTeamNum = !(i % 2) ? CS_TEAM_CT : CS_TEAM_T;
		else
			player.iTeamNum = team;
	}
}


// Called when gamemode stats detects round end
void GamemodesStats_OnRoundEnd(bool zombies = false){
	
	if (ActualMode.is(MODE_SWARM) || ActualMode.is(MODE_PLAGUE) || ActualMode.is(MODE_APOCALYPSIS) || ActualMode.is(MODE_ARMAGEDDON) || ActualMode.is(MODE_SYNAPSIS)){
		
		GamemodesStats_applyModesRewards(zombies);
		
		if (hModeStats!= null){
			delete hModeStats;
		}
	}
}

// When swarm round ends, give stacked rewards
void GamemodesStats_applyModesRewards(bool zombies = false){
	
	if (zombies){
		if (ModesZombies.Length > 0){
			int value;
			ZPlayer player;
			for (int i; i < ModesZombies.Length; i++){
				
				if (!IsPlayerExist(i))
					continue;
				
				player = ZPlayer(ModesZombies.Get(i));
				value = player.applyGain(iModesZombieRewards/ModesZombies.Length);
				TranslationPrintToChat(player.id, "Swarm zombie reward", value);
			}
		}
	}
	else{
		if (ModesHumans.Length > 0){
			int value;
			ZPlayer player;
			for (int i; i < ModesHumans.Length; i++){
				
				if (!IsPlayerExist(i))
					continue;
				
				player = ZPlayer(ModesHumans.Get(i));
				value = player.applyGain(iModesHumanRewards/ModesHumans.Length);
				TranslationPrintToChat(i, "Swarm human reward", value);
			}
		}
	}
	
	GamemodesStats_purgeModesData();
}

/*
public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason){
	
	// Save everyone's data
	DataBaseOnSaveAllData();
	
	return Plugin_Continue;
}*/

// Server announcements
stock void SendAnnouncement(){
	
	// Don't disturb players if warmup didn't end
	if (bWarmupStarted && !bWarmupEnded)
		return;
	
	// Initialize randomization
	int number = GetRandomInt(1, 8);
	
	// Initialize info buffer
	char sBuffer[128];
	
	FormatEx(sBuffer, sizeof(sBuffer), "Registered message %d", number);
	
	PrintToServer(sBuffer);
	
	// Print the announcement
	PrintToChatAll(" \x03 --------------------------");
	TranslationPrintToChatAll(sBuffer);
	PrintToChatAll(" \x03 --------------------------");
}

// Used to announce and start votemap
public void StartMapVote(){
	
	InitiateMapChooserVote(MapChange_RoundEnd);
	TranslationPrintToChatAll("Starting map vote");
}

//=====================================================
//					PLAYER HOOKS
//=====================================================

int obtainBaseProfitPerKill(int attackerLevel, int victimLevel){
	
	int diff = attackerLevel - victimLevel;
	int value = attackerLevel * KILL_SCALAR_REWARD;
	
	if (diff < 0) value += AbsValue(diff) * (KILL_SCALAR_REWARD / 2);
	
	return KILL_BASE_REWARD + value;
}

public Action ForceDropChest(int client, int args){
	ZPlayer id = ZPlayer(client);
	
	if (!id.bStaff)
	return Plugin_Handled;
	
	float origin[3];
	GetEntPropVector(id.id, Prop_Send, "m_vecOrigin", origin);
	origin[0] += 40;
	
	int chestId = CreateChest(id.id, origin);
	CreateTimer(CHEST_TIME_DISAPPEAR, DeleteChest, EntIndexToEntRef(chestId), TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Handled;
}

//=====================================================
//					HUD FUNCTIONS
//=====================================================
public void hideHUD(int client){
	
	if(IsPlayerExist(client)){
		//SetEntProp(player.id, Prop_Send, "m_iHideHUD", HIDEHUD_RADARANDTIMER);
		SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDEHUD_CSGO_RADAR);
	}
}

void formatHUD(int client, char[] buffer, int maxlen, bool bSpec = false){
	ZPlayer player = ZPlayer(client);
	
	// Parse variables
	char sPointed1[24];
	char sPointed2[24];
	char sPointed3[24];
	char sPointed4[24];
	int restantes = (NextLevel(player.iLevel, player.iReset)-player.iExp);
	
	if(restantes < 0 || player.iLevel >= RESET_LEVEL) restantes = 0;
	
	// Add "." to the numbers
	AddPoints(player.iHp, sPointed1, sizeof(sPointed1));
	AddPoints(player.iArmor, sPointed2, sizeof(sPointed2));
	AddPoints(player.iExp, sPointed3, sizeof(sPointed3));
	AddPoints(restantes, sPointed4, sizeof(sPointed4));
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	// Ending
	char sEnding[64];
	if (player.isType(PT_HUMAN) || player.isType(PT_ZOMBIE)){
		static char sClassname[32];
		static char sAlineacion[32];
		if (player.isType(PT_HUMAN)){
			HClass class;
			HClasses.GetArray(player.iHumanClass, class);
			strcopy(sClassname, sizeof(sClassname), class.name);

			HAlignment alignment;
			HAlignments.GetArray(player.iHumanAlignment, alignment);
			strcopy(sAlineacion, sizeof(sAlineacion), alignment.name);
		}
		else{
			ZClass class;
			ZClasses.GetArray(player.iZombieClass, class);
			strcopy(sClassname, sizeof(sClassname), class.name);
			
			ZAlignment alignment;
			ZAlignments.GetArray(player.iZombieAlignment, alignment);
			strcopy(sAlineacion, sizeof(sAlineacion), alignment.name);
		}
		FormatEx(sEnding, sizeof(sEnding), "%t", "Personal HUD ending complete", sClassname, sAlineacion);
	}
	else{
		// Calculate his type
		char sType[24];
		if (player.isBoss(true) || player.isBoss(false)){
			ZBoss boss;
			ZBosses.GetArray(GetBossIndex(player.iType), boss);
			
			boss.GetName(sType, sizeof(sType));
		}
		else{
			if (player.isHuman())
				sType = "Humano";
			else if (player.isZombie())
				sType = "Zombie";
		}
		
		FormatEx(sEnding, sizeof(sEnding), "%t", "Personal HUD ending partial", sType);
	}
	
	int percentage = ((player.iLevel >= RESET_LEVEL) ? 100 : ((player.iExp-NextLevel(player.iLevel-1, player.iReset))*100)/(NextLevel(player.iLevel, player.iReset)-NextLevel(player.iLevel-1, player.iReset)));
	
	char sSpec[16];
	if (bSpec) 	FormatEx(sSpec, sizeof(sSpec), "%t", "Spectating");
	
	// Party or single HUD
	if (gClientData[client].bInParty){
		
		char sPartyInfo[512];
		int ptId = findPartyByUID(gClientData[client].iPartyUID);
		ZParty pt = ZParty(ptId);
		
		if(ptId >= 0){
			
			ZPlayer ptPlayer;
			char sName[48];
			
			for(int i; i < pt.length(); i++){
				//ptPlayer = ZPlayer(gPartyMembers[pt.id].Get(i));
				ptPlayer = ZPlayer(pt.getMemberByArrayId(i));
				
				if (!IsPlayerExist(ptPlayer.id))
					continue;
				
				GetClientName(ptPlayer.id, sName, sizeof(sName));
				
				// Format the hud
				char sTemp[128];
				FormatEx(sTemp, sizeof(sTemp), "\n%s - %s (Level %d)", sName, ptPlayer.iTeamNum == CS_TEAM_T ? "Zombie" : "Humano", ptPlayer.iLevel);
				StrCat(sPartyInfo, sizeof(sPartyInfo), sTemp);
				//FormatEx(sPartyInfo, sizeof(sPartyInfo), "\n%s", sTemp);
				
			}
			
			FormatEx(buffer, maxlen, "%s%t\n%s%s\n", sSpec, "Personal HUD beginning",
				sPointed1, sPointed2, sPointed3, sPointed4, player.iLevel, (percentage >= 1) ? percentage : 1, player.iReset, sEnding, sPartyInfo);
		}
		
	}
	else{
		Format(buffer, maxlen, "%s%t\n%s\n", sSpec, "Personal HUD beginning",
			sPointed1, sPointed2, sPointed3, sPointed4, player.iLevel, (percentage >= 1) ? percentage : 1, player.iReset, sEnding);
	}
	ReplaceString(buffer, maxlen, "PCT", "%%", true);
}

public Action PrintMsg(Handle timer, int client){
	
	ZPlayer player = ZPlayer(client);
	
	if(!IsPlayerExist(client)){
		player.hHudTimer = null;
		return Plugin_Stop;
	}
	
	// Hide CSGO HUD
	hideHUD(client);
	
	if(IsFakeClient(client))
		return Plugin_Continue;
	
	/*if(!player.bInGame)
		return Plugin_Continue;*/
	
	// Is our player spectating someone?
	int iSpecMode = GetEntProp(client, Prop_Send, "m_iObserverMode");
	
	// Initialize message string
	char msg[2600];
	
	// Parse data in both cases
	if (player.bAlive){
		// Format the HUD
		formatHUD(player.id, msg, sizeof(msg), false);
	}
	else if (iSpecMode == SPECMODE_FIRSTPERSON || iSpecMode == SPECMODE_3RDPERSON){
		int iTarget = GetEntPropEnt(player.id, Prop_Send, "m_hObserverTarget");
		
		if (!IsPlayerExist(iTarget, true))
			return Plugin_Handled;
		
		formatHUD(iTarget, msg, sizeof(msg), true);
	}
	else return Plugin_Continue;
	
	// Show hud message
	SetHudTextParams(0.01, 0.01, 0.6, iHudColors[player.iHudColor][0], iHudColors[player.iHudColor][1], iHudColors[player.iHudColor][2], 255, 1, 0.2, 0.8, 0.4);
	ShowSyncHudText(player.id, hHudSynchronizer, msg);
	
	return Plugin_Continue;
}

public Action respawnPlayer(Handle timer, int client){
	//PrintToServer("Starting respawnPlayer()");
	
	if (gServerData.RoundEnd){
		return Plugin_Stop;
	}
	
	if (!IsPlayerExist(client)){
		return Plugin_Stop;
	}
	
	// If current mode doens't allow respawn
	if (!ActualMode.bRespawn){
		return Plugin_Stop;
	}
	
	ZPlayer player = ZPlayer(client);
	
	// If he isn't a bot and he isn't connected or logged
	if (!IsFakeClient(client)){
		if (!player.bLogged || !player.bInGame){
			PrintToServer("Player %d not ingame/logged", player.id);
			return Plugin_Stop;
		}
	}
	
	// If warmup
	if (ActualMode.is(MODE_WARMUP)){
		WarmUpRespawnPlayer(client);
		return Plugin_Stop;
	}
	
	if (ActualMode.is(MODE_HORDE)){
		if (IsFakeClient(client)){
			player.iRespawnPlayer(true);
		}
		else{
			player.iRespawnPlayer(false);
		}
	}
	
	// If its event mode
	if (eventmode){
		player.iRespawnPlayer(true);
		player.TurnInto(PT_ASSASSIN);
		return Plugin_Stop;
	}
	
	// If round didn't start yet
	if (gServerData.RoundNew){
		player.iRespawnPlayer(false);
		return Plugin_Stop;
	}
	else{ // round has started
		// If he is the only valid player or respawn is zombie only
		if(ActualMode.bRespawnZombieOnly || GetValidPlayingHumans() == 1){
			player.iRespawnPlayer(true);
		}
		// If there's no human alive
		else if (!fnGetAliveInTeam(CS_TEAM_CT)){
			player.iRespawnPlayer(false);
		}
		else { // Mode accepts respawning as human if lucky
			
			// Count zombies
			int zombies = fnGetZombies();
			
			// Count alive
			int alive = fnGetAlive();
			
			// If zombies are more than 2/3 of alive
			if(zombies > (alive*2/3)) {
				
				// Roll the chance
				int chance = GetRandomInt(1, 100);
				
				// If lucky respawn human
				if(chance <= CHANCE_TO_RESPAWN_HUMAN){
					player.iRespawnPlayer();
					makeHumanInvisible(client);
				}
				else player.iRespawnPlayer(true); // respawn zombie
			}
			else player.iRespawnPlayer(true); // respawn zombie
		}
	}
	return Plugin_Stop;
}

// STAFF CMDS
public void makeHumanInvisible(int client){
	
	ZPlayer player = ZPlayer(client);
	
	if (!player.isHuman())
		return;
	
	player.bInvulnerable = true;
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, 255, 255, 255, 0);
	
	int iHat = EntRefToEntIndex(player.iHatRef);
	if (IsValidEntity(iHat)){
		SetEntityRenderMode(iHat, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iHat, 255, 255, 255, 0);
	}
	CreateTimer(10.0, makeHumanVisible, client);
}
public Action makeHumanVisible(Handle timer, int client){

	ZPlayer player = ZPlayer(client);
	player.bInvulnerable = false;

	if(!IsPlayerExist(client, true))
		return Plugin_Stop;
	
	SetEntityRenderMode(client, RENDER_NORMAL);
	SetEntityRenderColor(client, 255, 255, 255, 255);
	
	if (player.iHatRef != INVALID_ENT_REFERENCE && player.iHatRef != -1){
		SetEntityRenderMode(player.iHatRef, RENDER_NORMAL);
		SetEntityRenderColor(player.iHatRef, 255, 255, 255, 255);
	}
	
	return Plugin_Handled;
}

// VIP CHAT
public Action printVipSay(int client, char[] text, int maxlen){
	ZPlayer player = ZPlayer(client);
	
	if (!player.bVip && !player.bStaff && !player.bAdmin)
		return Plugin_Handled;
	
	char name[64];
	GetClientName(player.id, name, sizeof(name));
	
	ReplaceString(name, sizeof(name), "%", "", false);
	ReplaceString(text, VIP_SAY_MAXLEN, "%", "%%", false);
	
	char msg[VIP_SAY_MAXLEN];
	if (player.bStaff)
		FormatEx(msg, maxlen, "STAFF %s: %s", name, text);
	else
		FormatEx(msg, maxlen, "%s %s: %s", player.bAdmin ? "[MOD]" : "", name, text);
	
	Handle hRotativeSynchronizer = CreateHudSynchronizer();
	
	float value;
	switch (GetRandomInt(0, 9)){
		case 0: value = 0.37;
		case 1: value = 0.40;
		case 2: value = 0.43;
		case 3: value = 0.46;
		case 4: value = 0.49;
		case 5: value = 0.52;
		case 6: value = 0.55;
		case 7: value = 0.58;
		case 8: value = 0.61;
		case 9: value = 0.64;
	}
	
	// Show hud message
	SetHudTextParams(0.03, value, VIP_SAY_DURATION, GetRandomInt(80, 255), GetRandomInt(80, 255), GetRandomInt(80, 255), 255, 1, 3.0, 0.4, 0.4);
	
	for (int i = 1; i <= MaxClients; i++){
		ZPlayer puto = ZPlayer(i);
		
		if (!IsPlayerExist(puto.id))
			continue;
		
		ShowSyncHudText(puto.id, hRotativeSynchronizer, msg);
		PrintToConsole(puto.id,"[VIP SAY] %s", msg);
	}
	//CloseHandle(hRotativeSynchronizer);
	delete hRotativeSynchronizer;
	return Plugin_Handled;
}

//=====================================================
//				USER CONFIGS FUNCTIONS
//=====================================================
public Action muteHurtSounds(int client, any args){
	ZPlayer player = ZPlayer(client);
	player.bHearHurtSounds = !player.bHearHurtSounds;
	TranslationPrintToChat(player.id, player.bHearHurtSounds ? "Silence hurt sounds disabled" : "Silence hurt sounds enabled");
}
public Action muteBullets(int client, any args){
	ZPlayer player = ZPlayer(client);
	player.bStopSound = !player.bStopSound;
	TranslationPrintToChat(player.id, player.bStopSound ? "Silence shots enabled" : "Silence shots disabled");
}
public Action autopBuy(int client){
	ZPlayer player = ZPlayer(client);
	player.bAutoWeaponUpgrade = !player.bAutoWeaponUpgrade;
	TranslationPrintToChat(player.id, player.bAutoWeaponUpgrade ? "Weapon auto upgrade enabled" : "Weapon auto upgrade disabled");
}
public Action autogBuy(int client){
	ZPlayer player = ZPlayer(client);
	player.bAutoGrenadeUpgrade = !player.bAutoGrenadeUpgrade;
	TranslationPrintToChat(player.id, player.bAutoGrenadeUpgrade ? "Grenade pack auto upgrade enabled" : "Grenade pack auto upgrade disabled");
}
public Action autozClass(int client){
	ZPlayer player = ZPlayer(client);
	player.bAutoZClass = !player.bAutoZClass;
	TranslationPrintToChat(player.id, player.bAutoZClass ? "Zombie class auto upgrade enabled" : "Zombie class auto upgrade disabled");
}
public Action NormalSoundHook(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags){
	
	//PrintToChatAll("Sample is: %s", sample);
	
	/*
	if (StrContains(sample, "headshot", false) != -1)
		return Plugin_Handled;
	
	// Ignore non-weapon sounds.
	if (!(strncmp(sample, "weapons", 7) == 0 || strncmp(sample[1], "weapons", 7) == 0))
		return Plugin_Continue;*/
		
	if (IsValidEdict(entity)){
		
		if (StrContains(sample, "player/kevlar") != -1 
		|| StrContains(sample, "physics/flesh") != -1 
		|| StrContains(sample, "player/headshot") != -1){
			return Plugin_Changed;
		}
		
		
		if (StrContains(sample, "weapons") != -1){
			
			int i, j;
			for (i = 0; i < numClients; i++){
				
				if (gClientData[clients[i]].bStopSound){
					// Remove the client from the array.
					for (j = i; j < numClients-1; j++){
						clients[j] = clients[j+1];
					}
					
					numClients--;
					i--;
				}
			}
		}
	}
	
	return (numClients > 0) ? Plugin_Changed : Plugin_Stop;
}

//=====================================================
//				RANDOM GAMEMODE
//=====================================================
/*int CalculateModeByChances(){
	
	if (modeCount > MAX_SIMPLE_MODES_IN_A_ROW && bAllowGain){
		modeCount = 0;
		return GetRandomInt(view_as<int>(MODE_SWARM), view_as<int>(MODE_APOCALYPSIS));
	}
	else if (modeCount <= 0){
		return GetRandomInt(view_as<int>(MODE_INFECTION), view_as<int>(MODE_MASSIVE_INFECTION));
	}
	
	int modes[GameModes];
	int modesCount;
	for (int i = view_as<int>(MODE_INFECTION); i < gModeName.Length-1; i++){
		ZGameMode mode = ZGameMode(i);
		
		if (mode.iProbability <= 0)
			continue;
		
		if (lastMode == mode.id || mode.id > view_as<int>(MODE_ANIHHILATION))
			continue;
		
		if (fnGetAlive() < mode.iMinUsers)
			continue;
		
		if (GetRandomInt(1, 100) > mode.iProbability)
			continue;
		
		modes[modesCount++] = i;
	}
	return (modesCount == 0) ? view_as<int>(MODE_INFECTION) : modes[GetRandomInt(0, modesCount-1)];
}*/

int CalculateModeByChances(){
	
	int random = GetRandomInt(1, iTotalProbabilities);
	
	#if defined DEBUG_GAMEMODES
	LogToFile("addons/sourcemod/logs/DEBUG_MODES.txt", " ");
	LogToFile("addons/sourcemod/logs/DEBUG_MODES.txt", "-----------------------------");
	LogToFile("addons/sourcemod/logs/DEBUG_MODES.txt", "[MODES] Random value is %d", random);
	LogToFile("addons/sourcemod/logs/DEBUG_MODES.txt", "------------------------------");
	LogToFile("addons/sourcemod/logs/DEBUG_MODES.txt", " ");
	#endif
	
	ZGameMode premode;
	ZGameMode actualmode;
	
	int value = GetRandomInt(view_as<int>(MODE_INFECTION), view_as<int>(MODE_ANIHHILATION));
	
	if (fnGetPlaying(true) < 4){
		value = view_as<int>(MODE_INFECTION);
	}
	
	for (int i = view_as<int>(MODE_INFECTION)+1; i <= ZGameModes.Length-1; i++){
		
		ZGameModes.GetArray(i, actualmode);
		
		if (!actualmode.probability) continue;
		
		ZGameModes.GetArray(i-1, premode);
		
		if (i == view_as<int>(MODE_INFECTION) && random > 0 && random <= premode.probability){
			
			value = i;
			PrintToServer("[MODES] Value is %i", value);
			//LogToFile("DEBUG_MODES.txt", "[MODES] First IF, value is %i", value);
			break;
		}
		else if (random > premode.probability && random <= actualmode.probability){
			
			if (fnGetPlaying(true) < actualmode.minUsers){
				#if defined DEBUG_GAMEMODES
				LogToFile("addons/sourcemod/logs/DEBUG_MODES.txt", "[MODES] Second IF, value is %i, low amount of users", value);
				#endif
				break;
			}
			
			value = i;
			PrintToServer("[MODES] Value is %i", value);
			//LogToFile("DEBUG_MODES.txt", "[MODES] Second IF, value is %i, premode.prob = %d, actualmode.prob = %d", value, premode.probability, actualmode.probability);
			break;
		}
	}
	
	char sname[32];
	ZGameModes.GetArray(value, actualmode);
	actualmode.GetName(sname, sizeof(sname));

	#if defined DEBUG_GAMEMODES
	LogToFile("addons/sourcemod/logs/DEBUG_MODES.txt", " ");
	LogToFile("addons/sourcemod/logs/DEBUG_MODES.txt", "------------------------------");
	LogToFile("addons/sourcemod/logs/DEBUG_MODES.txt", "[MODES] Loop ended, selected mode is %s", sname);
	LogToFile("addons/sourcemod/logs/DEBUG_MODES.txt", "------------------------------");
	LogToFile("addons/sourcemod/logs/DEBUG_MODES.txt", " ");
	#endif
	
	return value;
}
void StartMode(int mode, int client = 0, bool bypass = false){
	
	if (!gServerData.RoundNew){
		//PrintToChatAll("ROUNDNEW IS FALSE");
		return;
	}
	
	int nAlive = fnGetAlive();
	
	ZGameMode modeCheckVar;
	ZGameModes.GetArray(mode, modeCheckVar);
	
	// Check if the quantity of users reaches the minimum
	if (!bypass){
		if (!nAlive){
			PrintToServer("[StartMode] No hay usuarios suficientes para iniciar modos.");
			PrintToServer("[StartMode] Iniciando modo de espera de usuarios.");
			//LogError("[StartMode] No hay usuarios suficientes para iniciar algún modo.");
			
			// Initialize mode vars
			ZGameModes.GetArray(view_as<int>(IN_WAIT), ActualMode);
			
			// Initialize booleans
			gServerData.RoundNew = false;
			gServerData.RoundEnd = false;
			gServerData.RoundStart = true;
			return;
		}
		else if (nAlive < modeCheckVar.minUsers){
			StartMode(view_as<int>(MODE_INFECTION));
			return;
		}
	}
	
	// Initialize mode vars
	ZGameModes.GetArray(mode, ActualMode);
	
	// Update serverdata variable
	gServerData.RoundMode = mode;
	
	// Initialize max amount of zombies
	int nMaxZombies;
	
	// Initialize booleans
	gServerData.RoundNew = false;
	gServerData.RoundEnd = false;
	gServerData.RoundStart = true;
	
	float volume = 0.2;
	
	// Get mode name
	char name[32];
	ActualMode.GetName(name, sizeof(name));
	
	CreateFog();
	switchFog(false);
	
	mapFogEnd = 1800.0;
	mapFogDensity = 0.90;
	
	switch(mode){
		case MODE_WARMUP:{
			StartWarmup();
		}
		case MODE_HORDE:{
			
			ZPlayer p;
			for (int i = 1; i <= MaxClients; i++){
				
				if (!IsPlayerExist(i, true)){
					continue;
				}
				
				if (!IsFakeClient(i)){
					continue;
				}
				
				p = ZPlayer(i);
				
				p.Zombiefy();
			}
			
			int colors1[4];
			colors1[0] = 20;
			colors1[1] = 20;
			colors1[2] = 255;
			colors1[3] = 255;
			
			TranslationPrintHudTextAll(gServerData.GameSync, -1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, colors1[0], colors1[1], colors1[2], colors1[3], 1, 1.0, 1.0, 1.0, "Horde mode");
		}
		case MODE_INFECTION:{
			
			ZPlayer zombie = ZPlayer(IsPlayerExist(client) ? client : GetRandomUser(PT_HUMAN));
			
			if (view_as<int>(zombie) < 1)
			return;
			
			zombie.Zombiefy(true);
			
			int colors1[4];
			colors1[0] = 0;
			colors1[1] = 255;
			colors1[2] = 0;
			colors1[3] = 255;
			
			//ShowSyncHudTextAll(/*0.425*/-1.0, 0.20, 3.0, colors1, colors2, 1, 1.0, 1.0, 1.0, gServerData.GameSync, sData);
			char sName[48];
			GetClientName(zombie.id, sName, sizeof(sName));
			TranslationPrintHudTextAll(gServerData.GameSync, -1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, colors1[0], colors1[1], colors1[2], colors1[3], 1, 1.0, 1.0, 1.0, "Someone is infected", sName);
			
			EmitSoundToAll(AMBIENT_SOUND, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_, volume);
			
			int sound = GetRandomInt(0, sizeof(InfectionSounds)-1);
			EmitSoundToAll(InfectionSounds[sound], SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, 0.5);
		}
		case MODE_MULTIPLE_INFECTION:{
			nMaxZombies = RoundToCeil(nAlive / 5.0);
			GameModesTurnIntoZombie(nMaxZombies, PT_ZOMBIE);
			EmitSoundToAll(AMBIENT_SOUND, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_, volume);
			
			int colors1[4];
			colors1[0] = 0;
			colors1[1] = 255;
			colors1[2] = 0;
			colors1[3] = 255;
			
			char sData[32];
			FormatEx(sData, sizeof(sData), "%s", name);
			ShowSyncHudTextAll(/*0.425*/-1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, colors1, colors1, 1, 1.0, 1.0, 1.0, gServerData.GameSync, sData);
			//TranslationPrintHudTextAll(gServerData.GameSync, -1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, colors1[0], colors1[1], colors1[2], colors1[3], 1, 1.0, 1.0, 1.0, sData);
		}
		case MODE_ANIHHILATION:{
			
			ZPlayer zombie = ZPlayer(IsPlayerExist(client) ? client : GetRandomUser(PT_HUMAN));
			
			if (view_as<int>(zombie) < 1)
			return;
			
			zombie.Zombiefy(true);
			
			int colors1[4];
			colors1[0] = 0;
			colors1[1] = 255;
			colors1[2] = 0;
			colors1[3] = 255;
			
			//ShowSyncHudTextAll(/*0.425*/-1.0, 0.20, 3.0, colors1, colors2, 1, 1.0, 1.0, 1.0, gServerData.GameSync, sData);
			char sName[48];
			GetClientName(zombie.id, sName, sizeof(sName));
			TranslationPrintHudTextAll(gServerData.GameSync, -1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, colors1[0], colors1[1], colors1[2], colors1[3], 1, 1.0, 1.0, 1.0, "Anihhilation someone is infected", sName);
			
			EmitSoundToAll(AMBIENT_SOUND_SWARM, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_,  volume);
			
			int sound = GetRandomInt(0, sizeof(InfectionSounds)-1);
			EmitSoundToAll(InfectionSounds[sound], SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, 0.5);
		}
		case MODE_MASSIVE_INFECTION:{
			nMaxZombies = RoundToFloor(nAlive / 3.0);
			GameModesTurnIntoZombie(nMaxZombies, PT_ZOMBIE);
			EmitSoundToAll(AMBIENT_SOUND_SWARM, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_,  volume);
			
			int colors1[4];
			colors1[0] = 20;
			colors1[1] = 255;
			colors1[2] = 20;
			colors1[3] = 255;
			
			char sData[32];
			FormatEx(sData, sizeof(sData), "%s", name);
			ShowSyncHudTextAll(/*0.425*/-1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, colors1, colors1, 1, 1.0, 1.0, 1.0, gServerData.GameSync, sData);
		}
		case MODE_SWARM:{
			
			nMaxZombies = RoundToCeil(fnGetHumans() / 2.0);
			GameModesTurnIntoZombie(nMaxZombies, PT_ZOMBIE);
			
			EmitSoundToAll(MODE_SWARM_SOUND, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
			EmitSoundToAll(AMBIENT_SOUND_INFECTION, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_,  volume);
			
			int colors1[4];
			colors1[0] = 255;
			colors1[1] = 20;
			colors1[2] = 20;
			colors1[3] = 255;
			printModeHudAnnouncer(name, colors1, gServerData.GameSync, "Mode");
			
			ModeStats_StartDetection();
		}
		case MODE_PLAGUE:{
			EmitSoundToAll(MODE_SWARM_SOUND, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
			EmitSoundToAll(AMBIENT_SOUND_INFECTION, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_,  volume);
			
			nMaxZombies = RoundToCeil(nAlive / 2.0);
			GameModesTurnIntoZombie(nMaxZombies-1, PT_ZOMBIE);
			
			ZPlayer target1 = ZPlayer(GetRandomUser(PT_HUMAN));
			target1.TurnInto(PT_SURVIVOR);
			
			ZPlayer target2 = ZPlayer(GetRandomUser(PT_HUMAN));
			target2.TurnInto(PT_NEMESIS, true);
			
			int colors1[4];
			colors1[0] = 80;
			colors1[1] = 255;
			colors1[2] = 80;
			colors1[3] = 255;
			
			printModeHudAnnouncer(name, colors1, gServerData.GameSync, "Mode");
			
			ModeStats_StartDetection();
		}
		case MODE_NEMESIS:{
			EmitSoundToAll(MODE_NEMESIS_SOUND, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
			
			ZPlayer nemesis = ZPlayer(IsPlayerExist(client) ? client : GetRandomUserNoBots(PT_HUMAN, false));
			
			if (view_as<int>(nemesis) < 1)
				return;
			
			nemesis.TurnInto(PT_NEMESIS, true);
			
			int colors1[4];
			colors1[0] = 255;
			colors1[1] = 20;
			colors1[2] = 20;
			colors1[3] = 255;
			
			//ShowSyncHudTextAll(/*0.425*/-1.0, 0.20, 3.0, colors1, colors2, 1, 1.0, 1.0, 1.0, gServerData.GameSync, sData);
			char sName[48];
			GetClientName(nemesis.id, sName, sizeof(sName));
			TranslationPrintHudTextAll(gServerData.GameSync, -1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, colors1[0], colors1[1], colors1[2], colors1[3], 1, 1.0, 1.0, 1.0, "Is a nemesis", sName);
			
			EmitSoundToAll(AMBIENT_SOUND_ZBOSS, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_,  volume);
		}
		case MODE_SURVIVOR:{
			EmitSoundToAll(MODE_SURVIVOR_SOUND, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
			ZPlayer player = ZPlayer(IsPlayerExist(client) ? client : GetRandomUserNoBots(PT_HUMAN, false));
			
			if (view_as<int>(player) < 1)
				return;
			
			player.TurnInto(PT_SURVIVOR, true);
			makeHumanInvisible(player.id);
			
			for (int i = 1; i <= MaxClients; i++){
				ZPlayer p = ZPlayer(i);
				
				if (!p.isType(PT_SURVIVOR) && IsPlayerExist(p.id, true))
				p.Zombiefy();
			}
			
			int colors1[4];
			colors1[0] = 20;
			colors1[1] = 20;
			colors1[2] = 255;
			colors1[3] = 255;
			
			//ShowSyncHudTextAll(/*0.425*/-1.0, 0.20, 3.0, colors1, colors2, 1, 1.0, 1.0, 1.0, gServerData.GameSync, sData);
			char sName[48];
			GetClientName(player.id, sName, sizeof(sName));
			TranslationPrintHudTextAll(gServerData.GameSync, -1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, colors1[0], colors1[1], colors1[2], colors1[3], 1, 1.0, 1.0, 1.0, "Is a survivor", sName);
			
			//nMaxZombies = nAlive-1;
			//GameModesTurnIntoZombie(nMaxZombies, nAlive, ZOMBIE);
			////GameModesTurnIntoHuman(1, nAlive, SURVIVOR, true);
			
			EmitSoundToAll(AMBIENT_SOUND_HBOSS, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_,  volume);
		}
		case MODE_SUPERSURVIVOR:{
			EmitSoundToAll(MODE_SURVIVOR_SOUND, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
			ZPlayer player = ZPlayer(IsPlayerExist(client) ? client : GetRandomUserNoBots(PT_HUMAN, false));
			
			if (view_as<int>(player) < 1)
				return;
			
			player.TurnInto(PT_SUPERSURVIVOR, true);
			makeHumanInvisible(player.id);
			
			ZPlayer p;
			for (int i = 1; i <= MaxClients; i++){
				p = ZPlayer(i);
				
				if (!p.isType(PT_SUPERSURVIVOR) && IsPlayerExist(p.id, true)){
					p.Zombiefy();
				}
				
			}
			
			int colors1[4];
			colors1[0] = 20;
			colors1[1] = 20;
			colors1[2] = 255;
			colors1[3] = 255;
			
			//ShowSyncHudTextAll(/*0.425*/-1.0, 0.20, 3.0, colors1, colors2, 1, 1.0, 1.0, 1.0, gServerData.GameSync, sData);
			char sName[48];
			GetClientName(player.id, sName, sizeof(sName));
			TranslationPrintHudTextAll(gServerData.GameSync, -1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, colors1[0], colors1[1], colors1[2], colors1[3], 1, 1.0, 1.0, 1.0, "Is a Super Survivor", sName);
			
			EmitSoundToAll(AMBIENT_SOUND_HBOSS, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_,  volume);
		}
		case MODE_GUNSLINGER:{
			EmitSoundToAll(MODE_SURVIVOR_SOUND, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
			ZPlayer player = ZPlayer(IsPlayerExist(client) ? client : GetRandomUserNoBots(PT_HUMAN, false));
			
			if (view_as<int>(player) < 1)
				return;
			
			player.TurnInto(PT_GUNSLINGER, true);
			makeHumanInvisible(player.id);
			
			for (int i = 1; i <= MaxClients; i++){
				
				if (!ZPlayer(i).isType(PT_GUNSLINGER) && IsPlayerExist(i, true))
					ZPlayer(i).Zombiefy();
			}
			
			int colors1[4];
			colors1[0] = 20;
			colors1[1] = 20;
			colors1[2] = 255;
			colors1[3] = 255;
			
			//ShowSyncHudTextAll(/*0.425*/-1.0, 0.20, 3.0, colors1, colors2, 1, 1.0, 1.0, 1.0, gServerData.GameSync, sData);
			
			char sName[48];
			GetClientName(player.id, sName, sizeof(sName));
			TranslationPrintHudTextAll(gServerData.GameSync, -1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, colors1[0], colors1[1], colors1[2], colors1[3], 1, 1.0, 1.0, 1.0, "Is a gunslinger", sName);
			
			EmitSoundToAll(AMBIENT_SOUND_HBOSS, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_,  volume);
		}
		case MODE_ASSASSIN:{
			EmitSoundToAll(MODE_NEMESIS_SOUND, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
			
			VAmbienceTurnOffLights();
			switchFog(true);
			
			mapFogEnd = 1200.0;
			mapFogDensity = 0.999;
			
			int colors1[4];
			colors1[0] = 255;
			colors1[1] = 20;
			colors1[2] = 20;
			colors1[3] = 255;
			
			ZPlayer assassin = ZPlayer(IsPlayerExist(client) ? client : GetRandomUserNoBots(PT_HUMAN, false));
			
			if (view_as<int>(assassin) < 1)
				return;
			
			assassin.TurnInto(PT_ASSASSIN, true);
			
			char sName[48];
			GetClientName(assassin.id, sName, sizeof(sName));
			TranslationPrintHudTextAll(gServerData.GameSync, -1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, colors1[0], colors1[1], colors1[2], colors1[3], 1, 1.0, 1.0, 1.0, "Is an assassin", sName);
			
			for (int i = 1; i <= MaxClients; i++){
				if (!IsPlayerExist(i)) continue;
				
				if (!IsPlayerExist(i, true))
					continue;
				
				if (!ZPlayer(i).isType(PT_HUMAN))
					continue;
				
				ZPlayer(i).bNightvisionOn = false;
				ZPlayer(i).bNightvision = false;
			}
			
			EmitSoundToAll(AMBIENT_SOUND_ZBOSS, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_,  volume);
		}
		case MODE_SNIPER:{
			EmitSoundToAll(MODE_SURVIVOR_SOUND, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
			ZPlayer player = ZPlayer(IsPlayerExist(client) ? client : GetRandomUserNoBots(PT_HUMAN, false));
			
			if (view_as<int>(player) < 1)
				return;
			
			player.TurnInto(PT_SNIPER, true);
			makeHumanInvisible(player.id);
			
			for (int i = 1; i <= MaxClients; i++){
				
				if (!ZPlayer(i).isType(PT_SNIPER) && IsPlayerExist(i, true))
					ZPlayer(i).Zombiefy();
			}
			
			int colors1[4];
			colors1[0] = 20;
			colors1[1] = 20;
			colors1[2] = 255;
			colors1[3] = 255;
			
			//ShowSyncHudTextAll(/*0.425*/-1.0, 0.20, 3.0, colors1, colors2, 1, 1.0, 1.0, 1.0, gServerData.GameSync, sData);
			char sName[48];
			GetClientName(player.id, sName, sizeof(sName));
			TranslationPrintHudTextAll(gServerData.GameSync, -1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, colors1[0], colors1[1], colors1[2], colors1[3], 1, 1.0, 1.0, 1.0, "Is a sniper", sName);
			
			/*nMaxZombies = nAlive-1;
			GameModesTurnIntoZombie(nMaxZombies, nAlive, ZOMBIE);*/
			////GameModesTurnIntoHuman(1, nAlive, GUNSLINGER, true);
			EmitSoundToAll(AMBIENT_SOUND_HBOSS, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_,  volume);
		}
		case MODE_CHAINSAW:{
			EmitSoundToAll(MODE_SURVIVOR_SOUND, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
			ZPlayer player = ZPlayer(IsPlayerExist(client) ? client : GetRandomUserNoBots(PT_HUMAN, false));
			
			if (view_as<int>(player) < 1)
				return;
			
			player.TurnInto(PT_CHAINSAW, true);
			makeHumanInvisible(player.id);
			
			for (int i = 1; i <= MaxClients; i++){
				
				if (!ZPlayer(i).isType(PT_CHAINSAW) && IsPlayerExist(i, true)){
					ZPlayer(i).Zombiefy();
				}
			}
			
			int colors1[4];
			colors1[0] = 20;
			colors1[1] = 20;
			colors1[2] = 255;
			colors1[3] = 255;
			
			//ShowSyncHudTextAll(/*0.425*/-1.0, 0.20, 3.0, colors1, colors2, 1, 1.0, 1.0, 1.0, gServerData.GameSync, sData);
			char sName[48];
			GetClientName(player.id, sName, sizeof(sName));
			TranslationPrintHudTextAll(gServerData.GameSync, -1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, colors1[0], colors1[1], colors1[2], colors1[3], 1, 1.0, 1.0, 1.0, "Is a chainsaw", sName);
			
			/*nMaxZombies = nAlive-1;
			GameModesTurnIntoZombie(nMaxZombies, nAlive, ZOMBIE);*/
			////GameModesTurnIntoHuman(1, nAlive, GUNSLINGER, true);
			EmitSoundToAll(AMBIENT_SOUND_HBOSS, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_,  volume);
		}
//		case MODE_FEV:{
//			EmitSoundToAll(MODE_NEMESIS_SOUND, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
//			
//			ZPlayer fev = ZPlayer(GetRandomUser(PT_HUMAN, true));
//			
//			if (view_as<int>(fev) < 1)
//				return;
//			
//			fev.TurnInto(PT_FEV);
//			
//			int colors1[4];
//			colors1[0] = 20;
//			colors1[1] = 220;
//			colors1[2] = 20;
//			colors1[3] = 255;
//			
//			int colors2[4];
//			colors2[0] = 80;
//			colors2[1] = 255;
//			colors2[2] = 80;
//			colors2[3] = 255;
//			
//			for (int i = 1; i <= MaxClients; i++){
//				if (!IsPlayerExist(i)) continue;
//				
//				// Sets the global language target
//				SetGlobalTransTarget(i);
//				
//				SetHudTextParamsEx(0.425, 0.20, 3.0, colors1, colors2, 1, 1.0, 1.0, 1.0);
//				ShowSyncHudText(i, gServerData.GameSync, "%N %t", fev.id, "Is a FEV");
//			}
//			
//			EmitSoundToAll(AMBIENT_SOUND_ZBOSS, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_,  volume);
//		}
		case MODE_SYNAPSIS:{
			nMaxZombies = (fnGetPlaying() >= 15) ? 4 : 3;
			GameModesTurnIntoZombie(nMaxZombies, PT_NEMESIS);
			GameModesTurnIntoHuman((fnGetPlaying() >= 15) ? 3 : 2, PT_SURVIVOR, true);
			EmitSoundToAll(AMBIENT_SOUND_ARMAGEDON, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_,  volume);
			
			int colors1[4];
			colors1[0] = 255;
			colors1[1] = 20;
			colors1[2] = 20;
			colors1[3] = 255;
			
			printModeHudAnnouncer(name, colors1, gServerData.GameSync, "Mode");
		}
		case MODE_MULTIPLE_NEMESIS:{
			nMaxZombies = (fnGetPlaying() >= 15) ? 3 : 2;
			GameModesTurnIntoZombie(nMaxZombies, PT_NEMESIS);
			GameModesTurnIntoHuman((fnGetPlaying() >= 15) ? 2 : 1, PT_SURVIVOR, true);
			EmitSoundToAll(AMBIENT_SOUND_ARMAGEDON, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_,  volume);
			
			int colors1[4];
			colors1[0] = 255;
			colors1[1] = 20;
			colors1[2] = 20;
			colors1[3] = 255;
			
			printModeHudAnnouncer(name, colors1, gServerData.GameSync, "Mode");
		}
		case MODE_ARMAGEDDON:{
			StartArmageddonIntro();
		}
		case MODE_APOCALYPSIS:{
			EmitSoundToAll(MODE_SWARM_SOUND, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
			nMaxZombies = RoundToCeil(nAlive / 2.0);
			int nHumans = nAlive - nMaxZombies;
			GameModesTurnIntoZombie(nMaxZombies, PT_ASSASSIN);
			GameModesTurnIntoHuman(nHumans, PT_GUNSLINGER);
			
			for (int i = 1; i <= MaxClients; i++){
				
				// Verify that the client is exist
				if(!IsPlayerExist(i, true))
					continue;
				
				// Verify that the client is human
				if(ZPlayer(i).iTeamNum != CS_TEAM_CT)
					continue;
				
				if(ZPlayer(i).isType(PT_HUMAN))	ZPlayer(i).TurnInto(PT_ASSASSIN);
			}
			
			EmitSoundToAll(AMBIENT_SOUND_ARMAGEDON, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_,  volume);
			
			int colors1[4];
			colors1[0] = 255;
			colors1[1] = 20;
			colors1[2] = 20;
			colors1[3] = 255;
			
			printModeHudAnnouncer(name, colors1, gServerData.GameSync, "Mode");
			
			ModeStats_StartDetection();
		}
		case MODE_HYPERNEMESIS:{
			
			eventmode = true;
			
			ScreenFadeAll(0.6, 0.6+0.4, FFADE_OUT, { 0, 0, 0, 255 });
			CreateTimer(0.6+0.4, ScreenFadeIn);
			
			EmitSoundToAll(MODE_NEMESIS_SOUND, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
			EmitSoundToAll(AMBIENT_SOUND_ZBOSS, SOUND_FROM_PLAYER, SNDCHAN_STATIC,_,_, 0.2);
			
			for (int i = 1; i <= MaxClients; i++){
				
				if (!IsPlayerExist(i, true))
				continue;
				
				ZPlayer user = ZPlayer(i);
				
				if (user.bStaff){
					user.TurnInto(PT_NEMESIS, true);
					user.iHp *= 20;
					VEffectSpawnEffect(user.id);
				}
				else user.TurnInto(PT_SURVIVOR);
				
				TranslationPrintToChatAll("Event mode hypernemesis");
			}
			
			CreateTimer(15.0, TurnAssassinsIntoNemesis, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			TranslationPrintToChatAll("Assassins into nemesis");
			
			int colors1[4];
			colors1[0] = 0;
			colors1[1] = 255;
			colors1[2] = 0;
			colors1[3] = 255;
			
			printModeHudAnnouncer(name, colors1, gServerData.GameSync, "Event mode HUD", true);
		}
		case MODE_PANDEMIC:{
			eventmode = true;
			
			ScreenFadeAll(0.6, 0.6+0.4, FFADE_OUT, { 0, 0, 0, 255 });
			CreateTimer(0.6+0.4, ScreenFadeIn);
			
			EmitSoundToAll(MODE_NEMESIS_SOUND, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
			EmitSoundToAll(AMBIENT_SOUND_ZBOSS, SOUND_FROM_PLAYER, SNDCHAN_STATIC,_,_, 0.2);
			
			for (int i = 1; i <= MaxClients; i++){
				ZPlayer user = ZPlayer(i);
				
				if (!IsPlayerExist(user.id, true))
					continue;
				
				user.TurnInto(PT_SURVIVOR);
				
				/*
				if (user.bStaff){
					user.Zombiefy(true);
					user.iHp *= 20;
					
					SetEntityRenderMode(user.id, RENDER_TRANSCOLOR);
					SetEntityRenderColor(user.id, 0, 120, 255, 35);
				}*/
			}
			
			TranslationPrintToChatAll("Event mode pandemic");
			
			int iPandemicTimer1 = 20;
			CreateTimer(float(iPandemicTimer1), TransformRandomIntoAssassin, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			CreateTimer(float(iPandemicTimer1), TransformRandomIntoAssassin, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			TranslationPrintToChatAll("Random transformations", iPandemicTimer1);
			
			CreateTimer(30.0, TurnAssassinsIntoNemesis, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			
			int colors1[4];
			colors1[0] = 0;
			colors1[1] = 255;
			colors1[2] = 0;
			colors1[3] = 255;
			
			printModeHudAnnouncer(name, colors1, gServerData.GameSync, "Event mode HUD", true);
		}
		case MODE_MEOW:{
			EmitSoundToAll(AMBIENT_SOUND_MEOW, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_, volume*4);
			
			eventmode = true;
			
			EmitSoundToAll(MODE_NEMESIS_SOUND, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
			
			ZPlayer user;
			for (int i = 1; i <= MaxClients; i++){
				
				if (!IsPlayerExist(i, true)){
					continue;
				}
				
				user = ZPlayer(i);
				
				if (user.bStaff){
					user.TurnInto(PT_MEOW);
					VEffectSpawnEffect(user.id);
				}
				else user.TurnInto(PT_NEMESIS);
				
				TranslationPrintToChatAll("Event mode meow");
			}
			
			int colors1[4];
			colors1[0] = 0;
			colors1[1] = 255;
			colors1[2] = 0;
			colors1[3] = 255;
			
			printModeHudAnnouncer(name, colors1, gServerData.GameSync, "Event mode HUD", true);
		}
		case MODE_MUTATION:{
			
			ScreenFadeAll(0.6, 0.6+0.4, FFADE_OUT, { 0, 0, 0, 255 });
			CreateTimer(0.6+0.4, ScreenFadeIn);
			
			EmitSoundToAll(AMBIENT_SOUND_ZBOSS, SOUND_FROM_PLAYER, SNDCHAN_STATIC,_,_, 0.2);
			
			
			// Declare variables outside the loop
			HClass class;
			
			int colors1[4];
			colors1[0] = 0;
			colors1[1] = 255;
			colors1[2] = 0;
			colors1[3] = 255;
			
			int colors2[4];
			colors2[0] = 0;
			colors2[1] = 255;
			colors2[2] = 0;
			colors2[3] = 255;
			
			for (int i = 1; i <= MaxClients; i++){
				ZPlayer user = ZPlayer(i);
				
				if (!IsPlayerExist(user.id, true))
				continue;
				
				// Read class data
				HClasses.GetArray(user.iHumanClass, class);
				
				user.setModel(HAZMAT_MODEL, class.arms);
				
				CreateMutationTimer(i);
				
				SetHudTextParamsEx(-1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, colors1, colors2, 1, 1.0, 1.0, 1.0);
				ShowSyncHudText(i, gServerData.GameSync, "MUTACIÓN");
			}
			
			GrenadeRain_OnStartMode();
		}
	}
	
	// Validate T-Virus timer
	if (gServerData.TVirusReleasedTimer != null){
		// Resets server counter 
		delete gServerData.TVirusReleasedTimer;
	}
	
	// Validate counter timer
	if (gServerData.CounterTimer != null){
		// Resets server counter 
		delete gServerData.CounterTimer;
	}
	
	//PrintHintTextToAll("<font size='22' color='#XXXXXX'>Modo:</font>\n<font size='37' color='#FF0000'>%s</font>", name);
	
	//EmitSoundToAll(AMBIENT_SOUND, SOUND_FROM_PLAYER,_,_,_,0.7);
	//RoundEndOnValidate();
}

stock void printModeHudAnnouncer(char[] name, int colors1[4], Handle hSync, char[] phrase, bool event = false){
	
	//ShowSyncHudTextAll(/*0.425*/-1.0, 0.20, 3.0, colors1, colors2, 1, 1.0, 1.0, 1.0, hSync, sData);
	if (!event) TranslationPrintHudTextAll(gServerData.GameSync, -1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, colors1[0], colors1[1], colors1[2], colors1[3], 1, 1.0, 1.0, 1.0, phrase, name);
	else TranslationPrintHudTextAll(gServerData.GameSync, -1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, colors1[0], colors1[1], colors1[2], colors1[3], 1, 1.0, 1.0, 1.0, phrase);
}

void ShowSyncHudTextAll(float x, float y, float holdTime, int colors1[4], int colors2[4], int effect, float fxTime, float fadeIn, float fadeOut, Handle hSync, char[] sMessage){
	for (int i = 1; i <= MaxClients; i++){
		if (!IsPlayerExist(i)) continue;
		
		// Sets the global language target
		SetGlobalTransTarget(i);
		
		SetHudTextParamsEx(x, y, holdTime, colors1, colors2, effect, fxTime, fadeIn, fadeOut);
		ShowSyncHudText(i, hSync, sMessage);
	}
}

// MODE STATS DETECTION
public void ModeStats_StartDetection(){
	
	GamemodesStats_purgeModesData();
	
	ZPlayer player;
	for (int i = 1; i <= MaxClients; i++){
		
		player = ZPlayer(i);
		
		if (player.iTeamNum != CS_TEAM_T && player.iTeamNum != CS_TEAM_CT){
			continue;
		}
		
		if (!player.bLogged){
			continue;
		}
		
		if (player.isHuman()){
			ModesHumans.Push(i);
		}
		else if (player.isZombie()){
			ModesZombies.Push(i);
		}
		
	}
		
	CreateTimer(3.0, Timer_StartShowingModeStats, _, TIMER_FLAG_NO_MAPCHANGE);
}
public Action Timer_StartShowingModeStats(Handle hTimer, any data){
	
	hModeStats = CreateTimer(2.0, Timer_ShowModeStats, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}
public Action Timer_ShowModeStats(Handle hTimer, any data){
	
	if (!ActualMode.is(MODE_SWARM) && !ActualMode.is(MODE_PLAGUE) && !ActualMode.is(MODE_ARMAGEDDON) && !ActualMode.is(MODE_APOCALYPSIS) && !ActualMode.is(MODE_SYNAPSIS)){
		hModeStats = null;
		return Plugin_Stop;
	}
	
	int iHumansAlive = fnGetAliveInTeam(CS_TEAM_CT);
	int iZombiesAlive = fnGetAliveInTeam(CS_TEAM_T);
	
	TranslationPrintHudTextAll(gServerData.GameSync, -1.0, 0.05, 2.0, 255, 100, 100, 255, 1, 1.0, 1.0, 1.0, "Swarm mode stats", iHumansAlive, iZombiesAlive, iModesHumanRewards, iModesZombieRewards);
	
	return Plugin_Continue;
}

// Gamemodes funcs
stock void GameModesTurnIntoZombie(int nMaxZombies, PlayerType iType, bool firstZombie = false, bool nobots = false){
	int nZombies;
	
	int random;
	while (nZombies < nMaxZombies){
		
		if (nobots){
			random = GetRandomUserNoBots();
		}
		else{
			random = GetRandomUser();
		}
		
		
		if(!IsPlayerExist(random)) continue;
		
		if(ZPlayer(random).isBoss(true) || ZPlayer(random).isType(PT_ZOMBIE)) continue;
		
		if (iType == PT_ZOMBIE)
			ZPlayer(random).Zombiefy(firstZombie);
		else
			ZPlayer(random).TurnInto(iType, firstZombie);
		
		nZombies++;
	}
}
stock void GameModesTurnIntoHuman(int nMaxHumans, PlayerType iType, bool bWhile = false, bool nobots = false){
	int nHumans;
	
	if (bWhile){
		ZPlayer player;
		int random;
		while (nHumans < nMaxHumans){
			
			if (nobots){
				random = GetRandomUserNoBots();
			}
			else{
				random = GetRandomUser();
			}
			
			player = ZPlayer(random);
			
			if(!IsPlayerExist(player.id))
				continue;
			
			if(player.isBoss(false))
				continue;
			
			if (iType == PT_HUMAN)
				player.Humanize();
			else
				player.TurnInto(iType);
			
			nHumans++;
		}
	}
	else{
		ZPlayer player;
		// i = client index
		for (int i = 1; i <= MaxClients; i++){
			// Get real player index from event key
			player = ZPlayer(i);
			
			// Verify that the client is exist
			if(!IsPlayerExist(player.id, true))
				continue;
			
			// Verify that the client is human
			if(player.isBoss(false))
				continue;
			
			if (nHumans < nMaxHumans){
				if (iType == PT_HUMAN)
					player.Humanize();
				else
					player.TurnInto(iType);
				nHumans++;
			}
			else break;
		}
	}
}

bool RoundEndOnValidate(bool validateRound = true){
	int nPlayers = fnGetPlaying();
	
	if (!nPlayers){
		return false;
	}
	
	int nHumans  = fnGetHumans();
	int nZombies = fnGetZombies();
	
	if(validateRound){
		if(gServerData.RoundNew){
			int nAlive = fnGetAlive();
			
			if(nAlive > 1){
				return false;
			}
		}
		
		if (nZombies > 0 && nHumans > 0){
			return false;
		}
	}
	
	if (nHumans > 0){
		CS_TerminateRound(3.0, CSRoundEnd_CTWin, false);
	}
	else{
		CS_TerminateRound(3.0, CSRoundEnd_TerroristWin, false);
	}
	return true;
}
void switchFog(bool boolean = false){
	
	if (iFog != -1){
		AcceptEntityInput(iFog, boolean ? "TurnOn" : "TurnOff");
	}
}
void VAmbienceTurnOffLights(){
	// Initialize entity index
	int iLight = -1;
	
	// Searching fog lights entities
	while ((iLight = FindEntityByClassname(iLight, "light_dynamic")) != -1){ 
		AcceptEntityInput(iLight, "TurnOff");
	}
}

//=====================================================
//				WEAPONS HOOKS
//=====================================================
public Action WeaponsOnCanUse(int client, int weaponIndex){
	
	if(!IsValidEdict(weaponIndex) || !IsPlayerExist(client)){
		return Plugin_Handled;
	}
	
	int iWeaponID = readWeaponNetworkedIndex(weaponIndex);
	ZPlayer player = ZPlayer(client);
	
	if (!player.isBoss(true)){
		if (!hasAccessToWeapon(client, iWeaponID))
			return Plugin_Handled;
	}
	
	char weap[32];
	GetEdictClassname(weaponIndex, weap, sizeof(weap));
	
	if (!player.isType(PT_NEMESIS))
	if (StrEqual(weap, "weapon_awp") && iWeaponID == iWeaponBazooka)
		return Plugin_Handled;
	
	if(player.isType(PT_ZOMBIE)){
		if(StrEqual(weap, "weapon_knife")) return Plugin_Continue;
		if(StrEqual(weap, "weapon_flashbang")) return Plugin_Continue;
		
		return Plugin_Handled;
	}
	
	if (player.isBoss(false)){
		
		if (player.isType(PT_NEMESIS)){
			if (StrEqual(weap, "weapon_awp") && iWeaponID == iWeaponBazooka)
				return Plugin_Continue;
			
			else if (StrEqual(weap, "weapon_knife")) return Plugin_Continue;
			else{
				return Plugin_Handled;
			}
		}
		else{
			if (StrEqual(weap, "weapon_knife")) return Plugin_Continue;
			
			return Plugin_Handled;
		}
	}
	
	if (player.isType(PT_GUNSLINGER)){
		if (StrEqual(weap, "weapon_knife")) return Plugin_Continue;
		if (StrEqual(weap, "weapon_flashbang")) return Plugin_Continue;
		if (StrEqual(weap, "weapon_smokegrenade")) return Plugin_Continue;
		if (StrEqual(weap, "weapon_deagle")) return Plugin_Continue;
		
		return Plugin_Handled;
	}
	else if (player.isType(PT_SNIPER)){
		if (StrEqual(weap, "weapon_knife")) return Plugin_Continue;
		if (StrEqual(weap, "weapon_decoy")) return Plugin_Continue;
		if (StrEqual(weap, "weapon_awp")) return Plugin_Continue;
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public Action PreThink(int client){
	SetEntPropFloat(client, Prop_Send, "m_flStamina", 0.0);
}

public Action WeaponsOnDropPost(int clientIndex, int weaponIndex){
	if(IsValidEntity(weaponIndex)) {
		CreateTimer(TIME_TO_REMOVE_WEAPONS, WeaponsRemoveDropedWeapon, EntIndexToEntRef(weaponIndex), TIMER_FLAG_NO_MAPCHANGE);
	}
}
public Action WeaponsRemoveDropedWeapon(Handle hTimer, any weaponIndex){
	
	int weapon = EntRefToEntIndex(weaponIndex);
	
	if (weapon == INVALID_ENT_REFERENCE)
		return Plugin_Stop;
	
	if(!IsValidEntity(weaponIndex))
		return Plugin_Stop;
	
	if(GetEntPropEnt(weaponIndex, Prop_Data, "m_pParent") == -1)
		RemoveEntity(weaponIndex);
	
	return Plugin_Stop;
}

public Action WeaponsOnEquip(int client, int weapon){
	ZPlayer player = ZPlayer(client);
	
	int iWeaponID = readWeaponNetworkedIndex(weapon);
	
	if (!player.isBoss(true)){
		if (!hasAccessToWeapon(client, iWeaponID))
			return Plugin_Handled;
	}
	
	char sWeapon[48];
	GetEntPropString(weapon, Prop_Data, "m_iName", sWeapon, sizeof(sWeapon));
	
	if (StrContains(sWeapon, "primary") != -1){
		player.iPrimaryWeapon = iWeaponID;
	}
	else if (StrContains(sWeapon, "secondary") != -1){
		player.iSecondaryWeapon = iWeaponID;
	}
	
	return Plugin_Continue;
}

// Apply selected weapon viewmodel when selected
public void OnClientWeaponSwitch(int client, int weapon){
	ZPlayer player = ZPlayer(client);
	
	if(!IsPlayerExist(player.id) || !IsValidEdict(weapon) || weapon <= MaxClients)
		return;
	
	//////////////////////////////////////////////////////////////
	//					IMPORTANT BUGFIX
	//////////////////////////////////////////////////////////////
	
	int weaponID; weaponID = player.iActiveWeaponIndex;
	
	 // Validate coded weapons
	Bazooka_OnWeaponHolster(client, weapon, weaponID);
	Chainsaw_OnWeaponHolster(client, weapon, weaponID);
}

// Apply selected weapon viewmodel when selected
public void OnClientWeaponSwitchPost(int client, int weapon){
	ZPlayer player = ZPlayer(client);
	
	if(!IsPlayerExist(player.id) || !IsValidEdict(weapon) || weapon <= MaxClients)
		return;
	
	char sWpn[64]; 
	GetEdictClassname(weapon, sWpn, sizeof(sWpn));	// obtain edict classname to compare to actual weapon & weapon id in array
	
	#if defined ENABLE_WEAPONS_DEBUG_MESSAGES
	if (player.bStaff)
		PrintToChat(player.id, " \x091\x01 weapon: %d, sWpn: %s", weapon, sWpn);
	#endif
	
	int playerview = player.iPredictedViewModelIndex;
	if (playerview == INVALID_ENT_REFERENCE){
		player.iPredictedViewModelIndex = Weapon_GetViewModelIndex(player.id, -1);
		playerview = player.iPredictedViewModelIndex;
		
		#if defined ENABLE_WEAPONS_DEBUG_MESSAGES
		PrintToChat(player.id, "iPredictedViewModelIndex is invalid ref");
		#endif
		
		if (playerview == INVALID_ENT_REFERENCE){
			#if defined ENABLE_WEAPONS_DEBUG_MESSAGES
			PrintToChat(player.id, "iPredictedViewModelIndex is invalid ref AGAIN");
			#endif
			return;
		}
	}
	
	// Change models in each case
	if (StrEqual(sWpn, "weapon_knife")){
		
		if (player.isBoss(false)){
			SetViewModel(weapon, playerview, GetModelIndex(ZOMBIE_BOSSES_KNIFE_MODEL_V));
			SetWorldModel(weapon, GetModelIndex(ZOMBIE_BOSSES_KNIFE_MODEL_W));
		}
		else if (player.isType(PT_ZOMBIE)){
			ZClass class;
			ZClasses.GetArray(player.iZombieClass, class);
			
			SetViewModel(weapon, playerview, GetModelIndex(class.arms));
			if (class.hideKnife)
				hideWorldModel(weapon);
		}
	}
	else if (StrEqual(sWpn, "weapon_smokegrenade") && player.isHuman()){
		ZGrenadePack pack = ZGrenadePack(player.iGrenadePack);
		if (pack.hasGrenade(AURA_GRENADE)){
			SetViewModel(weapon, playerview, GetModelIndex(AURA_VMODEL));
			SetWorldModel(weapon, GetModelIndex(AURA_WMODEL));
		}
	}
	else if (StrEqual(sWpn, "weapon_decoy") && player.isHuman()){
		ZGrenadePack pack = ZGrenadePack(player.iGrenadePack);
		if (pack.hasGrenade(VOID_GRENADE)){
			SetViewModel(weapon, playerview, GetModelIndex(BLACKHOLE_VMODEL));
			SetWorldModel(weapon, GetModelIndex(BLACKHOLE_VMODEL));
		}
	}
	else if (StrEqual(sWpn, "weapon_flashbang") && player.isZombie()){
		SetViewModel(weapon, playerview, GetModelIndex(INFECT_GRENADE_VMODEL));
		SetWorldModel(weapon, GetModelIndex(INFECT_GRENADE_WMODEL));
	}
	else {
		//////////////////////////////////////////////////////////////
		//					IMPORTANT BUGFIX
		//////////////////////////////////////////////////////////////
		
		// Get primary weapon id
		int primary = GetPlayerWeaponSlot(player.id, CS_SLOT_PRIMARY);
		
		// Get secondary weapon id
		int secondary = GetPlayerWeaponSlot(player.id, CS_SLOT_SECONDARY);
		
		int iWeaponid;
		if (primary == weapon){
			iWeaponid = player.iPrimaryWeapon;
		}
		else if (secondary == weapon){
			iWeaponid = player.iSecondaryWeapon;
		}
		else return;
		
		#if defined ENABLE_WEAPONS_DEBUG_MESSAGES
		if (player.bStaff)
			PrintToChat(player.id, " \x092\x01 WEAPON IS MODIFIED: %s", sWpn);
		#endif
		
		// NOW THAT THE PLUGIN KNOWS WHERE TO READ THE DATA FROM, WE SHALL CONTINUE
		//////////////////////////////////////////////////////////////
		//////////////////////////////////////////////////////////////
		//////////////////////////////////////////////////////////////
		
		char sWeapEntName[32];
		ZWeapon zweapon = ZWeapon(iWeaponid);
		
		zweapon.GetEnt(sWeapEntName, sizeof(sWeapEntName)); // do the read!
		
		#if defined ENABLE_WEAPONS_DEBUG_MESSAGES
		if (player.bStaff)
			PrintToChat(player.id, "sWeapEntName: %s", sWeapEntName);
		#endif
		
		// Else
		if (StrEqual(sWpn, sWeapEntName) || (StrEqual(sWpn, "weapon_m4a1") && StrContains(sWeapEntName, "weapon_m4a1") != -1) || (StrEqual(sWpn, "weapon_mp7") && StrContains(sWeapEntName, "weapon_mp5sd") != -1)){
			char sWeapModel[WEAPONS_MODELS_MAXPATH];
			zweapon.GetViewModel(sWeapModel, sizeof(sWeapModel));
			
			// No sense in setting world model without view model
			if (!StrEqual(sWeapModel, "")){
				
				// Set view model
				SetViewModel(weapon, playerview, GetModelIndex(sWeapModel));
				
				// Set world model
				zweapon.SetWorldModel(weapon);
				
			}
			
			// Validate coded weapons
			Bazooka_OnWeaponDeploy(client, weapon, iWeaponid);
			Chainsaw_OnWeaponDeploy(client, weapon, iWeaponid);
		}
	}
}

// Apply selected weapon dropped skin when users drop them
public void OnClientWeaponDropPost(int client, int weapon){
	if (!IsValidEdict(weapon))
		return;
	
	if (!IsPlayerExist(client))
		return;
	
	ZPlayer player = ZPlayer(client);
	
	char sWeapon[32];
	GetEntPropString(weapon, Prop_Data, "m_iName", sWeapon, sizeof(sWeapon));
	
	/////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////
	
	// BUGFIX: PLAYER DROPS NOT CORRESPONDING WEAPON BY LVL TO AVOID COMBO PUNISHMENT!
	/*if (!player.isBoss(true))
		if (StrContains(sWeapon, "primary") != -1 || StrContains(sWeapon, "secondary") != -1)
			if (!hasAccessToWeapon(client, player.iPrimaryWeapon) || !hasAccessToWeapon(client, player.iSecondaryWeapon))
				SafeEndPlayerCombo(client);*/
	
	ZWeapon zWeapon;
	
	if (StrContains(sWeapon, "primary_") != -1){
		zWeapon = ZWeapon(StringToInt(sWeapon[8]));
		//PrintToChat(player.id, "%s PWeapon: %d", SERVERSTRING, StringToInt(sWeapon[8]));
		player.iPrimaryWeapon = 0;
	}
	else if (StrContains(sWeapon, "secondary_") != -1){
		zWeapon = ZWeapon(StringToInt(sWeapon[10]));
		//PrintToChat(player.id, "%s SWeapon: %d", SERVERSTRING, StringToInt(sWeapon[10]));
		player.iSecondaryWeapon = 0;
	}
	else return;
	
	// Get dropped model for compatibility
	static char sDroppedModel[WEAPONS_MODELS_MAXPATH];
	zWeapon.GetDroppedModel(sDroppedModel, sizeof(sDroppedModel));
	if (!hasLength(sDroppedModel)){
		zWeapon.GetWorldModel(sDroppedModel, sizeof(sDroppedModel));
	}
	
	if (!StrEqual(sDroppedModel, "")){
		
		// Send data to the next frame
		DataPack hPack = new DataPack();
		hPack.WriteCell(weapon);
		hPack.WriteString(sDroppedModel);
		
		RequestFrame(view_as<RequestFrameCallback>(SetDroppedModel), hPack);
	}
}
public void SetDroppedModel(DataPack hPack){
	// Resets the position in the datapack
	hPack.Reset();
	
	// Get the weapon index from the datapack
	int weapon = hPack.ReadCell();
	
	if (IsValidEdict(weapon)){
		// Get the world model from the datapack
		static char sDroppedModel[WEAPONS_MODELS_MAXPATH];
		hPack.ReadString(sDroppedModel, sizeof(sDroppedModel));
		
		SetEntityModel(weapon, sDroppedModel);
	}
	
	delete view_as<DataPack>(hPack);
}

// Modify entity details to store info
public Action CS_OnCSWeaponDrop(int client, int weaponIndex){
	
	if (!IsValidEdict(weaponIndex))
		return Plugin_Handled;
	
	#if !defined DISABLE_WEAPON_DROP
	ZPlayer player = ZPlayer(client);
	
	if (player.isBoss(true) || player.isBoss(false))
		return Plugin_Handled;
	
	// Initialize vars
	int primary, secondary;
	
	// Get primary weapon id
	primary = GetPlayerWeaponSlot(player.id, CS_SLOT_PRIMARY);
	
	// Get secondary weapon id
	secondary = GetPlayerWeaponSlot(player.id, CS_SLOT_SECONDARY);
	
	// Store to primary weapon id
	if(primary == weaponIndex){
		
		ZWeapon weapon = ZWeapon(player.iPrimaryWeapon);
		weapon.SetNetworkedName(weaponIndex);
		
		
		#if defined ENABLE_WEAPONS_DEBUG_MESSAGES
		if (player.bStaff)
			PrintToChat(player.id, " \x09DROPPED PRIMARY\x01 | index %d", player.iPrimaryWeapon);
		#endif
		
		player.iPrimaryWeapon = 0;
	}
	// Store to secondary weapon id
	else if(secondary == weaponIndex){
		
		ZWeapon weapon = ZWeapon(player.iSecondaryWeapon);
		weapon.SetNetworkedName(weaponIndex);
		
		#if defined ENABLE_WEAPONS_DEBUG_MESSAGES
		if (player.bStaff)
			PrintToChat(player.id, " \x09DROPPED SECONDARY\x01 | index %d", player.iSecondaryWeapon);
		#endif
		
		player.iSecondaryWeapon = 0;
	}
	
	return Plugin_Continue;
	#else
	return Plugin_Handled;
	#endif
}

//=====================================================
//					HATS
//=====================================================
/*
public void hasHat(int client, int idHat){
	
	if(gServerData.DBI == null) ConnectToDatabase();
	
	DataPack data = new DataPack();
	data.WriteCell(client);
	data.WriteCell(idHat);
	
	ZPlayer player = ZPlayer(client);
	Hat hat;
	Hats.GetArray(idHat, hat);
	
	char query[128];
	FormatEx(query, sizeof(query), "SELECT * FROM HatsXCharacter WHERE idHat=%d AND idCharacter=%d AND activo=1", hat.idDb, player.iPjSeleccionado);
	gServerData.DBI.Query(HasHatCallback, query, data);
}
public void HasHatCallback(Database db, DBResultSet results, const char[] error, any data){
	
	
	DataPack dpack = view_as<DataPack>(data);
	
	dpack.Reset();
	
	int client = dpack.ReadCell();
	
	if(!StrEqual(error, "")){
		LogError(error);
		delete dpack;
		return;
	}
	
	
	if(results.RowCount == 0){
		giveHatTo(dpack);
	}
	else {
		TranslationPrintToChat(client, "Already own this hat");
		delete dpack;
	}
}*/

/*
public void giveHatTo(DataPack data){
	
	if(gServerData.DBI == null) ConnectToDatabase();
	
	char query[128];
	
	data.Reset();
	
	int client = data.ReadCell();
	int idHat = data.ReadCell();
	
	ZPlayer player = ZPlayer(client);
	Hat hat;
	Hats.GetArray(idHat, hat);
	
	FormatEx(query, sizeof(query), "INSERT INTO HatsXCharacter(idHat, idCharacter, activo, costo) VALUES(%d, %d, 1, %d)", hat.idDb, player.iPjSeleccionado, hat.cost);
	if(player.iPiuPoints >= hat.cost){
		gServerData.DBI.Query(GiveHatToCallback, query, data);
	}else{
		TranslationPrintToChat(client, "Not hat points enought");
		delete data;
	}
}
public void GiveHatToCallback(Database db, DBResultSet results, const char[] error, any data){
	DataPack dpack = view_as<DataPack>(data);
	dpack.Reset();
	
	int client = dpack.ReadCell();
	int idHat = dpack.ReadCell();
	
	ZPlayer player = ZPlayer(client);
	Hat hat;
	Hats.GetArray(idHat, hat);
	
	if(StrEqual(error, "")){
		player.iPiuPoints -= hat.cost;
		
		//UpdatePiuPoints(player.id, player.iPiuPoints);
		TranslationPrintToChat(client, "Hat bought", hat.name);
	}else{
		LogError(error);
		PrintToChat(client, "%s ERROR AL COMPRAR EL HAT. No fueron descontados tus puntos.", SERVERSTRING);
	}
	delete dpack;
}
*/

// Chests
public int CreateChest(int owner, float vector[3]){
	int entity = CreateEntityByName("prop_dynamic_glow");
	
	if (IsValidEntity(entity)){
		// Move entity to origins
		//vector[2] += 50.0;
		TeleportEntity(entity, vector, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(entity, "Classname", CHEST_CLASSNAME);
		DispatchKeyValue(entity, "model", CHEST_MODEL);
		
		SetEntProp(entity, Prop_Send, "m_usSolidFlags", 12);
		//SetEntProp(entity, Prop_Data, "m_nSolidType", 6);
		SetEntProp(entity, Prop_Data, "m_nSolidType", 4);
		//SetEntProp(entity, Prop_Send, "m_CollisionGroup", 1);
		SetEntProp(entity, Prop_Send, "m_CollisionGroup", 5);
		
		// Set entity's owner
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", owner);
		
		DispatchSpawn(entity);
		ActivateEntity(entity);
		
		SetEntProp(entity, Prop_Send, "m_bShouldGlow", true, true);
		SetEntPropFloat(entity, Prop_Send, "m_flGlowMaxDist", 1000.0);
		SetGlowColor(entity, "20 150 50");
		
		SDKHook(entity, SDKHook_StartTouch, HookTouchChest);
		
		// Rotation
		int m_iRotator = CreateEntityByName("func_rotating");
		DispatchKeyValueVector(m_iRotator, "origin", vector);
		DispatchKeyValue(m_iRotator, "targetname", "Item");
		DispatchKeyValue(m_iRotator, "maxspeed", "70");
		DispatchKeyValue(m_iRotator, "friction", "0");
		DispatchKeyValue(m_iRotator, "dmg", "0");
		DispatchKeyValue(m_iRotator, "solid", "0");
		DispatchKeyValue(m_iRotator, "spawnflags", "64");
		DispatchSpawn(m_iRotator);
		
		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", m_iRotator, m_iRotator);
		AcceptEntityInput(m_iRotator, "Start");
		
		SetEntPropEnt(entity, Prop_Send, "m_hEffectEntity", m_iRotator);
		
		return entity;
	}
	return -1;
}
public Action TimerSpawnChest(Handle timer, int client){
	float origin[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", origin);
	int chestId = CreateChest(client, origin);
	CreateTimer(CHEST_TIME_DISAPPEAR, DeleteChest, EntIndexToEntRef(chestId), TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}
public Action DeleteChest(Handle timer, int ref){
	if (ref == INVALID_ENT_REFERENCE)
	return;
	
	int entity = EntRefToEntIndex(ref);
	
	if (!IsValidEntity(entity))
	return;
	
	static char sClassname[32];
	GetEntityClassname(entity, sClassname, sizeof(sClassname));
	
	if (StrEqual(sClassname, CHEST_CLASSNAME))
	AcceptEntityInput(entity, "FadeAndKill");
}
public void HookTouchChest(int entity, int other){
	if (!IsValidEntity(entity))
		return;
	
	// Get owner's id
	//int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	
	if (!IsPlayerExist(other, true)/* || other != client*/)
		return;
	
	ZPlayer p = ZPlayer(other);
	
	if (!p.isZombie())
		return;
	
	int gain = GetRandomInt(CHEST_MIN_AP, CHEST_MAX_AP);
	int total = p.applyGain(gain);
	PrintToChat(p.id, "%s Conseguiste un \x09headcrab\x01 que contenía \x09%d\x01 AP!", SERVERSTRING, total);
	AcceptEntityInput(entity, "FadeAndKill");
	SDKUnhook(entity, SDKHook_StartTouch, HookTouchChest);
}

//=====================================================
//					ZOMBIE MADNESS
//=====================================================
bool ZombieMadnessBegin(int client){
	
	if (!IsPlayerExist(client)){
		return false;
	}
	
	if (!IsPlayerAlive(client)){
		TranslationPrintToChat(client, "Not alive");
		return false;
	}
	
	ZPlayer player = ZPlayer(client);
	
	if (!player.isType(PT_ZOMBIE)){
		TranslationPrintToChat(player.id, "Not zombie");
		return false;
	}
	
	if (player.iMadness <= 0){
		TranslationPrintToChat(player.id, "No madness left");
		return false;
	}
	
	if (IsMadnessInCooldown(player.id)){
		TranslationPrintToChat(player.id, "Item in cooldown");
		return false;
	}
	
	if (player.bInvulnerable || !ActualMode.bZombieMadnessAvailable){
		TranslationPrintToChat(player.id, "Not available");
		return false;
	}
	
	/*if (fnGetAliveInTeam(CS_TEAM_CT) < 2){
		TranslationPrintToChat(player.id, "Not available");
		return false;
	}*/
	
	float fSeconds = applyPercentage(MADNESS_DURATION, GoldenUpgrade(getUpgradeIndexByUpgradeId(Z_MADNESSTIME)).getBuffAmount(player.iMadnessTimeLevel));
	
	player.bInvulnerable = true;
	
	float ori[3];
	GetClientAbsOrigin(client, ori);
	EmitAmbientSound(ZOMBIE_MADNESS_SOUND, ori, client, SNDLEVEL_NORMAL, _, 0.5);
	
	Unfreeze(player.hFreezeTimer, player.id);
	applyMadnessCooldown(player.id);
	
	CreateAura(player.id, iMadnessColors[player.iMadnessTimeLevel]);
	
	CreateTimer(fSeconds, ZombieMadnessEnd, player.id, TIMER_FLAG_NO_MAPCHANGE);
	
	return true;
}
public Action ZombieMadnessEnd(Handle hTimer, any client){
	
	if (!IsPlayerExist(client))
		return Plugin_Stop;
	
	ZPlayer player = ZPlayer(client);
	
	player.bInvulnerable = false;
	RemoveAura(client);
	
	return Plugin_Stop;
}

int fnGetPlayingLogged(){
	
	int value = 0;
	
	ZPlayer player;
	for (int i = 1; i <= MaxClients; i++){
		player = ZPlayer(i);
		
		if (!player.bLogged)
			continue;
		
		value++; 
	}
	
	return value;
}

// Get Amount of active users
void CheckQuantityPlaying(){
	
	int iLastCheckQuantity = iPlayersQuantity;
	
	iPlayersQuantity = fnGetPlayingLogged();
	
	
	if (iPlayersQuantity > PLAYERS_TO_GAIN){
		bAllowGain = true;
	}
	else if (iPlayersQuantity == PLAYERS_TO_GAIN){
		/*
		if (!ActualMode.is(MODE_WARMUP)){
			CS_TerminateRound(0.5, CSRoundEnd_CTWin, false);
			TranslationPrintToChatAll("Restarting round");
		}*/
		
		TranslationPrintToChatAll("Profits enabled");
		bAllowGain = true;
	}
	else{
		
		if (iLastCheckQuantity == PLAYERS_TO_GAIN && iPlayersQuantity == PLAYERS_TO_GAIN-1){
			// End any combos whenever disabling gain
			ZPlayer player;
			for (int i = 1; i <= MaxClients; i++){
				player = ZPlayer(i);
				
				if (!player.bLogged)
					continue;
				
				SafeEndPlayerCombo(i);
			}
		}
		
		
		TranslationPrintToChatAll("Waiting for users", PLAYERS_TO_GAIN-iPlayersQuantity);
		bAllowGain = false;
		
		if (iPlayersQuantity == 1){
			if (!ActualMode.is(MODE_WARMUP)){
				CS_TerminateRound(0.5, CSRoundEnd_CTWin, false);
				TranslationPrintToChatAll("Restarting round");
			}
		}
		else if (iPlayersQuantity == PLAYERS_TO_GAIN-1){
			TranslationPrintToChatAll("Profits disabled");
		}
	}
}
/*public void CheckToTerminate(){

	if (fnGetAlive() == 0){
		CS_TerminateRound(5.0, CSRoundEnd_Draw, false);
	}
	else if (!fnGetAliveInTeam(CS_TEAM_T) && fnGetAliveInTeam(CS_TEAM_CT)){
		CS_TerminateRound(5.0, CSRoundEnd_CTWin, false);
	}
	else if (fnGetAliveInTeam(CS_TEAM_T) && !fnGetAliveInTeam(CS_TEAM_CT)){
		CS_TerminateRound(5.0, CSRoundEnd_TerroristWin, false);
	}
}*/

//=====================================================
//					FREE VIP TEST
//=====================================================

public Action showPruebaVipMenu(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	Menu menu = new Menu(menuVipPruebaHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	menu.SetTitle("%t", "VIP test menu title");
	
	char option[32];
	Format(option, sizeof(option), "%t", "VIP test menu option 1");
	menu.AddItem("a", option, player.flExpBoost == 1.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	menu.ExitButton = true;
	
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int menuVipPruebaHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			registerVipPrueba(client);
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

public Action registerVipPrueba(int client){
	
	if(gServerData.DBI == null)
		return Plugin_Handled;
	
	ZPlayer p = ZPlayer(client);
	if(p.flExpBoost > 1.0){
		TranslationPrintToChat(client, "Already vip");
	}
	
	//PrintToChatAll("client: %d | pj: %d", client, p.iPjSeleccionado);
	char query[64];
	Format(query, sizeof(query), "CALL registerVipPrueba(%d)", p.iPjSeleccionado);
	gServerData.DBI.Query(RegisterVipPruebaHandler, query, client, DBPrio_High);
	
	return Plugin_Handled;
}
public void RegisterVipPruebaHandler(Database db, DBResultSet results, const char[] error, any data){
	
	if(!hasLength(error)){
		TranslationPrintToChat(data, "Vip test successful");
		//TranslationPrintToChat(data, "Relog to activate vip");
		checkFechaPrueba(data);
	}else{
		LogError(error);
		TranslationPrintToChat(data, "Already used test vip");
	}
}

public void checkFechaPrueba(int client){
	
	if(gServerData.DBI == null)
		return;
	
	ZPlayer p = ZPlayer(client);
	
	char query[128];
	Format(query, sizeof(query), "SELECT fechaFin FROM VipPrueba WHERE idChar=%d", p.iPjSeleccionado);
	gServerData.DBI.Query(CheckFechaPruebaHandler, query, client, DBPrio_Low);
	
}
public void CheckFechaPruebaHandler(Database db, DBResultSet results, const char[] error, any data){
	
	if(results.FetchRow()){
		char res[32], fyh[2][16], fecha[3][8];
		results.FetchString(0, res, sizeof(res));
		
		ExplodeString(res, " ", fyh, 2, 16);
		
		ExplodeString(fyh[0], "-", fecha, 3, 8);
		
		TranslationPrintToChat(data, "Your vip test expires", fecha[2], fecha[1], fecha[0], fyh[1]);
	}
}

/*
public Action rpoints(int client, int args){
	for(int i = 1; i <= 2458; i++){
		getPointsData(i);
	}
	
	return Plugin_Handled;
}
public Action getPointsData(int charId){
	
	char error[255];
	DBStatement hUserStmt = null;
	
	if (hUserStmt == null){
		char error2[255];
		hUserStmt = SQL_PrepareQuery(db, "SELECT hDamageLevel, hPenetrationLevel, hDexterityLevel, hResistanceLevel, zDamageLevel, zResistanceLevel, zDexterityLevel, zHealthLevel, HPoints, ZPoints FROM Characters WHERE id = ?", error2, sizeof(error2));
		if (hUserStmt == null){
			PrintToServer(error2);
			
			delete hUserStmt;
			
			
			return Plugin_Handled;
		}
	}
	SQL_BindParamInt(hUserStmt, 0, charId, false);
	
	if (!SQL_Execute(hUserStmt)) {
		PrintToServer("Didn't executed query");
		
		delete hUserStmt;
		
		
		return Plugin_Handled;
	}
	
	int rows = SQL_GetRowCount(hUserStmt);
	
	int hPoints, hDmg, hPenetration, hDexterity, hResistance;
	int zPoints, zDmg, zResistance, zDexterity, zHealth;
	
	if(rows <= 0 ){
		PrintToServer("Personaje no encontrado");
		return Plugin_Handled;
	}
	
	// Fetch SQL data
	for(int i; i < rows; i++) {
		if(SQL_FetchRow(hUserStmt)) {
			hDmg = SQL_FetchInt(hUserStmt, 0);
			hPenetration = SQL_FetchInt(hUserStmt, 1);
			hDexterity = SQL_FetchInt(hUserStmt, 2);
			hResistance = SQL_FetchInt(hUserStmt, 3);
			zDmg = SQL_FetchInt(hUserStmt, 4);
			zResistance = SQL_FetchInt(hUserStmt, 5);
			zDexterity = SQL_FetchInt(hUserStmt, 6);
			zHealth = SQL_FetchInt(hUserStmt, 7);
			hPoints = SQL_FetchInt(hUserStmt, 8);
			zPoints = SQL_FetchInt(hUserStmt, 9);
		}
		else break;
	}
	
	int ret = 0;
	for(int i; i < zDmg; 	i++) ret += (ZOMBIE_DAMAGE_COST);
	for(int i; i < zDexterity; 	i++) ret += (ZOMBIE_DEXTERITY_COST);
	for(int i; i < zResistance; 	i++) ret += (ZOMBIE_RESISTANCE_COST);
	for(int i; i < zHealth; 	i++) ret += (ZOMBIE_HEALTH_COST);
	zPoints += ret;
	zDmg = 0;
	zDexterity = 0;
	zResistance = 0;
	zHealth = 0;
	
	ret = 0;
	for(int i; i < hDmg; 	i++) ret += (HUMAN_DAMAGE_COST);
	for(int i; i < hPenetration; 	i++) ret += (HUMAN_PENETRATION_COST);
	for(int i; i < hDexterity; 	i++) ret += (HUMAN_DEXTERITY_COST);
	for(int i; i < hResistance; 	i++) ret += (HUMAN_RESISTANCE_COST);
	hPoints += ret;
	hDmg = 0;
	hPenetration = 0;
	hDexterity = 0;
	hResistance = 0;
	
	char query[256];
	Format(query, sizeof(query), "UPDATE Characters SET hDamageLevel=%d, hPenetrationLevel=%d, hDexterityLevel=%d, hResistanceLevel=%d, zDamageLevel=%d, zResistanceLevel=%d, zDexterityLevel=%d, zHealthLevel=%d, HPoints=%d, ZPoints=%d WHERE id=%d",
														hDmg, hPenetration, hDexterity, hResistance, zDmg, zResistance, zDexterity, zHealth, hPoints, zPoints, charId);
	SQL_FastQuery(db, query);
	
	delete hUserStmt;
	
	return Plugin_Handled;
}
*/
//=====================================================
//					AMBIENCE EFFECTS
//=====================================================
void VAmbienceApplySunDisable(bool bDisable = false){
	// Find sun entity
	int iSun = FindEntityByClassname(-1, "env_sun");
	
	// If sun is invalid, then stop
	if(iSun == -1){
		return;
	}
	
	// If default, then re-enable sun rendering
	if(bDisable){
	    // Turn on sun rendering
		AcceptEntityInput(iSun, "TurnOn");
		return;
	}
	
	// Turn off sun rendering
	AcceptEntityInput(iSun, "TurnOff");
}
void VAmbienceApplyLightStyle(){
	// Initialize entity index
	int iLight = -1;
	
	// Searching fog lights entities
	while ((iLight = FindEntityByClassname(iLight, "env_cascade_light")) != -1){
		//AcceptEntityInput(iLight, "Kill");
		RemoveEntity(iLight);
	}
}
public Action VAmbienceTest(int client, int args){
	ZPlayer id = ZPlayer(client);
	
	if (!id.bStaff)
	return Plugin_Handled;
	
	SetLightStyle(0, "b");
	VAmbienceApplySunDisable();
	VAmbienceApplyLightStyle();
	
	return Plugin_Handled;
}

//=====================================================
//					SCREENFADE
//=====================================================
void StartSmoothScreenFadeAll(float time){
	ScreenFadeAll(time, time+0.6, FFADE_OUT, { 0, 0, 0, 255 });
	CreateTimer((time*2.0)+0.1, ScreenFadeIn);
}
public Action ScreenFadeIn(Handle hTimer){
	ScreenFadeAll(1.0, 1.0+0.4, FFADE_IN|FFADE_PURGE, { 0, 0, 0, 255 });
}

//=====================================================
//				PLAYER VISUAL EFFECTS
//=====================================================
public Action testEffects(int client, int args){
	ZPlayer id = ZPlayer(client);
	
	if (!id.bStaff)
	return Plugin_Handled;
	
	for (int i = 1; i <= MaxClients; i++){
		if (!IsPlayerExist(i, true))
		continue;
		
		VEffectSpawnEffect(i);
		
		// Initialize vector variable
		static float flOrigin[3];
		
		// Get client's position
		GetClientAbsOrigin(i, flOrigin);
		
		VEffectBloodDecalFunction(flOrigin);
		VEffectSmokeFunction(flOrigin);
		VEffectDustFunction(flOrigin);
		VEffectEnergySplashFunction(flOrigin);
	}
	
	return Plugin_Handled;
}
void VEffectSpawnEffect(int clientIndex){
	// Initialize vector variable
	static float flOrigin[3];
	
	// Get client's position
	GetClientAbsOrigin(clientIndex, flOrigin);
	
	// Create an fire entity
	int nEntity = CreateEntityByName("info_particle_system");
	
	// If entity isn't valid, then skip
	if(nEntity){
		// Give name to the entity 
		DispatchKeyValue(nEntity, "effect_name", "env_fire_large");
		
		// Sets the origin of the explosion
		DispatchKeyValueVector(nEntity, "origin", flOrigin);
		
		// Spawn the entity into the world
		DispatchSpawn(nEntity);
		
		// Get and modify flags on fired
		SetVariantString("!activator");
		
		// Sets parent to the entity
		AcceptEntityInput(nEntity, "SetParent", clientIndex);
		
		// Activate the enity
		ActivateEntity(nEntity);
		AcceptEntityInput(nEntity, "Start");
		
		// Sets modified flags on entity
		SetVariantString("OnUser1 !self:kill::1000000.0:1");
		AcceptEntityInput(nEntity, "AddOutput");
		AcceptEntityInput(nEntity, "FireUser1");
	}
}
void VEffectBloodDecalFunction(float flOrigin[3]){
	TE_Start("World Decal");
	TE_WriteVector("m_vecOrigin", flOrigin);
	TE_WriteNum("m_nIndex", decalBloodDecal);
	TE_SendToAll();
}
void VEffectSmokeFunction(float flOrigin[3]){
	TE_SetupSmoke(flOrigin, decalSmoke, 130.0, 10);
	TE_SendToAll();
}
void VEffectDustFunction(float flOrigin[3]){
	TE_SetupDust(flOrigin, NULL_VECTOR, 10.0, 1.0);
	TE_SendToAll();
}
void VEffectEnergySplashFunction(float flOrigin[3]){
	TE_SetupEnergySplash(flOrigin, NULL_VECTOR, true);
	TE_SendToAll();
}

// Damage knockback
/** 
 * @brief Sets velocity knock for the applied damage.
 *
 * @param client            The client index.
 * @param attacker          The attacker index.
 * @param flForce           The push force.
 **/
void DamageOnClientKnockBack2(int victim, int attacker, float flForce){
	
	// Validate amount
	if (flForce <= 0.0){
		return;
	}
	
	ZPlayer Victim = ZPlayer(victim);
	ZPlayer Attacker = ZPlayer(attacker);
	
	if (!IsPlayerExist(Victim.id, true) || !IsPlayerExist(Attacker.id, true))
		return;
	
	if(Victim.iTeamNum != CS_TEAM_T){
		return;
	}
	
	if (Victim.isBoss(false))
	return;
	
	/*
	if (fnGetZombies() == 1){
		return;
	}*/
	
	// Apply multiplier if client on air
	if (GetEntPropEnt(victim, Prop_Send, "m_hGroundEntity") == -1) flForce *= 0.75;
	
	// Initialize vectors
	static float vPosition[3]; static float vAngle[3]; static float vVelocity[3]; static float vEndPosition[3];
	
	// Gets attacker position
	GetClientEyeAngles(attacker, vAngle);
	GetClientEyePosition(attacker, vPosition);
	
	// Create the infinite trace
	TR_TraceRayFilter(vPosition, vAngle, MASK_ALL, RayType_Infinite, HitGroupsFilter, attacker);
	
	// Gets hit point
	TR_GetEndPosition(vEndPosition);
	
	// Gets vector from the given starting and ending points
	MakeVectorFromPoints(vPosition, vEndPosition, vVelocity);
	
	// Normalize the vector (equal magnitude at varying distances)
	NormalizeVector(vVelocity, vVelocity);
	
	// Apply the magnitude by scaling the vector
	ScaleVector(vVelocity, flForce);
	
	// Adds the given vector to the client current velocity
	ToolsSetVelocity(victim, vVelocity);
}

public bool HitGroupsFilter(int entity, int contentsMask, int client){
	return (entity != client);
}

//=====================================================
//					ONGAMEFRAME
//=====================================================
public void OnGameFrame(){
	UpdateForceFields();
	UpdateBlackHoles();
}

//=====================================================
//			ZOMBIE CLAWS ANIMATION FIX
//=====================================================
#define	WeaponsValidateKnife(%0) (%0 == CSWeapon_KNIFE || %0 == CSWeapon_KNIFE_GG)
public Action WeaponsOnAnimationFix(int client){
	
	// Get real player index from event key 
	ZPlayer player = ZPlayer(client);
	
	// Validate client
	if(!IsPlayerExist(player.id)){
		return;
	}
	
	if (!player.isZombie())
		return;
	
	// Convert weapon index to ID
	CSWeaponID weaponID = WeaponsGetID(GetEntPropEnt(player.id, Prop_Data, "m_hActiveWeapon"));
	
	// If weapon isn't valid, then stop
	if(!CS_IsValidWeaponID(weaponID)){
		return;
	}
	
	// Get view index
	int viewIndex = GetEntPropEnt(player.id, Prop_Send, "m_hViewModel");
	
	// If weapon isn't valid, then stop
	if(IsValidEdict(viewIndex)){
		
		// Initialize variable
		static int nOldSequence[MAXPLAYERS+1]; static float flOldCycle[MAXPLAYERS+1];
		
		// Get the sequence number and it's playing time
		int nSequence = GetEntProp(viewIndex, Prop_Send, "m_nSequence");
		float flCycle = GetEntPropFloat(viewIndex, Prop_Data, "m_flCycle");
		
		// Validate a knife
		if(nSequence == nOldSequence[player.id] && flCycle < flOldCycle[player.id]){
			
			// Validate animation delay
			if (WeaponsValidateKnife(weaponID)){
				switch (nSequence){
					case 3 : SetEntProp(viewIndex, Prop_Send, "m_nSequence", 4);
					case 4 : SetEntProp(viewIndex, Prop_Send, "m_nSequence", 3);
					case 5 : SetEntProp(viewIndex, Prop_Send, "m_nSequence", 6);
					case 6 : SetEntProp(viewIndex, Prop_Send, "m_nSequence", 5);
					case 7 : SetEntProp(viewIndex, Prop_Send, "m_nSequence", 8);
					case 8 : SetEntProp(viewIndex, Prop_Send, "m_nSequence", 7);
					case 9 : SetEntProp(viewIndex, Prop_Send, "m_nSequence", 10);
					case 10: SetEntProp(viewIndex, Prop_Send, "m_nSequence", 11); 
					case 11: SetEntProp(viewIndex, Prop_Send, "m_nSequence", 10);
				}
			}
			else if (weaponID == CSWeapon_DEAGLE){
				switch (nSequence)
				{
					case 3: SetEntProp(viewIndex, Prop_Send, "m_nSequence", 2);
					case 2: SetEntProp(viewIndex, Prop_Send, "m_nSequence", 1);
					case 1: SetEntProp(viewIndex, Prop_Send, "m_nSequence", 3);
				}
			}
		}
		else{
			// Initialize variable
			static int nPrevSequence[MAXPLAYERS+1]; static float flDelay[MAXPLAYERS+1];
			
			// Returns the game time based on the game tick
			float flCurrentTime = GetEngineTime();
			
			// Play previous animation
			if(nPrevSequence[player.id] != 0 && flDelay[player.id] < flCurrentTime){
				
				SetEntProp(viewIndex, Prop_Send, "m_nSequence", nPrevSequence[player.id]);
				nPrevSequence[player.id] = 0;
			}
			
			// Validate animation delay
			if(flCycle < flOldCycle[player.id]){
				
				// Validate animation
				if(nSequence == nOldSequence[player.id]){
					SetEntProp(viewIndex, Prop_Send, "m_nSequence", 0);
					nPrevSequence[player.id] = nSequence;
					flDelay[player.id] = flCurrentTime + 0.03;
				}
			}
		}
		
		// Update the animation interval delay
		nOldSequence[player.id] = nSequence;
		flOldCycle[player.id] = flCycle;
	}
}
stock CSWeaponID WeaponsGetID(int weaponIndex){
	
	// If weapon isn't valid, then stop
	if(!IsValidEdict(weaponIndex)){
		return CSWeapon_NONE;
	}
	
	// Initialize char
	static char sClassname[16];
	
	// Get weapon classname and convert it to alias
	GetEntityClassname(weaponIndex, sClassname, sizeof(sClassname));
	ReplaceString(sClassname, sizeof(sClassname), "weapon_", "");
	
	// Convert weapon alias to ID
	return CS_AliasToWeaponID(sClassname);
}

public Action asd(int client, int args){
	ZPlayer player = ZPlayer(client);
	if(!player.bStaff) return Plugin_Handled;
	char data[4];
	GetCmdArg(1, data, 4);
	int iData = StringToInt(data);
	if (player.iTeamNum == CS_TEAM_CT){
		if (iData > ZClasses.Length-1)
			return Plugin_Handled;
		
		player.iZombieClass = iData;
		player.iNextZombieClass = iData;
		player.Zombiefy();
	}
	else if (player.iTeamNum == CS_TEAM_T){
		if (iData > HClasses.Length-1)
			return Plugin_Handled;
		
		player.iHumanClass = iData;
		player.iNextHumanClass = iData;
		player.Humanize();
		
		//SetWeaponsRGBA(player.id, RENDER_TRANSCOLOR, 255, 0, 0, 200);
	}
	
	return Plugin_Handled;
}

//////////////////////////////////

public MRESReturn SetModel(int client, Handle hParams){
	
	CreateTimer(0.1, ReHat, client);
	return MRES_Ignored;
}

public Action reloadhat(int client,  int args){
	ZPlayer player = ZPlayer(client);
	
	if (!player.bStaff)
		return Plugin_Handled;
	
	/*
	ScreenFadeAll(RoundToNearest(1.2 * 1000.0), RoundToNearest(1.2 * 1000.0), FFADE_OUT, { 0, 0, 0, 255 });
	
	CreateTimer(2.5, ScreenFadeIn);*/
	
	//StartMode(view_as<int>(MODE_WARMUP));
	CreateTimer(0.1, ReHat, player.id);
	
	return Plugin_Handled;

}

//=====================================================
//				CHARACTER DATA LOAD
//=====================================================
public Action checkAdmin(int client){
	
	if(gServerData.DBI == null)
		return Plugin_Handled;
	
	char query[128];
	
	ZPlayer p = ZPlayer(client);
	int id = p.iPjSeleccionado;
	
	FormatEx(query, sizeof(query), "CALL check_fecha_admin(%d)", id);
	gServerData.DBI.Query(DoNothingCallback, query, client, DBPrio_Low);
	
	return Plugin_Handled;
}
public Action checkVipPrueba(int client){
	char query[128];
	
	ZPlayer p = ZPlayer(client);
	int id = p.iPjSeleccionado;
	
	FormatEx(query, sizeof(query), "CALL checkFechaPrueba(%d)", id);
	gServerData.DBI.Query(DoNothingCallback, query, client, DBPrio_Low);
	
	return Plugin_Handled;
}

public Action loadCharacterData(int client, int charId){
	
	if(gServerData.DBI == null)
		return Plugin_Handled;

	int userid = GetClientUserId(client);
	
	checkAdmin(client);
	checkVipPrueba(client);
	
	char query[1024];
	//FormatEx(query, sizeof(query), "SELECT nombre, experiencia, level, reset, expboost, hClass, zClass, HPoints, HGPoints, ZPoints, ZGPoints, hLMHP, hCritChance, hItemChance, hAuraTime, zMadnessTime, zDamageToLM, zLeech, zMadnessChance, hDamageLevel, hResistanceLevel, hDexterityLevel, zDamageLevel, zDexterityLevel, zHealthLevel, weaponSelected, partyInv, autoClass, autoWeap, autoGPack, bullets, hAlineacion, zAlineacion, gPack, hudColor, nvgColor, tag, hat, hatPoints, accessLevel, refeerCode FROM Characters WHERE id = %d", charId);
	FormatEx(query, sizeof(query), "SELECT `nombre`, \
											`experiencia`, \ 
											`level`, \
											`reset`, \
											`expboost`, \
											`hClass`, \
											`zClass`, \
											`HPoints`, \
											`HGPoints`, \
											`ZPoints`, \
											`ZGPoints`, \
											`hLMHP`, \
											`hCritChance`, \
											`hItemChance`, \
											`hAuraTime`, \
											`zMadnessTime`, \
											`zDamageToLM`, \
											`zLeech`, \
											`zMadnessChance`, \
											`hDamageLevel`, \
											`hResistanceLevel`, \
											`hDexterityLevel`, \
											`zDamageLevel`, \
											`zDexterityLevel`, \
											`zHealthLevel`, \
											`primarySelected`, \
											`secondarySelected`, \
											`partyInv`, \
											`autoClass`, \
											`autoWeap`, \
											`autoGPack`, \
											`bullets`, \
											`hAlineacion`, \
											`zAlineacion`, \
											`gPack`, \
											`hudColor`, \
											`nvgColor`, \
											`tag`, \
											`hat`, \
											`hatPoints`, \
											`accessLevel`, \
											`refeerCode` FROM Characters WHERE id = %d", charId);
	LogToFile("addons/sourcemod/logs/SQL_LOG.txt", query);
	gServerData.DBI.Query(loadCharacterCallback, query, userid, DBPrio_High);
	
	return Plugin_Handled;
}
public void loadCharacterCallback(Database db, DBResultSet results, const char[] error, any data){
	int client = 0;
	
	/* Make sure the client didn't disconnect while the thread was running */
	if ((client = GetClientOfUserId(data)) == 0) {
		return;
	}
	
	if(results == null) {
		PrintToServer("[LOAD-CHARACTER] %s", error);
		return;
	}
	
	if(!results.RowCount){
		PrintToServer("Personaje no encontrado");
		return;
	}
	
	ZPlayer player = ZPlayer(client);
	
	// Initialize variables
	static char name[32];

	int exp, level, reset;
	float expBoost;
	
	int hClass, zClass;
	int hAlineacion, zAlineacion;
	
	int hPoints, hGPoints;
	int zPoints, zGPoints;
	
	int hDamageLevel, hResistanceLevel, hDexterityLevel;
	int zDamageLevel, zDexterityLevel, zHealthLevel;
	
	int hLMHP, hCritChance, hItemChance, hAuraTime;
	int zMadnessTime, zDamageToLM, zLeech, zMadnessChance;
	
	int primarySelected;
	int secondarySelected;
	
	bool partyInv, autoClass, autoWeap, autoGPack, bullets;
	
	int gPack;
	int hudColor, nvgColor;
	int tag, hat, hatPoints;
	int accessLevel;
	static char refeerCode[12];
	
	while(results.FetchRow()){
		results.FetchString(0, name, sizeof(name));
		exp = results.FetchInt(1);
		level = results.FetchInt(2);
		reset = results.FetchInt(3);
		expBoost = results.FetchFloat(4);
		hClass = results.FetchInt(5);
		zClass = results.FetchInt(6);
		hPoints = results.FetchInt(7);
		hGPoints = results.FetchInt(8);
		zPoints = results.FetchInt(9);
		zGPoints = results.FetchInt(10);
		hLMHP = results.FetchInt(11);
		hCritChance = results.FetchInt(12);
		hItemChance = results.FetchInt(13);
		hAuraTime = results.FetchInt(14);
		zMadnessTime = results.FetchInt(15);
		zDamageToLM = results.FetchInt(16);
		zLeech = results.FetchInt(17);
		zMadnessChance = results.FetchInt(18);
		hDamageLevel = results.FetchInt(19);
		hResistanceLevel = results.FetchInt(20);
		hDexterityLevel = results.FetchInt(21);
		zDamageLevel = results.FetchInt(22);
		zDexterityLevel = results.FetchInt(23);
		zHealthLevel = results.FetchInt(24);
		primarySelected = results.FetchInt(25);
		secondarySelected = results.FetchInt(26);
		partyInv = view_as<bool>(results.FetchInt(27));
		autoClass = view_as<bool>(results.FetchInt(28));
		autoWeap = view_as<bool>(results.FetchInt(29));
		autoGPack = view_as<bool>(results.FetchInt(30));
		bullets = view_as<bool>(results.FetchInt(31));
		hAlineacion = results.FetchInt(32);
		zAlineacion = results.FetchInt(33);
		gPack = results.FetchInt(34);
		hudColor = results.FetchInt(35);
		nvgColor = results.FetchInt(36);
		tag = results.FetchInt(37);
		hat = results.FetchInt(38);
		hatPoints = results.FetchInt(39);
		accessLevel = results.FetchInt(40);
		results.FetchString(41, refeerCode, sizeof refeerCode);
	}
	
	// Store data in user variables
	player.iExp = exp;
	player.iLevel = level;
	player.iReset = reset;
	player.flExpBoost = expBoost;
	
	// Clases
	player.iHumanClass = hClass;
	player.iNextHumanClass = hClass;
	player.iZombieClass = zClass;
	player.iNextZombieClass = zClass;
	
	// Puntos
	player.iHPoints = hPoints;
	player.iHGoldenPoints = hGPoints;
	player.iZPoints = zPoints;
	player.iZGoldenPoints = zGPoints;
	
	// Mejoras golden
	player.iLmHpLevel = hLMHP;
	player.iCritChanceLevel = hCritChance;
	player.iItemChanceLevel = hItemChance;
	player.iAuraTimeLevel = hAuraTime;
	player.iMadnessTimeLevel = zMadnessTime;
	player.iDamageToLmLevel = zDamageToLM;
	player.iLeechLevel = zLeech;
	player.iMadnessChanceLevel = zMadnessChance;
	
	// Mejoras humanas
	player.iHDamageLevel = hDamageLevel;
	player.iHResistanceLevel = hResistanceLevel;
	player.iHDexterityLevel = hDexterityLevel;
	
	// Mejoras zombie
	player.iZDamageLevel = zDamageLevel;
	player.iZDexterityLevel = zDexterityLevel;
	player.iZHealthLevel = zHealthLevel;
	
	// Weapons
	player.iSelectedPrimaryWeapon = player.iNextPrimaryWeapon = primarySelected;
	player.iSelectedSecondaryWeapon = player.iNextSecondaryWeapon = secondarySelected;
	
	// Config
	player.bReceivePartyInv = partyInv;
	player.bAutoZClass =  autoClass;
	player.bAutoWeaponUpgrade =  autoWeap;
	player.bAutoGrenadeUpgrade = autoGPack;
	player.bStopSound = bullets;
	
	// Alignments
	player.iHumanAlignment = hAlineacion;
	player.iNextHumanAlignment = hAlineacion;
	player.iZombieAlignment = zAlineacion;
	player.iNextZombieAlignment = zAlineacion;
	
	// Grenade packs
	player.iGrenadePack = gPack;
	player.iNextGrenadePack = gPack;
	
	// Hud color
	player.iHudColor = hudColor;
	
	// NVG color
	player.iNvColor = nvgColor;
	
	// Tags
	player.iTag = tag;
	player.iNextTag = tag;
	
	// Hats
	player.iHat = hat;
	player.iNextHat = hat;
	player.iHatPoints = hatPoints;
	
	// AccessLevel
	player.iAccessLevel = accessLevel;
	
	// Party
	gClientData[client].iPartyUID = PARTY_UNDEFINED;
	gClientData[client].bInParty = false;
	
	player.bAFK = false;
	
	if (!hasLength(refeerCode)){
		associateRefeerCode(client);
	}
	else{
		player.setRefeerCode(refeerCode);
	}
	
	// Stop joining sound
	StopSound(player.id, SNDCHAN_STATIC, WELCOME_SOUND);
	
	// Change name
	player.bCanChangeName = true;
	
	// Update player tag
	player.updateTag();
	
	// Update name
	Format(name, sizeof(name), " %s", name);
	SetClientInfo(client, "name", name);
	
	// Can't change name anymore
	player.bCanChangeName = false;
	
	// Augmented gain?	
	if(expBoost > 1.0){
		//char VipType[32];
		//bool legacy = (flExpBoost > 5.0 && !staff);
		player.bVip = true;
		//Format(VipType, sizeof(VipType), "%s VIP x%d %s |", legacy ? "✪":"", RoundToCeil(flExpBoost), legacy ? "✪":"");
		//CS_SetClientClanTag(client, VipType);
	}
	
	if (player.bStaff){
		TranslationPrintToChatAll("Welcome staff", name);
	}
	else if (player.bVip){
		TranslationPrintToChatAll("Welcome vip", RoundToCeil(expBoost), name);
		
		// Show expiration time
		getVencimientoTime(client, 0);
	}
	
	// Stop here in case he is new to the server
	if (player.bRecentlyRegistered){
		showMenuHMejoras(client);
	}
	else{
		JoinPlayer(client);
	}
}

// Join player ingame
void JoinPlayer(int client){
	
	ZPlayer player = ZPlayer(client);
	
	// Push into players array
	Players.Push(player.id);
	
	// Finish csgo warmup if not already finished
	FinishCSGOWarmup();
	
	// Now, he's officially in game
	player.bInUser = false;
	player.bInPassword = false;
	player.bInCreatingCharacter = false;
	player.bInTagCreation = false;
	
	player.bLogged = true;
	player.bInGame = true;
	player.bLoaded = true;
	
	// Join to CT
	player.iTeamNum = CS_TEAM_CT;
	
	// Check level and points
	player.checkLevelUp();
	player.checkAutoUpgrade(false);
	player.checkAutoDowngrade(false);
	tiersOnPlayerUpdateTier(client);
	
	// Should he respawn?
	CreateTimer(1.5, respawnPlayer, player.id);
	
	// Player just logged for the first time
	player.bRecentlyRegistered = false;
	
	CheckQuantityPlaying();
	RoundEndOnClientLogin();
}

public Action saveCharacterData(int client){
	
	if(gServerData.DBI == null){
		return Plugin_Handled;
	}
	
	/*if (!IsPlayerExist(client)){
		return Plugin_Handled;
	}*/
	
	ZPlayer player = ZPlayer(client);
	
	if (!player.bLoaded){
		return Plugin_Handled;
	}
	
	SafeEndPlayerCombo(client);
	
	if (gClientData[client].bInParty){
		ZParty party = ZParty(findPartyByUID(gClientData[client].iPartyUID));
		
		if (party.id != -1){
			SafeEndComboParty(party.id);
		}
	}
	
	char query[1920];
	if(player.iHat < 0){
		player.iHat = 0;
	}
	
	if(player.iPjSeleccionado < 0){
		return Plugin_Handled;
	}
	
	if (player.iLevel <= 0){
		return Plugin_Handled;
	}
	
	// BACKUP
	FormatEx(query, sizeof(query), "UPDATE Characters SET `lastLogin` = current_timeStamp(), \
						`experiencia` = %d, \
						`level` = %d, \
						`reset` = %d, \
						`hClass` = %d, \
						`zClass` = %d, \
						`HPoints` = %d, \
						`HGPoints` = %d, \
						`ZPoints` = %d, \
						`ZGPoints` = %d, \
						`hDamageLevel` = %d, \
						`hResistanceLevel` = %d, \
						`hDexterityLevel` = %d, \
						`zDamageLevel` = %d, \
						`zDexterityLevel` = %d, \
						`zHealthLevel` = %d, \
						`primarySelected` = %d, \
						`secondarySelected` = %d, \
						`partyInv` = %d, \
						`autoClass` = %d, \
						`autoWeap` = %d, \
						`autoGPack` = %d,\
						`bullets` = %d, \
						`hAlineacion` = %d, \
						`zAlineacion` = %d, \
						`gPack` = %d, \
						`hudColor` = %d, \
						`nvgColor` = %d, \
						`tag` = %d, \
						`hat` = %d, \
						`hatPoints` = %d, \
						`hLMHP` = %d, \
						`hCritChance` = %d, \
						`hItemChance` = %d, \
						`hAuraTime` = %d, \
						`zMadnessTime` = %d, \
						`zDamageToLM` = %d, \
						`zLeech` = %d, \
						`zMadnessChance` = %d WHERE `id` = %d;",
						player.iExp, player.iLevel, player.iReset, player.iHumanClass, player.iZombieClass, 
						player.iHPoints, player.iHGoldenPoints ,player.iZPoints, player.iZGoldenPoints, 
						player.iHDamageLevel, player.iHResistanceLevel, 
						player.iHDexterityLevel, player.iZDamageLevel, 
						player.iZDexterityLevel,player.iZHealthLevel,
						player.iSelectedPrimaryWeapon, player.iSelectedSecondaryWeapon, 
						player.bReceivePartyInv, player.bAutoZClass, 
						player.bAutoWeaponUpgrade, player.bAutoGrenadeUpgrade, 
						player.bStopSound, 
						player.iHumanAlignment, player.iZombieAlignment, 
						player.iGrenadePack,
						player.iHudColor, player.iNvColor, 
						player.iTag, player.iHat, player.iHatPoints,
						player.iLmHpLevel, player.iCritChanceLevel, player.iItemChanceLevel, player.iAuraTimeLevel,
						player.iMadnessTimeLevel, player.iDamageToLmLevel, player.iLeechLevel, player.iMadnessChanceLevel,
						/*SIEMPRE AL ULTIMO*/ player.iPjSeleccionado);
	gServerData.DBI.Query(saveCharacterCallback, query, client, DBPrio_Low);
	
	// Update piu points to account
	UpdatePiuPoints(client, player.iPiuPoints);
	
	return Plugin_Handled;
}
public void saveCharacterCallback(Database db, DBResultSet results, const char[] error, any data){
	
	//LogToFile("SQL_LOG.txt", StrEqual(error, "") ? "Save successfull":error);
	if(!StrEqual(error, "")){
		
		char query[1920];
		ZPlayer player = ZPlayer(data);
		
		FormatEx(query, sizeof(query), "UPDATE Characters SET `lastLogin` = current_timeStamp(), \
						`experiencia` = %d, \
						`level` = %d, \
						`reset` = %d, \
						`hClass` = %d, \
						`zClass` = %d, \
						`HPoints` = %d, \
						`HGPoints` = %d, \
						`ZPoints` = %d, \
						`ZGPoints` = %d, \
						`hDamageLevel` = %d, \
						`hResistanceLevel` = %d, \
						`hDexterityLevel` = %d, \
						`zDamageLevel` = %d, \
						`zDexterityLevel` = %d, \
						`zHealthLevel` = %d, \
						`primarySelected` = %d, \
						`secondarySelected` = %d, \
						`partyInv` = %d, \
						`autoClass` = %d, \
						`autoWeap` = %d, \
						`autoGPack` = %d,\
						`bullets` = %d, \
						`hAlineacion` = %d, \
						`zAlineacion` = %d, \
						`gPack` = %d, \
						`hudColor` = %d, \
						`nvgColor` = %d, \
						`tag` = %d, \
						`hat` = %d, \
						`hatPoints` = %d, \
						`hLMHP` = %d, \
						`hCritChance` = %d, \
						`hItemChance` = %d, \
						`hAuraTime` = %d, \
						`zMadnessTime` = %d, \
						`zDamageToLM` = %d, \
						`zLeech` = %d, \
						`zMadnessChance` = %d WHERE `id` = %d;",
						player.iExp, player.iLevel, player.iReset, player.iHumanClass, player.iZombieClass, 
						player.iHPoints, player.iHGoldenPoints ,player.iZPoints, player.iZGoldenPoints, 
						player.iHDamageLevel, player.iHResistanceLevel, 
						player.iHDexterityLevel, player.iZDamageLevel, 
						player.iZDexterityLevel,player.iZHealthLevel,
						player.iSelectedPrimaryWeapon, player.iSelectedSecondaryWeapon, 
						player.bReceivePartyInv, player.bAutoZClass, 
						player.bAutoWeaponUpgrade, player.bAutoGrenadeUpgrade, 
						player.bStopSound, 
						player.iHumanAlignment, player.iZombieAlignment, 
						player.iGrenadePack,
						player.iHudColor, player.iNvColor, 
						player.iTag, player.iHat, player.iHatPoints,
						player.iLmHpLevel, player.iCritChanceLevel, player.iItemChanceLevel, player.iAuraTimeLevel,
						player.iMadnessTimeLevel, player.iDamageToLmLevel, player.iLeechLevel, player.iMadnessChanceLevel,
						/*SIEMPRE AL ULTIMO*/ player.iPjSeleccionado);
		
		LogError("[SAVE] %s \nQuery: %s", error, query);
	}
}

//public Action deleteCharacter(int client){
//	char query[255];
//	
//	ZPlayer player = ZPlayer(client);
//	int idChar = player.getIdPjInSlot(player.iPjEnMenu);
//	FormatEx(query, sizeof(query),"DELETE FROM Characters WHERE id = %d", idChar);
//	bool done = SQL_FastQuery(ngServerData.DBI, query);
//	if(!done) {
//		char error[255];
//		SQL_GetError(gServerData.DBI, error, sizeof(error));
//		PrintToServer("[DELETE-CHARACTER] %s", error);
//	}
//}

public Action getVencimientoTime(int client, int args){

	if(gServerData.DBI == null)
		return Plugin_Handled;

	ZPlayer player = ZPlayer(client);

	char query[1024];
	FormatEx(query, sizeof(query), "SELECT DATE_FORMAT(fechaInicio, 'PCTd/PCTm/PCTy a las PCTH:PCTi:PCTS'), DATE_FORMAT(fechaVencimiento, 'PCTd/PCTm/PCTy a las PCTH:PCTi:PCTS') FROM Admin WHERE charId=%d AND vencido=0", player.iPjSeleccionado);
	ReplaceString(query, sizeof(query), "PCT", "%", true);
	
	int userid = GetClientUserId(client);
	gServerData.DBI.Query(VencimientoTimeCallback, query, userid, DBPrio_Low);
	
	return Plugin_Handled;
}
public void VencimientoTimeCallback(Database db, DBResultSet results, const char[] error, any data){
	
	int client = 0;
	
	/* Make sure the client didn't disconnect while the thread was running */
	if ((client = GetClientOfUserId(data)) == 0) {
		return;
	}
	
	if(!StrEqual(error, "")){
		PrintToServer("[ERROR-LOGGED] %s", error);
		return;
	}
	if(results.HasResults){
		static char fechaI[64], fechaV[64];
		while(results.FetchRow()){
			results.FetchString(0, fechaI, sizeof(fechaI));
			results.FetchString(1, fechaV, sizeof(fechaV));
			TranslationPrintToChat(client, "Vip expiration date", fechaI, fechaV);
		}
	}else{
		TranslationPrintToChat(client, "Not vip");
	}
	
}

///////////////////////////////////////////////////////

// Weapons
Action WeaponsOnRunCmd(int client, int &iButtons, int iLastButtons, int weaponID){
	
	// Validate use hook
	if (iButtons & IN_USE){
		
		// Validate overtransmitting
		if (!(iLastButtons & IN_USE)){
			// Forward event to sub-modules
		   // Weapons_OnUse(client);
		}
	}
	
	// Gets active weapon index from the client
	static int weapon; weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	
	// Validate weapon and access to hook
	if (weapon == -1 /*|| !gClientData[client].RunCmd*/){
		return Plugin_Continue;
	}
	// Forward event to sub-modules
	return Weapons_OnWeaponRunCmd(client, iButtons, iLastButtons, weapon, weaponID);
}

/**
 * @brief Called on each frame of a weapon holding.
 *
 * @param client			The client index.
 * @param iButtons		  The buttons buffer.
 * @param iLastButtons	  The last buttons buffer.
 * @param weapon			The weapon index.
 * @param weaponID		  The weapon id.
 *
 * @return				  Plugin_Continue to allow buttons. Anything else 
 *								(like Plugin_Changed) to change buttons.
 **/
public Action Weapons_OnWeaponRunCmd(int client, int &iButtons, int iLastButtons, int weapon, int weaponID){
	
	// Validate custom weapon
	Bazooka_OnWeaponRunCmd(client, iButtons, iLastButtons, weapon, weaponID);
	Chainsaw_OnWeaponRunCmd(client, iButtons, iLastButtons, weapon, weaponID);
	
	// Allow button
	return Plugin_Continue;
}


Handle startGrenadeRain_Timer;
Handle grenadeRain_Timer;
ArrayList alivePlayerArray;
bool grenadesFalling = false;
int grenades = 0;

#define GRENADE_RAIN_TIME_START 10
#define GRENADE_RAIN_TIME_END 	20
#define GRENADE_RAIN_TIME_DROP_INTERVAL 1.0
#define GRENADE_RAIN_GRENADE_QUANTITY  	8
#define GRENADE_RAIN_GRENADE_RADIUS 	230.0
#define GRENADE_RAIN_GRENADE_GRAVITY 	100.0
#define GRENADE_RAIN_HEIGHT 			200.0


/////////////////////////// EXPERIMENTAL
public Action StartMolotovRain(int client, int args){
	TimerCallBack(null);
}
void GrenadeRain_OnStartMode(){
	
	if (grenadeRain_Timer != null){
		delete grenadeRain_Timer;
		grenadeRain_Timer = null;
	}
	
	if (startGrenadeRain_Timer != null){
		delete startGrenadeRain_Timer;
		startGrenadeRain_Timer = null;
	}
	
	//ConVar roundtime = FindConVar("mp_roundtime");
	//int time_end = RoundToFloor(roundtime.FloatValue*60.0), time_start = GRENADE_RAIN_TIME_START;
	//if((time_end-GRENADE_RAIN_TIME_END)-time_start >= 0)
		//time_end -= GRENADE_RAIN_TIME_END;
	
	int starttime = GetRandomInt(GRENADE_RAIN_TIME_START, GRENADE_RAIN_TIME_END);
	startGrenadeRain_Timer = CreateTimer(float(starttime), TimerCallBack);
}
void GrenadeRain_OnRoundEnd(){
	
	if (grenadeRain_Timer != null){
		delete grenadeRain_Timer;
		grenadeRain_Timer = null;
	}
	
	if (startGrenadeRain_Timer != null){
		delete startGrenadeRain_Timer;
		startGrenadeRain_Timer = null;
	}
	
	grenadesFalling = false;
	grenades = 0;
}
stock bool IsValidPlayer(int client){
	return client > 0 && client <= MAXPLAYERS && IsClientInGame(client) && IsPlayerAlive(client) && ZPlayer(client).isHuman();
}
public Action TimerCallBack(Handle timer){
	
	if(grenadesFalling) return Plugin_Continue;
	
	if(!ActualMode.is(MODE_MUTATION)) return Plugin_Continue;
	
	int player = findValidPlayer();
	
	if (!player) return Plugin_Continue;
	
	grenadesFalling = true;
	startGrenadeRain_Timer = null;
	grenadeRain_Timer = null;
	
	grenadeRain_Timer = CreateTimer(GRENADE_RAIN_TIME_DROP_INTERVAL, GrenadeRain, player, TIMER_REPEAT);
	
	return Plugin_Continue;
}
stock int findValidPlayer(){
	
	// choose random player
	int valid = 0;
	alivePlayerArray = CreateArray(1);
	for (int i = 1; i <= MaxClients; i++){
		if (IsValidPlayer(i)){
			PushArrayCell(alivePlayerArray, i);
			valid++;
		}
	}
	
	if (!valid)
		return -1;
	
	int random_player = GetArrayCell(alivePlayerArray, GetRandomInt(1, GetArraySize(alivePlayerArray)) - 1);
	int player = GetClientOfUserId(GetClientUserId(random_player));
	
	return player;
}

float grenadePos[3];
public Action GrenadeRain(Handle timer, any player){
	if (++grenades > GRENADE_RAIN_GRENADE_QUANTITY){
		grenades = 0;
		grenadesFalling = false;
		grenadeRain_Timer = null;
		return Plugin_Stop;
	}
	
	if (!IsValidPlayer(player)){
		grenadesFalling = false;
		grenadeRain_Timer = null;
		TimerCallBack(null);
		return Plugin_Stop;
	}
	
	// create molotov
	int molly = CreateEntityByName("flashbang_projectile");
	if (molly == -1) return Plugin_Continue;
	
	// set molotov's position
	float rad_x = GetRandomFloat(0.0, GRENADE_RAIN_GRENADE_RADIUS), rad_y = GetRandomFloat(0.0, GRENADE_RAIN_GRENADE_GRAVITY);
	if (GetRandomInt(0, 1) > 0) rad_x = -rad_x;
	if (GetRandomInt(0, 1) > 0) rad_y = -rad_y;
	
	GetEntPropVector(player, Prop_Data, "m_vecOrigin", grenadePos);
	
	grenadePos[0] += rad_x;
	grenadePos[1] += rad_y;
	grenadePos[2] += GRENADE_RAIN_HEIGHT;
	
	SetEntPropString(molly, Prop_Data, "m_iName", "infectgrenade_projectile");
	
	DispatchSpawn(molly);
	TeleportEntity(molly, grenadePos, NULL_VECTOR, NULL_VECTOR);
	SetEntityGravity(molly, GRENADE_RAIN_GRENADE_GRAVITY/100.0);
	
	return Plugin_Continue;
}

// Special alignment: Mutation
//=====================================================
//					MUTANT HUMAN
//=====================================================
void CreateMutationTimer(int client){
	
	ZPlayer player = ZPlayer(client);
	if (player.hMutationTimer != null){
		delete player.hMutationTimer;
	}
	
	player.hMutationTimer = CreateTimer(GetRandomFloat(45.0, 60.0), Timer_Mutation, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

bool isAvailableToMutate(int client){
	
	if (!IsPlayerExist(client, true)){
		return false;
	}
	
	ZPlayer player = ZPlayer(client);
	if (player.iHumanAlignment != iMutantAlignment && !ActualMode.is(MODE_MUTATION)){
		return false;
	}
		
	if (!player.isType(PT_HUMAN)){
		return false;
	}

	if (!ActualMode.bInfection){
		return false;
	}
	
	int iHumans = fnGetHumans();
	if (iHumans <= 1){
		return false;
	}
	
	return true;
}

public Action Timer_Mutation(Handle hTimer, int client){

	if (!isAvailableToMutate(client))
		return Plugin_Continue;
	
	int iZombies = fnGetZombies();
	if (calculateChances(iZombies <= (iPlayersQuantity * ZOMBIES_AMOUNT_TO_RAISE_CHANCES_TO_MUTATE) ? MUTATION_CHANCES_RAISED : MUTATION_CHANCES_STANDARD, 1, 0)){
		
		CreateAura(client, { 0, 90, 0, 130 }, true);
		CreateTimer(3.0, MutatePlayer, client, TIMER_FLAG_NO_MAPCHANGE);
		ShakeClientScreen(client, 60.0, 1.0, 3.0);
	}
	ZPlayer(client).hMutationTimer = null;
	return Plugin_Stop;
}
public Action MutatePlayer(Handle hTimer, int client){
	
	ZPlayer player = ZPlayer(client);
	player.hMutationTimer = null;
	
	if (!IsPlayerExist(client, true)){
		return Plugin_Stop;
	}
	
	RemoveAura(client);
	
	if (!ActualMode.bInfection){
		return Plugin_Stop;
	}
	
	if (player.iHumanAlignment != iMutantAlignment){
		return Plugin_Stop;
	}
	
	if (!player.isType(PT_HUMAN)){
		return Plugin_Stop;
	}
	
	int iHumans = fnGetHumans();
	if (iHumans <= 1){
		return Plugin_Stop;
	}
	
	player.Zombiefy();
	
	//ShowSyncHudTextAll(/*0.425*/-1.0, 0.20, 3.0, colors1, colors2, 1, 1.0, 1.0, 1.0, gServerData.GameSync, sData);
	char sName[48];
	GetClientName(player.id, sName, sizeof(sName));
	TranslationPrintHudTextAll(gServerData.GameSync, 0.03, 0.32, 3.0, 0, 200, 30, 255, 1, 1.0, 1.0, 1.0, "Has mutated", sName);
	
	return Plugin_Stop;
}


int g_iBotStuckCounts;
int g_iBotStuckindex[128];
float g_fBotStuckPush = 2.0;

/**
 * Sets the Absolute velocity of an entity.
 * The absolute velocity is the sum of the local
 * and base velocities. It's the actual value used to move.
 *
 * @param entity		Entity index.
 * @param vel			An 3 dim array
 */
stock void Entity_SetAbsVelocity(int entity, const float vec[3]){
	
	// We use TeleportEntity to set the velocity more safely
	// Todo: Replace this with a call to CBaseEntity::SetAbsVelocity()
	TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vec);
}

stock bool IsValidClient(int client){
	
	if (client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client)){
		return true;
	}
	return false;
}
public Action Timer_CheckIfBotsStuck(Handle timer, any userid){
	
	float l_fClientVelocity[3];
	for (int i = 1; i <= MaxClients; i++){
		
		if (IsValidClient(i) && IsFakeClient(i) && IsPlayerAlive(i)){
			
			GetEntPropVector(i, Prop_Data, "m_vecAbsVelocity", l_fClientVelocity);
			
			if (l_fClientVelocity[0] < 30.0 && l_fClientVelocity[0] > -30.0 && l_fClientVelocity[1] < 30.0 && l_fClientVelocity[1] > -30.0){
				g_iBotStuckindex[i]++;
			}
			else{
				g_iBotStuckindex[i] = 0;
			}
			
			if (g_iBotStuckindex[i] > g_iBotStuckCounts){
				
				if (ZPlayer(i).isType(PT_ZOMBIE)){
					AntiStickOnCommandCatched(i, 0);
				}
				else{
					l_fClientVelocity[0] -= GetRandomInt(50, 250);
					l_fClientVelocity[1] -= GetRandomInt(50, 250);
					l_fClientVelocity[2] = g_fBotStuckPush * 5;
					Entity_SetAbsVelocity(i, l_fClientVelocity);
				}
				
				g_iBotStuckindex[i] = 0;
			}
		}
	}

	return Plugin_Handled;
}

//=====================================================
//					EVENTS
//=====================================================

// Event on weapon fire
public Action EventWeaponFire(Event gEventHook, const char[] gEventName, bool dontBroadcast){
	ZPlayer player = ZPlayer(GetClientOfUserId(gEventHook.GetInt("userId")));
	
	if(!IsPlayerExist(player.id, true))
		return Plugin_Handled;
	
	int weapon = GetEntPropEnt(player.id, Prop_Data, "m_hActiveWeapon");
	
	if (!weapon)
		return Plugin_Handled;
	
	if (!IsValidEntity(weapon))
		return Plugin_Handled;
	
	if (!player.isHuman())
		return Plugin_Handled;
	
	char classname[64];
	GetEdictClassname(weapon, classname, sizeof(classname));
	if (StrContains(classname, "_projectile") != -1 || StrContains(classname, "grenade") != -1 || StrContains(classname, "flashbang") != -1 || StrContains(classname, "knife") != -1){
		return Plugin_Continue;
	}
	
	/*
	char sWeapon[32];
	GetEntPropString(weapon, Prop_Data, "m_iName", sWeapon, sizeof(sWeapon));*/
	
	int ammo = GetEntProp(weapon, Prop_Data, "m_iClip1");
	
	if(ammo <= 1){
		SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", 200);
	}
	
	if(player.bInfiniteAmmo){
		if (StrEqual(classname, "weapon_famas") || StrEqual(classname, "weapon_glock")){
			if (IsBurstMode(weapon)){
				SetEntProp(weapon, Prop_Send, "m_iClip1", ammo+3);
				return Plugin_Handled;
			}
		}
		
		SetEntProp(weapon, Prop_Send, "m_iClip1", ammo+1);
	}
	
	return Plugin_Handled;
}

// Event decoy started
public Action Event_DecoyStarted(Event event, const char[] name, bool dontBroadcast){
	
	int entity = event.GetInt("entityid");
	char decoyName[16];
	GetEntPropString(entity, Prop_Data, "m_iName", decoyName, sizeof(decoyName));
	if(!StrEqual(decoyName, "normal", false)){
		//AcceptEntityInput(entity, "Kill");
		RemoveEntity(entity);
	}

	return Plugin_Handled;
}

public void EventsOnInit(){
	
	HookEvent("player_given_c4", EventPlayerGivenC4, EventHookMode_Pre);
	
	// Round hooks
	HookEvent("round_prestart", EventPreRoundStart, EventHookMode_Pre);
	HookEvent("round_start", EventPostRoundStart, EventHookMode_Post);
	
	// Round end
	HookEvent("round_end", EventRoundEnd, EventHookMode_Pre);
	
	// Win panel round
	HookEvent("cs_win_panel_round", EventBlockBroadCast, EventHookMode_Pre);
	
	// Weapon reload
	HookEvent("weapon_reload", EventWeaponReload, EventHookMode_Pre);
	
	// Events to remove hat
	//HookEvent("player_team", EventRemoveHat, EventHookMode_Post);
	
	// Spawn hooks
	HookEvent("player_spawn", EventPrePlayerSpawn, EventHookMode_Pre);
	HookEvent("player_spawn", EventPostPlayerSpawn, EventHookMode_Post);
	
	// Hook event messages
	HookEvent("player_team", EventPrePlayerTeam, EventHookMode_Pre);
	//HookEvent("player_radio", EventRadioMessage, EventHookMode_Pre);
	
	// Block name change
	HookEvent("player_changename", OnNameChange, EventHookMode_Pre);
	HookEvent("player_changename", EventBlockBroadCast, EventHookMode_Post);
	
	// Hook player events
	HookEvent("player_jump", JumpBoostOnClientJump, EventHookMode_Post);
	
	// Hook stupid warmup message
	//HookUserMessage(GetUserMessageId("TextMsg"), TextMsg, true); 
	
	// Hook when a player is fully connected
	HookEvent("player_connect_full", EventOnPlayerConnectedFull, EventHookMode_Post);
	
	// Mute bullets sounds
	AddTempEntHook("Shotgun Shot", ShotgunShotEntHook);
	AddNormalSoundHook(NormalSoundHook);
	
	// Sniper lightning effect
	AddTempEntHook("Shotgun Shot", Hook_BulletShot);
	HookEvent("bullet_impact", Event_BulletImpact);
}

// Event on given C4
public Action EventPlayerGivenC4(Event gEventHook, const char[] gEventName, bool dontBroadcast){
	return Plugin_Handled;
}

// Event pre round start
public Action EventPreRoundStart(Event gEventHook, const char[] gEventName, bool dontBroadcast){
	
	BalanceTeams(CS_TEAM_CT);
	
	if (!bWarmupStarted || bWarmupEnded){
		gServerData.RoundNew = true;
		gServerData.RoundEnd = false;
		gServerData.RoundStart = false;
		
		ZGameModes.GetArray(view_as<int>(NO_MODE), ActualMode);
	}
	
	ZPlayer player;
	for (int client = 1; client <= MaxClients; client++){
		
		player = ZPlayer(client);
		
		if (!IsPlayerExist(player.id))
			continue;
		
		if (player.hFreezeTimer != INVALID_HANDLE){
			KillTimer(player.hFreezeTimer);
			player.hFreezeTimer = INVALID_HANDLE;
		}
		
		player.iInfectorId = -1;
		player.iInfectedId = -1;
	}
	
	ExtraItemsOnPreRoundStart();
	
	return Plugin_Continue;
}

// Event post round start
public Action EventPostRoundStart(Event gEventHook, const char[] gEventName, bool dontBroadcast){
	
	LocateMercenary();
	
	HappyHoursOnPostRoundStart();
	ExtraItemsOnPostRoundStart();
	
	ZPlayer player;
	for (int i = 1; i <= MaxClients; i++){
		player = ZPlayer(i);
		
		if (!player.bLogged){
			continue;
		}
		
		// Check if player has pending piu points
		readPendingPiuPoints(i);
		
		if(!IsPlayerExist(i, true))
			continue;
		
		if(player.iTag != player.iNextTag){
			player.iTag = player.iNextTag;
			
			player.updateTag();
		}
		
		if (player.hasNightvision())
			player.RemoveNightvision();
		
		CreateNightvisionLight(player.id);
		
		if(player.bInGame){
			player.Humanize();
			
			// Give him an extra item if chances return truth
			if (player.iItemChanceLevel){
				if (GetUpgradeChance(player.id, 2)){
					applyExtraItemEffect(player.id, view_as<int>(EXTRA_ITEM_INFAMMO));
				}
			}
		}
	}
	
	if(WARMUP_DURATION > 1.0){
		if (!bWarmupEnded){
			if (bWarmupStarted){
				WarmupTurnIntoRandomAll();
			}
			else{
				StartMode(view_as<int>(MODE_WARMUP));
			}
		}
		else{
			// Print some info
			SendAnnouncement();
			
			/*if (ActualMode.is(NO_MODE)){
				if (hCounter != null){
					delete hCounter;
					hCounter = null;
					iCounter = ROUND_START_COUNTDOWN;
				}
				hCounter = CreateTimer(1.0, TimerShowCountdown, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}*/
		}
	}
	else{
		
		// Print some info
		SendAnnouncement();
		
		/*if (ActualMode.is(NO_MODE)){
			if (hCounter != null){
				delete hCounter;
				hCounter = null;
				iCounter = ROUND_START_COUNTDOWN;
			}
			hCounter = CreateTimer(1.0, TimerShowCountdown, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}*/
	}
	
	/*if (gServerData.RoundNumber >= ROUNDS_TO_END_MAP){
		StartMapVote();
	}*/
	
	//StartLightning();
	
	return Plugin_Continue;
}

// Event round end
public Action EventRoundEnd(Event gEventHook, const char[] gEventName, bool dontBroadcast){
	
	// Save everyone's data
	//DataBaseOnSaveAllData();
	
	// Clean aura shields array
	AuraShields.Clear();
	BlackHoles.Clear();
	
	GrenadeRain_OnRoundEnd();
	
	ExtraItemsOnRoundEnd();
	
	// Ending round, removal time!
	int reason = gEventHook.GetInt("reason");
	ZPlayer player;
	for (int i = 1; i <= MaxClients; i++){
		player = ZPlayer(i);
		
		if(IsPlayerExist(player.id)){
			
			player.bFlashlight = false;
			
			if (player.bAlive){
				player.removeGlow();
			}
			
			player.bNightvisionOn = false;
			player.iRoundDeaths = 0;
			player.RemoveNightvision();
		}
	}
	
	// Define which team wins
	int rSound;
	if(reason == 9){
		GamemodesStats_OnRoundEnd(true);
		
		TranslationPrintHudTextAll(gServerData.GameSync, -1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, 255, 45, 0, 255, 1, 1.0, 1.0, 1.0, "Zombies win");
		rSound = GetRandomInt(0, sizeof(ZWinSounds)-1);
		EmitSoundToAll(ZWinSounds[rSound], SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_, 0.4);
	} 
	else{
		GamemodesStats_OnRoundEnd(false);
		
		TranslationPrintHudTextAll(gServerData.GameSync, -1.0, ANNOUNCER_HUD_Y_POSITION, 3.0, 0, 45, 255, 255, 1, 1.0, 1.0, 1.0, "Humans win");
		rSound = GetRandomInt(0, sizeof(HWinSounds)-1);
		EmitSoundToAll(HWinSounds[rSound], SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_, 0.4);
	}
	
	// Reset variables
	if (!bWarmupStarted || bWarmupEnded){
		
		// Reset actual gamemode
		ZGameModes.GetArray(view_as<int>(NO_MODE), ActualMode);
		
		// Refresh booleans
		gServerData.RoundNew = false;
		gServerData.RoundEnd = true;
		gServerData.RoundStart = false;
		eventmode = false;
		
		// If the counter is still alive, kill it
		/*if(hCounter != null){
			delete hCounter;
			hCounter = null;
			iCounter = ROUND_START_COUNTDOWN;
		}*/
	}
	
	// Show screenfade
	/*if (bCSGOWarmupEnded && bWarmupEnded){
		//ScreenFadeAll(2.4, 2.8, FFADE_OUT, { 0, 0, 0, 255 });
		//CreateTimer(2.8, ScreenFadeIn);
		
		// Add ended rounds number
		gServerData.RoundNumber = gServerData.RoundNumber+1;
		
	}*/
	
	return Plugin_Continue;
}

// Event to block broadcast
public Action EventBlockBroadCast(Event gEventHook, const char[] gEventName, bool dontBroadcast){
	if (!dontBroadcast) {
		SetEventBroadcast(gEventHook, true);
	}

	return Plugin_Handled;
}

// Event pre player spawn
public Action EventPrePlayerSpawn(Event gEventHook, const char[] gEventName, bool dontBroadcast){
	
	int client = GetClientOfUserId(gEventHook.GetInt("userid"));
	
	if (!IsPlayerExist(client))
		return Plugin_Handled;
	
	ZPlayer player = ZPlayer(client);
	
	if(!IsFakeClient(player.id) && (!player.bInGame || !player.bLogged)) return Plugin_Handled;
	
	if (player.isType(PT_HUMAN))
		player.bBoughtWeapons = false;
		
	// If BOT, randomize vars
	if(IsFakeClient(player.id)){
		player.iLevel = GetRandomInt(20, RESET_LEVEL);
		
		int avgResets = getAveragePlayersReset();
		player.iReset = GetRandomInt(getAverageMins(avgResets, 20), getAverageMaxs(avgResets, 30));
		
		player.bAutoWeaponUpgrade = true;
		player.bAutoGrenadeUpgrade = true;
		player.bAutoZClass = true;
		
		player.iHumanAlignment = player.iNextHumanAlignment = GetRandomInt(0, HAlignments.Length-1);
		player.iZombieAlignment = player.iNextZombieAlignment = GetRandomInt(0, ZAlignments.Length-1);
		
		//player.iNextHat = GetRandomInt(0, Hats.Length-1);
		player.iHat = 0;
		player.iNextHat = 0;
		
		player.iTag = 0;
		player.iNextTag = 0;
		player.updateTag();
		tiersOnPlayerUpdateTier(client);
		
		player.checkAutoUpgrade(false);
		
		/*
		player.iHumanClass = GetRandomInt(0, HClasses.Length-1);
		player.iZombieClass = GetRandomInt(0, ZClasses.Length-1);
		player.iPrimaryWeapon = GetRandomInt(0, 23);
		//player.iSecondaryWeapon = GetRandomInt(0, 8);*/
		
		// Human upgrades averaging
		int hUpgrade[3];
		for (int i; i < view_as<int>(H_RESET); i++){
			hUpgrade[i] = getAveragePlayersUpgrades(i, true);
		}
		
		// Setting values
		player.iHDamageLevel = GetRandomInt(getAverageMins(hUpgrade[0], 40), getAverageMaxs(hUpgrade[0], 1));
		player.iHResistanceLevel = GetRandomInt(getAverageMins(hUpgrade[1], 20), getAverageMaxs(hUpgrade[1], 10));
		player.iHDexterityLevel = GetRandomInt(getAverageMins(hUpgrade[2], 20), getAverageMaxs(hUpgrade[2], 10));
		
		
		// Zombie upgrades averaging
		int zUpgrade[3];
		for (int i; i < view_as<int>(Z_RESET); i++){
			zUpgrade[i] = getAveragePlayersUpgrades(i, false);
		}
		
		// Setting values
		//player.iZDamageLevel = GetRandomInt(getAverageMins(zUpgrade[0], 20), getAverageMaxs(zUpgrade[0], 10));
		player.iZDamageLevel = 0;
		player.iZHealthLevel = GetRandomInt(getAverageMins(zUpgrade[1], 20), getAverageMaxs(zUpgrade[1], 10));
		//player.iZDexterityLevel = GetRandomInt(getAverageMins(zUpgrade[2], 20), getAverageMaxs(zUpgrade[2], 10));
		player.iZDexterityLevel = GetRandomInt(0, 10);
	}
	
	return Plugin_Continue;
}

// Event post player spawn
public Action EventPostPlayerSpawn(Event event, const char[] name, bool dontBroadcast){
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	// He doesnt exist, doesn't matter
	if (!IsPlayerExist(client))
		return Plugin_Handled;
		
	if (IsFakeClient(client)){
		SetEntData(client, Collision_Offsets, 2, 1, true);
	}
	
	ZPlayer player =  ZPlayer(client);
	
	// Nightvision light create
	if ((player.isHuman() || player.isZombie()) && player.bAlive){
		if (!player.hasNightvision()){
			CreateNightvisionLight(player.id);
		}
		else{
			player.toggleNv(true);
		}
	}
	
	// If respawned and there is no active gamemode
	if(gServerData.RoundNew){
		player.Humanize();
	}
	
	// Cache important variables
	player.iPredictedViewModelIndex = Weapon_GetViewModelIndex(player.id, -1);
	
	// Store client's spawn origins
	GetClientAbsOrigin(player.id, gfSpawnOrigins[player.id]);
	
	// Remove any existing lasermine and give him the default value
	RemoveLasermines(player.id);
	
	// If mode is Warmup
	if (ActualMode.is(MODE_WARMUP)){
		TurnIntoRandom(player.id);
	}
	
	// Apply new hat
	if(player.iNextHat != player.iHat){
		player.iHat = player.iNextHat;
	}
	
	// Deploy hat
	CreateTimer(0.1, ReHat, GetClientUserId(client));
	
	if (gClientData[client].bInParty){
		CreateTimer(1.0, Party_Timer_CreateMemberDecal, client);
	}
	
	return Plugin_Continue;
}

void GamemodeStats_OnPlayerKilled(int attacker, int victim){
	if (!ActualMode.is(MODE_SWARM) && !ActualMode.is(MODE_PLAGUE) && !ActualMode.is(MODE_APOCALYPSIS) && !ActualMode.is(MODE_ARMAGEDDON))
		return;
	
	ZPlayer Attacker = ZPlayer(attacker);
	ZPlayer Victim = ZPlayer(victim);
	
	// Calculate gain	
	int base;
	
	if (Attacker.isZombie()){
		
		base = obtainBaseProfitPerKill(Attacker.iLevel, Victim.iLevel);
		iModesZombieRewards += base;
	}
	else if (Attacker.isHuman()){
		
		base = obtainBaseProfitPerKill(Attacker.iLevel, Victim.iLevel)*1/2;
		iModesHumanRewards += base;
	}
}

// Finish round if no valid clients alive
public void RoundEndOnPlayerDeath(){
	
	if (!ActualMode.bKill){
		return;
	}
	
	int nHumans  = fnGetAliveInTeamNoBots(CS_TEAM_CT);
	int nZombies = fnGetAliveInTeamNoBots(CS_TEAM_T);
	
	if (!nZombies && !nHumans){
		CS_TerminateRound(1.0, CSRoundEnd_CTWin, false);
	}
}

// Event pre player team
public Action EventPrePlayerTeam(Event event, const char[] name, bool dontBroadcast){
	if(!dontBroadcast){
		Handle new_event = CreateEvent("player_team", true);
		
		SetEventInt(new_event, "userid", GetEventInt(event, "userid"));
		SetEventInt(new_event, "team", GetEventInt(event, "team"));
		SetEventInt(new_event, "oldteam", GetEventInt(event, "oldteam"));
		SetEventBool(new_event, "disconnect", GetEventBool(event, "disconnect"));
		
		FireEvent(new_event, true);
		
		return Plugin_Handled;
	}
	return Plugin_Continue; 
}

// On name change
public Action OnNameChange(Event event, const char[] name, bool dontBroadcast){
	int userId = event.GetInt("userid");
	int client = GetClientOfUserId(userId);
	ZPlayer player = ZPlayer(client);
	
	player.bChangedName = true;
	
	if (gClientData[client].bInRenameMenu){
		if (!IsFakeClient(client)){
			char sBuffer[32];
			FormatEx(sBuffer, sizeof sBuffer, "%N", client);
			characterNames.SetString(client, sBuffer);
			
			showMenuRenameCharacter(client);
			return Plugin_Continue;
		}
	}
	
	//SetEventBroadcast(event, true);
	if (IsClientInGame(player.id) && !IsFakeClient(player.id)){
		if (player.bCanChangeName){
			player.bCanChangeName = false;
			return Plugin_Continue;
		}
		/*else{
			char oldname[32], newname[32];
			GetEventString(event, "oldname", oldname, sizeof(oldname));
			GetEventString(event, "newname", newname, sizeof(newname));
			
			if (!StrEqual(newname, oldname))
				SetClientInfo(client, "name", oldname);
			
			return Plugin_Handled;
		}*/
	}
	
	PrintToConsole(player.id, "No se puede realizar un cambio de nombre ahora.");
	return Plugin_Handled;
}

// Boost on client jump
public Action JumpBoostOnClientJump(Event hEvent, char[] sName, bool dontBroadcast){
	
	// Gets all required event info
	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	
	// Creates a single use next frame hook
	if (ZPlayer(client).bCanLeap)
		_call.JumpBoostOnClientJumpPost(client);

	return Plugin_Handled;
}

// On player connected full
public void EventOnPlayerConnectedFull(Event event, char[] name, bool dontBroadcast){
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	RequestFrame(MoveToSpectator, client);
}

// Shotgun ent hook
public Action ShotgunShotEntHook(const char[] te_name, const int[] iPlayers, int numClients, float delay){
	
	// Check which clients need to be excluded.
	int newClients[MAXPLAYERS+1];
	int i;
	ZPlayer player;
	int newTotal = 0;
	
	for (i = 0; i < numClients; i++){
		player = ZPlayer(iPlayers[i]);
		
		if (!player.bStopSound){
			newClients[newTotal++] = player.id;
		}
	}
	
	// No clients were excluded.
	if (newTotal == numClients){
		return Plugin_Continue;
	}
	
	// All clients were excluded and there is no need to broadcast.
	else if (newTotal == 0){
		return Plugin_Stop;
	}
	
	// Re-broadcast to clients that still need it.
	float vTemp[3];
	TE_Start("Shotgun Shot");
	TE_ReadVector("m_vecOrigin", vTemp);
	TE_WriteVector("m_vecOrigin", vTemp);
	TE_WriteFloat("m_vecAngles[0]", TE_ReadFloat("m_vecAngles[0]"));
	TE_WriteFloat("m_vecAngles[1]", TE_ReadFloat("m_vecAngles[1]"));
	TE_WriteNum("m_weapon", TE_ReadNum("m_weapon"));
	TE_WriteNum("m_iMode", TE_ReadNum("m_iMode"));
	TE_WriteNum("m_iSeed", TE_ReadNum("m_iSeed"));
	TE_WriteNum("m_iPlayer", TE_ReadNum("m_iPlayer"));
	TE_WriteFloat("m_fInaccuracy", TE_ReadFloat("m_fInaccuracy"));
	TE_WriteFloat("m_fSpread", TE_ReadFloat("m_fSpread"));
	TE_Send(newClients, newTotal, delay);
	
	return Plugin_Stop;
}

// Event on weapon reload
public Action EventWeaponReload(Event gEventHook, const char[] gEventName, bool dontBroadcast){
	
	int client = GetClientOfUserId(gEventHook.GetInt("userId"));
	
	if(!IsPlayerExist(client))
		return Plugin_Handled;
	
	int weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	
	if (!weapon)
		return Plugin_Handled;
	
	if (!IsValidEntity(weapon))
		return Plugin_Handled;
	
	ZPlayer player = ZPlayer(client);
	
	if (player.isBoss(false))
		return Plugin_Continue;
	
	SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", 200);
	return Plugin_Continue;
}

// Sniper lightning effect
void GetWeaponAttachmentPosition(int client, const char[] attachment, float pos[3]){
	
	if (!attachment[0])
		return;
	
	int entity = CreateEntityByName("info_target");
	DispatchSpawn(entity);
	
	int weapon;
	
	if ((weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon")) == -1)
		return;
	
	if ((weapon = GetEntPropEnt(weapon, Prop_Send, "m_hWeaponWorldModel")) == -1)
		return;
	
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", weapon, entity, 0);
	
	SetVariantString(attachment); 
	AcceptEntityInput(entity, "SetParentAttachment", weapon, entity, 0);
	
	TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, NULL_VECTOR);
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
	//AcceptEntityInput(entity, "kill");
	RemoveEntity(entity);
}
void TE_DispatchEffect2(char[] particle, float pos[3], float endpos[3], float angles[3] = NULL_VECTOR){
	TE_Start("EffectDispatch");
	TE_WriteFloatArray("m_vStart.x", pos, 3);
	TE_WriteFloatArray("m_vOrigin.x", endpos, 3);
	TE_WriteVector("m_vAngles", angles);
	TE_WriteNum("m_nHitBox", GetParticleEffectIndex(particle));
	TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffect"));
}
public Action Hook_BulletShot(const char[] te_name, const int[] Users, int numClients, float delay){
	
	int client = TE_ReadNum("m_iPlayer") + 1;
	ZPlayer player = ZPlayer(client);
	
	if (!player.isType(PT_SNIPER))
		return Plugin_Continue;
	
	float origin[3];
	TE_ReadVector("m_vecOrigin", origin);
	g_fLastAngles[client][0] = TE_ReadFloat("m_vecAngles[0]");
	g_fLastAngles[client][1] = TE_ReadFloat("m_vecAngles[1]");
	g_fLastAngles[client][2] = 0.0;
	
	float impact_pos[3];
	Handle trace = TR_TraceRayFilterEx(origin, g_fLastAngles[client], MASK_SHOT, RayType_Infinite, TR_DontHitSelf, client);
	if (TR_DidHit(trace)){
		TR_GetEndPosition(impact_pos, trace);
	}
	delete trace;
	
	//Play the taser sounds
	EmitAmbientSound(SOUND_IMPACT, impact_pos, SOUND_FROM_WORLD, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5, SNDPITCH_LOW);
	EmitAmbientSound(SOUND_SHOOT, origin, SOUND_FROM_WORLD, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5, SNDPITCH_LOW);
	return Plugin_Continue;
}
public bool TR_DontHitSelf(int entity, int mask, any data){
	if (entity == data) 
		return false;
	
	return true;
}
public Action Event_BulletImpact(Event event, const char[] name, bool dontBroadcast){
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	ZPlayer player = ZPlayer(client);
	
	if (!player.isType(PT_SNIPER))
		return Plugin_Continue;
	
	float impact_pos[3];
	impact_pos[0] = event.GetFloat("x");
	impact_pos[1] = event.GetFloat("y");
	impact_pos[2] = event.GetFloat("z");
	
	float muzzle_pos[3], camera_pos[3];
	GetWeaponAttachmentPosition(client, "muzzle_flash", muzzle_pos);
	GetWeaponAttachmentPosition(client, "camera_buymenu", camera_pos);
	
	//Create an offset for first person
	float pov_pos[3];
	pov_pos[0] = muzzle_pos[0] - camera_pos[0];
	pov_pos[1] = muzzle_pos[1] - camera_pos[1];
	pov_pos[2] = muzzle_pos[2] - camera_pos[2] + 0.1;
	ScaleVector(pov_pos, 0.4);
	SubtractVectors(muzzle_pos, pov_pos, pov_pos);
	
	//Move the beam a bit forward so it isn't too close for first person
	float distance = GetVectorDistance(pov_pos, impact_pos);
	float percentage = 0.2 / (distance / 100);
	pov_pos[0] = pov_pos[0] + ((impact_pos[0] - pov_pos[0]) * percentage);
	pov_pos[1] = pov_pos[1] + ((impact_pos[1] - pov_pos[1]) * percentage);
	pov_pos[2] = pov_pos[2] + ((impact_pos[2] - pov_pos[2]) * percentage);
	
	//Display the particle to first person 
	TE_DispatchEffect2(TASER, pov_pos, impact_pos, g_fLastAngles[client]);
	TE_SendToClient(client);
	
	//Display the particle to everyone else under the normal position
	TE_DispatchEffect2(TASER, muzzle_pos, impact_pos, g_fLastAngles[client]);
	
	int[] clients = new int[MaxClients+1];
	int client_count;
	for (int i = 1; i <= MaxClients; i++){
		
		if ( !IsPlayerExist(i) ||!IsClientInGame(i) || i == client || IsFakeClient(i))
			continue;
		
		clients[client_count++] = i;
	}
	TE_Send(clients, client_count);
	
	//Move the impact glow a bit out so it doesn't clip the wall
	impact_pos[0] = impact_pos[0] + ((pov_pos[0] - impact_pos[0]) * percentage);
	impact_pos[1] = impact_pos[1] + ((pov_pos[1] - impact_pos[1]) * percentage);
	impact_pos[2] = impact_pos[2] + ((pov_pos[2] - impact_pos[2]) * percentage);
	
	TE_DispatchEffect2(GLOW, impact_pos, impact_pos);
	TE_SendToAll();
	
	//TE_DispatchEffect(SPARK, impact_pos, impact_pos);
	//TE_SendToAll();
	return Plugin_Continue;
}

//=====================================================
//					STAFF COMMANDS
//=====================================================
// STAFF CMDS
public Action infServerNow(int client, int args){
	//ZPlayer player = ZPlayer(client);
	//if(!player.bStaff) return Plugin_Handled;
	bool acc;
	bool gmode;
	bool zclass;
	bool hclass;
	bool pweaps;
	bool basic;
	bool gpacks;
	bool party;
	bool tag;
	bool hats;
	bool bosses;
	bool lasermines;
	bool halignments;
	bool zalignments;
	bool ranks;
	bool combos;
	
	//bool notif;
	bool all;
	
	char arg[32];
	for(int i = 1; i <= GetCmdArgs(); i++){
		GetCmdArg(i, arg, 32);
		if(StrEqual(arg, "all")) all = true;
		if(StrEqual(arg, "basic")) basic = true;
		if(StrEqual(arg, "players")) acc = true;
		if(StrEqual(arg, "gamemodes")) gmode = true;
		if(StrEqual(arg, "zclasses")) zclass = true;
		if(StrEqual(arg, "hclasses")) hclass = true;
		if(StrEqual(arg, "pweapons")) pweaps = true;
		if(StrEqual(arg, "gpacks")) gpacks = true;
		if(StrEqual(arg, "party")) party = true;
		if(StrEqual(arg, "tags")) tag = true;
		if(StrEqual(arg, "hats")) hats = true;
		if(StrEqual(arg, "bosses")) bosses = true;
		if(StrEqual(arg, "lasermines") || StrEqual(arg, "lm")) lasermines = true;
		if(StrEqual(arg, "halignments")) halignments = true;
		if(StrEqual(arg, "zalignments")) zalignments = true;
		if(StrEqual(arg, "ranks")) ranks = true;
		if(StrEqual(arg, "combos")) combos = true;
		//if (StrEqual(arg, "notify")) notif = true;
	}
	
	if(basic || all){
		PrintToConsole(client, "\nBasic info...\n");
		PrintToConsole(client, "Actual Mode: %d\ngServerData.RoundNew: %b\ngServerData.RoundStart: %b", ActualMode.id, gServerData.RoundNew, gServerData.RoundStart);
	}
	if(acc || all){
		PrintToConsole(client, "\nPlayers...\n");
		char name[32];
		for(int i; i<= MaxClients; i++){
			if(IsPlayerExist(i)){
				ZPlayer p = ZPlayer(i);
				GetClientName(i, name, 32);
				PrintToConsole(client, "------------------------------------------------------");
				PrintToConsole(client, "Id: %d\tPjSelec: %d\tUser: %s\tLvl: %d\tHClass: %d\tZClass: %d\tZPoints: %d\tHPoints: %d\tHat: %d\tHatRef: %d\tiPartyUID: %d", 
					i, p.iPjSeleccionado, name, p.iLevel, p.iHumanClass, p.iZombieClass, p.iZPoints, p.iHPoints, p.iHat, p.iHatRef, gClientData[client].iPartyUID);
				PrintToConsole(client, "------------------------------------------------------");
			}
		}
	}
	if(gmode || all) {
		PrintToConsole(client, "\nGamemodes...\n");
		char name[32];
		for(int i; i < ZGameModes.Length; i++){
			ZGameMode mode;
			ZGameModes.GetArray(i, mode);
			
			mode.GetName(name, 32);
			
			PrintToConsole(client, "ID: %d\tName: %s\nInfection: %b\tKill: %b\tRespawn: %b\tZombie Only: %b\tProbabilities: %i",
				mode.id, name, mode.bInfection, mode.bKill, mode.bRespawn, mode.bRespawnZombieOnly, mode.probability);
		}
	}
	if(zclass || all){
		PrintToConsole(client, "\nZombie Classes...\n");
		for(int i; i< ZClasses.Length; i++){
			ZClass class;
			ZClasses.GetArray(i, class);
			PrintToConsole(client, "Id: %d\nName: %s\nModel: %s\nArms: %s\nProperties:\nHp: %d\tSpeed: %f\tGravity: %f\n", class.id, class.name, class.model, class.arms,class.health, class.speed, class.gravity);
		}
	}
	if(hclass || all){
		PrintToConsole(client, "\nHuman Classes...\n");
		for(int i; i< HClasses.Length; i++){
			HClass class;
			HClasses.GetArray(i, class);
			PrintToConsole(client, "Id: %d\tName: %s\nModel: %s\nArms: %s\nHp: %d\tArmor: %d\tSpeed: %f\tGravity: %f\tLvl: %d\tReset: %d\n", i, class.name, class.model, class.arms, class.health, class.armor, class.speed, class.gravity, class.level, class.reset);
		}
	}
	if(pweaps ||all) {
		PrintToConsole(client, "\nPrimary Weapons...\n");
		char names[32];
		char ent[32];
		char model[WEAPONS_MODELS_MAXPATH];
		char wmodel[WEAPONS_MODELS_MAXPATH];
		for(int i; i< WeaponsName.Length; i++){
			ZWeapon weap = ZWeapon(i);
			WeaponsName.GetString(i, names, sizeof(names));
			WeaponsEnt.GetString(i, ent, sizeof(ent));
			WeaponsModel.GetString(i, model, sizeof(model));
			WeaponsWorldModel.GetString(i,wmodel, sizeof(wmodel));
			PrintToConsole(client, "Name: %s\tEnt: %s\nVModel: %s\nWModel: %s\nLevel: %d\nReset: %d", names, ent, model, wmodel,weap.iLevel, weap.iReset);
			PrintToConsole(client, "-----------------------------------------", names, ent, model, wmodel);
		}
	}
	if(gpacks || all){
		PrintToConsole(client, "\nGrenade Packs...\n");
		for(int i; i < gGrenadePackLevel.Length; i++){
			ZGrenadePack p = ZGrenadePack(i);
			PrintToConsole(client, "Id: %d\tLevel: %d\tReset: %d\tTypes:{%d,%d,%d,%d}\tCounts:{%d,%d,%d,%d}\thasGrenade:{%b,%b,%b,%b}\tgCount:{%d,%d,%d,%d}", i, p.iLevel, p.iReset, 
				p.iFirstGrenadeType, p.iSecondGrenadeType, p.iThirdGrenadeType, p.iFourthGrenadeType,
				p.iFirstGrenadeCount, p.iSecondGrenadeCount, p.iThirdGrenadeCount, p.iFourthGrenadeCount,
				p.hasGrenade(p.iFirstGrenadeType), p.hasGrenade(p.iSecondGrenadeType), p.hasGrenade(p.iThirdGrenadeType), p.hasGrenade(p.iFourthGrenadeType),
				p.getGrenadeCount(p.iFirstGrenadeType), p.getGrenadeCount(p.iSecondGrenadeType), p.getGrenadeCount(p.iThirdGrenadeType), p.getGrenadeCount(p.iFourthGrenadeType));
		}
	}
	if(party || all){
		PrintToConsole(client, "\nPartys...\n");
		
		ZParty p;
		for(int i; i < gPartys.Length; i++){
			p = ZParty(i);
			
			
			PrintToConsole(client, "id:%d\tUID:%d\tlength:%d\tavgLevel:%d\ttotalBoost:%f\t", i, p.iUID, p.length(), p.avgLevel(), p.getTotalBoost());
			PrintToConsole(client, "PARTY ID %d | UID: %d MEMBERS:", i, p.iUID);
			
			for (int j; j < p.length(); j++){
				PrintToConsole(client, "%N |\t idMember: %d |\t idPlayer: %d", p.getMemberByArrayId(j), j, p.getMemberByArrayId(j));
			}
		}
	}
	if(tag || all){
		PrintToConsole(client, "\nTags v%s...\n", TAGS_MODULE_VERSION);
		PrintToConsole(client, "%d", tags.Length);
		char buf[32];
		for(int i; i < tags.Length; i++){
			tags.GetString(i, buf, sizeof(buf));
			PrintToConsole(client, "index:%d\tnombre:%s", i,buf);
		}
	}
	if(hats || all){
		PrintToConsole(client, "\nHats v%s...\n", HATS_MODULE_VERSION);
		PrintToConsole(client, "%d", Hats.Length);
		for(int i; i < Hats.Length; i++){
			Hat hat;
			Hats.GetArray(i, hat);
			PrintToConsole(client, "id:%d\tnombre:%s\tmodelPath:%s", i,hat.name, hat.model);
		}
	}
	if (bosses || all){
		PrintToConsole(client, "\nBosses v%s...\n", BOSSES_MODULE_VERSION);
		PrintToConsole(client, "\nFound %d in array...\n", ZBosses.Length);

		char names[32];
		char models[255];
		char arms[255];
		ZBoss boss;
		for(int i; i < ZBosses.Length; i++){
			
			ZBosses.GetArray(i, boss);
			
			boss.GetName(names, 32);
			boss.GetModel(models, 255);
			boss.GetArms(arms, 255);
			PrintToConsole(client, "Id: %d\tName: %s\nModel: %s\nArms: %s\nHpAdditive: %d\nhpBase: %d\tflDamage: %f\tSpeed: %f\tGravity: %f\tLMDamage: %f\nTEAM: %d\n\n", i, names, models, arms, boss.iHealthAdditive, boss.iHealthBase, boss.flDamage, boss.flSpeed, boss.flGravity, boss.flDamageToLm, boss.iTeamNum);
		}
	}
	if (lasermines || all){
		PrintToConsole(client, "\nLasermines v%s...\n", LASERMINES_MODULE_VERSION);
		PrintToConsole(client, "\nFound %d in array...\n", ZLasermines.Length);

		char names[32];
		char colors[32];
		int hp;
		ZLasermine lasermine;
		for(int i; i < ZLasermines.Length; i++){
			
			ZLasermines.GetArray(i, lasermine);
			
			lasermine.GetName(names, 32);
			lasermine.GetColors(colors, 32);
			hp = lasermine.health;
			PrintToConsole(client, "Id: %d\tName: %s\nColors: %s\nHealth: %d\n\n", i, names, colors, hp);
		}
	}
	if (halignments || all){
		PrintToConsole(client, "\nHUMAN ALIGNMENTS v%s...\n", HALIGNMENTS_MODULE_VERSION);
		PrintToConsole(client, "\nFound %d in array...\n", HAlignments.Length);

		char names[32];
		char desc[48];
		float damage, hp, speed, gravity;
		int armor;

		HAlignment alignment;

		for (int i; i < HAlignments.Length; i++){

			HAlignments.GetArray(i, alignment);
			
			strcopy(names, sizeof(names), alignment.name);
			strcopy(desc, sizeof(desc), alignment.desc);

			damage = alignment.flDamageMul;
			hp = alignment.flHealthMul;
			speed = alignment.flSpeedMul;
			gravity = alignment.flGravityMul;
			armor = alignment.iArmorAdd;

			PrintToConsole(client,"Id: %d\nName: %s\nDescription: %s\nDamage: %0.2f\nHealth: %0.2f\nArmor: %d\nSpeed: %0.2f\nGravity: %0.2f\n\n", i, names, desc, damage, hp, armor, speed, gravity);
		}
	}
	if (zalignments || all){
		PrintToConsole(client, "\nZOMBIE ALIGNMENTS v%s...\n", ZALIGNMENTS_MODULE_VERSION);
		PrintToConsole(client, "\nFound %d in array...\n", ZAlignments.Length);

		char names[32];
		char desc[48];
		float damage, hp, speed, gravity;
		int armor;

		ZAlignment alignment;

		for (int i; i < ZAlignments.Length; i++){

			ZAlignments.GetArray(i, alignment);

			strcopy(names, sizeof(names), alignment.name);
			strcopy(desc, sizeof(desc), alignment.desc);

			damage = alignment.flDamageMul;
			hp = alignment.flHealthMul;
			speed = alignment.flSpeedMul;
			gravity = alignment.flGravityMul;

			PrintToConsole(client,"Id: %d\nName: %s\nDescription: %s\nDamage: %0.2f\nHealth: %0.2f\nSpeed: %0.2f\nGravity: %0.2f\n\n", i, names, desc, damage, hp, armor, speed, gravity);
		}
	}
	if (ranks || all){
		PrintToConsole(client, "\n Ranks v%s...\n", RANKTAGS_MODULE_VERSION);
		PrintToConsole(client, "RankTags in array: %d", RankTags.Length);
		RankTag rank;
		for(int i; i < RankTags.Length; i++){
			RankTags.GetArray(i, rank);
			PrintToConsole(client, "index:%d\tnombre:%s", i,rank.name);
		}
	}
	if (combos || all){
		PrintToConsole(client, "\n COMBOS v%s...\n", COMBOS_MODULE_VERSION);
		PrintToConsole(client, "Combos in array: %d", gComboName.Length);
		
		ZCombo combo;
		char sName[32];
		for(int i; i < gComboName.Length; i++){
			combo = ZCombo(i);
			gComboName.GetString(combo.id, sName, sizeof(sName));
			PrintToConsole(client, "index:%d \tNombre:%s \tDifficulty:%0.2f \tExpGain:%0.2f", i, sName, combo.fDifficulty, combo.fBonusExpGain);
		}
	}
	/*if (notif || all){
		PrintToConsole(client, "\nNotify v%s...\n", BOSSES_MODULE_VERSION);
		char type[32];
		
		int armas = 0;
		int granadas = 0;
		int zombies = 0;
		int humanos = 0;
		int items = 0;
		int ppoints = 0;
		
		Handle snap = CreateTrieSnapshot(itemPerLevel);
		
		int val;
		char lvl[4];
		
		for(int i=0; i <= 90; i++){
			IntToString(i,lvl, sizeof(lvl));
			itemPerLevel.GetValue(lvl, val);
			
			switch(val){
				case IL_WEAPON:{
					armas++;
					Format(type, sizeof(type), "Arma nueva");
				}
				case IL_GRENADE:{
					granadas++;
					Format(type, sizeof(type), "Pack granadas");
				}
				case IL_ZCLASS:{
					zombies++;
					Format(type, sizeof(type), "Clase zombie");
				}
				case IL_HCLASS:{
					humanos++;
					Format(type, sizeof(type), "Clase humana");
				}
				case IL_PIUPOINTS: {
					ppoints++;
					Format(type, sizeof(type), "Piu Points");
				}
			}
			PrintToConsole(client, "%d) ItemType: %s\t", i, type);
		}
		PrintToConsole(client, "Total: %d\tArmas: %d\tGranadas: %d\tZombies: %d\tHumanos: %d\tPPoints: %d\n",
		TrieSnapshotLength(snap), armas, granadas, zombies, humanos, items, ppoints);
		CloseHandle(snap);
	}*/
	
	PrintToConsole(client, "\nDebug ended...\n");
	return Plugin_Handled;
}

public void saveAll(){
	
	for (int i = 1; i <= MaxClients; i++){
		saveCharacterData(i);
	}
}
public Action saveAllcmd(int client, int args){
	ZPlayer player = ZPlayer(client);
	if(player.bStaff){
		saveAll();
		PrintToConsole(client, "[DATABASE] Saving all users' data!");
	}
	return Plugin_Handled;
}
public Action makemeHuman(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	char name[16];
	GetClientName(player.id, name, sizeof(name));
	
	if (!player.bStaff)
		return Plugin_Handled;
	
	if(IsPlayerAlive(player.id) && !player.isType(PT_HUMAN)){
		PrintHintText(player.id, "[ZP] You're a Human!");
		player.Humanize();
	}
	return Plugin_Handled;
}

public Action makemeSurvivor(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	if (!player.bStaff)
		return Plugin_Handled;
	
	if(IsPlayerAlive(player.id)){
		PrintHintText(player.id, "[ZP] You're a SURVIVOR!");
		if (ActualMode.is(NO_MODE))
			StartMode(view_as<int>(MODE_SURVIVOR), player.id, true);
		else
			player.TurnInto(PT_SURVIVOR);
	}
	
	return Plugin_Handled;
}

public Action makemeSuperSurvivor(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	if (!player.bStaff)
		return Plugin_Handled;
	
	if(IsPlayerAlive(player.id)){
		PrintHintText(player.id, "[ZP] You're a SUPERSURVIVOR!");
		if (ActualMode.is(NO_MODE))
		StartMode(view_as<int>(MODE_SUPERSURVIVOR), player.id, true);
		else
		player.TurnInto(PT_SUPERSURVIVOR);
	}
	return Plugin_Handled;
}

public Action makemeGunslinger(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	if (!player.bStaff)
		return Plugin_Handled;
	
	if(IsPlayerAlive(player.id)){
		PrintHintText(player.id, "[ZP] You're a GUNSLINGER!");
		if (ActualMode.is(NO_MODE))
			StartMode(view_as<int>(MODE_GUNSLINGER), player.id, true);
		else
			player.TurnInto(PT_GUNSLINGER);
	}
	return Plugin_Handled;
}

public Action makemeSniper(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	if (!player.bStaff)
		return Plugin_Handled;
	
	char code[32];
	GetCmdArg(1, code, sizeof(code));
	
	if(IsPlayerAlive(player.id)){
		PrintHintText(player.id, "[STAFF] You're a SNIPER!");
		if (ActualMode.is(NO_MODE))
			StartMode(view_as<int>(MODE_SNIPER), player.id, true);
		else
			player.TurnInto(PT_SNIPER);
	}
	return Plugin_Handled;
}

public Action makemeZombie(int client, int args){
	ZPlayer player = ZPlayer(client);
	if (!player.bStaff)
	return Plugin_Handled;
	if(gServerData.DBI == null)
		return Plugin_Handled;
	
	if(IsPlayerAlive(player.id)){
		PrintHintText(player.id, "[ZP] You're a Zombie!");
		if (ActualMode.is(NO_MODE))
			StartMode(view_as<int>(MODE_INFECTION), player.id, true);
		else
			player.Zombiefy(true);
	}
	return Plugin_Handled;
}
public Action makemeNemesis(int client, int args){
	ZPlayer player = ZPlayer(client);
	if (!player.bLogged || !player.bInGame)
		return Plugin_Handled;
	
	if (!player.bStaff)
		return Plugin_Handled;
	
	if(IsPlayerAlive(player.id)){
		PrintHintText(player.id, "[ZP] You're a NEMESIS!");
		
		if (ActualMode.is(NO_MODE))
			StartMode(view_as<int>(MODE_NEMESIS), player.id, true);
		else{
			player.TurnInto(PT_NEMESIS);
			
			// Bazooka
			CreateNetworkedWeaponEnt(player.id, iWeaponBazooka);
			//player.GiveNetworkedWeapon(iWeaponBazooka);
		}
	}
	return Plugin_Handled;
}

public Action makemeAssassin(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	if (!player.bStaff)
		return Plugin_Handled;
	
	if(IsPlayerAlive(player.id)){
		PrintHintText(player.id, "[STAFF] You're a ASSASSIN!");
		if (ActualMode.is(NO_MODE))
			StartMode(view_as<int>(MODE_ASSASSIN), player.id, true);
		else
			player.TurnInto(PT_ASSASSIN);
	}
	return Plugin_Handled;
}
	
//public Action makemeFev(int client, int args){
//	ZPlayer player = ZPlayer(client);
//	
//	if (!player.bStaff)
//		return Plugin_Handled;
//	
//	if(IsPlayerAlive(player.id)){
//		PrintHintText(player.id, "[STAFF] You're a FEV!");
//		player.TurnInto(PT_FEV);
//	}
//	return Plugin_Handled;
//}
public Action givemenades(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	if (!player.bStaff)
		return Plugin_Handled;
	
	if(IsPlayerAlive(player.id)){
		GivePlayerItem(player.id, "weapon_hegrenade");
		GivePlayerItem(player.id, "weapon_flashbang");
		GivePlayerItem(player.id, "weapon_smokegrenade");
		GivePlayerItem(player.id, "weapon_decoy");
	}
	
	return Plugin_Handled;
}

public Action AimInfect(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	if (!player.bStaff)
		return Plugin_Handled;
	
	int targetIndex = GetClientAimTarget(player.id, true);
	ZPlayer target = ZPlayer(targetIndex);
	
	if (!IsPlayerExist(target.id) || !IsPlayerAlive(target.id))
		return Plugin_Handled;
	
	target.Zombiefy(false);
	return Plugin_Handled;
}
public Action AimHumanize(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	if (!player.bStaff)
		return Plugin_Handled;
	
	int targetIndex = GetClientAimTarget(player.id, true);
	ZPlayer target = ZPlayer(targetIndex);
	
	if (!IsPlayerExist(target.id) || !IsPlayerAlive(target.id))
		return Plugin_Handled;
	
	target.Humanize(false);
	return Plugin_Handled;

}

public Action AimRemoveLasermines(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	int targetIndex = GetClientAimTarget(player.id, true);
	ZPlayer target = ZPlayer(targetIndex);
	if (!IsPlayerExist(target.id) || !IsPlayerAlive(target.id))
		return Plugin_Handled;
	
	RemoveLasermines(target.id);
	
	char name1[32], name2[32];
	GetClientName(player.id, name1, sizeof(name1));
	GetClientName(target.id, name2, sizeof(name2));
	TranslationPrintToChatAll("Mod removed lasermines", name1, name2);
	
	TranslationPrintToChat(target.id, "Your lasermines were removed", name1);
	return Plugin_Handled;
}

public Action stafflvl(int client, int args){
	ZPlayer id = ZPlayer(client);
	
	if (!id.bStaff){
		PrintToChat(id.id, "No access");
		return Plugin_Handled;
	}
	
	char sLvl[16];
	GetCmdArg(1, sLvl, sizeof(sLvl));
	int lvl = StringToInt(sLvl);
	
	id.iLevel = lvl;
	id.iExp = NextLevel(lvl-1, id.iReset);
	id.checkLevelUp();
	PrintToChat(id.id, "Applied %d lvl to you", lvl);
	
	return Plugin_Handled;
}

public Action AimRemoveLasermine(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	int targetIndex = GetClientAimTarget(player.id, false);
	
	if (!IsValidEntity(targetIndex))
		return Plugin_Handled;
	
	char sModel[64];
	GetEntPropString(targetIndex, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
	
	char targetname[64];
	GetEntPropString(targetIndex, Prop_Data, "m_iName", targetname, sizeof(targetname));
	
	if (!StrEqual(sModel, LASERMINE_MODEL_MINE, false)){
		PrintToChat(player.id, "Entity is not lasermine");
		return Plugin_Handled;
	}
	
	//AcceptEntityInput(targetIndex, "Kill");
	RemoveEntity(targetIndex);
	return Plugin_Handled;
}

public Action makeAlive(int client, int args){
	ZPlayer PIBE = ZPlayer(client);
	
	if (!(GetUserFlagBits(PIBE.id) & ADMFLAG_CHANGEMAP) && !PIBE.bStaff)
		return Plugin_Handled;
	
	char player[32];
	GetCmdArg(1, player, sizeof(player));
	
	bool respawned = false;
	
	char name[32];
	for(int i = 1; i<= MaxClients; i++){
		if(IsPlayerExist(i)){
			
			GetClientName(i, name, sizeof(name));
			if(StrContains(name, player, false) != -1){
				ZPlayer p = ZPlayer(i);
				
				if (!IsPlayerAlive(i)){
					respawned = true;
					//p.iRespawnPlayer();
					CreateTimer(0.1, respawnPlayer, p.id);
				}
				
				break;
			}
		}
	}
	
	if (respawned) PrintToChatAll(" %s %N: \x01 revivió a \x0B%s\x01", (PIBE.bStaff) ? "\x09STAFF" : "\x0FMOD", PIBE.id, name);
	
	return Plugin_Handled;
}

public Action givemeWeapon(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	if (!player.bStaff || !IsPlayerAlive(client))
		return Plugin_Handled;
	
	char weapon[8];
	GetCmdArg(1, weapon, sizeof(weapon));
	
	bool isNumeric = true;
	
	for (int i = 0; i < sizeof(weapon); i++){
		
		//PrintToConsole(client, "GIVE WEAPON: weapon[%d] = %s.", i, weapon[i]);
		
		if (StrEqual(weapon[i], ""))
			break;
		
		if (!IsCharNumeric(weapon[i])){
			isNumeric = false;
			break;
		}
	}
	
	int iWeaponID;
	
	if (!isNumeric){
		if (StrEqual(weapon, "bazooka")){
			iWeaponID = iWeaponBazooka;
		}

		PrintToConsole(client, "GIVE WEAPON: Introducido valor no numérico %s.", weapon);
		return Plugin_Handled;
	}
	else{
		iWeaponID = StringToInt(weapon);
	}
	
	if (iWeaponID >= WeaponsName.Length || iWeaponID < 0){
		PrintToConsole(client, "GIVE WEAPON: Introducido valor inexistente %s.", weapon);
		return Plugin_Handled;
	}
	
	player.GiveNetworkedWeapon(iWeaponID);
	
	char sName[24];
	ZWeapon(iWeaponID).GetName(sName, sizeof(sName));
	
	PrintToChat(client, "GIVEN WEAPON %s", sName);
	
	return Plugin_Handled;
}

public Action setAllowParty(int client, int args){
	
	ZPlayer player = ZPlayer(client);
	
	if(!player.bStaff){
		return Plugin_Handled;
	}
	
	allowParty = !allowParty;
	
	for(int i = 0; i < gPartys.Length; i++){
		gPartyMembers[i].Clear();
		gPartys.Clear();
	}
	
	for (int i = 1; i<= MaxClients; i++){
		gClientData[i].iPartyUID = -1;
		gClientData[i].bInParty = false;
	}
	
	PrintToConsole(client, "Party %s", allowParty ? "Enabled": "Disabled");
	return Plugin_Handled;
}

public Action meow(int client, int args){
	ZPlayer p = ZPlayer(client);
	if(p.bStaff){
		p.iNextPrimaryWeapon = iWeaponMeow;
		p.Zombiefy();
		p.TurnInto(PT_MEOW);
	}
	return Plugin_Handled;
}

public Action lightLevel(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	if (!player.bStaff)
		return Plugin_Handled;
	
	ServerCommand("sv_skyname sky_csgo_night02b");
	SetLightStyle(0, "b");
	
	return Plugin_Handled;
}

public Action valveFog(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	if (!player.bStaff)
		return Plugin_Handled;
	
	static bool bFog = true;
	
	AcceptEntityInput(iFog, bFog ? "TurnOff" : "TurnOn");
	bFog = !bFog;
	
	return Plugin_Handled;
}

public Action lightSwitch(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	if (!player.bStaff)
		return Plugin_Handled;
		
	static bool setting;
	int ent = -1;
	while((ent = FindEntityByClassname(ent, "light"))!=-1){
		AcceptEntityInput(ent, (setting) ? "TurnOn" : "TurnOff");
		PrintToChat(player.id, "%b", setting);
		setting = !setting;
		break;
	}
	
	return Plugin_Handled;
}

public Action staffzpoints(int client, int args){
	ZPlayer id = ZPlayer(client);
	
	if (!id.bStaff)
		return Plugin_Handled;
		
	char player[16];
	char cPoints[16];
	GetCmdArg(1, player, 16);
	GetCmdArg(2, cPoints, 16);
	int points = StringToInt(cPoints);
	
	char name[32];
	for (int i = 1; i <= MaxClients; i++){
		if(IsPlayerExist(i)){
			GetClientName(i, name, 32);
			if(StrEqual(name, player) && IsPlayerExist(i)){
				ZPlayer p = ZPlayer(i);
				p.iZPoints += points;
			}
		}
	}
	return Plugin_Handled;
}

public Action staffhpoints(int client, int args){
	ZPlayer id = ZPlayer(client);
	
	if (!id.bStaff)
		return Plugin_Handled;
	
	char player[16];
	char cPoints[16];
	GetCmdArg(1, player, 16);
	GetCmdArg(2, cPoints, 16);
	int points = StringToInt(cPoints);
	
	char name[32];
	for (int i = 1; i <= MaxClients; i++){
		if(IsPlayerExist(i)){
			GetClientName(i,name, 32);
			if(StrEqual(name, player)){
				ZPlayer p = ZPlayer(i);
				p.iHPoints += points;
			}
		}
	}
	
	return Plugin_Handled;
}

public Action staffmake(int client, int args){
	ZPlayer PIBE = ZPlayer(client);
	
	if (!PIBE.bStaff)
		return Plugin_Handled;

	char player[16];
	char type[16];
	char what[32];
	GetCmdArg(1, player, 16);
	GetCmdArg(2, type, 16);
	for(int i = 1; i<= MaxClients; i++){
		if(IsPlayerExist(i)){
			char name[32];
			GetClientName(i,name, 32);
			if(StrEqual(name, player)){
				ZPlayer p = ZPlayer(i);
				if(StrEqual(type, "human")){
					p.Humanize();
					FormatEx(what, 32, "Humano");
				}
				else if(StrEqual(type, "zombie")){
					p.Zombiefy();
					FormatEx(what, 32, "Zombie");
					GivePlayerItem(p.id, "weapon_flashbang");
				}
				else if(StrEqual(type, "gunslinger")){
					FormatEx(what, 32, "Gunslinger");
					
					if (ActualMode.is(NO_MODE))
						StartMode(view_as<int>(MODE_GUNSLINGER), p.id, true);
					else
						p.TurnInto(PT_GUNSLINGER);
				}
				else if(StrEqual(type, "sniper")){
					FormatEx(what, 32, "Sniper");
					if (ActualMode.is(NO_MODE))
						StartMode(view_as<int>(MODE_SNIPER), p.id, true);
					else
						p.TurnInto(PT_SNIPER);
				}
				else if(StrEqual(type, "survivor")){
					FormatEx(what, 32, "Survivor");
					if (ActualMode.is(NO_MODE))
						StartMode(view_as<int>(MODE_SURVIVOR), p.id, true);
					else
						p.TurnInto(PT_SURVIVOR);
				}
				else if(StrEqual(type, "supersurvivor")){
					FormatEx(what, 32, "SUPER Survivor");
					if (ActualMode.is(NO_MODE))
						StartMode(view_as<int>(MODE_SUPERSURVIVOR), p.id, true);
					else
						p.TurnInto(PT_SUPERSURVIVOR);
				}
				else if(StrEqual(type, "chainsaw")){
					FormatEx(what, 32, "Chainsaw");
					if (ActualMode.is(NO_MODE))
						StartMode(view_as<int>(MODE_CHAINSAW), p.id, true);
					else
						p.TurnInto(PT_CHAINSAW);
				}
				else if(StrEqual(type, "nemesis")){
					FormatEx(what, 32, "Nemesis");
					
					if (ActualMode.is(NO_MODE))
						StartMode(view_as<int>(MODE_NEMESIS), p.id, true);
					else
						p.TurnInto(PT_NEMESIS);
				}
				else if(StrEqual(type, "assassin")){
					FormatEx(what, 32, "Assassin");
					
					if (ActualMode.is(NO_MODE))
						StartMode(view_as<int>(MODE_ASSASSIN), p.id, true);
					else
						p.TurnInto(PT_ASSASSIN);
				}
				else if(StrEqual(type, "alive")){
					p.iRespawnPlayer();
					FormatEx(what, 32, "Vivo");
				}
				else if(StrEqual(type, "invulnerable")){
					p.bInvulnerable = !p.bInvulnerable;
					FormatEx(what, 32, "Invulnerable");
				}
//				else if(StrEqual(type, "fev")){
//					p.TurnInto(PT_FEV);
//					FormatEx(what, 32, "FEV");
//				}
				else{
					PrintToServer("%s no encontrado", type);
					return Plugin_Handled;
				}
			}
		}
	}
	return Plugin_Handled;
}

public Action staffexp(int client, int args){
	ZPlayer id = ZPlayer(client);
	
	if (!id.bStaff)
		return Plugin_Handled;
	
	char player[16];
	char cPoints[16];
	GetCmdArg(1, player, 16);
	GetCmdArg(2, cPoints, 16);
	
	PrintToChat(client, "Player Buscado: %s", player);
	PrintToChat(client, "Experiencia a dar: %s", cPoints);
	
	int points = StringToInt(cPoints);
	for(int i=1; i <= MaxClients; i++){
		if(IsPlayerExist(i)){
			char name[32];
			GetClientName(i,name, 32);
			PrintToChat(client, "Nombre encontrado: %s %b", name, StrEqual(name, player, false));
			if(StrEqual(name, player, false)){
				ZPlayer p = ZPlayer(i);
				p.iExp += points;
				p.checkLevelUp();
				break;
			}
		}
	}
	
	return Plugin_Handled;
}

public Action staffbanchat(int client, int args){
	ZPlayer id = ZPlayer(client);
	
	if (!id.bStaff)
		return Plugin_Handled;
	
	char player[16];
	GetCmdArg(1, player, 16);
	
	char name[32];
	for (int i = 1; i <= MaxClients; i++){
		if(IsPlayerExist(i)){
			GetClientName(i,name, 32);
			if(StrEqual(name, player)){
				ZPlayer p = ZPlayer(i);
				p.bChatBanned = !p.bChatBanned;
				PrintToChatAll("%s Se %s el chat de \x0B%s\x01.", SERVERSTRING, p.bChatBanned ? "baneo" : "desbaneo", name);
				break;
			}
		}
	}
	return Plugin_Handled;
}

public Action staffbanchatvoice(int client, int args){
	
	ZPlayer id = ZPlayer(client);
	
	if (!id.bStaff)
		return Plugin_Handled;
	
	char player[16];
	GetCmdArg(1, player, 16);
	
	char name[32];
	for (int i = 1; i <= MaxClients; i++){
		if(IsPlayerExist(i)){
			GetClientName(i,name, 32);
			if(StrEqual(name, player)){
				
				ZPlayer(i).bVoiceChatBanned = !ZPlayer(i).bVoiceChatBanned;
				PrintToChatAll("%s Se %s el voicechat de \x0B%s\x01.", SERVERSTRING, ZPlayer(i).bVoiceChatBanned ? "baneo" : "desbaneo", name);
				break;
			}
		}
	}
	return Plugin_Handled;
}

public Action Command_Map(int client, int args){
	
	OnMapEnd();

	return Plugin_Handled;
}

// Poison throw
public Action cmdPoisonThrow(int client, int args){
	
	
	if (!ZPlayer(client).bStaff)
		return Plugin_Handled;
	
	float vAngles[3];
	float vOrigin[3];
	
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	CreatePoison(client, vOrigin, vAngles);
	
	GetVectors(client, vOrigin, vAngles);
	vAngles[0] +=3;
	GetVectors(client, vOrigin, vAngles);
	vAngles[0] +=3;
	GetVectors(client, vOrigin, vAngles);
	vAngles[0] +=3;
	GetVectors(client, vOrigin, vAngles);
	vAngles[0] -=12;
	GetVectors(client, vOrigin, vAngles);
	vAngles[0] -=3;
	GetVectors(client, vOrigin, vAngles);
	vAngles[0] -=3;
	GetVectors(client, vOrigin, vAngles);
	
	//CreateTimer(6.0, Setpoison, client);
	
	return Plugin_Handled;
}
void GetVectors(int client, const float vOrigin[3], const float vAngles[3]){
	
	float newAngle[3];
	
	newAngle[0] = vAngles[0];
	newAngle[1] = vAngles[1];
	newAngle[2] = vAngles[2];
	
	GetAndTrace(client, vOrigin, newAngle);
	
	newAngle[1] += 3;
	GetAndTrace(client, vOrigin, newAngle);
	
	newAngle[1] += 3;
	GetAndTrace(client, vOrigin, newAngle);
	
	newAngle[1] += 3;
	GetAndTrace(client, vOrigin, newAngle);
	
	newAngle[1] = vAngles[1]-3;
	GetAndTrace(client, vOrigin, newAngle);
	
	newAngle[1] -= 3;
	GetAndTrace(client, vOrigin, newAngle);
	
	newAngle[1] -= 3;
	GetAndTrace(client, vOrigin, newAngle);
}
void GetAndTrace(int client, const float vOrigin[3], const float vAngles[3]){
	
	float AnglesVec[3];
	float EndPoint[3];
	
	GetAngleVectors(vAngles, AnglesVec, NULL_VECTOR, NULL_VECTOR);
	
	EndPoint[0] = vOrigin[0] + (AnglesVec[0]*float(400));
	EndPoint[1] = vOrigin[1] + (AnglesVec[1]*float(400));
	EndPoint[2] = vOrigin[2] + (AnglesVec[2]*float(400));
	
	Handle trace = TR_TraceRayFilterEx(vOrigin, EndPoint, MASK_PLAYERSOLID, RayType_EndPoint, TraceEntityFilterPlayerHuman, client);
	
	delete trace;
}
public bool TraceEntityFilterPlayerHuman(int entity, int contentsMask, int data){
	
	ZPlayer player = ZPlayer(entity);
	
	if (data != entity && (1 <= entity <= MaxClients) && player.isType(PT_HUMAN)){
		if (fnGetAliveInTeam(CS_TEAM_CT) > 1){
			
			ZPlayer attacker = ZPlayer(data);
			DataPack hPack = new DataPack();
			hPack.WriteCell(attacker.id);
			hPack.WriteCell(player);
			
			CreateTimer(1.0, Timer_PoisonDamage, hPack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	
	return false;
} 
void CreatePoison(int client, const float origin[3], const float angles[3]){
	char Distance[16];
	IntToString(400, Distance, sizeof(Distance));
	
	// Ident the player
	char tName[128];
	Format(tName, sizeof(tName), "target%i", client);
	DispatchKeyValue(client, "targetname", tName);
	
	EmitSoundToClient(client, "weapons/rpg/rocketfire1.wav", _, _, _, _, 0.7);
			
	// Create the poison
	char poison_name[128];
	Format(poison_name, sizeof(poison_name), "poison%i", client);
	int poison = CreateEntityByName("env_steam");
	DispatchKeyValue(poison,"targetname", poison_name);
	DispatchKeyValue(poison, "parentname", tName);
	DispatchKeyValue(poison,"SpawnFlags", "1");
	DispatchKeyValue(poison,"Type", "0");
	DispatchKeyValue(poison,"InitialState", "1");
	DispatchKeyValue(poison,"Spreadspeed", "10");
	DispatchKeyValue(poison,"Speed", "800");
	DispatchKeyValue(poison,"Startsize", "15");
	DispatchKeyValue(poison,"EndSize", "250");
	DispatchKeyValue(poison,"Rate", "30");
	DispatchKeyValue(poison,"JetLength", Distance);
	DispatchKeyValue(poison,"RenderColor", "20 225 8");
	DispatchKeyValue(poison,"RenderAmt", "180");
	DispatchSpawn(poison);
	TeleportEntity(poison, origin, angles, NULL_VECTOR);
	SetVariantString(tName);
	AcceptEntityInput(poison, "SetParent", poison, poison, 0);
		
	CreateTimer(0.5, Killpoison, poison);
}
public Action Killpoison(Handle timer, any poison){
	
	if (IsValidEntity(poison)){
		
		char classname[256];
		GetEdictClassname(poison, classname, sizeof(classname));
		if (StrEqual(classname, "env_steam", false))
			AcceptEntityInput(poison, "kill");
	}

	return Plugin_Handled;
}
public Action Timer_PoisonDamage(Handle timer, any hPack){
	
	static int repeats = 4;
	
	if (!repeats){
		delete view_as<DataPack>(hPack);
		return Plugin_Stop;
	}
	
	ResetPack(hPack);

	int infector = ReadPackCell(hPack);
	int infected = ReadPackCell(hPack);
	
	if (!IsPlayerExist(infected, true)){
		delete view_as<DataPack>(hPack);
		return Plugin_Stop;
	}
	
	ZPlayer player = ZPlayer(infected);
	
	if (!player.isType(PT_HUMAN)){
		delete view_as<DataPack>(hPack);
		return Plugin_Stop;
	}
	
	float dmg = 50.0;
	
	if(player.iArmor > 0){
		if(RoundToZero(dmg) > player.iArmor) player.iArmor = 0;
		else player.iArmor -= RoundToZero(dmg);
	}
	else{
	
		if(ActualMode.bInfection && GetValidPlayingHumans() > 1){
			FireInfectionEvent(infector, infected);
		}
		else{
			if((player.iHp) <= dmg) player.iHealth = 0;
			else player.iHp -= RoundToZero(dmg);
		}
	}
	
	repeats--;
	
	return Plugin_Handled;
	
}


/*
"UPDATE characters c
SET 
 piuPoints = SELECT p.piupoints FROM players p WHERE p.id = c.idPlayer+(c.reset*200),
 experiencia = DEFAULT,
 level = DEFAULT,
 reset = DEFAULT,
 hClass = DEFAULT, 
 zClass = DEFAULT, 
 HPoints = DEFAULT,
 HGPoints = DEFAULT,
 ZPoints = DEFAULT,
 ZGPoints = DEFAULT,
 
 hLMHP = DEFAULT, 
 hCritChance = DEFAULT, 
 hItemChance = DEFAULT,
 hAuraTime = DEFAULT, 
 
 zMadnessTime = DEFAULT, 
 zDamageToLM = DEFAULT,
 zLeech = DEFAULT, 
 zMadnessChance = DEFAULT, 
 
 hDamageLevel = DEFAULT, 
 hResistanceLevel = DEFAULT, 
 hPenetrationLevel = DEFAULT, 
 hDexterityLevel = DEFAULT, 
 
 zDamageLevel = DEFAULT, 
 zResistanceLevel = DEFAULT, 
 zDexterityLevel = DEFAULT, 
 zHealthLevel = DEFAULT, 
 
 primarySelected = DEFAULT,
 secondarySelected = DEFAULT,
 partyInv = DEFAULT,
 
 autoClass = DEFAULT, 
 autoWeap = DEFAULT, 
 autoGPack = DEFAULT, 
 bullets = DEFAULT, 
 
 hAlineacion = DEFAULT,
 zAlineacion = DEFAULT,
 
 gPack = DEFAULT,
 
 hudColor = DEFAULT,
 nvgColor = DEFAULT,
 
 tag = DEFAULT, 
 hat = DEFAULT, 
 hatPoints = DEFAULT, 
  
 usedVipPrueba = DEFAULT
  
 WHERE id = 2;"
*/