/**
 * @section Information about the weapon.
 **/
#define CHAINSAW_SLASH_DAMAGE            2.0 // this will later be multiplied by zweapon dmg
#define CHAINSAW_STAB_DAMAGE             1.0 // this will later be multiplied by zweapon dmg
#define CHAINSAW_SLASH_DISTANCE          80.0
#define CHAINSAW_RADIUS_DAMAGE           10.0
#define CHAINSAW_STAB_DISTANCE           90.0
#define CHAINSAW_IDLE_TIME               5.0
#define CHAINSAW_IDLE2_TIME              1.66
#define CHAINSAW_ATTACK_TIME             1.5
#define CHAINSAW_ATTACK_START_TIME       0.5
#define CHAINSAW_ATTACK_END_TIME         1.5


#define CHAINSAW_ATTACK_SPEED 	0.075
#define CHAINSAW_RELOAD_SPEED 	3.0
#define CHAINSAW_DEPLOY_SPEED 	1.23
#define CHAINSAW_CLIP_AMMOUNT 	100

#define CHAINSAW_SOUND_LEVEL 	60

#define CHAINSAW_HIT1_SOUND 	"weapons/chainsaw_hit1.mp3"
#define CHAINSAW_HIT2_SOUND 	"weapons/chainsaw_hit2.mp3"
#define CHAINSAW_HIT3_SOUND 	"weapons/chainsaw_hit3.mp3"
#define CHAINSAW_HIT4_SOUND 	"weapons/chainsaw_hit4.mp3"

#define CHAINSAW_IDLE_SOUND 	"weapons/chainsaw_idle.mp3"

#define CHAINSAW_ATTACK1_SOUND 	"weapons/chainsaw_attack1_loop.mp3"
#define CHAINSAW_ATTACK2_SOUND 	"weapons/chainsaw_slash1.mp3"
#define CHAINSAW_ATTACK3_SOUND 	"weapons/chainsaw_slash2.mp3"
#define CHAINSAW_ATTACK4_SOUND 	"weapons/chainsaw_slash3.mp3"

#define CHAINSAW_MODEL_V	 	"models/weapons/csstocsgo/chainsaw/v_chainsaw3.mdl"
#define CHAINSAW_MODEL_W	 	"models/weapons/csstocsgo/chainsaw/w_chainsaw3.mdl"
#define CHAINSAW_MODEL_DROPPED	"models/weapons/csstocsgo/chainsaw/w_chainsaw_dropped.mdl"

#define CHAINSAW_MUZZLE 		"weapon_muzzle_smoke"

/**
 * @endsection
 **/

// Timer index
Handle hWeaponStab[MAXPLAYERS+1] = null;
 
// Item index
int iWeaponChainsaw;

// Sound index
ConVar hSoundLevel;
#pragma unused hSoundLevel

// Animation sequences
enum{
	
	CHAINSAW_ANIM_IDLE,
	CHAINSAW_ANIM_SHOOT1,
	CHAINSAW_ANIM_SHOOT2,
	CHAINSAW_ANIM_RELOAD,
	CHAINSAW_ANIM_DRAW,
	CHAINSAW_ANIM_DUMMY,
	CHAINSAW_ANIM_EMPTY_IDLE,
	CHAINSAW_ANIM_EMPTY_SHOOT1,
	CHAINSAW_ANIM_EMPTY_RELOAD,
	CHAINSAW_ANIM_EMPTY_DRAW,
	CHAINSAW_ANIM_ATTACK_END,
	CHAINSAW_ANIM_ATTACK_LOOP1,
	CHAINSAW_ANIM_ATTACK_LOOP2,
	CHAINSAW_ANIM_ATTACK_START,
	CHAINSAW_ANIM_EMPTY_SHOOT2
};

// Weapon states
enum{
	
	STATE_BEGIN,
	STATE_ATTACK
};

/**
 * @brief The map is ending.
 **/
public void ChainsawOnMapEnd(/*void*/){
	
	// i = client index
	for (int i = 1; i <= MaxClients; i++){
		
		// Purge timers
		hWeaponStab[i] = null; /// with flag TIMER_FLAG_NO_MAPCHANGE 
	}
}

/**
 * @brief Called when a client is disconnecting from the server.
 *
 * @param client            The client index.
 **/
public void ChainsawOnClientDisconnect(int client){
	
	// Delete timers
	delete hWeaponStab[client];
}

//*********************************************************************
//*          Don't modify the code below this line unless             *
//*             you know _exactly_ what you are doing!!!              *
//*********************************************************************

void Chainsaw_OnHolster(int client, int weapon, int iClip, int iAmmo, int iStateMode, float flCurrentTime){
	
	#pragma unused client, weapon, iClip, iAmmo, iStateMode, flCurrentTime
	
	// Delete timers
	delete hWeaponStab[client];
	
	// Cancel reload
	SetEntPropFloat(weapon, Prop_Send, "m_flDoneSwitchingSilencer", 0.0);
	
	// Stop sound
	SEffectsInputEmitToAll(CHAINSAW_IDLE_SOUND, weapon, SNDCHAN_WEAPON, SNDLEVEL_NONE, SND_STOP, 0.0);
}

void Chainsaw_OnIdle(int client, int weapon, int iClip, int iAmmo, int iStateMode, float flCurrentTime){
	
	#pragma unused client, weapon, iClip, iAmmo, iStateMode, flCurrentTime
	
	// Validate clip
	if (iClip <= 0){
		
		// Validate ammo
		if (iAmmo){
			
			Chainsaw_OnReload(client, weapon, iClip, iAmmo, iStateMode, flCurrentTime);
			return; /// Execute fake reload
		}
	}
	
	// Validate animation delay
	if (GetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle") > flCurrentTime){
		return;
	}
	
	// Resets sound
	SEffectsInputEmitToAll(CHAINSAW_IDLE_SOUND, weapon, SNDCHAN_WEAPON, SNDLEVEL_NONE, SND_STOP, 0.0);
	
	// Validate clip
	if (iClip){
		
		// Sets idle animation
		SetWeaponAnimation(client, CHAINSAW_ANIM_IDLE); 
		
		// Sets next idle time
		SetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle", flCurrentTime + CHAINSAW_IDLE_TIME);
	
		// Play sound
		SEffectsInputEmitToAll(CHAINSAW_IDLE_SOUND, weapon, SNDCHAN_WEAPON, CHAINSAW_SOUND_LEVEL);
	}
	else{
		
		// Sets idle animation
		SetWeaponAnimation(client, CHAINSAW_ANIM_EMPTY_IDLE);
		
		// Sets next idle time
		SetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle", flCurrentTime + CHAINSAW_IDLE2_TIME);
	}
}

void Chainsaw_OnReload(int client, int weapon, int iClip, int iAmmo, int iStateMode, float flCurrentTime){
	
	#pragma unused client, weapon, iClip, iAmmo, iStateMode, flCurrentTime
	
	// Validate clip
	if (min(CHAINSAW_CLIP_AMMOUNT - iClip, iAmmo) <= 0){
		return;
	}
	
	// Validate mode
	if (iStateMode > STATE_BEGIN){
		
		Chainsaw_OnEndAttack(client, weapon, iClip, iAmmo, iStateMode, flCurrentTime);
		return;
	}
	
	// Validate animation delay
	if (GetEntPropFloat(weapon, Prop_Send, "m_fLastShotTime") > flCurrentTime){
		return;
	}
	
	// Sets reload animation
	SetWeaponAnimation(client, !iClip ? CHAINSAW_ANIM_EMPTY_RELOAD : CHAINSAW_ANIM_RELOAD); 
	SetPlayerAnimation(client, AnimType_Reload);
	
	// Adds the delay to the game tick
	flCurrentTime += CHAINSAW_RELOAD_SPEED;
	
	// Sets next attack time
	SetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle", flCurrentTime);
	SetEntPropFloat(weapon, Prop_Send, "m_fLastShotTime", flCurrentTime);

	// Stop sound
	SEffectsInputEmitToAll(CHAINSAW_IDLE_SOUND, weapon, SNDCHAN_WEAPON, SNDLEVEL_NONE, SND_STOP, 0.0);
	
	// Remove the delay to the game tick
	flCurrentTime -= 0.5;
	
	// Sets reloading time
	SetEntPropFloat(weapon, Prop_Send, "m_flDoneSwitchingSilencer", flCurrentTime);
	
	// Sets shots count
	SetEntProp(client, Prop_Send, "m_iShotsFired", 0);
}

void Chainsaw_OnReloadFinish(int client, int weapon, int iClip, int iAmmo, int iStateMode, float flCurrentTime){
	
	#pragma unused client, weapon, iClip, iAmmo, iStateMode, flCurrentTime

	// Gets new amount
	int iAmount = min(CHAINSAW_CLIP_AMMOUNT - iClip, iAmmo);

	// Sets ammunition
	SetEntProp(weapon, Prop_Send, "m_iClip1", iClip + iAmount);
	SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", iAmmo - iAmount);

	// Sets reload time
	SetEntPropFloat(weapon, Prop_Send, "m_flDoneSwitchingSilencer", 0.0);
}

void Chainsaw_OnDeploy(int client, int weapon, int iClip, int iAmmo, int iStateMode, float flCurrentTime){
	
	#pragma unused client, weapon, iClip, iAmmo, iStateMode, flCurrentTime

	/// Block the real attack
	SetEntPropFloat(client, Prop_Send, "m_flNextAttack", MAX_FLOAT);
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", MAX_FLOAT);
	SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", MAX_FLOAT);
	
	// Sets draw animation
	SetWeaponAnimation(client, !iClip ? CHAINSAW_ANIM_EMPTY_DRAW : CHAINSAW_ANIM_DRAW);
	
	// Sets attack state
	SetEntProp(weapon, Prop_Data, "m_iHealth", STATE_BEGIN);
	
	// Sets shots count
	SetEntProp(client, Prop_Send, "m_iShotsFired", 0);

	// Sets next attack time
	SetEntPropFloat(weapon, Prop_Send, "m_fLastShotTime", flCurrentTime + CHAINSAW_DEPLOY_SPEED);
}

void Chainsaw_OnPrimaryAttack(int client, int weapon, int iClip, int iAmmo, int iStateMode, float flCurrentTime){
	
	#pragma unused client, weapon, iClip, iAmmo, iStateMode, flCurrentTime

	// Validate clip
	if (iClip <= 0){
		
		// Validate mode
		if (iStateMode > STATE_BEGIN){
			
			Chainsaw_OnEndAttack(client, weapon, iClip, iAmmo, iStateMode, flCurrentTime);
		}
		else{
			
			Chainsaw_OnSecondaryAttack(client, weapon, iClip, iAmmo, iStateMode, flCurrentTime);
		}
		return;
	}
	
	// Validate animation delay
	if (GetEntPropFloat(weapon, Prop_Send, "m_fLastShotTime") > flCurrentTime){
		return;
	}

	// Validate water
	if (GetEntProp(client, Prop_Data, "m_nWaterLevel") == WLEVEL_CSGO_FULL){
		
		Chainsaw_OnEndAttack(client, weapon, iClip, iAmmo, iStateMode, flCurrentTime);
		return;
	}
	
	// Resets sound
	SEffectsInputEmitToAll(CHAINSAW_IDLE_SOUND, weapon, SNDCHAN_WEAPON, SNDLEVEL_NONE, SND_STOP, 0.0);
	
	// Switch mode
	switch (iStateMode){
		
		case STATE_BEGIN :{
			
			// Sets begin animation
			SetWeaponAnimation(client, CHAINSAW_ANIM_ATTACK_START);
			
			// Sets attack state
			SetEntProp(weapon, Prop_Data, "m_iHealth", STATE_ATTACK);

			// Adds the delay to the game tick
			flCurrentTime += CHAINSAW_ATTACK_START_TIME;
			
			// Sets next attack time
			SetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle", flCurrentTime);
			SetEntPropFloat(weapon, Prop_Send, "m_fLastShotTime", flCurrentTime);
		}

		case STATE_ATTACK :{
			
			// Sets attack animation
			SetWeaponAnimationPair(client, weapon, { CHAINSAW_ANIM_ATTACK_LOOP1, CHAINSAW_ANIM_ATTACK_LOOP2 });   
			SetPlayerAnimation(client, AnimType_FirePrimary);
	
			// Substract ammo
			if (!gClientData[client].bInfiniteAmmo){
				iClip -= 1;
				SetEntProp(weapon, Prop_Send, "m_iClip1", iClip);
			}
			
			if (!iClip){
				
				Chainsaw_OnEndAttack(client, weapon, iClip, iAmmo, iStateMode, flCurrentTime);
				return;
			}

			// Play sound
			SEffectsInputEmitToAll(CHAINSAW_ATTACK2_SOUND, client, SNDCHAN_WEAPON, CHAINSAW_SOUND_LEVEL);
			
			// Adds the delay to the game tick
			flCurrentTime += CHAINSAW_ATTACK_SPEED;
			
			// Sets next attack time
			SetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle", flCurrentTime);
			SetEntPropFloat(weapon, Prop_Send, "m_fLastShotTime", flCurrentTime);         

			// Sets shots count
			SetEntProp(client, Prop_Send, "m_iShotsFired", GetEntProp(client, Prop_Send, "m_iShotsFired") + 1);
			
			// Create a melee attack
			Chainsaw_OnSlash(client, weapon, 0.0, true);

			// Gets weapon muzzleflesh
			static char sMuzzle[NORMAL_LINE_LENGTH];
			FormatEx(sMuzzle, sizeof(sMuzzle), CHAINSAW_MUZZLE);
			
			// Creates a muzzle
			UTIL_CreateParticle(Weapon_GetViewModelIndex(client, -1), _, _, "1", sMuzzle, 3.5);
			
			// Initialize variables
			static float vVelocity[3]; int iFlags = GetEntityFlags(client);

			// Gets client velocity
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVelocity);

			// Apply kick back
			if (GetVectorLength(vVelocity) <= 0.0)
			{
				CreateWeaponKickBack(client, 6.5, 5.45, 5.225, 5.05, 6.5, 7.5, 7);
			}
			else if (!(iFlags & FL_ONGROUND))
			{
				CreateWeaponKickBack(client, 7.0, 5.0, 5.5, 5.35, 14.0, 11.0, 5);
			}
			else if (iFlags & FL_DUCKING)
			{
				CreateWeaponKickBack(client, 5.9, 5.35, 5.15, 5.025, 10.5, 6.5, 9);
			}
			else
			{
				CreateWeaponKickBack(client, 5.0, 5.375, 5.175, 5.0375, 10.75, 1.75, 8);
			}
		}
	}
}

void Chainsaw_OnSecondaryAttack(int client, int weapon, int iClip, int iAmmo, int iStateMode, float flCurrentTime){
	
	#pragma unused client, weapon, iClip, iAmmo, iStateMode, flCurrentTime
	
	// Validate animation delay
	if (GetEntPropFloat(weapon, Prop_Send, "m_fLastShotTime") > flCurrentTime){
		return;
	}

	// Validate water
	if (GetEntProp(client, Prop_Data, "m_nWaterLevel") == WLEVEL_CSGO_FULL){
		
		Chainsaw_OnEndAttack(client, weapon, iClip, iAmmo, iStateMode, flCurrentTime);
		return;
	}

	// Validate mode
	if (iStateMode > STATE_BEGIN){
		
		Chainsaw_OnEndAttack(client, weapon, iClip, iAmmo, iStateMode, flCurrentTime);
		return;
	}
	
	// Resets sound
	SEffectsInputEmitToAll(CHAINSAW_IDLE_SOUND, weapon, SNDCHAN_WEAPON, SNDLEVEL_NONE, SND_STOP, 0.0);

	// Validate no ammo
	if (!iClip){
		
		// Sets attack animation  
		SetWeaponAnimationPair(client, weapon, { CHAINSAW_ANIM_EMPTY_SHOOT1, CHAINSAW_ANIM_EMPTY_SHOOT2 });    
		
		// Play sound
		SEffectsInputEmitToAll(CHAINSAW_ATTACK4_SOUND, client, SNDCHAN_WEAPON, CHAINSAW_SOUND_LEVEL);
	}
	else{
		
		// Sets attack animation
		SetWeaponAnimationPair(client, weapon, { CHAINSAW_ANIM_SHOOT1, CHAINSAW_ANIM_SHOOT2 });
		
		// Play sound
		SEffectsInputEmitToAll(GetRandomInt(0, 1) ? CHAINSAW_ATTACK2_SOUND : CHAINSAW_ATTACK3_SOUND, client, SNDCHAN_WEAPON, CHAINSAW_SOUND_LEVEL);		
	}
	
	// Adds the delay to the game tick
	flCurrentTime += CHAINSAW_ATTACK_TIME;

	// Create timer for stab
	delete hWeaponStab[client];
	hWeaponStab[client] = CreateTimer(0.105, Chainsaw_OnStab, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);

	// Sets next attack time
	SetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle", flCurrentTime);
	SetEntPropFloat(weapon, Prop_Send, "m_fLastShotTime", flCurrentTime);
}

void Chainsaw_OnSlash(int client, int weapon, float flRightShift, bool bSlash){
	   
	#pragma unused client, weapon, flRightShift, bSlash

	// Initialize vectors
	static float vPosition[3]; static float vEndPosition[3]; static float vNormal[3];

	// Gets weapon position
	GetPlayerGunPosition(client, 0.0, 0.0, 10.0, vPosition);
	GetPlayerGunPosition(client, bSlash ? CHAINSAW_SLASH_DISTANCE : CHAINSAW_STAB_DISTANCE, flRightShift, 10.0, vEndPosition);

	// Create the end-point trace
	Handle hTrace = TR_TraceRayFilterEx(vPosition, vEndPosition, (MASK_SHOT|CONTENTS_GRATE), RayType_EndPoint, SelfFilter, client);

	// Initialize some variables
	int victim;
	
	// Validate collisions
	if (!TR_DidHit(hTrace)){
		
		// Initialize the hull box
		static const float vMins[3] = { -16.0, -16.0, -18.0  }; 
		static const float vMaxs[3] = {  16.0,  16.0,  18.0  }; 
		
		// Create the hull trace
		delete hTrace;
		hTrace = TR_TraceHullFilterEx(vPosition, vEndPosition, vMins, vMaxs, MASK_SHOT_HULL, SelfFilter, client);
		
		// Validate collisions
		if (TR_DidHit(hTrace)){
			
			// Gets victim index
			victim = TR_GetEntityIndex(hTrace);

			// Is hit world ?
			if (victim < 1 || ToolsIsBSPModel(victim)){
				
				UTIL_FindHullIntersection(hTrace, vPosition, vMins, vMaxs, SelfFilter, client);
			}
		}
	}
	
	// Validate collisions
	if (TR_DidHit(hTrace)){
		
		// Gets victim index
		victim = TR_GetEntityIndex(hTrace);
		
		// Returns the collision position of a trace result
		TR_GetEndPosition(vEndPosition, hTrace);

		// Is hit world ?
		if (victim < 1 || ToolsIsBSPModel(victim)){
			// Returns the collision plane
			TR_GetPlaneNormal(hTrace, vNormal);
			
			// Create a sparks effect
			TE_SetupSparks(vEndPosition, vNormal, 50, 2);
			TE_SendToAll();
			
			// Play sound
			SEffectsInputEmitToAll(GetRandomInt(0, 1) ? CHAINSAW_ATTACK1_SOUND : CHAINSAW_ATTACK2_SOUND, client, SNDCHAN_ITEM, CHAINSAW_SOUND_LEVEL);
		}
		else{
			// Create the damage for victims
			SDKHooks_TakeDamage(victim, weapon, client, bSlash ? CHAINSAW_SLASH_DAMAGE : CHAINSAW_STAB_DAMAGE, DMG_NEVERGIB, weapon);
			//UTIL_CreateDamage(_, vEndPosition, client, bSlash ? CHAINSAW_SLASH_DAMAGE : CHAINSAW_STAB_DAMAGE, CHAINSAW_RADIUS_DAMAGE, DMG_NEVERGIB, iWeaponChainsaw);

			// Validate victim
			if (IsPlayerExist(victim) && gClientData[victim].Zombie){
				
				// Play sound
				SEffectsInputEmitToAll(GetRandomInt(0, 1) ? CHAINSAW_HIT3_SOUND : CHAINSAW_HIT4_SOUND, victim, SNDCHAN_ITEM, CHAINSAW_SOUND_LEVEL);
			}
		}
	}
	
	// Close trace 
	delete hTrace;
}

void Chainsaw_OnEndAttack(int client, int weapon, int iClip, int iAmmo, int iStateMode, float flCurrentTime){
	
	#pragma unused client, weapon, iClip, iAmmo, iStateMode, flCurrentTime

	// Validate mode
	if (iStateMode > STATE_BEGIN){
		
		// Sets end animation
		SetWeaponAnimation(client, CHAINSAW_ANIM_ATTACK_END);

		// Sets begin state
		SetEntProp(weapon, Prop_Data, "m_iHealth", STATE_BEGIN);

		// Adds the delay to the game tick
		flCurrentTime += CHAINSAW_ATTACK_END_TIME;
		
		// Sets next attack time
		SetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle", flCurrentTime);
		SetEntPropFloat(weapon, Prop_Send, "m_fLastShotTime", flCurrentTime);
	}
}

/**
 * @brief Timer for stab effect.
 *
 * @param hTimer            The timer handle.
 * @param userID            The user id.
 **/
public Action Chainsaw_OnStab(Handle hTimer, int userID){
	
	// Gets client index from the user ID
	int client = GetClientOfUserId(userID); int weapon;
	
	// Clear timer 
	hWeaponStab[client] = null;

	// Validate client
	if (IsPlayerHoldWeapon(client, weapon, iWeaponChainsaw)){
		
		float flRightShift = -14.0;
		for (int i = 0; i < 15; i++){
			
			// Do slash
			Chainsaw_OnSlash(client, weapon, flRightShift += 4.0, false);
		}
	}

	// Destroy timer
	return Plugin_Stop;
}

//**********************************************
//* Item (weapon) hooks.                       *
//**********************************************

#define _call2.%0(%1,%2)        \
								\
	Chainsaw_On%0               \
	(                           \
		%1,                     \
		%2,                     \
								\
		GetEntProp(%2, Prop_Send, "m_iClip1"), \
								\
		GetEntProp(%2, Prop_Send, "m_iPrimaryReserveAmmoCount"), \
								\
		GetEntProp(%2, Prop_Data, "m_iHealth"), \
								\
		GetGameTime() \
	)

/**
 * @brief Called after a custom weapon is created.
 *
 * @param client            The client index.
 * @param weapon            The weapon index.
 * @param weaponID          The weapon id.
 **/
public void Chainsaw_OnWeaponCreated(int client, int weapon, int weaponID){
	
	// Validate custom weapon
	if (weaponID == iWeaponChainsaw){
		
		// Resets variables
		SetEntProp(weapon, Prop_Data, "m_iHealth", STATE_BEGIN);
		SetEntPropFloat(weapon, Prop_Send, "m_flDoneSwitchingSilencer", 0.0);
	}
} 
	
/**
 * @brief Called on deploy of a weapon.
 *
 * @param client            The client index.
 * @param weapon            The weapon index.
 * @param weaponID          The weapon id.
 **/
public void Chainsaw_OnWeaponDeploy(int client, int weapon, int weaponID){
	
	// Validate custom weapon
	if (weaponID == iWeaponChainsaw){
		
		// Call event
		_call2.Deploy(client, weapon);
	}
}

/**
 * @brief Called on holster of a weapon.
 *
 * @param client            The client index.
 * @param weapon            The weapon index.
 * @param weaponID          The weapon id.
 **/
public void Chainsaw_OnWeaponHolster(int client, int weapon, int weaponID){
	
	// Validate custom weapon
	if (weaponID == iWeaponChainsaw){
		
		// Call event
		_call2.Holster(client, weapon);
	}
}

/**
 * @brief Called on each frame of a weapon holding.
 *
 * @param client            The client index.
 * @param iButtons          The buttons buffer.
 * @param iLastButtons      The last buttons buffer.
 * @param weapon            The weapon index.
 * @param weaponID          The weapon id.
 *
 * @return                  Plugin_Continue to allow buttons. Anything else 
 *                                (like Plugin_Changed) to change buttons.
 **/
public Action Chainsaw_OnWeaponRunCmd(int client, int &iButtons, int iLastButtons, int weapon, int weaponID){
	
	// Validate custom weapon
	if (weaponID == iWeaponChainsaw){
		
		// Time to reload weapon
		static float flReloadTime;
		if ((flReloadTime = GetEntPropFloat(weapon, Prop_Send, "m_flDoneSwitchingSilencer")) && flReloadTime <= GetGameTime()){
			
			// Call event
			_call2.ReloadFinish(client, weapon);
		}
		else{
			
			// Button reload press
			if (iButtons & IN_RELOAD){
				
				// Call event
				_call2.Reload(client, weapon);
				iButtons &= (~IN_RELOAD); //! Bugfix
				return Plugin_Changed;
			}
		}

		// Button primary attack press
		if (iButtons & IN_ATTACK){
			
			// Call event
			_call2.PrimaryAttack(client, weapon);
			iButtons &= (~IN_ATTACK); //! Bugfix
			return Plugin_Changed;
		}
		// Button primary attack release
		else if (iLastButtons & IN_ATTACK){
			
			// Call event
			_call2.EndAttack(client, weapon);
		}

		// Button secondary attack press
		if (iButtons & IN_ATTACK2){
			
			// Call event
			_call2.SecondaryAttack(client, weapon);
			iButtons &= (~IN_ATTACK2); //! Bugfix
			return Plugin_Changed;
		}
		
		// Call event
		_call2.Idle(client, weapon);
	}
	
	// Allow button
	return Plugin_Continue;
}

/**
 * @brief Trace filter.
 *  
 * @param entity            The entity index.
 * @param contentsMask      The contents mask.
 * @param filter            The filter index.
 *
 * @return                  True or false.
 **/
public bool SelfFilter(int entity, int contentsMask, int filter){
	
	return (entity != filter);
}