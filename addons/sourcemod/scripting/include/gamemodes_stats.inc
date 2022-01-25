//
// Mode stats for ZS gamemodes
//

#if defined _gamemodes_stats_included
	#endinput
#endif
#define _gamemodes_stats_included


Handle hModeStats;
int iModesHumanRewards = 0;
int iModesZombieRewards = 0;

ArrayList ModesHumans;
ArrayList ModesZombies;

// Start gamemodes stats
void GamemodesStats_OnPluginStart(){
	
	ModesHumans = new ArrayList(1);
	ModesZombies = new ArrayList(1);
}

// End gamemodes stats
void GamemodesStats_OnPluginEnd(){
	
	ModesHumans.Clear();
	delete ModesHumans;
	
	ModesZombies.Clear();
	delete ModesZombies;
}

// Reset gamemodes stats
void GamemodesStats_purgeModesData(){
	
	iModesHumanRewards = 0;
	iModesZombieRewards = 0;
	
	ModesHumans.Clear();
	ModesZombies.Clear();
}

void GamemodeStatsOnPlayerDisconnectPre(int client){
	
	int playerArrayID = -1;
	
	playerArrayID = ModesHumans.FindValue(client);
	if (playerArrayID != -1){
		ModesHumans.Erase(playerArrayID);
		return;
	}
	
	playerArrayID = ModesZombies.FindValue(client);
	if (playerArrayID != -1){
		ModesZombies.Erase(playerArrayID);
		return;
	}
}