#pragma semicolon 1
#pragma newdecls required

#define DEBUG

#if defined _spawn_included
	#endinput
#endif
#define _spawn_included

float gfSpawnOrigins[MAXPLAYERS+1][3];

/**
 * @brief Spawn module init function.
 **/
void Spawn_OnPluginStart(/*void*/)
{
    // Hook player events
    //HookEvent("player_spawn", SpawnOnClientSpawn, EventHookMode_Post);
    
    // Initialize a spawn position array
    gServerData.Spawns = new ArrayList(3);
}

/**
 * @brief Spawn module load function.
 **/
void Spawn_OnMapStart(/*void*/)
{
    // Clear out the array of all data
    gServerData.Spawns.Clear();
    
    // Now copy positions to array structure
    SpawnOnCacheData("info_player_terrorist");
    SpawnOnCacheData("info_player_counterterrorist");
    
    // If team spawns weren't found
    if (!gServerData.Spawns.Length)
    {
        // Now copy positions to array structure
        SpawnOnCacheData("info_player_deathmatch");
        SpawnOnCacheData("info_player_start");
        SpawnOnCacheData("info_player_teamspawn");
    }
}

/**
 * @brief Caches spawn data from the server.
 *
 * @param sClassname        The string with info name. 
 **/
void SpawnOnCacheData(char[] sClassname)
{
    // Loop throught all entities
    int entity;
    while ((entity = FindEntityByClassname(entity, sClassname)) != -1)
    {
        // Gets origin position
        static float vPosition[3];
        ToolsGetAbsOrigin(entity, vPosition); 
        
        // Push data into array 
        gServerData.Spawns.PushArray(vPosition, sizeof(vPosition));
    }
}
 
/**
 * Event callback (player_spawn)
 * @brief Client has ben spawned.
 * 
 * @param gEventHook        The event handle.
 * @param gEventName        The name of the event.
 * @param dontBroadcast     If true, event is broadcasted to all clients, false if not.
 **/
 /*
public Action SpawnOnClientSpawn(Event hEvent, char[] sName, bool dontBroadcast) 
{
    // Gets all required event info
    int client = GetClientOfUserId(hEvent.GetInt("userid"));

    // Validate client
    if (!IsPlayerExist(client))
    {
        return;
    }
    
    // Forward event to modules
    ApplyOnClientSpawn(client);
}*/

/**
 * @brief Teleport client to a random spawn position.
 * 
 * @param client            The client index.
 **/
void SpawnTeleportToRespawn(int client)
{
    // Initialize vectors
    static float vPosition[3]; float vMaxs[3]; float vMins[3]; 

    // Gets client's min and max size vector
    GetClientMins(client, vMins);
    GetClientMaxs(client, vMaxs);

    // i = origin index
    int iSize = gServerData.Spawns.Length;
    for (int i = 0; i < iSize; i++)
    {
        // Gets random array
        gServerData.Spawns.GetArray(i, vPosition, sizeof(vPosition));
        
        // Create the hull trace
        TR_TraceHullFilter(vPosition, vPosition, vMins, vMaxs, MASK_SOLID, AntiStickFilter, client);
        
        // Returns if there was any kind of collision along the trace ray
        if (!TR_DidHit())
        {
            // Teleport player back on the spawn point
            TeleportEntity(client, vPosition, NULL_VECTOR, NULL_VECTOR);
            return;
        }
    }
}