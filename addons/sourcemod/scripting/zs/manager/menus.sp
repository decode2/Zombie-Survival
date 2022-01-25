//
// Menus
//

// Menu enum
enum MenuIndex{
	MENUINDEX_WEAPONS,  // Option 0
	MENUINDEX_ITEMS,  // 1
	MENUINDEX_CLASSES,  // 2
	MENUINDEX_POINTS, // 3
	MENUINDEX_CONFIGS,   // 4
	MENUINDEX_PARTY, // 5
	MENUINDEX_VIP_PURCHASE, // 6
	MENUINDEX_STAFF  // 7
};

// Enum for the account menu
enum UserAction{
	UserAction_AddEmail,
	UserAction_AddPassword,
	UserAction_CreateCharacter
};

// PIU POINTS price to change character name
#define NAME_CHANGE_COST 	3000

//=====================================================
//					MENUS SECTION
//=====================================================

// VIP MENU
/*
public Action showVipMenu(int client){
	ZPlayer player = ZPlayer(client);
	if(!player.bVip && !player.bStaff) return Plugin_Handled;
	Menu menu = new Menu(VipMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	menu.SetTitle("Menu de VIP");
	menu.AddItem("0", "Iniciar Votacion mapa");
	menu.AddItem("1", "Iniciar Modo");
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;

}
public int VipMenuHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			switch(selection){
				case 0: PrintToChat(client, "En construcción");
				case 1: showMenuModos(client);
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}*/

// MODES MENU
/*
public Action showMenuModos(int client){
	ZPlayer player = ZPlayer(client);
	PrintToServer("Iniciando Menu Modos..");
	
	if(!player.bVip && !player.bStaff)
		return Plugin_Handled;
	
	Menu menu = new Menu(ModsMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	char title[64];
	char nam[32];
	Format(title, 64, "Seleccionar modo (Modos restantes: %d)", modesForced);
	menu.SetTitle(title);
	for(int i = view_as<int>(IN_WAIT)+1; i < gModeName.Length; i++){
		ZGameMode mode = ZGameMode(i);
		
		if (mode.bStaffOnly)
			continue;
		
		// Get mode name
		gModeName.GetString(i, nam, 32);
		
		// Store index into the buffer
		char buffer[4];
		IntToString(i, buffer, sizeof(buffer));
		
		
		if ((i == lastMode && i > view_as<int>(MODE_MASSIVE_INFECTION)) || !modesForced || ActualMode.id)
			menu.AddItem(buffer, nam, ITEMDRAW_DISABLED);
		else if (gMinVipToForce.Get(i) > player.flExpBoost && !player.bStaff)
			menu.AddItem(buffer, "Requiere mayor VIP!", ITEMDRAW_DISABLED);
		else if (fnGetAlive() < gMinUsers.Get(i))
			menu.AddItem(buffer, "Usuarios insuficientes", ITEMDRAW_DISABLED);
		else if (gMaxTimesPerMap.Get(i) == 0 || bForcedMode)
			menu.AddItem(buffer, nam, ITEMDRAW_DISABLED);
		else
			menu.AddItem(buffer, nam);
	}
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}
public int ModsMenuHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			if(gServerData.RoundNew){
				// Get mode index
				char buffer[4];
				menu.GetItem(selection, buffer, sizeof(buffer));
				
				// Store mode index as option selected
				int option = StringToInt(buffer);
				
				if (fnGetAlive() < gMinUsers.Get(option)){
					return 0;
				}
				else{
					if (bForcedMode)
						return 0;
						
					int iMaxTimes = gMaxTimesPerMap.Get(option);
					
					if (!iMaxTimes){
						return 0;
					}
					
					// Initialize vars
					char name[32];
					char mod[32];
					
					// Get mode activator data
					GetClientName(client, name, sizeof(name));
					ZPlayer player = ZPlayer(client);
					
					// Get mode data
					gModeName.GetString(option, mod, 32);
					
					// Send announcement
					PrintToChatAll("%s %s %s:\x01 iniciar modo \x0F%s", SERVERSTRING, (player.bStaff) ? "\x09STAFF" : "\x0FVIP", name, mod);
					
					// Decrease quantity of modes available
					modesForced--;
					gMaxTimesPerMap.Set(option, iMaxTimes-1);
					bForcedMode = true;
				}
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}*/

// STAFF MODES MENU
public Action showMenuModosStaff(int client){
	ZPlayer player = ZPlayer(client);
	
	if(!player.bStaff && player.iAccessLevel != MODES_ACCESS)
		return Plugin_Handled;
	
	Menu menu = new Menu(StaffModsMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	char title[64];
	Format(title, sizeof(title), "Seleccionar modo");
	menu.SetTitle(title);
	
	ZGameMode mode;
	char nam[32];
	char buffer[4];
	
	for(int i = view_as<int>(IN_WAIT)+1; i < ZGameModes.Length; i++){
		
		// Get mode name
		ZGameModes.GetArray(i, mode);
		mode.GetName(nam, sizeof(nam));
		
		// Store index into the buffer
		IntToString(i, buffer, sizeof(buffer));
		
		if ( ActualMode.id || (player.iAccessLevel == MODES_ACCESS && mode.id == view_as<int>(MODE_MEOW)) )
			menu.AddItem(buffer, nam, ITEMDRAW_DISABLED);
		else
			menu.AddItem(buffer, nam);
	}
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}
public int StaffModsMenuHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			if(gServerData.RoundNew){
				// Get mode index
				char buffer[8];
				menu.GetItem(selection, buffer, sizeof(buffer));
				
				// Store mode index as option selected
				int option = StringToInt(buffer);
				
				// Initialize vars
				char name[32];
				char mod[32];
				
				// Get mode activator data
				GetClientName(client, name, sizeof(name));
				ZPlayer player = ZPlayer(client);
				
				// Get mode data
				ZGameMode mode;
				ZGameModes.GetArray(option, mode);
				mode.GetName(mod, sizeof(mod));
				
				// Send announcement
				TranslationPrintToChatAll("Started forced mode", (player.bStaff) ? "\x09STAFF" : "\x0FPARTNER", name, mod);
				
				StartMode(option, _, true);
			}
			//else PrintToChatAll("ROUNDNEW IS FALSE");
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// MAIN HANDLER MENU
public Action showMainMenu(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	if (!IsPlayerExist(player.id))
		return Plugin_Handled;
	
	if((player.iTeamNum == CS_TEAM_NONE || player.iTeamNum == CS_TEAM_SPECTATOR) && !player.bLogged) {
		//player.iTeamNum = CS_TEAM_SPECTATOR;
		//showLoginMenu(player.id);
		loginPlayer(client);
	}
	else if ((player.iTeamNum == CS_TEAM_NONE || player.iTeamNum == CS_TEAM_SPECTATOR) && player.bLogged && !player.bInGame) showMenuCuenta(player.id);
	else{
		Menu menu = new Menu(MainMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
		
		static char option[48];
		
		// Sets the global language target
		SetGlobalTransTarget(client);
		
		FormatEx(option, sizeof(option), "%t", "Main menu title", PLUGIN_VERSION);
		menu.SetTitle("%s", option);
		
		FormatEx(option, sizeof(option), "%t", "Main menu option 1");
		menu.AddItem("0", option);
		
		FormatEx(option, sizeof(option), "%t", "Main menu option 2");
		menu.AddItem("1", option);
		
		FormatEx(option, sizeof(option), "%t", "Main menu option 3");
		menu.AddItem("2", option);
		
		FormatEx(option, sizeof(option), "%t", "Main menu option 4");
		menu.AddItem("3", option);
		
		FormatEx(option, sizeof(option), "%t", "Main menu option 5");
		menu.AddItem("4", option);
		
		FormatEx(option, sizeof(option), "%t", "Main menu option 6");
		menu.AddItem("5", option, (iPlayersQuantity >= PARTY_MIN_PLAYERS_ONLINE && allowParty) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		
		FormatEx(option, sizeof(option), "%t", "Main menu option 7");
		menu.AddItem("6", option);
		
		FormatEx(option, sizeof(option), "%t", "Main menu option 8");
		menu.AddItem("7", option, (player.bStaff || player.iAccessLevel == MODES_ACCESS) ? ITEMDRAW_DEFAULT : ITEMDRAW_NOTEXT);
		
		menu.Pagination = MENU_NO_PAGINATION;
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	
	return Plugin_Handled;
}
public int MainMenuHandler(Menu menu, MenuAction action, int client, int selection){
	ZPlayer p = ZPlayer(client);
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			switch(selection){
				case MENUINDEX_WEAPONS: showMenuWeaponsMenu(client, 0);
				case MENUINDEX_ITEMS: showMenuItemsExtra(client);
				case MENUINDEX_CLASSES: showMenuClasses(client, 0);
				case MENUINDEX_POINTS: showMejorasMenu(client);
				case MENUINDEX_CONFIGS: showMenuConfigs(client);
				case MENUINDEX_PARTY: showMenuParty(client, 0);
				case MENUINDEX_VIP_PURCHASE: showVipPurchaseMenu(client);
				case MENUINDEX_STAFF: {
					/*if(p.bVip) showVipMenu(client);
					else */if (p.bStaff || p.iAccessLevel == MODES_ACCESS) showMenuModosStaff(client);
					else 	TranslationPrintToChat(client, "Not vip");
				}
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// WEAPONS MENUS
//=====================================================
// 				NEW WEAPONS MENUS
//=====================================================
public Action showMenuWeaponsPrimaryTiers(int client, int args){
	
	Menu menu = new Menu(MenuWeaponsPrimaryTierHandler, MenuAction_Start|MenuAction_Select|MenuAction_End|MenuAction_DisplayItem);
	
	// Title
	menu.SetTitle("Selecciona el tier de armas primarias que deseas ver");
	
	// Reserve space to store translated options
	char option[32];
	
	// Store primary weapon name
	FormatEx(option, sizeof(option), "Armas primarias tier 0");
	menu.AddItem("0", option);
	
	FormatEx(option, sizeof(option), "Armas primarias tier 1");
	menu.AddItem("1", option);
	
	FormatEx(option, sizeof(option), "Armas primarias tier 2");
	menu.AddItem("2", option);
	
	FormatEx(option, sizeof(option), "Armas primarias tier 3");
	menu.AddItem("3", option);
	
	FormatEx(option, sizeof(option), "Armas primarias tier 4");
	menu.AddItem("4", option);
	
	FormatEx(option, sizeof(option), "Armas primarias tier 5");
	menu.AddItem("5", option);
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}
public int MenuWeaponsPrimaryTierHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			
			switch(selection){
				case 0: {
					showMenuWeaponsByTier(client, 0, WEAPON_PRIMARY);
				}
				case 1: {
					showMenuWeaponsByTier(client, 1, WEAPON_PRIMARY);
				}
				case 2: {
					showMenuWeaponsByTier(client, 2, WEAPON_PRIMARY);
				}
				case 3: {
					showMenuWeaponsByTier(client, 3, WEAPON_PRIMARY);
				}
				case 4: {
					showMenuWeaponsByTier(client, 4, WEAPON_PRIMARY);
				}
				case 5: {
					showMenuWeaponsByTier(client, 5, WEAPON_PRIMARY);
				}
			}
		}
		
		case MenuAction_DisplayItem:{
			
		}
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

///////////////////////////////////////////////////////////////////////////////////////////
public Action showMenuWeaponsMenu(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	Menu menu = new Menu(MenuWeaponsMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_End|MenuAction_DisplayItem);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	// Title
	menu.SetTitle("%t", "Weapon menu title");
	
	// Reserve space to store translated options
	static char option[64];
	
	static char sWeap[32];
	
	// Store primary weapon name
	WeaponsName.GetString(player.iSelectedPrimaryWeapon, sWeap, sizeof(sWeap));
	FormatEx(option, sizeof(option), "%t", "Weapon menu primary weapons", gClientData[client].iTier, sWeap);
	menu.AddItem("0", option);
	
	WeaponsName.GetString(player.iSelectedSecondaryWeapon, sWeap, sizeof(sWeap));
	FormatEx(option, sizeof(option), "%t", "Weapon menu secondary weapons", sWeap);
	menu.AddItem("1", option);
	
	FormatEx(option, sizeof(option), "%t", "Weapon menu grenades", player.iGrenadePack+1);
	menu.AddItem("2", option);
	
	FormatEx(option, sizeof(option), "%t", player.bAutoWeaponUpgrade ? "Automatic weapons upgrade on" : "Automatic weapons upgrade off");
	menu.AddItem("3", option);
	
	FormatEx(option, sizeof(option), "%t", player.bAutoGrenadeUpgrade ? "Automatic grenades upgrade on" : "Automatic grenades upgrade off");
	menu.AddItem("4", option);
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}
public int MenuWeaponsMenuHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			
			switch(selection){
				case 0: {
					showMenuWeaponsByTier(client, gClientData[client].iTier, WEAPON_PRIMARY);
					//showMenuWeaponsPrimaryTiers(client, 0);
				}
				case 1: {
					//showMenuWeaponsByTier(client, gClientData[client].iTier, WEAPON_SECONDARY);
					showSecondaryWeaponsMenu(client);
				}
				case 2: showGrenadePacks(client);
				case 3: {
					autopBuy(client);
					showMenuWeaponsMenu(client, 0);
				}
				case 4: {
					autogBuy(client);
					showMenuWeaponsMenu(client, 0);
				}
			}
		}
		
		case MenuAction_DisplayItem:{
			
		}
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// PRIMARY WEAPONS MENU
public Action showMenuWeaponsByTier(int client, int tier, WeaponType type){
	ZPlayer p = ZPlayer(client);
	Menu menu = new Menu(MenuWeaponsByTierHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	int iLen = WeaponsName.Length-1;
	
	//WeaponsLevel.Sort()
	/*int zweaponID[WEAPONS];
	SortIntegers(zweaponID, WEAPONS, Sort_Ascending);*/
	
	// Initialize vars
	char nf[4];
	char op[64];
	char pWeap[32];
	ZWeapon weapon;
	for (int i; i <= iLen; i++){
		
		weapon = ZWeapon(i);
		
		if (!weapon.bInMenu)
			continue;
		
		if (weapon.iTier != tier)
			continue;
		
		if (weapon.iType != type)
			continue;
		
		IntToString(i, nf, sizeof(nf));
		
		WeaponsName.GetString(i, pWeap, sizeof(pWeap));
		
		FormatEx(op, sizeof(op), "%s", pWeap);
		
		if (p.iLevel >= weapon.iLevel && p.iReset >= weapon.iReset){
			if (weapon.iReset)
				Format(op, sizeof(op), "%s (Reset %d)", op, weapon.iReset);
			menu.AddItem(nf, op);
		}
		else{
			if (weapon.iReset)
				Format(op, sizeof(op), "%s (Level %d | Reset %d)", op, weapon.iLevel, weapon.iReset);
			else
				Format(op, sizeof(op), "%s (Level %d)", op, weapon.iLevel);
			menu.AddItem(nf, op, ITEMDRAW_DISABLED);
		}
	}
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "Selected weapon menu title");
	
	menu.ExitButton = true;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int MenuWeaponsByTierHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			
			char sWeapId[4];
			menu.GetItem(selection, sWeapId, sizeof(sWeapId));
			int num = StringToInt(sWeapId);
			
			
			
			ZPlayer player = ZPlayer(client);
			ZWeapon weapon = ZWeapon(num);
			
			if(player.iLevel >= weapon.iLevel && player.iReset >= weapon.iReset){
				
				showWeaponsDetails(client, weapon.id);
				
				/*char pWeap[32];
				WeaponsName.GetString(weapon.id, pWeap, sizeof(pWeap));
				TranslationPrintToChat(player.id, "Weapon changed", pWeap);
				
				switch (weapon.iType){
					case WEAPON_PRIMARY:{
						player.iNextPrimaryWeapon = weapon.id;
					}
					case WEAPON_SECONDARY:{
						player.iNextSecondaryWeapon = weapon.id;
					}
				}
				
				if (player.bAutoWeaponUpgrade){
					player.bAutoWeaponUpgrade = false;
					TranslationPrintToChat(player.id, "Weapon auto upgrade disabled");
				}*/
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// EXTRA ITEMS MENU
public Action showMenuItemsExtra(int client){
	ZPlayer p = ZPlayer(client);
	Menu menu = new Menu(ItemsExtraMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_Cancel|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "Extra items menu title");
	
	int cost[EXTRA_ITEMS_COUNT];
	char sBuff[EXTRA_ITEMS_COUNT][32];
	
	for (int i; i < sizeof(cost); i++){
		cost[i] = getExtraItemPrice(client, view_as<ExtraItems>(i));
		AddPoints(cost[i], sBuff[i], 32);
	}
	
	ZExtraItem item[EXTRA_ITEMS_COUNT];
	ZExtraItems.GetArray(GetItemIndexByItemid(EXTRA_ITEM_ANTIDOTE), item[0]);
	ZExtraItems.GetArray(GetItemIndexByItemid(EXTRA_ITEM_MADNESS), item[1]);
	ZExtraItems.GetArray(GetItemIndexByItemid(EXTRA_ITEM_INFAMMO), item[2]);
	ZExtraItems.GetArray(GetItemIndexByItemid(EXTRA_ITEM_NIGHTVISION), item[3]);
	ZExtraItems.GetArray(GetItemIndexByItemid(EXTRA_ITEM_ARMOR), item[4]);
	
	bool condition[EXTRA_ITEMS_COUNT];
	condition[0] = (p.iAntidotes > 0 && p.iExp >= cost[0] && p.isType(PT_ZOMBIE) && ActualMode.bAntidoteAvailable);
	condition[1] = (p.iMadness > 0 && p.iExp >= cost[1] && p.isType(PT_ZOMBIE) && ActualMode.bZombieMadnessAvailable && !IsMadnessInCooldown(p.id));
	condition[2] = (p.iExp >= cost[2] && p.iType == PT_HUMAN && !p.bInfiniteAmmo);
	condition[3] = (p.iExp >= cost[3] && p.isType(PT_HUMAN) && !p.bNightvision && !ActualMode.is(MODE_ASSASSIN));
	condition[4] = (p.iExp >= cost[4] && p.isType(PT_HUMAN) && (p.iArmor < ARMOR_MAX_QUANTITY) && ActualMode.bInfection);
	
	char sOption[EXTRA_ITEMS_COUNT][48];
	FormatEx(sOption[0], sizeof(sOption[]), "%t", "Extra items menu option 1", sBuff[0], p.iAntidotes, MAX_ANTIDOTES);
	if (IsMadnessInCooldown(p.id))
		FormatEx(sOption[1], sizeof(sOption[]), "%t", "Extra items menu option 2 unavailable", sBuff[1], AbsValue(RoundToNearest(GetEngineTime() - (MADNESS_COOLDOWN+p.flMadnessTime))));
	else
		FormatEx(sOption[1], sizeof(sOption[]), "%t", "Extra items menu option 2 available", sBuff[1], MAX_MADNESS-p.iMadness, MAX_MADNESS);
	FormatEx(sOption[2], sizeof(sOption[]), "%t", "Extra items menu option 3", sBuff[2]);
	FormatEx(sOption[3], sizeof(sOption[]), "%t", "Extra items menu option 4", sBuff[3]);
	FormatEx(sOption[4], sizeof(sOption[]), "%t", "Extra items menu option 5", sBuff[4]);
	
	for (int i; i < sizeof(cost); i++){
		menu.AddItem("0", sOption[i], (condition[i] && !gServerData.RoundNew && !gServerData.RoundNew) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}
public int ItemsExtraMenuHandler(Menu menu, MenuAction action, int client, int selection){
	ZPlayer player = ZPlayer(client);
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			buyExtraItem(player.id, selection);
		}
		case MenuAction_Cancel:{
			if(selection == MenuCancel_ExitBack){
				showMainMenu(client, 0);
			}
		}
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}
public void buyExtraItem(int client, int selection){
	
	if (gServerData.RoundNew || gServerData.RoundEnd){
		PrintToChat(client, "%s No puedes comprar items ahora!", SERVERSTRING);
		return;
	}
	
	if (!IsPlayerExist(client, false)){
		return;
	}
	
	int cost = getExtraItemPrice(client, view_as<ExtraItems>(selection));
	ZPlayer player = ZPlayer(client);
	
	if (player.iExp < cost)
		return;
	
	
	switch(selection){
		case EXTRA_ITEM_ANTIDOTE:{
			if (!player.isType(PT_ZOMBIE)){
				TranslationPrintToChat(player.id, "Not zombie");
				return;
			}
			
			int zombies = fnGetZombies();
			
			if (zombies <= 1){
				TranslationPrintToChat(player.id, "The last zombie cannot use antidote");
				return;
			}
			
			if (zombies < iPlayersQuantity*ANTIDOTE_MIN_ZOMBIES_REQUIRED){
				TranslationPrintToChat(player.id, "Cannot use antidote when less than x zombies", iPlayersQuantity*ANTIDOTE_MIN_ZOMBIES_REQUIRED);
				return;
			}
			
			if(!IsPlayerAlive(player.id)){
				TranslationPrintToChat(player.id, "Not alive");
				return;
			}
			
			if (!player.iAntidotes || !ActualMode.bAntidoteAvailable){
				return;
			}
			
			applyExtraItemEffect(player.id, selection);
			
			// Apply costs
			player.iAntidotes--;
			gConsumedAntidotes++;
			player.iExp -= cost;
			player.iAntidoteCount++;
			player.checkLevelUp();
		}
		case EXTRA_ITEM_MADNESS:{
			
			if (!ZombieMadnessBegin(client)){
				return;
			}
			
			player.iMadness--;
			player.iExp -= cost;
			player.iMadnessCount++;
			player.checkLevelUp();
			
			TranslationPrintToChat(player.id, "Used zombie madness");
		}
		case EXTRA_ITEM_INFAMMO:{
			if (!player.isType(PT_HUMAN) || player.bInfiniteAmmo){
				return;
			}
			
			if(!IsPlayerAlive(player.id)){
				TranslationPrintToChat(player.id, "Not alive");
				return;
			}
			
			applyExtraItemEffect(player.id, selection);
			
			gClientData[client].iExp -= cost;
			gClientData[client].iItemsCount[EXTRA_ITEM_INFAMMO]++;
			player.checkLevelUp();
		}
		case EXTRA_ITEM_NIGHTVISION:{
			if (!player.isType(PT_HUMAN)){
				TranslationPrintToChat(player.id, "Not human");
				return;
			}
			
			if(!IsPlayerAlive(player.id)){
				TranslationPrintToChat(player.id, "Not alive");
				return;
			}
			
			if (player.bNightvision){
				TranslationPrintToChat(player.id, "Already have this item");
				return;
			}
			
			if (ActualMode.is(MODE_ASSASSIN)){
				TranslationPrintToChat(player.id, "Item not allowed in this mode");
				return;
			}
			
			applyExtraItemEffect(player.id, selection);
			
			player.iExp -= cost;
			player.iNightvisionCount++;
			player.checkLevelUp();
		}
		case EXTRA_ITEM_ARMOR:{
			
			if (!player.isType(PT_HUMAN)){
				PrintToChat(client, "%s Debes ser \x05humano\x01 para comprar este item", SERVERSTRING);
				return;
			}
			
			if (player.iArmor >= ARMOR_MAX_QUANTITY){
				PrintToChat(client, "%s Ya posees el máximo de armadura.", SERVERSTRING);
				return;
			}
			
			if (!ActualMode.bInfection){
				PrintToChat(client, "%s Item solamente disponible en rondas de infección.", SERVERSTRING);
				return;
			}
			
			if (!gClientData[client].iRemainingPurchases){
				PrintToChat(client, "%s Item solamente disponible \x05%d veces por ronda\x01.", SERVERSTRING, ARMOR_MAX_BUYS_PER_ROUND);
				return;
			}
			
			applyExtraItemEffect(player.id, selection);
			
			gClientData[client].iItemsCount[EXTRA_ITEM_ARMOR]++;
			gClientData[client].iExp -= cost;
			gClientData[client].iRemainingPurchases--;
			player.checkLevelUp();
		}
	}
}

// ExtraItems funcs
stock int getExtraItemPrice(int client, ExtraItems itemid){
	
	ZPlayer player = ZPlayer(client);
	ZExtraItem item;
	ZExtraItems.GetArray(GetItemIndexByItemid(itemid), item);
	
	int lvl = player.iLevel;
	int cost = bAllowGain ? (lvl*item.iCost) : (lvl*item.iCost)/10;
	
	if (itemid == EXTRA_ITEM_MADNESS && player.iMadnessCount){
		cost *= 1+RoundToZero(player.iMadnessCount*0.30);
	}
	
	if (player.iReset){
		cost *= 1+RoundToZero(player.iReset*0.24);
	}
	
	/*if (iPlayersQuantity < 2){
		cost = 0;
	}*/
	
	return cost;
}
void applyExtraItemEffect(int client, int itemId){
	
	ZPlayer player = ZPlayer(client);
	
	switch (itemId){
		case EXTRA_ITEM_ANTIDOTE:{
			
			if (!player.isType(PT_ZOMBIE) || (fnGetZombies() <= 1) || !IsPlayerAlive(player.id)){
				return;
			}
			
			
			// Stop crowd control effects
			ExtinguishEntity(player.id);
			Unfreeze(player.hFreezeTimer, player.id);
			
			// Turn into human
			player.Humanize();
			TranslationPrintToChat(player.id, "Used antidote");
			
			char sName[48];
			GetClientName(player.id, sName, sizeof(sName));
			TranslationPrintHudTextAll(gServerData.GameSync, 0.03, 0.35, 3.0, 0, 30, 200, 255, 1, 1.0, 1.0, 1.0, "Has taken antidote", sName);
		}
		case EXTRA_ITEM_MADNESS:{
			
			if (!ZombieMadnessBegin(client)){
				return;
			}
			
			TranslationPrintToChat(player.id, "Used zombie madness");
		}
		case EXTRA_ITEM_INFAMMO:{
			
			if (!player.isType(PT_HUMAN) || player.bInfiniteAmmo){
				return;
			}
			
			player.bInfiniteAmmo = true;
			TranslationPrintToChat(player.id, "Bought unlimited bullets");
		}
		case EXTRA_ITEM_NIGHTVISION:{
			
			if (!player.isType(PT_HUMAN) || !IsPlayerAlive(player.id) || player.bNightvision){
				return;
			}
			
			player.bNightvision = true;
			player.bNightvisionOn = true;
			TranslationPrintToChat(player.id, "Bought nightvision");
		}
		case EXTRA_ITEM_ARMOR:{
			
			if (!player.isType(PT_HUMAN)){
				PrintToChat(client, "%s Debes ser \x05humano\x01 para comprar este item", SERVERSTRING);
				return;
			}
			
			if (player.iArmor >= ARMOR_MAX_QUANTITY){
				PrintToChat(client, "%s Ya posees el máximo de armadura.", SERVERSTRING);
				return;
			}
			
			if (!ActualMode.bInfection){
				PrintToChat(client, "%s Item solamente disponible en rondas de infección.", SERVERSTRING);
				return;
			}
			
			player.iArmor += ARMOR_QUANTITY;
			
			if (player.iArmor > ARMOR_MAX_QUANTITY){
				player.iArmor = ARMOR_MAX_QUANTITY;
			}
			
			PrintToChat(client, "%s Has comprado \x05%d\x01 de armadura.", SERVERSTRING, ARMOR_QUANTITY);
			
		}
	}
}

// PRIMARY WEAPONS MENU

/*public Action showPrimaryWeaponsMenu(int client){
	ZPlayer p = ZPlayer(client);
	Menu menu = new Menu(MenuPrimaryWeaponsHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	int iLen = WeaponsName.Length-1;
	
//	int iWeaponByLevel = getWeaponByPlayerLevel(p.id);
//
//	ArrayList DisplayedWeapons = new ArrayList(1, 0);
//	
//	int topeLevel = (iWeaponByLevel == iLen) ? 7:6;
//	
//	int bannedWeapon= -1;
//	for (int i = iWeaponByLevel; i >= 0; i--){
//		if(i == iWeaponByLevel){
//			DisplayedWeapons.Push(i);
//			continue;
//		}
//		
//		if(DisplayedWeapons.Length < topeLevel){
//			if(bannedWeapon == i){
//				bannedWeapon = -1;
//				continue;
//			}
//			if(i-1 >=0){
//				ZWeapon weapon = ZWeapon(i);
//				ZWeapon nextWeapon = ZWeapon(i-1);
//				if(weapon.iReset > nextWeapon.iReset){
//					if(p.iLevel >= weapon.iLevel && p.iReset >= weapon.iReset){
//						bannedWeapon = nextWeapon.id;
//						DisplayedWeapons.Push(i);
//					}else{
//						continue;
//					}
//				}else{
//					if(p.iLevel >= weapon.iLevel && p.iReset >= weapon.iReset){
//						DisplayedWeapons.Push(i);
//					}
//					else {
//						continue;
//					}
//				}
//			}else{
//				DisplayedWeapons.Push(i);
//			}
//		}
//		else break;
//	}
////	PrintToChat(client, "TopeLevel: %d | iWeaponByLevel: %d | length: %d", topeLevel, iWeaponByLevel, DisplayedWeapons.Length);
//	int dwLength = DisplayedWeapons.Length-1;
//	for(int i = 0; i < (dwLength+1)/2; i++){
//		DisplayedWeapons.SwapAt(i,dwLength-i);
//	}
//	
//	if(topeLevel == 6){
//		for(int i = iWeaponByLevel+1; i< iLen; i++){
//			if(DisplayedWeapons.Length == 7)
//				break;
//			ZWeapon weapon = ZWeapon(i);
//			ZWeapon nextWeapon = ZWeapon(i+1);
////			PrintToChatAll("weapon: (%d, %d) | next: (%d, %d) | player: (%d, %d)", weapon.iLevel, weapon.iReset, nextWeapon.iLevel, nextWeapon.iReset, p.iLevel, p.iReset);
//			if(p.iReset >= weapon.iReset){
//				if(p.iReset >= nextWeapon.iReset){
//					if(weapon.iReset < nextWeapon.iReset){
////						PrintToChatAll("Arma pospuesta");
//						continue;
//					} else{
//						DisplayedWeapons.Push(i);
////						PrintToChatAll("Arma agregada");
//					}
//				}else{
//					DisplayedWeapons.Push(i);
////					PrintToChatAll("Arma agregada");
//				}
//			}
////			PrintToChatAll("i: %d | length: %d", i, DisplayedWeapons.Length);
//		}
//	}
	
//	PrintToChatAll("Levels iguales pero next reset mayor");
//	if(p.iReset >= nextWeapon.iReset){
//		PrintToChatAll("El usuario tiene los resets para usarla");
//		continue;
//	}
//	else{
//		DisplayedWeapons.Push(i);
//	}
//	
//	else{
//		PrintToChatAll("Levels diferentes o next reset menor");
//		if(p.iReset >= nextWeapon.iReset) {
//			PrintToChatAll("El usuario puede usar esta arma en este reset");
//			DisplayedWeapons.Push(i);
//		}
//	}
	
	// Initialize vars
	char nf[4];
	char op[64];
	char pWeap[32];
	ZWeapon weapon;
	for (int i; i <= iLen; i++){
		
		weapon = ZWeapon(i);
		
		if (!weapon.bInMenu)
			continue;
			
		if (weapon.iType != WEAPON_PRIMARY)
			continue;
		
		IntToString(i, nf, sizeof(nf));
		
		WeaponsName.GetString(i, pWeap, sizeof(pWeap));
		
		FormatEx(op, sizeof(op), "%s", pWeap);
		
		if (p.iLevel >= weapon.iLevel && p.iReset >= weapon.iReset){
			if (weapon.iReset)
				Format(op, sizeof(op), "%s (Reset %d)", op, weapon.iReset);
			menu.AddItem(nf, op);
		}
		else{
			if (weapon.iReset)
				Format(op, sizeof(op), "%s (Level %d | Reset %d)", op, weapon.iLevel, weapon.iReset);
			else
				Format(op, sizeof(op), "%s (Level %d)", op, weapon.iLevel);
			menu.AddItem(nf, op, ITEMDRAW_DISABLED);
		}
	}
	
	
//	for (int i; i <= iLen; i++){
//		
//		ZWeapon weapon = ZWeapon(i);
//		
//		// Overlap weapons with same level but not same reset requirement
//		if (i < iLen-1){
//			ZWeapon nextweapon = ZWeapon(i+1);
//			if (nextweapon.iLevel == weapon.iLevel && nextweapon.iReset > weapon.iReset)
//				continue;
//		}
//		
//		// Initialize vars
//		char nf[4];
//		char op[64];
//		char pWeap[32];
//		IntToString(i, nf, 4);
//		
//		WeaponsName.GetString(weapon.id, pWeap, 32);
//		
//		Format(op, sizeof(op), "%s", pWeap);
//		if (p.iLevel >= weapon.iLevel && p.iReset >= weapon.iReset){
//			if (weapon.iReset)
//				Format(op, sizeof(op), "%s (%drr)", op, weapon.iReset);
//			
//			menu.AddItem(nf, op);
//		}
//		else{
//			if (p.iReset < weapon.iReset)
//				Format(op, sizeof(op), "%s (Level %d | Reset %d)", op, weapon.iLevel, weapon.iReset);
//			else
//				Format(op, sizeof(op), "%s (Level %d)", op, weapon.iLevel);
//			
//			menu.AddItem(nf, op, ITEMDRAW_DISABLED);
//		}
//	}
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "Selected weapon menu title");
	
	menu.ExitButton = true;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}*/
/*public int MenuPrimaryWeaponsHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			
			char sWeapId[4];
			menu.GetItem(selection, sWeapId, sizeof(sWeapId));
			int num = StringToInt(sWeapId);
			
			ZPlayer player = ZPlayer(client);
			ZWeapon weapon = ZWeapon(num);
			
			if(player.iLevel >= weapon.iLevel && player.iReset >= weapon.iReset){
				
				showWeaponsDetails(client, weapon.id);
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}*/

// SECONDARY WEAPONS
public Action showSecondaryWeaponsMenu(int client){
	ZPlayer p = ZPlayer(client);
	Menu menu = new Menu(MenuSecondaryWeaponsHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	int iLen = WeaponsName.Length-1;
	
	// Initialize vars
	char nf[4];
	char op[64];
	char pWeap[32];
	ZWeapon weapon;
	for (int i; i <= iLen; i++){
		
		weapon = ZWeapon(i);
		
		if (!weapon.bInMenu)
			continue;
		
		if (weapon.iType != WEAPON_SECONDARY)
			continue;
		
		IntToString(i, nf, sizeof(nf));
		
		WeaponsName.GetString(i, pWeap, sizeof(pWeap));
		
		FormatEx(op, sizeof(op), "%s", pWeap);
		
		if (p.iLevel >= weapon.iLevel && p.iReset >= weapon.iReset){
			if (weapon.iReset)
				Format(op, sizeof(op), "%s (Reset %d)", op, weapon.iReset);
			menu.AddItem(nf, op);
		}
		else{
			if (weapon.iReset)
				Format(op, sizeof(op), "%s (Level %d | Reset %d)", op, weapon.iLevel, weapon.iReset);
			else
				Format(op, sizeof(op), "%s (Level %d)", op, weapon.iLevel);
			menu.AddItem(nf, op, ITEMDRAW_DISABLED);
		}
	}
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "Select secondary weapon menu title");
	
	menu.ExitButton = true;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int MenuSecondaryWeaponsHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			
			char sWeapId[4];
			menu.GetItem(selection, sWeapId, sizeof(sWeapId));
			int num = StringToInt(sWeapId);
			
			ZPlayer player = ZPlayer(client);
			ZWeapon weapon = ZWeapon(num);
			
			if(player.iLevel >= weapon.iLevel && player.iReset >= weapon.iReset){
				
				/*char pWeap[32];
				WeaponsName.GetString(weapon.id, pWeap, sizeof(pWeap));
				player.iNextSecondaryWeapon = weapon.id;
				TranslationPrintToChat(player.id, "Weapon changed", pWeap);
				
				if (player.bAutoWeaponUpgrade){
					player.bAutoWeaponUpgrade = false;
					TranslationPrintToChat(player.id, "Weapon auto upgrade disabled");
				}*/
				showWeaponsDetails(client, weapon.id);
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// Menu to look details of weapons
// Needs 2 handlers because param2 acts as "reason" outside MenuAction_Select
public Action showWeaponsDetails(int client, int weaponArrayID){
	
	Menu menu;
	
	ZWeapon weapon = ZWeapon(weaponArrayID);
	
	if (weapon.iType == WEAPON_PRIMARY){
		menu = new Menu(showPrimaryWeaponsDetailsHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	}
	else{
		menu = new Menu(showSecondaryWeaponsDetailsHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	}
	
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	
	char sWeapName[32];
	weapon.GetName(sWeapName, sizeof(sWeapName));
	
	char sWeapModel[WEAPONS_MODELS_MAXPATH];
	weapon.GetViewModel(sWeapModel, sizeof(sWeapModel));
	
	menu.SetTitle("Detalles del arma\n \n ·Nombre: %s\n ·Tipo de arma: %s\n ·Daño base promedio: ~%d\n ·Nivel requerido: %d lvl y %d resets\n ·Tier: %d \n ·Apariencia: %s\n \n ", sWeapName, (weapon.iType == WEAPON_PRIMARY) ? "PRIMARIA" : "SECUNDARIA", RoundToNearest((weapon.flDamageMin+weapon.flDamageMax)/2.0), weapon.iLevel, weapon.iReset, weapon.iTier, (!hasLength(sWeapModel)) ? "POR DEFECTO" : "MODIFICADA");
	
	static char sWeapID[4];
	IntToString(weaponArrayID, sWeapID, sizeof(sWeapID));
	
	static char option[32];
	FormatEx(option, sizeof(option), "Seleccionar arma %s", (weapon.iType == WEAPON_PRIMARY) ? "primaria" : "secundaria");
	menu.AddItem(sWeapID, option);
	
	menu.ExitBackButton = true;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

// Handler for primary weapons
public int showPrimaryWeaponsDetailsHandler(Menu menu, MenuAction action, int client, int selection){
	
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			
			char sWeapId[4];
			menu.GetItem(selection, sWeapId, sizeof(sWeapId));
			int num = StringToInt(sWeapId);
			
			ZWeapon weapon = ZWeapon(num);
			ZPlayer player = ZPlayer(client);
			
			if(player.iLevel >= weapon.iLevel && player.iReset >= weapon.iReset){
				
				char pWeap[32];
				WeaponsName.GetString(weapon.id, pWeap, sizeof(pWeap));
				
				player.iNextPrimaryWeapon = weapon.id;
				
				TranslationPrintToChat(player.id, "Weapon changed", pWeap);
				
				player.bAutoWeaponUpgrade = false;
				TranslationPrintToChat(player.id, "Weapon auto upgrade disabled");
				
				//showMenuWeaponsLegacy(client, 0);
			}
		}
		case MenuAction_Cancel:{
			if(selection == MenuCancel_ExitBack){
				showMenuWeaponsByTier(client, gClientData[client].iTier, WEAPON_PRIMARY);
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// Handler for secondary weapons
public int showSecondaryWeaponsDetailsHandler(Menu menu, MenuAction action, int client, int selection){
	
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			
			char sWeapId[4];
			menu.GetItem(selection, sWeapId, sizeof(sWeapId));
			int num = StringToInt(sWeapId);
			
			ZWeapon weapon = ZWeapon(num);
			ZPlayer player = ZPlayer(client);
			
			if(player.iLevel >= weapon.iLevel && player.iReset >= weapon.iReset){
				
				char pWeap[32];
				WeaponsName.GetString(weapon.id, pWeap, sizeof(pWeap));
				
				player.iNextSecondaryWeapon = weapon.id;
				
				TranslationPrintToChat(player.id, "Weapon changed", pWeap);
				
				player.bAutoWeaponUpgrade = false;
				TranslationPrintToChat(player.id, "Weapon auto upgrade disabled");
				
				//showMenuWeaponsLegacy(client, 0);
			}
		}
		case MenuAction_Cancel:{
			if(selection == MenuCancel_ExitBack){
				showSecondaryWeaponsMenu(client);
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// CLASSES MENUS
public Action showMenuClasses(int client, int args){
	Menu menu = new Menu(MenuClassesHandler, MenuAction_Start|MenuAction_Select|MenuAction_Cancel|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "Classes menu title");
	
	char option[48];
	
	ZPlayer player = ZPlayer(client);
	
	char sData[32];
	
	ZClass zclass;
	ZClasses.GetArray(player.iZombieClass, zclass);
	Format(option, sizeof(option), "%t", "Classes menu option 1", zclass.name);
	menu.AddItem("1", option);
	
	HClass hclass;
	HClasses.GetArray(player.iHumanClass, hclass);
	Format(option, sizeof(option), "%t", "Classes menu option 2", hclass.name);
	menu.AddItem("2", option);
	
	ZAlignment alignment;
	ZAlignments.GetArray(player.iZombieAlignment, alignment);
	strcopy(sData, sizeof(sData), alignment.name);
	Format(option, sizeof(option), "%t", "Classes menu option 3", sData);
	menu.AddItem("3", option);
	
	HAlignment halignment;
	HAlignments.GetArray(player.iHumanAlignment, halignment);
	strcopy(sData, sizeof(sData), halignment.name);
	Format(option, sizeof(option), "%t", "Classes menu option 4", sData);
	menu.AddItem("4", option);
	
	Format(option, sizeof(option), "%t", player.bAutoZClass ? "Classes menu option 5 on" : "Classes menu option 5 off");
	menu.AddItem("5", option);
	
	menu.ExitBackButton = true;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int MenuClassesHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			switch(selection){
				case 0:{
					showMenuClassesZombie(client);
				}
				case 1:{
					showMenuClassesHuman(client);
				}
				case 2:{
					showMenuZombieAlignment(client);
				}
				case 3:{
					showMenuHumanAlignment(client);
				}
				case 4:{
					autozClass(client);
					showMenuClasses(client, 0);
				}
			}
		}
		case MenuAction_Cancel:{
			if(selection == MenuCancel_ExitBack){
				showMainMenu(client, 0);
			}
		}
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// ZOMBIE CLASSES MENU
public Action showMenuClassesZombie(int client){
	Menu menu = new Menu(MenuClassesZombieHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	ZPlayer player = ZPlayer(client);
	
	char nf[4];
	char op[64];
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "Zombie classes menu title");
	
	ZClass class;
	for(int i; i < ZClasses.Length; i++) {
		
		ZClasses.GetArray(i, class);
		
		IntToString(i, nf, 4);
		
		if (class.reset)
			FormatEx(op, sizeof(op), "%s (Lvl %d | Reset: %d)", class.name, class.level, class.reset);
		else
			FormatEx(op, sizeof(op), "%s (Lvl %d)", class.name, class.level);
		
		if(player.iLevel >= class.level && player.iReset >= class.reset){
			menu.AddItem(nf, op);
		}
		else {
			menu.AddItem(nf, op, ITEMDRAW_DISABLED);
		}
	}
	menu.ExitButton = true;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int MenuClassesZombieHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			showClassesDetails(client, selection, true);
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// Menu to look details of classes
// Needs 2 handlers because param2 acts as "reason" outside MenuAction_Select
public Action showClassesDetails(int client, int classArrayID, bool classZombie){
	
	Menu menu;
	
	char sPointedHP[24];
	if (classZombie){
		ZClass class;
		ZClasses.GetArray(classArrayID, class);
		
		menu = new Menu(showZombieClassDetailsHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
		AddPoints(class.health, sPointedHP, sizeof(sPointedHP));
		menu.SetTitle("Detalles de la clase\n \n ·Nombre: %s\n ·Vida: %s\n ·Daño: %d%%\n ·Velocidad de movimiento: %d%%\n ·Gravedad: %d%%\n ·Nivel requerido: %d lvl y %d resets \n \n ", class.name, sPointedHP, RoundToZero(class.damage*100.0), RoundToZero(class.speed*100.0), RoundToZero(class.gravity*100.0), class.level, class.reset);
	}
	else{
		HClass class;
		HClasses.GetArray(classArrayID, class);
		
		menu = new Menu(showHumanClassDetailsHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
		
		AddPoints(class.health, sPointedHP, sizeof(sPointedHP));
		menu.SetTitle("Detalles de la clase\n \n ·Nombre: %s\n ·Vida: %s\n ·Armadura: %d\n ·Velocidad de movimiento: %d%%\n ·Gravedad: %d%%\n ·Nivel requerido: %d lvl y %d resets \n \n ", class.name, sPointedHP, class.armor, RoundToZero(class.speed*100.0), RoundToZero(class.gravity*100.0), class.level, class.reset);
	}
	
	
	// Sets the global language target
	SetGlobalTransTarget(client);	
	
	static char sClassID[4];
	IntToString(classArrayID, sClassID, sizeof(sClassID));
	
	static char option[32];
	FormatEx(option, sizeof(option), "Seleccionar clase %s", (classZombie) ? "zombie" : "humana");
	menu.AddItem(sClassID, option);
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

// Handler for primary weapons
public int showZombieClassDetailsHandler(Menu menu, MenuAction action, int client, int selection){
	
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			
			char sClassID[4];
			menu.GetItem(selection, sClassID, sizeof(sClassID));
			int num = StringToInt(sClassID);
			
			ZPlayer player = ZPlayer(client);
			ZClass class;
			ZClasses.GetArray(num, class);
			if(player.iLevel >= class.level && player.iReset >= class.reset){
				player.iNextZombieClass = num;
				TranslationPrintToChat(player.id, "Zombie class changed", class.name);
			}
		}
		case MenuAction_Cancel:{
			if(selection == MenuCancel_ExitBack){
				showMenuClassesZombie(client);
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// Handler for secondary weapons
public int showHumanClassDetailsHandler(Menu menu, MenuAction action, int client, int selection){
	
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			
			char sClassID[4];
			menu.GetItem(selection, sClassID, sizeof(sClassID));
			int num = StringToInt(sClassID);
			
			ZPlayer player = ZPlayer(client);
			HClass  hclass;
			HClasses.GetArray(num, hclass);
			if(player.iLevel >= hclass.level && player.iReset >= hclass.reset){
				player.iNextHumanClass = num;
				TranslationPrintToChat(player.id, "Human class changed", hclass.name);
			}
		}
		case MenuAction_Cancel:{
			if(selection == MenuCancel_ExitBack){
				showMenuClassesHuman(client);
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// HUMAN CLASSES MENU
public Action showMenuClassesHuman(int client){
	Menu menu = new Menu(MenuClassesHumanHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	ZPlayer player = ZPlayer(client);
	
	char nf[4];
	char op[64];
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "Human classes menu title");
	
	HClass class;
	for(int i; i < HClasses.Length; i++) {
		
		HClasses.GetArray(i, class);
		
		IntToString(i, nf, 4);
		
		if (class.reset)
			FormatEx(op, sizeof(op), "%s (Lvl %d | Reset: %d)", class.name, class.level, class.reset);
		else
			FormatEx(op, sizeof(op), "%s (Lvl %d)", class.name, class.level);
		
		if (class.id == player.iHumanClass)
			Format(op, sizeof op, "%s [ACTUAL]", op);
		
		//menu.AddItem(nf, op, ITEMDRAW_DISABLED);
		
		if(player.iLevel >= class.level && player.iReset >= class.reset){
			menu.AddItem(nf, op);
		}
		else {
			menu.AddItem(nf, op, ITEMDRAW_DISABLED);
		}
		
		/*if(player.iLevel >= class.level && player.iReset >= class.reset){
			menu.AddItem(nf, op);
		}
		else {
			menu.AddItem(nf, op, ITEMDRAW_DISABLED);
		}*/
	}
	menu.ExitButton = true;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int MenuClassesHumanHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			showClassesDetails(client, selection, false);
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// ZOMBIE ALIGNMENT MENU
public Action showMenuZombieAlignment(int client){
	Menu menu = new Menu(MenuZombieAlignmentHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	static char op[96];
	static char sName[32];
	static char sDescription[64];
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "Zombie alignments menu title");
	
	ZAlignment alignment;

	for(int i; i < ZAlignments.Length; i++) {
		
		ZAlignments.GetArray(i, alignment);
		
		strcopy(sName, sizeof(sName), alignment.name);
		strcopy(sDescription, sizeof(sDescription), alignment.desc);
		
		// Simply format the fkin menu
		FormatEx(op, sizeof(op), "%s (%s)", sName, sDescription);
		menu.AddItem("", op);
	}
	menu.ExitButton = true;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int MenuZombieAlignmentHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			ZPlayer player = ZPlayer(client);
			char sName[32];
			player.iNextZombieAlignment = selection;
			
			ZAlignment alignment;
			ZAlignments.GetArray(selection, alignment);
			strcopy(sName, sizeof(sName), alignment.name);
			TranslationPrintToChat(player.id, "Zombie alignment changed", sName);
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// HUMAN ALIGNMENT MENU
public Action showMenuHumanAlignment(int client){
	Menu menu = new Menu(MenuHumanAlignmentHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	static char op[96];
	static char sName[32];
	static char sDescription[64];
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "Human alignments menu title");
	
	HAlignment alignment;

	for(int i; i < HAlignments.Length; i++) {
		
		HAlignments.GetArray(i, alignment);

		strcopy(sName, sizeof(sName), alignment.name);
		strcopy(sDescription, sizeof(sDescription), alignment.desc);

		// Simply format the fkin menu
		FormatEx(op, sizeof(op), "%s (%s)", sName, sDescription);
		menu.AddItem("", op);
	}
	menu.ExitButton = true;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int MenuHumanAlignmentHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			ZPlayer player = ZPlayer(client);
			char sName[32];
			player.iNextHumanAlignment = selection;

			HAlignment alignment;
			HAlignments.GetArray(selection, alignment);
			strcopy(sName, sizeof(sName), alignment.name);
			TranslationPrintToChat(player.id, "Human alignment changed", sName);
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// UPGRADES MENUS
public Action showMejorasMenu(int client){
	Menu menu = new Menu(MejorasMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_Cancel|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "Upgrades menu title");
	
	char option[48];
	
	Format(option, sizeof(option), "%t", "Upgrades menu option 1");
	menu.AddItem("0", option);
	
	Format(option, sizeof(option), "%t", "Upgrades menu option 2");
	menu.AddItem("1", option);
	
	menu.AddItem("", "", ITEMDRAW_SPACER);
	
	Format(option, sizeof(option), "%t", "Upgrades menu option 3");
	menu.AddItem("2", option);
	
	Format(option, sizeof(option), "%t", "Upgrades menu option 4");
	menu.AddItem("3", option);
	
	Format(option, sizeof(option), "%t", "Upgrades menu option 5", RESET_LEVEL);
	menu.AddItem("5", option, ITEMDRAW_DEFAULT);
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}
public int MejorasMenuHandler(Menu menu, MenuAction action, int client, int selection){
	
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			switch(selection){
				case 0: showMenuHMejoras(client);
				case 1: showMenuZMejoras(client);
				case 3: showMenuHGoldenMejoras(client);
				case 4: showMenuZGoldenMejoras(client);
				case 5: showResetMenu(client, 0);
			}
		}
		case MenuAction_Cancel:{
			if(selection == MenuCancel_ExitBack){
				showMainMenu(client, 0);
			}
		}
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// RESET MENU
public Action showResetMenu(int client, int args){
	Menu menu = new Menu(resetMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	static char sBuffer[512];
	FormatEx(sBuffer, sizeof(sBuffer), "%t", "Reset menu title", RESET_LEVEL, resetsCalculateFeeByResets(gClientData[client].iReset), gClientData[client].iReset);
	
	menu.SetTitle(sBuffer);
	
	menu.AddItem("", "", ITEMDRAW_SPACER);
	
	FormatEx(sBuffer, sizeof(sBuffer), "%t", "Reset menu option 1");
	menu.AddItem("2", sBuffer, playerCheckCanReset(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}
public int resetMenuHandler(Menu menu, MenuAction action, int client, int selection){
	ZPlayer player = ZPlayer(client);
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			if (selection == 1){
				
				if (player.iReset >= RESET_MAX_QUANTITY){
					PrintToChat(client, "%s Has llegado al \x04máximo de resets por el momento\x01, aprovecha a sumar puntos \x03H&Z\x01!", SERVERSTRING);
					PrintToChat(client, "%s Desbloquearemos el límite de resets \x05cada semana\x01!", SERVERSTRING);
					return 0;
				}
				
				int feeAmmount = resetsCalculateFeeByResets(gClientData[client].iReset);
					
				if (gClientData[client].iHPoints < feeAmmount || gClientData[client].iZPoints < feeAmmount){
					PrintToChat(client, "%s No posees \x04suficientes puntos\x01 para resetear.", SERVERSTRING);
					return 0;
				}
				
				
				if (gClientData[client].iLevel >= RESET_LEVEL){
					PrintToChat(client, "%s No posees \x04nivel suficiente\x01 para resetear.", SERVERSTRING);
				}
				
				resetear(client);
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

bool playerCheckCanReset(int client){
	
	if (gClientData[client].iReset >= RESET_MAX_QUANTITY){
		return false;
	}
	
	if (gClientData[client].iLevel < RESET_LEVEL){
		return false;
	}
	
	if (gClientData[client].iReset >= RESET_AMMOUNT_TO_START_PAYING_POINTS){
		
		if (gClientData[client].iHPoints < RESET_POINTS_AMMOUNT_TO_PAY_FEE || gClientData[client].iZPoints < RESET_POINTS_AMMOUNT_TO_PAY_FEE){
			return false;
		}
	}
	
	return true;
}

// COMMON HUMAN UPGRADES MENU
public Action showMenuHMejoras(int client){
	
	ZPlayer player = ZPlayer(client);
	bool isMaxed[3];
	if (player.iHDamageLevel == MAX_HUMAN_DAMAGE_LEVEL) isMaxed[0] = true;
	if (player.iHResistanceLevel == MAX_HUMAN_RESISTANCE_LEVEL) isMaxed[1] = true;
	if (player.iHDexterityLevel == MAX_HUMAN_DEXTERITY_LEVEL) isMaxed[2] = true;
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	Menu menu = new Menu(MejorasHMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	menu.SetTitle("%t", "Human upgrades menu title", player.iHPoints);
	
	// Options
	char sOption[80];
	char sDescription[32];
	
	// Loop vars
	int upgradeLevel[3];
	upgradeLevel[0] = player.iHDamageLevel;
	upgradeLevel[1] = player.iHResistanceLevel;
	upgradeLevel[2] = player.iHDexterityLevel;
	
	int upgradeCost[3];
	for (int i; i < view_as<int>(H_RESET); i++){
		upgradeCost[i] = getCommonHumanUpgradeCost(view_as<HMEJORAS>(i), upgradeLevel[i]);
	}
	
	/*
	char info[4];
	
	for (int i; i < view_as<int>(H_RESET); i++){
		if (isMaxed[i])
			Format(sOption, sizeof(sOption), "%t", "Human upgrades menu option 1 maxed", upgradeLevel[i]);
		else
			Format(sOption, sizeof(sOption), "%t", "Human upgrades menu option 1 not maxed", getCommonHumanUpgradeCost(view_as<HMEJORAS>(i), upgradeLevel[i]), upgradeLevel[i], MAX_HUMAN_DAMAGE_LEVEL);
		
		IntToString(i, info, sizeof(info));
		menu.AddItem(info, sOption, isMaxed[i] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}*/
	
	Format(sDescription, sizeof(sDescription), "\n +%0.1f%%", HUMAN_DAMAGE_BONUS*upgradeLevel[0]*100.0);
	if (isMaxed[0]) Format(sOption, sizeof(sOption), "%t", "Human upgrades menu option 1 maxed", upgradeLevel[0]);
	else Format(sOption, sizeof(sOption), 	"%t", "Human upgrades menu option 1 not maxed", upgradeCost[0], upgradeLevel[0], MAX_HUMAN_DAMAGE_LEVEL);
	
	Format(sOption, sizeof(sOption), "%s %s", sOption, sDescription);
	menu.AddItem("0", sOption, isMaxed[0] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	Format(sDescription, sizeof(sDescription), "\n +%i HP | +%i armor", HUMAN_RESISTANCE_HEALTH_BONUS*upgradeLevel[1], HUMAN_RESISTANCE_ARMOR_BONUS*upgradeLevel[1]);
	if (isMaxed[1]) Format(sOption, sizeof(sOption), "%t", "Human upgrades menu option 2 maxed", upgradeLevel[1]);
	else Format(sOption, sizeof(sOption), 	"%t", "Human upgrades menu option 2 not maxed", upgradeCost[1], upgradeLevel[1], MAX_HUMAN_RESISTANCE_LEVEL);
	
	Format(sOption, sizeof(sOption), "%s %s", sOption, sDescription);
	menu.AddItem("1", sOption, isMaxed[1] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	Format(sDescription, sizeof(sDescription), "\n +%0.1f%% speed | +%0.1f%% grav", HUMAN_DEXTERITY_SPEED_BONUS*upgradeLevel[2]*100.0, HUMAN_DEXTERITY_SPEED_BONUS*upgradeLevel[2]*100.0);
	if (isMaxed[2]) Format(sOption, sizeof(sOption), "%t", "Human upgrades menu option 3 maxed", upgradeLevel[2]);
	else Format(sOption, sizeof(sOption), 	"%t", "Human upgrades menu option 3 not maxed", upgradeCost[2], upgradeLevel[2], MAX_HUMAN_DEXTERITY_LEVEL);
	
	Format(sOption, sizeof(sOption), "%s %s\n ", sOption, sDescription);
	menu.AddItem("2", sOption, isMaxed[2] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	if (player.bRecentlyRegistered){
		Format(sOption, sizeof(sOption), "Continuar");
		menu.AddItem("5", sOption, (player.iHPoints == 200) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		
		menu.ExitButton = false;
	}
	else{
		Format(sOption, sizeof(sOption), "%t", "Reset points option", RESET_BONUS_COST);
		menu.AddItem("5", sOption, (player.iHPoints >= RESET_BONUS_COST && !playerUpgradesAreZero(client, true)) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		
		menu.ExitButton = true;
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}
public int MejorasHMenuHandler(Menu menu, MenuAction action, int client, int selection){
	ZPlayer p = ZPlayer (client);
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			switch(selection){
				case H_DAMAGE: {
					if(p.iHPoints >= (p.iHDamageLevel+1)*HUMAN_DAMAGE_COST && p.iHDamageLevel < MAX_HUMAN_DAMAGE_LEVEL){
						p.iHPoints -= (p.iHDamageLevel+1)*HUMAN_DAMAGE_COST;
						p.iHDamageLevel++;
						TranslationPrintToChat(client, "Human upgrade 1 successful", p.iHDamageLevel);
					}
					else TranslationPrintToChat(client, "Not enought human points");
				}
				case H_RESISTANCE: {
					if(p.iHPoints >= (p.iHResistanceLevel+1)*HUMAN_RESISTANCE_COST && p.iHResistanceLevel < MAX_HUMAN_RESISTANCE_LEVEL){
						p.iHPoints -= (p.iHResistanceLevel+1)*HUMAN_RESISTANCE_COST;
						p.iHResistanceLevel++;
						TranslationPrintToChat(client, "Human upgrade 2 successful", p.iHResistanceLevel);
					}
					else TranslationPrintToChat(client, "Not enought human points");
				}
				case H_DEXTERITY: {
					if(p.iHPoints >= (p.iHDexterityLevel+1)*HUMAN_DEXTERITY_COST && p.iHDexterityLevel < MAX_HUMAN_DEXTERITY_LEVEL){
						p.iHPoints -= (p.iHDexterityLevel+1)*HUMAN_DEXTERITY_COST;
						p.iHDexterityLevel++;
						TranslationPrintToChat(client, "Human upgrade 3 successful", p.iHDexterityLevel);
					}
					else TranslationPrintToChat(client, "Not enought human points");
				}
				case H_RESET:{
					if (p.bRecentlyRegistered){
						showMenuZMejoras(client);
					}
					else if(p.iHPoints >= RESET_BONUS_COST){
						p.iHPoints -= RESET_BONUS_COST;
						p.resetPoints();
					}
				}
			}
			
			if (!(p.bRecentlyRegistered && selection == view_as<int>(H_RESET))){
				showMenuHMejoras(client);
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// COMMON ZOMBIE UPGRADES MENU
public Action showMenuZMejoras(int client){
	ZPlayer player = ZPlayer(client);
	
	bool isMaxed[3];
	if (player.iZHealthLevel == MAX_ZOMBIE_HEALTH_LEVEL) isMaxed[0] = true;
	if (player.iZDamageLevel == MAX_ZOMBIE_DAMAGE_LEVEL) isMaxed[1] = true;
	if (player.iZDexterityLevel == MAX_ZOMBIE_DEXTERITY_LEVEL) isMaxed[2] = true;
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	Menu menu = new Menu(MejorasZMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	menu.SetTitle("%t", "Zombie upgrades menu title", player.iZPoints);
	
	// Options
	char sOption[80];
	char sDescription[32];
	
	// Loop vars
	int upgradeLevel[3];
	upgradeLevel[0] = player.iZHealthLevel;
	upgradeLevel[1] = player.iZDamageLevel;
	upgradeLevel[2] = player.iZDexterityLevel;
	
	int upgradeCost[3];
	for (int i; i < view_as<int>(Z_RESET); i++){
		upgradeCost[i] = getCommonZombieUpgradeCost(view_as<ZMEJORAS>(i), upgradeLevel[i]);
	}
	
	FormatEx(sDescription, sizeof(sDescription), "\n +%0.1f%%", ZOMBIE_HEALTH_BONUS*upgradeLevel[0]*100.0);
	//ReplaceString(sDescription, sizeof(sDescription), "PCT", "%%", true);
	if (isMaxed[0]) FormatEx(sOption, sizeof(sOption), "%t", "Zombie upgrades menu option 1 maxed", player.iZHealthLevel);
	else FormatEx(sOption, sizeof(sOption), "%t", "Zombie upgrades menu option 1 not maxed", ((player.iZHealthLevel+1) * ZOMBIE_HEALTH_COST), player.iZHealthLevel, MAX_ZOMBIE_HEALTH_LEVEL);
	
	Format(sOption, sizeof(sOption), "%s %s", sOption, sDescription);
	menu.AddItem("0", sOption, isMaxed[0] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	FormatEx(sDescription, sizeof(sDescription), "\n +%0.1f%%", ZOMBIE_DAMAGE_BONUS*upgradeLevel[1]*100.0);
	//ReplaceString(sDescription, sizeof(sDescription), "PCT", "%%", true);
	if (isMaxed[1]) FormatEx(sOption, sizeof(sOption), "%t", "Zombie upgrades menu option 2 maxed", player.iZDamageLevel);
	else FormatEx(sOption, sizeof(sOption), "%t", "Zombie upgrades menu option 2 not maxed", ((player.iZDamageLevel +1) * ZOMBIE_DAMAGE_COST), player.iZDamageLevel, MAX_ZOMBIE_DAMAGE_LEVEL);
	
	Format(sOption, sizeof(sOption), "%s %s", sOption, sDescription);
	menu.AddItem("1", sOption, isMaxed[1] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	FormatEx(sDescription, sizeof(sDescription), "\n +%0.1f%% speed | +%0.1f%% grav", ZOMBIE_DEXTERITY_SPEED_BONUS*upgradeLevel[2]*100.0, ZOMBIE_DEXTERITY_GRAVITY_BONUS*upgradeLevel[2]*100.0);
	//ReplaceString(sDescription, sizeof(sDescription), "PCT", "%%", true);
	if (isMaxed[2]) FormatEx(sOption, sizeof(sOption), "%t", "Zombie upgrades menu option 3 maxed", player.iZDexterityLevel);
	else FormatEx(sOption, sizeof(sOption), "%t", "Zombie upgrades menu option 3 not maxed", ((player.iZDexterityLevel+1) * ZOMBIE_DEXTERITY_COST), player.iZDexterityLevel, MAX_ZOMBIE_DEXTERITY_LEVEL);
	
	Format(sOption, sizeof(sOption), "%s %s\n ", sOption, sDescription);
	menu.AddItem("2", sOption, isMaxed[2] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	if (player.bRecentlyRegistered){
		FormatEx(sOption, sizeof(sOption), "Continuar");
		menu.AddItem("5", sOption, (player.iZPoints == 200) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		
		menu.ExitButton = false;
	}
	else{
		FormatEx(sOption, sizeof(sOption), "%t", "Reset points option", RESET_BONUS_COST);
		menu.AddItem("5", sOption, (player.iZPoints >= RESET_BONUS_COST && !playerUpgradesAreZero(client, false)) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		
		menu.ExitButton = true;
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}
public int MejorasZMenuHandler(Menu menu, MenuAction action, int client, int selection){
	ZPlayer p = ZPlayer (client);
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			switch(selection){
				case Z_HEALTH: {
					if(p.iZPoints >= (p.iZHealthLevel+1)*ZOMBIE_HEALTH_COST && p.iZHealthLevel < MAX_ZOMBIE_HEALTH_LEVEL){
						p.iZPoints -= (p.iZHealthLevel+1)*ZOMBIE_HEALTH_COST;
						p.iZHealthLevel++;
						TranslationPrintToChat(client, "Zombie upgrade 1 successful", p.iZHealthLevel);
					}
					else TranslationPrintToChat(client, "Not enought zombie points");
				}
				case Z_DAMAGE: {
					if(p.iZPoints >= (p.iZDamageLevel+1)*ZOMBIE_DAMAGE_COST && p.iZDamageLevel < MAX_ZOMBIE_DAMAGE_LEVEL){
						p.iZPoints -= (p.iZDamageLevel+1)*ZOMBIE_DAMAGE_COST;
						p.iZDamageLevel++;
						TranslationPrintToChat(client, "Zombie upgrade 2 successful", p.iZDamageLevel);
					}
					else TranslationPrintToChat(client, "Not enought zombie points");
				}
				case Z_DEXTERITY: {
					if(p.iZPoints >= (p.iZDexterityLevel+1)*ZOMBIE_DEXTERITY_COST && p.iZDexterityLevel < MAX_ZOMBIE_DEXTERITY_LEVEL){
						p.iZPoints -= (p.iZDexterityLevel+1)*ZOMBIE_DEXTERITY_COST;
						p.iZDexterityLevel++;
						TranslationPrintToChat(client, "Zombie upgrade 3 successful", p.iZDexterityLevel);
					}
					else TranslationPrintToChat(client, "Not enought zombie points");
				}
				case Z_RESET:{
					if (p.bRecentlyRegistered){
						JoinPlayer(client);
						return 0;
					}
					else if(p.iZPoints >= RESET_BONUS_COST){
						p.iZPoints -= RESET_BONUS_COST;
						p.resetPoints(true);
					}
				}
			}
			
			if (!(p.bRecentlyRegistered && selection == view_as<int>(Z_RESET))){
				showMenuZMejoras(client);
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

bool playerUpgradesAreZero(int client, bool human){
	
	ZPlayer player = ZPlayer(client);
	
	if (human && !player.iHDamageLevel && !player.iHResistanceLevel && !player.iHDexterityLevel)
		return true;
	else if (!human && !player.iZHealthLevel && !player.iZDamageLevel && !player.iZDexterityLevel)
		return true;
	
	return false;
}

// GOLDEN HUMAN UPGRADES MENU
public Action showMenuHGoldenMejoras(int client){
	ZPlayer player = ZPlayer(client);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	Menu menu = new Menu(MejorasHGoldenMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	menu.SetTitle("%t", "Human golden upgrades menu title", player.iHGoldenPoints);
	
	// Options
	char sOption[64];
	char sDescription[32];
	char sBuffer[64];
	char sNum[4];
	
	for (int i; i < view_as<int>(HG_RESET); i++){
		
		IntToString(i, sNum, sizeof(sNum));
		
		if (gClientData[client].iGoldenHUpgradeLevel[i] == GOLDEN_UPGRADES_MAXLEVEL){
			FormatEx(sBuffer, sizeof(sBuffer), "Human golden upgrades menu option %d maxed", i+1);
			FormatEx(sDescription, sizeof(sDescription), "\n +%0.1f%%", GoldenUpgrade(getUpgradeIndexByUpgradeId(view_as<GoldenUpgrades>(i))).getBuffPercentage(gClientData[client].iGoldenHUpgradeLevel[i]));
			
			FormatEx(sOption, sizeof(sOption), "%t %s", sBuffer, gClientData[client].iGoldenHUpgradeLevel[i], sDescription);
			menu.AddItem(sNum, sOption, ITEMDRAW_DISABLED);
		}
		else{
			FormatEx(sBuffer, sizeof(sBuffer), "Human golden upgrades menu option %d not maxed", i+1);
			FormatEx(sDescription, sizeof(sDescription), "\n +%0.1f%%", GoldenUpgrade(getUpgradeIndexByUpgradeId(view_as<GoldenUpgrades>(i))).getBuffPercentage(gClientData[client].iGoldenHUpgradeLevel[i]));
			
			FormatEx(sOption, sizeof(sOption), "%t %s", sBuffer, GoldenUpgrade(getUpgradeIndexByUpgradeId(view_as<GoldenUpgrades>(i))).getCost(gClientData[client].iGoldenHUpgradeLevel[i]), gClientData[client].iGoldenHUpgradeLevel[i], GOLDEN_UPGRADES_MAXLEVEL, sDescription);
			menu.AddItem(sNum, sOption, ITEMDRAW_DEFAULT);
		}
	}
	
	IntToString(view_as<int>(HG_RESET), sNum, sizeof(sNum));
	
	FormatEx(sOption, sizeof(sOption), "%t", "Reset points option", 0);
	menu.AddItem(sNum, sOption, GoldenUpgradesAreZero(client, true) ?  ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}
public int MejorasHGoldenMenuHandler(Menu menu, MenuAction action, int client, int selection){
	ZPlayer p = ZPlayer (client);
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			
			if (selection == view_as<int>(HG_RESET)){
				
				if (gClientData[client].iGoldenHUpgradeLevel[H_LMHP] != 0){
					// Remove planted lasermines
					RemoveLasermines(client, false);
				}
				
				for (int i; i < view_as<int>(HG_RESET); i++){
					gClientData[client].iGoldenHUpgradeLevel[i] = 0;
				}
				gClientData[client].iHGoldenPoints = gClientData[client].iReset;
			}
			else{
				
				if (gClientData[client].iGoldenHUpgradeLevel[selection] == GOLDEN_UPGRADES_MAXLEVEL){
					return 0;
				}
			
				int cost = GoldenUpgrade(getUpgradeIndexByUpgradeId(view_as<GoldenUpgrades>(selection))).getCost(gClientData[client].iGoldenHUpgradeLevel[selection]);
				if (p.iHGoldenPoints >= cost){
					p.iHGoldenPoints -= cost;
					gClientData[client].iGoldenHUpgradeLevel[selection]++;
					
					char sBuffer[64];
					
					/*char sNum[8];
					IntToString(selection+1, sNum, sizeof(sNum));*/
					FormatEx(sBuffer, sizeof(sBuffer), "Human golden upgrade %d successful", selection+1);
					TranslationPrintToChat(client, sBuffer, gClientData[client].iGoldenHUpgradeLevel[selection]);
				}
				else TranslationPrintToChat(client, "Not enought golden human points");
			}			
			
			showMenuHGoldenMejoras(client);
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// GOLDEN ZOMBIE UPGRADES MENU
public Action showMenuZGoldenMejoras(int client){
	ZPlayer player = ZPlayer(client);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	Menu menu = new Menu(MejorasZGoldenMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	menu.SetTitle("%t", "Zombie golden upgrades menu title", player.iZGoldenPoints);
	
	// Options
	char sOption[64];
	char sDescription[32];
	char sBuffer[64];
	char sNum[4];
	
	int num;
	
	for (int i = view_as<int>(HG_RESET)+1; i < view_as<int>(ZG_RESET); i++){
		
		num = i-(view_as<int>(HG_RESET))-1;
		
		//LogError("NUM IS %i", num);
		
		IntToString(num, sNum, sizeof(sNum));
		
		if (gClientData[client].iGoldenZUpgradeLevel[num] == GOLDEN_UPGRADES_MAXLEVEL){
			Format(sBuffer, sizeof(sBuffer), "Zombie golden upgrades menu option %d maxed", num+1);
			Format(sDescription, sizeof(sDescription), "\n +%0.1f%%", GoldenUpgrade(getUpgradeIndexByUpgradeId(view_as<GoldenUpgrades>(i))).getBuffPercentage(gClientData[client].iGoldenZUpgradeLevel[num]));
			
			Format(sOption, sizeof(sOption), "%t %s", sBuffer, gClientData[client].iGoldenZUpgradeLevel[num], sDescription);
			menu.AddItem(sNum, sOption, ITEMDRAW_DISABLED);
		}
		else{
			//LogError("NUM IS STILL %i", num);
			Format(sBuffer, sizeof(sBuffer), "Zombie golden upgrades menu option %d not maxed", num+1);
			//LogError("NUM AFTER IS %i, BUFFER IS %s", num, sBuffer);
			Format(sDescription, sizeof(sDescription), "\n +%0.1f%%", GoldenUpgrade(getUpgradeIndexByUpgradeId(view_as<GoldenUpgrades>(i))).getBuffPercentage(gClientData[client].iGoldenZUpgradeLevel[num]));
			
			Format(sOption, sizeof(sOption), "%t %s", sBuffer, GoldenUpgrade(getUpgradeIndexByUpgradeId(view_as<GoldenUpgrades>(i))).getCost(gClientData[client].iGoldenZUpgradeLevel[num]), gClientData[client].iGoldenZUpgradeLevel[num], GOLDEN_UPGRADES_MAXLEVEL, sDescription);
			menu.AddItem(sNum, sOption, ITEMDRAW_DEFAULT);
		}
	}
	
	IntToString(view_as<int>(HG_RESET)-view_as<int>(ZG_RESET)-1, sNum, sizeof(sNum));
	
	FormatEx(sOption, sizeof(sOption), "%t", "Reset points option", 0);
	menu.AddItem(sNum, sOption, GoldenUpgradesAreZero(client, false) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}
public int MejorasZGoldenMenuHandler(Menu menu, MenuAction action, int client, int selection){
	ZPlayer p = ZPlayer (client);
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			
			if (selection == view_as<int>(ZG_RESET)-view_as<int>(HG_RESET)-1){
				for (int i; i < view_as<int>(HG_RESET); i++){
					gClientData[client].iGoldenZUpgradeLevel[i] = 0;
				}
				gClientData[client].iZGoldenPoints = gClientData[client].iReset;
			}
			else{
				if (gClientData[client].iGoldenZUpgradeLevel[selection] == GOLDEN_UPGRADES_MAXLEVEL){
					return 0;
				}
				
				int cost = GoldenUpgrade(getUpgradeIndexByUpgradeId(view_as<GoldenUpgrades>(selection))).getCost(gClientData[client].iGoldenZUpgradeLevel[selection]);
				if (p.iZGoldenPoints >= cost){
					p.iZGoldenPoints -= cost;
					gClientData[client].iGoldenZUpgradeLevel[selection]++;
					
					char sBuffer[64];
					
					/*char sNum[8];
					IntToString(selection+1, sNum, sizeof(sNum));*/
					Format(sBuffer, sizeof(sBuffer), "Zombie golden upgrade %d successful", selection+1);
					TranslationPrintToChat(client, sBuffer, gClientData[client].iGoldenZUpgradeLevel[selection]);
				}
				else TranslationPrintToChat(client, "Not enought golden zombie points");
			}		
			
			showMenuZGoldenMejoras(client);
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// LOGIN MENU
/*
public Action showLoginMenu(int client, bool disableLogin){
	Menu menu = new Menu(LoginMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "Register menu title");
	
	static char option[24];
	
	Format(option, sizeof(option), "%t", "Register menu option 1");
	menu.AddItem("0", option, disableLogin ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	Format(option, sizeof(option), "%t", "Register menu option 2");
	menu.AddItem("1", option);
	menu.ExitButton = false;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int LoginMenuHandler(Menu menu, MenuAction action, int client, int selection){
	ZPlayer player = ZPlayer(client);
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			//player.bInUser = true;
			switch(selection){
				case 0: loginPlayer(player.id);
				case 1: {
					player.bInUser = true;
					showIndicacionesRegister(client, false);
				}
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}*/

/************************************************************************************************* */
// 				NEW REGISTER/LOGIN MENU
/************************************************************************************************* */
// LOGIN MENU
public Action showLoginMenu2(int client){
	Menu menu = new Menu(LoginMenuHandler2, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	gClientData[client].InfoMenuPage = 0;
	
	menu.SetTitle("%t\n\n ", "Register menu title");
	
	static char option[32];
	
	FormatEx(option, sizeof(option), "%t", "Register menu option 1");
	menu.AddItem("0", option);
	
	//FormatEx(option, sizeof(option), "%t", "Register menu option 2");
	//menu.AddItem("1", option);
	
	menu.ExitButton = false;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int LoginMenuHandler2(Menu menu, MenuAction action, int client, int selection){

	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			//player.bInUser = true;
			switch(selection){
				/*case 0:{
					// Create account with minimal data
					static char query[64];
					FormatEx(query, sizeof(query), "INSERT INTO Players(steamid) VALUES(%d)", GetSteamAccountID(client));
					gServerData.DBI.Query(createAccountCallback, query, GetClientUserId(client));
					
					TranslationPrintToChat(client, "We will try to create character with your name");
				}*/
				case 0:{
					showInfoMenu(client, 0);
				}
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

public Action showInfoMenu(int client, int iPage){
	Menu menu = new Menu(infoMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	// Sets the global language target
	//SetGlobalTransTarget(client);
	
	switch (iPage){
		case 0:{
			menu.SetTitle("Información general del servidor (1/3)\n \n Debes subir de nivel para progresar!\n \n Para subir de nivel debes infectar/matar humanos siendo zombie\n o dañar zombies siendo humano!\n ");
		}
		case 1:{
			menu.SetTitle("Información general del servidor (2/3)\n \n Llegar a nivel 400 permite hacer un RESET\n \n Hacer reset permite desbloquear armas, clases y mejoras para tu personaje\n \n Resetear te hará subir de TIER, desbloquear recompensas\n como armas, clases, máscaras y tags!\n ");
		}
		case 2:{
			menu.SetTitle("Información general del servidor (3/3)\n \n Existen beneficios VIP que aumentarán la\n velocidad con la que ganas experiencia y puntos!\n \n Puedes comprarlo desde nuestra página web www.piu-games.com\n \nTambién puedes probarlo gratis por 7 días usando el comando !pruebavip\n ");
		}
	}
	
	static char option[32];
	
	FormatEx(option, sizeof(option), (iPage == 2) ? "Comenzar" : "Siguiente");
	menu.AddItem("0", option);
	
	menu.ExitButton = false;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int infoMenuHandler(Menu menu, MenuAction action, int client, int selection){
	
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			switch(selection){
				case 0:{
					
					// Different actions depending page
					switch (gClientData[client].InfoMenuPage){
						
						case 0, 1, 2:{
							showInfoMenu(client, gClientData[client].InfoMenuPage);
							gClientData[client].InfoMenuPage++;
						}
						default:{
							// Create account with minimal data
							static char query[64];
							FormatEx(query, sizeof(query), "INSERT INTO Players(steamid) VALUES(%d)", GetSteamAccountID(client));
							gServerData.DBI.Query(createAccountCallback, query, GetClientUserId(client), DBPrio_High);
						
							TranslationPrintToChat(client, "We will try to create character with your name");
							
							gClientData[client].InfoMenuPage = 0;
						}
					}
				}
			}	
		}
		
		case MenuAction_End:{
			
			if (IsPlayerExist(client, false)){
				gClientData[client].InfoMenuPage = 0;
			}
			
			delete menu;
		}
	}
	return 0;
}

public void createAccountCallback(Database db, DBResultSet results, const char[] error, any data){
	
	int client = 0;

	/* Make sure the client didn't disconnect while the thread was running */
	if ((client = GetClientOfUserId(data)) == 0){
		return;
	}
	
	if(StrEqual(error, "")){
		//showMenuCuenta(client);
		setCharacterNameFromSteamName(client);
		createCharacter(client);
	}
	else{
		LogError("[REGISTER] error: %s", error);
	}
}

/************************************************************************************************* */
/************************************************************************************************* */
// ADD OPTIONAL DATA MENU
public Action showMenuAddOptionalData(int client, UserAction action, bool canAccept){
	
	if (!IsPlayerExist(client))
		return Plugin_Handled;

	// Sets the global language target
	SetGlobalTransTarget(client);

	Menu menu;

	switch (action){
		case UserAction_AddEmail:{
			menu = new Menu(AddEmailHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);

			menu.SetTitle("%t", "Add optional data menu title email");
		}
		case UserAction_AddPassword:{
			menu = new Menu(AddPasswordHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
			menu.SetTitle("%t", "Add optional data menu title password");			
		}
		default:{
			return Plugin_Handled;
		}
	}
	
	static char option[24];
	
	FormatEx(option, sizeof(option), "%t", "Add optional data menu option 1");
	menu.AddItem("0", option, canAccept ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	FormatEx(option, sizeof(option), "%t", "Add optional data menu option 2");
	menu.AddItem("1", option);
	
	menu.ExitButton = false;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

// ADD EMAIL MENU HANDLER
public int AddEmailHandler(Menu menu, MenuAction action, int client, int selection){
	ZPlayer player = ZPlayer(client);
	
	if (!IsPlayerExist(client))
		return 0;
	
	switch(action){
		case MenuAction_Start:{
			player.bInPassword = false;
			player.bInCreatingCharacter = false;
		}
		
		case MenuAction_Select:{
			switch(selection) {
				case 0: {
					
					static char metaMail[32];
					users.GetString(client, metaMail, sizeof(metaMail));

					static char mail[64];
					gServerData.DBI.Escape(metaMail, mail, sizeof(mail));
					
					if (isEntryValidToSQL(mail, DATA_MAIL) != INPUT_OK){
						PrintToServer("[REGISTER] Not valid email address(%s).", mail);
						TranslationPrintToChat(client, "Not valid email address");
						showLoginMenu2(client);
						return 0;
					}

					player.bInUser = false;

					int userid = GetClientUserId(client);

					// Update email
					static char query[128];
					FormatEx(query, sizeof(query), "UPDATE Players SET email = '%s' WHERE steamid = %d", mail, GetSteamAccountID(client));
					gServerData.DBI.Query(AddEmailCallback, query, userid, DBPrio_Low);
				}
				case 1: {
					player.bInPassword = false;
					player.bInUser = false;
					player.bInCreatingCharacter = false;
					//showLoginMenu(client, false);
					TranslationPrintToChat(client, "Cancelling email addition");
					showMenuCuenta(client);
				}
				
			}
		}
		
		case MenuAction_End:{
			player.bInPassword = false;
			player.bInUser = false;
			player.bInCreatingCharacter = false;
			delete menu;
		}
	}
	return 0;
}
public void AddEmailCallback(Database db, DBResultSet results, const char[] error, any data){
	
	int client = 0;

	/* Make sure the client didn't disconnect while the thread was running */
	if ((client = GetClientOfUserId(data)) == 0){
		return;
	}
	
	static char mail[32];
	
	users.GetString(client, mail, sizeof(mail));
	
	if(StrEqual(error, "")){
		//TranslationPrintToChat(client, "Successfully registered", mail, pass);
		TranslationPrintToChat(client, "Email added", mail);
		ZPlayer(client).bHasMail = true;
	}
	else{
		if(StrContains(error, "email_UNIQUE") != -1){
			TranslationPrintToChat(client, "Email in use", mail);
		}
		else{
			LogError("[REGISTER] error: %s", error);
		}
		//PrintToChat(client, "[PIU] Email no pudo ser agregado!");
	}
	
	showMenuCuenta(client);
}

// ADD PASSWORD MENU HANDLER
public int AddPasswordHandler(Menu menu, MenuAction action, int client, int selection){
	ZPlayer player = ZPlayer(client);
	switch(action){
		case MenuAction_Start:{
			player.bInUser = false;
			player.bInCreatingCharacter = false;
		}
		
		case MenuAction_Select:{
			switch(selection) {
				case 0:{

					static char metaPass[32];
					passwords.GetString(client, metaPass, sizeof(metaPass));

					static char pass[64];
					gServerData.DBI.Escape(metaPass, pass, sizeof(pass));

					int userid = GetClientUserId(client);

					player.bInPassword = false;

					// Update password
					static char query[96];
					FormatEx(query, sizeof(query), "UPDATE Players SET contrasenia = '%s' WHERE steamid = %d", pass, GetSteamAccountID(client));
					gServerData.DBI.Query(AddPasswordCallback, query, userid, DBPrio_Low);
				}
				case 1:{
					player.bInPassword = false;
					player.bInUser = false;
					player.bInCreatingCharacter = false;
					//showLoginMenu2(client);
					TranslationPrintToChat(client, "Cancelling password addition");
					showMenuCuenta(client);
				}
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}
public void AddPasswordCallback(Database db, DBResultSet results, const char[] error, any data){
	
	int client = 0;

	// Make sure the client didn't disconnect while the thread was running
	if ((client = GetClientOfUserId(data)) == 0){
		return;
	}
	
	static char pass[32];
	
	passwords.GetString(client, pass, sizeof(pass));
	
	if(StrEqual(error, "")){
		//TranslationPrintToChat(client, "Successfully registered", mail, pass);
		TranslationPrintToChat(client, "Password added", pass);
		ZPlayer(client).bHasPassword = true;
	}
	else{
		LogError("[REGISTER] error: %s", error);			
		//PrintToChat(client, "[PIU] La contraseña no pudo ser agregada!");
	}
	
	showMenuCuenta(client);
}

// ACCOUNT MENU
// static bool for the menu toggle
public Action showMenuCuenta(int client){
	
	Menu menu = new Menu(CuentaMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	static char title[64];
	static char pName[32];
	GetClientName(client, pName, sizeof(pName));
	FormatEx(title, sizeof(title), "%t\n\n ", "Register message welcome", pName);
	
	menu.SetTitle(title);
	
	static char op[96];
	
	if (numCharacters[client]){
		
		static char name[32];
		charactersNames[client].GetString(0, name, sizeof(name));
		
		int itemdraw;
		
		if (charactersAccessLevels[client].Get(0) == BANNED_ACCESS){
			FormatEx(op, sizeof(op), "%s | %t", name, "Character is blocked");
			
			itemdraw = ITEMDRAW_DISABLED;
		}
		else{
			if (charactersResets[client].Get(0)){
				FormatEx(op, sizeof(op), "%t%s", "Characters menu display info 1 resets", name, charactersLevels[client].Get(0), charactersResets[client].Get(0), "\n\n ");
			}
			else{
				FormatEx(op, sizeof(op), "%t%s", "Characters menu display info 1 no resets", name, charactersLevels[client].Get(0), "\n\n ");
			}
			
			itemdraw = ITEMDRAW_DEFAULT;
		}
		
		menu.AddItem("0", op, itemdraw);
		/*
		int charactersDeltaLegacy = MAXCHARACTERS_LEGACY-numCharacters[client];
		if (charactersDeltaLegacy > 0){
			for(int j; j < charactersDeltaLegacy; j++){
				//FormatEx(op, sizeof(op), "%t%s", "Characters menu display info 2", (j == (MAXCHARACTERS_NEW-numCharacters[client])-1) ? "\n\n " : "");
				FormatEx(op, sizeof(op), "---%s", (j == (MAXCHARACTERS_LEGACY-1)) ? "\n\n " : "");
				menu.AddItem("notext", op, ITEMDRAW_NOTEXT);
			}
		}*/
	}
	else{
		FormatEx(op, sizeof(op), "%t%s", "Characters menu start game", "\n\n ");
		menu.AddItem("create", op);
	}
	
	// Fill the remaining spaces with NOTEXT
	for (int i = 1; i < MAXCHARACTERS_LEGACY; i++){
		FormatEx(op, sizeof(op), "---%s", (i == (MAXCHARACTERS_LEGACY-1)) ? "\n\n " : "");
		menu.AddItem("notext", op, ITEMDRAW_NOTEXT);
	}
	
	FormatEx(op, sizeof(op), "%t", (ZPlayer(client).bHasMail) ? "Email already associated" : "Create character add email");
	menu.AddItem("addEmail", op, (ZPlayer(client).bHasMail) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		
	FormatEx(op, sizeof(op), "%t\n\n ", (ZPlayer(client).bHasPassword) ? "Password already associated" : "Create character add password");
	menu.AddItem("addPassword", op, (ZPlayer(client).bHasPassword) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	if (MAXCHARACTERS_NEW - numCharacters[client] > 0){
		FormatEx(op, sizeof(op), "%t: %t", "Create character use current name", (gClientData[client].bUseMyName) ? "Translation ON" : "Translation OFF");
		menu.AddItem("currName", op);
	}
	
	menu.Pagination = MENU_NO_PAGINATION;
	menu.ExitButton = false;	
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int CuentaMenuHandler(Menu menu, MenuAction action, int client, int selection){
	
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			if (!IsPlayerExist(client))
				return 0;
			
			/*char buffer[16];
			menu.GetItem(selection, buffer, sizeof(buffer));*/
			
			ZPlayer player = ZPlayer(client);
			
			if (0 <= selection < MAXCHARACTERS_NEW){
				
				// If character slot is empty, register
				if(player.isSlotEmpty(selection)){
					if (gClientData[client].bUseMyName){
						
						setCharacterNameFromSteamName(client);
						createCharacter(client);
					}
					else{
						player.bInPassword = false;
						player.bInUser = false;
						player.bInCreatingCharacter = true;
						
						showCrearCharacter(client, false);
					}
				}
				else{ // character slot is used
					
					player.bInCreatingCharacter = false;
					
					player.iPjEnMenu = selection;//player.getIdPjInSlot(selection);
					player.iPjSeleccionado = player.getIdPjInSlot(player.iPjEnMenu);
					
					loadCharacterData(client, player.iPjSeleccionado);
					
					//player.bInGame = true;
					
					/*
					loadCharacterData(client, player.getIdPjInSlot(selection));
					player.bInCreatingCharacter = false;
					player.bInGame = true;
					*/
				}
			}
			else{
				
				switch (selection){
					case 5:{
						TranslationPrintToChat(client, "Type email in chat");
				
						player.bInPassword = false;
						player.bInUser = true;
						player.bInCreatingCharacter = false;
						
						showMenuAddOptionalData(client, UserAction_AddEmail, false);
					}
					case 6:{
						TranslationPrintToChat(client, "Type password in chat");
				
						player.bInPassword = true;
						player.bInUser = false;
						player.bInCreatingCharacter = false;
						
						showMenuAddOptionalData(client, UserAction_AddPassword, false);
					}
					case 7:{
						gClientData[client].bUseMyName = !gClientData[client].bUseMyName;
						showMenuCuenta(client);
					}
				}
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

void setCharacterNameFromSteamName(int client){
	static char name[32];
	FormatEx(name, sizeof(name), "%N", client);
	
	StripQuotes(name);
	ReplaceString(name, sizeof(name), "'", "", false);
	
	characterNames.SetString(client, name);
}

public void createCharacter(int client){
	
	if(gServerData.DBI == null)
		return;
	
	int steamid = GetSteamAccountID(client, true);

	int userid = GetClientUserId(client);
	
	char metaName[32];
	characterNames.GetString(client, metaName, sizeof(metaName));
	
	char scapedName[65];
	gServerData.DBI.Escape(metaName, scapedName, sizeof(scapedName));
	
	char query[160];
	FormatEx(query, sizeof(query), "CALL createCharacter(%d,\"%s\")", steamid, scapedName);
	
	//gServerData.DBI.Escape(query, query, sizeof(query));
	gServerData.DBI.Query(CreateCharacterCallback, query, userid, DBPrio_High);
}
public void CreateCharacterCallback(Database db, DBResultSet results, const char[] error, any data){
	
	int client = 0;

	/* Make sure the client didn't disconnect while the thread was running */
	if ((client = GetClientOfUserId(data)) == 0){
		return;
	}
	
	static char name[32], user[32];
	characterNames.GetString(client, name, sizeof(name));
	
	if (!StrEqual(error, "")){
		if(StrContains(error, "nombre_UNIQUE") != -1){
			TranslationPrintToChat(client, "Name already in use");
		}
		else{
			GetClientName(client, user, sizeof(user));
			PrintToChatAll("%s El usuario \x0b%s\x01 esta intentando crear un personaje pero no puede, por favor informar al staff.", SERVERSTRING, user);
			
			PrintToChat(client, "%s \x02ERROR!\x01 Intenta \x0bquitando los símbolos\x01 de tu nombre.", SERVERSTRING);

			LogError("[Create-Character] user %s is trying create character, error: %s", user, error);
		}
		ZPlayer(client).bInCreatingCharacter = true;
		ZPlayer(client).bInPassword = false;
		ZPlayer(client).bInUser = false;
		
		showCrearCharacter(client, false);

		return;
	}
	
	ZPlayer(client).bInCreatingCharacter = false;
	ZPlayer(client).bInPassword = false;
	ZPlayer(client).bInUser = false;
	
	ZPlayer(client).bRecentlyRegistered = true;
	
	TranslationPrintHintText(client, "Character successfully created", name);
	TranslationPrintToChat(client, "Registered message 1");
	TranslationPrintToChat(client, "Registered message 2");
	TranslationPrintToChat(client, "Registered message 3");
	
	TranslationPrintToChat(client, "Info message 8");
	
	loadCharacters(client);
}

// CHARACTERS MENU
//public Action showMenuCharacter(int client){
//	Menu menu = new Menu(IndCrearCharacterMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
//	ZPlayer p = ZPlayer(client);
//	char title[64];
//	char name[32];
//	charactersNames[client].GetString(p.iPjEnMenu, name, 32);
//	Format(title, 64, "Personaje: %s", name);
//	menu.SetTitle(title);
//	menu.AddItem("0", "Jugar");
//	menu.AddItem("1", "Borrar");
//	menu.AddItem("2", "Atrás");
//	menu.ExitButton = false;
//	
//	menu.Display(client, MENU_TIME_FOREVER);
//	return Plugin_Handled;
//}
//public int IndCrearCharacterMenuHandler(Menu menu, MenuAction action, int client, int selection){
//	ZPlayer player = ZPlayer(client);
//	switch(action){
//		case MenuAction_Start:{
//		}
//		
//		case MenuAction_Select:{
//			switch(selection) {
//				case 0: {
//					player.iPjSeleccionado = player.getIdPjInSlot(player.iPjEnMenu);
//					loadCharacterData(client, player.iPjSeleccionado);
//					player.bInCreatingCharacter = false;
//					player.bInGame = true;
//				}
//				case 1: showConfirmacionBorrar(client);
//				case 2:{
//					player.iPjEnMenu = -1;
//					loginPlayer(player.id);
//				}
//			}
//		}
//		
//		case MenuAction_End:{
//			delete menu;
//		}
//	}
//	return 0;
//}

// DELETE CONFIRM MENU
//public Action showConfirmacionBorrar(int client){
//	Menu menu = new Menu(confirmarBorrarHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
//	ZPlayer p = ZPlayer(client);
//	char title[128];
//	char name [32];
//	charactersNames[client].GetString(p.iPjEnMenu, name, 32);
//	Format(title, 128, "Estás seguro que deseas borrar el personaje %s?\n(No podrás recuperarlo)", name);
//	
//	menu.SetTitle(title);
//	menu.AddItem("0", "Sí");
//	menu.AddItem("1", "No");
//	menu.ExitButton = false;
//	
//	menu.Display(client, MENU_TIME_FOREVER);
//	return Plugin_Handled;
//}
//public int confirmarBorrarHandler(Menu menu, MenuAction action, int client, int selection){
//	ZPlayer player = ZPlayer(client);
//	switch(action){
//		case MenuAction_Start:{
//		}
//		
//		case MenuAction_Select:{
//			switch(selection) {
////				case 0: {
////					deleteCharacter(client);
////					player.setSlotEmpty(player.iPjEnMenu, true);
////					player.iPjEnMenu = -1;
////					loginPlayer(client);
////					PrintHintText(client, "Personaje eliminado con exito");
////				}
//				case 0: showMenuCharacter(client);
//			}
//		}
//		
//		case MenuAction_End:{
//			delete menu;
//		}
//	}
//	return 0;
//}

// CREATE CHARACTER MENU
public Action showCrearCharacter(int client, bool canAccept){
	Menu menu = new Menu(crearCharacterHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "Create character menu title");
	
	char option[24];
	
	Format(option, sizeof(option), "%t", "Create character menu option 1");
	menu.AddItem("0", option, canAccept ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	Format(option, sizeof(option), "%t", "Create character menu option 2");
	menu.AddItem("1", option);
	
	menu.ExitButton = false;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int crearCharacterHandler(Menu menu, MenuAction action, int client, int selection){
	ZPlayer player = ZPlayer(client);
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			switch(selection) {
				case 0: {
					player.bInCreatingCharacter = false;
					createCharacter(client);
				}
				case 1: showMenuCuenta(client);
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// PARTY MENU
public Action showMenuParty(int client, int args){
	ZPlayer player = ZPlayer(client);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	if (!player.bStaff && !allowParty){
		TranslationPrintToChat(client, "Party under development");
		return Plugin_Handled;
	}
	
	if (iPlayersQuantity < PARTY_MIN_PLAYERS_ONLINE){
		TranslationPrintToChat(client, "Not enought online users to use party");
		return Plugin_Handled;
	}
	
	Menu menu = new Menu(MenuPartyHandler, MenuAction_Start|MenuAction_Select|MenuAction_Cancel|MenuAction_End);
	
	menu.SetTitle("%t", "Party menu title");
	
	static char buffer[256], buf[8], names[32];
	static char option[48];
	
	if (gClientData[client].bInParty){
		
		int partyID = findPartyByUID(gClientData[client].iPartyUID);
		
		if (partyID == -1){
			LogError("[PARTY] Encontrado player %N, id %d en party pero findParty da %d", client, client, partyID);
			partyDestroyPartyUID(gClientData[client].iPartyUID);
			return Plugin_Handled;
		}
		
		ZParty party = ZParty(partyID);
		ZPlayer member;
		
		for (int i = 0; i < party.length(); i++){
			member = ZPlayer(party.getMemberByArrayId(i));
			
			if(!IsPlayerExist(member.id)){
				continue;
			}
			
			if(!member.bLogged){
				continue;
			}
			
			// obtains possible targets name
			GetClientName(member.id, names, sizeof(names));
			
			if (args == 1){
				FormatEx(buffer, sizeof(buffer), "%t%s", "Kick client from party", names, member.iLevel, member.iReset, (i == party.length()-1) ? "\n\n " : "");
			}
			else{
				FormatEx(buffer, sizeof(buffer), "%s (Level %d | RR %d)%s", names, member.iLevel, member.iReset, (i == party.length()-1) ? "\n\n " : "");
			}
			
			//obtains it's id and transform it to int
			IntToString(member.id, buf, sizeof(buf));
			
			//lets put it in the menu
			menu.AddItem(buf, buffer, (player.id != member.id && args == 1 && player.id == party.iOwner) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		}
		
		if (party.length() < PARTY_MAX_MEMBERS){
			for (int i = 0; i < PARTY_MAX_MEMBERS-party.length(); i++){
				menu.AddItem("n", "", ITEMDRAW_SPACER);
			}
		}
		
		FormatEx(option, sizeof(option), "%t", "Party menu option 1");
		menu.AddItem("4", option);
		
		char sTemp[32];
		FormatEx(sTemp, sizeof(sTemp), "Party menu option 2 %s", (args == 0) ? "enable" : "disable");
		
		FormatEx(option, sizeof(option), "%t", sTemp);
		menu.AddItem("5", option, (party.iOwner == client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		
		FormatEx(option, sizeof(option), "%t", "Party menu option 3");
		menu.AddItem("6", option);
	}
	else{
		for (int i = 0; i < PARTY_MAX_MEMBERS; i++){
			//FormatEx(option, sizeof(option), "Party member %i%s", i+1, (i == PARTY_MAX_MEMBERS-1) ? "\n\n " : "");
			FormatEx(option, sizeof(option), "---ESPACIO DISPONIBLE---%s", (i == PARTY_MAX_MEMBERS-1) ? "\n\n " : "");
			menu.AddItem("n", option, ITEMDRAW_DISABLED);
		}
		
		FormatEx(option, sizeof(option), "%t", "Party menu option 1");
		menu.AddItem("4", option);
	}
	
	//menu.Pagination = MENU_NO_PAGINATION;
	menu.ExitBackButton = true;
	
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}
public int MenuPartyHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			
			switch (selection){
				case 0, 1, 2:{
					// Buffer for info item selected
					char sTarget[32];
					
					//Buffer for id target
					int target;
					
					//obtains id of target as string
					menu.GetItem(selection, sTarget, sizeof(sTarget));
					
					//Converts to int
					StringToIntEx(sTarget, target);
					
					if (target != client){
						
						if (gClientData[client].bInParty && gClientData[target].bInParty){
							if (gClientData[client].iPartyUID == gClientData[target].iPartyUID){
								leaveParty(target, 0);
								PrintToChat(client, "%s Miembro \x07%N\x01 expulsado de la party.", SERVERSTRING, target);
							}
						}
					}
					else{
						PrintToChat(client, "%s No puedes expulsarte a ti mismo!", SERVERSTRING);
					}
					
					showMenuParty(client, view_as<int>(gClientData[client].bPartyMenuKicks));
				}
				case 3: showMenuPartyInvitation(client, 0);
				case 4:{
					gClientData[client].bPartyMenuKicks = !gClientData[client].bPartyMenuKicks;
					showMenuParty(client, view_as<int>(gClientData[client].bPartyMenuKicks));
				}
				case 5: leaveParty(client, 0);
			}
		}
		case MenuAction_Cancel:{
			if(selection == MenuCancel_ExitBack){
				showMainMenu(client, 0);
			}
		}
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// PARTY INVITATION MENU
public Action showMenuPartyInvitation(int client, int args){
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	ZPlayer player = ZPlayer(client);
	
	if (!player.bStaff && !allowParty){
		TranslationPrintToChat(client, "Party under development");
		return Plugin_Handled;
	}
	
	if (fnGetPlaying() < PLAYERS_TO_GAIN){
		TranslationPrintToChat(client, "Not enought online users to use party");
		return Plugin_Handled;
	}
	
	Menu menu = new Menu(MenuPartyInvitationHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	menu.SetTitle("%t", "Party invitation menu title");
	
	char buffer[128], names[32], buf[8];
	
	int totalClients = 0;
	for(int i = 1; i <= MaxClients; i++){
		
		if (!IsPlayerExist(i) || i == client) continue;
		
		if (!gClientData[i].bLoaded) continue;
		
		if (gClientData[i].bInParty) continue;
		
		if (gClientData[i].bAFK) continue;
		
		totalClients++;
		
		// obtains possible targets name
		GetClientName(i, names, sizeof(names));
		
		FormatEx(buffer, sizeof(buffer), "%s (Level %d | RR %d)", names, gClientData[i].iLevel, gClientData[i].iReset);
		
		//obtains it's id and transform it to string
		IntToString(i, buf, sizeof(buf));
		
		//lets put it in the menu
		menu.AddItem(buf, buffer);
	}
	
	if (!totalClients){
		PrintToChat(client, "%s No hay usuarios disponibles para party.", SERVERSTRING);
		return Plugin_Handled;
	}
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}
public int MenuPartyInvitationHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			// Buffer for info item selected
			char inv[32];
			
			//Buffer for id invited
			int invited;
			
			//obtains id of invited as string
			menu.GetItem(selection, inv, sizeof(inv));
			
			//Converts to int
			StringToIntEx(inv, invited);
			ZPlayer target = ZPlayer(invited);
			
			if(IsPlayerExist(target.id) && target.bLogged){
				
				if(target.bReceivePartyInv && !gClientData[target].bInParty){
					showMenuInvParty(invited, client);
					PrintToChat(client, "%s Invitación de \x03party enviada a \x05%N\x01.", SERVERSTRING, invited);
				}
				else if(gClientData[target].bInParty){
					PrintToChat(client, "%s \x05%N\x01 ya se encuentra en \x03party\x01!", SERVERSTRING, invited);
				}
				else{
					PrintToChat(client, "%s \x05%N\x01 tiene las invitaciones de party \x07DESACTIVADAS\x01.", SERVERSTRING, invited);
				}
				
			}
			
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// PARTY INVITATIONS MENU
public Action showMenuInvParty(int invitedId, int senderId){
	char buffer[32];
	char sender[8];
	char title [128];
	ZPlayer p = ZPlayer(invitedId);
	if(gClientData[invitedId].bInParty || !IsPlayerExist(p.id) || !p.bLogged){
		PrintToChat(senderId, "%s \x05%s\x01 ya esta en party!", SERVERSTRING);
		return Plugin_Handled;
	}
	
	//Obtengo el nombre de la persona que invito
	GetClientName(senderId, buffer, sizeof(buffer));
	
	//Paso el id de la persona que invito a string
	IntToString(senderId, sender, sizeof(sender));
	
	FormatEx(title, sizeof(title), "Aceptar invitación de party de: %s", buffer);
	Menu menu = new Menu(MenuInvPartyHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	menu.SetTitle(title);
	menu.AddItem(sender, "Sí");
	menu.AddItem(sender, "No");
	menu.ExitButton = false;
	
	
	menu.Display(invitedId, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int MenuInvPartyHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			
			if(!IsPlayerExist(client))
				return 0;
			
			char sender[32];
			menu.GetItem(selection, sender, sizeof(sender));
			
			int senderid;
			StringToIntEx(sender, senderid);
			
			if(!IsPlayerExist(senderid))
				return 0;
				
			bool created = false;
			PartyError added = PARTY_ERROR_ANY;
			
			switch(selection){
				case 0:{
					
					if (!IsPlayerExist(client)){
						return 0;
					}
					
					if (!IsPlayerExist(senderid)){
						PrintToChat(client, "%s Esta invitación caducó.", SERVERSTRING);
						return 0;
					}
					
					if (gClientData[client].bInParty){ // invited client is already in party
						PrintToChat(client, "%s Ya estás en party.", SERVERSTRING);
						return 0;
					}
					
					// if sender is in party
					if(gClientData[senderid].bInParty) {
						
						// if invited user already in party
						if (partyFindPlayerInPartyArray(client) != -1){
							PrintToChat(client, "%s Ya estás en party", SERVERSTRING);
							return 0;
						}
						
						ZParty pt = ZParty(findPartyByUID(gClientData[senderid].iPartyUID));
						
						if (pt.id < 0){
							PrintToChat(client, "%s Este grupo ya no existe.", SERVERSTRING);
							return 0;
						}
						
						added = pt.addMember(client); // add invited user as a new party member
					}
					else{ // sender is not in party
						
						if (partyFindPlayerInPartyArray(senderid) != -1){
							PrintToChat(client, "%s No se puede crear party porque el lider ya tiene una", SERVERSTRING);
							return 0;
						}
						
						created = CreateParty(senderid, client); // Owner, member
					}
					
					if (created){
						SafeEndPlayerCombo(client);
						PrintToChat(client, "%s Se inició party con \x05%N\x01.", SERVERSTRING, senderid);
						
						SafeEndPlayerCombo(senderid);
						PrintToChat(senderid, "%s \x05%N\x01 \x09aceptó\x01 tu invitación de party.", SERVERSTRING, client);
						
						//PrintToChatAll("Party CREATED");
					}
					else{
						switch (added){
							case PARTY_NO_ERROR:{
								SafeEndPlayerCombo(client);
						
								ZParty pt = ZParty(findPartyByUID(gClientData[client].iPartyUID));
								SafeEndComboParty(pt.id);
								
								PrintToChat(client, "%s Aceptaste la invitación de party de \x05%N\x01.", SERVERSTRING, senderid);
								PrintToChat(senderid, "%s \x05%N\x01 \x09aceptó\x01 tu invitación de party.", SERVERSTRING, client);
							}
							case PARTY_ERROR_ANY:{
								PrintToChat(client, "%s No se pudo crear la party.", SERVERSTRING);
								PrintToChat(senderid, "%s No se pudo crear la party.", SERVERSTRING);
							}
							case PARTY_GROUP_FULL:{
								PrintToChat(client, "%s El grupo de \x05%N\x01 ya está \x07lleno\x01!", SERVERSTRING, senderid);
								PrintToChat(senderid, "%s El grupo ya está \x07lleno\x01!", SERVERSTRING);
							}
						}
					}
				}
				case 1:{
					PrintToChat(client, "%s Rechazaste la invitación de party de \x05%N\x01.", SERVERSTRING, senderid);
					PrintToChat(senderid, "%s \x09%N\x01 \x07rechazó\x01 tu invitación de party.", SERVERSTRING, client);
				}
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// CONFIGURATIONS MENU
public Action showMenuConfigs(int client){
	ZPlayer player = ZPlayer(client);
	Menu menu = new Menu(MenuCfgsHandler, MenuAction_Start|MenuAction_Select|MenuAction_Cancel|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "Configs menu title");
	
	char option[48];
	
	Format(option, sizeof(option), "%t", player.bHearHurtSounds ? "Configs menu option 3 off": "Configs menu option 3 on");
	menu.AddItem("d", option);
	
	Format(option, sizeof(option), "%t", player.bStopSound ? "Configs menu option 4 on" : "Configs menu option 4 off");
	menu.AddItem("e", option);
	
	Format(option, sizeof(option), "%t", player.bReceivePartyInv ?  "Configs menu option 5 on" : "Configs menu option 5 off");
	menu.AddItem("f", option, allowParty ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	Format(option, sizeof(option), "%t", "Configs menu option 6");
	menu.AddItem("g", option);
	
	Format(option, sizeof(option), "%t", "Configs menu option 7");
	menu.AddItem("h", option);
	
	Format(option, sizeof(option), "%t", "Configs menu option 8");
	menu.AddItem("i", option);
	
	menu.ExitBackButton = true;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int MenuCfgsHandler(Menu menu, MenuAction action, int client, int selection){
	
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			switch(selection){ 
				case 0: muteHurtSounds(client, 0);
				case 1: muteBullets(client, 0);
				case 2: changeReceiveOp(client, 0);
				case 3: showHudColorMenu(client);
				case 4: showNvColorMenu(client);
				case 5:{
					ZPlayer(client).bChangedName = false;
					showMenuRenameCharacter(client);
				}
			}
			if (selection <= 2)
				showMenuConfigs(client);
		}
		case MenuAction_Cancel:{
			if(selection == MenuCancel_ExitBack){
				showMainMenu(client, 0);
			}
		}
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// RENAME MENU
public Action showMenuRenameCharacter(int client){
	
	if (!IsPlayerExist(client))
		return Plugin_Handled;
	
	ZPlayer player = ZPlayer(client);
	gClientData[client].bInRenameMenu = true;
	
	Menu menu = new Menu(MenuRenameCharacterHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	char cost[16];
	AddPoints(NAME_CHANGE_COST, cost, sizeof cost);
	
	menu.SetTitle("%t", "Rename character menu title", cost);
	char option[24];
	
	FormatEx(option, sizeof(option), "%t", "Confirm");
	menu.AddItem("0", option, player.bChangedName ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	FormatEx(option, sizeof(option), "%t", "Cancel");
	menu.AddItem("1", option);
	
	menu.ExitButton = false;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int MenuRenameCharacterHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			if (selection == 0) renameCharacter(client);
			else return 0;
		}
		
		case MenuAction_End:{
			if (IsPlayerExist(client)){
				gClientData[client].bInRenameMenu = false;
			}
			delete menu;
		}
	}
	return 0;
}

// Check if client is available to buy vip
bool changeCharacterNameCheck(int client){
	
	if (!IsPlayerExist(client)){
		return false;
	}
	
	ZPlayer player = ZPlayer(client);
	
	if (player.iPiuPoints < NAME_CHANGE_COST){
		return false;
	}
	
	return true;
}

// Rename character functions
public void renameCharacter(int client){
	
	if(gServerData.DBI == null)
		return;
	
	if (!changeCharacterNameCheck(client))
		return;
	
	// Read name from steam profile
	static char newName[32];
	FormatEx(newName, sizeof(newName), "%N", client);
	
	// Remove quotes & symbols from new name
	/*StripQuotes(newName);
	ReplaceString(newName, sizeof(newName), "'", "", false);
	ReplaceString(newName, sizeof(newName), "`", "", false);
	ReplaceString(newName, sizeof(newName), "\'", "", false);*/
	
	// Escape new name
	static char newNameScaped[65];
	gServerData.DBI.Escape(newName, newNameScaped, sizeof(newNameScaped));
	
	// Read selected character & get its name
	ZPlayer player = ZPlayer(client);
	
	// Format & escape the query
	char query[256];
	FormatEx(query, sizeof(query), "UPDATE `characters` SET `nombre` = \'%s\' WHERE `id`=%d", newNameScaped, player.iPjSeleccionado);
	//gServerData.DBI.Escape(query, query, sizeof(query));
	
	// Call the query with client userid
	int userid = GetClientUserId(client);
	gServerData.DBI.Query(renameCharacterCallback, query, userid, DBPrio_Low);
}
public void renameCharacterCallback(Database db, DBResultSet results, const char[] error, any data){
	
	int client = 0;

	/* Make sure the client didn't disconnect while the thread was running */
	if ((client = GetClientOfUserId(data)) == 0){
		return;
	}
	
	if (!changeCharacterNameCheck(client)){
		return;
	}
	
	ZPlayer player = ZPlayer(client);
	
	// Handle SQL error received
	if (!StrEqual(error, "")){
		if(StrContains(error, "nombre_UNIQUE") != -1){
			TranslationPrintToChat(client, "Name already in use");
		}
		else{
			LogError("[RENAME-CHARACTER] error: %s", error);
		}
		
		// Restore old data to the array
		/*static char oldName[32];
		charactersNames[client].GetString(player.iPjSeleccionado, oldName, sizeof(oldName));
		
		// Update array to the old name
		characterNames.SetString(client, oldName);*/
		
		return;
	}
	
	// Read name from steam profile
	static char newName[32];
	FormatEx(newName, sizeof(newName), "%N", client);
	
	// Send a query to register data about the name change
	// Format the query
	static char query[256];
	static char oldname[32];
	charactersNames[client].GetString(0, oldname, sizeof(oldname));
	
	// Escape new name
	static char newNameScaped[65];
	gServerData.DBI.Escape(newName, newNameScaped, sizeof(newNameScaped));
	
	FormatEx(query, sizeof(query), "INSERT INTO `%s` (`character_id`, `old_name`, `new_name`, `piupoints_paid`, `namechange_date`) VALUES ('%d', \'%s\', \'%s\', '%d', CURRENT_TIMESTAMP() )", DATABASE_RENAMES, player.iPjSeleccionado, oldname, newNameScaped, NAME_CHANGE_COST);
	ReplaceString(query, sizeof(query), "PCT", "%", true);
	gServerData.DBI.Query(DoNothingCallback, query, client, DBPrio_Low);
	
	// Update array to the new name
	characterNames.SetString(client, newName);
	
	// Take payment
	player.iPiuPoints -= NAME_CHANGE_COST;
	
	// Get new name
	static char name[32];
	characterNames.GetString(client, name, sizeof(name));
	
	// Print on success
	TranslationPrintToChat(client, "Name successfully changed", name);
}


// Get tags data from MySQL
public void GetMyTagsData(int client){
	
	/*
	DBStatement hUserStmt = null;
	
	// SQL QUERY
	if (hUserStmt == null){
		char error2[255];
		hUserStmt = SQL_PrepareQuery(gServerData.DBI, "SELECT t.nombre FROM TagsXCharacter tc LEFT JOIN Tags t ON(tc.idTag=t.idTag) WHERE tc.idChar=? AND activo=1", error2, sizeof(error2));
		
		if (hUserStmt == null){
			PrintToServer(error2);
			delete hUserStmt;
			return Plugin_Handled;
		}
		
	}
	ZPlayer p = ZPlayer(client);
	SQL_BindParamInt(hUserStmt, 0, p.iPjSeleccionado, false);
	
	if (!SQL_Execute(hUserStmt)) {
		PrintToServer("Didn't execute query");
		delete hUserStmt;
		return;
	}*/
	
	if(gServerData.DBI == null){
		LogError("[MYSQL-TAGS] No database connection.");
		return;
	}
	
	char query[128];
	
	FormatEx(query, sizeof(query), "SELECT t.nombre FROM TagsXCharacter tc LEFT JOIN Tags t ON(tc.idTag=t.idTag) WHERE tc.idChar=%d AND activo=1", ZPlayer(client).iPjSeleccionado);
	
	int userid = GetClientUserId(client);
	gServerData.DBI.Query(MyTagsDataCallback, query, userid, DBPrio_Normal);
}
public void MyTagsDataCallback(Database db, DBResultSet results, const char[] error, any data){
	
	int client = 0;
	
	/* Make sure the client didn't disconnect while the thread was running */
	if ((client = GetClientOfUserId(data)) == 0) {
		return;
	}
	
	showMenuMyTags(client, results);
}

// TAGS MENU
public Action showMenuMyTags(int client, DBResultSet results){
	
	int rows = results.RowCount;
	
	static char op[128];
	static char nam[32];
	static char nfo[4];
	
	Menu menu = new Menu(TagsMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	menu.SetTitle("%t", "Tags menu title");
	
	//int rankTag = RankTags_FindForReset(p.iReset);
	
	ZPlayer p = ZPlayer(client);
	
	RankTag rankTag;
	RankTags.GetArray(p.iRankTag, rankTag);
	
	static char defaultOption[32];
	FormatEx(defaultOption, sizeof(defaultOption), rankTag.name);
	
	menu.AddItem("0", defaultOption);
	
	int idTag;
	
	for(int i; i < rows; i++) {
		if(SQL_FetchRow(results)){
			SQL_FetchString(results, 0, nam, sizeof(nam));
			
			idTag = tags.FindString(nam);
			
			IntToString(idTag, nfo, sizeof(nfo));
			FormatEx(op, sizeof(op), "%s %s", nam, idTag==p.iTag ? "(SELECTED)" : "");
			menu.AddItem(nfo, op, idTag==p.iTag ? ITEMDRAW_DISABLED: ITEMDRAW_DEFAULT);
		}
	}
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}
public int TagsMenuHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			char buf[4];
			char nam[32];
			menu.GetItem(selection, buf, sizeof(buf));
			int idTag = StringToInt(buf);
			ZPlayer p = ZPlayer(client);
			//PrintToChatAll("p.iTag: %d, idTag:%d", p.iTag, idTag);
			p.iNextTag = idTag;
			
			if (idTag > 0){
				tags.GetString(idTag, nam, sizeof(nam));
				TranslationPrintToChat(client, "Tag changed", nam);
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

public void GetMyHatsData(int client){
	
	if(gServerData.DBI == null)
		return;
	
	char query[255];
	ZPlayer player = ZPlayer(client);
	
	FormatEx(query, sizeof(query),"SELECT h.name FROM HatsXCharacter hc LEFT JOIN Hats h ON(hc.idHat=h.idHat) WHERE hc.idCharacter=%d AND activo=1", player.iPjSeleccionado);
	
	int userid = GetClientUserId(client);
	gServerData.DBI.Query(MyHatsDataHandler, query, userid, DBPrio_Normal);
}
public void MyHatsDataHandler(Database db, DBResultSet results, const char[] error, any data){
	
	int client = 0;
	
	/* Make sure the client didn't disconnect while the thread was running */
	if ((client = GetClientOfUserId(data)) == 0) {
		return;
	}
	
	showMenuMyHats(client, results);
}

// MYHATS MENU
public Action showMenuMyHats(int client, DBResultSet results){
	ZPlayer p = ZPlayer(client);
	static char op[128];
	static char nam[32];
	static char nfo[4];
	
	int rows = results.RowCount;
	
	Menu menu = new Menu(MyHatsMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "Hats menu title");
	
	Hat rrhat;
	Hats.GetArray(Hats_FindForReset(p.iReset), rrhat);
	
	static char defaultOption[32];
	FormatEx(defaultOption, sizeof(defaultOption), rrhat.name);
	menu.AddItem("0", defaultOption);
	
	Hat hat;
	for(int i; i < rows; i++) {
		if(results.FetchRow()){
			//SQL_FetchString(results, 0, nam, sizeof(nam));
			results.FetchString(0, nam, sizeof nam);
			FindHatByName(nam, hat);
			
			IntToString(hat.id, nfo, sizeof(nfo));
			
			if (hat.id==p.iHat){
				FormatEx(op, sizeof(op), "%s (ACTUAL)", hat.name);
			}
			else{
				FormatEx(op, sizeof(op), "%s %s", hat.name, hat.id==p.iNextHat ? "(SELECCIONADO)" : "");
			}
			menu.AddItem(nfo, op, hat.id==p.iHat ? ITEMDRAW_DISABLED: ITEMDRAW_DEFAULT);
		}
	}
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int MyHatsMenuHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			char buf[4];
			Hat hat;
			menu.GetItem(selection, buf, sizeof(buf));
			int id = StringToInt(buf);
			Hats.GetArray(id, hat);
			ZPlayer p = ZPlayer(client);
			//PrintToChatAll("p.iTag: %d, idTag:%d", p.iTag, idTag);
			p.iNextHat = hat.id;
			if(hat.id>0){
				TranslationPrintToChat(client, "Hat changed", hat.name);
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

/*
//HATS MENU
public Action showMenuHats(int client){
	
	//GetMyPiuPoints(client);
	
	ZPlayer p = ZPlayer(client);
	Menu menu = new Menu(HatsMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "Buy hats menu title", p.iPiuPoints);
	char opt[128], inf[3];
	for(int i = 1; i < Hats.Length; i++){
		Hat h;
		Hats.GetArray(i, h);
		if(!h.legacy){
			IntToString(h.id, inf, sizeof(inf));
			FormatEx(opt, sizeof(opt), "%s (%d PIU-Points)", h.name, h.cost);
			
			menu.AddItem(inf, opt, ITEMDRAW_DEFAULT);
		}
		
	}
	
	menu.ExitButton = true;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int HatsMenuHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			char inf[3];
			menu.GetItem(selection,inf, sizeof(inf));
			int idHat= StringToInt(inf);
			
			hasHat(client, idHat);
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}
*/

//MERCENARY MENU
public Action showMenuMercenary(int client){
	Menu menu = new Menu(MercenaryMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("Welcome Stranger: ");
	char option[24];
	
	FormatEx(option, sizeof(option), "%t", "Mercenary menu option 1");
	menu.AddItem("0", option, ITEMDRAW_DISABLED);
	
	FormatEx(option, sizeof(option), "%t", "Mercenary menu option 2");
	menu.AddItem("1", option);
	
	FormatEx(option, sizeof(option), "%t", "Mercenary menu option 3");
	menu.AddItem("2", option);
	
	/*Format(option, sizeof(option), "%t", "Mercenary menu option 4");
	menu.AddItem("2", option, ITEMDRAW_DISABLED);*/
	
	menu.ExitButton = true;
	
	menu.Display(client, 20);
	return Plugin_Handled;
}
public int MercenaryMenuHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			switch(selection) {
				case 0: {
					//showMenuLogros(client);
					
				}
				case 1: {
					ZPlayer p = ZPlayer(client);
					if(p.iTag == p.iNextTag) GetMyTagsData(client);
					else TranslationPrintToChat(client, "Tag change in cooldown");
				}
				case 2: {
					ZPlayer player = ZPlayer(client);
					if(player.iNextHat == player.iHat) GetMyHatsData(client);
					else TranslationPrintToChat(client, "Hat change in cooldown");
				}
				//case 2: showMenuHats(client);
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

public Action GetTop50(int client, int args){
	
	char query[255];
	
	FormatEx(query, sizeof(query),"SELECT nombre, c.reset, c.level FROM Characters c ORDER BY c.reset DESC, c.level DESC LIMIT 50");
	
	int userid = GetClientUserId(client);
	gServerData.DBI.Query(Top50DataHandler, query, userid, DBPrio_High);
	return Plugin_Handled;
}
public void Top50DataHandler(Database db, DBResultSet results, const char[] error, any data){
	
	int client = 0;
	
	/* Make sure the client didn't disconnect while the thread was running */
	if ((client = GetClientOfUserId(data)) == 0) {
		return;
	}
	
	showTop50(client, results);
}

// TOP MENU
public Action showTop50(int client, DBResultSet results){
	
	int rows = results.RowCount;
	
	char nfo[255];
	char nam[64];
	
	Menu menu = new Menu(Top50Handler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "Top menu title");
	for(int i; i < rows; i++) {
		if(SQL_FetchRow(results)){
			SQL_FetchString(results, 0, nam, sizeof(nam));
			FormatEx(nfo, sizeof(nfo), "TOP %d | %s (RR %d | Lvl %d)", i+1, nam, results.FetchInt(1), results.FetchInt(2));
			menu.AddItem("", nfo, ITEMDRAW_DISABLED);
		}
	}
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}
public int Top50Handler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// GRENADE PACKS MENU
public Action showGrenadePacks(int client){
	ZPlayer p = ZPlayer(client);
	Menu menu = new Menu(MenuGrenadePackHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "Grenade packs menu title");
	
	for(int i; i < gGrenadePackLevel.Length; i++) {
		ZGrenadePack gp = ZGrenadePack(i);
		char nf[4];
		char fire[16], ice[16], light[16], aura[16], voidgrenade[16], op[128];
		IntToString(i, nf, 4);
		if(gp.hasGrenade(FIRE_GRENADE)){
			Format(fire, sizeof(fire), "%t", "Grenade packs menu fire", gp.getGrenadeCount(FIRE_GRENADE));
		} 
		if(gp.hasGrenade(FREEZE_GRENADE)){
			Format(ice, sizeof(ice), "%t", "Grenade packs menu ice", gp.getGrenadeCount(FREEZE_GRENADE));
		} 
		if(gp.hasGrenade(LIGHT_GRENADE)){
			Format(light, sizeof(light), "%t", "Grenade packs menu flare", gp.getGrenadeCount(LIGHT_GRENADE));
		} 
		if(gp.hasGrenade(AURA_GRENADE)){
			Format(aura, sizeof(aura), "%t", "Grenade packs menu aura", gp.getGrenadeCount(AURA_GRENADE));
		}
		if (gp.hasGrenade(VOID_GRENADE)){
			Format(voidgrenade, sizeof(voidgrenade), "%t", "Grenade packs menu void", gp.getGrenadeCount(AURA_GRENADE));
		}
		
		if (gp.iReset)
		Format(op, sizeof(op), "Pack %d (lvl %d | %d rr):\n%s%s%s%s%s", i+1, gp.iLevel, gp.iReset, fire, ice, light, aura, voidgrenade);
		else
		Format(op, sizeof(op), "Pack %d (lvl %d):\n%s%s%s%s%s", i+1, gp.iLevel, fire, ice, light, aura, voidgrenade);
		menu.AddItem(nf, op, (gp.iLevel <= p.iLevel && gp.iReset <= p.iReset) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		//menu.AddItem("", "\n", ITEMDRAW_RAWLINE);
	}
	menu.Pagination = 3;
	menu.ExitButton = true;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int MenuGrenadePackHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			ZPlayer player = ZPlayer(client);
			ZGrenadePack pack = ZGrenadePack(selection);
			
			if(player.iLevel >= pack.iLevel && player.iReset >= pack.iReset){
				player.iNextGrenadePack = pack.id;
				TranslationPrintToChat(player.id, "Grenade pack selected", selection+1);
			}
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}


#pragma unused sHudColors
#pragma unused iHudColors
#define HUDCOLORS_NUMBER	8
char sHudColors[HUDCOLORS_NUMBER][] = { "Color white", "Color red", "Color yellow", "Color blue", "Color light blue", "Color orange", "Color green", "Color purple" };
int iHudColors[HUDCOLORS_NUMBER][3] = {
	{ 255, 255, 255 },
	{ 220, 10, 10 },
	{ 255, 224, 51 },
	{ 35, 35, 210 },
	{ 30, 229, 240 },
	{ 240, 150, 30 },
	{ 10, 220, 10 },
	{ 177, 71, 242 }
};

// CUSTOMIZE HUD COLOR MENU
public Action showHudColorMenu(int client){
	ZPlayer player = ZPlayer(client);
	Menu menu = new Menu(MenuHudColorHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "HUD color menu title");
	
	char option[16];
	
	for(int i; i < HUDCOLORS_NUMBER; i++) {
		Format(option, sizeof(option), "%t", sHudColors[i]);
		menu.AddItem("", option, (player.iHudColor != i) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	menu.ExitButton = true;
	menu.Pagination = 10;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int MenuHudColorHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			ZPlayer player = ZPlayer(client);
			player.iHudColor = selection;
			showHudColorMenu(player.id);
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// CUSTOMIZE NIGHTVISION COLOR MENU
public Action showNvColorMenu(int client){
	ZPlayer player = ZPlayer(client);
	Menu menu = new Menu(MenuNvColorHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t", "Nightvision color menu title");
	
	char option[16];
	
	for(int i; i < HUDCOLORS_NUMBER; i++) {
		Format(option, sizeof(option), "%t", sNvgColors[i]);
		menu.AddItem("", option, (player.iNvColor != i) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	menu.ExitButton = true;
	menu.Pagination = 10;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int MenuNvColorHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			ZPlayer player = ZPlayer(client);
			player.iNvColor = selection;
			DispatchDistanceAndColor(player.id);
			showNvColorMenu(player.id);
		}
		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// GET MY PIU POINTS
/*
public void GetMyPiuPoints(int client){
	
	if(gServerData.DBI == null)
		return;
	
	char query[128];
	
	int steam_id = GetSteamAccountID(client);
	
	FormatEx(query, sizeof(query),"SELECT a.piuPoints FROM players a WHERE a.steamid = %d;", steam_id);
	gServerData.DBI.Query(MyPiuPointsHandler, query, client, DBPrio_High);
}
public void MyPiuPointsHandler(Database db, DBResultSet results, const char[] error, any data){
	
	int client = data;
	
	if(results == null) {
		PrintToServer("[LOAD-PIUPOINTS] %s", error);
		return;
	}
	
	if(!results.RowCount){
		PrintToServer("COULD NOT READ PP");
		return;
	}
	
	if (results.FetchRow()){
		ZPlayer(client).iPiuPoints = results.FetchInt(0);
	}
}*/

public void UpdatePiuPoints(int client, int value){
	
	if(gServerData.DBI == null){
		return;
	}
	
	if (!ZPlayer(client).bLogged){
		return;
	}
	
	char query[128];
	
	int steam_id = ZPlayer(client).iSteamAccountID;
	FormatEx(query, sizeof(query), "UPDATE `players` SET `piuPoints` = %d WHERE `steamid` = %d;", value, steam_id);
	gServerData.DBI.Query(DoNothingCallback, query, client, DBPrio_Low);
}

// BUY PREMIUM ITEMS
public Action showVipPurchaseMenu(int client){
	
	//GetMyPiuPoints(client);
	
	Menu menu = new Menu(VipPurchaseMenuHandler, MenuAction_Start|MenuAction_Select|MenuAction_Cancel|MenuAction_End);
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	ZPlayer player = ZPlayer(client);
	menu.SetTitle("%t", "Vip purchase menu title", player.iPiuPoints);
	
	char option[64];
	char sName[48];
	char sNumber[4];
	
	ZVip vip;	
	for (int i; i <= getTotalVips(); i++){
		
		ZVips.GetArray(i, vip); // Get the array from the arraylist
		
		if (!vip.available)
			continue;
		
		vip.GetName(sName, sizeof(sName));
		Format(option, sizeof(option), "%t", "Vip purchase menu option", sName, vip.cost);
		
		IntToString(i, sNumber, sizeof(sNumber));
		menu.AddItem(sNumber, option, ITEMDRAW_DEFAULT);
	}
	
	menu.ExitBackButton = true;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int VipPurchaseMenuHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			showConfirmVipPurchase(client, selection);
		}
		case MenuAction_Cancel:{
			if(selection == MenuCancel_ExitBack){
				showMainMenu(client, 0);
			}
		}
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

// Check if client is available to buy vip
bool purchaseVipCheck(int client, int vipId){
	
	if (!IsPlayerExist(client)){
		return false;
	}
	
	if (vipId > getTotalVips()){
		return false;
	}
	
	ZVip vip;
	ZVips.GetArray(vipId, vip);
	
	if (!vip.available){
		return false;
	}
	
	ZPlayer player = ZPlayer(client);
	
	if (player.flExpBoost > 1.0){
		return false;
	}
	
	if (player.iPiuPoints < vip.cost){
		return false;
	}
	
	return true;
}

// CONFIRM VIP PURCHASE
public Action showConfirmVipPurchase(int client, int selection){
	
	// Sets the global language target
	SetGlobalTransTarget(client);
	
	Menu menu = new Menu(ConfirmVipPurchaseHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
	
	ZVip vip;
	ZVips.GetArray(selection, vip);
	
	char sId[4];
	IntToString(vip.id, sId, sizeof(sId));
	
	char sName[32];
	vip.GetName(sName, sizeof(sName));
	
	menu.SetTitle("%t", "Selected vip info", sName, vip.days, RoundToZero(vip.expBoost), vip.pointsBonus);
	
	char option[32];
	if (ZPlayer(client).flExpBoost > 1.0){
		FormatEx(option, sizeof(option), "%t", "You are already vip", RoundToZero(ZPlayer(client).flExpBoost));
	}
	else{
		FormatEx(option, sizeof(option), "%t", "Confirm");
	}
	menu.AddItem(sId, option, purchaseVipCheck(client, vip.id) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	FormatEx(option, sizeof(option), "%t", "Cancel");
	menu.AddItem(sId, option);
	
	menu.ExitButton = false;
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int ConfirmVipPurchaseHandler(Menu menu, MenuAction action, int client, int selection){
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			if (selection == 0){
				ZPlayer player = ZPlayer(client);
				
				char sOption[4];
				menu.GetItem(selection, sOption, sizeof(sOption));
				
				int id = StringToInt(sOption);
				
				ZVip vip;
				ZVips.GetArray(id, vip);
				
				if (!purchaseVipCheck(client, vip.id)){
					TranslationPrintToChat(client, "Vip purchase failed");
					return 0;
				}
				
				BuyVip(player.id, vip.id);
			}
			else{
				showVipPurchaseMenu(client);
			}
		}
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}

public Action BuyVip(int client, int idVip){
	if(gServerData.DBI == null)
		return Plugin_Handled;
	
	ZPlayer player = ZPlayer(client);
	
	char query[1024];
	if(purchaseVipCheck(client, idVip)){
		int id = player.iPjSeleccionado;
		
		ZVip vip;
		ZVips.GetArray(idVip, vip);
		
		FormatEx(query, sizeof(query), "CALL registerVipById(%d, current_timestamp(), %d, %0.2f)", id, vip.days, vip.expBoost);
		LogToFile("/addons/sourcemod/logs/VIP_BUY_LOG.txt", "[VIP-STORE] %N (pjID %i) bought VIP: x%0.2f", client, id, vip.expBoost);
		
		DataPack data = new DataPack();
		data.WriteCell(GetClientUserId(client));
		data.WriteCell(vip.id);
		
		gServerData.DBI.Query(BuyVipCallback, query, data, DBPrio_High);
		
	}else{
		TranslationPrintToChat(client, "Vip purchase failed");
	}
	return Plugin_Handled;
}
public void BuyVipCallback(Database db, DBResultSet results, const char[] error, DataPack dpack){
	
	dpack.Reset();
	
	int data = dpack.ReadCell();
	ZVip vip;
	ZVips.GetArray(dpack.ReadCell(), vip);
	
	int client = 0;
	
	/* Make sure the client didn't disconnect while the thread was running */
	if ((client = GetClientOfUserId(data)) == 0){
		delete dpack;
		return;
	}
	
	if(!StrEqual(error, "")){
		PrintToServer("[ERROR-LOGGED] %s", error);
		LogError("[BUY VIP CALLBACK] %s", error);
		TranslationPrintToChat(client, "Vip purchase failed");
	}
	else{
		ZPlayer player = ZPlayer(client);
		player.iPiuPoints -= vip.cost;
		player.flExpBoost = vip.expBoost;
		
		// APPLY PURCHASED VIP MEMBERSHIP
		// Si pudo comprarlo
		char sName[32];
		vip.GetName(sName, sizeof(sName));
		
		TranslationPrintToChat(client, "Vip purchase successful", sName);
		
		// Update piu points in database
		UpdatePiuPoints(client, gClientData[client].iPiuPoints);
	}
	
	delete dpack;
	
}

public Action showMenuRedes(int client, int args){
	
	Menu menu = new Menu(showMenuRedesHandler, MenuAction_Start|MenuAction_Select|MenuAction_End);
		
	menu.SetTitle("Nuestras redes sociales\n\n");
	
	
	// Sets the global language target
	SetGlobalTransTarget(client);	
	
	static char option[32];
	FormatEx(option, sizeof(option), "Obtener link de Discord");
	menu.AddItem("0", option);
	
	FormatEx(option, sizeof(option), "Obtener link de WhatsApp");
	menu.AddItem("1", option);
	
	FormatEx(option, sizeof(option), "Obtener link de Instagram");
	menu.AddItem("2", option);
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

// Handler for primary weapons
public int showMenuRedesHandler(Menu menu, MenuAction action, int client, int selection){
	
	switch(action){
		case MenuAction_Start:{
		}
		
		case MenuAction_Select:{
			
			switch (selection){
				
				case 0:{
					infoDiscord(client, 0);
				}
				case 1:{
					infoWhatsapp(client, 0);
				}
				case 2:{
					infoInstagram(client, 0);
				}
			}
		}		
		case MenuAction_End:{
			delete menu;
		}
	}
	return 0;
}



/////////////////////////////////////////
void MenusOnClientInit(int client){
	
	gClientData[client].InfoMenuPage = 0;
	gClientData[client].bUseMyName = true;
	gClientData[client].bPartyMenuKicks = false;
	gClientData[client].bInRenameMenu = false;
}

void MenusOnCommandInit(){
	
	// Main menu
	RegConsoleCmd("mainmenu", showMainMenu);
	RegConsoleCmd("menu", showMainMenu);
	
	// Reset menu
	RegConsoleCmd("reset", showResetMenu);
	
	// Weapons
	RegConsoleCmd("weapons", showMenuWeaponsMenu);
	RegConsoleCmd("guns", showMenuWeaponsMenu);
	RegConsoleCmd("armas", showMenuWeaponsMenu);
	
	// Classes
	RegConsoleCmd("classes", showMenuClasses);
	RegConsoleCmd("clases", showMenuClasses);
	RegConsoleCmd("class", showMenuClasses);
	RegConsoleCmd("clase", showMenuClasses);
	
	// Redes
	RegConsoleCmd("redes", showMenuRedes);
}