//
// Database accounts & login
//

//temporal
ArrayList users;
ArrayList passwords;
ArrayList characterNames;

//Temporal
ArrayList charactersNames[MAXPLAYERS+1];
ArrayList charactersLevels[MAXPLAYERS+1];
ArrayList charactersResets[MAXPLAYERS+1];
ArrayList charactersAccessLevels[MAXPLAYERS+1];
int numCharacters[MAXPLAYERS+1];

//=====================================================
//				SQL MAIN DATA MANAGEMENT
//=====================================================
/*public void registerPlayer(int client){
	
	if(gServerData.DBI == null) ConnectToDatabase();
	
	int steam_id = GetSteamAccountID(client);
	
	static char metaMail[32];
	static char metaPass[32];
	static char mail[64];
	static char pass[64];
	static char query[128];
	
	users.GetString(client, metaMail, sizeof(metaMail));
	passwords.GetString(client, metaPass, sizeof(metaPass));
	
	gServerData.DBI.Escape(metaMail, mail, sizeof(mail));
	gServerData.DBI.Escape(metaPass, pass, sizeof(pass));
	
	if (isEntryValidToSQL(mail, DATA_MAIL) != INPUT_OK){
		PrintToServer("[REGISTER] Not valid email address(%s).", mail);
		TranslationPrintToChat(client, "Not valid email address");
		showLoginMenu(client, false);
		return;
	}
	
	FormatEx(query, sizeof(query), "INSERT INTO Players(email, contrasenia, steamid) VALUES('%s', '%s', %d)", mail, pass, steam_id);
	gServerData.DBI.Query(RegisterPlayerCallback, query, client);
}
public void RegisterPlayerCallback(Database db, DBResultSet results, const char[] error, any data){
	
	int client = 0;

	//Make sure the client didn't disconnect while the thread was running
	if ((client = GetClientOfUserId(data)) == 0){
		return;
	}
	
	static char mail[32], pass[32], user[32];
	
	users.GetString(client, mail, sizeof(mail));
	passwords.GetString(client, pass, sizeof(pass));
	
	if(StrEqual(error, "")){
		TranslationPrintToChat(client, "Successfully registered", mail, pass);
	}else{
		if(StrContains(error, "email_UNIQUE") != -1){
			PrintToChat(client, "%s El mail \x0b%s\x01 ya esta en uso.", SERVERSTRING, mail);
		}else{
			GetClientName(client, user, sizeof(user));
			LogError("[REGISTER] error: %s", error);
			PrintToChatAll("%s El usuario \x0b%s\x01 esta intentando registrarse pero no puede, por favor informar al staff.", SERVERSTRING, user);
			
		}
		TranslationPrintToChat(client, "Not registered");
	}
	showLoginMenu(client, false);
}*/

public Action loginPlayer(int client){
	
	if(gServerData.DBI == null)
		return;
	
	int steam_id = GetSteamAccountID(client);
	
	int userid = GetClientUserId(client);
	
	static char query[255];
	FormatEx(query, sizeof(query), "SELECT P.steamid, P.contrasenia, P.email, P.blockAccess, P.piupoints FROM %s P WHERE P.steamid=%d", DATABASE_MAIN, steam_id);
	LogToFile("addons/sourcemod/logs/SQL_LOG.txt", query);
	gServerData.DBI.Query(loginPlayerCallback, query, userid, DBPrio_High);
}
public void loginPlayerCallback(Database db, DBResultSet results, const char[] error, any data){
	
	int client = 0;
	
	/* Make sure the client didn't disconnect while the thread was running */
	if ((client = GetClientOfUserId(data)) == 0){
		return;
	}
	
	if (!IsPlayerExist(client))
		return;
	
	if(results == null){
		PrintToServer("[LOGIN] %s", error);
		return;
	}
	
	ZPlayer player = ZPlayer(client);
	int steam_id = GetSteamAccountID(client);
	
	if(!results.RowCount){
		TranslationPrintToChat(client, "No user associated");
		showLoginMenu2(client);
		//showLoginMenu(client, true);
		return;
	}
	
	bool isBanned = false;
	static char szData[32];
	DBResult result;
	
	while(results.FetchRow()){
		results.FetchString(1, szData, sizeof(szData), result);
		player.bHasPassword = (result == DBVal_Data);
			
		results.FetchString(2, szData, sizeof(szData), result);
		player.bHasMail = (result == DBVal_Data);
		
		isBanned = view_as<bool>(results.FetchInt(3));
		
		player.iPiuPoints = results.FetchInt(4);
	}
	
	static char lastLogin[192];
	
	static char clientIP[64];
	GetClientIP(client, clientIP, sizeof(clientIP));
	
	// Update last login
	FormatEx(lastLogin, sizeof(lastLogin), "UPDATE %s SET lastLogin = CURRENT_TIMESTAMP(), lastIP =\'%s\' WHERE steamid = %d", DATABASE_MAIN, clientIP, steam_id);
	gServerData.DBI.Query(DoNothingCallback, lastLogin, client, DBPrio_Low);
	
	if (isBanned){
		TranslationPrintToChat(client, "Blocked account");
		infoDiscord(client, 0);
		CreateTimer(10.0, TimedKickPlayer, client);
		return;
	}
	
	// Welcome message
	static char name[32];
	GetClientName(client, name, sizeof(name));
	TranslationPrintToChat(client, "Welcome again", name);
	
	// Log it OK
	LogToFile("addons/sourcemod/logs/SQL_LOG.txt", "Login playerCallback OK");
	
	player.bLogged = true;
	
	loadCharacters(client);
}
public void DoNothingCallback(Database db, DBResultSet results, const char[] error, any data){
	//Aca no hay que hacer un choto xd
	if(!StrEqual(error, "")){
		LogToFile("addons/sourcemod/logs/SQL_DoNothingCallback.txt", "[DONOTHINGCALLBACK] %s", error);
	}
}

public Action TimedKickPlayer(Handle hTimer, int client){
	
	if (!IsPlayerExist(client))
		return Plugin_Stop;
		
	KickClient(client, "[PIU] Tu cuenta está bloqueada, comunicate a nuestro discord");
	
	return Plugin_Stop;
}

public Action loadCharacters(int client){
	
	if(gServerData.DBI == null)
		return;
	
	int steam_id = GetSteamAccountID(client);
	
	int userid = GetClientUserId(client);
	
	char query[255];
	FormatEx(query, sizeof(query), "SELECT c.id, c.nombre, c.level, c.reset, c.accesslevel FROM %s p RIGHT JOIN Characters c ON (p.id = c.idPlayer) WHERE p.steamid = %d", DATABASE_MAIN, steam_id);
	gServerData.DBI.Query(loadCharactersCallback, query, userid, DBPrio_High);
	
	LogToFile("addons/sourcemod/logs/SQL_LOG.txt", query);
}
public void loadCharactersCallback(Database db, DBResultSet results, const char[] error, any data){
	int client = 0;
	
	/* Make sure the client didn't disconnect while the thread was running */
	if ((client = GetClientOfUserId(data)) == 0){
		return; 
	}
	
	if(results == null){
		PrintToServer("[LOAD-CHARACTERS] %s", error);
		return;
	}
	
	if(!results.RowCount){
		showMenuCuenta(client);
		return;
	}
	
	char name[32];
	int level;
	int reset;
	int accessLevel;
	int id;
	int pjs;
	
	ZPlayer player = ZPlayer(client);
	
	for (int i; i < MAXCHARACTERS_LEGACY; i++){
		if (results.FetchRow()){
			id = results.FetchInt(0);
			results.FetchString(1, name, sizeof(name));
			level = results.FetchInt(2);
			reset = results.FetchInt(3);
			accessLevel = results.FetchInt(4);
			charactersNames[client].SetString(i, name);
			charactersLevels[client].Set(i, level);
			charactersResets[client].Set(i, reset);
			charactersAccessLevels[client].Set(i, accessLevel);
			player.setIdPjInSlot(i, id);
			player.setSlotEmpty(i, false);
			pjs++;
		}
	}
	
	/*
	while(results.FetchRow()){
		id = results.FetchInt(0);
		results.FetchString(1, name, sizeof(name));
		level = results.FetchInt(2);
		reset = results.FetchInt(3);
		accessLevel = results.FetchInt(4);
		charactersNames[client].SetString(i, name);
		charactersLevels[client].Set(i, level);
		charactersResets[client].Set(i, reset);
		charactersAccessLevels[client].Set(i, accessLevel);
		player.setIdPjInSlot(i, id);
		player.setSlotEmpty(i, false);
		i++;
	}*/
	
	numCharacters[client] = pjs;
	showMenuCuenta(client);
	
	LogToFile("addons/sourcemod/logs/SQL_LOG.txt", "LoadCharactersCallback OK");
}

//============================================
// 				DB FUNCS
//============================================
public void associateRefeerCode(int client){
		
	if(gServerData.DBI == null) return;
	
	char query[256], code[9];
	GenerateUniqueCode(code, sizeof(code));
	
	ZPlayer player = ZPlayer(client);
	player.setRefeerCode(code);
	
	//PrintToChat(client, "%s Your code is %s", SERVERSTRING, code);
	
	FormatEx(query, sizeof(query), "UPDATE characters SET refeerCode = \'%s\' WHERE id=%d", code, player.iPjSeleccionado);
	gServerData.DBI.Query(associateRefeerCodeCallback, query, client, DBPrio_Low);
}
public void associateRefeerCodeCallback(Database db, DBResultSet results, const char[] error, any data){
	
	if(!StrEqual(error, "")){
		associateRefeerCode(data);
	}
}

/////////////////////////
public void readPendingPiuPoints(int client){
	
	if(gServerData.DBI == null){
		return;
	}
	
	if (!IsPlayerExist(client)){
		return;
	}
	
	if (!ZPlayer(client).bLogged){
		return;
	}
	
	if (IsFakeClient(client)){
		return;
	}
	
	char query[128];
	
	int steam_id = gClientData[client].iSteamAccountID;
	FormatEx(query, sizeof(query), "SELECT `pendingPiuPoints` FROM `players` WHERE `steamid` = %d;", steam_id);
	
	int userid = GetClientUserId(client);
	gServerData.DBI.Query(readPendingPiuPointsCallback, query, userid, DBPrio_High);
}
public void readPendingPiuPointsCallback(Database db, DBResultSet results, const char[] error, any data){
	
	int client = data;
	
	/* Make sure the client didn't disconnect while the thread was running */
	if ((client = GetClientOfUserId(data)) == 0) {
		return;
	}
	
	if(results == null) {
		PrintToServer("[PIUPOINTS-UPDATER] %s", error);
		return;
	}
	
	if(!results.RowCount){
		PrintToServer("COULD NOT READ PP");
		return;
	}
	
	if (results.FetchRow()){
		int updatablePoints = results.FetchInt(0);
		
		if (updatablePoints == 0){
			return;
		}
		
		LogToFile("/addons/sourcemod/logs/PP_UPDATER.txt", "[PIUPOINTS-UPDATER] Found %d PIU POINTS pending to update on player %N", updatablePoints, client);
		gClientData[client].iPiuPoints += updatablePoints;
		
		char query[128];
		int steam_id = gClientData[client].iSteamAccountID;
		FormatEx(query, sizeof(query), "UPDATE `players` SET `pendingPiuPoints` = 0 WHERE `steamid` = %d;", steam_id);
		gServerData.DBI.Query(DoNothingCallback, query, client, DBPrio_Low);
		
		// Update piu points in db
		UpdatePiuPoints(client, gClientData[client].iPiuPoints);
		
		if (updatablePoints){
			PrintToChat(client, "%s Encontramos \x04%d PIU-POINTS\x01 pendientes de activación, ¡que los disfrutes!", SERVERSTRING, updatablePoints);
		}
	}
}