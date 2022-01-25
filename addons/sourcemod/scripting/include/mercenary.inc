//
// Mercenary
//

#if defined _mercenary_included
	#endinput
#endif
#define _mercenary_included

// Mercenary
#define NPC_MAX_DISTANCE 	120.0
#define NPC_MAX_DISTANCE_SQUARED 	NPC_MAX_DISTANCE*NPC_MAX_DISTANCE
#define	NPC_CLASSNAME 		"Mercenary"
#define NPC_DEFAULT_ANIM 	"grenade_near_fire"
#define	NPC_MODEL 			"models/player/custom_player/kuristaja/cso2/sas/sas2.mdl"

public void MercenaryOnInit(){
	
	// NPC shit
	RegAdminCmd("npc", CreateMercenary, ADMFLAG_ROOT);
	RegAdminCmd("deletenpc", DeleteMercenary, ADMFLAG_ROOT);
	//RegConsoleCmd("sequence", ChangeAnimation);
	RegAdminCmd("savelocation", SaveNpcLocation, ADMFLAG_ROOT);
	//RegConsoleCmd("readlocation", ReadLocations);
}

Action MercenaryOnRunCmd(int client, int &buttons){
	if (buttons & IN_USE){
		int targetIndex = GetClientAimTarget(client, false);
		
		if (!IsValidEdict(targetIndex))
			return Plugin_Continue;
		
		static char sClassname[32];
		float entVec[3], userVec[3];
		GetEdictClassname(targetIndex, sClassname, sizeof(sClassname));
		GetEntPropVector(targetIndex, Prop_Send, "m_vecOrigin", entVec);
		GetClientAbsOrigin(client, userVec);
		
		if (!StrEqual(sClassname, NPC_CLASSNAME))
			return Plugin_Continue;
		
		if (GetVectorDistance(entVec, userVec, true) <= NPC_MAX_DISTANCE_SQUARED)
			showMenuMercenary(client);
	}
	
	return Plugin_Continue;
}

// Dispatch mercenary based on kv file
public Action SaveNpcLocation(int client, int args){
	
	ZPlayer player = ZPlayer(client);
	if(!player.bStaff){
		return Plugin_Handled;
	}
	
	float pos[3];
	int targetIndex = GetClientAimTarget(client, false);
	
	if (!IsValidEntity(targetIndex))
		return Plugin_Handled;
	
	static char sClassname[16];
	GetEdictClassname(targetIndex, sClassname, sizeof(sClassname));
	
	if (!StrEqual(sClassname, NPC_CLASSNAME))
		return Plugin_Handled;
	
	KeyValues MyKv = CreateKeyValues("spawn");
	
	// Read file if it exist
	MyKv.ImportFromFile("mercenaryspawn.txt");
	
	char buffer[PLATFORM_MAX_PATH];
	GetCurrentMap(buffer, sizeof(buffer));
	
	GetEntPropVector(targetIndex, Prop_Send, "m_vecOrigin", pos);
	
	// Create "mapname" section
	MyKv.JumpToKey(buffer, true);
	
	int count;
	
	// If "mapname" section have previous savings, coordinates
	if(MyKv.GotoFirstSubKey(false)){
		// do count how many savings under mapname section
		do
		{
			count++;
		}
		while(MyKv.GotoNextKey(false));
		
		// remember go back to "mapname" section root
		MyKv.GoBack();
	}
	
	ReplyToCommand(client, "\n");
	ReplyToCommand(client, buffer);
	
	// save new coordinate into "mapname" section
	FormatEx(buffer, sizeof(buffer), "%i", count);
	MyKv.SetVector(buffer, pos);
	
	ReplyToCommand(client, "Saved position %i %f %f %f", count, pos[0], pos[1], pos[2]);
	
	// go top of keyvalue structure
	MyKv.Rewind();
	
	// save file
	MyKv.ExportToFile("mercenaryspawn.txt");
	delete MyKv;
	return Plugin_Handled;
}
stock Action ReadLocations(int client, int args){
	
	ZPlayer player = ZPlayer(client);
	if(!player.bStaff){
		return Plugin_Handled;
	}
	
	KeyValues MyKv = CreateKeyValues("spawn");
	// Read file if it exist
	MyKv.ImportFromFile("mapconfigs.txt");
	
	char buffer[PLATFORM_MAX_PATH];
	GetCurrentMap(buffer, sizeof(buffer));
	
	float pos[3];
	
	// "mapname" section not found
	if(!MyKv.JumpToKey(buffer, false)){
		ReplyToCommand(client, "No records in \"%s\" section", buffer);
		delete MyKv;
		return Plugin_Handled;
	}
	
	ReplyToCommand(client, "\n");
	ReplyToCommand(client, buffer);
	
	// If "mapname" section have previous savings, coordinates
	if(MyKv.GotoFirstSubKey(false)){
		
		// do count how many savings under mapname section
		do{
			MyKv.GetSectionName(buffer, sizeof(buffer));
			MyKv.GetVector(NULL_STRING, pos, NULL_VECTOR);
			Format(buffer, sizeof(buffer), "%20s %f %f %f", buffer, pos[0], pos[1], pos[2]);
			ReplyToCommand(client, buffer);
		}
		while(MyKv.GotoNextKey(false));
		
		// remember go back to "mapname" section root
		MyKv.GoBack();
	}
	delete MyKv;
	return Plugin_Handled;
}

// Locate mercenary on round start
public void LocateMercenary(){
	KeyValues MyKv = CreateKeyValues("spawn");
	// Read file if it exist
	MyKv.ImportFromFile("mercenaryspawn.txt");
	
	char buffer[PLATFORM_MAX_PATH];
	GetCurrentMap(buffer, sizeof(buffer));
	
	float pos[3];
	
	// "mapname" section not found
	if(!MyKv.JumpToKey(buffer, false)){
		PrintToServer("No records in \"%s\" section", buffer);
		delete MyKv;
		return;
	}
	PrintToServer("\n");
	PrintToServer("%s", buffer);
	
	// If "mapname" section have previous savings, coordinates
	if(MyKv.GotoFirstSubKey(false)){
		
		// do count how many savings under mapname section
		do
		{
			MyKv.GetSectionName(buffer, sizeof(buffer));
			MyKv.GetVector(NULL_STRING, pos, NULL_VECTOR);
			/*Format(buffer, sizeof(buffer), "%20s %f %f %f", buffer, pos[0], pos[1], pos[2]);
			ReplyToCommand(client, buffer);*/
			DispatchMercenary(pos);
			
		}
		while(MyKv.GotoNextKey(false));
		
		// remember go back to "mapname" section root
		MyKv.GoBack();
	}
	delete MyKv;
}

//=====================================================
//				MERCENARY FUNCS
//=====================================================
public Action CreateMercenary(int client, int args){
	
	ZPlayer player = ZPlayer(client);
	
	if (!player.bStaff)
		return Plugin_Handled;
	
	// Move entity to origins
	float vector[3];
	GetAimCoords(client, vector);
	
	DispatchMercenary(vector);
	
	return Plugin_Handled;
}
public void DispatchMercenary(float vector[3]){
	int entity = CreateEntityByName("prop_dynamic_glow");
	
	if (IsValidEntity(entity)){
		// Move entity to origins
		TeleportEntity(entity, vector, NULL_VECTOR, NULL_VECTOR);
		
		DispatchKeyValue(entity, "Classname", NPC_CLASSNAME); // used to detect while users aim and press E
		DispatchKeyValue(entity, "model", NPC_MODEL);
		DispatchKeyValue(entity, "Solid", "6");
		DispatchKeyValue(entity, "RandomAnimation", "0");
		DispatchKeyValue(entity, "DefaultAnim", NPC_DEFAULT_ANIM);
		/*DispatchKeyValueFloat(entity, "MinAnimTime", 200.0);
		DispatchKeyValueFloat(entity, "MaxAnimTime", 200.0);
		DispatchKeyValue(entity, "SetGlowEnabled", "1");*/
		
		DispatchSpawn(entity);
		ActivateEntity(entity);
		
		SetEntProp(entity, Prop_Send, "m_bShouldGlow", true, true);
		SetEntPropFloat(entity, Prop_Send, "m_flGlowMaxDist", 10000.0);
		SetGlowColor(entity, "255 255 255");
		
		/*SetVariantString("Death1");
		AcceptEntityInput(entity, "Enable");*/
	}
}
public Action DeleteMercenary(int client, int args){
	
	ZPlayer player = ZPlayer(client);
	
	if (!player.bStaff)
	return Plugin_Handled;
	
	int targetIndex = GetClientAimTarget(client, false);
	
	if (!IsValidEdict(targetIndex))
	return Plugin_Continue;
	
	// Mejor manejo de entidades por referencias
	int targetRef = EntIndexToEntRef(targetIndex);
	
	static char sClassname[32];
	GetEdictClassname(targetRef, sClassname, sizeof(sClassname));
	if (strcmp(sClassname, NPC_CLASSNAME) == 0){
		//AcceptEntityInput(targetRef, "Kill");
		RemoveEntity(targetRef);
	}
	
	return Plugin_Handled;
}
public Action ChangeAnimation(int client, int args){
	
	ZPlayer player = ZPlayer(client);
	
	if (!player.bStaff)
		return Plugin_Handled;
	
	int targetIndex = GetClientAimTarget(client, false);
	char sArg[16];
	GetCmdArg(args, sArg, sizeof(sArg));
	int iSequence = StringToInt(sArg);
	
	if (!IsValidEdict(targetIndex))
		return Plugin_Continue;
	
	char sClassname[32];
	GetEdictClassname(targetIndex, sClassname, sizeof(sClassname));
	if (strcmp(sClassname, NPC_CLASSNAME) == 0)
	{
		SetEntProp(targetIndex, Prop_Send, "m_flAnimTime", 1);
		SetEntProp(targetIndex, Prop_Send, "m_nSequence", iSequence);
		//SetEntProp(targetRef, Prop_Data, "m_bHoldAnimation", true);
		//DispatchKeyValue(targetRef, "RandomAnimation", "On");
		SetEntityRenderColor(targetIndex, 255, 255, 255, 64);
		
		PrintToChat(client, "NPC Sequence changed to: %s", sArg);
	}
	return Plugin_Handled;
}