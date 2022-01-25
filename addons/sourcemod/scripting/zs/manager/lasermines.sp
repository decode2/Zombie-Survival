//
// lasermines
//

#define LASERMINES_MODULE_VERSION "0.1"

///////////
/*
#define METAL_GIBS_AMOUNT                   5.0
#define METAL_GIBS_DELAY                    0.05
#define METAL_GIBS_SPEED                    500.0
#define METAL_GIBS_VARIENCE                 1.0  
#define METAL_GIBS_LIFE                     1.0  
#define METAL_GIBS_DURATION                 2.0*/

// Lasermines
//-----------------------------------------------------
//#define MODEL_MINE		"models/lasermine/lasermine.mdl"
#define LASERMINES_USE_SOUNDS
#define LASERMINE_MODEL_MINE 	"models/weapons/eminem/laser_mine/w_laser_mine_dropped3.mdl"
#define LASERMINE_MODEL_BEAM 	"materials/sprites/purplelaser1.vmt"
#define LASERMINE_DEPLOY_SOUND 		"*/MassiveInfection/mine_deploy2.mp3"
#define LASERMINE_CHARGE_SOUND 		"*/MassiveInfection/mine_charge2.mp3"
#define LASERMINE_ACTIVATE_SOUND 	"*/MassiveInfection/mine_activate2.mp3"
#define LASERMINE_HEALTH 	170
#define LASERMINE_ACTIVATE_TIME 	0.8
#define LASERMINE_PLANT_COOLDOWN 	0.8
#define LASERMINE_BEAM_UPDATE_DELAY 	0.1
#define LASERMINE_EXPLOSION_RADIUS 	150.0

#define LASERMINE_KILL_SCALAR_REWARD 		11

// Lasermine quantity
//#define LASERMINE_QUANTITY 	3

ArrayList ZLasermines;

enum struct ZLasermine{
	
	int id;
	int health;
	char colors[16];
	char name[16];
	
	void GetColors(char[] buffer, int maxlength){
		strcopy(buffer, maxlength, this.colors);
	}
	
	void GetName(char[] buffer, int maxlength){
		strcopy(buffer, maxlength, this.name);
	}
}

void Lasermines_OnPluginStart(){
	
	// Create the array
	ZLasermines = new ArrayList(sizeof(ZLasermine));
	
	// Fill the array with data
	LoadLasermines();
	
	// Hooks entity env_beam output events - lasermine hook
	HookEntityOutput("env_beam", "OnTouchedByEntity", BeamTouchHook);
}

void Lasermines_OnPluginEnd(){
	
	ZLasermines.Clear();
	delete ZLasermines;
}

void LaserminesOnCommandInit(){
	
	RegConsoleCmd("lasermine", cmdLasermines);
	RegConsoleCmd("lasermines", cmdLasermines);
	RegConsoleCmd("lm", cmdLasermines);
	RegConsoleCmd("minas", cmdLasermines);
	RegConsoleCmd("mina", cmdLasermines);
}

public Action cmdLasermines(int client, int args){
	
	PrintToChat(client, " \x03 --------------------------");
	PrintToChat(client, "%s Para plantar lasermines debes ser \x03HUMANO\x01.", SERVERSTRING);
	PrintToChat(client, "%s Presiona CTRL+E apuntando al \x03piso\x01, \x03paredes\x01 o \x03lasermines\x01.", SERVERSTRING);
	PrintToChat(client, "%s Presiona CTRL+R apuntando a una de \x03tus lasermines\x01 para \x04quitarla\x01.", SERVERSTRING);
	PrintToChat(client, " \x03 --------------------------");
	
	return Plugin_Handled;
}

int CreateLasermine(int health, char[] colors, char[] name){
	
	ZLasermine lasermine;
	lasermine.id = ZLasermines.Length;
	lasermine.health = health;
	strcopy(lasermine.name, sizeof(lasermine.name), name);
	strcopy(lasermine.colors, sizeof(lasermine.colors), colors);
	
	return ZLasermines.PushArray(lasermine);
}

void LoadLasermines(){
	
	ZLasermines.Clear();

	CreateLasermine(getMineMaxHealthByLevel(0), 	"0 255 0", 		"Lasermine tier 1");
	CreateLasermine(getMineMaxHealthByLevel(1), 	"0 255 0", 		"Lasermine tier 2");
	CreateLasermine(getMineMaxHealthByLevel(2), 	"51 255 202", 	"Lasermine tier 3");
	CreateLasermine(getMineMaxHealthByLevel(3), 	"51 255 202", 	"Lasermine tier 4");
	CreateLasermine(getMineMaxHealthByLevel(4), 	"245 223 7", 	"Lasermine tier 5");
	CreateLasermine(getMineMaxHealthByLevel(5), 	"245 223 7", 	"Lasermine tier 6");
	CreateLasermine(getMineMaxHealthByLevel(6), 	"255 255 255", 	"Lasermine tier 7");
	CreateLasermine(getMineMaxHealthByLevel(7), 	"255 255 255", 	"Lasermine tier 8");
	CreateLasermine(getMineMaxHealthByLevel(8), 	"93 0 75", 		"Lasermine tier 9");
	CreateLasermine(getMineMaxHealthByLevel(9), 	"93 0 75", 		"Lasermine tier 10");
	CreateLasermine(getMineMaxHealthByLevel(10), 	"1 13 160", 	"Lasermine tier 11");
	CreateLasermine(getMineMaxHealthByLevel(11), 	"1 13 160", 	"Lasermine tier 12");
	CreateLasermine(getMineMaxHealthByLevel(12), 	"51 160 216", 	"Lasermine tier 13");
}

int getMineMaxHealthByLevel(int iMineLevel){
	
	return RoundToZero(applyPercentage(LASERMINE_HEALTH*1.0, GoldenUpgrade(getUpgradeIndexByUpgradeId(H_LMHP)).getBuffAmount(iMineLevel)));
}

public void Lasermines_OnClientDisconnect(int client){
	
	// Remove any planted lasermine
	RemoveLasermines(client);
}

//=====================================================
//					LASERMINES
//=====================================================
public void PlantLasermine(int userID){
	
	if( ActualMode.is(MODE_ASSASSIN) || ActualMode.is(MODE_WARMUP) || (ActualMode.is(MODE_HORDE) && fnGetPlaying(true) < 10) ) return;
	
	 // Gets client index from the user ID
	int clientIndex = GetClientOfUserId(userID);
	
	// Initialize vectors
	static float vPosition[3]; static float vEndPosition[3]; static float vAngle[3]; 
	
	// Gets trace line
	GetClientEyePosition(clientIndex, vPosition);
	GetPlayerGunPosition(clientIndex, 80.0, 0.0, 0.0, vEndPosition);
	
	// Create the end-point trace
	TR_TraceRayFilter(vPosition, vEndPosition, MASK_SOLID, RayType_EndPoint, TraceFilter2);
	
	// Validate collisions
	if(TR_DidHit() && (TR_GetEntityIndex() < 1 || IsEntityLasermine(TR_GetEntityIndex()))){
		
		// Returns the collision position/angle of a trace result
		TR_GetEndPosition(vPosition);
		TR_GetPlaneNormal(null, vAngle);
		
		// Gets angles of the trace vectors
		GetVectorAngles(vAngle, vAngle); //vAngle[0] += 90.0; /// Bugfix for w_
		
		// Create a physics entity
		int entityIndex = UTIL_CreatePhysics("mine", vPosition, vAngle, LASERMINE_MODEL_MINE, PHYS_FORCESERVERSIDE | PHYS_MOTIONDISABLED | PHYS_NOTAFFECTBYROTOR);
		
		// Validate entity
		if(entityIndex != INVALID_ENT_REFERENCE){
			
			// Sets physics
			SetEntProp(entityIndex, Prop_Data, "m_nSolidType", SOLID_VPHYSICS);
			SetEntProp(entityIndex, Prop_Data, "m_CollisionGroup", COLLISION_GROUP_DEBRIS);
			//SetEntProp(entityIndex, Prop_Data, "m_CollisionGroup", COLLISION_GROUP_WEAPON);
			
			#if LASERMINE_HEALTH > 0
			// Sets health
			SetEntProp(entityIndex, Prop_Data, "m_takedamage", DAMAGE_YES);
			
			/////////////////////////////////START//////////////////////////
			////////////////////////////////////////////////////////////////			
			ZLasermine lasermine;
			ZLasermines.GetArray(gClientData[clientIndex].iGoldenHUpgradeLevel[0], lasermine);
			
			int mineMaxHP = lasermine.health;
			
			int iLasermineStoredHealth = mineMaxHP;
			
			int iCase = -1;
			
			for (int i; i < LASERMINE_QUANTITY; i++){
				
				if (gClientData[clientIndex].iLaserminesHP[i]){
					iCase = i;
					iLasermineStoredHealth -= gClientData[clientIndex].iLaserminesHP[i];
					break;
				}
			}
			
			SetEntProp(entityIndex, Prop_Data, "m_iHealth", iLasermineStoredHealth);
			SetEntProp(entityIndex, Prop_Data, "m_iMaxHealth", mineMaxHP);
			
			/////////////////////////////////END///////////////////////////
			///////////////////////////////////////////////////////////////
			
			// Create damage hook
			SDKHook(entityIndex, SDKHook_OnTakeDamage, MineOnTakeDamage);
			#endif
			
			/////////////////////////////////START//////////////////////////
			///////////////////////////////////////////////////////////////
			SetEntPropFloat(entityIndex, Prop_Send, "m_flModelScale", 1.1);
			
			// Increase mins and maxs
			float vecMins[3], vecMaxs[3];
			GetEntPropVector(entityIndex, Prop_Send, "m_vecMins", vecMins);
			GetEntPropVector(entityIndex, Prop_Send, "m_vecMaxs", vecMaxs);
			
			ScaleVector(vecMins, 1.1);
			ScaleVector(vecMaxs, 1.1);
			
			SetEntPropVector(entityIndex, Prop_Send, "m_vecMins", vecMins);
			SetEntPropVector(entityIndex, Prop_Send, "m_vecMaxs", vecMaxs);
			/////////////////////////////////END///////////////////////////
			///////////////////////////////////////////////////////////////
			
			// Create the angle trace
			//vAngle[0] -= 90.0; /// Bugfix for beam
			TR_TraceRayFilter(vPosition, vAngle, MASK_SOLID, RayType_Infinite, TraceFilter, entityIndex);
			
			// Returns the collision position of a trace result
			TR_GetEndPosition(vEndPosition);
			
			// Store the end position
			SetEntPropVector(entityIndex, Prop_Data, "m_vecViewOffset", vEndPosition);
			
			// Sets owner to the entity
			SetEntPropEnt(entityIndex, Prop_Data, "m_pParent", clientIndex); 
			
			DataPack pack;
			
			// Create timer for activating 
			CreateDataTimer(LASERMINE_ACTIVATE_TIME, MineActivateHook, pack, TIMER_FLAG_NO_MAPCHANGE);
			
			pack.WriteCell(EntIndexToEntRef(entityIndex));
			pack.WriteCell(iLasermineStoredHealth);
			pack.WriteCell(gClientData[clientIndex].iGoldenHUpgradeLevel[0]);
			
			// Play sound			
			/////////////////////////////////START//////////////////////////
			///////////////////////////////////////////////////////////////
			#if defined LASERMINES_USE_SOUNDS
			EmitSoundToAll(LASERMINE_DEPLOY_SOUND, clientIndex, SNDCHAN_STATIC, _, _, 0.5);
			EmitSoundToAll(LASERMINE_CHARGE_SOUND, entityIndex, SNDCHAN_STATIC, _, _, 0.5);
			#endif
			/////////////////////////////////END///////////////////////////
			///////////////////////////////////////////////////////////////
			
			gClientData[clientIndex].iLasermines--;
			
			if (iCase >= 0){
				gClientData[clientIndex].iLaserminesHP[iCase] = 0;
			}
			
			PrintHintText(clientIndex, "Lasermines: %d", gClientData[clientIndex].iLasermines);
		}
	}
	else{
		PrintHintText(clientIndex, "Debes apuntar hacia una <span style='color:blue;'>pared o lasermine</span> para plantar minas");
	}
}
public Action MineActivateHook(Handle hTimer, DataPack pack){
	
	pack.Reset();
	
	int referenceIndex = pack.ReadCell();
	int iLasermineStoredHealth = pack.ReadCell();
	int iLmHpLevel = pack.ReadCell();
	
	// Gets entity index from reference key
	int entityIndex = EntRefToEntIndex(referenceIndex);
	
	// Validate entity
	if(entityIndex != INVALID_ENT_REFERENCE){
		
		// Gets owner of the entity
		int mineOwner = GetEntPropEnt(referenceIndex, Prop_Data, "m_pParent");
		
		bool bDamaged = false;
		ZLasermine lasermine;
		ZLasermines.GetArray(iLmHpLevel, lasermine);
		
		if (iLasermineStoredHealth < lasermine.health){
			bDamaged = true;
		}
		
		bool bStuck = false;
		
		int obstructor;
		// Check if a player is stuck with the mine
		for (int i = 1; i <= MaxClients; i++){
			
			obstructor = i;
			
			if (IsPlayerStuckInEnt(obstructor, entityIndex, true)){
				if (/*mineOwner.id != obstructor.id && */ GetClientTeam(obstructor) == CS_TEAM_CT){
					
					if (bDamaged){
						
						for (int j; j < LASERMINE_QUANTITY; j++){
							
							if (!gClientData[mineOwner].iLaserminesHP[j]){
								gClientData[mineOwner].iLaserminesHP[j] = iLasermineStoredHealth;
								break;
							}
						}
					}
					
					gClientData[mineOwner].iLasermines++;
					
					PrintToChat(mineOwner, "%s Se te ha devuelto \x0Funa\x01 mina láser.", SERVERSTRING);
				}
				
				AcceptEntityInput(entityIndex, "break");
				
				bStuck = true;
				break;
			}
		}
		
		if (bStuck) return Plugin_Stop;
		
		// Initialize vectors
		static float vPosition[3]; static float vEndPosition[3]; 
		
		// Gets mine position
		GetEntPropVector(entityIndex, Prop_Data, "m_vecAbsOrigin", vPosition);
		
		// Play sound
		#if defined LASERMINES_USE_SOUNDS
		EmitSoundToAll(LASERMINE_ACTIVATE_SOUND, entityIndex, SNDCHAN_STATIC, _, _, 0.5);
		#endif
		
		// Gets the end position
		GetEntPropVector(entityIndex, Prop_Data, "m_vecViewOffset", vEndPosition);
		
		// Create a beam entity
		char sColors[16];
		
		if (bDamaged){
			sColors = "255 70 70";
		}
		else{
			FormatEx(sColors, sizeof(sColors), lasermine.colors);
		}
		
		int beamIndex = UTIL_CreateBeam(vPosition, vEndPosition, _, _, _, _, _, _, _, _, _, LASERMINE_MODEL_BEAM, _, _, /*BEAM_STARTSPARKS | BEAM_ENDSPARKS*/_, _, _, _, sColors, LASERMINE_BEAM_UPDATE_DELAY, 0.0, "laser");
		
		// Validate entity
		if(beamIndex != INVALID_ENT_REFERENCE){
			
			// Sets parent to the entity
			SetEntPropEnt(entityIndex, Prop_Data, "m_hMoveChild", beamIndex);
			SetEntPropEnt(beamIndex, Prop_Data, "m_hEffectEntity", entityIndex);
			
			// Gets owner of the entity
			int ownerIndex = GetEntPropEnt(entityIndex, Prop_Data, "m_pParent");
			
			// Validate owner
			if(ownerIndex != INVALID_ENT_REFERENCE){
				// Sets owner to the entity
				SetEntPropEnt(beamIndex, Prop_Data, "m_pParent", ownerIndex);
			}
		}
		
		SetEntProp(entityIndex, Prop_Data, "m_CollisionGroup", COLLISION_GROUP_PLAYER);
	}
	
	// Destroy timer
	return Plugin_Stop;
} 
public void BeamTouchHook(char[] sOutput, int entityIndex, int activatorIndex, float flDelay){
	
	// Validate entity
	if(IsEntityBeam(entityIndex)){
		
		// Validate breakness
		if(IsPlayerExist(activatorIndex, true)){
			
			// Gets owner/victim index
			int mineIndex = GetEntPropEnt(entityIndex, Prop_Data, "m_hEffectEntity");
			
			if (IsEntityLasermine(mineIndex)){
				// Explode entity
				if (GetClientTeam(activatorIndex) == CS_TEAM_T){
					MineExplode(mineIndex);
				}
			}
		}
	}
}
void DefuseLasermine(int userID){
	
	// Gets client index from the user ID
	int client = GetClientOfUserId(userID);
	
	// Initialize vectors
	static float vPosition[3]; static float vEndPosition[3];
	
	// Gets trace line
	GetClientEyePosition(client, vPosition);
	GetPlayerGunPosition(client, 80.0, 0.0, 0.0, vEndPosition);
	
	// Create the end-point trace
	TR_TraceRayFilter(vPosition, vEndPosition, MASK_SOLID, RayType_EndPoint, TraceFilter2);
	
	// Validate collisions
	if(!TR_DidHit()){
		
		// Initialize the hull intersection
		static const float vMins[3] = { -16.0, -16.0, -18.0  };
		static const float vMaxs[3] = {  16.0,  16.0,  18.0  };
		
		// Create the hull trace
		TR_TraceHullFilter(vPosition, vEndPosition, vMins, vMaxs, MASK_SOLID, TraceFilter2);
	}
		
	// Validate collisions
	if(TR_DidHit()){
		
		// Gets entity index
		int entityIndex = TR_GetEntityIndex();
		
		// Validate entity
		if(IsEntityLasermine(entityIndex)){
			
			int owner = GetEntPropEnt(entityIndex, Prop_Data, "m_pParent");
			// Validate owner
			if(owner == client){
				
				int iHealth = GetEntProp(entityIndex, Prop_Data, "m_iHealth");
				if (iHealth < GetEntProp(entityIndex, Prop_Data, "m_iMaxHealth")){
					PrintToChat(client, "%s Quitaste una mina \x0Adañada\x01, plantarla nuevamente le dará vida reducida.", SERVERSTRING);
					
					/*
					if (!player.iLasermineDefused0) player.iLasermineDefused0 = iHealth;
					else if (!player.iLasermineDefused1) player.iLasermineDefused1 = iHealth;
					else player.iLasermineDefused2 = iHealth;*/
					
					for (int i; i < LASERMINE_QUANTITY; i++){
						
						if (!gClientData[client].iLaserminesHP[i]){
							gClientData[client].iLaserminesHP[i] = iHealth;
							break;
						}
					}
				}
				
				gClientData[client].iLasermines++;
				gClientData[client].bInLmAction = true;
				
				#if defined LASERMINES_USE_SOUNDS
				// Emit sound
				EmitSoundToAll("*/items/itempickup.wav", entityIndex, SNDCHAN_STATIC);
				#endif
				
				// Kill entity
				AcceptEntityInput(entityIndex, "Kill");
				
				gClientData[client].bInLmAction = false;
				
				PrintHintText(client, "Lasermines: %d", gClientData[client].iLasermines);
			}
			else{
				if (IsPlayerExist(owner, false)){
					PrintToChat(client, "%s Esta lasermine pertenece a \x09%N\x01!", SERVERSTRING, owner);
				}
			}
		}
	}
}

//=====================================================
//					TAKEDAMAGE
//=====================================================
////////////
#define LASERMINE_KILL_SCALAR_PCT_PER_RESET 	0.03 // 3% reward for each reset ahead between attacker & owner
public Action MineOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype){
	
	if (!IsPlayerExist(attacker, true))
		return Plugin_Handled;
	
	if (!IsEntityLasermine(victim))
		return Plugin_Handled;
	
	if (GetClientTeam(attacker) != CS_TEAM_T)
		return Plugin_Handled;
	
	//PrintToChat(attacker, "iType: %d | isBoss: %b", view_as<int>(iAttacker.iType), iAttacker.isBoss());
	if (gClientData[attacker].iType == PT_ZOMBIE){
		ZClass class;
		ZClasses.GetArray(gClientData[attacker].iZombieClass, class);
		damage *= class.damage;
		
		if (gClientData[attacker].bInvulnerable){
			damage *= 1.5;
		}
	}
	else{
		ZBoss boss;
		ZBosses.GetArray(GetBossIndex(gClientData[attacker].iType), boss);
		damage *= boss.flDamageToLm;
	}
	
	if (gClientData[attacker].iGoldenZUpgradeLevel[1])
		damage *= 1+GoldenUpgrade(getUpgradeIndexByUpgradeId(Z_DAMAGETOLM)).getBuffAmount(gClientData[attacker].iGoldenZUpgradeLevel[1]);
	
	// Calculate the damage
	int iHealth = GetEntProp(victim, Prop_Data, "m_iHealth") - RoundToNearest(damage); iHealth = (iHealth > 0) ? iHealth : 0;
	
	int owner = GetEntPropEnt(victim, Prop_Data, "m_pParent");
	
	// Destroy entity
	if (!iHealth){
		
		// Destroy damage hook
		SDKUnhook(victim, SDKHook_OnTakeDamage, MineOnTakeDamage);
		
		// Explode it
		MineExplode(victim);
		
		ZPlayer iAttacker = ZPlayer(attacker);
		
		// Calculate reward
		//int iReward = obtainBaseProfitPerLasermineKill(attacker, owner);
		
		int resetDiff = gClientData[owner].iReset - gClientData[attacker].iReset;
		
		if (resetDiff < 1){
			resetDiff = 0;
		}
		
		int iReward = LASERMINE_KILL_SCALAR_REWARD*( RoundToZero(0.5*gClientData[attacker].iReset+gClientData[attacker].iLevel*(1.0+0.20*float(gClientData[owner].iGoldenHUpgradeLevel[0])) * (1.0+(LASERMINE_KILL_SCALAR_PCT_PER_RESET*float(resetDiff)) ) ) );
		iReward = iAttacker.applyGain(iReward);
		
		TranslationPrintToChat(attacker, "Destroyed lasermine reward", iReward);
	}
	else{
		SetEntProp(victim, Prop_Data, "m_iHealth", iHealth);
		PrintHintText(attacker, "Vida restante de lasermine: %d", iHealth);
	}
	
	return Plugin_Handled;
}
void MineExplode(int entityIndex){
	
	// Initialize vectors
	static float vPosition[3];
	
	// Gets entity position
	GetEntPropVector(entityIndex, Prop_Data, "m_vecAbsOrigin", vPosition);
	
	// Create an explosion
	UTIL_CreateExplosion(vPosition, /*EXP_NOFIREBALL | */EXP_NOSOUND, _, 0.0, LASERMINE_EXPLOSION_RADIUS, "lasermine", entityIndex, entityIndex);
	
	// Kill after some duration
	UTIL_RemoveEntity(entityIndex, 0.1);
}

//=====================================================
//					STOCKS
//=====================================================

stock bool IsEntityBeam(int entityIndex){
	
	// Gets classname
	static char sClassname[SMALL_LINE_LENGTH];
	GetEntPropString(entityIndex, Prop_Data, "m_iName", sClassname, sizeof(sClassname));
	
	// Validate model
	return (!strncmp(sClassname, "laser", 5, false));
}
stock bool IsEntityLasermine(int entityIndex){
	
	// Validate entity
	if(entityIndex <= MaxClients+1 || !IsValidEdict(entityIndex)){
		return false;
	}
	
	// Gets classname
	static char sClassname[SMALL_LINE_LENGTH];
	GetEntPropString(entityIndex, Prop_Data, "m_iName", sClassname, sizeof(sClassname));
	
	// Validate model
	return (!strcmp(sClassname, "mine", false));
}
public bool TraceFilter(int entityIndex, int contentsMask, int filterIndex){
	if(IsPlayerExist(entityIndex)){
		return false;
	}
	
	return (entityIndex != filterIndex);
}
public bool TraceFilter2(int entityIndex, int contentsMask){
	
	return !(1 <= entityIndex <= MaxClients+1);
}

/////////////
stock void RemoveLasermines(int client, bool returnAll = true){
	ZPlayer player = ZPlayer(client);
	
	int nGetMaxEnt = GetMaxEntities();
	
	int killedEntities;
	for (int nEntity = MaxClients+1; nEntity <= nGetMaxEnt; nEntity++){
		
		if (killedEntities >= LASERMINE_QUANTITY) break;
		
		if(IsEntityLasermine(nEntity) && GetEntPropEnt(nEntity, Prop_Data, "m_pParent") == client){
			
			if (GetEntProp(nEntity, Prop_Data, "m_iHealth") < GetEntProp(nEntity, Prop_Data, "m_iMaxHealth")){			
						
				for (int i; i < LASERMINE_QUANTITY; i++){
				
					if (!gClientData[client].iLaserminesHP[i]){
						gClientData[client].iLaserminesHP[i] = GetEntProp(nEntity, Prop_Data, "m_iHealth");
						break;
					}
				}
			}
			
			AcceptEntityInput(nEntity, "KillHierarchy");
			killedEntities++;
		}
	}
	
	if (returnAll){
		player.iLasermines = LASERMINE_QUANTITY;
		player.iLasermineDefused0 = 0;
		player.iLasermineDefused1 = 0;
		player.iLasermineDefused2 = 0;
	}
	else{
		player.iLasermines = killedEntities;
	}
}


stock int obtainBaseProfitPerLasermineKill(int attacker, int owner){
	
	int attackerLevel = gClientData[attacker].iLevel;
	int attackerReset = gClientData[attacker].iReset;
	int ownerReset = gClientData[owner].iReset;
	
	// Calculate bonus for every level & reset the attacker has
	float levelBonus = float(attackerLevel);
	
	float resetBonus = (0.10*float(attackerReset));
	
	float ownerUpgradeBonus = (1.0+0.20*float(gClientData[owner].iGoldenHUpgradeLevel[0]));
	
	// Calculate base reward without applying any DIFF augment
	//int baseReward = RoundToNearest(float(LASERMINE_KILL_SCALAR_REWARD) * float(levelBonus) * ownerUpgradeBonus);
	
	int baseReward = LASERMINE_KILL_SCALAR_REWARD * Round ToZero(resetBonus+levelBonus*ownerUpgradeBonus);
	
	// Calculate how much reset difference exists between attacker & victim
	int resetDiff = ownerReset - attackerReset;
	
	if (resetDiff >= 1){
		return baseReward * RoundToNearest(LASERMINE_KILL_SCALAR_PCT_PER_RESET*float(resetDiff));
	}
	
	return baseReward;
}