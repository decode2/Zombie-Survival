#pragma semicolon 1

#define DEBUG

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <resources>

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

stock void GetAimCoords(int client, float vector[3])
{
	float vAngles[3];
	float vOrigin[3];
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);

	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if (TR_DidHit(trace)){
		TR_GetEndPosition(vector, trace);
	}
	delete trace;
}

stock bool TraceEntityFilterPlayer(int entity, int contentsMask) {
	return (entity > MaxClients || entity < 1);
}

stock bool IsPlayerExist(int clientIndex, bool clientAlive = true)
{
	// If client isn't valid
	if (clientIndex <= 0 || clientIndex > MaxClients)
	{
		return false;
	}
	
	// If client isn't connected
	if (!IsClientConnected(clientIndex))
	{
		return false;
	}

	// If client isn't in game
	if (!IsClientInGame(clientIndex))
	{
		return false;
	}

	// If client isn't alive
	if(clientAlive && !IsPlayerAlive(clientIndex))
	{
		return false;
	}
	
	// If client exist
	return true;
}

// Get model index and prevent server from crash 
stock int Weapon_GetViewModelIndex(int client, int sIndex)
{  
	while ((sIndex = FindEntityByClassname2(sIndex, "predicted_viewmodel")) != -1)
	{  
		int Owner = GetEntPropEnt(sIndex, Prop_Send, "m_hOwner");
          
		if (Owner != client)
			continue;
	          
		return sIndex;  
	} 
	return -1;  
}

// Get entity name 
stock int FindEntityByClassname2(int sStartEnt, char[] szClassname)
{ 
	while (sStartEnt > -1 && !IsValidEntity(sStartEnt)) sStartEnt--;
	return FindEntityByClassname(sStartEnt, szClassname);
}

stock int setColor(int r, int g, int b, int a = 255)
{
	return (r + (g << 8) + (b << 16) + (a << 24));
}