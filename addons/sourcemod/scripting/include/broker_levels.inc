#pragma semicolon 1
#pragma newdecls required

#define DEBUG

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

#if defined broker_levels_included
	#endinput
#endif
#define broker_levels_included

#define BROKER_LEVELS_MODULE_VERSION "1.0"


#define PIUPOINTS_PER_LEVEL 200
#define POINTS_PER_LEVEL 5

enum ItemLevel{
	IL_WEAPON,
	IL_GRENADE,
	IL_ZCLASS,
	IL_HCLASS,
	IL_ZPOINTS,
	IL_HPOINTS,
	IL_PIUPOINTS,
	IL_TOTALIL
}

StringMap itemPerLevel;


void BrokerLevels_OnPluginStart(){
	itemPerLevel = CreateTrie();
}
void BorkerLevels_OnPluginEnd(){
	ClearTrie(itemPerLevel);
}

void RegisterItemPerLevel(int level, ItemLevel item){
	char lvl[4];
	IntToString(level, lvl, sizeof(lvl));
	itemPerLevel.SetValue(lvl, item, false);
}

int Notify(int client, int level){
	
	char lvl[8];
	
	IntToString(level, lvl, sizeof(lvl));
	
	//Ver como enviar mensaje
	int x;
	itemPerLevel.GetValue(lvl, x);
	
	char type[32];
	
	switch(x){
		case IL_WEAPON:{
			//Mensaje
			TranslationPrintToChat(client, "Unlocked weapon");
			Format(type, sizeof(type), "Arma nueva");
		}
		case IL_GRENADE:{
			//Mensaje
			TranslationPrintToChat(client, "Unlocked grenade pack");
			Format(type, sizeof(type), "Pack Granadas");
		}
		case IL_ZCLASS:{
			//Mensaje
			TranslationPrintToChat(client, "Unlocked zclass");
			Format(type, sizeof(type), "Clase zombie");
		}
		case IL_HCLASS:{
			//Mensaje
			TranslationPrintToChat(client, "Unlocked hclass");
			Format(type, sizeof(type), "Clase humana");
		}
		case IL_PIUPOINTS:{
			//Mensaje
			TranslationPrintToChat(client, "Unlocked piu points", PIUPOINTS_PER_LEVEL);
			Format(type, sizeof(type), "Piu Points");
		}
		case IL_ZPOINTS:{
			//Mensaje
			TranslationPrintToChat(client, "Unlocked zombie points", POINTS_PER_LEVEL);
			Format(type, sizeof(type), "Puntos Zombie");
		}
		case IL_HPOINTS:{
			//Mensaje
			TranslationPrintToChat(client, "Unlocked human points", POINTS_PER_LEVEL);
			Format(type, sizeof(type), "Puntos Humanos");
		}
	}
	
	return x;
}