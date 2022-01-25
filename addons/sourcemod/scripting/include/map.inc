//
// Map enum struct
//

#if defined _map_class_included
	#endinput
#endif
#define _map_class_included

enum eWeaponsBitFields{
	
	WEAPON_G3SG1 = (1<<0),
	WEAPON_SCAR20 = (1<<1),
	WEAPON_AWP = (1<<2)
}

int WeaponsBitFields[3] = {
	
	WEAPON_G3SG1,
	WEAPON_SCAR20,
	WEAPON_AWP
}

char WeaponsEntName[][] = {
	
	"g3sg1",
	"scar20",
	"awp"
};

char WeaponsName[][] = {
	
	"G3SG1",
	"SCAR20",
	"AWP"
}

/*
enum struct eWeapon{
	
	char entName[32];
	char name[16];
	int bitfield;
}

eWeapon weaponsList[][] = {
	
	{ "weapon_g3sg1", "G3SG1",  WEAPON_G3SG1 },
	{ "weapon_scar20", "SCAR20",  WEAPON_SCAR20 },
	{ "weapon_awp", "AWP",  WEAPON_AWP }
}*/

// Enum struct, we will use it as a guide
enum struct MapData{
	
	int id;
	char name[64];
	int blockedWeapons;
}

ArrayList maps;
//MapData map;

// When plugin starts
void MapsOnInit(){
	
	maps = new ArrayList(sizeof(MapData));
}

char sMapName[64];
// When map starts
void MapsOnMapStart(){
	
	// Cache current map
	GetCurrentMap(sMapName, sizeof(sMapName));
	
	// Clear array
	maps.Clear();
	
	// Load map configs
	LoadMapsConfigs();
}

// Fill enum struct array with info
int CreateMapConfigs(char[] name, int blockedWeapons){
	
	int id = maps.Length;
	MapData map;
	
	map.id = id;
	strcopy(map.name, sizeof(map.name), name);
	map.blockedWeapons |= blockedWeapons;
	
	return maps.PushArray(map);
}

// Load predefined maps blocks
void LoadMapsConfigs(){
	
	CreateMapConfigs("$2000$_csgo", WEAPON_G3SG1|WEAPON_SCAR20|WEAPON_AWP);
	CreateMapConfigs("fy_pool_day_classic", WEAPON_G3SG1|WEAPON_SCAR20|WEAPON_AWP);
	CreateMapConfigs("fy_iceworld2k_t0", WEAPON_G3SG1|WEAPON_SCAR20|WEAPON_AWP)
	CreateMapConfigs("aim_redline", WEAPON_AWP);
	//CreateMapConfigs("de_dust2", WEAPON_AWP);
}

// When plugin ends
void MapsOnPluginEnd(){
	
	delete maps;
}