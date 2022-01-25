//
// Hats module
//


#define HATS_MODULE_VERSION "0.2"

enum struct Hat{
	int id;
	int idDb;
	char name[32];
	char model[256];
	int reset;
	bool legacy;
}
ArrayList Hats;

void HatsOnInit(){
	Hats = new ArrayList(sizeof(Hat));
}

void HatsOnUpdate(Database db){
	
	Hats.Clear();
	
	//db.Query(LoadHatsCallback,"SELECT idHat, h.name, modelPath, reset, legacy FROM Hats h ORDER BY h.order");
	db.Query(LoadHatsCallback, "SELECT idHat, h.name, modelPath, reset, legacy FROM Hats h ORDER BY h.legacy ASC, h.reset ASC", 0, DBPrio_High);
}

void HatsOnPluginEnd(){
	Hats.Clear();
	delete Hats;
}

stock void CreateHat(int idDb, char[] name, char[] model, int reset, bool legacy){
	int id = Hats.Length;
	Hat hat;
	hat.id = id;
	//hat.idDb = idDb;
	hat.reset = reset;
	hat.legacy = legacy;
	strcopy(hat.name, sizeof(hat.name), name);
	strcopy(hat.model, sizeof(hat.model), model);
	
	Hats.PushArray(hat);
}

public void LoadHatsCallback(Database db, DBResultSet results, const char[] error, any data){
	
	int id;
	char name[32];
	char modelPath[256];
	int reset;
	bool legacy;
	
	while(results.FetchRow()){
		id = results.FetchInt(0);
		results.FetchString(1, name, sizeof(name));
		results.FetchString(2, modelPath, sizeof(modelPath));
		reset = results.FetchInt(3);
		legacy = view_as<bool>(results.FetchInt(4));
		
		CreateHat(id, name, modelPath, reset, legacy);
	}
}

stock void FindHatByName(char[] name, Hat data){
	
	Hat hat;
	
	for(int i = 0; i < Hats.Length; i++){
		Hats.GetArray(i, hat);
		if(StrEqual(hat.name, name)){
			data = hat;
			break;
		}
	}
}

stock int Hats_FindForReset(int reset){
		
	int value = -1;
	Hat hat;
	
	for (int i; i < Hats.Length; i++){
		
		Hats.GetArray(i, hat);
		
		if (reset < hat.reset)
			break;
		
		if (hat.legacy)
			continue;
		
		value = i;
	}
	
	return value;
}