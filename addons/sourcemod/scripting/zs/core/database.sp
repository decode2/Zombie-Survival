#if defined _database_included
 #endinput
#endif
#define _database_included

/**
 * @section Properties of the database.
 **/ 
#define DATABASE_SECTION 		"zpdb"
#define DATABASE_MAIN 			"players"
#define DATABASE_CHARACTERS 	"characters"
#define DATABASE_RENAMES 		"characters_renames"

/**
 * @section Database column types.
 **/
enum ColumnType{
	ColumnType_ID,
	ColumnType_AccountID,
	ColumnType_Name,
	ColumnType_Exp,
	ColumnType_Level,
	ColumnType_Reset,
	ColumnType_ExpBoost,
	ColumnType_HClass,
	ColumnType_ZClass,
	ColumnType_HumanPoints,
	ColumnType_HumanGoldenPoints,
	ColumnType_ZombiePoints,
	ColumnType_ZombieGoldenPoints,
	ColumnType_LasermineHP,
	ColumnType_CritChance,
	ColumnType_ItemChance,
	ColumnType_AuraTime,
	ColumnType_MadnessTime,
	ColumnType_DamageToLM,
	ColumnType_Leech,
	ColumnType_MadnessChance,
	ColumnType_HumanDamageLevel,
	ColumnType_HumanResistanceLevel,
	ColumnType_HumanDexterityLevel,
	ColumnType_ZombieDamageLevel,
	ColumnType_ZombieDexterityLevel,
	ColumnType_ZombieHealthLevel,
	ColumnType_PrimarySelected,
	ColumnType_SecondarySelected,
	ColumnType_PartyInvites,
	ColumnType_AutoClasses,
	ColumnType_AutoWeapons,
	ColumnType_AutoGrenades,
	ColumnType_MuteBullets,
	ColumnType_HumanAlignment,
	ColumnType_ZombieAlignment,
	ColumnType_GrenadePack,
	ColumnType_HudColor,
	ColumnType_NvgColor,
	ColumnType_Tag,
	ColumnType_Hat,
	ColumnType_HatPoints,
	ColumnType_AccessLevel,
	ColumnType_RefeerCode,
	
	ColumnType_PiuPoints,
	//ColumnType_Time,
	ColumnType_Default
};
/**
 * @endsection
 **/
 
/**
 * @section Database transaction types.
 **/ 
enum TransactionType{
	TransactionType_Create,
	TransactionType_Load,
	TransactionType_Unload,
	TransactionType_Describe,
	TransactionType_Info
}
/**
 * @endsection
 **/
 
/**
 * @section Database factories types.
 **/ 
enum FactoryType{
	FactoryType_Create,
	FactoryType_Drop,
	FactoryType_Dump,
	FactoryType_Keys,
	FactoryType_Parent,
	FactoryType_Add,
	FactoryType_Remove,
	FactoryType_Select,
	FactoryType_Update,
	FactoryType_Insert,
	FactoryType_Delete
}

// On plugin init
stock void DataBaseOnInit(){
	
	// If database exists
	if (gServerData.DBI != null){
		
		// Save data
		DataBaseOnUnload();
		
		// Unhook commands
		RemoveCommandListener2(DataBaseOnCommandListened, "exit");
		RemoveCommandListener2(DataBaseOnCommandListened, "quit");
		RemoveCommandListener2(DataBaseOnCommandListened, "restart");
		RemoveCommandListener2(DataBaseOnCommandListened, "_restart");
		
		// Close connection
		CleanConnections();
	}
	
	Database.Connect(SQLBaseConnect_Callback, DATABASE_SECTION, false);
	
	// Validate loaded map
	if (gServerData.MapLoaded){
		
		//!! Get all data !!//
		DataBaseOnLoad();
	}
	
	// Database hooks to prevent data loss
	AddCommandListener(DataBaseOnCommandListened, "exit");
	AddCommandListener(DataBaseOnCommandListened, "quit");
	AddCommandListener(DataBaseOnCommandListened, "restart");
	AddCommandListener(DataBaseOnCommandListened, "_restart");
}

/*
 * Callbacks SQL functions.
 */

/**
 * SQL: DROP, CREATE
 * @brief Callback for receiving asynchronous database connection.
 *
 * @param hDatabase         Handle to the database connection.
 * @param sError            Error string if there was an error.
 * @param bDropping         Data passed in via the original threaded invocation.
 **/
public void SQLBaseConnect_Callback(Database hDatabase, char[] sError, bool bDropping){
	
	// If invalid query handle, then log error
	if (hDatabase == null || hasLength(sError)){
		
		// Unexpected error, log it
		LogError("[MYSQL DB] DATABASE CONNECTION ERROR: %s", sError);
	}
	else{
		
		// Validate a global database handler
		if (gServerData.DBI != null){
			
			// Validate a new database is the same connection as old database
			if (hDatabase.IsSameConnection(gServerData.DBI)){
				return;
			}
			
			// Close database
			delete gServerData.DBI;
		}

		// Store into a global database handler
		gServerData.DBI = hDatabase;
		
		if(!gServerData.DBI.SetCharset("utf8mb4")){
			gServerData.DBI.SetCharset("utf8");
		}
		else{
			PrintToServer("[MYSQL DB] Charset to utf8mb4");
		}
		
		//////////////////////////////////////////////////
		//		THESE ARE DATABASE DEPENDANT
		//////////////////////////////////////////////////
		
		// SQL stored data must be loaded every map start
		
		// Load hats
		HatsOnUpdate(gServerData.DBI);
		
		// Load tags & hats
		TagsOnUpdate(gServerData.DBI);
		
		// Load hclasses
		HClassesOnUpdate(gServerData.DBI);
		
		// Load zclasses
		ZClassesOnUpdate(gServerData.DBI);
		
		////////////////////////////////////////////////// 
	}
}

/**
 * @brief Callback for a failed transaction.
 * 
 * @param hDatabase         Handle to the database connection.
 * @param mTransaction      Data passed in via the original threaded invocation.
 * @param numQueries        Number of queries executed in the transaction.
 * @param sError            Error string if there was an error.
 * @param iFail             Index of the query that failed, or -1 if something else.
 * @param client            An array of each data value passed.
 **/
public void SQLTxnFailure_Callback(Database hDatabase, TransactionType mTransaction, int numQueries, char[] sError, int iFail, int[] client){
	
	// If invalid query handle, then log error
	if (hDatabase == null || hasLength(sError)){
		
		// Unexpected error, log it
		LogError("[MYSQL DB] ID: \"%d\" - \"%s\"", iFail, sError);
	}
}

public void DataBaseOnSaveAllData(){
	
	for (int i = 1; i <= MaxClients; i++){
		saveCharacterData(i);
	}
}

public void DataBaseOnPluginEnd(){
	
	// Save data	
	DataBaseOnUnload();
}

public Action DataBaseOnCommandListened(int entity, char[] commandMsg, int iArguments){
	
	// Validate server
	if (!entity){
		// Switches server commands
		switch (commandMsg[0]){
			
			// Exit/disabling/restart server
			case 'e', 'q', 'r', '_':{
				//!! Store all current data !!//
				DataBaseOnUnload();
			}
		}
	}
	
	// Allow commands
	return Plugin_Continue;
}


void DataBaseOnUnload(/*void*/){
	
	// If database doesn't exist, then stop
	if(gServerData.DBI == null){
		return;
	}

	// Initialize request char
	static char sRequest[1920];

	// Creates a new transaction object
	Transaction hTxn = new Transaction();
	
	// i = client index
	for (int i = 1; i <= MaxClients; i++){
		
		
		// If client wasn't loaded, then skip
		if (!gClientData[i].bLogged){
			continue;
		}
		
		if (!gClientData[i].bLoaded){
			continue;
		}
		
		if (IsFakeClient(i)){
			continue;
		}
	
		// Generate request
		SQLBaseFactory__(sRequest, sizeof(sRequest), ColumnType_Default, FactoryType_Update, i);
		
		// Adds a query to the transaction
		hTxn.AddQuery(sRequest, i);
		
		// Generate request
		SQLBaseFactory__(sRequest, sizeof(sRequest), ColumnType_PiuPoints, FactoryType_Update, i);
		
		// Adds a query to the transaction
		hTxn.AddQuery(sRequest, i);
	}

	// Sent a transaction
	gServerData.DBI.Execute(hTxn, INVALID_FUNCTION, INVALID_FUNCTION, TransactionType_Unload, DBPrio_High);
}

void DataBaseOnLoad(/*void*/){
	
	// If database doesn't exist, then stop
	if(gServerData.DBI == null){
		return;
	}

	// Initialize request char
	static char sRequest[1920];

	// Creates a new transaction object
	Transaction hTxn = new Transaction();
	
	// i = client index
	for (int i = 1; i <= MaxClients; i++){
		
		
		// If client wasn't loaded, then skip
		if (gClientData[i].bLogged){
			continue;
		}
		
		if (gClientData[i].bLoaded){
			continue;
		}
		
		if (IsFakeClient(i)){
			continue;
		}
		
		if (!IsPlayerExist(i, false)){
			continue;
		}
	
		// Generate request
		SQLBaseFactory__(sRequest, sizeof(sRequest), ColumnType_Default, FactoryType_Select, i);
		
		// Adds a query to the transaction
		hTxn.AddQuery(sRequest, i);
		
		// Generate request
		/*SQLBaseFactory__(sRequest, sizeof(sRequest), ColumnType_PiuPoints, FactoryType_Select, i);
		
		// Adds a query to the transaction
		hTxn.AddQuery(sRequest, i);*/
	}

	// Sent a transaction
	gServerData.DBI.Execute(hTxn, INVALID_FUNCTION, INVALID_FUNCTION, TransactionType_Load, DBPrio_Low);
}

// Stock to clear database variable
stock void CleanConnections(){
	delete gServerData.DBI;
}

//////////////////////////////////////////

/*
 * Stocks database API.
 */
 
/**
 * @brief Function for building any SQL request.
 *
 * @param MySQL             (Optional) The type of connection. 
 * @param sRequest          The request output.
 * @param iMaxLen           The lenght of string.
 * @param nColumn           The column type.
 * @param mFactory          The request type.
 * @param client            (Optional) The client index.
 * @param sData             (Optional) The string input.
 **/
void SQLBaseFactory__(char[] sRequest, int iMaxLen, ColumnType nColumn, FactoryType mFactory, int client = 0){
	 
	// Gets factory mode
	switch (mFactory){
		
		case FactoryType_Create:{
			
			/// Format request
			/*FormatEx(sRequest, iMaxLen, "CREATE TABLE IF NOT EXISTS `%s` ", DATABASE_MAIN);			StrCat(sRequest, iMaxLen,
			  "(`id` int(32) NOT NULL AUTO_INCREMENT, \
				`account_id` int(32) NOT NULL, \
				`money` int(32) NOT NULL DEFAULT 0, \
				`level` int(32) NOT NULL DEFAULT 1, \
				`exp` int(32) NOT NULL DEFAULT 0, \
				`zombie` varchar(32) NOT NULL DEFAULT '', \
				`human` varchar(32) NOT NULL DEFAULT '', \
				`skin` varchar(32) NOT NULL DEFAULT '', \
				`vision` int(32) NOT NULL DEFAULT 1, \
				`time` int(32) NOT NULL DEFAULT 0, \
				PRIMARY KEY (`id`), \
				UNIQUE KEY `account_id` (`account_id`));");*/

			// Log database creation info
			//LogEvent(true, LogType_Normal, LOG_CORE_EVENTS, LogModule_Database, "Query", "Main table \"%s\" was created/loaded. \"%s\" - \"%s\"", DATABASE_MAIN, sRequest);
		}
		
		case FactoryType_Dump:{
			
			/// Format request
			FormatEx(sRequest, iMaxLen, "DESCRIBE `%s`;", DATABASE_MAIN);
			
			// Log database dumping info
			//LogEvent(true, LogType_Normal, LOG_CORE_EVENTS, LogModule_Database, "Query", "Table \"%s\" was dumped. \"%s\"", DATABASE_MAIN, sRequest);
		}
		
		case FactoryType_Keys:{
			
			 /// Format request
			 FormatEx(sRequest, iMaxLen, "SET FOREIGN_KEY_CHECKS = 1;");
		}
		
		case FactoryType_Update:{
			
			//static char sBuffer[3][SMALL_LINE_LENGTH];
		
			/// Format request
			FormatEx(sRequest, iMaxLen, "UPDATE `%s` SET", DATABASE_CHARACTERS);    
			switch (nColumn){
				
				case ColumnType_Default:{
					
					if(gClientData[client].iHat < 0){
						gClientData[client].iHat = 0;
					}
					
					if(gClientData[client].iPjSeleccionado < 0){
						return;
					}
					
					if (gClientData[client].iLevel < 1){
						return;
					}
					
					Format(sRequest, iMaxLen, "%s `lastLogin` = current_timeStamp(), \
						`experiencia` = %d, \
						`level` = %d, \
						`reset` = %d, \
						`hClass` = %d, \
						`zClass` = %d, \
						`HPoints` = %d, \
						`HGPoints` = %d, \
						`ZPoints` = %d, \
						`ZGPoints` = %d, \
						`hDamageLevel` = %d, \
						`hResistanceLevel` = %d, \
						`hDexterityLevel` = %d, \
						`zDamageLevel` = %d, \
						`zDexterityLevel` = %d, \
						`zHealthLevel` = %d, \
						`primarySelected` = %d, \
						`secondarySelected` = %d, \
						`partyInv` = %d, \
						`autoClass` = %d, \
						`autoWeap` = %d, \
						`autoGPack` = %d,\
						`bullets` = %d, \
						`hAlineacion` = %d, \
						`zAlineacion` = %d, \
						`gPack` = %d, \
						`hudColor` = %d, \
						`nvgColor` = %d, \
						`tag` = %d, \
						`hat` = %d, \
						`hatPoints` = %d, \
						`hLMHP` = %d, \
						`hCritChance` = %d, \
						`hItemChance` = %d, \
						`hAuraTime` = %d, \
						`zMadnessTime` = %d, \
						`zDamageToLM` = %d, \
						`zLeech` = %d, \
						`zMadnessChance` = %d",
						//WHERE `id` = %d;"
						gClientData[client].iExp, gClientData[client].iLevel, gClientData[client].iReset, gClientData[client].iHumanClass, gClientData[client].iZombieClass, 
						gClientData[client].iHPoints, gClientData[client].iHGoldenPoints ,gClientData[client].iZPoints, gClientData[client].iZGoldenPoints, 
						gClientData[client].iHDamageLevel, gClientData[client].iHResistanceLevel, 
						gClientData[client].iHDexterityLevel, gClientData[client].iZDamageLevel, 
						gClientData[client].iZDexterityLevel,gClientData[client].iZHealthLevel,
						gClientData[client].iSelectedPrimaryWeapon, gClientData[client].iSelectedSecondaryWeapon, 
						gClientData[client].bReceivePartyInv, gClientData[client].bAutoZClass, 
						gClientData[client].bAutoWeaponUpgrade, gClientData[client].bAutoGrenadeUpgrade, 
						gClientData[client].bStopSound, 
						gClientData[client].iHumanAlignment, gClientData[client].iZombieAlignment, 
						gClientData[client].iGrenadePack,
						gClientData[client].iHudColor, gClientData[client].iNvColor, 
						gClientData[client].iTag, gClientData[client].iHat, gClientData[client].iHatPoints,
						gClientData[client].iGoldenHUpgradeLevel[0], gClientData[client].iGoldenHUpgradeLevel[1], gClientData[client].iGoldenHUpgradeLevel[2], gClientData[client].iGoldenHUpgradeLevel[3],
						gClientData[client].iGoldenZUpgradeLevel[0], gClientData[client].iGoldenZUpgradeLevel[1], gClientData[client].iGoldenZUpgradeLevel[2], gClientData[client].iGoldenZUpgradeLevel[3],
						/*SIEMPRE AL ULTIMO*/ gClientData[client].iPjSeleccionado);

					// Log database updation info
					//LogEvent(true, LogType_Normal, LOG_CORE_EVENTS, LogModule_Database, "Query", "Player \"%N\" was stored. \"%s\"", client, sRequest); 
				}
				
				case ColumnType_PiuPoints:{
					
					int steam_id = GetSteamAccountID(client);
					FormatEx(sRequest, iMaxLen, "UPDATE players SET `piuPoints` = %d WHERE `steamid` = %d;", gClientData[client].iPiuPoints, steam_id);
					return;
				}
				
				/*
				case ColumnType_AccountID :
				{
					Format(sRequest, iMaxLen, "%s `account_id` = (SELECT CAST(SUBSTR(`steam_id`, 11) AS UNSIGNED) * 2 + CAST(SUBSTR(`steam_id`, 9, 1) AS UNSIGNED));", sRequest);
					return;
				}
				
				case ColumnType_Money :
				{
					Format(sRequest, iMaxLen, "%s `money` = %d", sRequest, gClientData[client].Money);
				}
				
				case ColumnType_Level :
				{
					Format(sRequest, iMaxLen, "%s `level` = %d", sRequest, gClientData[client].Level);
				}
				
				case ColumnType_Exp :
				{
					Format(sRequest, iMaxLen, "%s `exp` = %d", sRequest, gClientData[client].Exp);
				}
				
				case ColumnType_Zombie :
				{
					ClassGetName(gClientData[client].ZombieClassNext, sBuffer[0], sizeof(sBuffer[]));
		 
					Format(sRequest, iMaxLen, "%s `zombie` = '%s'", sRequest, sBuffer[0]);
				}
				
				case ColumnType_Human :
				{
					ClassGetName(gClientData[client].HumanClassNext, sBuffer[1], sizeof(sBuffer[]));
		 
					Format(sRequest, iMaxLen, "%s `human` = '%s'", sRequest, sBuffer[1]);
				}

				case ColumnType_Costume :
				{
					CostumesGetName(gClientData[client].Costume, sBuffer[2], sizeof(sBuffer[]));
					
					Format(sRequest, iMaxLen, "%s `skin` = '%s'", sRequest, sBuffer[2]);
				}
				
				case ColumnType_Vision :
				{
					Format(sRequest, iMaxLen, "%s `vision` = %d", sRequest, gClientData[client].Vision);
				}

				case ColumnType_Time :
				{
					Format(sRequest, iMaxLen, "%s `time` = %d", sRequest, GetTime()); /// Gets system time as a unix timestamp
				}*/
			}
			
			// Validate row id
			/*if (gClientData[client].DataID < 1)
			{
				Format(sRequest, iMaxLen, "%s WHERE `account_id` = %d;", sRequest, gClientData[client].AccountID);
			}
			else
			{
				Format(sRequest, iMaxLen, "%s WHERE `id` = %d;", sRequest, gClientData[client].DataID);
			}*/
			
			Format(sRequest, iMaxLen, "%s WHERE `id` = %d;", sRequest, gClientData[client].DataID);
		}
		
		case FactoryType_Select:{
			
			/// Format request
			FormatEx(sRequest, iMaxLen, "SELECT ");
			switch (nColumn){
				
				case ColumnType_Default:{
					
					StrCat(sRequest, iMaxLen, "*");
				
					// Log database updation info
					//LogEvent(true, LogType_Normal, LOG_CORE_EVENTS, LogModule_Database, "Query", "Player \"%N\" was found. \"%s\"", client, sRequest);
				}
				
				case ColumnType_Name:{
					StrCat(sRequest, iMaxLen, "`nombre`");
				}
				
				case ColumnType_Exp:{
					StrCat(sRequest, iMaxLen, "`experiencia`");
				}
				
				case ColumnType_Level:{
					StrCat(sRequest, iMaxLen, "`level`");
				}
				
				case ColumnType_Reset:{
					StrCat(sRequest, iMaxLen, "`reset`");
				}
				
				case ColumnType_ExpBoost:{
					StrCat(sRequest, iMaxLen, "`expboost`");
				}

				case ColumnType_HClass:{
					StrCat(sRequest, iMaxLen, "`hClass`");
				}
				
				case ColumnType_ZClass:{
					StrCat(sRequest, iMaxLen, "`zClass`");
				}

				case ColumnType_HumanPoints:{
					StrCat(sRequest, iMaxLen, "`HPoints`");
				}
				
				case ColumnType_HumanGoldenPoints:{
					StrCat(sRequest, iMaxLen, "`HGPoints`");
				}
				
				case ColumnType_ZombiePoints:{
					StrCat(sRequest, iMaxLen, "`ZPoints`");
				}
				
				case ColumnType_ZombieGoldenPoints:{
					StrCat(sRequest, iMaxLen, "`ZGPoints`");
				}
				
				case ColumnType_LasermineHP:{
					StrCat(sRequest, iMaxLen, "`hLMHP`");
				}

				case ColumnType_CritChance:{
					StrCat(sRequest, iMaxLen, "`hCritChance`");
				}
				
				case ColumnType_ItemChance:{
					StrCat(sRequest, iMaxLen, "`hItemChance`");
				}

				case ColumnType_AuraTime:{
					StrCat(sRequest, iMaxLen, "`hAuraTime`");
				}
				
				case ColumnType_MadnessTime:{
					StrCat(sRequest, iMaxLen, "`zMadnessTime`");
				}

				case ColumnType_DamageToLM:{
					StrCat(sRequest, iMaxLen, "`zDamageToLM`");
				}
				
				case ColumnType_Leech:{
					StrCat(sRequest, iMaxLen, "`zLeech`");
				}

				case ColumnType_MadnessChance:{
					StrCat(sRequest, iMaxLen, "`zMadnessChance`");
				}
				
				case ColumnType_HumanDamageLevel:{
					StrCat(sRequest, iMaxLen, "`hDamageLevel`");
				}
				
				case ColumnType_HumanResistanceLevel:{
					StrCat(sRequest, iMaxLen, "`hResistanceLevel`");
				}
				
				case ColumnType_HumanDexterityLevel:{
					StrCat(sRequest, iMaxLen, "`hDexterityLevel`");
				}
				
				case ColumnType_ZombieDamageLevel:{
					StrCat(sRequest, iMaxLen, "`zDamageLevel`");
				}
				
				case ColumnType_ZombieDexterityLevel:{
					StrCat(sRequest, iMaxLen, "`zDexterityLevel`");
				}

				case ColumnType_ZombieHealthLevel:{
					StrCat(sRequest, iMaxLen, "`zHealthLevel`");
				}
				
				case ColumnType_PrimarySelected:{
					StrCat(sRequest, iMaxLen, "`primarySelected`");
				}

				case ColumnType_SecondarySelected:{
					StrCat(sRequest, iMaxLen, "`secondarySelected`");
				}
				
				case ColumnType_PartyInvites:{
					StrCat(sRequest, iMaxLen, "`partyInv`");
				}
				
				case ColumnType_AutoClasses:{
					StrCat(sRequest, iMaxLen, "`autoClass`");
				}
				
				case ColumnType_AutoWeapons:{
					StrCat(sRequest, iMaxLen, "`autoWeap`");
				}
				
				case ColumnType_AutoGrenades:{
					StrCat(sRequest, iMaxLen, "`autoGPack`");
				}

				case ColumnType_MuteBullets:{
					StrCat(sRequest, iMaxLen, "`bullets`");
				}
				
				case ColumnType_HumanAlignment:{
					StrCat(sRequest, iMaxLen, "`hAlineacion`");
				}

				case ColumnType_ZombieAlignment:{
					StrCat(sRequest, iMaxLen, "`zAlineacion`");
				}
				
				case ColumnType_GrenadePack:{
					StrCat(sRequest, iMaxLen, "`gPack`");
				}

				case ColumnType_HudColor:{
					StrCat(sRequest, iMaxLen, "`hudColor`");
				}
				
				case ColumnType_NvgColor:{
					StrCat(sRequest, iMaxLen, "`nvgColor`");
				}

				case ColumnType_Tag:{
					StrCat(sRequest, iMaxLen, "`tag`");
				}
				
				case ColumnType_Hat:{
					StrCat(sRequest, iMaxLen, "`hat`");
				}

				case ColumnType_HatPoints:{
					StrCat(sRequest, iMaxLen, "`hatPoints`");
				}
				
				case ColumnType_AccessLevel:{
					StrCat(sRequest, iMaxLen, "`accessLevel`");
				}

				case ColumnType_RefeerCode:{
					StrCat(sRequest, iMaxLen, "`refeerCode`");
				}
				
				/* Child table */
				/*case ColumnType_Weapon :
				{
					StrCat(sRequest, iMaxLen, "`weapon`"); /// If client wouldn't has the id, it will not throw errors
					Format(sRequest, iMaxLen, "%s FROM `%s` WHERE `client_id`= %d", sRequest, DATABASE_CHILD, gClientData[client].DataID);
					return;
				}*/
			}
			Format(sRequest, iMaxLen, "%s FROM `%s`", sRequest, DATABASE_CHARACTERS);
			
			// Validate row id
			/*if (gClientData[client].DataID < 1)
			{
				Format(sRequest, iMaxLen, "%s WHERE `account_id` = %d;", sRequest, gClientData[client].AccountID);
			}
			else
			{
				Format(sRequest, iMaxLen, "%s WHERE `id` = %d;", sRequest, gClientData[client].DataID);
			}*/
		}
		
		case FactoryType_Insert:{
			
			/// Format request
			/*switch (nColumn)
			{
				case ColumnType_AccountID :
				{
					FormatEx(sRequest, iMaxLen, "INSERT INTO `%s` (`account_id`) VALUES (%d);", DATABASE_MAIN, gClientData[client].AccountID);
					
					// Log database insertion info
					LogEvent(true, LogType_Normal, LOG_CORE_EVENTS, LogModule_Database, "Query", "Player \"%N\" was inserted. \"%s\"", client, sRequest);
				}
				
				case ColumnType_Weapon :
				{
					FormatEx(sRequest, iMaxLen, "INSERT INTO `%s` (`client_id`, `weapon`) VALUES (%d, '%s');", DATABASE_CHILD, gClientData[client].DataID, sData);
			
					// Log database insertion info
					LogEvent(true, LogType_Normal, LOG_CORE_EVENTS, LogModule_Database, "Query", "Player \"%N\" was inserted. \"%s\"", client, sRequest);
				}

			}*/
		}
	}
}

/**
 * SQL: SELECT
 * @brief Callback for receiving asynchronous database query results.
 *
 * @param hDatabase         Parent object of the handle.
 * @param hResult           Handle to the child object.
 * @param sError            Error string if there was an error.
 * @param client            Data passed in via the original threaded invocation.
 **/
 /*
public void SQLBaseSelect_Callback(Database hDatabase, DBResultSet hResult, char[] sError, int client)
{
	// Make sure the client didn't disconnect while the thread was running
	if (IsPlayerExist(client, false))
	{
		// If invalid query handle, then log error
		if (hDatabase == null || hResult == null || hasLength(sError))
		{
			// Unexpected error, log it
			//LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Database, "Query", "%s", sError);
		}
		else
		{
			// Initialize request char
			static char sRequest[HUGE_LINE_LENGTH]; 

			// Client was found, get data from the row
			if (hResult.FetchRow()){
				
				// Initialize some variables 
				static char sColumn[SMALL_LINE_LENGTH]; ColumnType nColumn; int iIndex;
 
				// i = field index
				int iCount = hResult.FieldCount;
				for (int i = 0; i < iCount; i++){
					
					// Gets name of the field
					hResult.FieldNumToName(i, sColumn, sizeof(sColumn));

					// Validate that field is exist
					if (gServerData.Cols.GetValue(sColumn, nColumn)){
						
						// Sets client data
						switch (nColumn){
							
							case ColumnType_ID:     gClientData[client].DataID = hResult.FetchInt(i); 
							case ColumnType_Name:{
								
								hResult.FetchString(i, sColumn, sizeof(sColumn));
								// Change name
								player.bCanChangeName = true;
								
								// Update player tag
								player.updateTag();
								
								// Update name
								Format(name, sizeof(name), " %s", name);
								SetClientInfo(client, "name", name);
								
								// Can't change name anymore
								player.bCanChangeName = false;
							}
							case ColumnType_Level :  gClientData[client].Level  = hResult.FetchInt(i);
							case ColumnType_Exp :    gClientData[client].Exp    = hResult.FetchInt(i); 
							case ColumnType_Zombie :
							{
								hResult.FetchString(i, sColumn, sizeof(sColumn)); iIndex = ClassNameToIndex(sColumn);
								gClientData[client].ZombieClassNext = (iIndex != -1) ? iIndex : 0;
							}
							case ColumnType_Human :
							{
								hResult.FetchString(i, sColumn, sizeof(sColumn)); iIndex = ClassNameToIndex(sColumn);
								gClientData[client].HumanClassNext  = (iIndex != -1) ? iIndex : 0;
							}
							case ColumnType_Costume:{
								
								hResult.FetchString(i, sColumn, sizeof(sColumn));
								gClientData[client].Costume = CostumesNameToIndex(sColumn);
							}
							case ColumnType_Vision : gClientData[client].Vision = view_as<bool>(hResult.FetchInt(i));
							case ColumnType_Time :   gClientData[client].Time   = hResult.FetchInt(i);
						}
					}
				}
				
				// Generate request
				SQLBaseFactory__(_, sRequest, sizeof(sRequest), ColumnType_Weapon, FactoryType_Select, client);
				
				// Sent a request
				gServerData.DBI.Query(SQLBaseExtract_Callback, sRequest, client, DBPrio_Normal);
			}
			else
			{
				// Generate request
				SQLBaseFactory__(_, sRequest, sizeof(sRequest), ColumnType_AccountID, FactoryType_Insert, client);
				
				// Sent a request
				gServerData.DBI.Query(SQLBaseInsert_Callback, sRequest, client, DBPrio_High); 
			}
			
			// Client was loaded
			gClientData[client].Loaded = true;
		}
	}
}*/