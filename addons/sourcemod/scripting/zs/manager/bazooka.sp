// BAZOOKA EXPERIMENTAL
//*********************************************************************
//*          Don't modify the code below this line unless             *
//*             you know _exactly_ what you are doing!!!              *
//*********************************************************************

#define WEAPON_ROCKET_SPEED 		2000.0
#define WEAPON_ROCKET_DAMAGE 		1200.0
#define WEAPON_ROCKET_GRAVITY 		0.01
#define WEAPON_ROCKET_RADIUS 		400.0
#define WEAPON_EFFECT_TIME 			5.0
#define WEAPON_EXPLOSION_TIME 		2.0
#define WEAPON_IDLE_TIME 			2.0
#define WEAPON_ATTACK_TIME 			1.0

#define BAZOOKA_CLIP_AMMOUNT		1 // 0 is default
#define BAZOOKA_RELOAD_TIME	 		1.0 // duration of reload, 0.0 default, -1.0 instant
#define BAZOOKA_DEPLOY_TIME	 		0.5 // duration of reload, 0.0 default, -1.0 instant
#define BAZOOKA_SPEED	 			2.0 // The delay between shoots of a weapon, 0.0 default, -1.0 instant

#define BAZOOKA_FIRE_SOUND				"weapons/bazooka-1.mp3"
#define BAZOOKA_ROCKET_TRAIL_SOUND		"weapons/ignite_trail_fix.mp3"
#define BAZOOKA_ROCKET_EXPLODE_SOUND	"weapons/rocket_explode.mp3"

#define BAZOOKA_PARTICLES_PCF1 			"muzzle"
#define BAZOOKA_PARTICLES_PCF2 			"trails"
#define BAZOOKA_PARTICLES_PCF3 			"explosions"

#define BAZOOKA_MODEL_V 				"models/weapons/cso/bazooka/v_bazooka.mdl"
#define BAZOOKA_MODEL_W 				"models/weapons/cso/bazooka/w_bazooka.mdl"

#define BAZOOKA_MODEL_MUZZLE 				"muzzle_grenadelauncher"
#define BAZOOKA_ROCKET_EFFECT_PARTICLE 		"rockettrail_airstrike"
#define BAZOOKA_EXPLOSION_EFFECT_PARTICLE 	"ExplosionCore_MidAir"

#define BAZOOKA_MIN_PLAYERS_TO_GIVE 		12


#define _call1.%0(%1,%2)		\
								\
	Bazooka_On%0				\
	(						   	\
		%1,					 	\
		%2,					 	\
								\
		GetEntProp(%2, Prop_Send, "m_iClip1"), \
								\
		GetEntProp(%2, Prop_Send, "m_iPrimaryReserveAmmoCount"), \
								\
		GetGameTime()		   	\
	) 

/**
 * @endsection
 **/
 
 int iWeaponBazooka;
 
// Animation sequences
enum {
	ANIM_IDLE,
	ANIM_SHOOT1,
	ANIM_DRAW,
	ANIM_RELOAD,
	ANIM_SHOOT2
};

void Bazooka_OnHolster(int client, int weapon, int iClip, int iAmmo, float flCurrentTime){
	
	#pragma unused client, weapon, iClip, iAmmo, flCurrentTime

	// Cancel reload
	SetEntPropFloat(weapon, Prop_Send, "m_flDoneSwitchingSilencer", 0.0);
}

void Bazooka_OnIdle(int client, int weapon, int iClip, int iAmmo, float flCurrentTime){
	
	#pragma unused client, weapon, iClip, iAmmo, flCurrentTime

	// Validate clip
	if (iClip <= 0){
		
		// Validate ammo
		if (iAmmo){
			
			Bazooka_OnReload(client, weapon, iClip, iAmmo, flCurrentTime);
			return; /// Execute fake reload
		}
	}
	
	// Validate animation delay
	if (GetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle") > flCurrentTime){
		return;
	}
	
	// Sets idle animation
	SetWeaponAnimation(client, ANIM_IDLE);
	
	// Sets next idle time
	SetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle", flCurrentTime + WEAPON_IDLE_TIME);
}

void Bazooka_OnReload(int client, int weapon, int iClip, int iAmmo, float flCurrentTime){
	
	#pragma unused client, weapon, iClip, iAmmo, flCurrentTime

	// Validate clip
	if (min(BAZOOKA_CLIP_AMMOUNT - iClip, iAmmo) <= 0){
		return;
	}

	// Validate animation delay
	if (GetEntPropFloat(weapon, Prop_Send, "m_fLastShotTime") > flCurrentTime){
		return;
	}
	
	// Sets reload animation
	SetWeaponAnimation(client, ANIM_RELOAD); 
	SetPlayerAnimation(client, AnimType_Reload);
	
	// Adds the delay to the game tick
	flCurrentTime += BAZOOKA_RELOAD_TIME;
	
	// Sets next attack time
	SetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle", flCurrentTime);
	SetEntPropFloat(weapon, Prop_Send, "m_fLastShotTime", flCurrentTime);

	// Remove the delay to the game tick
	flCurrentTime -= 0.5;
	
	// Sets reloading time
	SetEntPropFloat(weapon, Prop_Send, "m_flDoneSwitchingSilencer", flCurrentTime);
	
	// Sets shots count
	SetEntProp(client, Prop_Send, "m_iShotsFired", 0);
}

void Bazooka_OnReloadFinish(int client, int weapon, int iClip, int iAmmo, float flCurrentTime){
	
	#pragma unused client, weapon, iClip, iAmmo, flCurrentTime
	
	// Gets new amount
	int iAmount = min(BAZOOKA_CLIP_AMMOUNT - iClip, iAmmo);

	// Sets ammunition
	SetEntProp(weapon, Prop_Send, "m_iClip1", iClip + iAmount);
	SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", iAmmo - iAmount);

	// Sets reload time
	SetEntPropFloat(weapon, Prop_Send, "m_flDoneSwitchingSilencer", 0.0);
}

void Bazooka_OnDeploy(int client, int weapon, int iClip, int iAmmo, float flCurrentTime){
	
	#pragma unused client, weapon, iClip, iAmmo, flCurrentTime

	/// Block the real attack
	SetEntPropFloat(client, Prop_Send, "m_flNextAttack", MAX_FLOAT);
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", MAX_FLOAT);

	// Sets draw animation
	SetWeaponAnimation(client, ANIM_DRAW); 
	
	// Sets shots count
	SetEntProp(client, Prop_Send, "m_iShotsFired", 0);
	
	// Sets next attack time
	SetEntPropFloat(weapon, Prop_Send, "m_fLastShotTime", flCurrentTime + BAZOOKA_DEPLOY_TIME);
}

void Bazooka_OnPrimaryAttack(int client, int weapon, int iClip, int iAmmo, float flCurrentTime){
	
	#pragma unused client, weapon, iClip, iAmmo, flCurrentTime

	// Validate animation delay
	if (GetEntPropFloat(weapon, Prop_Send, "m_fLastShotTime") > flCurrentTime){
		return;
	}
	
	// Validate clip
	if (iClip <= 0){
		
		// Emit empty sound
		ClientCommand(client, "play weapons/clipempty_rifle.wav");
		SetEntPropFloat(weapon, Prop_Send, "m_fLastShotTime", flCurrentTime + 0.2);
		return;
	}

	// Validate water
	if (GetEntProp(client, Prop_Data, "m_nWaterLevel") == WLEVEL_CSGO_FULL){
		return;
	}

	// Substract ammo
	//iClip -= 1; SetEntProp(weapon, Prop_Send, "m_iClip1", iClip);
	
	SetEntProp(weapon, Prop_Send, "m_iClip1", 0);

	// Sets next attack time
	SetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle", flCurrentTime + WEAPON_ATTACK_TIME);
	SetEntPropFloat(weapon, Prop_Send, "m_fLastShotTime", flCurrentTime + BAZOOKA_SPEED);

	// Sets shots count
	SetEntProp(client, Prop_Send, "m_iShotsFired", GetEntProp(client, Prop_Send, "m_iShotsFired") + 1);
	
	// Play sound
	SEffectsInputEmitToAll(BAZOOKA_FIRE_SOUND, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);
	
	// Sets attack animation
	SetWeaponAnimationPair(client, weapon, { ANIM_SHOOT1, ANIM_SHOOT2 });
	SetPlayerAnimation(client, AnimType_FirePrimary);
	
	// Create a rocket
	Bazooka_OnCreateRocket(client);

	// Initialize variables
	static float vVelocity[3]; int iFlags = GetEntityFlags(client);

	// Gets client velocity
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVelocity);

	// Apply kick back
	if (GetVectorLength(vVelocity) <= 0.0){
		CreateWeaponKickBack(client, 10.5, 7.5, 0.225, 0.05, 10.5, 7.5, 7);
	}
	else if (!(iFlags & FL_ONGROUND)){
		CreateWeaponKickBack(client, 14.0, 10.0, 0.5, 0.35, 14.0, 10.0, 5);
	}
	else if (iFlags & FL_DUCKING){
		CreateWeaponKickBack(client, 10.5, 6.5, 0.15, 0.025, 10.5, 6.5, 9);
	}
	else{
		CreateWeaponKickBack(client, 10.75, 10.75, 0.175, 0.0375, 10.75, 10.75, 8);
	}

	// Creates a muzzle
	UTIL_CreateParticle(Weapon_GetViewModelIndex(client, -1), _, _, "1", BAZOOKA_MODEL_MUZZLE, 0.1);
	
	if (GetEntProp(weapon, Prop_Send, "m_iClip1") < 1){
		if(weapon != -1 && IsValidEdict(weapon)){
    		RemovePlayerItem(client, weapon);
    		//AcceptEntityInput(weapon1, "Kill");
    		RemoveEdict(weapon);
    		FakeClientCommandEx(client, "use weapon_knife");
    	}
	}
}

void Bazooka_OnCreateRocket(int client){
	
	#pragma unused client

	// Initialize vectors
	static float vPosition[3]; static float vAngle[3]; static float vVelocity[3]; static float vSpeed[3];

	// Gets weapon position
	GetPlayerGunPosition(client, 30.0, 10.0, 0.0, vPosition);

	// Gets client eye angle
	GetClientEyeAngles(client, vAngle);

	// Gets client velocity
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVelocity);

	// Create a rocket entity
	int entity = UTIL_CreateProjectile(vPosition, vAngle, "models/weapons/cso/bazooka/w_bazooka_projectile.mdl");

	// Validate entity
	if (entity != -1){
		
		// Returns vectors in the direction of an angle
		GetAngleVectors(vAngle, vSpeed, NULL_VECTOR, NULL_VECTOR);

		// Normalize the vector (equal magnitude at varying distances)
		NormalizeVector(vSpeed, vSpeed);

		// Apply the magnitude by scaling the vector
		ScaleVector(vSpeed, WEAPON_ROCKET_SPEED);

		// Adds two vectors
		AddVectors(vSpeed, vVelocity, vSpeed);

		// Push the rocket
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vSpeed);

		// Create an effect
		UTIL_CreateParticle(entity, vPosition, _, _, BAZOOKA_ROCKET_EFFECT_PARTICLE, WEAPON_EFFECT_TIME);

		// Sets parent for the entity
		SetEntPropEnt(entity, Prop_Data, "m_pParent", client); 
		SetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", client);
		SetEntPropEnt(entity, Prop_Data, "m_hThrower", client);

		// Sets gravity
		SetEntPropFloat(entity, Prop_Data, "m_flGravity", WEAPON_ROCKET_GRAVITY); 
		
		// Play sound
		SEffectsInputEmitToAll(BAZOOKA_ROCKET_TRAIL_SOUND, entity, SNDCHAN_STATIC, SNDLEVEL_NORMAL);
		
		// Create touch hook
		SDKHook(entity, SDKHook_Touch, RocketTouchHook);
	}
}

//**********************************************
//* Item (rocket) hooks.					   *
//**********************************************

/**
 * @brief Rocket touch hook.
 * 
 * @param entity			The entity index.		
 * @param target			The target index.			   
 **/
public Action RocketTouchHook(int entity, int target){
	
	// Validate target
	if (IsValidEdict(target)){
		
		// Gets thrower index
		int thrower = GetEntPropEnt(entity, Prop_Data, "m_hThrower");

		// Validate thrower
		if (thrower == target){
			// Return on the unsuccess
			return Plugin_Continue;
		}

		// Gets entity position
		static float vPosition[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPosition);
		
		// Create an explosion
		UTIL_CreateExplosion(vPosition, EXP_NOFIREBALL | EXP_NOSOUND, _, WEAPON_ROCKET_DAMAGE, WEAPON_ROCKET_RADIUS, "bazooka", thrower, entity);

		// Create an explosion effect
		UTIL_CreateParticle(_, vPosition, _, _, BAZOOKA_EXPLOSION_EFFECT_PARTICLE, WEAPON_EXPLOSION_TIME);

		// Play sound
		SEffectsInputEmitToAll(BAZOOKA_ROCKET_EXPLODE_SOUND, entity, SNDCHAN_STATIC, SNDLEVEL_NORMAL);
		
		// Remove the entity from the world
		AcceptEntityInput(entity, "Kill");
	}

	// Return on the success
	return Plugin_Continue;
}

/**
 * @brief Called before a grenade sound is emitted.
 *
 * @param grenade		   The grenade index.
 * @param weaponID		  The weapon id.
 *
 * @return				  Plugin_Continue to allow sounds. Anything else
 *							  (like Plugin_Stop) to block sounds.
 **/
public Action OnGrenadeSound(int grenade, int weaponID){
	// Validate custom grenade
	if (weaponID == iWeaponBazooka){
		
		// Block sounds
		return Plugin_Stop;
	}
	
	// Allow sounds
	return Plugin_Continue;
}

public void Bazooka_OnWeaponCreated(int client, int weapon, int weaponID){
	
	if (weaponID == iWeaponBazooka){
		
		// Resets variables
		SetEntPropFloat(weapon, Prop_Send, "m_flDoneSwitchingSilencer", 0.0);
	}
}

public void Bazooka_OnWeaponDeploy(int client, int weapon, int weaponID){
	
	// Validate custom weapon
	if (weaponID == iWeaponBazooka){
		
		// Call event
		_call1.Deploy(client, weapon);
	}
}


public void Bazooka_OnWeaponHolster(int client, int weapon, int weaponID){
	
	if (weaponID == iWeaponBazooka){
		
		// Call event
		_call1.Holster(client, weapon);
	}
}

public Action Bazooka_OnWeaponRunCmd(int client, int &iButtons, int iLastButtons, int weapon, int weaponID){
	
	if (weaponID == iWeaponBazooka){
		
		// Time to reload weapon
		static float flReloadTime;
		if ((flReloadTime = GetEntPropFloat(weapon, Prop_Send, "m_flDoneSwitchingSilencer")) && flReloadTime <= GetGameTime()){
			// Call event
			_call1.ReloadFinish(client, weapon);
		}
		else{
			
			// Button reload press
			if (iButtons & IN_RELOAD){
				
				// Call event
				_call1.Reload(client, weapon);
				iButtons &= (~IN_RELOAD); //! Bugfix
				return Plugin_Changed;
			}
		}
		
		// Button primary attack press
		if (iButtons & IN_ATTACK){
			
			// Call event
			_call1.PrimaryAttack(client, weapon);
			iButtons &= (~IN_ATTACK); //! Bugfix
			return Plugin_Changed;
		}
		
		// Call event
		_call1.Idle(client, weapon);
	}
	
	
	// Allow button
	return Plugin_Continue;
}