#pragma semicolon 1
#pragma newdecls required

#define DEBUG

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>


#if defined weapons_utils_included
	#endinput
#endif
#define weapons_utils_included

#define WEAPONS_UTILS_MODULE_VERSION "0.1"

/*----------------------------------------
-----------------------------------------*/


// EXPERIMENTAL FUNCS, WILL USE THEM LATER ON

enum SlotType{
	SlotType_Invalid = -1,		/** Used as return value when a slot doens't exist. */
	
	SlotType_Primary,			/** Primary slot */
	SlotType_Secondary,			/** Secondary slot */
	SlotType_Melee,				/** Melee slot */
	SlotType_Equipment,			/** Equipment slot */  
	SlotType_C4,				/** C4 slot */  
};

stock int Weapon_GetViewModelIndex(int client, int sIndex){  
	while ((sIndex = FindEntityByClassname2(sIndex, "predicted_viewmodel")) != -1){  
		int Owner = GetEntPropEnt(sIndex, Prop_Send, "m_hOwner");
          
		if (Owner != client)
			continue;
	          
		return EntIndexToEntRef(sIndex);
	} 
	return -1;  
}
stock int FindEntityByClassname2(int sStartEnt, char[] szClassname){
	while (sStartEnt > -1 && !IsValidEntity(sStartEnt)) sStartEnt--;
	return FindEntityByClassname(sStartEnt, szClassname);
}

//=====================================================
//					WEAPONS UTILS
//=====================================================

/**
 * Variables to store SDK calls handlers.
 **/
Handle hSDKCallRemoveAllItems;
Handle hSDKCallWeaponSwitch;

#pragma unused hSDKCallGetMaxClip1
Handle hSDKCallGetMaxClip1;

#pragma unused hSDKCallGetReserveAmmoMax
Handle hSDKCallGetReserveAmmoMax;

//
/**
 * @section Variables to store offset values.
 **/
//int g_iOffset_PlayerVelocity;
//int g_iOffset_PlayerOrigin;
//int g_iOffset_PlayerAngles;
//int g_iOffset_PlayerLMV;
//int g_iOffset_PlayerRender;
//int g_iOffset_PlayerNightVisionOn;
//int g_iOffset_PlayerHasNightVision;
//int g_iOffset_PlayerHasDefuser;
//int g_iOffset_PlayerFov;
//int g_iOffset_PlayerDefaultFOV;
//int g_iOffset_PlayerAccount;
//int g_iOffset_PlayerSpotted;
//int g_iOffset_PlayerSpottedByMask;
//int g_iOffset_PlayerCanBeSpotted;
//int g_iOffset_PlayerDetected;
//int g_iOffset_PlayerHUD;
//int g_iOffset_PlayerHitGroup;
//int g_iOffset_PlayerArmor;
//int g_iOffset_PlayerHasHeavyArmor;
//int g_iOffset_PlayerHasHelmet;
//int g_iOffset_PlayerHealth;
//int g_iOffset_PlayerMaxHealth;
//int g_iOffset_PlayerGravity;
//int g_iOffset_PlayerFrags;
//int g_iOffset_PlayerDeath;
//int g_iOffset_PlayerCollision;
//int g_iOffset_PlayerRagdoll;
int g_iOffset_PlayerViewModel;
//int g_iOffset_PlayerActiveWeapon;
//int g_iOffset_PlayerLastWeapon;
//int g_iOffset_PlayerObserverMode;
//int g_iOffset_PlayerObserverTarget;
//int g_iOffset_PlayerAttack;
//int g_iOffset_PlayerArms;
//int g_iOffset_PlayerAddonBits;
//int g_iOffset_EntityModelIndex;
//int g_iOffset_EntityOwnerEntity;
//int g_iOffset_EntityTeam;
//int g_iOffset_EntityEffects;
//int g_iOffset_EntityOrigin;
int g_iOffset_WeaponID;
int g_iOffset_WeaponOwner;
int g_iOffset_WeaponWorldModel;
//int g_iOffset_WeaponWorldSkin;
int g_iOffset_WeaponBody;
int g_iOffset_WeaponSkin;
int g_iOffset_WeaponAmmoType;
int g_iOffset_WeaponClip1;
int g_iOffset_WeaponReserve1;
int g_iOffset_WeaponReserve2;
int g_iOffset_WeaponPrimaryAttack;
int g_iOffset_WeaponSecondaryAttack;
int g_iOffset_WeaponIdle;
int g_iOffset_CharacterWeapons;
int g_iOffset_GrenadeThrower;
int g_iOffset_ViewModelOwner;
int g_iOffset_ViewModelWeapon;
int g_iOffset_ViewModelSequence;
int g_iOffset_ViewModelPlaybackRate;
int g_iOffset_ViewModelIndex;
int g_iOffset_ViewModelIgnoreOffsAcc;
int g_iOffset_EconItemDefinitionIndex;
int g_iOffset_NewSequenceParity;
int g_iOffset_LastShotTime;

Handle gameConfig;
Handle sdkConfig;
/**
 * @endsection
 **/

void WeaponSDKOnInit(/*void*/) /// @link https://www.unknowncheats.me/forum/counterstrike-global-offensive/152722-dumping-datamap_t.html
{							// C_BaseFlex -> C_EconEntity -> C_BaseCombatWeapon -> C_WeaponCSBase -> C_BaseCSGrenade
	
	gameConfig = LoadGameConfigFile("plugin.zombieplague");
	sdkConfig = LoadGameConfigFile("sdkhooks.games");
	
	// Starts the preparation of an SDK call
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gameConfig, SDKConf_Virtual, "CBasePlayer::RemoveAllItems");
	
	// Adds a parameter to the calling convention. This should be called in normal ascending order
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	
	// Validate call
	if((hSDKCallRemoveAllItems = EndPrepSDKCall()) == null){
		// Log failure
		//LogEvent(false, LogType_Fatal, LOG_GAME_EVENTS, LogModule_Weapons, "GameData Validation", "Failed to load SDK call \"CBasePlayer::RemoveAllItems\". Update virtual offset in \"%s\"", PLUGIN_CONFIG);
		return;
	}
	
	/*_________________________________________________________________________________________________________________________________________*/
	
	// Starts the preparation of an SDK call
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(sdkConfig, SDKConf_Virtual, /*CBasePlayer::*/"Weapon_Switch");
	
	// Adds a parameter to the calling convention. This should be called in normal ascending order
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	
	// Validate call
	if((hSDKCallWeaponSwitch = EndPrepSDKCall()) == null){
		// Log failure
		//LogEvent(false, LogType_Fatal, LOG_GAME_EVENTS, LogModule_Weapons, "GameData Validation", "Failed to load SDK call \"CBasePlayer::Weapon_Switch\". Update \"SourceMod\"");
		return;
	}
	
	/*_________________________________________________________________________________________________________________________________________*/
	
	// Starts the preparation of an SDK call
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gameConfig, SDKConf_Virtual, "CBaseCombatWeapon::GetMaxClip1");
	
	// Adds a parameter to the calling convention. This should be called in normal ascending order
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_ByValue); 
	
	// Validate call
	if((hSDKCallGetMaxClip1 = EndPrepSDKCall()) == null){
		
		// Log failure
		//LogEvent(false, LogType_Fatal, LOG_GAME_EVENTS, LogModule_Weapons, "GameData Validation", "Failed to load SDK call \"CBaseCombatWeapon::GetMaxClip1\". Update virtual offset in \"%s\"", PLUGIN_CONFIG);
		return;
	}
	
	/*_________________________________________________________________________________________________________________________________________*/
	
	// Starts the preparation of an SDK call
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gameConfig, SDKConf_Virtual, "CBaseCombatWeapon::GetReserveAmmoMax");
	
	// Adds a parameter to the calling convention. This should be called in normal ascending order
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_ByValue); 
	
	// Validate call
	if((hSDKCallGetReserveAmmoMax = EndPrepSDKCall()) == null){
		
		// Log failure
		//LogEvent(false, LogType_Fatal, LOG_GAME_EVENTS, LogModule_Weapons, "GameData Validation", "Failed to load SDK call \"CBaseCombatWeapon::GetReserveAmmoMax\". Update virtual offset in \"%s\"", PLUGIN_CONFIG);
		return;
	}
	
	/*_________________________________________________________________________________________________________________________________________*/
	
	// Load weapon offsets
	fnInitSendPropOffset(g_iOffset_WeaponOwner, "CBaseCombatWeapon", "m_hOwner");
	fnInitSendPropOffset(g_iOffset_WeaponWorldModel, "CBaseCombatWeapon", "m_hWeaponWorldModel");
	fnInitSendPropOffset(g_iOffset_WeaponBody, "CBaseCombatWeapon", "m_nBody");
	fnInitSendPropOffset(g_iOffset_WeaponSkin, "CBaseCombatWeapon", "m_nSkin");
	fnInitSendPropOffset(g_iOffset_WeaponAmmoType, "CBaseCombatWeapon", "m_iPrimaryAmmoType");
	fnInitSendPropOffset(g_iOffset_WeaponClip1, "CBaseCombatWeapon", "m_iClip1");
	fnInitSendPropOffset(g_iOffset_WeaponReserve1, "CBaseCombatWeapon", "m_iPrimaryReserveAmmoCount");
	fnInitSendPropOffset(g_iOffset_WeaponReserve2, "CBaseCombatWeapon", "m_iSecondaryReserveAmmoCount");
	fnInitSendPropOffset(g_iOffset_WeaponPrimaryAttack, "CBaseCombatWeapon", "m_flNextPrimaryAttack");
	fnInitSendPropOffset(g_iOffset_WeaponSecondaryAttack, "CBaseCombatWeapon", "m_flNextSecondaryAttack");
	fnInitSendPropOffset(g_iOffset_WeaponIdle, "CBaseCombatWeapon", "m_flTimeWeaponIdle");
	fnInitSendPropOffset(g_iOffset_CharacterWeapons, "CBaseCombatCharacter", "m_hMyWeapons");
	fnInitSendPropOffset(g_iOffset_GrenadeThrower, "CBaseGrenade", "m_hThrower");
	fnInitSendPropOffset(g_iOffset_PlayerViewModel, "CBasePlayer", "m_hViewModel");
	fnInitSendPropOffset(g_iOffset_ViewModelOwner, "CBaseViewModel", "m_hOwner");
	fnInitSendPropOffset(g_iOffset_ViewModelWeapon, "CBaseViewModel", "m_hWeapon");
	fnInitSendPropOffset(g_iOffset_ViewModelSequence, "CBaseViewModel", "m_nSequence");
	fnInitSendPropOffset(g_iOffset_ViewModelPlaybackRate, "CBaseViewModel", "m_flPlaybackRate");
	fnInitSendPropOffset(g_iOffset_ViewModelIndex, "CBaseViewModel", "m_nViewModelIndex");
	fnInitSendPropOffset(g_iOffset_ViewModelIgnoreOffsAcc, "CBaseViewModel", "m_bShouldIgnoreOffsetAndAccuracy");
	fnInitSendPropOffset(g_iOffset_EconItemDefinitionIndex, "CEconEntity", "m_iItemDefinitionIndex");
	fnInitSendPropOffset(g_iOffset_NewSequenceParity, "CBaseAnimating", "m_nNewSequenceParity");
	fnInitSendPropOffset(g_iOffset_LastShotTime, "CWeaponCSBase", "m_fLastShotTime");
	
	/*_________________________________________________________________________________________________________________________________________*/
}
/*
stock int IsPlayerHasWeapon(int clientIndex, int weaponID){
	
	// i = weapon number
	static int iSize; if(!iSize) iSize = GetEntPropArraySize(clientIndex, Prop_Send, "m_hMyWeapons");
	for (int i = 0; i < iSize; i++){
		
		// Gets weapon index
		int weaponIndex = GetEntPropEnt(clientIndex, Prop_Send, "m_hMyWeapons", i);
		
		// If entity isn't valid, then skip
		if(weaponIndex != INVALID_ENT_REFERENCE){
		
			// If weapon find, then return
			if(GetWeaponID(weaponIndex) == weaponID){
			    return weaponIndex;
			}
		}
		
		// Go to next weapon
		continue;
	}
		
	// If wasn't found
	return -1;
}*/

stock int readWeaponNetworkedIndex(int weaponIndex){
	
	char sWpn[64]; 
	GetEntityClassname(weaponIndex, sWpn, sizeof(sWpn));
	
	// If not weapon, return
	if (StrContains(sWpn, "weapon_") == -1)
		return -1;
	
	int weaponNetworkedIndex = -1;
	
	char sWeapon[32];
	GetEntPropString(weaponIndex, Prop_Data, "m_iName", sWeapon, sizeof(sWeapon));
	
	if (StrContains(sWeapon, "primary_") != -1){
		weaponNetworkedIndex = StringToInt(sWeapon[8]);
	}
	else if (StrContains(sWeapon, "secondary_") != -1){
		weaponNetworkedIndex = StringToInt(sWeapon[10]);
	}
	
	return weaponNetworkedIndex;
}

/**
 * @brief Returns true if the player hold a current weapon, false if not.
 * 
 * @param clientIndex       The client index. 
 * @param weaponIndex       The weapon index.
 * @param weaponID          The weapon id.
 * 
 * @return                  True or false.
 **/
stock bool IsPlayerHoldWeapon(int clientIndex, int &weaponIndex, int weaponID){
	
	// Validate client
	if(!IsPlayerExist(clientIndex)){
		return false;
	}
	
	// Gets weapon index
	weaponIndex = GetEntPropEnt(clientIndex, Prop_Data, "m_hActiveWeapon");
	
	// If entity isn't valid, then stop
	if(weaponIndex == INVALID_ENT_REFERENCE){
		return false;
	}
	
	// If weapon didn't find, then stop
	if(readWeaponNetworkedIndex(weaponIndex) != weaponID){
		return false;
	}
	
	// Return on success
	return true;
}

/**
 * @brief Gets the weapon shoot position.
 *
 * @param clientIndex       The client index.
 * @param flForward         (Optional) The forward distance.
 * @param flRight           (Optional) The right distance. 
 * @param flVertical        (Optional) The vertical distance.
 * @param vPosition         The calculated position vector output.
 **/
stock void GetPlayerGunPosition(int clientIndex, float flForward = 0.0, float flRight = 0.0, float flVertical = 0.0, float vPosition[3]){
	
	// Initialize vectors
	static float vEntPosition[3]; static float vEntAngle[3]; static float vForward[3]; static float vRight[3];  static float vVertical[3]; 
	
	// Gets client eye angle
	GetClientEyePosition(clientIndex, vEntPosition);
	
	// Gets client eye angle
	GetClientEyeAngles(clientIndex, vEntAngle);
	
	// Returns vectors in the direction of an angle
	GetAngleVectors(vEntAngle, vForward, vRight, vVertical);
	
	// Calculate ends point by applying all vectors distances 
	vPosition[0] = vEntPosition[0] + (vForward[0] * flForward) + (vRight[0] * flRight) + (vVertical[0] * flVertical);
	vPosition[1] = vEntPosition[1] + (vForward[1] * flForward) + (vRight[1] * flRight) + (vVertical[1] * flVertical);
	vPosition[2] = vEntPosition[2] + (vForward[2] * flForward) + (vRight[2] * flRight) + (vVertical[2] * flVertical);
}

/**
 * @brief Gets the weapon animating index.
 *
 * @param clientIndex       The client index.
 *
 * @return                  The sequence index.
 **/
stock int GetWeaponAnimation(int clientIndex){
	
	// Gets client viewmodel
	int viewModel = Weapon_GetViewModelIndex(clientIndex, -1); /// Gets anims on the custom model 
	
	// Validate viewmodel
	if(viewModel != INVALID_ENT_REFERENCE){
		// Gets animation
		return GetEntProp(viewModel, Prop_Send, "m_nSequence");
	}
	
	// Return on unsuccess
	return -1;
}

/**
 * @brief Sets the weapon animating index.
 *
 * @param clientIndex       The client index.
 * @param nSequence         The sequence index.
 **/
stock void SetWeaponAnimation(int clientIndex, int nSequence){
	
	// Gets client viewmodel
	int viewModel = Weapon_GetViewModelIndex(clientIndex, -1); /// Play anims on the original model 
	
	// Validate viewmodel
	if(viewModel != INVALID_ENT_REFERENCE){
		// Sets animation
		SetEntProp(viewModel, Prop_Send, "m_nSequence", nSequence);
	}
}

/**
 * @brief Sets the weapon animating paired index. (Important for animations, which should played in the not-repeatable row, like an attack)
 *
 * @param clientIndex       The client index.
 * @param weaponIndex       The weapon index.
 * @param nSequence         The sequence array.
 **/
stock void SetWeaponAnimationPair(int clientIndex, int weaponIndex, int nSequence[2]){
	
	// Gets client viewmodel
	int viewModel = Weapon_GetViewModelIndex(clientIndex, -1); /// Play anims on the original model 
	
	// Validate viewmodel
	if(viewModel != INVALID_ENT_REFERENCE){
		
		// Gets the current played state of animation
		bool bPrevAnim = view_as<bool>(GetEntProp(weaponIndex, Prop_Send, "m_bSilencerOn"));
		
		// Sets animation
		SetEntProp(viewModel, Prop_Send, "m_nSequence", nSequence[bPrevAnim ? 0 : 1]);
		
		// Sets inversed played state
		SetEntProp(weaponIndex, Prop_Send, "m_bSilencerOn", !bPrevAnim);
	}
}

/**
 * @brief Returns index if the player has a weapon.
 *
 * @param clientIndex       The client index.
 * @param sType             The weapon entity.
 *
 * @return                  The weapon index.
 **/
stock int GetWeaponIndex(int clientIndex, char[] sType){
	
	// Initialize classname char
	static char sClassname[SMALL_LINE_LENGTH];
	
	// i = weapon number
	static int iSize; if(!iSize) iSize = GetEntPropArraySize(clientIndex, Prop_Send, "m_hMyWeapons");
	for(int i = 0; i < iSize; i++){
		
		// Gets weapon index
		int weaponIndex = GetEntPropEnt(clientIndex, Prop_Send, "m_hMyWeapons", i);
		
		// Validate weapon
		if(weaponIndex != INVALID_ENT_REFERENCE){
			
			// Gets weapon classname
			GetEdictClassname(weaponIndex, sClassname, sizeof(sClassname));
			
			// If weapon find, then return
			if(!strcmp(sClassname[7], sType[7], false)){
			    return weaponIndex;
			}
		}
	}
	
	// Weapon wasn't found
	return -1;
}

/**
 * @brief Remove a weapon from the player.
 *
 * @param clientIndex       The client index.
 * @param weaponIndex       The weapon index.
 * @param slotType          (Optional) The slot index to replace.
 **/
stock void RemoveWeapon(int clientIndex, int weaponIndex, SlotType slotType = SlotType_Melee){
	
	// Forces a player to remove weapon
	RemovePlayerItem(clientIndex, weaponIndex);
	AcceptEntityInput(weaponIndex, "Kill");
	
	//Gets weapon index
	int weaponIndex2 = GetPlayerWeaponSlot(clientIndex, view_as<int>(slotType));
	
	// Validate weapon
	if(weaponIndex2 != INVALID_ENT_REFERENCE){
		
		// Gets weapon classname
		static char sClassname[SMALL_LINE_LENGTH];
		GetEdictClassname(weaponIndex2, sClassname, sizeof(sClassname));
		
		// Switch the weapon
		FakeClientCommand(clientIndex, "use %s", sClassname);
	}
}

/**
 * @brief Create the tracer to a weapon.
 *
 * @param clientIndex       The client index.
 * @param weaponIndex       The weapon index.
 * @param sAttach1          The attachment name. (view)
 * @param sAttach2          The attachment name. (world)
 * @param sEffect           The effect name.
 * @param vBulletPosition   The position of a bullet hit.
 * @param flDurationTime    The duration of life.
 **/

/*
stock void CreateWeaponTracer(int clientIndex, int weaponIndex, char[] sAttach1, char[] sAttach2, char[] sEffect, float vBulletPosition[3], float flDurationTime)
{
	// Validate name
	if(!hasLength(sEffect)){
		return;
	}
	
	#define ClientSrt  0
	#define ClientEnd  1
	#define ViewerSrt  2
	#define ViewerEnd  3
	// Regards to Phoenix
	// Dont ask me how it works ;)
	
	// Gets client view/world model
	int viewModel = Weapon_GetViewModelIndex(clientIndex, -1);
	int worldModel = GetEntPropEnt(weaponIndex, Prop_Send, "m_hWeaponWorldModel");
	
	// Validate models
	if(viewModel == INVALID_ENT_REFERENCE || worldModel == INVALID_ENT_REFERENCE){    
		return;
	}
	
	// Validate attachments
	if((sAttach1[0] != '\0' && !LookupAttachment(viewModel, sAttach1)) || (sAttach2[0] != '\0' && !LookupAttachment(worldModel, sAttach2))){
		return;
	}
	
	// Create an attach particle entity
	static int entityIndex[4];
	entityIndex[ClientSrt] = CreateEntityByName("info_particle_system");
	entityIndex[ClientEnd] = CreateEntityByName("info_particle_system");
	entityIndex[ViewerSrt] = CreateEntityByName("info_particle_system");
	entityIndex[ViewerEnd] = CreateEntityByName("info_particle_system");
	
	// If entity isn't valid, then skip
	if(entityIndex[ViewerEnd] != INVALID_ENT_REFERENCE){ /// Check the last entity ;)
		
		// Gets the client angle
		static float vAngle[3]; static float vEmpty[3];
		GetEntPropVector(clientIndex, Prop_Data, "m_angAbsRotation", vAngle);
		
		// Teleport the entity
		TeleportEntity(entityIndex[ClientEnd], vBulletPosition, vAngle, NULL_VECTOR);
		TeleportEntity(entityIndex[ViewerEnd], vBulletPosition, vAngle, NULL_VECTOR);
		
		// Dispatch main values of the entity
		static char sClassname[SMALL_LINE_LENGTH];
		FormatEx(sClassname, sizeof(sClassname), "particle%d", entityIndex[ClientSrt]);
		DispatchKeyValue(entityIndex[ClientSrt], "targetname", sClassname);
		DispatchKeyValue(entityIndex[ClientEnd], "effect_name", sEffect);
		DispatchKeyValue(entityIndex[ClientEnd], "cpoint1", sClassname);
		
		// Spawn the entity into the world
		DispatchSpawn(entityIndex[ClientEnd]);
		
		// Sets owner to the entity 
		SetEntPropEnt(entityIndex[ClientEnd], Prop_Send, "m_hOwnerEntity", clientIndex);
		
		// Dispatch main values of the entity
		FormatEx(sClassname, sizeof(sClassname), "particle%d",  entityIndex[ViewerSrt]);
		DispatchKeyValue(entityIndex[ViewerSrt], "targetname", sClassname);
		DispatchKeyValue(entityIndex[ViewerEnd], "effect_name", sEffect);
		DispatchKeyValue(entityIndex[ViewerEnd], "cpoint1", sClassname);
		
		// Spawn the entity into the world
		DispatchSpawn(entityIndex[ViewerEnd]);
		
		// Sets owner to the entity 
		SetEntPropEnt(entityIndex[ViewerEnd], Prop_Send, "m_hOwnerEntity", clientIndex);
		
		// Teleport the entity
		TeleportEntity(entityIndex[ViewerSrt], NULL_VECTOR, vAngle, NULL_VECTOR);
		
		// Sets parent to the entity
		SetVariantString("!activator");
		AcceptEntityInput(entityIndex[ViewerSrt], "SetParent", worldModel,  entityIndex[ViewerSrt]);
		
		// Sets attachment to the entity
		SetVariantString(sAttach2);
		AcceptEntityInput(entityIndex[ViewerSrt], "SetParentAttachment",  entityIndex[ViewerSrt], entityIndex[ViewerSrt]);
		
		// Teleport the entity
		TeleportEntity(entityIndex[ViewerSrt], vEmpty, NULL_VECTOR, NULL_VECTOR);
		
		// Sets parent to the entity
		SetVariantString("!activator");
		AcceptEntityInput(entityIndex[ClientSrt], "SetParent", viewModel, entityIndex[ClientSrt]);
		
		// Sets attachment to the entity
		SetVariantString(sAttach1);
		AcceptEntityInput(entityIndex[ClientSrt], "SetParentAttachment", entityIndex[ClientSrt], entityIndex[ClientSrt]);
		
		//______________________________________________________________________________
		
		// Hook entity callbacks 
		SDKHook(entityIndex[ClientEnd], SDKHook_SetTransmit, TracerClientTransmit);
		SDKHook(entityIndex[ViewerEnd], SDKHook_SetTransmit, TracerViewerTransmit);
		
		// Activate the entity
		ActivateEntity(entityIndex[ClientEnd]);
		AcceptEntityInput(entityIndex[ClientEnd], "Start");
		ActivateEntity(entityIndex[ViewerEnd]);
		AcceptEntityInput(entityIndex[ViewerEnd], "Start");
		
		// Initialize time char
		UTIL_RemoveEntity(entityIndex[ClientEnd], flDurationTime);
		UTIL_RemoveEntity(entityIndex[ViewerEnd], flDurationTime);
		UTIL_RemoveEntity(entityIndex[ClientSrt], flDurationTime);
		UTIL_RemoveEntity(entityIndex[ViewerSrt], flDurationTime);
	}
}
*/
/**
 * @brief Create the kickback effect to a weapon .
 *
 * @param clientIndex       The client index.
 * @param upBase            The upward base amount.
 * @param lateralBase       The lateral base amount.
 * @param upMod             The upward mod amount.
 * @param lateralMod        The lateral mod amount.
 * @param upMax             The upward max amount.
 * @param directionChange   The direction seed.
 **/
stock void CreateWeaponKickBack(int clientIndex, float upBase, float lateralBase, float upMod, float lateralMod, float upMax, float lateralMax, int directionChange){
	
	// Initialize variables
	static int iDirection; static int iShotsFired; static float vPunchAngle[3];
	GetEntPropVector(clientIndex, Prop_Send, "m_aimPunchAngle", vPunchAngle);
	
	// Gets a shots fired
	if((iShotsFired = GetEntProp(clientIndex, Prop_Send, "m_iShotsFired")) != 1){
		// Calculate a base power
		upBase += iShotsFired * upMod;
		lateralBase += iShotsFired * lateralMod;
	}
	
	// Reduce a max power
	upMax *= -1.0;
	vPunchAngle[0] -= upBase;
	
	// Validate max angle
	if(upMax >= vPunchAngle[0]){
		vPunchAngle[0] = upMax;
	}
	
	// Gets a direction change
	if((iDirection = GetEntProp(clientIndex, Prop_Send, "m_iDirection"))){
		// Increase the angle
		vPunchAngle[1] += lateralBase;
		
		// Validate min angle
		if(lateralMax < vPunchAngle[1]){
			vPunchAngle[1] = lateralMax;
		}
	}
	else{
		// Decrease the angle
		lateralMax *=  -1.0;
		vPunchAngle[1] -= lateralBase;
		
		// Validate max angle
		if(lateralMax > vPunchAngle[1]){
			vPunchAngle[1] = lateralMax;
		}
	}
		
	// Create a direction change
	if(!GetRandomInt(0, directionChange)){
		SetEntProp(clientIndex, Prop_Send, "m_iDirection", !iDirection);
	}
	
	// Sets a punch angle
	SetEntPropVector(clientIndex, Prop_Send, "m_aimPunchAngle", vPunchAngle);
	SetEntPropVector(clientIndex, Prop_Send, "m_viewPunchAngle", vPunchAngle);
}

//**********************************************
//* Tracer hooks.                              * 
//**********************************************

/**
 * Hook: SetTransmit
 * @brief Called right before the entity transmitting to other entities.
 *
 * @param entityIndex       The entity index.
 * @param clientIndex       The client index.
 **/
public Action TracerClientTransmit(int entityIndex, int clientIndex){
	
	// Allow particle to be transmittable
	if(GetEdictFlags(entityIndex) & FL_EDICT_ALWAYS){
		SetEdictFlags(entityIndex, (GetEdictFlags(entityIndex) ^ FL_EDICT_ALWAYS));
	}
	
	// Gets the owner of the entity
	int ownerIndex = GetEntPropEnt(entityIndex, Prop_Send, "m_hOwnerEntity");
	
	// Validate observer mode
	if(ownerIndex == clientIndex || (GetEntProp(clientIndex, Prop_Send, "m_iObserverMode") == SPECMODE_FIRSTPERSON && ownerIndex == GetEntPropEnt(clientIndex, Prop_Send, "m_hObserverTarget"))){
		// Allow transmitting
		return Plugin_Continue;
	}
	
	// Block transmitting
	return Plugin_Handled;
}

/**
 * Hook: SetTransmit
 * @brief Called right before the entity transmitting to other entities.
 *
 * @param entityIndex       The entity index.
 * @param clientIndex       The client index.
 **/
public Action TracerViewerTransmit(int entityIndex, int clientIndex){
	
	// Allow particle to be transmittable
	if(GetEdictFlags(entityIndex) & FL_EDICT_ALWAYS){
		SetEdictFlags(entityIndex, (GetEdictFlags(entityIndex) ^ FL_EDICT_ALWAYS));
	}
	
	// Gets the owner of the entity
	int ownerIndex = GetEntPropEnt(entityIndex, Prop_Send, "m_hOwnerEntity");
	
	// Validate observer mode
	if(ownerIndex == clientIndex || (GetEntProp(clientIndex, Prop_Send, "m_iObserverMode") == SPECMODE_FIRSTPERSON && ownerIndex == GetEntPropEnt(clientIndex, Prop_Send, "m_hObserverTarget"))){
		// Block transmitting
		return Plugin_Handled;
	}
	
	// Allow transmitting
	return Plugin_Continue;
}

///////////////////////////
stock int WeaponsGetCustomID(int weaponIndex){
	
	// Find the datamap
	if(!g_iOffset_WeaponID){
		g_iOffset_WeaponID = FindDataMapInfo(weaponIndex, "m_iHammerID");
	}
	
	// Gets value on the weapon
	return GetEntData(weaponIndex, g_iOffset_WeaponID);
}

/**
 * @brief Sets the custom weapon ID.
 *
 * @param weaponIndex       The weapon index.
 * @param iD                The weapon id.
 **/
stock void WeaponsSetCustomID(int weaponIndex, int iD){
	
	// Find the datamap
	if(!g_iOffset_WeaponID){
		g_iOffset_WeaponID = FindDataMapInfo(weaponIndex, "m_iHammerID");
	}
	
	// Sets value on the weapon
	SetEntData(weaponIndex, g_iOffset_WeaponID, iD, _, true);
}

/**
 * @brief Sets the custom weapon ID.
 *
 * @param weaponIndex       The weapon index.
 * @param ownerIndex        The owner index.  
 **/
stock void WeaponsSetOwner(int weaponIndex, int ownerIndex){
	
	// Sets value on the weapon
	SetEntDataEnt2(weaponIndex, g_iOffset_WeaponOwner, ownerIndex, true);
}

/**
 * @brief Sets the animation delay.
 *
 * @param weaponIndex       The weapon index.
 * @param flDelay           The delay duration.  
 **/
stock void WeaponsSetAnimating(int weaponIndex, float flDelay){
	
	// Sets value on the weapon
	SetEntDataFloat(weaponIndex, g_iOffset_WeaponPrimaryAttack, flDelay, true);
	SetEntDataFloat(weaponIndex, g_iOffset_WeaponSecondaryAttack, flDelay, true);
	SetEntDataFloat(weaponIndex, g_iOffset_WeaponIdle, flDelay, true);
}
 
/**
 * @brief Drop/remove a weapon.
 *
 * @param clientIndex       The client index.
 * @param weaponIndex       The weapon index.
 * @param bRemove           True to delete weapon or false to just drop weapon.
 **/

/*
stock void WeaponsDrop(int clientIndex, int weaponIndex, bool bRemove = false){
	
	// Validate weapon
	if(IsValidEdict(weaponIndex)){
		
		// Gets the owner of the weapon
		int ownerIndex = ToolsGetEntityOwner(weaponIndex);
		
		// If owner index is different, so set it again
		if(ownerIndex != clientIndex){
			ToolsSetEntityOwner(weaponIndex, clientIndex);
		}
		
		// Validate delete
		if(bRemove){
			// Forces a player to remove weapon
			RemovePlayerItem(clientIndex, weaponIndex);
			AcceptEntityInput(weaponIndex, "Kill"); /// Destroy
		}
		else{
			// Forces a player to drop weapon
			CS_DropWeapon(clientIndex, weaponIndex, false, false);
		}
	}
}*/

/**
 * @brief Pick up a weapon.
 *
 * @param clientIndex       The client index.
 * @param weaponIndex       The weapon index.
 * @param iD                The weapon id.
 * @param mSlot             The slot index.
 **/

/*
stock void WeaponsPickUp(int clientIndex, int weaponIndex, int iD, SlotType mSlot){
	
	// Gets weapon index
	int weaponIndex2 = GetPlayerWeaponSlot(clientIndex, view_as<int>(mSlot));
	
	// Validate weapon
	if(weaponIndex2 == INVALID_ENT_REFERENCE){
		
		// Give the new weapon
		AcceptEntityInput(weaponIndex, "Kill"); /// Destroy
		WeaponsGive(clientIndex, iD);
	}
}*/

/**
 * @brief Remove all weapons and give default weapon.
 *
 * @param clientIndex       The client index.
 * @return                  True on success, false if client has access. 
 **/

/*
stock bool WeaponsRemoveAll(int clientIndex){
	
	// i = weapon number
	static int iSize; if(!iSize) iSize = GetEntPropArraySize(clientIndex, Prop_Send, "m_hMyWeapons");
	for(int i = 0; i < iSize; i++){
		
		// Gets weapon index
		int weaponIndex = GetEntDataEnt2(clientIndex, g_iOffset_CharacterWeapons + (i * 4));
		
		// Validate weapon
		if(weaponIndex != INVALID_ENT_REFERENCE){
			
			// Validate custom index
			int iD = WeaponsGetCustomID(weaponIndex);
			
			if(iD != -1){
				// Validate access
				if(WeaponsValidateClass(clientIndex, iD)){
					// Stop here!
					return false;
				}
			}
		}
	}
	
	// Remove all weapons
	SDKCall(hSDKCallRemoveAllItems, clientIndex, true);
	
	// Return on success
	return true;
}*/

/**
 * @brief Give weapon from a id.
 *
 * @param clientIndex       The client index.
 * @param iD                The weapon id.
 * @return                  The weapon index.
 **/

/*
stock int WeaponsGive(int clientIndex, int iD){
	
	// Initialize index
	int weaponIndex = INVALID_ENT_REFERENCE;
	
	// Validate weapon index
	if(iD != -1){
		// Validate access
		if(!WeaponsValidateClass(clientIndex, iD)) {
			return weaponIndex;
		}
		
		// Initialize name char
		static char sWeaponName[SMALL_LINE_LENGTH];
		
		// Gets weapon classname
		WeaponsGetEntity(iD, sWeaponName, sizeof(sWeaponName));
		
		// Validate weapons
		if(sWeaponName[0] == 'w' && sWeaponName[1] == 'e' && sWeaponName[6] == '_')
		{
			// Gets weapon index
			weaponIndex = WeaponsGetIndex(clientIndex, sWeaponName);
			
			// Validate index
			if(weaponIndex != INVALID_ENT_REFERENCE){
				// Drop weapon
				WeaponsDrop(clientIndex, weaponIndex);
			}
			
			// Validate exceptions
			if(!strncmp(sWeaponName[7], "fis", 3, false) || !strncmp(sWeaponName[12], "_g", 2, false) || 
			!strncmp(sWeaponName[7], "spa", 3, false) || !strncmp(sWeaponName[7], "tab", 3, false) ||
			!strcmp(sWeaponName[7], "axe", false) || !strncmp(sWeaponName[7], "ha", 2, false) || 
			!strncmp(sWeaponName[7], "br", 2, false) || !strncmp(sWeaponName[7], "sn", 2, false) ||
			!strcmp(sWeaponName[7], "c4", false) || !strcmp(sWeaponName[12], "_t", false)){
				
				// Create a weapon entity
				weaponIndex = CreateEntityByName(sWeaponName);
				
				// Validate index
				if(weaponIndex != INVALID_ENT_REFERENCE) 
				{
					// Spawn the entity into the world
					if(DispatchSpawn(weaponIndex)){
						// Give weapon
						EquipPlayerWeapon(clientIndex, weaponIndex);
					}
				}
			}
			else{
				// Give weapon
				weaponIndex = GivePlayerItem(clientIndex, sWeaponName);
			}
					
			// Validate index
			if(weaponIndex != INVALID_ENT_REFERENCE){
				// Sets weapon id
				WeaponsSetCustomID(weaponIndex, iD);
				
				// Sets max ammo only for standart weapons
				SetEntData(weaponIndex, g_iOffset_WeaponReserve2, GetEntData(weaponIndex, g_iOffset_WeaponReserve1), _, true); /// GetReserveAmmoMax not work for standart weapons
					
				// Switch the weapon
				FakeClientCommand(clientIndex, "use %s", sWeaponName);
				ToolsSetClientActiveWeapon(clientIndex, weaponIndex);
				SDKCall(hSDKCallWeaponSwitch, clientIndex, weaponIndex, 0);
				
				// Call forward
				gForwardData._OnWeaponCreated(clientIndex, weaponIndex, iD);
			}
		}
		// Validate items
		else if(sWeaponName[0] == 'i' && sWeaponName[1] == 't'){
			// Gets existing items 
			switch(sWeaponName[5]){
				/// item_assaultsuit
				case 'a' : 
				{
					// Sets kevlar
					ToolsSetClientHelmet(clientIndex, true);
					ToolsSetClientArmor(clientIndex, WeaponsGetClip(iD));
					ToolsSetClientHeavySuit(clientIndex, false);
				}
				
				/// item_kevlar
				case 'k' :
				{
					// Sets armor
					ToolsSetClientHelmet(clientIndex, false);
					ToolsSetClientArmor(clientIndex, WeaponsGetClip(iD));
					ToolsSetClientHeavySuit(clientIndex, false);
				}
				
				/// item_heavyassaultsuit
				case 'h' :
				{
					// Sets heavy suit
					ToolsSetClientHelmet(clientIndex, true);
					ToolsSetClientArmor(clientIndex, WeaponsGetClip(iD));
					ToolsSetClientHeavySuit(clientIndex, true);
				}
				
				/// item_defuser
				case 'd' :
				{
					// Sets item id
					WeaponsSetCustomID(clientIndex, iD);
					
					// Sets defuser
					ToolsSetClientDefuser(clientIndex, true);
				}
				
				/// item_nvgs
				case 'n' :
				{
					// Sets nightvision
					ToolsSetClientNightVision(clientIndex, true, true);
					ToolsSetClientNightVision(clientIndex, true);
				}
			}
		}
	}
	
	// Return on success
	return weaponIndex;
}*/

/**
 * @brief Returns index if the player has a weapon.
 *
 * @param clientIndex       The client index.
 * @param sType             The weapon entity.
 *
 * @return                  The weapon index.
 **/
stock int WeaponsGetIndex(int clientIndex, char[] sType){
	
	// Initialize classname char
	static char sClassname[SMALL_LINE_LENGTH];
	
	// i = weapon number
	static int iSize; if(!iSize) iSize = GetEntPropArraySize(clientIndex, Prop_Send, "m_hMyWeapons");
	for(int i = 0; i < iSize; i++){
		
		// Gets weapon index
		int weaponIndex = GetEntDataEnt2(clientIndex, g_iOffset_CharacterWeapons + (i * 4));
		
		// Validate weapon
		if(weaponIndex != INVALID_ENT_REFERENCE){
			// Gets weapon classname
			GetEdictClassname(weaponIndex, sClassname, sizeof(sClassname));
			
			// If weapon find, then return
			if(!strcmp(sClassname[7], sType[7], false)){
				return weaponIndex;
			}
		}
	}
	
	// Weapon doesn't exist
	return -1;
}