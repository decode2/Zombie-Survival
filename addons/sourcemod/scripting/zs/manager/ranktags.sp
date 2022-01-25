
#if defined _ranktags_included
	#endinput
#endif
#define _ranktags_included

#define RANKTAGS_MODULE_VERSION "0.1"

enum struct RankTag{
	int id;
	char name[32];
	int reset;
}

ArrayList RankTags;

void RankTags_OnPluginStart(){
	RankTags = new ArrayList(sizeof(RankTag));
}
void RankTags_OnPluginEnd(){
	RankTags.Clear();
	delete RankTags;
}
void RankTags_OnMapStart(){
	RankTags.Clear();
	LoadRankTags();
}

// Register ranktags
void CreateRankTag(char[] name, int reset){
	
	int id = RankTags.Length;
	RankTag rank;
	
	rank.id = id;
	strcopy(rank.name, sizeof(rank.name), name);
	rank.reset = reset;
	
	RankTags.PushArray(rank);
	
}

void LoadRankTags(){
	
	//
	CreateRankTag("[NOVATO I]", 0);
	CreateRankTag("[NOVATO II]", 1);
	CreateRankTag("[NOVATO III]", 3);
	CreateRankTag("[NOVATO IV]", 5);
	
	//
	CreateRankTag("[APRENDIZ I]", 7);
	CreateRankTag("[APRENDIZ II]", 9);
	CreateRankTag("[APRENDIZ III]", 12);
	CreateRankTag("[APRENDIZ IV]", 15);
	
	//
	CreateRankTag("[EXPERTO I]", 20);
	CreateRankTag("[EXPERTO II]", 23);
	CreateRankTag("[EXPERTO III]", 26);
	CreateRankTag("[EXPERTO IV]", 30);
	
	//
	CreateRankTag("[CAZADOR I]", 35);
	CreateRankTag("[CAZADOR II]", 40);
	CreateRankTag("[CAZADOR III]", 45);
	CreateRankTag("[CAZADOR IV]", 50);
	
	//
	CreateRankTag("[DEMOLEDOR I]", 55);
	CreateRankTag("[DEMOLEDOR II]", 60);
	CreateRankTag("[DEMOLEDOR III]", 65);
	CreateRankTag("[DEMOLEDOR IV]", 70);
	
	//
	CreateRankTag("[PROTECTOR I]", 80);
	CreateRankTag("[PROTECTOR II]", 90);
	CreateRankTag("[PROTECTOR III]", 100);
	CreateRankTag("[PROTECTOR IV]", 110);
	
	//
	CreateRankTag("[LEGENDARIO I]", 120);
	CreateRankTag("[LEGENDARIO II]", 135);
	CreateRankTag("[LEGENDARIO III]", 150);
	CreateRankTag("[LEGENDARIO IV]", 165);
	
	//
	CreateRankTag("[MÍTICO I]", 180);
	CreateRankTag("[MÍTICO II]", 190);
	CreateRankTag("[MÍTICO III]", 200);
	CreateRankTag("[MÍTICO IV]", 210);
	
	//
	CreateRankTag("[CHALLENGER]", 230);
}

stock int RankTags_FindForReset(int reset){
	
	int value = 0;
	RankTag rank;
	
	for (int i; i < RankTags.Length; i++){
		
		RankTags.GetArray(i, rank);
		
		if (reset < rank.reset)
			break;
		
		value = i;
	}
	
	return value;
}