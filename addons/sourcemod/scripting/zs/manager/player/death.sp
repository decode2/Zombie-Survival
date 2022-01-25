//
// Death module
//

/**
 * Variables to store DHook calls handlers.
 **/
Handle hDHookCommitSuicide;

/**
 * Variables to store dynamic DHook offsets.
 **/
int DHook_CommitSuicide;

void DeathOnInit(){
	
	// Hook player events
	HookEvent("player_death", DeathOnClientDeathPre, EventHookMode_Pre);
	HookEvent("player_death", DeathOnClientDeathPost, EventHookMode_Post);

	// Load offsets
	fnInitGameConfOffset(gServerData.SDKTools, DHook_CommitSuicide, /*CBasePlayer::*/"CommitSuicide");
	
	/// CBasePlayer::CommitSuicide(CBasePlayer *this, bool a2, bool a3)
	hDHookCommitSuicide = DHookCreate(DHook_CommitSuicide, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, DeathDhookOnCommitSuicide);
	DHookAddParam(hDHookCommitSuicide, HookParamType_Bool);
	DHookAddParam(hDHookCommitSuicide, HookParamType_Bool);
}

void DeathOnCommandInit(){
	
	// Hook listeners
	AddCommandListener(DeathOnCommandListened, "kill");
	AddCommandListener(DeathOnCommandListened, "explode");
	AddCommandListener(DeathOnCommandListened, "killvector");
}

void DeathOnClientInit(int client){
	
	// Hook entity callbacks
	DHookEntity(hDHookCommitSuicide, true, client);
}

//=====================================================
//					EVENT FUNCS
//=====================================================
public Action DeathOnCommandListened(int client, const char[] command, int args){
	
	if (IsPlayerExist(client, false)){
		PrintToConsole(client, "Comando %s no permitido.", command);
		PrintToChat(client, "%s Comando \x05%s\x01 no permitido.", SERVERSTRING, command);
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action DeathOnClientDeathPre(Event hEvent, char[] sName, bool dontBroadcast){
	
	// Gets all required event info
	int client = GetClientOfUserId(hEvent.GetInt("userid"));

	// Validate client
	if (!IsPlayerExist(client, false)){
		return;
	}

	// Remove weapons on death
	ZPlayerOnClientDeath(client);
}

public Action DeathOnClientDeathPost(Event hEvent, char[] sName, bool dontBroadcast){
	
	// Gets all required event info
	int client   = GetClientOfUserId(hEvent.GetInt("userid"));
	int attacker = GetClientOfUserId(hEvent.GetInt("attacker"));
	
	// Validate client
	if (!IsPlayerExist(client, false)){
		return Plugin_Continue;
	}
	
	ZPlayer victim = ZPlayer(client);
	ZPlayer Attacker = ZPlayer(attacker);
	
	// Turn off his flashlight
	victim.bFlashlight = false;
	
	// Turn off nightvision
	victim.bNightvisionOn = false;
	
	// Glow bugfix
	victim.removeGlow();
	
	// Hats removal
	//RemoveHat(victim.id);
	
	/*if (!IsPlayerExist(victim.id))
		return Plugin_Continue;*/
	
	// Extinguish if player is on fire
	if (IsClientInGame(victim.id)) ExtinguishEntity(victim.id);
	
	// Freeze grenade timer's reset
	if (victim.hFreezeTimer != INVALID_HANDLE){
		KillTimer(victim.hFreezeTimer);
		victim.hFreezeTimer = INVALID_HANDLE;
	}
	
	// Stop idle sounds
	delete victim.hIdleSound;
	
	// If client commited suicide
	//if(victim.id == Attacker.id) return Plugin_Continue;
	
	// Finish combo party when user is killed/infected
	if (ZPlayer(client).isHuman()){
		
		// If he is in party
		if(gClientData[client].bInParty){
			
			int partyID = findPartyByUID(gClientData[client].iPartyUID);
			
			// Check if party is in array
			if (partyID >= 0){
				SafeEndComboParty(partyID);
			}
		}
	}
	
	// PIU points chance on killing
	if (!IsFakeClient(victim.id) && !IsFakeClient(Attacker.id)){
		if(bAllowGain){
			
			float baseChances = Attacker.isHuman() ? PIUPOINTS_HUMAN_MAX_CHANCES : PIUPOINTS_ZOMBIE_MAX_CHANCES;
			float minChances = Attacker.isHuman() ? PIUPOINTS_HUMAN_MIN_CHANCES : PIUPOINTS_ZOMBIE_MIN_CHANCES;
			float reduction = PIUPOINTS_CHANCES_REDUCTION_PER_RESET*Attacker.iReset;
			
			float totalChances = (baseChances - reduction) < minChances ? minChances : (baseChances - reduction);
			
			int PPoints = calculateChancesFloat(totalChances, GetRandomInt(3, 10), 0);
			
			if(PPoints > 0){
				Attacker.iPiuPoints += PPoints;
				//UpdatePiuPoints(Attacker.id, Attacker.iPiuPoints);
				TranslationPrintToChat(Attacker.id, "Obtained piu points", PPoints);
			}
		}
	}
	
	// If simulated death event
	if(victim.bRecentlyInfected){
		victim.bRecentlyInfected = false;
		
		char szName[48];
		GetClientName(victim.id, szName, sizeof(szName));
		TranslationPrintHudTextAll(gServerData.GameSync, 0.03, 0.35, 3.0, 0, 200, 30, 255, 1, 1.0, 1.0, 1.0, "Has been infected", szName);
		
		return Plugin_Handled;
	}
	
	// Forward event to sub-modules
	DeathOnClientDeath(client, IsPlayerExist(attacker, false) ? attacker : 0);
	
	return Plugin_Continue;
}

void DeathOnClientDeath(int client, int attacker = 0){
	
	ZPlayer victim = ZPlayer(client);
	ZPlayer Attacker = ZPlayer(attacker);
	
	if (attacker > 0 && attacker != client){
		if(victim.isZombie()){
			victim.iRoundDeaths++;
		}
		//victim.RemoveNightvision();
		
		if(Attacker.isZombie()){
			
			// Calculate gain	
			int base = obtainBaseProfitPerKill(Attacker.iLevel, victim.iLevel);
			int iTotal =  Attacker.applyGain(base);
			
			//TranslationPrintToChat(Attacker.id, "Assassination", iTotal);
			printZombieComboHUD(Attacker.id, iTotal, false);
		}
		
		// Gamemode stats check on player killed
		GamemodeStats_OnPlayerKilled(Attacker.id, victim.id);
		
		if (ActualMode.is(MODE_WARMUP) && fnGetPlaying(true) < 4){
			// nothing xd
		}
		else{
			if (victim.isBoss(false)){
				Attacker.applyPoints(true);
			}
			else if (victim.isBoss(true)){
				Attacker.applyPoints(false);
				if(ActualMode.is(MODE_MEOW)){
					Attacker.applyPoints(false);
					Attacker.applyPoints(false);
					Attacker.applyPoints(false);
					Attacker.applyPoints(false);
					Attacker.applyPoints(false);
				}
			}
		}
		
		
		
		#if defined ENABLE_CHESTS
		// Let's deploy this shit
		if (victim.isZombie()){
			int rand = GetRandomInt(0, 100);
			if(rand >= 100-CHEST_DROP_RATIO){
				
				if (CHEST_TIME_TO_SPAWN >= 0.1)
					CreateTimer(CHEST_TIME_TO_SPAWN, TimerSpawnChest, victim.id, TIMER_FLAG_NO_MAPCHANGE);
				else{
					float origin[3];
					GetEntPropVector(victim.id, Prop_Send, "m_vecOrigin", origin);
					
					int chestId = CreateChest(victim.id, origin);
					CreateTimer(CHEST_TIME_DISAPPEAR, DeleteChest, EntIndexToEntRef(chestId), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
		#endif
	}
	
	// Emit death sound
	EmitDeathSound(victim.id);
	
	// Hats removal
	RemoveHat(victim.id);
	
	RagdollOnClientDeath(victim.id);
	
	RemoveAura(victim.id);
	
	PartyOnPlayerDeath(victim.id);
	
	RoundEndOnPlayerDeath();
	
	// If gamemode allows respawn
	if (ActualMode.bRespawn && !gServerData.RoundEnd) CreateTimer(1.5, respawnPlayer, victim);
	
	//return Plugin_Continue;
}

public MRESReturn DeathDhookOnCommitSuicide(int client){
	
	// Forward event to sub-modules
	DeathOnClientDeath(client);
}