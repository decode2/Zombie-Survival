
#define STRING_MESSAGES_BLOCK "Player_Cash_Award_Team_Cash_Award_Player_Point_Award_Match_Will_Start_Chat_SavePlayer"

/**
 * @section List of cvars used by the plugin.
 **/
enum struct CvarsList
{    
	ConVar DATABASE;
	ConVar ANTISTICK;
	ConVar COSTUMES;
	ConVar MENU_BUTTON;
	ConVar SKILL_BUTTON;
	ConVar LIGHT_BUTTON;
	ConVar BUY_BUTTON;
	ConVar HUMAN_MENU;
	ConVar ZOMBIE_MENU;

	ConVar HITGROUP;
	ConVar HITGROUP_KNOCKBACK;
	ConVar HITGROUP_KNOCKBACK_AIR;
	ConVar HITGROUP_FRIENDLY_FIRE;
	ConVar HITGROUP_FRIENDLY_GRENADE;
	ConVar HITGROUP_FRIENDLY_BULLETS;
	ConVar HITGROUP_FRIENDLY_OTHER;
	ConVar HITGROUP_FRIENDLY_SELF;

	ConVar GAMEMODE;
	ConVar GAMEMODE_BLAST_TIME;
	ConVar GAMEMODE_WEAPONS_REMOVE;
	ConVar GAMEMODE_TEAM_BALANCE;
	ConVar GAMEMODE_LIMIT_TEAMS;
	ConVar GAMEMODE_WARMUP_TIME;
	ConVar GAMEMODE_WARMUP_PERIOD;
	ConVar GAMEMODE_ROUNDTIME_ZP;
	ConVar GAMEMODE_ROUNDTIME_CS;
	ConVar GAMEMODE_ROUNDTIME_DE;
	ConVar GAMEMODE_ROUND_RESTART;
	ConVar GAMEMODE_RESTART_DELAY;

	ConVar WEAPON_GIVE_TASER;
	ConVar WEAPON_GIVE_BOMB;
	ConVar WEAPON_DROP_GRENADE;
	ConVar WEAPON_DROP_BREACH;
	ConVar WEAPON_DROP_KNIFE;
	ConVar WEAPON_CT_DEFAULT_GRENADES;
	ConVar WEAPON_CT_DEFAULT_MELEE;
	ConVar WEAPON_CT_DEFAULT_SECONDARY;
	ConVar WEAPON_CT_DEFAULT_PRIMARY;
	ConVar WEAPON_T_DEFAULT_GRENADES;
	ConVar WEAPON_T_DEFAULT_MELEE;
	ConVar WEAPON_T_DEFAULT_SECONDARY;
	ConVar WEAPON_T_DEFAULT_PRIMARY;
	ConVar WEAPON_PICKUP_RANGE;
	ConVar WEAPON_PICKUP_LEVEL;
	ConVar WEAPON_PICKUP_ONLINE;
	ConVar WEAPON_DEFAULT_MELEE;

	ConVar LOG;
	ConVar LOG_MODULE_FILTER;
	ConVar LOG_IGNORE_CONSOLE;
	ConVar LOG_ERROR_OVERRIDE;
	ConVar LOG_PRINT_CHAT;
		   
	ConVar JUMPBOOST;
	ConVar JUMPBOOST_MULTIPLIER;
	ConVar JUMPBOOST_MAX;
		   
	ConVar LEVEL_SYSTEM;
	ConVar LEVEL_HEALTH_RATIO;
	ConVar LEVEL_SPEED_RATIO;
	ConVar LEVEL_GRAVITY_RATIO;
	ConVar LEVEL_DAMAGE_RATIO;
	ConVar LEVEL_HUD;
	ConVar LEVEL_HUD_ZOMBIE_R;
	ConVar LEVEL_HUD_ZOMBIE_G;
	ConVar LEVEL_HUD_ZOMBIE_B;
	ConVar LEVEL_HUD_ZOMBIE_A;
	ConVar LEVEL_HUD_HUMAN_R;
	ConVar LEVEL_HUD_HUMAN_G;
	ConVar LEVEL_HUD_HUMAN_B;
	ConVar LEVEL_HUD_HUMAN_A;
	ConVar LEVEL_HUD_SPECTATOR_R;
	ConVar LEVEL_HUD_SPECTATOR_G;
	ConVar LEVEL_HUD_SPECTATOR_B;
	ConVar LEVEL_HUD_SPECTATOR_A;
	ConVar LEVEL_HUD_X;
	ConVar LEVEL_HUD_Y;

	ConVar ACCOUNT_CASH_AWARD;
	ConVar ACCOUNT_BUY_ANYWHERE;
	ConVar ACCOUNT_BUY_IMMUNITY;
	ConVar ACCOUNT_MONEY;
	ConVar ACCOUNT_CONNECT;
	ConVar ACCOUNT_BET;
	ConVar ACCOUNT_COMMISION;
	ConVar ACCOUNT_DECREASE;
	ConVar ACCOUNT_HUD_R;
	ConVar ACCOUNT_HUD_G;
	ConVar ACCOUNT_HUD_B;
	ConVar ACCOUNT_HUD_A;
	ConVar ACCOUNT_HUD_X;
	ConVar ACCOUNT_HUD_Y;
	
	ConVar ZTELE_ESCAPE;
	ConVar ZTELE_ZOMBIE;
	ConVar ZTELE_HUMAN;
	ConVar ZTELE_DELAY_ZOMBIE;
	ConVar ZTELE_DELAY_HUMAN;
	ConVar ZTELE_MAX_ZOMBIE;
	ConVar ZTELE_MAX_HUMAN;
	ConVar ZTELE_AUTOCANCEL;
	ConVar ZTELE_AUTOCANCEL_DIST;

	ConVar VEFFECTS_IMMUNITY_ALPHA;
	ConVar VEFFECTS_HEALTH;
	ConVar VEFFECTS_HEALTH_SPRITE;
	ConVar VEFFECTS_HEALTH_SCALE;
	ConVar VEFFECTS_HEALTH_VAR;
	ConVar VEFFECTS_HEALTH_FRAMES;
	ConVar VEFFECTS_HEALTH_DURATION;
	ConVar VEFFECTS_HEALTH_HEIGHT;
	ConVar VEFFECTS_INFECT;
	ConVar VEFFECTS_INFECT_FADE;
	ConVar VEFFECTS_INFECT_FADE_TIME;
	ConVar VEFFECTS_INFECT_FADE_DURATION;
	ConVar VEFFECTS_INFECT_FADE_R;
	ConVar VEFFECTS_INFECT_FADE_G;
	ConVar VEFFECTS_INFECT_FADE_B;
	ConVar VEFFECTS_INFECT_FADE_A;
	ConVar VEFFECTS_INFECT_SHAKE;
	ConVar VEFFECTS_INFECT_SHAKE_AMP;
	ConVar VEFFECTS_INFECT_SHAKE_FREQUENCY;
	ConVar VEFFECTS_INFECT_SHAKE_DURATION;
	ConVar VEFFECTS_HUMANIZE;
	ConVar VEFFECTS_HUMANIZE_FADE;
	ConVar VEFFECTS_HUMANIZE_FADE_TIME;
	ConVar VEFFECTS_HUMANIZE_FADE_DURATION;
	ConVar VEFFECTS_HUMANIZE_FADE_R;
	ConVar VEFFECTS_HUMANIZE_FADE_G;
	ConVar VEFFECTS_HUMANIZE_FADE_B;
	ConVar VEFFECTS_HUMANIZE_FADE_A;
	ConVar VEFFECTS_RESPAWN;
	ConVar VEFFECTS_RESPAWN_NAME;
	ConVar VEFFECTS_RESPAWN_ATTACH;
	ConVar VEFFECTS_RESPAWN_DURATION;
	ConVar VEFFECTS_HEAL;
	ConVar VEFFECTS_HEAL_NAME;
	ConVar VEFFECTS_HEAL_ATTACH;
	ConVar VEFFECTS_HEAL_DURATION;
	ConVar VEFFECTS_HEAL_FADE;
	ConVar VEFFECTS_HEAL_FADE_TIME;
	ConVar VEFFECTS_HEAL_FADE_DURATION;
	ConVar VEFFECTS_HEAL_FADE_R;
	ConVar VEFFECTS_HEAL_FADE_G;
	ConVar VEFFECTS_HEAL_FADE_B;
	ConVar VEFFECTS_HEAL_FADE_A;
	ConVar VEFFECTS_LEAP;
	ConVar VEFFECTS_LEAP_NAME;
	ConVar VEFFECTS_LEAP_ATTACH;
	ConVar VEFFECTS_LEAP_DURATION;
	ConVar VEFFECTS_LEAP_SHAKE;
	ConVar VEFFECTS_LEAP_SHAKE_AMP;
	ConVar VEFFECTS_LEAP_SHAKE_FREQUENCY;
	ConVar VEFFECTS_LEAP_SHAKE_DURATION;
	ConVar VEFFECTS_LIGHTSTYLE;
	ConVar VEFFECTS_LIGHTSTYLE_VALUE;
	ConVar VEFFECTS_SKY;
	ConVar VEFFECTS_SKYNAME;
	ConVar VEFFECTS_SKY_PATH; 
	ConVar VEFFECTS_SUN_DISABLE;
	ConVar VEFFECTS_FOG;
	ConVar VEFFECTS_FOG_COLOR;
	ConVar VEFFECTS_FOG_DENSITY;
	ConVar VEFFECTS_FOG_STARTDIST;
	ConVar VEFFECTS_FOG_ENDDIST;
	ConVar VEFFECTS_FOG_FARZ;
	ConVar VEFFECTS_RAGDOLL_REMOVE;
	ConVar VEFFECTS_RAGDOLL_DISSOLVE;
	ConVar VEFFECTS_RAGDOLL_DELAY;

	ConVar SEFFECTS_LEVEL;
	ConVar SEFFECTS_ALLTALK;
	ConVar SEFFECTS_VOICE;
	ConVar SEFFECTS_VOICE_ZOMBIES_MUTE;
	ConVar SEFFECTS_INFECT;
	ConVar SEFFECTS_MOAN;
	ConVar SEFFECTS_GROAN;
	ConVar SEFFECTS_BURN;
	ConVar SEFFECTS_DEATH;
	ConVar SEFFECTS_FOOTSTEPS;
	ConVar SEFFECTS_CLAWS;    
	ConVar SEFFECTS_PLAYER_FLASHLIGHT; 
	ConVar SEFFECTS_PLAYER_NVGS;
	ConVar SEFFECTS_PLAYER_AMMUNITION;  
	ConVar SEFFECTS_PLAYER_LEVEL;       
	ConVar SEFFECTS_ROUND_START;       
	ConVar SEFFECTS_ROUND_COUNT;  
	ConVar SEFFECTS_ROUND_BLAST;

	ConVar ICON_INFECT;
	ConVar ICON_HEAD;

	ConVar MESSAGES_OBJECTIVE;
	ConVar MESSAGES_COUNTER;
	ConVar MESSAGES_BLAST;
	ConVar MESSAGES_DAMAGE;
	ConVar MESSAGES_DONATE;
	ConVar MESSAGES_CLASS_INFO;
	ConVar MESSAGES_CLASS_CHOOSE;
	ConVar MESSAGES_CLASS_DUMP;
	ConVar MESSAGES_ITEM_INFO;
	ConVar MESSAGES_ITEM_ALL;
	ConVar MESSAGES_WEAPON_INFO;
	ConVar MESSAGES_WEAPON_ALL;
	ConVar MESSAGES_WEAPON_DROP;
	ConVar MESSAGES_BLOCK;

	ConVar SEND_TABLES;
}
/**
 * @endsection
 **/
 
/**
 * Array to store cvar data in.
 **/
CvarsList gCvarList;

/**
 * Handles for storing messages id.
 **/
UserMsg hTextMsg; UserMsg hHintText; char sEmpty[FILE_LINE_LENGTH] = "";

/**
 * @brief Creates commands for tools module.
 **/
void ToolsOnCommandInit(/*void*/)
{
	// Returns the ID of a given message
	hTextMsg = GetUserMessageId("TextMsg");
	hHintText = GetUserMessageId("HintText");
	
	// Validate an empty string
	if (!hasLength(sEmpty)){
		
		// Fill the string with spaces
		for (int i = 0; i < sizeof(sEmpty) - 1; i++){
			sEmpty[i] = ' ';
		}
	}

	// Hook messages
	HookUserMessage(hTextMsg, ToolsOnMessageHook, true);
	HookUserMessage(hTextMsg, ToolsOnHintHook, true);
	HookUserMessage(hHintText, ToolsOnHintHook, true);
}

/**
 * @brief Hook tools cvar changes.
 **/
void ToolsOnCvarInit(/*void*/){
	
	// Creates cvars
	gCvarList.SEND_TABLES           = FindConVar("sv_sendtables");
	
	// Sets locked cvars to their locked value
	gCvarList.SEND_TABLES.IntValue = 1;
}


public Action ToolsOnMessageHook(UserMsg hMessage, Protobuf hMsg, const int[] iPlayers, int playersNum, bool bReliable, bool bInit){
	
	// Initialize message
	static char sBuffer[PLATFORM_LINE_LENGTH]; 
	hMsg.ReadString("params", sBuffer, sizeof(sBuffer), 0);
	
	// Initialize block message list
	static char sBlock[PLATFORM_LINE_LENGTH];
	FormatEx(sBlock, sizeof sBlock, STRING_MESSAGES_BLOCK);
	
	// Block messages on the matching
	return (StrContains(sBlock, sBuffer, false) != -1) ? Plugin_Handled : Plugin_Continue; 
}

/**
 * @brief Hook client hint messages.
 *
 * @param hMessage          The message index.
 * @param hMsg              Handle to the input bit buffer.
 * @param iPlayers          Array containing player indexes.
 * @param playersNum        Number of players in the array.
 * @param bReliable         True if message is reliable, false otherwise.
 * @param bInit             True if message is an initmsg, false otherwise.
 **/
public Action ToolsOnHintHook(UserMsg hMessage, Protobuf hMsg, const int[] iPlayers, int playersNum, bool bReliable, bool bInit)
{
	// Initialize message
	static char sBuffer[FILE_LINE_LENGTH];
	
	// Gets the string from a protobuf
	if (hMessage == hHintText)
	{
		hMsg.ReadString("text", sBuffer, sizeof(sBuffer));
	}
	else if (hMsg.ReadInt("msg_dst") == 4)
	{
		hMsg.ReadString("params", sBuffer, sizeof(sBuffer), 0);
	}
	else
	{
		return Plugin_Continue;
	}
	
	// Validate html tags
	if (StrContains(sBuffer, "</font>") != -1 || StrContains(sBuffer, "</span>") != -1)
	{
		DataPack hPack = new DataPack();
		/// Initialize pack
		hPack.WriteCell(playersNum);
		for (int i = 0; i < playersNum; i++)
		{
			hPack.WriteCell(iPlayers[i]);
		}
		hPack.WriteString(sBuffer);
		hPack.Reset();
		
		// Execute fix on the next frame
		RequestFrame(ToolsOnMessageFix, hPack);
		
		// Block message
		return Plugin_Handled;
	}
	
	// Allow message
	return Plugin_Continue;
}

/**
 * @brief Called after a default hint message is created.
 *
 * @param hPack             The pack handle.
 **/
public void ToolsOnMessageFix(DataPack hPack)
{
	// Intitialize some variables
	int iCount = 0; int iCountAll = hPack.ReadCell();
	static int iPlayers[MAXPLAYERS+1];
	
	// i = incrementer index 
	for (int i = 0, client; i < iCountAll; i++)
	{
		/// Extract data from pack
		client = hPack.ReadCell();
		
		// Validate client
		if (IsPlayerExist(client, false))
		{
			iPlayers[iCount++] = client;
		}
	}
	
	// Validate player count
	if (iCount != 0)
	{
		// Gets the string from the pack
		static char sBuffer[FILE_LINE_LENGTH];
		hPack.ReadString(sBuffer, sizeof(sBuffer));

		// Create message
		Protobuf hMessage = view_as<Protobuf>(StartMessageEx(hTextMsg, iPlayers, iCount, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS));
		
		// Validate message
		if (hMessage != null)
		{
			hMessage.SetInt("msg_dst", 4);
			hMessage.AddString("params", "#SFUI_ContractKillStart");
			Format(sBuffer, sizeof(sBuffer), "</font>%s%s", sBuffer, sEmpty);
			hMessage.AddString("params", sBuffer);
			hMessage.AddString("params", NULL_STRING);
			hMessage.AddString("params", NULL_STRING);
			hMessage.AddString("params", NULL_STRING);
			hMessage.AddString("params", NULL_STRING);
			
			// Ends a previously started network message
			EndMessage();
		}
	}
	
	// Close pack 
	delete hPack;
}

/**
 * @brief Gets or sets the velocity of a entity.
 *
 * @param entity            The entity index.
 * @param vVelocity         The velocity output, or velocity to set on entity.
 * @param bApply            True to get entity velocity, false to set it.
 * @param bStack            If modifying velocity, then true will stack new velocity onto the entity.
 *                          current velocity, false will reset it.
 **/
stock void ToolsSetVelocity(int entity, float vVelocity[3], bool bApply = true, bool bStack = true)
{
    // If retrieve if true, then get entity velocity
    if (!bApply)
    {
        // Gets entity velocity
        ToolsGetVelocity(entity, vVelocity);
        
        // Stop here
        return;
    }
    
    // If stack is true, then add entity velocity
    if (bStack)
    {
        // Gets entity velocity
        static float vSpeed[3];
        ToolsGetVelocity(entity, vSpeed);
        
        // Add to the current
        AddVectors(vSpeed, vVelocity, vVelocity);
    }
    
    // Apply velocity on entity
    TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vVelocity);
}

/**
 * @brief Gets the velocity of a entity.
 *
 * @param entity            The entity index.
 * @param vVelocity         The velocity output.
 **/
stock void ToolsGetVelocity(int entity, float vVelocity[3])
{
    // Gets origin of the entity
    GetEntPropVector(entity, Prop_Data, "m_vecVelocity", vVelocity);
}

/**
 * @brief Gets the abs origin of a entity.
 *
 * @param entity            The entity index.
 * @param vPosition         The origin output.
 **/
stock void ToolsGetAbsOrigin(int entity, float vPosition[3])
{
    // Gets origin of the entity
    GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPosition);
}

/**
 * @brief Gets the abs angle of a entity.
 *
 * @param entity            The entity index.
 * @param vAngle            The angle output.
 **/
stock void ToolsGetAbsAngles(int entity, float vAngle[3])
{
    // Gets angles of the entity
    GetEntPropVector(entity, Prop_Data, "m_angAbsRotation", vAngle);
}

/**
 * @brief Gets the max weapons of a entity.
 *
 * @param entity            The entity index.
 * @return                  The max weapon amount.
 **/
stock int ToolsGetMyWeapons(int entity)
{
    // Gets weapons of the entity
    return GetEntPropArraySize(entity, Prop_Data, "m_hMyWeapons");
}

/**
 * @brief Gets weapon on the position of a entity.
 *
 * @param entity            The entity index.
 * @param iPosition         The weapon position.
 * @return                  The weapon index.
 **/
stock int ToolsGetWeapon(int entity, int iPosition)
{
    // Gets weapon of the entity
    return GetEntPropEnt(entity, Prop_Data, "m_hMyWeapons", iPosition);
}

/**
 * @brief Gets the health of a entity.
 *
 * @param entity            The entity index.
 * @param bMax              True to get maximum value, false to get health.  
 * @return                  The health value.
 **/
stock int ToolsGetHealth(int entity, bool bMax = false)
{
    // Gets health of the entity
    return GetEntProp(entity, Prop_Data, bMax ? "m_iMaxHealth" : "m_iHealth");
}

/**
 * @brief Sets the health of a entity.
 *
 * @param entity            The entity index.
 * @param iValue            The health value.
 * @param bSet              True to set maximum value, false to modify health.  
 **/
stock void ToolsSetHealth(int entity, int iValue, bool bSet = false)
{
    // Sets health of the entity
    SetEntProp(entity, Prop_Send, "m_iHealth", iValue);
    
    // If set is true, then set max health
    if (bSet) 
    {
        // Sets max health of the entity
        SetEntProp(entity, Prop_Data, "m_iMaxHealth", iValue);
    }
}

/**
 * @brief Gets the speed of a entity.
 *
 * @param entity            The entity index.
 * @return                  The LMV value.
 **/
/*float ToolsGetLMV(int entity)
{
    // Gets lagged movement value of the entity
    return GetEntPropFloat(entity, Prop_Data, "m_flLaggedMovementValue");
}*/

/**
 * @brief Sets the speed of a entity.
 *
 * @param entity            The entity index.
 * @param flValue           The LMV value.
 **/
stock void ToolsSetLMV(int entity, float flValue)
{
    // Sets lagged movement value of the entity
    SetEntPropFloat(entity, Prop_Data, "m_flLaggedMovementValue", flValue);
}

/**
 * @brief Gets the armor of a entity.
 *
 * @param entity            The entity index.
 * @return                  The armor value.
 **/
stock int ToolsGetArmor(int entity)
{
    // Gets armor of the entity
    return GetEntProp(entity, Prop_Send, "m_ArmorValue");
}

/**
 * @brief Sets the armor of a entity.
 *
 * @param entity            The entity index.
 * @param iValue            The armor value.
 **/
stock void ToolsSetArmor(int entity, int iValue)
{
    // Sets armor of the entity
    SetEntProp(entity, Prop_Send, "m_ArmorValue", iValue);
}

/**
 * @brief Gets the team of an entity.
 * 
 * @param entity            The entity index.
 * @return                  The team index.
 **/
stock int ToolsGetTeam(int entity)
{
    // Gets team on the entity
    return GetEntProp(entity, Prop_Data, "m_iTeamNum");
}

/**
 * @brief Sets the team of a entity.
 *
 * @param entity            The entity index.
 * @param iValue            The team index.
 **/
stock void ToolsSetTeam(int entity, int iValue)
{
    // Validate team
    if (ToolsGetTeam(entity) <= TEAM_SPECTATOR) /// Fix, thanks to inklesspen!
    {
        // Sets team of the entity
        ChangeClientTeam(entity, iValue);
    }
    else
    {
        // Switch team of the entity
        CS_SwitchTeam(entity, iValue); 
    }
}

/**
 * @brief Gets nightvision values on a entity.
 *
 * @param entity            The entity index.
 * @param ownership         If true, function will return the value of the entity ownership of nightvision.
 *                          If false, function will return the value of the entity on/off state of the nightvision.
 * @return                  True if aspect of nightvision is enabled on the entity, false if not.
 **/
stock bool ToolsGetNightVision(int entity, bool bOwnership = false)
{
    // If ownership is true, then gets the ownership of nightvision on entity
    return view_as<bool>(GetEntProp(entity, Prop_Send, bOwnership ? "m_bHasNightVision" : "m_bNightVisionOn"));
}

/**
 * @brief Controls nightvision values on a entity.
 *
 * @param entity            The entity index.
 * @param bEnable           Enable or disable an aspect of nightvision. (see ownership parameter)
 * @param bOwnership        If true, enable will toggle the entity ownership of nightvision.
 *                          If false, enable will toggle the entity on/off state of the nightvision.
 **/
stock void ToolsSetNightVision(int entity, bool bEnable, bool bOwnership = false)
{
    // If ownership is true, then toggle the ownership of nightvision on entity
    SetEntProp(entity, Prop_Send, bOwnership ? "m_bHasNightVision" : "m_bNightVisionOn", bEnable);
}

/**
 * @brief Gets defuser value on a entity.
 *
 * @param entity            The entity index.
 * @return                  The aspect of the entity defuser.
 **/
stock bool ToolsGetDefuser(int entity)
{
    // Gets defuser on the entity
    return view_as<bool>(GetEntProp(entity, Prop_Send, "m_bHasDefuser"));
}

/**
 * @brief Controls defuser value on a entity.
 *
 * @param entity            The entity index.
 * @param bEnable           Enable or disable an aspect of defuser.
 **/
stock void ToolsSetDefuser(int entity, bool bEnable)
{
    // Sets defuser on the entity
    SetEntProp(entity, Prop_Send, "m_bHasDefuser", bEnable);
}

/**
 * @brief Gets helmet value on a entity.
 *
 * @param entity            The entity index.
 * @return                  The aspect of the entity helmet.
 **/
stock bool ToolsGetHelmet(int entity)
{
    // Gets helmet on the entity
    return view_as<bool>(GetEntProp(entity, Prop_Send, "m_bHasHelmet"));
}

/**
 * @brief Controls helmet value on a entity.
 *
 * @param entity            The entity index.
 * @param bEnable           Enable or disable an aspect of helmet.
 **/
stock void ToolsSetHelmet(int entity, bool bEnable)
{
    // Sets helmet on the entity
    SetEntProp(entity, Prop_Send, "m_bHasHelmet", bEnable);
}

/**
 * @brief Gets suit value on a entity.
 *
 * @param entity            The entity index.
 * @return                  The aspect of the entity suit.
 **/
stock bool ToolsGetHeavySuit(int entity)
{
    // Gets suit on the entity
    return view_as<bool>(GetEntProp(entity, Prop_Send, "m_bHasHeavyArmor"));
}

/**
 * @brief Controls suit value on a entity.
 *
 * @param entity            The entity index.
 * @param bEnable           Enable or disable an aspect of suit.
 **/
stock void ToolsSetHeavySuit(int entity, bool bEnable)
{
    // Sets suit on the entity
    SetEntProp(entity, Prop_Send, "m_bHasHeavyArmor", bEnable);
}

/**
 * @brief Gets the active weapon index of a entity.
 *
 * @param entity            The entity index.
 * @return                  The weapon index.
 **/
stock int ToolsGetActiveWeapon(int entity)
{
    // Gets weapon on the entity
    return GetEntPropEnt(entity, Prop_Send, "m_hActiveWeapon");
}

/**
 * @brief Sets the active weapon index of a entity.
 *
 * @param entity            The entity index.
 * @param weapon            The weapon index.
 **/
/*stock void ToolsSetActiveWeapon(int entity, int weapon)
{
    // Sets weapon on the entity    
    SetEntPropEnt(entity, Prop_Send, "m_hActiveWeapon", weapon);
}*/

/**
 * @brief Gets the addon bits of a entity.
 *
 * @param entity            The entity index.
 * @return                  The addon bits.
 **/
stock int ToolsGetAddonBits(int entity)
{
    // Gets addon value on the entity    
    return GetEntProp(entity, Prop_Send, "m_iAddonBits");
}

/**
 * @brief Sets the addon bits index of a entity.
 *
 * @param entity            The entity index.
 * @param iValue            The addon bits.
 **/
stock void ToolsSetAddonBits(int entity, int iValue)
{
    // Sets addon value on the entity    
    SetEntProp(entity, Prop_Send, "m_iAddonBits", iValue);
}

/**
 * @brief Gets the observer mode of a entity.
 *
 * @param entity            The entity index.
 * @return                  The mode index.
 **/
stock int ToolsGetObserverMode(int entity)
{
    // Gets obs mode on the entity    
    return GetEntProp(entity, Prop_Data, "m_iObserverMode");
}

/**
 * @brief Gets the observer target of a entity.
 *
 * @param entity            The entity index.
 * @return                  The target index.
 **/
stock int ToolsGetObserverTarget(int entity)
{
    // Gets obs mode on the entity    
    return GetEntPropEnt(entity, Prop_Data, "m_hObserverTarget");
}

/**
 * @brief Gets hitgroup value on a entity.
 *
 * @param entity            The entity index.
 * @return                  The hitgroup index.
 **/
stock int ToolsGetHitGroup(int entity)
{
    // Gets hitgroup on the entity    
    return GetEntProp(entity, Prop_Send, "m_LastHitGroup");
}

/**
 * @brief Gets or sets a entity score or deaths.
 * 
 * @param entity            The entity index.
 * @param bScore            True to look at score, false to look at deaths.  
 * @return                  The score or death count of the entity.
 **/
stock int ToolsGetScore(int entity, bool bScore = true)
{
    // If score is true, then return entity score, otherwise return entity deaths
    return GetEntProp(entity, Prop_Data, bScore ? "m_iFrags" : "m_iDeaths");
}

/**
 * @brief Sets a entity score or deaths.
 * 
 * @param entity            The entity index.
 * @param bScore            True to look at score, false to look at deaths.  
 * @param iValue            The score/death amount.
 **/
stock void ToolsSetScore(int entity, bool bScore = true, int iValue = 0)
{
    // If score is true, then set entity score, otherwise set entity deaths
    SetEntProp(entity, Prop_Data, bScore ? "m_iFrags" : "m_iDeaths", iValue);
}

/**
 * @brief Sets the gravity of a entity.
 * 
 * @param entity            The entity index.
 * @param flValue           The gravity amount.
 **/
stock void ToolsSetGravity(int entity, float flValue)
{
    // Sets gravity on the entity
    SetEntPropFloat(entity, Prop_Data, "m_flGravity", flValue);
}

/**
 * @brief Sets the spotting of a entity.
 * 
 * @param entity            The entity index.
 * @param bEnable           Enable or disable an aspect of spotting.
 **/
stock void ToolsSetSpot(int entity, bool bEnable)
{
    // If retrieve if true, then reset variables
    if (!bEnable)
    {
        // Sets value on the entity
        SetEntData(entity, Player_Spotted, false, 1, true);
        SetEntData(entity, Player_SpottedByMask, false, _, true);
        SetEntData(entity, Player_SpottedByMask + 4, false, _, true); /// That is table
        SetEntData(entity, Player_Spotted - 4, 0, _, true);
    }
    else
    {
        // Sets value on the entity
        SetEntData(entity, Player_Spotted - 4, 9, _, true);
    }
}

/**
 * @brief Sets the detecting of a entity.
 * 
 * @param entity            The entity index.
 * @param bEnable           Enable or disable an aspect of detection.
 **/
stock void ToolsSetDetecting(int entity, bool bEnable)
{
    // Sets glow on the entity
    SetEntPropFloat(entity, Prop_Send, "m_flDetectedByEnemySensorTime", bEnable ? (GetGameTime() + 9999.0) : 0.0);
}

/**
 * @brief Sets the hud of a entity.
 * 
 * @param entity            The entity index.
 * @param bEnable           Enable or disable an aspect of hud.
 **/
stock void ToolsSetHud(int entity, bool bEnable)
{   
    // Sets hud type on the entity
    SetEntProp(entity, Prop_Send, "m_iHideHUD", bEnable ? (GetEntProp(entity, Prop_Send, "m_iHideHUD") & ~HIDEHUD_CROSSHAIR) : (GetEntProp(entity, Prop_Send, "m_iHideHUD") | HIDEHUD_CROSSHAIR));
}

/**
 * @brief Sets the arms of a entity.
 * 
 * @param entity            The entity index.
 * @param sModel            The model path.
 **/
stock void ToolsSetArm(int entity, char[] sModel)
{
    // Sets arm on the entity
    SetEntPropString(entity, Prop_Send, "m_szArmsModel", sModel);
}

/**
 * @brief Sets the attack delay of a entity.
 * 
 * @param entity            The entity index.
 * @param flValue           The speed amount.
 **/
stock  void ToolsSetAttack(int entity, float flValue)
{
    // Sets next attack on the entity
    SetEntPropFloat(entity, Prop_Send, "m_flNextAttack", flValue);
}

/**
 * @brief Sets the flashlight of a entity.
 * 
 * @param entity            The entity index.
 * @param bEnable           Enable or disable an aspect of flashlight.
 **/
stock void ToolsSetFlashLight(int entity, bool bEnable)
{
    // Sets flashlight on the entity
    ToolsSetEffect(entity, bEnable ? (ToolsGetEffect(entity) ^ EF_DIMLIGHT) : 0);
}

/**
 * @brief Sets the fov of a entity.
 * 
 * @param entity            The entity index.
 * @param iValue            (Optional) The fov amount.
 **/
stock void ToolsSetFov(int entity, int iValue = 90)
{
    // Sets fov on the entity
    SetEntProp(entity, Prop_Send, "m_iFOV", iValue);
    SetEntProp(entity, Prop_Send, "m_iDefaultFOV", iValue);
}

/**
 * @brief Sets body/skin for the entity.
 *
 * @param entity            The entity index.
 * @param iBody             (Optional) The body index.
 * @param iSkin             (Optional) The skin index.
 **/
stock void ToolsSetTextures(int entity, int iBody = -1, int iSkin = -1)
{
    if (iBody != -1) SetEntProp(entity, Prop_Send, "m_nBody", iBody);
    if (iSkin != -1) SetEntProp(entity, Prop_Send, "m_nSkin", iSkin);
}

/**
 * @brief Gets the effect of an entity.
 * 
 * @param entity            The entity index.
 * @return                  The effect value.
 **/
stock int ToolsGetEffect(int entity)
{
    // Gets effect on the entity    
    return GetEntProp(entity, Prop_Send, "m_fEffects");
}

/**
 * @brief Sets the effect of an entity.
 * 
 * @param entity            The entity index.
 * @param iValue            The effect value.
 **/
stock void ToolsSetEffect(int entity, int iValue)
{
    // Sets effect on the entity
    SetEntProp(entity, Prop_Send, "m_fEffects", iValue);
}

/**
 * @brief Gets the activator of an entity.
 *
 * @param entity            The entity index.
 * @return                  The activator index.
 **/
stock int ToolsGetActivator(int entity)
{
    // Gets activator on the entity
    return GetEntPropEnt(entity, Prop_Data, "m_pActivator");
}

/**
 * @brief Sets the model of an entity.
 * 
 * @param entity            The entity index.
 * @param iModel            The model index.
 **/
stock void ToolsSetModelIndex(int entity, int iModel)
{
    // Sets index on the entity
    SetEntProp(entity, Prop_Send, "m_nModelIndex", iModel);
}

/**
 * @brief Gets the owner of an entity.
 * 
 * @param entity            The entity index.
 * @return                  The owner index.
 **/
stock int ToolsGetOwner(int entity)
{
    // Gets owner on the entity
    return GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
}

/**
 * @brief Sets the owner of an entity.
 * 
 * @param entity            The entity index.
 * @param owner             The owner index.
 **/
stock void ToolsSetOwner(int entity, int owner)
{
    // Sets owner on the entity
    SetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", owner);
}

/**
 * @brief Gets the parent of an entity.
 * 
 * @param entity            The entity index.
 * @return                  The parent index.
 **/
stock int ToolsGetParent(int entity)
{
    // Gets owner on the entity
    return GetEntPropEnt(entity, Prop_Data, "m_pParent");
}

/**
 * @brief Sets the parent of an entity.
 * 
 * @param entity            The entity index.
 * @param parent            The parent index.
 **/
stock void ToolsSetParent(int entity, int parent)
{
    // Sets parent on the entity
    SetEntPropEnt(entity, Prop_Data, "m_pParent", parent);
}

/*_____________________________________________________________________________________________________*/

/**
 * @brief Validate the attachment on the entity.
 *
 * @param entity            The entity index.
 * @param sAttach           The attachment name.
 * @return                  True or false.
 **/
bool ToolsLookupAttachment(int entity, char[] sAttach)
{
	return (hasLength(sAttach) && SDKCall(hSDKCallLookupAttachment, entity, sAttach));
}

/**
 * @brief Gets the attachment of the entity.
 *
 * @param entity            The entity index.
 * @param sAttach           The attachment name.
 * @param vPosition         The origin output.
 * @param vAngle            The angle output.
 **/
void ToolsGetAttachment(int entity, char[] sAttach, float vPosition[3], float vAngle[3])
{
	// Validate windows
	if (gServerData.Platform == OS_Windows)
	{
		SDKCall(hSDKCallGetAttachment, entity, sAttach, vPosition, vAngle); 
	}
	else
	{
		int iAttach = SDKCall(hSDKCallLookupAttachment, entity, sAttach);
		if (iAttach)
		{
			SDKCall(hSDKCallGetAttachment, entity, iAttach, vPosition, vAngle); 
		}
	}
}

/**
 * @brief Gets the sequence of the entity.
 *
 * @param entity            The entity index.
 * @param sAnim             The sequence name.
 * @return                  The sequence index.
 **/
int ToolsLookupSequence(int entity, char[] sAnim)
{
	// Validate windows
	if (gServerData.Platform == OS_Windows)
	{
		return SDKCall(hSDKCallLookupSequence, entity, sAnim); 
	}
	else
	{
		// Gets 'CStudioHdr' class
		Address pStudioHdrClass = ToolsGetStudioHdrClass(entity);
		if (pStudioHdrClass == Address_Null)
		{
			return -1;
		}
		
		return SDKCall(hSDKCallLookupSequence, pStudioHdrClass, sAnim); 
	}
}

/**
 * @brief Gets the pose of the entity.
 *
 * @param entity            The entity index.
 * @param sPose             The pose name.
 * @return                  The pose parameter.
 **/
int ToolsLookupPoseParameter(int entity, char[] sPose)
{
	// Gets 'CStudioHdr' class
	Address pStudioHdrClass = ToolsGetStudioHdrClass(entity);
	if (pStudioHdrClass == Address_Null)
	{
		return -1;
	}
	
	return SDKCall(hSDKCallLookupPoseParameter, entity, pStudioHdrClass, sPose); 
}

/**
 * @brief Resets the sequence of the entity.
 *
 * @param entity            The entity index.
 * @param sAnim             The sequence name.
 **/
void ToolsResetSequence(int entity, char[] sAnim) 
{ 
	// Find the sequence index
	int iSequence = ToolsLookupSequence(entity, sAnim); 
	if (iSequence < 0) 
	{
		return; 
	}
	
	// Tracker 17868: If the sequence number didn't actually change, but you call resetsequence info, it changes
	// the newsequenceparity bit which causes the client to call m_flCycle.Resets() which causes a very slight 
	// discontinuity in looping animations as they reset around to cycle 0.0. This was causing the parentattached
	// helmet on barney to hitch every time barney's idle cycled back around to its start.
	SDKCall(hSDKCallResetSequence, entity, iSequence);
}

/**
 * @brief Gets the total sequence amount.
 *
 * @note The game has two methods for getting the sequence count:
 * 
 * 1. Local sequence count if the model has sequences built in the model itself.
 * 2. Virtual model sequence count if the model inherits the sequences from a different model, also known as an include model.
 *
 * @param entity            The entity index.
 * @return                  The sequence count.
 **/
int ToolsGetSequenceCount(int entity)
{
	// Gets 'CStudioHdr' class
	Address pStudioHdrClass = ToolsGetStudioHdrClass(entity);
	if (pStudioHdrClass == Address_Null)
	{
		return -1;
	}
	
	// Gets 'studiohdr_t' class
	Address pStudioHdrStruct = view_as<Address>(LoadFromAddress(pStudioHdrClass + view_as<Address>(StudioHdrClass_StudioHdrStruct), NumberType_Int32));
	if (pStudioHdrStruct != Address_Null)
	{
		int localSequenceCount = LoadFromAddress(pStudioHdrStruct + view_as<Address>(StudioHdrStruct_SequenceCount), NumberType_Int32);
		if (localSequenceCount)
		{
			return localSequenceCount;
		}
	}
	
	// Gets 'virtualmodel_t' class
	Address pVirtualModelStruct = view_as<Address>(LoadFromAddress(pStudioHdrClass + view_as<Address>(StudioHdrClass_VirualModelStruct), NumberType_Int32));
	if (pVirtualModelStruct != Address_Null)
	{
		return LoadFromAddress(pVirtualModelStruct + view_as<Address>(VirtualModelStruct_SequenceVector_Size), NumberType_Int32);
	}
	
	// Return on unsuccess 
	return -1;
}

/**
 * @brief Gets the activity of a sequence.
 *
 * @param entity            The entity index.
 * @param iSequence         The sequence index.
 * @return                  The activity index.
 **/
int ToolsGetSequenceActivity(int entity, int iSequence)
{
	return SDKCall(hSDKCallGetSequenceActivity, entity, iSequence);
}

/**
 * @brief Gets the hdr class address.
 * 
 * @param entity            The entity index.
 * @return                  The address of the hdr.    
 **/
Address ToolsGetStudioHdrClass(int entity)
{
	return view_as<Address>(GetEntData(entity, Animating_StudioHdr));
}

/**
 * @brief Update a entity transmit state.
 * 
 * @param entity            The entity index.
 **/
void ToolsUpdateTransmitState(int entity)
{
	SDKCall(hSDKCallUpdateTransmitState, entity);
}

/**
 * @brief Checks that the entity is a brush.
 * 
 * @param entity            The entity index.
 **/
bool ToolsIsBSPModel(int entity)
{
	return SDKCall(hSDKCallIsBSPModel, entity);
}

/**
 * @brief Emulate bullet_shot on the server and does the damage calculations.
 *
 * @param client            The client index.
 * @param weapon            The weapon index.
 * @param vPosition         The position to the spawn.
 * @param vAngle            The angle to the spawn.
 * @param iMode             The mode index.
 * @param iSeed             The randomizing seed.
 * @param flInaccuracy      The inaccuracy variable.
 * @param flSpread          The spread variable.
 * @param flFishTail        The fishtail variable.
 * @param iSoundType        The sound type.
 * @param flRecoilIndex     The recoil variable.
 **/
void ToolsFireBullets(int client, int weapon, float vPosition[3], float vAngle[3], int iMode, int iSeed, float flInaccuracy, float flSpread, float flFishTail, int iSoundType, float flRecoilIndex)
{
	// Create a bullet decal
	TE_Start("Shotgun Shot");
	TE_WriteVector("m_vecOrigin", vPosition);
	TE_WriteFloat("m_vecAngles[0]", vAngle[0]);
	TE_WriteFloat("m_vecAngles[1]", vAngle[1]);
	TE_WriteNum("m_weapon", GetEntProp(weapon, Prop_Send, "m_Item"));
	TE_WriteNum("m_iMode", iMode);
	TE_WriteNum("m_iSeed", iSeed);
	TE_WriteNum("m_iPlayer", client - 1);
	TE_WriteFloat("m_fInaccuracy", flInaccuracy);
	TE_WriteFloat("m_fSpread", flSpread);
	TE_WriteNum("m_iSoundType", 12); /// silenced
	TE_WriteFloat("m_flRecoilIndex", flRecoilIndex);
	TE_WriteNum("m_nItemDefIndex", GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex"));
	TE_SendToAll();

	// Disable the lag compensation and store the status
	bool bLock = view_as<bool>(GetEntProp(client, Prop_Data, "m_bLagCompensation"));
	SetEntProp(client, Prop_Data, "m_bLagCompensation", false);
	
	// Validate windows
	if (gServerData.Platform == OS_Windows)
	{
		// Write a new function in free memory and call it
		memcpy(pFireBullets, ASMTRAMPOLINE, sizeof(ASMTRAMPOLINE));
	}
	
	// Emulate bullet_shot on the server
	SDKCall(hSDKCallFireBullets, client, weapon, 0/*CEconItemView*/, vPosition, vAngle, iMode, iSeed, flInaccuracy, flSpread, flFishTail, 0.0, iSoundType, flRecoilIndex);
	
	// Reset the lag compensation back
	SetEntProp(client, Prop_Data, "m_bLagCompensation", bLock);
}

/**
 * @brief Sets the player progress bar.
 *
 * @param client            The client index.
 * @param iDuration         The duration in the seconds.
 **/
void ToolsSetProgressBarTime(int client, int iDuration)
{
	// Gets the current time
	float flGameTime = GetGameTime();
	
	// Sets the bar for the client
	SetEntData(client, Player_ProgressBarDuration, iDuration, 4, true);
	SetEntDataFloat(client, Player_ProgressBarStartTime, flGameTime, true);
	SetEntDataFloat(client, Entity_SimulationTime, flGameTime + float(iDuration), true);
	
	// Progress bar type 0-15
	SetEntData(client, Player_BlockingUseActionInProgress, 0, 4, true);
}

/**
 * @brief Sets the player progress bar.
 *
 * @param client            The client index.
 * @param iDuration         The duration in the seconds.
 **/
void ToolsResetProgressBarTime(int client)
{
	// Resets the progress bar
	SetEntDataFloat(client, Player_ProgressBarStartTime, 0.0, true);
	SetEntData(client, Player_ProgressBarDuration, 0, 1, true);
}