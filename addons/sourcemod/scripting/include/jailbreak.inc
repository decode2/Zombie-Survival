#pragma semicolon 1

#define DEBUG

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <main>

// Countdown defines
#define ROUND_START_INTERVAL 4.0
#define ROUND_START_COUNTDOWN 4

// One CT per X TTs
#define TT_QUANTITY_REQUIRED	4


#define DEAGLE_PRICE 100
#define LOCKPICK_PRICE 60
#define MERCA_PRICE 20
#define JERINGA_PRICE 35
#define PEPPERSPRAY_PRICE 40
#define ARMOR_PRICE 15
#define BATE_PRICE 50
#define POLICE_PRICE 25


//Sounds
#define DUEL_SOUND "*/PiuJailBreak/duels.mp3"
#define TT_WIN_SOUND "*/PiuJailBreak/policiapolicia.mp3"
#define CT_WIN_SOUND "*/PiuJailBreak/aminomeimporta.mp3"

//models
#define MODEL_MARTILLO "models/weapons/eminem/hammer/v_hammer.mdl"
#define WMODEL_MARTILLO "models/weapons/eminem/hammer/w_hammer.mdl"
#define VMODEL_FISTS "models/weapons/v_punchs.mdl"
#define VMODEL_BATON "models/weapons/eminem/police_baton/v_police_baton.mdl"
#define WMODEL_BATON "models/weapons/eminem/police_baton/w_police_baton.mdl"

// JPlayer
bool	gSimon[MAXPLAYERS+1];
bool	bMartillo[MAXPLAYERS+1];
bool	bLockpick[MAXPLAYERS+1];
int 	gCigarros[MAXPLAYERS+1];
int		gVipLevel[MAXPLAYERS+1];
int 	gTipoPresoSelected[MAXPLAYERS+1];
int		gNextTipoPreso[MAXPLAYERS+1];
int		gAdversario[MAXPLAYERS+1];
int 	gPjSelected[MAXPLAYERS+1];

// TipoPreso
ArrayList	gPNombre;
ArrayList	gPHealth;
ArrayList	gPArmor;
ArrayList	gPCigarros;
ArrayList	gPVelocidad;
ArrayList	gPGravedad;
ArrayList	gPDamage;


//Clase de preso
methodmap JPreso{
	public JPreso(int value){
		return view_as<JPreso>(value);
	}
	property int id { 
        public get(){ 
			return view_as<int>(this); 
		} 
    }
	property int iHealth{
		public get(){
			return gPHealth.Get(this.id);
		}
		public set(int value){
			gPHealth.Set(this.id, value);
		}
	}
	property int iArmor{
		public get(){
			return gPArmor.Get(this.id);
		}
		public set(int value){
			gPArmor.Set(this.id, value);
		}
	}
	
	property float flCigarros{
		public get(){
			return gPCigarros.Get(this.id);
		}
		public set(float value){
			gPCigarros.Set(this.id, value);
		}
	}
	property float flVelocidad{
		public get(){
			return gPVelocidad.Get(this.id);
		}
		public set(float value){
			gPVelocidad.Set(this.id, value);
		}
	}
	property float flGravedad{
		public get(){
			return gPGravedad.Get(this.id);
		}
		public set(float value){
			gPGravedad.Set(this.id, value);
		}
	}
	property float flDamage{
		public get(){
			return gPDamage.Get(this.id);
		}
		public set(float value){
			gPDamage.Set(this.id, value);
		}
	}
}

methodmap JPlayer < Player{
	public JPlayer(int value){
		return view_as<JPlayer>(value);
	}
    property bool bSimon{
    	public get(){
    		return gSimon[this.id];
    	}
    	public set(bool value){
    		gSimon[this.id] = value;
    	}
    }
    property bool bMartillo {
    	public get(){
    		return bMartillo[this.id];
    	}
    	public set(bool value){
    		bMartillo[this.id] = value;
    	}
    }
    property bool bLockpick{
    	public get(){
    		return bLockpick[this.id];
    	}
    	public set (bool value){
    		bLockpick[this.id] = value;
    	}
    }
	property int iCigarros{
		public get() { 
			return gCigarros[this.id]; 
		}
		public set(int value) { 
			gCigarros[this.id] = value;
		}
	}
	property int iAdversario{
		public get() { 
			return gAdversario[this.id]; 
		}
		public set(int value) { 
			gAdversario[this.id] = value;
		}
	}
	property int iPjSelected{
		public get() { 
			return gPjSelected[this.id]; 
		}
		public set(int value) { 
			gPjSelected[this.id] = value;
		}
	}
	property int iVipLevel{
		public get() { 
			return gVipLevel[this.id]; 
		}
		public set(int value) { 
			gVipLevel[this.id] = value;
		}
	}
	property int iTipoPresoSelected{
		public get(){
			return gTipoPresoSelected[this.id];
		}
		public set(int value){
			gTipoPresoSelected[this.id] = value;
		}
	}
	property int iNextPreso{
		public get(){
			return gNextTipoPreso[this.id];
		}
		public set(int value){
			gNextTipoPreso[this.id] = value;
		}
	}
	public void moveToTeam(int team){
		if (!IsPlayerExist(this.id))
			return;
		
		if (IsPlayerAlive(this.id))
			ForcePlayerSuicide(this.id);
		
		this.iTeamNum = team;
		
		char sName[48];
		GetClientName(this.id, sName, sizeof(sName));
		
		char sTeam[32];
		switch (team){
			case CS_TEAM_SPECTATOR: sTeam = " espectador";
			case CS_TEAM_T: sTeam = "l equipo \x09Terrorista\x01";
			case CS_TEAM_CT: sTeam = "l equipo \x09AntiTerrorista\x01";
		}
		
		PrintToChatAll("%s \x09%s\x01 movido a%s.", SERVERSTRING, sName, sTeam);
	}
	public void setAttribs(){
		JPreso x = JPreso(this.iTipoPresoSelected);
		this.iHealth = x.iHealth;
		this.iArmor = x.iArmor;
		this.flSpeed = x.flVelocidad;
		this.flGravity = x.flGravedad;
	}
}


stock int CreateJPreso(const char[] name, int health, int armor, float cigarros, float vel, float grav, float dmg){
	JPreso preso = JPreso(gPNombre.Length);
	gPNombre.PushString(name);
	gPHealth.Push(health);
	gPArmor.Push(armor);
	gPCigarros.Push(cigarros);
	gPVelocidad.Push(vel);
	gPGravedad.Push(grav);
	gPDamage.Push(dmg);
	
	return preso.id;
}

stock int fnGetRandomPlaying(int nRandom){
	int nAlive;
	
	for (int i = 1; i <= MaxClients; i++){
		JPlayer player = JPlayer(i);
		
		if(!IsPlayerExist(player.id, false))
			continue;
		
		nAlive++;
		
		if (nAlive == nRandom){
			return i;
		}
	}
	return GetRandomInt(1, fnGetPlaying());
}