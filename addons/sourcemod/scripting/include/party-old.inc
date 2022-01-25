#pragma semicolon 1
#pragma newdecls required

#define DEBUG

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <zplayer>
#include <colorvariables>

#if defined party_included
	#endinput
#endif
#define party_included

#define PARTY_MODULE_VERSION "0.1"

#define PARTY_MAX_COUNT 20
#define PARTY_MAX_MEMBERS 3
#define PARTY_MAX_DIFFERENCE 400
#define PARTY_BOOST_PER_PLAYER 0.15 // percentage
#define PARTY_UID_BASE 1000
#define PARTY_UID_CEIL 3000
#define PARTY_UNDEFINED -1
#define PARTY_COMBO_FINISH_ON_EVENT

//=====================================================
//					PARTY NUEVA
//=====================================================

enum PartyError{
	PARTY_NO_ERROR,
	PARTY_GROUP_FULL,
	PARTY_GROUP_LEVEL_EXCEEDS,
	PARTY_PLAYER_NOT_VALID,
	PARTY_ERROR_ANY
}

enum struct ZParty{
	int id;
	int iUID;
	int iOwner;
	
	Handle hComboHandle;
	float fComboTime;
	int iCombo;
	int iDamageDealt;
	
	ArrayList partyMembers;
	
	// Party members count
	int length(){
		return this.partyMembers.Length;
	}
	
	// Function to find member's ID by array search
	int getMemberByArrayId(int arrayId){
		return this.partyMembers.Get(arrayId);
	}
	
	// Average stats
	int avgLevel(){
	
		int ret = 0;
		ZPlayer player;
		for(int i = 0; i < this.length(); i++){
			player = ZPlayer(this.getMemberByArrayId(i));
			ret += player.iLevel;
		}
		ret = ret / this.length();
		return ret;
	}
	int avgReset(){
		
		int ret = 0;
		ZPlayer player;
		for(int i = 0; i < this.length(); i++){
			player = ZPlayer(this.getMemberByArrayId(i));
			ret += player.iReset;
		}
		ret = ret / this.length();
		return ret;
	}
	
	// Get valid players
	int getValidPlayers(){
		
		int ret = 0;
		ZPlayer player;
		for(int i = 0; i < this.length(); i++){
			player = ZPlayer(this.getMemberByArrayId(i));
			if(player.iTeamNum == CS_TEAM_CT && IsPlayerExist(player.id)) ret++;
		}
		
		//ret = ret/this.length();
		return ret;
	}
	
	// Max accepted level
	int iMaxLevel(){
		int lvl = 0;
		for(int i=0; i < this.length(); i++){
			ZPlayer player = ZPlayer(this.getMemberByArrayId(i));
			if(lvl < player.iLevel) lvl = player.iLevel;
		}
		return lvl;
	}
	
	// Total boost counting players in party
	float getTotalBoost(){
		return PARTY_BOOST_PER_PLAYER * (this.getValidPlayers()-1);
	}
	
	// Print message function
	void printMessageToMember(int client, const char[] format, any ...){
		
		if (!IsPlayerExist(client))
			return;
		
		char buffer[256];
		
		SetGlobalTransTarget(client);
		VFormat(buffer, sizeof(buffer), format, 2);
		PrintToChat(client, "%s", buffer);
	}
}

// Struct para las parties
ZParty PartyData;

// Find party from UID
int findPartyByUID(int UID){
	
	int value = PARTY_UNDEFINED;
	for (int i; i < PartyData.Length; i++){
		PartyData.GetArray(i, party);
		
		if (party.iUID == UID){
			value = i;
			break;
		}
	}
	
	return value;
}

// Find member array ID
int findMemberArrayId(int client, int partyID){
	
	if (partyID == PARTY_UNDEFINED){
		return PARTY_UNDEFINED;
	}
	
	if (!IsPlayerExist(client)){
		return -1;
	}
	
	if (!ZPlayer(client).isInParty()){
		return -1;
	}
	
	ZParty party;
	PartyData.GetArray(partyID, party);
	
	int id = party.partyMembers.FindValue(client);
	
	return id;
}

// Check if user can join this group
PartyError userCanJoin(int client, int partyID){
	
	if (partyID == PARTY_UNDEFINED){
		return PARTY_ERROR_ANY;
	}
	
	if (!IsPlayerExist(client))
		return PARTY_PLAYER_NOT_VALID;
	
	ZParty party;
	ZPartys.GetArray(partyID, party);
	
	ZPlayer player = ZPlayer(client);
	PartyError ret = PARTY_ERROR_ANY;
	
	if (party.length() < PARTY_MAX_MEMBERS){
		
		if (!player.isInParty()){
			if(userLevelAccomplishes(party.iMaxLevel(), player.iLevel)){
				ret = PARTY_NO_ERROR;
			}
		}
		else{
			ret = PARTY_GROUP_LEVEL_EXCEEDS;
		}
	}
	else{
		ret = PARTY_GROUP_FULL;
	}
	return ret;
}

// Add member to the group
PartyError addMember(int client, int UID, bool bShouldCheck = true){
	
	int id;
	
	// Read array ID using UID as reference
	if ((id = findPartyByUID(UID)) == PARTY_UNDEFINED){
		return PARTY_ERROR_ANY;
	}
	
	// Read array structure
	ZParty party;
	ZPartys.GetArray(id, party);
	
	// Check compliance
	PartyError compliance = userCanJoin(id, client);
	
	// If compliance should be checked
	if (bShouldCheck){
		if (compliance != PARTY_NO_ERROR)
			return compliance;
	}
	
	// Make this UID, player's UID
	ZPlayer(client).iPartyUID = this.iUID;
	
	// Add the member
	party.partyMembers.Push(client);
	
	// Save changes into the structure
	ZPartys.SetArray(id, party);
	
	// Create party member icon
	CreateTimer(1.0, Party_Timer_CreateMemberDecal, client);
	
	// Return compliance
	return compliance;
}

// Remove member from group
bool removeMember(int client, int partyID){
	
	if (partyID == PARTY_UNDEFINED){
		return false;
	}
	
	// Get party structure
	ZParty party;
	ZPartys.GetArray(partyID, party);
	
	// Search client's party arrayid
	int memberId = -1;
	
	// If not member of this party, return
	if ((memberId = party.getMemberArrayId(client)) == -1){
		LogError("[PARTY] El usuario %N (id %i) no pertenece al party ID %i", client, client, partyID);
		return false;
	}
	
	// If he is the owner
	if(party.iOwner == client){
		
		// And members-1 is still 2 or more
		if (party.length()-1 > 1){
			
			// Store new owner's ID
			party.iOwner = party.getMemberByArrayId(1);
			
			// Print message to the other members
			int member;
			
			// Loop through the members
			for (int i = 1; i < party.length(); i++){
				member = party.getMemberByArrayId(i);
				
				if (member < 0)
					return false;
				
				party.printMessageToMember(member, "%s El líder salió de la party, ahora \x05%N\x01 es el líder.", SERVERSTRING, party.iOwner);
			}
		}
	}
	
	// Clean member's partyUID
	ZPlayer(client).iPartyUID = PARTY_UNDEFINED;
	
	// Remove member from array
	party.partyMembers.Erase(memberId);
	
	// Update structure with new data
	ZPartys.SetArray(id, party);
	
	// If player isn't connected, return
	if (!IsPlayerExist(client))
		return false;
	
	// else, print info
	PrintToChat(client, "%s Has salido del \x03party\x01.", SERVERSTRING);
	
	// Remove party mate icon
	RemoveDecalAbovePlayer(client);
	
	// Success!
	return true;
}

//=====================================================
//		THESE FUNCS USE THE FUNCTIONS DEFINED BEFORE
//=====================================================

// Create group
bool createGroup(int owner, int member){
	
	// If any user isn't properly connected
	if (!IsPlayerExist(owner) || !IsPlayerExist(member))
		return false;
	
	// Method to call ZPlayer
	ZPlayer p = ZPlayer(owner);
	ZPlayer p2 = ZPlayer(member);
	
	// If any of those is in party, return
	if (p.isInParty() || p2.isInParty())
		return false;
	
	// If levels don't accomplish conditions, return
	if (userLevelAccomplishes(p.iLevel, p2.iLevel))
		return false;
	
	// Get random UID
	int UID = GetRandomInt(PARTY_UID_BASE, PARTY_UID_CEIL);
	
	// If UID already exists, get another non-existant
	while(findPartyByUID(UID) != -1) UID = GetRandomInt(PARTY_UID_BASE, PARTY_UID_CEIL);
	
	// 
	//ZParty party = ZParty(gPartys.Length);
	
	ZParty party;
	
	party.id = ZPartys.Length;
	party.iUID = UID;
	
	// Add owner to the party
	if (party.addMember(owner, false) != PARTY_NO_ERROR){ // don't check userCanJoin because we are creating the party
		PrintToServer("[PARTY] ERROR AL AGREGAR MIEMBRO: OWNER ID %d al PARTY %d", owner, party.id);
		return false;
	}
	else{
		party.iOwner = owner;
	}
	
	// Add second member to the party
	if (party.addMember(member, false) != PARTY_NO_ERROR){ // same reason as above
		PrintToServer("[PARTY] ERROR AL AGREGAR MIEMBRO: MEMBER ID %d al PARTY %d", member, party.id);
		
		// Couldnt add second member, so, remove added owner
		removeMember(owner, party.id);
		
		return false;
	}
	
	ZPartys.PushArray(party);
	
	return true;
}

// Delete group
bool deleteGroup(int UID){
	
	int id;
	
	if ((id = findPartyByUID(UID)) == PARTY_UNDEFINED){
		LogError("[PARTY] No se pudo encontrar el ID de party número %d", id);
		return false;
	}
	
	ZParty party;
	ZPartys.GetArray(id, party);
	
	int length = this.length();
		
	//char buff[32];
	int playerId;
	for(int i = 0; i < length; i++){
		playerId = party.getMemberByArrayId(0);
		
		//GetClientName(playerId, buff, sizeof(buff));
		//PrintToChatAll("Eliminando a %s del party %d", buff, party.id);
		removeMember(playerId, id);
		//PrintToChatAll("%s eliminado de la party con exito. (iPartyUID: %d)", buff, p.iPartyUID);
	}
	
	ZPartys.Erase(this.id);
	
	return true;
}

//
void Party_OnPluginStart(){
	
	//Parties
	ZPartys = new ArrayList(sizeof(ZParty));
	PartyData.partyMembers = CreateArray();
}

stock bool userLevelAccomplishes(int level1, int level2){
	
	if (AbsValue(level1 - level2) > PARTY_MAX_DIFFERENCE)
		return false;
	
	return true;
}


//
//
//
//
// CREATE MEMBER DECAL
/**
 * Gets the Global Name of an entity.
 *
 * @param entity			Entity index.
 * @param buffer			Return/Output buffer.
 * @param size				Max size of buffer.
 * @return					Number of non-null bytes written.
 */
stock int Entity_GetGlobalName(int entity, char[] buffer, int size){
	return GetEntPropString(entity, Prop_Data, "m_iGlobalname", buffer, size);
}

/**
 * Sets the Global Name of an entity.
 *
 * @param entity			Entity index.
 * @param name				The global name you want to set.
 * @return					True on success, false otherwise.
 */
stock bool Entity_SetGlobalName(int entity, const char[] name, any ...){
	
	if (!IsValidEntity(entity))
		return false;
	
	char format[128];
	VFormat(format, sizeof(format), name, 3);

	return DispatchKeyValue(entity, "globalname", format);
}

public Action Party_Timer_CreateMemberDecal(Handle timer, any client){
	
	if (!IsPlayerExist(client))
		return;
	
	ZPlayer player = ZPlayer(client);
	
	if (!player.isInParty())
		return;
	
	gPartyDecalEntity[client] = SpawnDecalAbovePlayer(client, "materials/overlays/friends2.vmt");
	
	if (gPartyDecalEntity[client] != -1){
		char Gname[24];
		FormatEx(Gname, sizeof Gname, "partySprite_UID_%i", player.iPartyUID);
		
		Entity_SetGlobalName(gPartyDecalEntity[client], Gname);
		
		SDKHook(gPartyDecalEntity[client], SDKHook_SetTransmit, ShowFriendOverlay);
	}
}

public Action ShowFriendOverlay(int ent, int client){
	char Gname[24];
	Entity_GetGlobalName(ent, Gname, sizeof(Gname));
	
	// If not party sprite, return
	if (StrContains(Gname, "partySprite_UID_") == -1)
		return Plugin_Handled;
	
	int UID = StringToInt(Gname[16]);
	if(ZPlayer(client).iPartyUID == UID)
		return Plugin_Continue;
	else
		return Plugin_Handled;
}

stock int SpawnDecalAbovePlayer(int client, const char sDecal[PLATFORM_MAX_PATH]){
	
	if (!IsPlayerExist(client, true))
		return -1;
	
	int iEnt = CreateEntityByName("env_sprite");
	if(iEnt == -1)
		return -1;
	
	SetEntityModel(iEnt, sDecal);
	DispatchKeyValue(iEnt, "GlowProxySize", "1");
	DispatchKeyValue(iEnt, "rendercolor", "82 200 0");
	DispatchKeyValue(iEnt, "renderamt", "140");
	DispatchKeyValue(iEnt, "rendermode", "5");
	DispatchKeyValue(iEnt, "renderfx", "0");
	DispatchKeyValueFloat(iEnt, "framerate", 15.0);
	DispatchKeyValueFloat(iEnt, "scale", 0.05);
	char sBuffer[32];
	Format(sBuffer, sizeof(sBuffer), "1337client_%d", iEnt);
	DispatchKeyValue(client, "targetname", sBuffer);
	float fMin[3] = {-50.0, -50.0, 0.0};
	float fMax[3] = {50.0, 50.0, 100.0};
	SetEntPropVector(iEnt, Prop_Send, "m_vecMins", fMin);
	SetEntPropVector(iEnt, Prop_Send, "m_vecMaxs", fMax);
	SetEntProp(iEnt, Prop_Send, "m_nSolidType", 2);
	int iEffects = GetEntProp(iEnt, Prop_Send, "m_fEffects");
	SetEntProp(iEnt, Prop_Send, "m_fEffects", (iEffects | 32));
	DispatchSpawn(iEnt);
	ActivateEntity(iEnt);
	float fOrigin[3];
	GetClientEyePosition(client, fOrigin);
	
	// Place 30 units above player's head.
	fOrigin[2] += 30.0;
	
	TeleportEntity(iEnt, fOrigin, NULL_VECTOR, NULL_VECTOR);
	SetVariantString(sBuffer);
	AcceptEntityInput(iEnt, "SetParent");
	
	return iEnt;
}

bool RemoveDecalAbovePlayer(int client){
	
	if(!IsPlayerExist(client))
		return false;
	
	char sBuffer[32];
	GetEntPropString(client, Prop_Data, "m_iName", sBuffer, sizeof(sBuffer));
	
	// That player doesn't have a sprite above his head, which has been spawned with the above stock.
	if(StrContains(sBuffer, "1337client_") != 0){
		
		DispatchKeyValue(client, "targetname", "");
		return false;
	}
	
	int iEnt = StringToInt(sBuffer[11]);
	if(iEnt <= 0 || !IsValidEntity(iEnt) || !IsValidEdict(iEnt))
		return false;
	
	GetEdictClassname(iEnt, sBuffer, sizeof(sBuffer));
	
	if(!StrEqual(sBuffer, "env_sprite")){
		
		DispatchKeyValue(client, "targetname", "");
		return false;
	}
	
	AcceptEntityInput(iEnt, "Kill");
	DispatchKeyValue(client, "targetname", "");
	
	gPartyDecalEntity[client] = -1;
	return true;
}

public void Party_OnPlayerDeath(int client){
	RemoveDecalAbovePlayer(client);
}

// Function to check whether the message should be handled by party chat or not
stock bool Party_OnSayCommand(int client, char[] msg, int maxsize){
	
	if (!IsPlayerExist(client))
		return false;
		
	if (msg[0] != '#')
		return false;
	
	ZPlayer player = ZPlayer(client);
	
	if (player.isInParty()){
		ReplaceStringEx(msg, maxsize, "#", "");
		ReplaceString(msg, maxsize, "%", "%%");
		
		ZParty party = ZParty(findPartyByUID(player.iPartyUID));
		for (int i; i < party.length(); i++){
			CPrintToChat(party.getMemberByArrayId(i), "{lime}[PARTY] {player %d}%N{default}: %s", client, client, msg);
		}
	}
	else{
		CPrintToChat(client, "{lime}[PIU]{default} No estás en party.");
	}
		
	return true;
}

public void Party_OnPlayerDeath(int client){
	RemoveDecalAbovePlayer(client);
}

// Function to check whether the message should be handled by party chat or not
stock bool Party_OnSayCommand(int client, char[] msg, int maxsize){
	
	if (!IsPlayerExist(client))
		return false;
		
	if (msg[0] != '#')
		return false;
	
	ZPlayer player = ZPlayer(client);
	
	if (player.isInParty()){
		ReplaceStringEx(msg, maxsize, "#", "");
		ReplaceString(msg, maxsize, "%", "%%");
		
		int id = findPartyByUID(player.iPartyUID);
		ZParty party;
		ZPartys.GetArray(id, party);
		
		for (int i; i < party.length(); i++){
			CPrintToChat(party.getMemberByArrayId(i), "{lime}[PARTY] {player %d}%N{default}: %s", client, client, msg);
		}
	}
	else{
		CPrintToChat(client, "{lime}[PIU]{default} No estás en party.");
	}
		
	return true;
}