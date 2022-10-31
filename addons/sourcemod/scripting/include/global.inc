#if defined global_included
	#endinput
#endif
#define global_included

#pragma semicolon 1
#pragma newdecls required

#define DEBUG

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

// Own includes
#include <resources>
#include <anti_retry>
#include <ragdolls>

// typedef MenuHandler = function int (Menu menu, MenuAction action, int param1, int param2);

#define HEADSHOT_DAMAGE_MULTIPLIER 	2.0

#define ANNOUNCER_HUD_Y_POSITION 	0.15

#define LEVEL_UP_SOUND "*/MassiveInfection/powerup.mp3"
#define LEVEL_DOWN_SOUND "*/MassiveInfection/powerdown.mp3"

char ZWinSounds[][] = {
	"*/MassiveInfection/the_horror1.mp3",
	"*/MassiveInfection/the_horror3.mp3",
	"*/MassiveInfection/the_horror4.mp3"
};
char HWinSounds[][] = {
	"*/MassiveInfection/human_win1.mp3",
	"*/MassiveInfection/human_win2.wav"
};

// Disable weapon drop?
//#define DISABLE_WEAPON_DROP

// Enable weapon debug messages?
//#define ENABLE_WEAPONS_DEBUG_MESSAGES

// Enable infection heritage?
#define ENABLE_INFECTION_HERITAGE

// Define
//-----------------------------------------------------


// Random shit
#define TIME_TO_REMOVE_WEAPONS 5.0
#define INVULNERABLE_TIME 	6.0
#define DMG_FALL 	(1 << 5)
#define LEAP_DELAY 	2.0

// Infection define
#define INFECTION_BASE_REWARD	620
#define INFECTION_SCALAR_REWARD	45 /*		int value = Attacker.iLevel * INFECTION_SCALAR_REWARD;
											int diff = Attacker.iLevel - Victim.iLevel;*/

#define KILL_BASE_REWARD 	710
#define KILL_SCALAR_REWARD 	55

// Chest defines
//#define ENABLE_CHESTS
#define CHEST_TIME_TO_SPAWN 	1.5
#define CHEST_TIME_DISAPPEAR 	25.0
#define CHEST_DROP_RATIO 		15
#define CHEST_CLASSNAME 		"BonusChest"
#define CHEST_MODEL 			"models/player/kodua/headcrabclassic.mdl"
//#define CHEST_MODEL 			"models/player/custom_player/kuristaja/cso2/sas/sas2.mdl"
#define CHEST_MIN_AP 			500
#define CHEST_MAX_AP 			5000

#pragma unused gfSpawnOrigins

//=====================================================
//				HUD COLORS & VARS
//=====================================================

// Hud synchronizer
Handle hHudSynchronizer;

//
int GlowSprite, g_halosprite;

//=====================================================

//=====================================================
//					UTILITIES
//=====================================================
stock void GetAimCoords(int client, float vector[3]){
	
	float vAngles[3];
	float vOrigin[3];
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);

	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if (TR_DidHit(trace)){
		TR_GetEndPosition(vector, trace);
	}
	delete trace;
}
stock bool TraceEntityFilterPlayer(int entity, int contentsMask){
	
	return (entity > MaxClients || entity < 1);
}
stock void SetGlowColor(int entity, const char[] color){
	char colorbuffers[3][4];
	ExplodeString(color, " ", colorbuffers, sizeof(colorbuffers), sizeof(colorbuffers[]));
	int colors[4];
	for (int i = 0; i < 3; i++)
		colors[i] = StringToInt(colorbuffers[i]);
	colors[3] = 255; // Set alpha
	SetVariantColor(colors);
	AcceptEntityInput(entity, "SetGlowColor");
}

stock InputErrorCodes isValidInput(const char[] input, int minlen=3, int maxlen=15){
	int len = strlen(input);
	if(len > maxlen) return INPUT_LARGE;
	if(len < minlen) return INPUT_SHORT;
	
	/*if(StrContains(temp, "/")) {PrintToServer("Contiene /\t input: %s", temp);return INPUT_INVALID_SIMBOL;}
	if(StrContains(temp, "'")) {PrintToServer("Contiene '\t input: %s", temp) ; return INPUT_INVALID_SIMBOL;}
	if(StrContains(temp, "`")) {PrintToServer("Contiene `\t input: %s", temp) ; return INPUT_INVALID_SIMBOL;}
	if(StrContains(temp, "´")) {PrintToServer("Contiene ´\t input: %s", temp) ; return INPUT_INVALID_SIMBOL;}
	
	if(StrContains(temp, " ")) {PrintToServer("Contiene espacio") ; return INPUT_INVALID_SPACE;}*/
	
	PrintToServer("[VALID INPUT] Ta todo gud amio");
	
	return INPUT_OK;
}

stock int AbsValue(int v1){
	return v1 < 0 ? (v1*-1) : v1;
}

//=====================================================
//					INFECTION EFFECTS
//=====================================================

// Screenshake
stock void ShakeClientScreen(int client, float amplitude, float frequency, float duration){
	Handle hShake = StartMessageOne("Shake", client);
	
	// Validate.
	if (hShake == INVALID_HANDLE){
		return;
	}
	
	if (GetUserMessageType() == UM_Protobuf){
		PbSetInt(hShake, "command", 0);
		PbSetFloat(hShake, "local_amplitude", amplitude);
		PbSetFloat(hShake, "frequency", frequency);
		PbSetFloat(hShake, "duration", duration);
	}
	else{
		BfWriteByte(hShake, 0);
		BfWriteFloat(hShake, amplitude);
		BfWriteFloat(hShake, frequency);
		BfWriteFloat(hShake, duration);
	}
	EndMessage();
}

// Energy splash
stock void CreateEnergySplash(const float origin[3], const float direction[3], bool explosive){
	TE_SetupEnergySplash(origin, direction, explosive);
	TE_SendToAll();
}
stock void CreateExplosion(const float origin[3], int flags){
	// Create an explosion entity.
	int explosion = CreateEntityByName("env_explosion");
	
	// If explosion entity isn't valid, then stop.
	if (explosion == -1){
		return;
	}
	
	// Get and modify flags on explosion.
	int spawnflags = GetEntProp(explosion, Prop_Data, "m_spawnflags");
	spawnflags = spawnflags | EXP_NODAMAGE | EXP_NODECAL | flags;
	
	// Set modified flags on entity.
	SetEntProp(explosion, Prop_Data, "m_spawnflags", spawnflags);
	
	// Spawn the entity into the world.
	DispatchSpawn(explosion);
	
	// Set the origin of the explosion.
	DispatchKeyValueVector(explosion, "origin", origin);
	
	// Set fireball material.
	PrecacheModel("materials/sprites/xfireball3.vmt");
	DispatchKeyValue(explosion, "fireballsprite", "materials/sprites/xfireball3.vmt");
	
	// Tell the entity to explode.
	AcceptEntityInput(explosion, "Explode");
	
	// Remove entity from world.
	RemoveEntity(explosion);
	//AcceptEntityInput(explosion, "Kill");
}

// Player rendermode
stock void SetWeaponsRGBA(int client, RenderMode mode, int red = 255, int green = 255, int blue = 255, int alpha = 255){
	int m_hMyWeapons = FindSendPropInfo("CBasePlayer", "m_hMyWeapons");
	
	//GetEntDataEnt2 will error if m_hMyWeapons is -1
	if (m_hMyWeapons == -1){
		return;
	}
	
	for(int i = 0, weapon; i < 47; i += 4){
		weapon = GetEntDataEnt2(client, m_hMyWeapons + i);
	
		if (weapon > 0 && IsValidEdict(weapon)){
			char classname[64];
			if (GetEdictClassname(weapon, classname, sizeof(classname)) && StrContains(classname, "weapon") != -1){
				SetEntityRenderMode(weapon, mode);
				SetEntityRenderColor(weapon, red, green, blue, alpha);
			}
		}
	}
}

// Collide entity check
/*
stock int IsPlayerStuck(int client, int entity){
	float vecMin[3], vecMax[3], vecOrigin[3];
	
	if (!IsPlayerExist(client, true) || !IsValidEntity(entity))
		return 0;
	
	GetClientMins(client, vecMin);
	GetClientMaxs(client, vecMax);
	
	GetClientAbsOrigin(client, vecOrigin);
	
	TR_TraceHullFilter(vecOrigin, vecOrigin, vecMin, vecMax, MASK_PLAYERSOLID, TraceRayDontHitPlayerAndWorld);
	
	if (!TR_DidHit())
		return 0;
		
	return (TR_GetEntityIndex() == entity);
}
public bool TraceRayDontHitPlayerAndWorld(int entityhit, int mask) {
	return entityhit > MAXPLAYERS+1;
}*/

stock bool IsPlayerStuckInEnt(int client, int ent, bool bSolid = false){
	
	if (!IsPlayerExist(client, true) || !IsValidEntity(ent))
		return false;
	
	float vecMin[3], vecMax[3], vecOrigin[3];
	
	GetClientMins(client, vecMin);
	GetClientMaxs(client, vecMax);
	
	GetClientAbsOrigin(client, vecOrigin);
	
	TR_TraceHullFilter(vecOrigin, vecOrigin, vecMin, vecMax, bSolid ? MASK_SOLID : MASK_ALL, TraceRayHitOnlyEnt, ent);
	return TR_DidHit();
}

public bool TraceRayHitOnlyEnt(int entityhit, int mask, any data){
    return entityhit == data;
}

// Screen fade
#define FFADE_IN            0x0001        // Just here so we don't pass 0 into the function
#define FFADE_OUT           0x0002        // Fade out (not in)
#define FFADE_MODULATE      0x0004        // Modulate (don't blend)
#define FFADE_STAYOUT       0x0008        // ignores the duration, stays faded out until new ScreenFade message received
#define FFADE_PURGE         0x0010        // Purges all other fades, replacing them with this one

stock void ScreenFadeAll(float duration, float holdtime, int flag = FFADE_IN, int colors[4] = {255, 255, 255, 255}){
	for (int i = 1; i <= MaxClients; i++){
		if (IsClientInGame(i) && !IsFakeClient(i)){
			ScreenFade(i, duration, holdtime, flag, colors);
		}
	}
}
stock bool ScreenFade(int client, float duration, float holdtime, int flag = FFADE_IN, int colors[4] = {255, 255, 255, 255}){
	// Create message
	Handle hFade = StartMessageOne("Fade", client);

	// Validate message
	if(hFade != INVALID_HANDLE)
	{
		// Write shake information to message handle
		PbSetInt(hFade, "duration", RoundToNearest(duration * 1000.0)); 
		PbSetInt(hFade, "hold_time", RoundToNearest(holdtime * 1000.0)); 
		PbSetInt(hFade, "flags", flag); 
		PbSetColor(hFade, "clr", colors); 

		// End usermsg and send to client
		EndMessage();
	}
}

/*
// Player already has weapons check utility
stock bool Client_HasWeapon(int client, const char[] className){
	
	int weapon = Client_GetWeapon(client, className);

	return (weapon != INVALID_ENT_REFERENCE);
}
stock int Client_GetWeapon(int client, const char[] className){
	
	int offset = Client_GetWeaponsOffset(client) - 4;
	int weapon = INVALID_ENT_REFERENCE;
	for (int i=0; i < MAX_WEAPONS; i++) {
		offset += 4;

		weapon = GetEntDataEnt2(client, offset);

		if (!Weapon_IsValid(weapon)) {
			continue;
		}

		if (Entity_ClassNameMatches(weapon, className)) {
			return weapon;
		}
	}

	return INVALID_ENT_REFERENCE;
}
stock bool Weapon_IsValid(int weapon){
	
	if (!IsValidEdict(weapon)) {
		return false;
	}

	return Entity_ClassNameMatches(weapon, "weapon_", true);
}
stock bool Entity_ClassNameMatches(int entity, const char[] className, bool partialMatch=false){
	
	char entity_className[64];
	Entity_GetClassName(entity, entity_className, sizeof(entity_className));

	if (partialMatch) {
		return (StrContains(entity_className, className) != -1);
	}

	return StrEqual(entity_className, className);
}*/

//=====================================================
//					GLOW SUPPORT
//=====================================================
#pragma unused SetupGlow
#pragma unused SetupGlowSkin
//#pragma unused UnhookGlow

// Prepare client for glow
void SetupGlowSkin(int client, int colors[3]){
	
	char sModel[PLATFORM_MAX_PATH];
	GetClientModel(client, sModel, sizeof(sModel));

	int iSkin = CreatePlayerModelProp(client, sModel);
	
	if (iSkin > MaxClients){
		if (SDKHookEx(iSkin, SDKHook_SetTransmit, OnSetTransmit_GlowSkin)){
			SetupGlow(iSkin, colors, client);
		}
	}
}

public int CreatePlayerModelProp(int client, char[] sModel){

	RemoveSkin(client);

	int skin = CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(skin, "model", sModel);
	DispatchKeyValue(skin, "disablereceiveshadows", "1");
	DispatchKeyValue(skin, "disableshadows", "1");
	DispatchKeyValue(skin, "solid", "0");
	DispatchKeyValue(skin, "spawnflags", "256");
	SetEntProp(skin, Prop_Send, "m_CollisionGroup", 0);
	DispatchSpawn(skin);
	SetEntityRenderMode(skin, RENDER_TRANSALPHA);
	SetEntityRenderColor(skin, 0, 0, 0, 0);
	SetEntProp(skin, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_NOSHADOW|EF_NORECEIVESHADOW);
	SetVariantString("!activator");
	AcceptEntityInput(skin, "SetParent", client, skin);
	SetVariantString("primary");
	AcceptEntityInput(skin, "SetParentAttachment", skin, skin, 0);
	
	ZPlayer player = ZPlayer(client);

	player.iModel = EntIndexToEntRef(skin);
	player.iModelIndex = skin;

	return skin;
}

public void RemoveSkin(int client){

	ZPlayer player = ZPlayer(client);

	if (player.bGlowing){
		if (IsValidEntity(player.iModel)){
			SDKUnhook(player.iModel, SDKHook_SetTransmit, OnSetTransmit_GlowSkin);
			//AcceptEntityInput(player.iModel, "Kill");
			RemoveEntity(player.iModel);
		}
	}

	player.bGlowing = false;
	player.iModel = INVALID_ENT_REFERENCE;
	player.iModelIndex = -1;
}

// Set client glow
void SetupGlow(int iSkin, int colors[3], int client){
	
	int iOffset;
	
	if (!iOffset && (iOffset = GetEntSendPropOffs(iSkin, "m_clrGlow")) == -1)
		return;
	
	SetEntProp(iSkin, Prop_Send, "m_bShouldGlow", true, true);
	SetEntProp(iSkin, Prop_Send, "m_nGlowStyle", 1);
	SetEntPropFloat(iSkin, Prop_Send, "m_flGlowMaxDist", 1000.0);
	
	int iRed = colors[0];
	int iGreen = colors[1];
	int iBlue = colors[2];

	SetEntData(iSkin, iOffset, iRed, _, true);
	SetEntData(iSkin, iOffset + 1, iGreen, _, true);
	SetEntData(iSkin, iOffset + 2, iBlue, _, true);
	SetEntData(iSkin, iOffset + 3, 255, _, true);

	ZPlayer(client).bGlowing = true;
}

// Check who can see the glow effect
public Action OnSetTransmit_GlowSkin(int iSkin, int client){
	
	if (!IsPlayerExist(client)){
		return Plugin_Handled;
	}

	ZPlayer player = ZPlayer(client);
	if (player.iModelIndex == iSkin){
		return Plugin_Handled;
	}
	
	if (!IsPlayerAlive(player.id)){
		// Is our player spectating someone?
		int iSpecMode = GetEntProp(player.id, Prop_Send, "m_iObserverMode");
		
		if (iSpecMode == SPECMODE_FIRSTPERSON){
			int iTarget = GetEntPropEnt(player.id, Prop_Send, "m_hObserverTarget");
			
			if (IsPlayerExist(iTarget) && ZPlayer(iTarget).iModelIndex == iSkin)
				return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}

//Remove glow
/*
void UnhookGlow(int client){
	
	ZPlayer player = ZPlayer(client);
	player.bGlowing = false;
	
	if (!CPS_HasSkin(client))
		return;
		
	int iSkin = EntRefToEntIndex(CPS_GetSkin(client));
	
	SDKUnhook(iSkin, SDKHook_SetTransmit, OnSetTransmit_GlowSkin);
	
	CPS_RemoveSkin(client);
}*/


// Madness
stock bool IsMadnessInCooldown(int client, bool apply = false){
	ZPlayer player = ZPlayer(client);
	float flCurrentTime = GetEngineTime();
	
	// Cooldown isn't over yet, then stop
	if ((flCurrentTime - player.flMadnessTime) < MADNESS_COOLDOWN)
		return true;
	
	return false;
}
stock void applyMadnessCooldown(int client){
	
	ZPlayer player = ZPlayer(client);
	float flCurrentTime = GetEngineTime();
	
	player.flMadnessTime = flCurrentTime;
}
//=====================================================
//					BOSSES AURA
//=====================================================
void RemoveAura(int clientIndex){
	
	ZPlayer player = ZPlayer(clientIndex);
	
	if(!player.bAura || !IsValidEntity(player.iAuraEntity)){
		return;
	}
	
	//AcceptEntityInput(player.iAuraEntity, "kill");
	RemoveEntity(player.iAuraEntity);
	player.bAura = false;
}

#define DEFAULT_AURA_RADIUS 		10.0

void CreateAura(int client, int colors[4], bool bFlicker = false){
	
	RemoveAura(client);
	
	ZPlayer player = ZPlayer(client);
	
	int iEntity = CreateEntityByName("light_dynamic");
	player.iAuraEntity = iEntity;
	DispatchKeyValue(iEntity, "brightness", "0");
	DispatchKeyValueFloat(iEntity, "spotlight_radius", DEFAULT_AURA_RADIUS);
	
	if (bFlicker) DispatchKeyValue(iEntity, "style", "4");
	else DispatchKeyValue(iEntity, "style", "5");
	
	char sLightColor[32];
	
	FormatEx(sLightColor, sizeof(sLightColor), "%i %i %i %i", colors[0], colors[1], colors[2], colors[3]);
	
	DispatchKeyValue(iEntity, "_light", sLightColor);
	DispatchKeyValueFloat(iEntity, "distance", DEFAULT_AURA_RADIUS*100.0);
	DispatchSpawn(iEntity);
	
	float m_flClientOrigin[3];
	GetClientAbsOrigin(client, m_flClientOrigin);
	
	m_flClientOrigin[0] -= 30.0;
	
	TeleportEntity(iEntity, m_flClientOrigin, NULL_VECTOR, NULL_VECTOR);
	SetEntityMoveType(iEntity, MOVETYPE_NONE);
	SetVariantString("!activator");
	AcceptEntityInput(iEntity, "SetParent", client, iEntity, 0);
	
	player.bAura = true;
}

//=====================================================
//					HATS
//=====================================================
int NotWorking[7] = { 1, 3, 5, 6, 8 };

void DeployHat(int client, int hatId){
	
	if (hatId <= 0)
		return;
	
	if(GetClientTeam(client) < CS_TEAM_T) return;
	
	if (!IsPlayerExist(client, true))
		return;
	
	ZPlayer player = ZPlayer(client);
		
	Hat hat;
	Hats.GetArray(hatId, hat);
	
	if (player.isType(PT_ZOMBIE)){
		bool notworking = false;
		for (int i; i < sizeof(NotWorking); i++){
			if (player.iZombieClass == NotWorking[i]){
				notworking = true;
				break;
			}
		}
		
		if (notworking)
			return;
	}
	
	if (player.isType(PT_HUMAN) && player.iHumanClass == 0)
		return;
	
	// Calculate the final position and angles for the hat
	float m_fHatOrigin[3], m_fHatAngles[3], m_fForward[3], m_fRight[3], m_fUp[3], m_fOffset[3];

	GetClientAbsOrigin(client, m_fHatOrigin);
	GetClientAbsAngles(client, m_fHatAngles);
	
	m_fOffset[0] = 0.0;
	m_fOffset[1] = 0.0;
	m_fOffset[2] = 0.0;
	
	m_fHatAngles[0] += 0.0;
	m_fHatAngles[1] += 0.0;
	m_fHatAngles[2] += 0.0;

	GetAngleVectors(m_fHatAngles, m_fForward, m_fRight, m_fUp);

	m_fHatOrigin[0] += m_fRight[0]*m_fOffset[0]+m_fForward[0]*m_fOffset[1]+m_fUp[0]*m_fOffset[2];
	m_fHatOrigin[1] += m_fRight[1]*m_fOffset[0]+m_fForward[1]*m_fOffset[1]+m_fUp[1]*m_fOffset[2];
	m_fHatOrigin[2] += m_fRight[2]*m_fOffset[0]+m_fForward[2]*m_fOffset[1]+m_fUp[2]*m_fOffset[2];
	
	// Create the hat entity
	int m_iEnt = CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(m_iEnt, "model", hat.model);
	DispatchKeyValue(m_iEnt, "spawnflags", "256");
	DispatchKeyValue(m_iEnt, "solid", "0");
	SetEntPropEnt(m_iEnt, Prop_Send, "m_hOwnerEntity", client);
	
	//if(g_eHats[g_Elegido[client]][bBonemerge]) Bonemerge(m_iEnt);
	//Bonemerge(m_iEnt);
	
	DispatchSpawn(m_iEnt);
	AcceptEntityInput(m_iEnt, "TurnOn", m_iEnt, m_iEnt, 0);
	
	// Save the entity index
	player.iHatRef = EntIndexToEntRef(m_iEnt);
	
	// We don't want the client to see his own hat
	/*if(player.iHat) */
	SDKHook(m_iEnt, SDKHook_SetTransmit, ShouldHide);
	
	// Teleport the hat to the right position and attach it
	TeleportEntity(m_iEnt, m_fHatOrigin, m_fHatAngles, NULL_VECTOR); 

	SetVariantString("!activator");
	AcceptEntityInput(m_iEnt, "SetParent", client, m_iEnt, 0);

	SetVariantString("facemask");
	AcceptEntityInput(m_iEnt, "SetParentAttachmentMaintainOffset", m_iEnt, m_iEnt, 0);
}
public void Bonemerge(int ent){

	int m_iEntEffects = GetEntProp(ent, Prop_Send, "m_fEffects"); 
	m_iEntEffects &= ~32;
	m_iEntEffects |= 1;
	m_iEntEffects |= 128;
	SetEntProp(ent, Prop_Send, "m_fEffects", m_iEntEffects); 
}
public Action ShouldHide(int ent, int client){

	int owner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if (owner == client){
		return Plugin_Handled;
	}

	if (GetEntProp(client, Prop_Send, "m_iObserverMode") == 4){
		if (owner == GetEntPropEnt(client, Prop_Send, "m_hObserverTarget")){
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}
public void RemoveHat(int client){
	ZPlayer player = ZPlayer(client);
	
	int entity = EntRefToEntIndex(player.iHatRef);
	if(entity != INVALID_ENT_REFERENCE && IsValidEdict(entity) && entity > MaxClients){
	
		SDKUnhook(entity, SDKHook_SetTransmit, ShouldHide);
		
		char m_szClassname[64];
		GetEdictClassname(entity, m_szClassname, sizeof(m_szClassname));
		if(strcmp("prop_dynamic", m_szClassname) == 0){
			//AcceptEntityInput(entity, "Kill");
			RemoveEntity(entity);
		}
	}
	player.iHatRef = INVALID_ENT_REFERENCE;
}
public Action ReHat(Handle hTimer, int client){

	if (IsPlayerExist(client, true)){
		
		ZPlayer player = ZPlayer(client);
		
		if (IsClientInGame(player.id)){
			RemoveHat(client);
			
			int hatByResets = -1;
			if (player.iHat <= 0){
				hatByResets = Hats_FindForReset(player.iReset);
			}
			
			int iFixedHat = (hatByResets != -1) ? hatByResets : player.iHat;
			
			DeployHat(client, iFixedHat);
			
			int iHat = EntRefToEntIndex(player.iHatRef);
			if (IsValidEntity(iHat)){
				
				int red, green, blue, alpha;
				GetEntityRenderColor(client, red, green, blue, alpha);
				
				SetEntityRenderMode(iHat, GetEntityRenderMode(client));
				SetEntityRenderColor(iHat, red, green, blue, alpha);
			}
		}
	}
}

//=====================================================
//					LEVELS
//=====================================================
// Returns how many ammopacks are needed to get to the next level
// EXAMPLE NextLevel(1) returns how many ammopacks are needed to get to level 2.
stock int NextLevel(int level, int reset){
	
	// version 1.6, no apta al meta nuevo
	//return RoundToZero((3000+700*(level+1)+500*(level+1)*(level+1)) * ((0.15*reset)+1));
	if (reset >= 500){
		return RoundToZero((61 * level * (level+(level/6)) + 300) * ((0.10*500)+1));
	}
	
	return RoundToZero((61 * level * (level+(level/6)) + 300) * ((0.10*reset)+1));
	
	//return RoundToCeil((10000.0*level*level)*(1+(0.5*reset)));
	//return RoundToCeil((25 * level * (level+(level/2)) + 500)(1+(reset*0.25)));
	//(NextLevel(player.iLevel+1, player.iReset)-player.iExp);
	//NextLevel(201, 6);
}

//=====================================================
//					POINTS
//=====================================================
stock int calculateChances(int chances, int successValue, int failureValue){
	int value;
	if (GetRandomInt(0, 100) < chances/*>= 100-chances*/)
		value = successValue;
	else
		value = failureValue;
	
	return value;
}

stock int calculateChancesFloat(float chances, int successValue, int failureValue){
	int value;
	if (GetRandomFloat(0.0, 100.0) < chances)
		value = successValue;
	else
		value = failureValue;
	
	return value;
}

/*
 * Returns if chances resulted true or false.
	0 is for zombie madness
	1 is for human critical chance
	2 is for human item extra chance
 */
stock int GetUpgradeChance(int client, int iUpgrade){
	
	ZPlayer player = ZPlayer(client);
	
	int value;
	
	switch (iUpgrade){
		case 0: value = calculateChancesFloat(GoldenUpgrade(getUpgradeIndexByUpgradeId(Z_MADNESSCHANCE)).getBuffAmount(player.iMadnessChanceLevel), 1, 0);
		case 1: value = calculateChancesFloat(GoldenUpgrade(getUpgradeIndexByUpgradeId(H_CRITCHANCE)).getBuffAmount(player.iCritChanceLevel), 1, 0);
		case 2: value = calculateChancesFloat(GoldenUpgrade(getUpgradeIndexByUpgradeId(H_ITEMCHANCE)).getBuffAmount(player.iItemChanceLevel), 1, 0);
	}
	
	return value;
}

//=====================================================
//					ARMAGEDDON INTRO
//=====================================================
void StartArmageddonIntro(){
	// Define screenfade time
	float fTime = 4.0;
	
	// Bugfix: users might not plant lasermines until mode is fully started
	gServerData.RoundStart = false;
	
	// Play sound
	EmitSoundToAll("*/MassiveInfection/siren.mp3", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
	
	// Apply limitations to velocities
	ServerCommand("sv_maxvelocity 50");
	
	// Start screenfade effect
	StartSmoothScreenFadeAll(fTime);
	
	// Send HUD announcement
	SendHudAnnouncementAll(INVALID_HANDLE, 0);
	
	// Create a timer to remove the effects and start the mode
	CreateTimer(fTime*2.5, SendHudAnnouncementAll, 1);
}
public Action SendHudAnnouncementAll(Handle hTimer, any data){
	for (int i = 1; i <= MaxClients; i++){
		SendModeAnnouncement(i, data);
	}
	
	if (data){
		FinishArmageddonIntro();
	}
}
stock void SendModeAnnouncement(int client, int value){
	
	if (!IsPlayerExist(client) || IsFakeClient(client))
		return;
	
	char sBuffer[64];
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	if (value == 0){
		SetHudTextParams(-1.0, ANNOUNCER_HUD_Y_POSITION, 5.0, GetRandomInt(55, 255), GetRandomInt(55, 255), GetRandomInt(55, 255), 255, 1, 3.0, 0.4, 0.4);
		Format(sBuffer, sizeof(sBuffer), "%t", "Armageddon announcement 1");
	}
	else{
		SetHudTextParams(-1.0, ANNOUNCER_HUD_Y_POSITION, 5.0, GetRandomInt(55, 255), GetRandomInt(55, 255), GetRandomInt(55, 255), 255, 1, 3.0, 0.4, 0.4);
		Format(sBuffer, sizeof(sBuffer), "%t", "Armageddon announcement 2");
	}
	
	// Show hud message	
	ShowSyncHudText(client, gServerData.GameSync, sBuffer);
}
void FinishArmageddonIntro(){
	
	// Play sound
	EmitSoundToAll("*/MassiveInfection/nemesis1.mp3", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
	
	// Normalize velocity
	ServerCommand("sv_maxvelocity 3500");
	
	// Initialize vars
	int nAlive = fnGetAlive();
	int nMaxZombies = RoundToCeil(nAlive / 2.0);
	float volume = 0.2;
	int nHumans = nAlive - nMaxZombies;
	
	// Turn into the corresponding class
	GameModesTurnIntoZombie(nMaxZombies, PT_NEMESIS);
	GameModesTurnIntoHuman(nHumans, PT_SURVIVOR);
	
	// Ensure everyone is the class that should be
	ZPlayer player;
	for (int i = 1; i <= MaxClients; i++){
		// Get real player index from event key
		player = ZPlayer(i);
		
		// Verify that the client is exist
		if(!IsPlayerExist(player.id, true))
			continue;
		
		// Verify that the client is human
		if(player.iTeamNum != CS_TEAM_CT)
			continue;
		
		if(player.isType(PT_HUMAN))	player.TurnInto(PT_NEMESIS);
	}
	
	// Play ambience sound
	EmitSoundToAll(AMBIENT_SOUND_ARMAGEDON, SOUND_FROM_PLAYER,SNDCHAN_STATIC,_,_, volume);
	
	// Mode has finished intro, now they can plant lasermines
	gServerData.RoundStart = true;
	
	ModeStats_StartDetection();
}

//=====================================================
//					MODES FUNCS
//=====================================================
public Action TurnAssassinsIntoNemesis(Handle hTimer){
	
	if (!eventmode)
		return Plugin_Stop;
	
	ZPlayer user;
	for (int i = 1; i <= MaxClients; i++){
		user = ZPlayer(i);
		
		if (!IsPlayerExist(user.id, true))
			continue;
		
		if (user.isType(PT_ASSASSIN))
			user.TurnInto(PT_NEMESIS);
	}
	
	TranslationPrintToChatAll("Assassins into nemesis");
	
	return Plugin_Handled;
}
public Action TransformRandomIntoAssassin(Handle hTimer){
	if (!eventmode || fnGetAliveInTeam(CS_TEAM_CT) < 10)
		return Plugin_Stop;
	
	ZPlayer player = ZPlayer(GetRandomUser(PT_SURVIVOR));
	
	player.TurnInto(PT_ASSASSIN, true);
	
	TranslationPrintToChatAll("Mutation done");
	
	return Plugin_Handled;
}

//=====================================================
//					AVERAGE UTILS
//=====================================================
stock int getAveragePlayersReset(){
	
	int value = 0;
	int clients = 0;
	
	for (int i = 1; i <= MaxClients; i++){
		
		if (!IsPlayerExist(i))
			continue;
		
		if (!ZPlayer(i).bInGame)
			continue;
		
		clients++;
		value += ZPlayer(i).iReset;
	}
	
	if (!value || !clients)
		return 0;
	
	return (value/clients);
}
stock int getAveragePlayersUpgrades(int upgradeId, bool human = true){
	
	int value = 0;
	int clients = 0;
	
	int upgradeLevel = 0;
	ZPlayer player;
	
	for (int i = 1; i <= MaxClients; i++){
		
		if (!IsPlayerExist(i))
			continue;
		
		player = ZPlayer(i);
		
		if (!player.bInGame)
			continue;
		
		clients++;
		
		switch (upgradeId){
			case 0:{
				upgradeLevel = (human) ? player.iHDamageLevel : player.iZDamageLevel;
			}
			case 1:{
				upgradeLevel = (human) ? player.iHResistanceLevel : player.iZHealthLevel;
			}
			case 2:{
				upgradeLevel = (human) ? player.iHDexterityLevel : player.iZDexterityLevel;
			}
		}
		
		value += upgradeLevel;
	}
	
	if (!value || !clients)
		return 0;
	
	return (value/clients);
}
stock int getAverageMins(int value, int reduction){
	
	if (!value || reduction >= 100)
		return 0;
	
	return (value*(100-reduction)/100);
}
stock int getAverageMaxs(int value, int increasement){
	
	if (!value || !increasement)
		return 1;
	
	return (value*(100+increasement)/100);
}


//=====================================================
//					WARM UP
//=====================================================

void WarmupTurnIntoRandomAll(){
	for (int i = 1; i <= MaxClients; i++){
		if (!IsPlayerExist(i))
			continue;
		
		if (!IsPlayerAlive(i)){
			WarmUpRespawnPlayer(i);
			continue;
		}
		TurnIntoRandom(i);
	}
}
void StartWarmup(){
	
	if (hWarmupTimer != null)
		return;
	
	if (bWarmupStarted || bWarmupEnded){
		WarmupTurnIntoRandomAll();
		return;
	}
	
	bWarmupStarted = true;
	
	//PrintHintTextToAll("<font size='22' color='#XXXXXX'>Ronda de</font>\n<font size='37' color='#FF0000'>calentamiento</font>");
	TranslationPrintToChatAll("Warm Up chat message");
	
	WarmupTurnIntoRandomAll();
	
	hWarmupTimer = CreateTimer(1.0, WarmupMessages, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}
public Action WarmupMessages(Handle hTimer, any data){
	
	if (!bWarmupStarted || bWarmupEnded)
		return Plugin_Stop;
	
	int colors1[4];
	colors1[0] = GetRandomInt(120, 255);
	colors1[1] = GetRandomInt(120, 255);
	colors1[2] = GetRandomInt(120, 255);
	colors1[3] = 255;
	
	int colors2[4];
	colors2[0] = GetRandomInt(180, 255);
	colors2[1] = GetRandomInt(180, 255);
	colors2[2] = GetRandomInt(180, 255);
	colors2[3] = 255;
	
	//SetHudTextParams(0.40, 0.20, 1.0, GetRandomInt(55, 255), GetRandomInt(55, 255), GetRandomInt(55, 255), 255, 2, 0.1, 0.1, 0.1);
	SetHudTextParamsEx(-1.0, 0.15, 1.0, colors1, colors2, 1, 1.0, 0.03, 0.04);
	
	iWarmupTime++;
	
	if (iWarmupTime < WARMUP_DURATION){
		for (int i = 1; i <= MaxClients; i++){
			if (!IsPlayerExist(i)){
				continue;
			}
			
			SetGlobalTransTarget(i);
			ShowSyncHudText(i, gServerData.GameSync, "%t", "Warmup finishes in", RoundToZero(WARMUP_DURATION)-iWarmupTime);
		}
	}
	else{
		hWarmupTimer = null;
		iWarmupTime = 0;
		FinishWarmup(0, 0);
		
		for (int i = 1; i <= MaxClients; i++){
			if (!IsPlayerExist(i)){
				continue;
			}
			
			SetGlobalTransTarget(i);
			ShowSyncHudText(i, gServerData.GameSync, "%t", "Warmup round finished");
		}
		return Plugin_Stop;
	}
	return Plugin_Continue;
	
}
public Action FinishWarmup(int client, int args){
	
	if (ActualMode.is(MODE_WARMUP)){
		bWarmupEnded = true;
		CS_TerminateRound(0.1, CSRoundEnd_GameStart);
	}
}
void WarmUpRespawnPlayer(int client){
	
	ZPlayer player = ZPlayer(client);
	
	if (!IsPlayerExist(client))
		return;
	
	if (!IsFakeClient(client) && !gClientData[client].bLoaded)
		return;
	
	if (player.bAlive)
		return;
	
	player.iRespawnPlayer();
	TurnIntoRandom(client);
}
void TurnIntoRandom(int client){
	
	ZPlayer player = ZPlayer(client);
	
	if (!IsPlayerExist(client, true))
		return;
		
	if (!IsFakeClient(client) && !gClientData[client].bLoaded)
		return;
	
	bool zombie;
	int iZombies = fnGetInTeam(CS_TEAM_T);
	int iHumans = fnGetInTeam(CS_TEAM_CT);
	
	if (iZombies > iHumans)
		zombie = false;
	else if (iHumans > iZombies)
		zombie = true;
	else
		zombie = view_as<bool>(GetRandomInt(0, 1));
		
	/*	
	int nMaxZombies = RoundToCeil(nAlive / 2.0);
	int nHumans = nAlive - nMaxZombies;
	
	// Turn into the corresponding class
	GameModesTurnIntoZombie(nMaxZombies, nAlive, view_as<ZombieType>(GetRandomInt(view_as<int>(ZOMBIE), view_as<int>(ASSASSIN))));
	GameModesTurnIntoHuman(nHumans, nAlive, view_as<HumanType>(GetRandomInt(view_as<int>(HUMAN), view_as<int>(SNIPER));*/
	
	int iType;
	if (zombie){
		iType = GetRandomInt(view_as<int>(PT_ZOMBIE)+1, view_as<int>(PT_MAX_ZOMBIES)-1);
	}
	else{
		iType = GetRandomInt(view_as<int>(PT_HUMAN)+1, view_as<int>(PT_MAX_HUMANS)-2);
	}
	player.TurnInto(view_as<PlayerType>(iType));
}

//=====================================================
//					GRENADES
//=====================================================
/*public Action TimerOnGrenadeCreated(Handle timer, any ref){
	int entity = EntRefToEntIndex(ref);
	if(entity != INVALID_ENT_REFERENCE){
		SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
	}
}*/

// Create again detonation event
public Action CreateEventGrenadeDetonate(Handle timer, any hPack){
	ResetPack(hPack);
	
	int entity = ReadPackCell(hPack);
	
	if (!IsValidEdict(entity)){
		delete view_as<DataPack>(hPack);
		return Plugin_Stop;
	}
	
	bool bFreeze = ReadPackCell(hPack);
	
	char g_szClassname[64];
	GetEdictClassname(entity, g_szClassname, sizeof(g_szClassname));
	
	if (!strcmp(g_szClassname, "flashbang_projectile", false)){
		float origin[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
		int client = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
		
		bFreeze ? FreezeSplash(client, origin) : ZombiefySplash(client, origin);
		
		RemoveEntity(entity);
		//AcceptEntityInput(entity, "Kill");
	}
	delete view_as<DataPack>(hPack);
	return Plugin_Stop;
}

// Create burning grenade detonation event
public Action CreateEventBurnDetonate(Handle timer, any ref){
	int entity = EntRefToEntIndex(ref);
	
	if (!IsValidEdict(entity))
		return Plugin_Stop;
		
	static char sClassname[64];
	GetEdictClassname(entity, sClassname, sizeof(sClassname));
	
	if (!strcmp(sClassname, "hegrenade_projectile", false)){
		float origin[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
		int client = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
		
		BurningSplash(client, origin);
		
		//AcceptEntityInput(entity, "kill");
		RemoveEntity(entity);
	}
	return Plugin_Stop;
}

// Projectile's beam
void BeamFollowCreate(int entity, int color[4]){
	TE_SetupBeamFollow(entity, BeamSprite,	0, 1.0, 10.0, 10.0, 5, color);
	TE_SendToAll();	
}

// Kill original projectile
public Action DeleteEntity(Handle timer, any entref){
	int entity = EntRefToEntIndex(entref);
	if (IsValidEntity(entity)){
		//AcceptEntityInput(entity, "kill");
		RemoveEntity(entity);
	}
}
public bool FilterTarget(int entity, int contentsMask, any data){
	return (data == entity);
}

//=====================================================
//					INFECTION GRENADE
//=====================================================
void ZombiefySplash(int client, float origin[3]){
	
	origin[2] += 10.0;
	
	float targetOrigin[3];
	
	int infected = 0;
	
	for (int i = 1; i <= MaxClients; i++){
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;
		
		ZPlayer victim = ZPlayer(i);
		
		GetClientAbsOrigin(i, targetOrigin);
		targetOrigin[2] += 2.0;
		if (GetVectorDistance(origin, targetOrigin) <= FREEZE_DISTANCE){
			Handle trace = TR_TraceRayFilterEx(origin, targetOrigin, MASK_SOLID, RayType_EndPoint, FilterTarget, i);
			if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == i) || (GetVectorDistance(origin, targetOrigin) <= 100.0)){
				if(fnGetHumans() <= 1) continue;
				if(victim.isType(PT_HUMAN)){
					victim.Zombiefy();
					TranslationPrintHintText(victim.id, "Infected infection grenade");
					
					char sName[48];
					GetClientName(victim.id, sName, sizeof(sName));
					TranslationPrintHudTextAll(gServerData.GameSync, 0.03, 0.35, 3.0, 0, 200, 30, 255, 1, 1.0, 1.0, 1.0, "Has been infected", sName);
					
					infected++;
				}
				delete trace;
			}
			else
			{
				delete trace;
				
				GetClientEyePosition(i, targetOrigin);
				targetOrigin[2] -= 2.0;
		
				trace = TR_TraceRayFilterEx(origin, targetOrigin, MASK_SOLID, RayType_EndPoint, FilterTarget, i);
			
				if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == i) || (GetVectorDistance(origin, targetOrigin) <= 100.0)){
					if(fnGetHumans() <= 1) continue;
					if(victim.isType(PT_HUMAN)){
						victim.Zombiefy();
						TranslationPrintHintText(victim.id, "Infected infection grenade");
						
						char sName[48];
						GetClientName(victim.id, sName, sizeof(sName));
						TranslationPrintHudTextAll(gServerData.GameSync, 0.03, 0.35, 3.0, 0, 200, 30, 255, 1, 1.0, 1.0, 1.0, "Has been infected", sName);
						
						infected++;
					}
				}
				delete trace;
			}
		}
	}
	
	if(fnGetHumans() < 1){
		RoundEndOnValidate(false);
	}
	
	if (infected){
		if (!IsPlayerExist(client))
			return;
		
		ZPlayer attacker = ZPlayer(client);
		DataPack hPack = new DataPack();
		hPack.WriteCell(attacker.id);
		hPack.WriteCell(infected);
		
		CreateTimer(2.0, PrintInfectionMessage, hPack);
	}
	
	TE_SetupBeamRingPoint(origin, 10.0, FREEZE_DISTANCE, BeamSprite, g_halosprite, 1, 1, 0.2, 100.0, 1.0, InfectColor, 0, 0);
	TE_SendToAll();
	LightCreate(FLASH, origin);
}
public Action PrintInfectionMessage(Handle hTimer, any hPack){
	ResetPack(hPack);

	int client = ReadPackCell(hPack);
	int infected = ReadPackCell(hPack);
	
	if (IsPlayerExist(client)){
		
		ZPlayer player = ZPlayer(client);
		
		// Calculate gain
		int value = player.iLevel * INFECTION_SCALAR_REWARD;
		
		int total = player.applyGain((INFECTION_BASE_REWARD + value)*infected);
		
		char sPointed[32];
		AddPoints(total, sPointed, sizeof(sPointed));
		TranslationPrintToChat(player.id, "Infection grenade earnings", sPointed);
	}
	
	delete view_as<DataPack>(hPack);
	return Plugin_Stop;
}

//=====================================================
//					FREEZE GRENADE
//=====================================================
void FreezeSplash(int client, float origin[3]){
	origin[2] += 10.0;
	
	float targetOrigin[3];
	static float vVictimAngle[3];
	for (int i = 1; i <= MaxClients; i++){
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;
		
		// Get victim's eye angle
		GetClientEyeAngles(i, vVictimAngle);
		
		GetClientAbsOrigin(i, targetOrigin);
		targetOrigin[2] += 2.0;
		if (GetVectorDistance(origin, targetOrigin) <= FREEZE_DISTANCE){
			Handle trace = TR_TraceRayFilterEx(origin, targetOrigin, MASK_SOLID, RayType_EndPoint, FilterTarget, i);
			if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == i) || (GetVectorDistance(origin, targetOrigin) <= 100.0)){
				Freeze(i, client, FREEZE_DURATION);
				delete trace;
			}
			else
			{
				delete trace;
				
				GetClientEyePosition(i, targetOrigin);
				targetOrigin[2] -= 2.0;
		
				trace = TR_TraceRayFilterEx(origin, targetOrigin, MASK_SOLID, RayType_EndPoint, FilterTarget, i);
			
				if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == i) || (GetVectorDistance(origin, targetOrigin) <= 100.0)){
					Freeze(i, client, FREEZE_DURATION);
				}
				delete trace;
			}
		}
	}
	
	TE_SetupBeamRingPoint(origin, 10.0, FREEZE_DISTANCE, BeamSprite, g_halosprite, 1, 1, 0.2, 100.0, 1.0, FreezeColor, 0, 0);
	TE_SendToAll();
	LightCreate(FLASH, origin);
}
bool Freeze(int client, int attacker, float time){
	ZPlayer player = ZPlayer(client);
	#pragma unused attacker
	float dummy_duration = time;
	if(!player.isType(PT_ZOMBIE)) return false;
	
	if (player.bInvulnerable) return false;
	
	if (player.hFreezeTimer != INVALID_HANDLE){
		KillTimer(player.hFreezeTimer);
		player.hFreezeTimer = INVALID_HANDLE;
	}
	
	SetEntityMoveType(client, MOVETYPE_NONE);
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, NULL_VELOCITY);
	
	float vec[3];
	GetClientEyePosition(client, vec);
	vec[2] -= 50.0;
	//EmitAmbientSound(SOUND_FREEZE, vec, client, SNDLEVEL_RAIDSIREN);
	EmitSoundToAll(SOUND_FREEZE, SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vec);

	TE_SetupGlowSprite(vec, GlowSprite, dummy_duration, 2.0, 50);
	TE_SendToAll();
	
	player.removeGlow();
	player.applyGlow({0, 110, 255});
	
	player.hFreezeTimer = CreateTimer(dummy_duration, Unfreeze, client, TIMER_FLAG_NO_MAPCHANGE);
	
	return true;
}
public Action Unfreeze(Handle timer, any client){
	ZPlayer player = ZPlayer(client);
	
	if (!IsPlayerExist(player.id, true)){
		player.hFreezeTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	if (player.hFreezeTimer != INVALID_HANDLE){
		SetEntityMoveType(client, MOVETYPE_WALK);
		player.hFreezeTimer = INVALID_HANDLE;
		player.setGravity();
		
		player.removeGlow();
		if (player.iZombieAlignment == iRadAlignment){
			player.applyGlow({ 40, 200, 40 });
		}
	}
	
	return Plugin_Stop;
}

// Start of light grenade
void LightCreate(int grenade, float pos[3]){
	
	switch(grenade){
		case SMOKE :{
			
			char sColors[24];
			FormatEx(sColors, sizeof(sColors), "%i %i %i 80", GetRandomInt(40, 100), GetRandomInt(40, 100), GetRandomInt(40, 100));
				
			// Create effects
			UTIL_CreateLight(INVALID_ENT_REFERENCE, pos, _, _, _, _, _, _, _, sColors, GRENADE_FLARE_DISTANCE, GRENADE_FLARE_RADIUS, GRENADE_FLARE_DURATION);
		}
		case FLASH :{
			UTIL_CreateLight(INVALID_ENT_REFERENCE, pos, _, _, _, _, _, _, _, "75 75 255 255", FREEZE_DISTANCE, FREEZE_DISTANCE, 0.1);
		}
	}
}

// Start of burning grenade
void BurningSplash(int client, float origin[3]){
	origin[2] += 10.0;
	
	#pragma unused client
	
	float targetOrigin[3];
	for (int i = 1; i <= MaxClients; i++){
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;
		
		GetClientAbsOrigin(i, targetOrigin);
		targetOrigin[2] += 2.0;
		if (GetVectorDistance(origin, targetOrigin) <= BURN_DISTANCE){
			Handle trace = TR_TraceRayFilterEx(origin, targetOrigin, MASK_SOLID, RayType_EndPoint, FilterTarget, i);
			if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == i) || (GetVectorDistance(origin, targetOrigin) <= 100.0)){
				ZPlayer victim = ZPlayer(i);
				
				if (victim.isType(PT_ASSASSIN))
					continue;
				
				if (victim.iTeamNum == CS_TEAM_T){
					IgniteEntity(victim.id, victim.isBoss() ? 0.8 : BURN_DURATION);
					victim.iIgniterId = client;
				}
				
				delete trace;
			}
			else{
				delete trace;
				
				GetClientEyePosition(i, targetOrigin);
				targetOrigin[2] -= 2.0;
		
				trace = TR_TraceRayFilterEx(origin, targetOrigin, MASK_SOLID, RayType_EndPoint, FilterTarget, i);
			
				if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == i) || (GetVectorDistance(origin, targetOrigin) <= 100.0)){
					ZPlayer victim = ZPlayer(i);
					
					if (victim.isType(PT_ASSASSIN))
						continue;
					
					if (victim.iTeamNum == CS_TEAM_T){
						IgniteEntity(victim.id, victim.isBoss() ? 0.8 : BURN_DURATION);
						victim.iIgniterId = client;
					}
				}
				
				delete trace;
			}
		}
	}
	
	TE_SetupBeamRingPoint(origin, 10.0, BURN_DISTANCE, BeamSprite, g_halosprite, 1, 1, 0.2, 100.0, 1.0, BurnColor, 0, 0);
	TE_SendToAll();
	LightCreate(FLASH, origin);
}

// Cancel explosion sound
public Action NormalSHook(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags){
	
	/*
	if (!strcmp(sample, "^weapons/smokegrenade/sg_explode.wav"))
		return Plugin_Handled;*/
		
	// Validate client
	if (IsValidEdict(entity)){
		
		// Validate custom grenade
		//if (GetEntProp(entity, Prop_Data, "m_iHammerID") == gWeapon){
			
			// Validate sound
			/*if (!strncmp(sample[31], "hit", 3, false)){
				
				// Play sound
				
				// Block sounds
				return Plugin_Stop; 
			}
			else */if (!strncmp(sample[29], "emit", 4, false)){
				
				// Play sound
				
				// Block sounds
				return Plugin_Stop; 
			}
		//}
	}
	
	return Plugin_Continue;
}

///////////////////////////////////////
public void GrenadeSpawnPost(int entity){
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	//if (client == -1) return;
	
	ZPlayer owner = ZPlayer(client);
	
	char classname[64];
	GetEdictClassname(entity, classname, sizeof(classname));
	
	// Hook every grenade projectile entity
	// -> HERE!
	if (!strcmp(classname, "hegrenade_projectile")){
		int iReference = EntIndexToEntRef(entity);
		
		// Create a proper event for our purposes
		CreateTimer(1.3, CreateEventBurnDetonate, iReference, TIMER_FLAG_NO_MAPCHANGE);
		
		// Block grenade
		SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
		
		BeamFollowCreate(entity, BurnColor);
	}
	else if (!strcmp(classname, "flashbang_projectile")){
		
		char sName[32];
		GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));
			
		if (StrEqual(sName, "infectgrenade_projectile")){
			
			SetEntityModel(entity, INFECT_GRENADE_DROPPED_MODEL);
			
			// Now we can continue
			BeamFollowCreate(entity, InfectColor);
			CreateTimer(1.3, CustomEventGrenadeDetonate, entity, TIMER_FLAG_NO_MAPCHANGE);
		
			//int iReference = EntIndexToEntRef(entity);
			
			// Block grenade
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			return;
		}
			
		// Lets create a datapack to ensure effectivity
		DataPack hPack = new DataPack();
		hPack.WriteCell(entity);
		
		// Is owner zombie or human?
		hPack.WriteCell(owner.isHuman());
		
		if (owner.isType(PT_ZOMBIE)){
			SetEntPropString(entity, Prop_Data, "m_iName", "infectgrenade_projectile");
			SetEntityModel(entity, INFECT_GRENADE_DROPPED_MODEL);
		}
		
		// Now we can continue
		BeamFollowCreate(entity, owner.isType(PT_ZOMBIE) ? InfectColor : FreezeColor);
		CreateTimer(1.3, CreateEventGrenadeDetonate, hPack, TIMER_FLAG_NO_MAPCHANGE);
		
		//int iReference = EntIndexToEntRef(entity);
		
		// Block grenade
		SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
	}
	else if (!strcmp(classname, "smokegrenade_projectile")){
		// Get owner's pack
		ZGrenadePack pack = ZGrenadePack(owner.iGrenadePack); 
		
		if (pack.hasGrenade(AURA_GRENADE)){
			SetEntityModel(entity, AURA_DROPPED_GRENADE);
		}
		
		BeamFollowCreate(entity, FlashColor);
	}
	else if (!strcmp(classname, "decoy_projectile")){
		
		// Get owner's pack
		ZGrenadePack pack = ZGrenadePack(owner.iGrenadePack);
		
		if (pack.hasGrenade(VOID_GRENADE)){
			SetEntityModel(entity, BLACKHOLE_WMODEL);
			
			BeamFollowCreate(entity, BlackHoleColor);
		
			if(0 < client <= MaxClients){
				
				//SetEntityModel(entity, BLACKHOLE_WMODEL);
				SetEntPropString(entity, Prop_Data, "m_iName", BLACKHOLE_EFFECT_NAME);
				SDKHook(entity, SDKHook_TouchPost, DecoyTouchPost);
			}
		}
	}
}

// Modified grenades rain func to detonate
// Create again detonation event
public Action CustomEventGrenadeDetonate(Handle timer, any data){
	
	int entity = data;
	
	if (!IsValidEdict(entity)){
		return Plugin_Stop;
	}
	
	char g_szClassname[64];
	GetEdictClassname(entity, g_szClassname, sizeof(g_szClassname));
	
	if (!strcmp(g_szClassname, "flashbang_projectile", false)){
		float origin[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
		
		ZombiefySplash(0, origin);
		
		//AcceptEntityInput(entity, "Kill");
		RemoveEntity(entity);
	}
	
	return Plugin_Stop;
}

//=====================================================
//					AURA SHIELD
//=====================================================
public Action CreateAuraShield(int client, float coords[3]){
	int entity = CreateEntityByName("prop_dynamic_glow");
	
	if (IsValidEntity(entity)){
		// Move entity to origins
		TeleportEntity(entity, coords, NULL_VECTOR, NULL_VECTOR);
		
		DispatchKeyValue(entity, "Classname", AURA_CLASSNAME);
		DispatchKeyValue(entity, "model", AURA_WORLDMODEL);
		DispatchKeyValue(entity, "Solid", "6");
		DispatchKeyValue(entity, "SetGlowEnabled", "1");
		
		// SOLID TEST
		//DispatchKeyValue(entity, "Collisions", "1");
		
		SetEntProp(entity, Prop_Send, "m_usSolidFlags", 12); // FSOLID_NOT_SOLID|FSOLID_TRIGGER 
		SetEntProp(entity, Prop_Data, "m_nSolidType", 6); // SOLID_VPHYSICS 
		SetEntProp(entity, Prop_Send, "m_CollisionGroup", 5); // COLLISION_GROUP_DEBRIS
		
		// GLOW THIS SH*T
		SetEntProp(entity, Prop_Send, "m_bShouldGlow", true, true);
		SetEntProp(entity, Prop_Send, "m_nGlowStyle", 1); 
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 1.2);
		SetEntPropFloat(entity, Prop_Send, "m_flGlowMaxDist", 100000000.0);
		
		int iColors[4];
		
		iColors[0] = GetRandomInt(35, 255);
		iColors[1] = GetRandomInt(35, 255);
		iColors[2] = GetRandomInt(35, 255);
		iColors[3] = 255;
		
		SetVariantColor(iColors);
		AcceptEntityInput(entity, "SetGlowColor");
		
		SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
		SetEntityRenderColor(entity, 255, 255, 255, 110);
		
		DispatchSpawn(entity);
		ActivateEntity(entity);
		
		// Send data to the next frame
		DataPack hPack = new DataPack();
		hPack.WriteCell(entity);
		hPack.WriteCell(client);
		
		RequestFrame(FrameCallback, hPack);
		
		//SDKHook(entity, SDKHook_Touch, AuraOnStartTouch);
	}
	return Plugin_Handled;
}
void PushPlayersAwayFromForceField(int client, int iForcefield){
	
	if(IsValidEntity(iForcefield)){
	
		ZPlayer player = ZPlayer(client);
		
		if (!IsPlayerExist(player.id, true))
			return;
			
		if (!player.isType(PT_ZOMBIE) || player.bInvulnerable)
			return;
		
		float clientPos[3], forcefieldPos[3];
		GetClientAbsOrigin(client, clientPos);
		GetEntPropVector(iForcefield, Prop_Send, "m_vecOrigin", forcefieldPos);
		
		float distance = GetVectorDistance(clientPos, forcefieldPos);
		
		if(distance < 170.0){
			if (player.bLadder){
				SetEntityMoveType(client, MOVETYPE_WALK);
				player.setGravity();
				player.bLadder = false;
			}
			
			if (player.hFreezeTimer != INVALID_HANDLE)
				Unfreeze(player.hFreezeTimer, player.id);
			
			SetEntPropEnt(client, Prop_Data, "m_hGroundEntity", -1);
			
			float direction[3];
			SubtractVectors(forcefieldPos, clientPos, direction);
			
			float gravityForce = FindConVar("sv_gravity").FloatValue * (((800.0 * 180.0 / 50) * 20.0) / GetVectorLength(direction,true));
			gravityForce = gravityForce / 20.0;
			
			NormalizeVector(direction, direction);
			ScaleVector(direction, gravityForce);
			
			float playerVel[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", playerVel);
			
			ScaleVector(direction, distance / 200);
			SubtractVectors(playerVel, direction, direction);
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, direction);
		}
	}
}
void UpdateForceFields(){

	static int iForcefield;

	for (int index = 0; index < AuraShields.Length; index++){
		
		iForcefield = EntRefToEntIndex(AuraShields.Get(index));
		if(IsValidEntity(iForcefield)){
		
			for (int client = 1; client <= MaxClients; client++){
			
				if (!IsPlayerExist(client, true))
					continue;
				
				if (!ZPlayer(client).isType(PT_ZOMBIE) || ZPlayer(client).bInvulnerable)
					continue;
					
				PushPlayersAwayFromForceField(client, iForcefield);
			}
			
			PushAwayFromForceField(iForcefield, "prop_physics*");
			//PushAwayFromForceField(iForcefield, "flashbang_projectile");
		}
		else
			AuraShields.Erase(index);
	}
}
void PushAwayFromForceField(int iForcefield, const char[] classname){

	int iEnt = MaxClients + 1;
	while((iEnt = FindEntityByClassname(iEnt, classname)) != -1){
		/*
		if (StrEqual(classname, "flashbang_projectile")){
		
			char sName[32];
			GetEntPropString(iEnt, Prop_Data, "m_iName", sName, sizeof(sName));
			
			if (!StrEqual(sName, "infectgrenade_projectile"))
				return;
		}*/
	
		float propPos[3], forcefieldPos[3];
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", propPos);
		GetEntPropVector(iForcefield, Prop_Send, "m_vecOrigin", forcefieldPos);
		
		float distance = GetVectorDistance(propPos, forcefieldPos);
		if(distance < 180.0){
			SetEntPropEnt(iEnt, Prop_Data, "m_hGroundEntity", -1);
			
			float direction[3];
			SubtractVectors(forcefieldPos, propPos, direction);
			
			float gravityForce = FindConVar("sv_gravity").FloatValue * (((800.0 * 180.0 / 50) * 20.0) / GetVectorLength(direction,true));
			gravityForce = gravityForce / 20.0;
			
			NormalizeVector(direction, direction);
			ScaleVector(direction, gravityForce);
			
			float playerVel[3];
			GetEntPropVector(iEnt, Prop_Data, "m_vecVelocity", playerVel);

			ScaleVector(direction, distance / 200);
			SubtractVectors(playerVel, direction, direction);
			TeleportEntity(iEnt, NULL_VECTOR, NULL_VECTOR, direction);
		}
	}
}
public void FrameCallback(DataPack hPack){
	
	hPack.Reset();
	
	int entity = ReadPackCell(hPack);
	int client = ReadPackCell(hPack);
	
	if (!IsValidEdict(entity)){
		delete view_as<DataPack>(hPack);
		return;
	}
	
	int ref = EntIndexToEntRef(entity);
	
	AuraShields.Push(ref);
	
	ZPlayer player = ZPlayer(client);
	
	//CreateTimer(player.iAuraTimeLevel ? applyPercentage(AURA_DURATION, GoldenHUpgradesAmount[H_AURATIME][player.iAuraTimeLevel-1]) : AURA_DURATION, AuraTimer, ref, TIMER_FLAG_NO_MAPCHANGE);
	
	if (player.iAuraTimeLevel){
		CreateTimer(applyPercentage(AURA_DURATION, GoldenUpgrade(getUpgradeIndexByUpgradeId(H_AURATIME)).getBuffAmount(player.iAuraTimeLevel)), AuraTimer, ref, TIMER_FLAG_NO_MAPCHANGE);
		//PrintToChatAll("DURACION: %f segs", applyPercentage(AURA_DURATION, GoldenHUpgradesAmount[H_AURATIME][player.iAuraTimeLevel-1]));
	}
	else{
		CreateTimer(AURA_DURATION, AuraTimer, ref, TIMER_FLAG_NO_MAPCHANGE);
		//PrintToChatAll("DURACION: %f segs", AURA_DURATION);
	}
	
	
	delete view_as<DataPack>(hPack);
}
public Action AuraTimer(Handle hTimer, any data){
	
	int entity = EntRefToEntIndex(data);
	
	if (!IsValidEntity(entity))
		return;
	
	int index = AuraShields.FindValue(data);
	
	if(index != -1)
		AuraShields.Erase(index);
	
	//AcceptEntityInput(entity, "Kill");
	RemoveEntity(entity);

}

//=====================================================
//					BLACK HOLE
//=====================================================
void UpdateBlackHoles(){
	
	int owner;
	ZPlayer player;
	
	ZGrenadePack pack;
	
	static int iBlackhole;
	for (int index = 0; index < BlackHoles.Length; index++){
		
		iBlackhole = EntRefToEntIndex(BlackHoles.Get(index));
		if(IsValidEntity(iBlackhole)){
			
			owner = GetEntPropEnt(iBlackhole, Prop_Data, "m_hOwnerEntity");
			
			if (!IsPlayerExist(owner, true)){
				BlackHoles.Erase(index);
				//AcceptEntityInput(iBlackhole, "Kill");
				RemoveEntity(iBlackhole);
				break;
			}
			
			// Get owner's pack
			pack = ZGrenadePack(ZPlayer(owner).iGrenadePack);
			
			if(!pack.hasGrenade(VOID_GRENADE)){
				BlackHoles.Erase(index);
				//AcceptEntityInput(iBlackhole, "Kill");
				RemoveEntity(iBlackhole);
				break;
			}
			
			for (int client = 1; client <= MaxClients; client++){
				
				if(IsClientInGame(client) && IsPlayerAlive(client)){
					
					if (!IsPlayerExist(client, true))
						continue;
					
					player = ZPlayer(client);
					
					if (!player.isType(PT_ZOMBIE) || player.bInvulnerable)
						continue;
						
					PushPlayersToBlackHole(client, owner, iBlackhole);
				}
			}
		
			PushToBlackHole(iBlackhole, "prop_physics*");
			PushToBlackHole(iBlackhole, "weapon_*");
			//PushToBlackHole(iBlackhole, "hegrenade_projectile");
			//PushToBlackHole(iBlackhole, "flashbang_projectile");
			//PushToBlackHole(iBlackhole, "smokegrenade_projectile");
		}
		else
			BlackHoles.Erase(index);
	}
}

#define VOID_GRENADE_HP_PCT_DAMAGE 		0.0001
#define VOID_GRENADE_MAX_DAMAGE_PER_HIT 900.0
#define VOID_GRENADE_MAX_DAMAGE_PER_HIT_HORDE 150.0

float VoidGetMaxHPDamage(int hp){
	
	float damage;
	
	damage = float(hp)*VOID_GRENADE_HP_PCT_DAMAGE;
	
	if (damage > VOID_GRENADE_MAX_DAMAGE_PER_HIT){
		damage = VOID_GRENADE_MAX_DAMAGE_PER_HIT;
	}
	
	if (ActualMode.is(MODE_HORDE)){
		if (damage > VOID_GRENADE_MAX_DAMAGE_PER_HIT_HORDE){
			damage = VOID_GRENADE_MAX_DAMAGE_PER_HIT_HORDE;
		}
	}
	
	return damage;
}
void PushPlayersToBlackHole(int client, int owner, int iBlackhole){
	
	if(IsValidEntity(iBlackhole)){
		
		float clientPos[3], blackholePos[3];
		GetClientAbsOrigin(client, clientPos);
		GetEntPropVector(iBlackhole, Prop_Send, "m_vecOrigin", blackholePos);
		
		float distance = GetVectorDistance(clientPos, blackholePos);
		
		if(distance < 20.0){
			
			if (!IsPlayerExist(client, true))
				return;
		
			ZPlayer player = ZPlayer(client);
		
			if (!player.isType(PT_ZOMBIE) || player.bInvulnerable)
				return;
			
			UTIL_CreateShakeScreen(client, 5.0, 0.1, 0.7);
			
			if (owner == -1 || !IsClientInGame(owner)){
				owner = iBlackhole;
			}
			
			ZPlayer victim = ZPlayer(client);
			
			if (client != owner){
				SDKHooks_TakeDamage(client, iBlackhole, owner, VoidGetMaxHPDamage(victim.iHp), DMG_DROWN, -1);
			}
		}
		if(distance < BLACKHOLE_MIN_DISTANCE){
			
			if (!IsPlayerExist(client, true))
				return;
		
			ZPlayer player = ZPlayer(client);
		
			if (!player.isType(PT_ZOMBIE) || player.bInvulnerable)
				return;
			
			UTIL_CreateShakeScreen(client, 5.0, 0.1, 0.7);
			
			SetEntPropEnt(client, Prop_Data, "m_hGroundEntity", -1);
			
			float direction[3];
			SubtractVectors(blackholePos, clientPos, direction);
			
			float gravityForce = FindConVar("sv_gravity").FloatValue * (((BLACKHOLE_FORCE_PULL * BLACKHOLE_MIN_DISTANCE / 50) * 20.0) / GetVectorLength(direction,true));
			gravityForce = gravityForce / 20.0;
			
			NormalizeVector(direction, direction);
			ScaleVector(direction, gravityForce);
			
			float playerVel[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", playerVel);
			NegateVector(direction);
			ScaleVector(direction, distance / 300);
			SubtractVectors(playerVel, direction, direction);
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, direction);
		}
	}
}
void PushToBlackHole(int iBlackhole, const char[] classname){
	
	int iEnt = MaxClients + 1;
	while((iEnt = FindEntityByClassname(iEnt, classname)) != -1){
		
		float propPos[3], blackholePos[3];
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", propPos);
		GetEntPropVector(iBlackhole, Prop_Send, "m_vecOrigin", blackholePos);
		
		float distance = GetVectorDistance(propPos, blackholePos);
		if(distance > 20.0 && distance < BLACKHOLE_MIN_DISTANCE){
			
			float direction[3];
			SubtractVectors(blackholePos, propPos, direction);
			
			float gravityForce = FindConVar("sv_gravity").FloatValue * (((BLACKHOLE_FORCE_PULL * BLACKHOLE_MIN_DISTANCE / 50) * 20.0) / GetVectorLength(direction,true));
			gravityForce = gravityForce / 20.0;
			
			NormalizeVector(direction, direction);
			ScaleVector(direction, gravityForce);
			
			float entityVel[3];
			GetEntPropVector(iEnt, Prop_Data, "m_vecVelocity", entityVel);
			NegateVector(direction);
			ScaleVector(direction, distance / 300);
			SubtractVectors(entityVel, direction, direction);
			TeleportEntity(iEnt, NULL_VECTOR, NULL_VECTOR, direction);
		}
	}
}

public Action DecoyTouchPost(int entity, int other){
	
	if(other == 0 || IsEntityLasermine(other)){
	
		if(!IsValidEntity(entity))
			return;
			
		int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
		
		if(owner < 1 || owner > MaxClients || !IsClientInGame(owner)){
			//AcceptEntityInput(entity, "Kill");
			RemoveEntity(entity);
		}
		
		float vecPos[3], startPoint[3], endPoint[3], slopeAngle[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vecPos);
		endPoint = vecPos;
		startPoint = vecPos;
		endPoint[2] = vecPos[2] - 5.0;
		
		Handle traceZ = TR_TraceRayFilterEx(startPoint, endPoint, MASK_PLAYERSOLID, RayType_EndPoint, TraceFilterNotSelf, entity);
		TR_GetPlaneNormal(traceZ, slopeAngle);
		
		endPoint = vecPos;
		startPoint = vecPos;
		startPoint[1] = vecPos[1] + 1.0;
		endPoint[1] = vecPos[1] - 1.0;
		
		Handle traceX = TR_TraceRayFilterEx(startPoint, endPoint, MASK_PLAYERSOLID, RayType_EndPoint, TraceFilterNotSelf, entity);
		
		endPoint = vecPos;
		startPoint = vecPos;
		startPoint[0] = vecPos[0] + 1.0;
		endPoint[0] = vecPos[0] - 1.0;
		
		Handle traceY = TR_TraceRayFilterEx(startPoint, endPoint, MASK_PLAYERSOLID, RayType_EndPoint, TraceFilterNotSelf, entity);

		if((TR_DidHit(traceZ) && !TR_DidHit(traceX) && !TR_DidHit(traceY)) || slopeAngle[2] > 0.5)
			RequestFrame(DecoyFrameCallback, entity);
			
		delete traceZ;
		delete traceX;
		delete traceY;
	}
}
public void DecoyFrameCallback(any entity){
	
	if(!IsValidEntity(entity))
		return;
	
	SDKUnhook(entity, SDKHook_TouchPost, DecoyTouchPost);
	
	char entityName[16];
	GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));
	int ref = EntIndexToEntRef(entity);
	float vel[3] =  { 0.0, 0.0, 300.0 };
	
	if (StrEqual(entityName, BLACKHOLE_EFFECT_NAME, false)){
		vel[2] = BLACKHOLE_BOUNCE_VELOCITY;
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vel);
		CreateTimer(0.5, DecoyTimer, ref);
	}
}
public Action DecoyTimer(Handle timer, any ref){
	int ent = EntRefToEntIndex(ref);
	BlackHoleSpawnEffect(ent);
}
void BlackHoleSpawnEffect(int entity){
	
	if(!IsValidEntity(entity))
		return;
	
	float interval = 10.0;
	float nadeOrigin[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", nadeOrigin);
	int volumeIndex;
	
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	if(owner < 1 || owner > MaxClients)
		return;
	
	if(!IsClientInGame(owner))
		return;
	
	int particle = CreateEntityByName("info_particle_system");
	SetEntPropEnt(particle, Prop_Data, "m_hOwnerEntity", owner);
	SetEntPropString(particle, Prop_Data, "m_iName", BLACKHOLE_EFFECT_NAME);
	//AcceptEntityInput(entity, "Kill");
	RemoveEntity(entity);
	
	int ref = EntIndexToEntRef(particle);
	
	DispatchKeyValue(particle, "effect_name", BLACKHOLE_EFFECT_NAME);

	BlackHoles.Push(ref);
	volumeIndex = BlackHoles.FindValue(ref);
	EmitSoundToAll("*/piu/blackhole.mp3", entity, SNDCHAN_ITEM, _, _, BLACKHOLE_VOLUME, _, _, nadeOrigin);
	//EmitSoundToAll("piu/blackhole.mp3", SOUND_FROM_PLAYER, SNDCHAN_ITEM,_,_, BLACKHOLE_VOLUME);
	interval = BLACKHOLE_DURATION;
	
	#if BLACKHOLE_INDICATOR > 0
		
	int color[4] =  { 80, 100, 200, 60 };
	TE_SetupBeamRingPoint(nadeOrigin, (BLACKHOLE_MIN_DISTANCE + 80.0)*1.4, (BLACKHOLE_MIN_DISTANCE + 81.0)*1.4, GlowSprite, GlowSprite, 0, 60, BLACKHOLE_DURATION, 10.0, 10.0, color, 1, 0);
	TE_SendToAll();
	#endif
	
	
	DispatchKeyValue(particle, "start_active", "0");
	DispatchSpawn(particle);
	TeleportEntity(particle, nadeOrigin, NULL_VECTOR,NULL_VECTOR);
	ActivateEntity(particle);
	AcceptEntityInput(particle, "Start");

	DataPack pack;
	CreateDataTimer(interval, Timer_Duration, pack);
	pack.WriteCell(ref);
	pack.WriteCell(nadeOrigin[0]);
	pack.WriteCell(nadeOrigin[1]);
	pack.WriteCell(nadeOrigin[2]);
	pack.WriteCell(volumeIndex);
}
public Action Timer_Duration(Handle timer, DataPack pack){
	
	pack.Reset();
	
	int ref = pack.ReadCell();
	
	float nadeOrigin[3];
	nadeOrigin[0] = pack.ReadCell();
	nadeOrigin[1] = pack.ReadCell();
	nadeOrigin[2] = pack.ReadCell();
	
	int volumeIndex = pack.ReadCell();
	int particle = EntRefToEntIndex(ref);
	
	if(!IsValidEntity(particle)){
		int blackholeIndex = BlackHoles.FindValue(ref);
		if(blackholeIndex != -1)
			BlackHoles.Erase(blackholeIndex);
		
		return Plugin_Handled;
	}
	
	char particleName[16];
	GetEntPropString(particle, Prop_Data, "m_iName", particleName, sizeof(particleName));
	
	if(StrEqual(particleName, "blackhole", false)){
		int index = BlackHoles.FindValue(ref);
		if(index != -1)
			BlackHoles.Erase(index);
	}
	
	AcceptEntityInput(particle, "Stop");
	
	DataPack packFade;
	CreateDataTimer(0.2, Timer_Fade, packFade, TIMER_REPEAT);
	packFade.WriteCell(ref);
	packFade.WriteCell(nadeOrigin[0]);
	packFade.WriteCell(nadeOrigin[1]);
	packFade.WriteCell(nadeOrigin[2]);
	packFade.WriteCell(volumeIndex);
	
	return Plugin_Handled;
}
float g_BlackholeVolume[MAXPLAYERS * 2] =  { BLACKHOLE_VOLUME, ... };
public Action Timer_Fade(Handle timer, DataPack pack){
	
	pack.Reset();
	float nadeOrigin[3];
	int ref = pack.ReadCell();
	nadeOrigin[0] = pack.ReadCell();
	nadeOrigin[1] = pack.ReadCell();
	nadeOrigin[2] = pack.ReadCell();
	int volumeIndex = pack.ReadCell();
	int particle = EntRefToEntIndex(ref);
	
	if(!IsValidEntity(particle)){
		return Plugin_Stop;
	}
	
	char particleName[16];
	GetEntPropString(particle, Prop_Data, "m_iName", particleName, sizeof(particleName));
	
	if(StrEqual(particleName, BLACKHOLE_EFFECT_NAME, false)){
		
		if(g_BlackholeVolume[volumeIndex] <= 0.0){
			
			//AcceptEntityInput(particle, "Kill");
			RemoveEntity(particle);
			StopSound(particle, SNDCHAN_ITEM, "*/piu/blackhole.mp3");
			g_BlackholeVolume[volumeIndex] = BLACKHOLE_VOLUME;
			
			return Plugin_Stop;
		}
		else{
			g_BlackholeVolume[volumeIndex] -= 0.25;
			EmitSoundToAll("*/piu/blackhole.mp3", SOUND_FROM_PLAYER, SNDCHAN_ITEM,_,SND_CHANGEVOL, g_BlackholeVolume[volumeIndex]);
		}
	}
	
	return Plugin_Continue;
}

public bool TraceFilterNotSelf(int entityhit, int mask, any entity){
	
	if(entity == 0 && entityhit != entity)
		return true;
	
	return false;
}

public Action Event_EntitySmoke(Event hEvent, char[] sName, bool dontBroadcast){
	
	// Gets real player index from event key
	ZPlayer owner = ZPlayer(GetClientOfUserId(hEvent.GetInt("userid")));
	
	// Get owner's pack
	ZGrenadePack pack = ZGrenadePack(owner.iGrenadePack);
	
	bool bAura = pack.hasGrenade(AURA_GRENADE);
	
	 // Initialize vectors
	static float vPosition[3]; //static float vAngle[3]; static float vEnemy[3];
	
	// Gets all required event info
	int grenade = hEvent.GetInt("entityid");
	vPosition[0] = hEvent.GetFloat("x"); 
	vPosition[1] = hEvent.GetFloat("y"); 
	vPosition[2] = hEvent.GetFloat("z");
	
	vPosition[2] += 20.0;
	
	if (!ActualMode.is(MODE_ASSASSIN))
		LightCreate(SMOKE, vPosition);
		
	//AcceptEntityInput(entity, "kill");
	RemoveEntity(grenade);
	
	// Spawn aura shield when the grenade pack contains one
	if (bAura){
		int client = owner.id;
		CreateAuraShield(client, vPosition);
	}
	
	//int iReference = EntIndexToEntRef(entity);
	
	// Block grenade
	//SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
}
