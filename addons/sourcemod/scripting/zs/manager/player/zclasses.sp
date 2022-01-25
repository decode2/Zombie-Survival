
#if defined zclasses_included
	#endinput
#endif
#define zclasses_included

#define ZCLASSES_MODULE_VERSION "0.1"

//=====================================================
//				ZOMBIE CLASSES VARIABLES
//=====================================================
#define ZOMBIECLASSES 15
#define ZOMBIECLASSES_MODELS_MAXPATH 	256
#define ZOMBIECLASSES_ARMS_MAXPATH 		256

// ZM vars
int iRadioactiveZombie;
ArrayList ZClasses;

enum ZombieType{
	ZOMBIE,
	NEMESIS,
	ASSASSIN,
	FEV
}

enum struct ZClass{
	int id;
	int health;
	int level;
	int reset;
	float damage;
	float speed;
	float gravity;
	int alpha;
	bool hideKnife;
	char name[32];
	char model[256];
	char arms[256];
}

void ZClassesOnInit(){
	
	ZClasses = new ArrayList(sizeof(ZClass));
}

void ZClassesOnUpdate(Database db){
	
	ZClasses.Clear();
	PrintToServer("[ZOMBIE-CLASSES] START");
	db.Query(ZClassesCallback, "SELECT level, reset, health, damage, speed, gravity, alpha, hideKnife, nombre, model, arms FROM zombie_clases ORDER BY orden ASC;", 0, DBPrio_High);
}

public void ZClassesCallback(Database db, DBResultSet results, const char[] error, any data){

	if(!StrEqual(error, "")){
		PrintToServer("[ZOMBIE-CLASSES] %s", error);
		return;
	}
	
	
	PrintToServer("[ZOMBIE-CLASSES] ROW COUNT: %d", results.RowCount);

	// Delete data on the array
	ZClasses.Clear();

	ZClass class;
	for(int i = 0; i < results.RowCount; i++){
		if(results.FetchRow()){
			class.id = i;
			class.level = results.FetchInt(0);
			class.reset = results.FetchInt(1);
			class.health = results.FetchInt(2);
			class.damage = results.FetchFloat(3);
			class.speed = results.FetchFloat(4);
			class.gravity = results.FetchFloat(5);
			class.alpha = results.FetchInt(6);
			class.hideKnife = view_as<bool>(results.FetchInt(7));
			results.FetchString(8, class.name, sizeof(class.name));
			results.FetchString(9, class.model, sizeof(class.model));
			results.FetchString(10, class.arms, sizeof(class.arms));
			
			if (StrContains(class.name, "Radio", false) != -1)
				iRadioactiveZombie = class.id;
			
			ZClasses.PushArray(class);
		}
	}
}

void ZClassesOnPluginEnd(){
	
	ZClasses.Clear();
	delete ZClasses;
}

stock int CreateZClass(const char[] name, const char[] model, const char[] arms, int hp, float dmg, float speed, float gravity, int levelReq, int resetReq, int alpha, bool hideKnife){
	ZClass class;
	strcopy(class.name, sizeof(class.name), name);
	strcopy(class.model, sizeof(class.model), model);
	strcopy(class.arms, sizeof(class.arms), arms);
	class.health = hp;
	class.damage = dmg;
	class.speed = speed;
	class.gravity = gravity;
	class.level = levelReq;
	class.reset = resetReq;
	class.alpha = alpha;
	class.hideKnife = hideKnife;
	class.id = ZClasses.Length;
	
	return ZClasses.PushArray(class);
}

//void LoadZClasses(){
//	
//	char sModel[ZOMBIECLASSES][ZOMBIECLASSES_MODELS_MAXPATH];
//	char sArms[ZOMBIECLASSES][ZOMBIECLASSES_ARMS_MAXPATH];
//	
//	//FormatEx(sModel[0], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/kuristaja/zombies/gozombie/gozombie.mdl");
//	FormatEx(sModel[0], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/custom_player/ventoz/zombies/gozombie/gozombie_fix.mdl");
//	//FormatEx(sModel[1], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/kuristaja/zombies/police/police.mdl");
//	FormatEx(sModel[1], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/custom_player/ventoz/zombies/police/police_fix.mdl");
//	FormatEx(sModel[2], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/custom_player/kodua/zombie_heavy/heavy_origin.mdl");
//	
//	//FormatEx(sModel[3], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/nf/dead_effect_2/soldier.mdl");
//	FormatEx(sModel[3], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/custom_player/ventoz/zombies/soldado/soldado.mdl");
//	
//	FormatEx(sModel[4], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/custom_player/cso2_zombi/zombie.mdl");
//	FormatEx(sModel[5], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/custom_player/kodua/eliminator/eliminator.mdl");
//	FormatEx(sModel[6], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/custom_player/ventoz/zombies/skinny/skinny_fix.mdl");
//	FormatEx(sModel[7], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/custom_player/cso2_zombi/normalhost2.mdl");
//	FormatEx(sModel[8], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/custom_player/kodua/bloatv2/bloat.mdl");
//	FormatEx(sModel[9], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/custom_player/kodua/bo/nazi_frozen.mdl");
//	FormatEx(sModel[10], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/custom_player/kodua/invisible_bitch/stalker_fix.mdl");
//	FormatEx(sModel[11], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/custom_player/kodua/fleshpoundv2/fleshpound.mdl");
//	FormatEx(sModel[12], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/custom_player/kodua/scrake_albino/scrake.mdl");
//	FormatEx(sModel[13], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/custom_player/caleon1/mummy/mummy.mdl");
//	//FormatEx(sModel[14], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/mapeadores/morell/ghoul/ghoulfix.mdl");
//	FormatEx(sModel[14], ZOMBIECLASSES_MODELS_MAXPATH, "models/player/custom_player/ventoz/zombies/radiactivo/radiactivo.mdl");
//	
//	
//	FormatEx(sArms[0], ZOMBIECLASSES_ARMS_MAXPATH, "models/zombie/normal/hand/hand_zombie_normal_fix_v2.mdl");
//	FormatEx(sArms[1], ZOMBIECLASSES_ARMS_MAXPATH, "models/zombie/normal_f/hand/hand_zombie_normal_f.mdl");
//	FormatEx(sArms[2], ZOMBIECLASSES_ARMS_MAXPATH, "models/zombie/normalhost/hand/hand_zombie_normalhost.mdl");
//	FormatEx(sArms[3], ZOMBIECLASSES_ARMS_MAXPATH, "models/zombie/normalhost/hand/hand_zombie_normalhost.mdl");
//	FormatEx(sArms[4], ZOMBIECLASSES_ARMS_MAXPATH, "models/zombie/normal_f/hand/hand_zombie_normal_f.mdl");
//	FormatEx(sArms[5], ZOMBIECLASSES_ARMS_MAXPATH, "models/zombie/normal/hand/hand_zombie_normal_fix_v2.mdl");
//	FormatEx(sArms[6], ZOMBIECLASSES_ARMS_MAXPATH, "models/zombie/normalhost_female/hand/hand_zombie_normalhost_f.mdl");
//	FormatEx(sArms[7], ZOMBIECLASSES_ARMS_MAXPATH, "models/zombie/normalhost/hand/hand_zombie_normalhost.mdl");
//	FormatEx(sArms[8], ZOMBIECLASSES_ARMS_MAXPATH, "models/zombie/normal/hand/hand_zombie_normal_fix_v2.mdl");
//	FormatEx(sArms[9], ZOMBIECLASSES_ARMS_MAXPATH, "models/zombie/normal_f/hand/hand_zombie_normal_f.mdl");
//	FormatEx(sArms[10], ZOMBIECLASSES_ARMS_MAXPATH, "models/zombie/normal_f/hand/hand_zombie_normal_f.mdl");
//	FormatEx(sArms[11], ZOMBIECLASSES_ARMS_MAXPATH, "models/zombie/normal/hand/hand_zombie_normal_fix_v2.mdl");
//	FormatEx(sArms[12], ZOMBIECLASSES_ARMS_MAXPATH, "models/zombie/normalhost/hand/hand_zombie_normalhost.mdl");
//	FormatEx(sArms[13], ZOMBIECLASSES_ARMS_MAXPATH, "models/player/custom_player/zombie/normal_m_01/hand/eminem/hand_normal_m_01.mdl");
//	FormatEx(sArms[14], ZOMBIECLASSES_ARMS_MAXPATH, "models/zombie/normalhost/hand/hand_zombie_normalhost.mdl");
//	
//	
//	//============================================================================
//	//							ZOMBIE CLASSES
//	//============================================================================
//	//CreateZClass(name, 			model, 		 arms, 		int hp, 	dmg,	speed, gravity, level, reset, alpha, hideKnife)
//	CreateZClass("Infectado", 		sModel[0], 	sArms[0], 	130000, 	1.1, 	1.0, 	1.0, 	1, 		0, 		255, true);
//	CreateZClass("Ex oficial", 		sModel[1], 	sArms[1], 	133000, 	1.15, 	1.1, 	1.0, 	20, 	0, 		255, true);
//	CreateZClass("Heavy Origin",	sModel[2], 	sArms[2], 	138000, 	1.3, 	0.95, 	1.0, 	50, 	0, 		255, true);
//	CreateZClass("Soldado Caído", 	sModel[3], 	sArms[3], 	141000, 	1.3, 	1.23, 	0.91, 	60, 	0, 		255, true);
//	CreateZClass("Walker", 			sModel[4], 	sArms[4], 	145000, 	1.2, 	1.23, 	0.98, 	100, 	0, 		255, true);
//	CreateZClass("Simio Mutante", 	sModel[5], 	sArms[5], 	151000, 	1.25, 	1.24, 	0.93, 	130, 	0, 		255, false);
//	CreateZClass("Ágil", 			sModel[6], 	sArms[6], 	158000, 	1.25, 	1.27, 	0.87, 	170, 	0, 		255, true);
//	CreateZClass("Inferno",			sModel[7], 	sArms[7], 	166000, 	1.33, 	1.26, 	0.85, 	200, 	0, 		255, true);
//	CreateZClass("Mórbido",			sModel[8], 	sArms[8], 	166000, 	1.35, 	1.27, 	0.84, 	220, 	0, 		255, true);
//	CreateZClass("Tundra", 			sModel[9], 	sArms[9], 	170000, 	1.36, 	1.29, 	0.82, 	240, 	0, 		255, true);
//	CreateZClass("Transparente", 	sModel[10], sArms[10], 	248000, 	1.36, 	1.4, 	0.79, 	270, 	10, 	100, true);
//	CreateZClass("Triturador",		sModel[11], sArms[11], 	270000, 	1.38, 	1.42, 	0.78, 	300, 	20, 	255, true);
//	CreateZClass("Nightmare", 		sModel[12], sArms[12], 	310000, 	1.39, 	1.43, 	0.77, 	320, 	30, 	255, true);
//	CreateZClass("Momia",			sModel[13], sArms[13], 	360000, 	1.40,	1.44, 	0.76, 	340, 	40, 	255, true);
//	
//	
//	iRadioactiveZombie = CreateZClass("Radioactivo",	sModel[14], sArms[14],	400000,	1.41,	1.45,	0.75,	360,	50, 255, true);
//
//}