#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#pragma newdecls required


int iOnlineClients;
int iMaxPlayers;

public Plugin myinfo = 
{
	name = "Serverside client limiter",
	author = "Deco (PIU)",
	description = "Reject client when server is full (limit set up in cfg)",
	version = "1.0",
	url = "www.piu-games.com"
};

public void OnPluginStart(){
	
	iOnlineClients = 0;
	iMaxPlayers = GetMaxHumanPlayers();
}

public void OnClientConnected(int client){
	iOnlineClients++;
}

public void OnClientPostAdminCheck(int client){
	
	if (iOnlineClients > iMaxPlayers){
		KickClient(client, "Server is full");
	}
}

public void OnClientDisconnect_Post(int client){
	iOnlineClients--;
}