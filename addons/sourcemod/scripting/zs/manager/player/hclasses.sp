
#if defined hclasses_included
	#endinput
#endif
#define hclasses_included

#define HCLASSES_MODULE_VERSION "0.1"

//=====================================================
//				HUMAN CLASSES VARIABLES
//=====================================================
#define HUMANCLASSES 20
#define HUMANCLASSES_MODELS_MAXPATH 	256
#define HUMANCLASSES_ARMS_MAXPATH 		256

enum HumanType{
	HUMAN,
	SURVIVOR,
	GUNSLINGER,
	SNIPER,
	MEOW
}

//void LoadHClasses(){
//	
//	char sModel[HUMANCLASSES][HUMANCLASSES_MODELS_MAXPATH];
//	char sArms[HUMANCLASSES][HUMANCLASSES_ARMS_MAXPATH];
//	
//	FormatEx(sModel[0], HUMANCLASSES_MODELS_MAXPATH, "models/player/custom_player/kuristaja/l4d2/ellis/ellisv2.mdl");
//	FormatEx(sModel[1], HUMANCLASSES_MODELS_MAXPATH, "models/player/custom_player/kuristaja/cso2/lincoln/lincoln.mdl");
//	FormatEx(sModel[2], HUMANCLASSES_MODELS_MAXPATH, "models/player/custom_player/kuristaja/re6/chris/chrisv4.mdl");
//	FormatEx(sModel[3], HUMANCLASSES_MODELS_MAXPATH, "models/player/custom_player/kuristaja/cso2/gign/gign.mdl");
//	FormatEx(sModel[4], HUMANCLASSES_MODELS_MAXPATH, "models/player/custom_player/kuristaja/cso2/emma/emma.mdl");
//	FormatEx(sModel[5], HUMANCLASSES_MODELS_MAXPATH, "models/player/custom_player/kuristaja/hunk/hunk.mdl");
//	FormatEx(sModel[6], HUMANCLASSES_MODELS_MAXPATH, "models/player/custom_player/kuristaja/cso2/mila/mila.mdl");
//	FormatEx(sModel[7], HUMANCLASSES_MODELS_MAXPATH, "models/player/custom_player/kuristaja/cso2/carrie/carrie.mdl");
//	FormatEx(sModel[8], HUMANCLASSES_MODELS_MAXPATH, "models/player/custom_player/kuristaja/cso2/karachenko/karachenko.mdl");
//	FormatEx(sModel[9], HUMANCLASSES_MODELS_MAXPATH, "models/player/custom_player/kuristaja/cso2/707/707.mdl");
//	FormatEx(sModel[10], HUMANCLASSES_MODELS_MAXPATH, "models/player/custom_player/kuristaja/cso2/lisa/lisa.mdl");
//	FormatEx(sModel[11], HUMANCLASSES_MODELS_MAXPATH, "models/player/custom_player/hekut/talizorah/talizorah.mdl");
//	FormatEx(sModel[12], HUMANCLASSES_MODELS_MAXPATH, "models/player/custom_player/kuristaja/nanosuit/nanosuitv3.mdl");
//	FormatEx(sModel[13], HUMANCLASSES_MODELS_MAXPATH, "models/player/custom_player/kuristaja/billy/billy_normal.mdl");
//	FormatEx(sModel[14], HUMANCLASSES_MODELS_MAXPATH, "models/player/custom_player/kuristaja/myers/myers.mdl");
//	FormatEx(sModel[15], HUMANCLASSES_MODELS_MAXPATH, "models/player/custom_player/kuristaja/krueger/krueger.mdl");
//	FormatEx(sModel[16], HUMANCLASSES_MODELS_MAXPATH, "models/player/custom_player/kuristaja/leatherface/leatherface.mdl");
//	FormatEx(sModel[17], HUMANCLASSES_MODELS_MAXPATH, "models/player/custom_player/kuristaja/t-600/t-600.mdl");
//	
//	
//	FormatEx(sArms[0], HUMANCLASSES_ARMS_MAXPATH, "models/player/custom_player/kuristaja/l4d2/ellis/ellis_arms.mdl");
//	FormatEx(sArms[1], HUMANCLASSES_ARMS_MAXPATH, "models/player/custom_player/kuristaja/cso2/lincoln/lincoln_arms.mdl");
//	FormatEx(sArms[2], HUMANCLASSES_ARMS_MAXPATH, "models/player/custom_player/kuristaja/re6/chris/chris_arms.mdl");
//	FormatEx(sArms[3], HUMANCLASSES_ARMS_MAXPATH, "models/player/custom_player/kuristaja/cso2/gign/gign_arms.mdl");
//	FormatEx(sArms[4], HUMANCLASSES_ARMS_MAXPATH, "models/player/custom_player/kuristaja/cso2/emma/emma_arms.mdl");
//	FormatEx(sArms[5], HUMANCLASSES_ARMS_MAXPATH, "models/player/custom_player/kuristaja/hunk/hunk_arms.mdl");
//	FormatEx(sArms[6], HUMANCLASSES_ARMS_MAXPATH, "models/player/custom_player/kuristaja/cso2/mila/mila_arms.mdl");
//	FormatEx(sArms[7], HUMANCLASSES_ARMS_MAXPATH, "models/player/custom_player/kuristaja/cso2/carrie/carrie_arms.mdl");
//	FormatEx(sArms[8], HUMANCLASSES_ARMS_MAXPATH, "models/player/custom_player/kuristaja/cso2/karachenko/karachenko_arms.mdl");
//	FormatEx(sArms[9], HUMANCLASSES_ARMS_MAXPATH, "models/player/custom_player/kuristaja/cso2/707/707_arms.mdl");
//	FormatEx(sArms[10], HUMANCLASSES_ARMS_MAXPATH, "models/player/custom_player/kuristaja/cso2/lisa/lisa_arms.mdl");
//	FormatEx(sArms[11], HUMANCLASSES_ARMS_MAXPATH, "models/player/custom_player/hekut/talizorah/talizorah_arms.mdl");
//	FormatEx(sArms[12], HUMANCLASSES_ARMS_MAXPATH, "models/player/custom_player/kuristaja/nanosuit/nanosuit_arms.mdl");
//	FormatEx(sArms[13], HUMANCLASSES_ARMS_MAXPATH, "models/player/custom_player/kuristaja/billy/billy_arms.mdl");
//	FormatEx(sArms[14], HUMANCLASSES_ARMS_MAXPATH, "models/player/custom_player/kuristaja/myers/myers_arms.mdl");
//	FormatEx(sArms[15], HUMANCLASSES_ARMS_MAXPATH, "models/player/custom_player/kuristaja/krueger/krueger_arms2.mdl");
//	FormatEx(sArms[16], HUMANCLASSES_ARMS_MAXPATH, "models/player/custom_player/kuristaja/leatherface/leatherface_arms.mdl");
//	FormatEx(sArms[17], HUMANCLASSES_ARMS_MAXPATH, "models/player/custom_player/kuristaja/t-600/t-600_arms.mdl");
//	
//	//============================================================================
//	//							HUMAN CLASSES
//	//============================================================================
//	//CreateHClass(name, 				 model, 	arms, 		hp, armor, 	speed, gravity,		level, reset)
//	
//	CreateHClass("Civil", 				sModel[0], 	sArms[0], 	100, 0, 	1.0, 	1.0, 		1, 		0);
//	CreateHClass("Guardia", 			sModel[1], 	sArms[1], 	110, 0, 	1.0, 	1.0, 		15, 	0);
//	CreateHClass("Brigada", 			sModel[2], 	sArms[2], 	120, 0, 	1.0, 	1.0, 		30, 	0);
//	CreateHClass("Oficial", 			sModel[3], 	sArms[3], 	130, 0, 	1.0, 	1.0, 		60, 	0);
//	CreateHClass("Teniente", 			sModel[4], 	sArms[4], 	135, 0, 	1.0, 	1.0, 		90, 	0);
//	CreateHClass("Soldado", 			sModel[5], 	sArms[5], 	140, 0, 	1.0, 	1.0, 		110, 	0);
//	CreateHClass("Sargento", 			sModel[6], 	sArms[6], 	145, 0, 	1.0, 	1.0, 		130, 	0);
//	CreateHClass("Investigadora", 		sModel[7], 	sArms[7], 	150, 0, 	1.0, 	1.0, 		150, 	0);
//	CreateHClass("Ricky", 				sModel[8], 	sArms[8], 	155, 0, 	1.0, 	1.0, 		180, 	0);
//	CreateHClass("Capitán", 			sModel[9], 	sArms[9], 	160, 0, 	1.1, 	0.99, 		210, 	0);
//	CreateHClass("Fuerzas Especiales", 	sModel[10], sArms[10], 	165, 0, 	1.2, 	0.95, 		240, 	0);
//	CreateHClass("Guerrera Khaz'El", 	sModel[11], sArms[11], 	170, 0, 	1.3, 	0.92, 		260, 	0);
//	CreateHClass("Super Soldado", 		sModel[12], sArms[12], 	175, 0, 	1.32, 	0.90, 		280, 	10);
//	CreateHClass("Jigsaw", 				sModel[13], sArms[13], 	180, 0, 	1.35, 	0.89, 		330, 	20);
//	CreateHClass("Michael Myers", 		sModel[14], sArms[14], 	190, 0, 	1.38, 	0.88, 		350, 	30);
//	CreateHClass("Freddy Krueger", 		sModel[15], sArms[15], 	200, 0, 	1.4, 	0.86, 		360, 	40);
//	CreateHClass("Texas' Leatherface", 	sModel[16], sArms[16], 	220, 0, 	1.44, 	0.85, 		370, 	50);
//	// Halloween
//	CreateHClass("T-600", 				sModel[17], sArms[17], 	230, 0, 	1.50, 	0.80, 		380, 	70);
//}

enum HClass_Tier{
	HCLASS_LOW_LEVEL,
	HCLASS_MID_LEVEL,
	HCLASS_HIGH_LEVEL,
	HCLASS_END
}

enum struct HClass{
	int id;
	HClass_Tier tier;
	int level;
	int reset;
	int health;
	int armor;
	float speed;
	float gravity;
	char name[32];
	char model[255];
	char arms[255];
}

ArrayList HClasses;

void HClassesOnInit(){
	
	HClasses = new ArrayList(sizeof(HClass));
}

void HClassesOnUpdate(Database db){
	
	HClasses.Clear();
	
	PrintToServer("[HUMAN-CLASSES] START");
	db.Query(HClassesCallback, "SELECT level, reset, health, armor, speed, gravity, nombre, model, arms, tier FROM human_clases ORDER BY orden ASC;", 0, DBPrio_High);
}

public void HClassesCallback(Database db, DBResultSet results, const char[] error, any data){

	if(!StrEqual(error, "")){
		LogError("[HUMAN-CLASSES] %s", error);
		return;
	}
	
	PrintToServer("[HUMAN-CLASSES] ROW COUNT: %d", results.RowCount);
	
	// Delete previous data on the array
	HClasses.Clear();

	HClass class;
	for(int i = 0; i < results.RowCount; i++){
		if(results.FetchRow()){
			class.id = i;
			class.level = results.FetchInt(0);
			class.reset = results.FetchInt(1);
			class.health = results.FetchInt(2);
			class.armor = results.FetchInt(3);
			class.speed = results.FetchFloat(4);
			class.gravity = results.FetchFloat(5);
			results.FetchString(6, class.name, sizeof(class.name));
			results.FetchString(7, class.model, sizeof(class.model));
			results.FetchString(8, class.arms, sizeof(class.arms));
			class.tier = view_as<HClass_Tier>(results.FetchInt(9));
			
			HClasses.PushArray(class);
		}
	}
}

void HClassesOnPluginEnd(){
	HClasses.Clear();
	delete HClasses;
}

/*
stock int CreateHClass(const char[] name, const char[] model, const char[] arms, int hp, int armor, float speed, float gravity, int levelReq, int resetReq){
	int id = HClasses.Length;
	HClass class;
	class.id = id;
	class.level = levelReq;
	class.reset = resetReq;
	class.health = hp;
	class.armor = armor;
	class.speed = speed;
	class.gravity = gravity;
	strcopy(class.name, sizeof(class.name), name);
	strcopy(class.model, sizeof(class.model), model);
	strcopy(class.arms, sizeof(class.arms), arms);
	
	HClasses.PushArray(class);
	
	return class.id;
}*/

/*
stock int HClasses_FindForPlayer(int level, int reset){
	
	int value = 0;
	HClass class;
	
	for (int i; i < HClasses.Length; i++){
		
		HClasses.GetArray(i, rank);
		
		if (level < class.level)
			continue;
		
		if (reset < class.reset)
			break;
		
		value = i;
	}
	
	return value;
}*/