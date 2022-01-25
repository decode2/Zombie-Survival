#pragma semicolon 1

#define DEBUG

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

#if defined anti_retry_include
	#endinput
#endif
#define anti_retry_include

#define ANTI_RETRY_MODULE_VERSION "0.1"


#define MAX_RETRYS_TO_BAN 5
#define TIME_BEFORE_ENTER_AFTER_RETRY 30.0

ArrayList gActualSteamIds;
ArrayList gHistoricSteamIds;
ArrayList gHistoricsCount;
//ArrayList hPositions;
//ArrayList hAngles;

enum Retry_Actions{
	RETRY_NO_ACTION,
	RETRY_RESTRICT,
	RETRY_BAN
}

stock void AntiRetry_OnPluginStart(){
	
	gActualSteamIds = CreateArray(1);
	gHistoricSteamIds = CreateArray(1);
	gHistoricsCount = CreateArray(1);
}

stock void AntiRetry_OnMapStart(){
	AntiRetry_OnPluginEnd();
}

stock void AntiRetry_OnPluginEnd(){
	gActualSteamIds.Clear();
	gHistoricSteamIds.Clear();
	gHistoricsCount.Clear();
}

public void AddToRetrysList(int client){
	int steamid = GetSteamAccountID(client);
	
	gActualSteamIds.Push(steamid);
	
	CreateTimer(TIME_BEFORE_ENTER_AFTER_RETRY, RetryTimerCallback, steamid);
}

public Action RetryTimerCallback(Handle timer, any steamid){
	
	int actualId = gActualSteamIds.FindValue(steamid);
	int historicId = gHistoricSteamIds.FindValue(steamid);
	if(actualId != -1){
		gActualSteamIds.Erase(actualId);
		if(historicId != -1){
			gHistoricsCount.Set(historicId, gHistoricsCount.Get(historicId)+1);
		}else{
			gHistoricSteamIds.Push(steamid);
			gHistoricsCount.Push(1);
		}
	}
	return Plugin_Handled;
}

public Retry_Actions GetRetryAction(int client){
	int steamid = GetSteamAccountID(client);
	
	Retry_Actions ret = RETRY_NO_ACTION;
	
	int historicId = gHistoricSteamIds.FindValue(steamid);
	int actualId = gActualSteamIds.FindValue(steamid);
	if(historicId != -1 && gHistoricsCount.Get(historicId) > MAX_RETRYS_TO_BAN){
		LogMessage("[ANTI-RETRY] SteamId %d baneado.", steamid);
		ret = RETRY_BAN;
	}
	else if(actualId != -1 && historicId != -1 && gHistoricsCount.Get(historicId) > 1){
		PrintToServer("SteamId: %d restringido.", steamid);
		LogMessage("[ANTI-RETRY] SteamId %d restringido.", steamid);
		
		ret = RETRY_RESTRICT;
	}
	debugRetry();
	return ret;
}

public void CheckIfRetry(int client){
	
	CreateTimer(1.0,RetryActionTimerHandler, client);
}

public Action RetryActionTimerHandler(Handle timer, any client){
	
	if (!IsPlayerExist(client))
		return;
	
	if (IsFakeClient(client))
		return;
	
	int steamid = GetSteamAccountID(client);
	int historicId = gHistoricSteamIds.FindValue(steamid);
	
	if (historicId <= -1)
		return;
	
	switch(GetRetryAction(client)){
		case RETRY_RESTRICT:{
			KickClientEx(client, "[Piu-Breakers] You cannot  retry, wait %d secs until reconnect. If you retry 3 times in the same map you get 10 minutes ban.", RoundToFloor(TIME_BEFORE_ENTER_AFTER_RETRY));
		}
		case RETRY_BAN:{
			BanClient(client, 10, BANFLAG_AUTHID, "Retry","[Piu-Breakers] You tried to retry more than 5, now you're banned for 10 minutes.");
			gHistoricsCount.Set(historicId, -1);
		}
	}
}

public void debugRetry(){
	PrintToServer(" ----------------- Actual steam ids -----------------");
	for(int i = 0; i < gActualSteamIds.Length; i++){
		PrintToServer("id: %d, value:%d", i, gActualSteamIds.Get(i));
	}
	PrintToServer(" ----------------- Historics steam ids -----------------");
	for(int i = 0; i < gHistoricSteamIds.Length; i++){
		PrintToServer("id: %d, value:%d", i, gHistoricSteamIds.Get(i));
	}
	PrintToServer(" ----------------- Count steam ids -----------------");
	for(int i = 0; i < gHistoricsCount.Length; i++){
		PrintToServer("id: %d, value:%d", i, gHistoricsCount.Get(i));
	}
}