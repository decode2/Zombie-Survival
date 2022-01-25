#pragma semicolon 1
#pragma newdecls required

#define DEBUG

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <basecomm>

#if defined main_included
	#endinput
#endif
#define main_included

#define HIDEHUD_CSGO_ALL 						( 1<<2 )
#define HIDEHUD_CSGO_HEALTH_AND_CROSSHAIR 		( 1<<4 )
#define HIDEHUD_CSGO_RADAR 						( 1<<12 )
#define HIDEHUD_RADARANDTIMER 					12288

// Spectator defines
#define SPECMODE_NONE 				0
#define SPECMODE_FIRSTPERSON 		4
#define SPECMODE_3RDPERSON 			5
#define SPECMODE_FREELOOK	 		6


#define VIP_SAY_DURATION 	5.25
#define VIP_SAY_MAXLEN 		164

#define WELCOME_SOUND "*/MassiveInfection/bienvenidoapiubreakers.mp3"

#define INVISIBLE_KNIFE "models/weapons/mtch/w_empty.mdl"

bool 	gAdmin[MAXPLAYERS+1];
bool 	gLadder[MAXPLAYERS+1];
bool 	gMuted[MAXPLAYERS+1];
int 	gPredictedViewModelIndex[MAXPLAYERS+1];
bool 	gLogged[MAXPLAYERS+1];
bool 	gInUser[MAXPLAYERS+1];
bool 	gInPassword[MAXPLAYERS+1];
bool 	gInCreatingCharacter[MAXPLAYERS+1];
bool 	gInGame[MAXPLAYERS+1];
bool 	gCanChangeName[MAXPLAYERS+1];
bool 	gHasMail[MAXPLAYERS+1] = false;
bool 	gHasPassword[MAXPLAYERS+1] = false;

methodmap Player{
	public Player(int value){
		return view_as<Player>(value);
	}
	property int id { 
        public get(){ 
			return view_as<int>(this); 
		} 
    }
	property int iHealth{
        public get() 
		{ 
			return GetClientHealth(this.id); 
		}
		
        public set(int value) 
		{ 
			SetEntProp(this.id, Prop_Send, "m_iHealth", value, 4); 
		}
    }
    property int iArmor{
        public get() 
		{ 
			return GetClientArmor(this.id); 
		}
		
		public set(int value) 
		{ 
			SetEntProp(this.id, Prop_Send, "m_ArmorValue", value, 4); 
		}
    }
	property int iFrags{
		public get() 
		{ 
			return GetEntProp(this.id, Prop_Data, "m_iFrags"); 
		}
		
		public set(int value)
		{ 
			SetEntProp(this.id, Prop_Data, "m_iFrags", value); 
		}
	}
	property int iDeaths{
		public get() 
		{ 
			return GetEntProp(this.id, Prop_Data, "m_iDeaths");
		}
		
		public set(int value) 
		{ 
			SetEntProp(this.id, Prop_Data, "m_iDeaths", value); 
		}
	}
	property int iFlags{
		public get() 
		{ 
			return GetEntityFlags(this.id);
		}
		
        public set(int value) 
		{ 
			SetEntityFlags(this.id, value);
		}
	}
	property int iTeamNum{
		public get() {
			if (!IsPlayerExist(this.id, false))
				return -1;
			
			return GetClientTeam(this.id); 
		}
		public set(int value) { 
			CS_SwitchTeam(this.id, value);
		}
	}
	property int iPredictedViewModelIndex{
		public get()
		{
			return gPredictedViewModelIndex[this.id];
		}
		public set(int value)
		{
			gPredictedViewModelIndex[this.id] = EntRefToEntIndex(value);
		}
	}
    /*
    property int iNightVision{
		public get() 
		{ 
			return GetEntProp(this.id, Prop_Send, "m_bNightVisionOn"); 
		}
		
        public set(int value) 
		{ 
			SetEntProp(this.id, Prop_Send, "m_bNightVisionOn", value); 
		}
	}*/
	property bool bAlive{
		public get(){
			return IsPlayerAlive(this.id);
		}
	}
	property bool bLadder{
		public get(){
			return gLadder[this.id];
		}
		public set(bool value){
			gLadder[this.id] = value;
		}
	}
	property bool bMuted{
		public get(){
			return gMuted[this.id];
		}
		public set(bool value){
			BaseComm_SetClientMute(this.id, value);
		}
	}
	property bool bAdmin{
		public get() {return gAdmin[this];}
		public set(bool value){
			gAdmin[this] = value;
		}
	}
	property bool bStaff{
		public get(){
			char name[32];
			GetClientName(this.id, name, sizeof(name));
			
			if (StrEqual(name, "Deco") || StrEqual(name, "Codes"))
				return true;
				
			return false;
		}
	}
	property bool bLogged{
		public get(){
			return gLogged[this.id];
		}
		public set(bool value){
			gLogged[this.id] = value;
		}
	}
	property bool bInUser{
		public get(){
			return gInUser[this.id];
		}
		public set(bool value){
			gInUser[this.id] = value;
		}
	}
	property bool bInPassword{
		public get(){
			return gInPassword[this.id];
		}
		public set(bool value){
			gInPassword[this.id] = value;
		}
	}
	property bool bInCreatingCharacter{
		public get(){
			return gInCreatingCharacter[this.id];
		}
		public set(bool value){
			gInCreatingCharacter[this.id] = value;
		}
	}
	property bool bInGame{
		public get(){
			return gInGame[this.id];
		}
		public set(bool value){
			gInGame[this.id] = value;
		}
	}
	property bool bCanChangeName{
		public get(){
			return gCanChangeName[this.id];
		}
		public set(bool value){
			gCanChangeName[this.id] = value;
		}
	}
	property bool bHasMail{
		public get(){
			return gHasMail[this.id];
		}
		public set(bool value){
			gHasMail[this.id] = value;
		}
	}
	property bool bHasPassword{
		public get(){
			return gHasPassword[this.id];
		}
		public set(bool value){
			gHasPassword[this.id] = value;
		}
	}
	property MoveType iMoveType{
		public get(){ 
			return GetEntityMoveType(this.id);
		}
		
        public set(MoveType value){ 
			SetEntityMoveType(this.id, value);
		}
	}
	
	public void iTeleportPlayer(float origin[3] = NULL_VECTOR, float angles[3] = NULL_VECTOR, float velocity[3] = NULL_VECTOR){
		TeleportEntity(this.id, origin, angles, velocity);
	}
	
	public void iFOV(int value) {
		SetEntProp(this.id, Prop_Send, "m_iFOV", value);
		SetEntProp(this.id, Prop_Send, "m_iDefaultFOV", value);
	}
	
	public void iRender(int red, int green, int blue) {
		SetEntityRenderMode(this.id, RENDER_TRANSCOLOR);
		SetEntityRenderColor(this.id, red, green, blue, 255);
	}
	
	public void respawnPlayer(){
		CS_RespawnPlayer(this.id);
	}
	
	property float flSpeed{
		public get() { 
			return GetEntPropFloat(this.id, Prop_Data, "m_flLaggedMovementValue"); 
		}
		public set(float value) { 
			SetEntPropFloat(this.id, Prop_Data, "m_flLaggedMovementValue", value);
		}
	}
	property float flGravity{
		public get(){ 
			return GetEntityGravity(this.id); 
		}
		public set(float value){
			SetEntityGravity(this.id, value); 
		}
	}
	
	public void bSetGlow(bool value){
		SetEntPropFloat(this.id, Prop_Send, "m_flDetectedByEnemySensorTime", value ? (GetGameTime() + 9999.0) : 0.0);
	}
	
	public void setModel(char[] model, char[] arms) {
		if (IsValidEdict(this.id)){
			if(IsModelPrecached(model) && !StrEqual(model, ""))
				SetEntityModel(this.id, model);
			else
				PrintToServer("Model %s not precached", model);
			
			if(!StrEqual(arms, ""))
				SetEntPropString(this.id, Prop_Send, "m_szArmsModel", arms);
		}
	}
	public void removeWeapons(){
		if(GetPlayerWeaponSlot(this.id, CS_SLOT_PRIMARY) != -1)
			RemovePlayerItem(this.id, GetPlayerWeaponSlot(this.id, CS_SLOT_PRIMARY));
			
		if(GetPlayerWeaponSlot(this.id, CS_SLOT_SECONDARY) != -1)
			RemovePlayerItem(this.id, GetPlayerWeaponSlot(this.id, CS_SLOT_SECONDARY));
			
		for (int i; i <= 4; i++){
			if(GetPlayerWeaponSlot(this.id, CS_SLOT_GRENADE) != -1)	RemovePlayerItem(this.id, GetPlayerWeaponSlot(this.id, CS_SLOT_GRENADE));
		}
    }
}
//-----------------------------------------------------
// SQL Validation
//-----------------------------------------------------
enum InputErrorCodes {
	INPUT_LARGE = 0,
	INPUT_SHORT,
	INPUT_INVALID_SIMBOL,
	INPUT_INVALID_SPACE,
	INPUT_NOT_AT,
	INPUT_INVALID_MAIL,
	INPUT_OK
};
enum EntryType {
	DATA_MAIL,
	DATA_PASSWORD,
	DATA_NAME
};
char sValidEmails[][] = {
	"hotmail.com",
	"live.com",
	"live.com.ar",
	"gmail.com",
	"outlook.com"
};
stock InputErrorCodes isEntryValidToSQL(const char[] input, EntryType entry){

	if (strlen(input) > MAX_NAME_LENGTH){
		PrintToServer("Invalid input for SQL, data too long (input was: %s)", input);
		return INPUT_LARGE;
	}
	
	switch (entry){
		case DATA_MAIL:{
			if (strlen(input) < 10){
				PrintToServer("Invalid input for SQL, data too short (input was: %s)", input);
				return INPUT_SHORT;
			}
			
			if (StrContains(input, "@") == -1){
				PrintToServer("Couldn't find @ in mail validation");
				return INPUT_NOT_AT;
			}
			
			bool isEmail = false;
			for (int i = 0; i < sizeof(sValidEmails); i++){
				char sTemp[16];
				FormatEx(sTemp, sizeof(sTemp), "@%s", sValidEmails[i]);
				
				if (StrContains(input, sTemp)){
					PrintToServer("Valid mail direction (found: %s)", sValidEmails[i]);
					isEmail = true;
					break;
				}
			}
			
			if (!isEmail)
				return INPUT_INVALID_MAIL;
		}
		case DATA_PASSWORD:{
			if (strlen(input) < 8){
				PrintToServer("Invalid input for SQL, data too short to be a password (input was: %s)", input);
				return INPUT_SHORT;
			}
		}
		case DATA_NAME:{
			if (strlen(input) < 3 || StrEqual(input, "")){
				PrintToServer("Invalid input for SQL, data too short to be a name (input was: %s)", input);
				return INPUT_SHORT;
			}
		}
	}
	
	return INPUT_OK;
}

stock bool IsPlayerExist(int clientIndex, bool clientAlive = false){
	// If client isn't valid
	if (clientIndex <= 0 || clientIndex > MaxClients){
		return false;
	}
	
	if(!IsValidEdict(clientIndex)) return false;
	
	// If client isn't connected
	if (!IsClientConnected(clientIndex)){
		return false;
	}

	// If client isn't in game
	if (!IsClientInGame(clientIndex)){
		return false;
	}

	// If client isn't alive
	if(clientAlive && !IsPlayerAlive(clientIndex)){
		return false;
	}
	
	// If client exist
	return true;
}

stock int fnGetAlive(){
	int nAlive;
	Player player;
	for (int i = 1; i <= MaxClients; i++){
		player = Player(i);
		
		if(!IsPlayerExist(player.id, true))
			continue;
		
		nAlive++;
	}
	return nAlive;
}
stock int fnGetRandomAlive(int nRandom){
	int nAlive;
	Player player;
	for (int i = 1; i <= MaxClients; i++){
		player = Player(i);
		
		if(!IsPlayerExist(player.id, true))
			continue;
		
		nAlive++;
		
		if (nAlive == nRandom){
			return i;
		}
	}
	return GetRandomInt(1, fnGetAlive());
}
stock int fnGetPlaying(bool nobots = false){
	int nPlaying;
	Player player;
	for (int i = 1; i <= MaxClients; i++){
		player = Player(i);
		
		if(!IsPlayerExist(player.id, false))
			continue;
		
		if (IsFakeClient(i) && nobots)
			continue;
		
		if(!IsFakeClient(i) && !player.bLogged)
			continue;
			
		nPlaying++;
	}
	return nPlaying;
}
stock int fnGetInTeam(int team){
	int nPlaying;
	Player player;
	for (int i = 1; i <= MaxClients; i++){
		player = Player(i);
		
		if(!IsPlayerExist(player.id, false))
			continue;
		
		if(!IsFakeClient(i) && !player.bLogged)
			continue;
		
		if (player.iTeamNum != team)
			continue;
		
		nPlaying++;
	}
	return nPlaying;
}
stock int fnGetAliveInTeam(int team){
	int nPlaying;
	Player player;
	for (int i = 1; i <= MaxClients; i++){
		player = Player(i);
		
		if(!IsPlayerExist(player.id, true))
			continue;
		
		if(!IsFakeClient(i) && !player.bLogged)
			continue;
		
		if (player.iTeamNum != team)
			continue;
		
		nPlaying++;
	}
	return nPlaying;
}
stock int fnGetAliveInTeamNoBots(int team){
	int nPlaying;
	Player player;
	for (int i = 1; i <= MaxClients; i++){
		player = Player(i);
		
		if(!IsPlayerExist(player.id, true))
			continue;
		
		if(!player.bLogged)
			continue;
		
		if (player.iTeamNum != team)
			continue;
		
		nPlaying++;
	}
	return nPlaying;
}

stock int AddPoints(int iNum, char[] szOutput, int iLen){
	char szTmp[17];
	int iOutputPos, iNumPos, iNumLen;
	iNumLen = IntToString(iNum, szTmp, sizeof(szTmp));
	
	if (iNumLen <= 3){
		iOutputPos += strcopy(szOutput[iOutputPos], iLen, szTmp);
	}
	else{
		while ((iNumPos < iNumLen) && (iOutputPos < iLen)){
			szOutput[iOutputPos++] = szTmp[iNumPos++];
			
			if ((iNumLen - iNumPos) && !((iNumLen - iNumPos) % 3)) 
				szOutput[iOutputPos++] = '.';
		}
		szOutput[ iOutputPos ] = EOS;
	}
	return iOutputPos;
}

stock int GetModelIndex(const char[] sModel){
	if(!FileExists(sModel))
		return -1;

	return PrecacheModel(sModel);
}
stock void SetWorldModel(int weaponIndex, int modelIndex){
	int worldIndex = GetEntPropEnt(weaponIndex, Prop_Send, "m_hWeaponWorldModel");
	
	if(IsValidEdict(worldIndex))
		SetEntProp(worldIndex, Prop_Send, "m_nModelIndex", modelIndex);
}
stock void SetViewModel(int weaponId, int viewId, int modelId){
	
	if(IsValidEntity(weaponId))
		SetEntProp(weaponId, Prop_Send, "m_nModelIndex", 0);
	
	if(IsValidEntity(viewId))
		SetEntProp(viewId, Prop_Send, "m_nModelIndex", modelId);
}

public void hideWorldModel(int weapon){
    if(IsValidEntity(weapon)) {
        int vm = GetEntPropEnt(weapon, Prop_Send, "m_hWeaponWorldModel");
        if(vm != -1) {
            SetEntProp(vm, Prop_Send, "m_nModelIndex", GetModelIndex(INVISIBLE_KNIFE));
        }
    }
}  

stock bool IsOnCooldown(int client, float flDelay){
	static float flTime[MAXPLAYERS+1];
	float flCurrentTime = GetEngineTime();
	
	// Cooldown don't over yet, then stop
	if ((flCurrentTime - flTime[client]) < flDelay)
		return true;
	
	flTime[client] = flCurrentTime;
	
	return false;
}

/*
stock int CSGO_ReplaceWeapon(int client, int slot, const char[] weapon_string){

	int old_weapon = GetPlayerWeaponSlot(client, slot);

	if (IsValidEntity(old_weapon)){
		if (GetEntPropEnt(old_weapon, Prop_Send, "m_hOwnerEntity") != client){
			SetEntPropEnt(old_weapon, Prop_Send, "m_hOwnerEntity", client);
		}

		CS_DropWeapon(client, old_weapon, false, true);
		AcceptEntityInput(old_weapon, "Kill");
	}

	int new_weapon = GivePlayerItem(client, weapon_string);

	if (IsValidEntity(new_weapon)){
		EquipPlayerWeapon(client, new_weapon);
	}
	
	return new_weapon;
}*/
/*
public void showInstructorHint(int client, char[] message, int target, int color) {
	char colorString[24];
	cColor[color].GetString(colorString, sizeof(colorString));
	
	int userId = GetClientUserId(client);
	char hintName[32]; //Used to override current displayed name.
	Format(hintName, sizeof(hintName), "gi_%d", userId);
	int iFlags = 0; //https://github.com/pmrowla/hl2sdk-csgo/blob/master/game/server/env_instructor_hint.cpp#L108-L113
	Event event = CreateEvent("instructor_server_hint_create", true);
	event.SetString("hint_name", hintName);
	event.SetString("hint_replace_key", hintName);
	event.SetInt("hint_target", target);
	event.SetInt("hint_activator_userid", userId);
	event.SetInt("hint_timeout", cTimeout.IntValue);
	event.SetString("hint_icon_onscreen", "");
	event.SetString("hint_icon_offscreen", "");
	event.SetString("hint_caption", message);
	event.SetString("hint_activator_caption", message);
	event.SetString("hint_color", colorString);
	event.SetFloat("hint_icon_offset", 0.0);
	event.SetFloat("hint_range", 0.0);
	event.SetInt("hint_flags", iFlags);
	event.SetString("hint_binding", "");
	event.SetBool("hint_allow_nodraw_target", true);
	event.SetBool("hint_nooffscreen", true);
	event.SetBool("hint_forcecaption", true);
	event.SetBool("hint_local_player_only", true);
	event.FireToClient(client);
	delete event;
}*/

char arrayUniqueCode[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789";
stock void GenerateUniqueCode(char[] sOutput, int size){
	
	for(int i = 0; i < size; i++){
		sOutput[i] = arrayUniqueCode[GetRandomInt(0, sizeof(arrayUniqueCode))];
	}
	
	sOutput[size-1] = EOS;
}