//
// Party manager
//
#include <colorvariables>

bool allowParty = true;

#define PARTY_MODULE_VERSION "0.1"

#define PARTY_MIN_PLAYERS_ONLINE 5
#define PARTY_MAX_COUNT 20
#define PARTY_MAX_MEMBERS 3
#define PARTY_MAX_DIFFERENCE 400 // level difference
#define PARTY_BOOST_PER_PLAYER 0.05 // percentage
#define PARTY_UID_BASE 1000
#define PARTY_UID_CEIL 3000
#define PARTY_UNDEFINED -1

//Arraylist que guarda UIDS de parties
ArrayList 	gPartys;

//Arraylist que guarda el id de los players de una party.
ArrayList 	gPartyMembers[PARTY_MAX_COUNT];

Handle 		gPartyComboHandle[PARTY_MAX_COUNT];
int			gPartyCombo[PARTY_MAX_COUNT];
int			gPartyDamageDealt[PARTY_MAX_COUNT];
int			gPartyOwner[PARTY_MAX_COUNT];

int 	gPartyDecalEntity[MAXPLAYERS+1] = -1;

//
void PartyOnInit(){
	
	//Parties
	gPartys = CreateArray(4);
	for(int i = 0; i < PARTY_MAX_COUNT; i++){
		gPartyMembers[i] = CreateArray(4);
	}
}

void Party_OnMapEnd(){
	gPartys.Clear();
	for(int i = 0; i < PARTY_MAX_COUNT; i++){
		gPartyMembers[i].Clear();
	}
}

void Party_OnPluginEnd(){
	delete gPartys;
	for(int i = 0; i < PARTY_MAX_COUNT; i++){
		delete gPartyMembers[i];
	}
}

enum PartyError{
	PARTY_NO_ERROR,
	PARTY_GROUP_FULL,
	PARTY_GROUP_LEVEL_EXCEEDS,
	PARTY_PLAYER_NOT_VALID,
	PARTY_PLAYER_IN_PARTY,
	PARTY_ERROR_ANY
}

//=====================================================
//				PARTY STOCKS AND UTILS
//=====================================================

stock bool userLevelAccomplishes(int level1, int level2){
	
	if (AbsValue(level1 - level2) > PARTY_MAX_DIFFERENCE)
		return false;
	
	return true;
}


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
		return Plugin_Continue;
	
	if (!gClientData[client].bInParty)
		return Plugin_Continue;
	
	gPartyDecalEntity[client] = SpawnDecalAbovePlayer(client, "materials/overlays/friends2.vmt");
	
	if (gPartyDecalEntity[client] != -1){
		char Gname[24];
		FormatEx(Gname, sizeof Gname, "partySprite_UID_%i", gClientData[client].iPartyUID);
		
		Entity_SetGlobalName(gPartyDecalEntity[client], Gname);
		
		SDKHook(gPartyDecalEntity[client], SDKHook_SetTransmit, ShowFriendOverlay);
	}

	return Plugin_Continue;
}

public Action ShowFriendOverlay(int ent, int client){
	char Gname[24];
	Entity_GetGlobalName(ent, Gname, sizeof(Gname));
	
	// If not party sprite, return
	if (StrContains(Gname, "partySprite_UID_") == -1)
		return Plugin_Handled;
	
	int UID = StringToInt(Gname[16]);
	if(gClientData[client].iPartyUID == UID)
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

public void PartyOnPlayerDeath(int client){
	RemoveDecalAbovePlayer(client);
}

//=====================================================
//					PARTY METHOD
//=====================================================

methodmap ZParty {
	public ZParty(int partyid){
		return view_as<ZParty>(partyid);
	}
	property int id{
		public get(){
			return view_as<int>(this);
		}
	}
	property int iUID{
		public get(){
			return gPartys.Get(this.id);
		}
	}
	property int iOwner{
		public get(){ return gPartyOwner[this.id]; }
		public set(int value){ gPartyOwner[this.id] = value; }
	}
	
	// Party combos
	property Handle hComboHandle{
		public get(){ return gPartyComboHandle[this.id]; }
		public set(Handle value){ gPartyComboHandle[this.id] = value; }
	}
	property float fComboTime{
		public get(){
			return gClientData[this.id].fComboTime;
		}
		public set(float value){
			gClientData[this.id].fComboTime = value;
		}
	}
	property int iCombo{
		public get(){ return gPartyCombo[this.id]; }
		public set(int value){ gPartyCombo[this.id] = value; }
	}
	property int iDamageDealt{
		public get(){ return gPartyDamageDealt[this.id]; }
		public set(int value){ gPartyDamageDealt[this.id] = value; }
	}
	
	// Party members count
	public int length(){
		return gPartyMembers[this.id].Length;
	}
	
	// Function to find member's ID by array search
	public int getMemberByArrayId(int arrayId){
		
		if (-1 < arrayId < this.length())
			return gPartyMembers[this.id].Get(arrayId);
			
		return -1;
	}
	
	public int getMemberArrayId(int client){
		
		int value = -1;
		
		if (gClientData[client].bInParty){
			value = gPartyMembers[this.id].FindValue(client);
		}
		
		return value;
	}
	
	// Average stats
	public int avgLevel(){
			
		int ret = 0;
		
		if (this.length()){
			ZPlayer player;
			for(int i = 0; i < this.length(); i++){
				player = ZPlayer(this.getMemberByArrayId(i));
				ret += player.iLevel;
			}
			ret = ret / this.length();
		}
		
		return ret;
	}
	public int avgReset(){
		
		int ret = 0;
		
		if (this.length()){
			ZPlayer player;
			for(int i = 0; i < this.length(); i++){
				player = ZPlayer(this.getMemberByArrayId(i));
				ret += player.iReset;
			}
			ret = ret / this.length();
		}
		
		return ret;
	}
	
	// Get valid players
	public int getValidPlayers(){
		
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
	public int iMaxLevel(){
		int lvl = 0;
		for(int i=0; i < this.length(); i++){
			ZPlayer player = ZPlayer(this.getMemberByArrayId(i));
			if(lvl < player.iLevel) lvl = player.iLevel;
		}
		return lvl;
	}
	
	// Total boost counting players in party
	public float getTotalBoost(){
		return PARTY_BOOST_PER_PLAYER * this.getValidPlayers();
	}
	
	public PartyError userCanJoin(int client){
		
		if (!IsPlayerExist(client)){
			return PARTY_PLAYER_NOT_VALID;
		}
			
		if (gClientData[client].bInParty){
			return PARTY_PLAYER_IN_PARTY;
		}
		
		if (this.length() >= PARTY_MAX_MEMBERS){
			return PARTY_GROUP_FULL;
		}
		
		if (!gClientData[client].bLoaded){
			return PARTY_ERROR_ANY;
		}
		
		/*if (!userLevelAccomplishes(this.iMaxLevel(), gClientData[client].iLevel)){
			return PARTY_GROUP_LEVEL_EXCEEDS;
		}*/
		
		return PARTY_NO_ERROR;
	}
	public PartyError addMember(int client){
		
		PartyError compliance = this.userCanJoin(client);
		
		if (compliance == PARTY_NO_ERROR){
			//PrintToChatAll("PARTYUID %d set to ClientData[%d].iPartyUID", this.iUID, client);
			gClientData[client].iPartyUID = this.iUID;
			gClientData[client].bInParty = true;
			gPartyMembers[this.id].Push(client);
			CreateTimer(1.0, Party_Timer_CreateMemberDecal, client);
		}		

		return compliance;
	}
	public bool removeMember(int client){
		
		// Update new owner
		if(this.iOwner == client && this.length()-1 >= 2){
			
			int owner = this.getMemberByArrayId(1);
			
			if (!IsPlayerExist(owner)){
				LogError("[PARTY] owner inválido en party index %d", this.id);
				return false;
			}
			
			// Owner's memberId is 0, so, new owner's memberId is 1
			this.iOwner = owner;
			
			int member;
			for (int i = 1; i < this.length(); i++){
				member = this.getMemberByArrayId(i);
				
				if(!IsPlayerExist(member))
					continue;
				
				PrintToChat(member, "%s El líder salió de la party, ahora \x05%N\x01 es el líder.", SERVERSTRING, this.iOwner);
			}
		}
		
		// Reset variables to the removed player
		int memberId = this.getMemberArrayId(client);
		
		// Prevent modification of attributes to non-members
		if (memberId >= 0){
			gClientData[client].iPartyUID = PARTY_UNDEFINED;
			gClientData[client].bInParty = false;
			gPartyMembers[this.id].Erase(memberId);
			
			if (!IsPlayerExist(client))
				return false;
		
			PrintToChat(client, "%s Has salido del \x03party\x01.", SERVERSTRING);
			RemoveDecalAbovePlayer(client);
		}
		else{
			LogError("[PARTY] El usuario %N (id %i) no pertenece al party ID %i", client, client, this.id);
		}
		
		return true;
	}
}

stock bool CreateParty(int owner, int member){
	
	// If any user isn't properly connected
	if (!IsPlayerExist(owner) || !IsPlayerExist(member))
		return false;
	
	// If any of those is in party, return
	if (gClientData[owner].bInParty || gClientData[member].bInParty)
		return false;
	
	if (partyFindPlayerInPartyArray(owner) != -1 || partyFindPlayerInPartyArray(member) != -1){
		return false;
	}
	
	// If levels don't accomplish conditions, return
	if (!userLevelAccomplishes(gClientData[owner].iLevel, gClientData[member].iLevel))
		return false;
	
	// Get random UID
	int UID = GetRandomInt(PARTY_UID_BASE, PARTY_UID_CEIL);
	
	// If UID already exists, get another non-existant
	while(findPartyByUID(UID) != -1) UID = GetRandomInt(PARTY_UID_BASE, PARTY_UID_CEIL);
	
	// Create ZParty
	ZParty party = ZParty(gPartys.Push(UID));
	
	// Add owner to the party
	if (party.addMember(owner) != PARTY_NO_ERROR){ // don't check userCanJoin because we are creating the party
		LogError("[PARTY] ERROR AL AGREGAR MIEMBRO: OWNER ID %d al PARTY %d", owner, party.id);
		
		DeleteParty(party.id);
		return false;
	}
	
	party.iOwner = owner;
	
	// Add second member to the party
	if (party.addMember(member) != PARTY_NO_ERROR){ // same reason as above
		LogError("[PARTY] ERROR AL AGREGAR MIEMBRO: MEMBER ID %d al PARTY %d", member, party.id);
		
		// Couldnt add second member, so, delete party
		DeleteParty(party.id);
		
		return false;
	}
	
	return true;
}
stock int findPartyByUID(int uid){
	return gPartys.FindValue(uid);
}
stock void DeletePartyByUID(int uid){
	int id = findPartyByUID(uid);
	DeleteParty(id);
}

stock void DeleteParty(int id){
	
	if (id < 0){
		LogError("[PARTY] No se pudo encontrar el ID de party número %d", id);
		return;
	}
	
	ZParty party = ZParty(id);
	int length = party.length();
		
	//char buff[32];
	int playerId;
	for(int i = 0; i < length; i++){
		playerId = party.getMemberByArrayId(0);
		
		//GetClientName(playerId, buff, sizeof(buff));
		//PrintToChatAll("Eliminando a %s del party %d", buff, party.id);
		party.removeMember(playerId);
		//PrintToChatAll("%s eliminado de la party con exito. (iPartyUID: %d)", buff, p.iPartyUID);
	}
	gPartys.Erase(party.id);
}

// Function to check whether the message should be handled by party chat or not
stock bool Party_OnSayCommand(int client, char[] msg, int maxsize){
	
	if (!IsPlayerExist(client))
		return false;
		
	if (msg[0] != '#')
		return false;
	
	if (gClientData[client].bInParty){
		ReplaceStringEx(msg, maxsize, "#", "");
		ReplaceString(msg, maxsize, "%", "%%");
		
		ZParty party = ZParty(findPartyByUID(gClientData[client].iPartyUID));
		for (int i; i < party.length(); i++){
			CPrintToChat(party.getMemberByArrayId(i), "{lime}[PARTY] {player %d}%N{default}: %s", client, client, msg);
		}
	}
	else{
		CPrintToChat(client, "{lime}[PIU]{default} No estás en party.");
	}
	
	DispatchKeyValue(client, "targetname", "");
	
	gPartyDecalEntity[client] = -1;
	return true;
}

void PartyOnCommandInit(){
	
	// Party
	RegConsoleCmd("receive", changeReceiveOp);
	RegConsoleCmd("leave", leaveParty);
	RegConsoleCmd("party", showMenuParty);
}

void PartyOnClientInit(int client){
	
	gClientData[client].iPartyUID = -1;
	gClientData[client].bInParty = false;
}

public Action leaveParty(int client, int args){
	
	if (IsFakeClient(client) || !IsClientConnected(client)){
		return Plugin_Handled;
	}
	
	
	if(gClientData[client].bInParty){
		int partyIndex = findPartyByUID(gClientData[client].iPartyUID);
		
		if (partyIndex == -1){
			if (IsPlayerExist(client)){
				PrintToChat(client, "%s No se pudo encontrar el ID de party con \x05UID %i\x01.", SERVERSTRING, gClientData[client].iPartyUID);
				LogError("[PARTY] No se pudo encontrar el ID de party con UID %i, user %N ID %i.", gClientData[client].iPartyUID, client, client);
				partyDestroyPartyUID(gClientData[client].iPartyUID);
			}
			
			return Plugin_Handled;
		}
		
		ZParty party = ZParty(partyIndex);
		if(party.length()-1 <= 1){
			SafeEndComboParty(party.id);
			DeleteParty(party.id);
			//party.deleteGroup();
		}
		else{
			/*
			if (player.isType(PT_HUMAN)){
				SafeEndComboParty(party.id);
			}*/
			party.removeMember(client);
		}
	}
	else{
		
		if (IsPlayerExist(client)){
			PrintToChat(client, "%s No estás en party.", SERVERSTRING);
		}
	}
	return Plugin_Handled;
}

public Action changeReceiveOp(int client, int args){
	
	gClientData[client].bReceivePartyInv = !gClientData[client].bReceivePartyInv;
	PrintToChat(client, "%s \x03%s\x01 las invitaciones de party.", SERVERSTRING, gClientData[client].bReceivePartyInv ? "Activaste" : "Desactivaste");
	
	return Plugin_Handled;
}

void partyDestroyPartyUID(int UID){
	
	int partyIndex = findPartyByUID(UID);
	
	if (partyIndex != -1){
		DeleteParty(partyIndex);
		return;
	}
	
	int partyArrayIDByMemberClientID = -1;
	
	// Search in every dimension of members array
	for(int i = 0; i < gPartys.Length; i++){
		
		// Loop through players to see if their id is inside of the array
		for (int j = 1; j <= MaxClients; j++){
			if (gPartyMembers[i].FindValue(i) != -1){ // found his ID here
				partyArrayIDByMemberClientID = gPartyMembers[i].FindValue(i);
				break;
			}
		}
		
		// Members array is bugged because parties array has been shifted
		if (partyArrayIDByMemberClientID != -1){
			gPartyMembers[i].Erase(partyArrayIDByMemberClientID);
		}
	}
	
	//  Loop throught players to disable party variables
	for (int i = 1; i <= MaxClients; i++){
		
		// If his party UID isnt the one we are looking for, skip him
		if (gClientData[i].iPartyUID != UID){
			continue;
		}
		
		// Disable party variables
		gClientData[i].iPartyUID = -1;
		gClientData[i].bInParty = false;
	}
	
	LogToFile("/addons/sourcemod/logs/PARTY_DESTROYED.txt", "[PARTY] Party with UID %d has been forcibly destroyed", UID);
}

int partyFindPlayerInPartyArray(int client){
	
	if (client <= 0){
		return -1;
	}
	
	int partyID = -1;
	
	if (gPartys.Length){
		for (int i; i < gPartys.Length; i++){
			
			if (gPartyMembers[i].FindValue(client) != -1){
				
				partyID = i;
				break;
			}
		}
	}
	
	return partyID;
}