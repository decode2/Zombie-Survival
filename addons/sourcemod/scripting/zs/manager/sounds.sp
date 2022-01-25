/**
 * @section Sound config data indexes.
 **/
enum
{
	SOUNDS_DATA_KEY,
};
/**
 * @endsection
 **/
 
/*
 * Load other sound effect modules
 */
//#include "zs/manager/soundeffects/ambientsounds.sp"
#include "zs/manager/soundeffects/soundeffects.sp"
//#include "zs/manager/soundeffects/playersounds.sp"

/**
 * @brief Sounds module init function.
 **/
void SoundsOnInit(/*void*/){
	
	// Hooks server sounds
	AddNormalSoundHook(view_as<NormalSHook>(PlayerSoundsNormalHook));
}

/**
 * @brief Hook sounds cvar changes.
 **/
void SoundsOnCvarInit(/*void*/){
	
	// Create cvars
	gCvarList.SEFFECTS_LEVEL = FindConVar("zs_seffects_level");
	
	// Forward event to sub-modules
	PlayerSoundsOnCvarInit();
}

/**
 * @brief The round is ending.
 *
 * @param reason            The reason index.
 **/
void SoundsOnRoundEnd(CSRoundEndReason reason){
	
	// Forward event to sub-modules
	SEffectsInputStopAll();
	
	// Create timer for emit sounds
	delete gServerData.EndTimer;
	gServerData.EndTimer = CreateTimer(0.2, PlayerSoundsOnRoundEndPost, reason, TIMER_FLAG_NO_MAPCHANGE); /// HACK~HACK
}

/**
 * @brief The counter is working.
 *
 * @return                  True or false.
 **/
bool SoundsOnCounter(/*void*/){
	
	// Forward event to sub-modules
	return PlayerSoundsOnCounter();
}

/**
 * @brief The blast is started.
 **/
void SoundsOnBlast(/*void*/){
	
	// Create timer for emit sounds
	delete gServerData.BlastTimer;
	gServerData.BlastTimer = CreateTimer(0.3, PlayerSoundsOnBlastPost, _, TIMER_FLAG_NO_MAPCHANGE); /// HACK~HACK
}

/**
 * @brief The gamemode is starting.
 **/
void SoundsOnGameModeStart(/*void*/){
	
	// Forward event to sub-modules
	AmbientSoundsOnGameModeStart();
}

/**
 * @brief Client has been hurt.
 * 
 * @param client            The client index.
 * @param iBits             The type of damage inflicted.
 **/
void SoundsOnClientHurt(int client, int iBits){
	
	// Forward event to sub-modules
	//PlayerSoundsOnClientHurt(client, ((iBits & DMG_BURN) || (iBits & DMG_DIRECT)));
}

/**
 * @brief Client has been infected.
 * 
 * @param client            The client index.
 * @param attacker          The attacker index.
 **/
void SoundsOnClientInfected(int client, int attacker){
	
	// Forward event to sub-modules
	//PlayerSoundsOnClientInfected(client, attacker);
}

/**
 * @brief Client has been changed class state.
 * 
 * @param client            The client index.
 **/
void SoundsOnClientUpdate(int client){
	
	// Forward event to sub-modules
	AmbientSoundsOnClientUpdate(client);
}

/**
 * @brief Client has been regenerating.
 * 
 * @param client            The client index.
 **/
void SoundsOnClientRegen(int client){
	
	// Forward event to sub-modules
	//PlayerSoundsOnClientRegen(client);
}

/**
 * @brief Client has been leap jumped.
 * 
 * @param client            The client index.
 **/
void SoundsOnClientJump(int client){
	
	// Forward event to sub-modules
	//PlayerSoundsOnClientJump(client);
}

/**
 * @brief Client has been swith nightvision.
 * 
 * @param client            The client index.
 **/
void SoundsOnClientNvgs(int client){
	
	// Forward event to sub-modules
	//PlayerSoundsOnClientNvgs(client);
}

/**
 * @brief Client has been swith flashlight.
 * 
 * @param client            The client index.
 **/
void SoundsOnClientFlashLight(int client){
	
	// Forward event to sub-modules
	//PlayerSoundsOnClientFlashLight(client);
}

/**
 * @brief Client has been level up.
 * 
 * @param client            The client index.
 **/
void SoundsOnClientLevelUp(int client){
	
	// Forward event to sub-modules
	//PlayerSoundsOnClientLevelUp(client);
}

/**
 * @brief Client has been shoot.
 * 
 * @param client            The client index.
 * @param iD                The weapon id.
 **/
Action SoundsOnClientShoot(int client, int iD){
	
	// Forward event to sub-modules
	//return PlayerSoundsOnClientShoot(client, iD) ? Plugin_Stop : Plugin_Continue;
}

/*
 * Sounds natives API.
 */

/**
 * @brief Sets up natives for library.
 **/
void SoundsOnNativeInit(/*void*/) {
	
	CreateNative("ZP_GetSound",          API_GetSound);
	CreateNative("ZP_EmitSoundToAll",    API_EmitSoundToAll);
	CreateNative("ZP_EmitSoundToClient", API_EmitSoundToClient);
	CreateNative("ZP_EmitAmbientSound",  API_EmitAmbientSound);
}

/**
 * @brief Gets sound from a key id from sounds config.
 *
 * @note native void ZP_GetSound(keyID, sound, maxlenght, position);
 **/
public int API_GetSound(Handle hPlugin, int iNumParams){
	
	// Gets string size from native cell
	int maxLen = GetNativeCell(3);

	// Validate s
	if (!maxLen)
	{
		LogEvent(false, LogType_Native, LOG_GAME_EVENTS, LogModule_Sounds, "Native Validation", "No buffer size");
		return -1;
	}
	
	// Initialize sound char
	static char sSound[PLATFORM_LINE_LENGTH]; sSound[0] = NULL_STRING[0];
	
	// Gets sound path
	SoundsGetPath(GetNativeCell(1), sSound, sizeof(sSound), GetNativeCell(4));
	
	// Validate sound
	if (hasLength(sSound))
	{
		// Format sound
		Format(sSound, sizeof(sSound), "*/%s", sSound);
	}
	
	// Return on success
	return SetNativeString(2, sSound, maxLen);
}

/**
 * @brief Emits a sound to all clients.
 *
 * @note native bool ZP_EmitSoundToAll(keyID, num, entity, channel, level, flags, volume, pitch);
 **/
public int API_EmitSoundToAll(Handle hPlugin, int iNumParams){
	
	// Play sound
	return SEffectsInputEmitToAll(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3), GetNativeCell(4), GetNativeCell(5), GetNativeCell(6), GetNativeCell(7), GetNativeCell(8));
}

/**
 * @brief Emits a sound to the client.
 *
 * @note native bool ZP_EmitSoundToClient(keyID, num, client, entity, channel, level, flags, volume, pitch);
 **/
public int API_EmitSoundToClient(Handle hPlugin, int iNumParams){
	
	// Play sound
	return SEffectsInputEmitToClient(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3), GetNativeCell(4), GetNativeCell(5), GetNativeCell(6), GetNativeCell(7), GetNativeCell(8), GetNativeCell(9));
}

/**
 * @brief Emits an ambient sound.
 *
 * @note native bool ZP_EmitAmbientSound(keyID, num, origin, entity, level, flags, volume, pitch, delay);
 **/
public int API_EmitAmbientSound(Handle hPlugin, int iNumParams){
	
	// Gets origin vector
	static float vPosition[3];
	GetNativeArray(3, vPosition, sizeof(vPosition));
	
	// Play sound
	return SEffectsInputEmitAmbient(GetNativeCell(1), GetNativeCell(2), vPosition, GetNativeCell(4), GetNativeCell(5), GetNativeCell(6), GetNativeCell(7), GetNativeCell(8), GetNativeCell(9));
}