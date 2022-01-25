#if defined tags_included
	#endinput
#endif
#define tags_included

#define TAGS_MODULE_VERSION "0.1"

#define TAGS_MINLEN 	3
#define TAGS_MAXLEN 	13
#define TAGS_PRICE_FOR_CREATING_TAG 500 // In PIU-Points

#define TAGS_DISABLE_SPACES

ArrayList tags;

// On init
void TagsOnInit(){
	
	tags = CreateArray(5);
}

// On plugin end
void TagsOnPluginEnd(){
	
	tags.Clear();
	delete tags;
}

// On update
void TagsOnUpdate(Database db){
	
	tags.Clear();
	db.Query(LoadTagsCallback, "SELECT * FROM Tags", 0, DBPrio_High);
}

// Register tags
void CreateTag(char[] name){
	tags.PushString(name);
}

public void LoadTagsCallback(Database db, DBResultSet results, const char[] error, any data){
	
	if(!StrEqual(error, "")){
		LogError("%s", error);
	}
	char name[32];
	while(results.FetchRow()){
		SQL_FetchString(results, 1,  name, sizeof(name));
		CreateTag(name);
	}
}

stock bool Tags_isEntryValid(const char[] input, const char[] sError){
	
	if (!(TAGS_MINLEN < strlen(input) < TAGS_MAXLEN)){
		return false;
	}
	
	if (input[0] != "[" || input[strlen(input)-1] != "]"){
		return false;
	}
	
	StripQuotes(input);
	TrimString(input);
	
	#if defined TAGS_DISABLE_SPACES
	if (StrContains(input, " ") != -1){
		return false;
	}
	#endif
	
	if (stringHasSymbols(input)){
		return false;
	}
	
	if (tags.FindString(input)){
		return false;
	}
	
	return true;
}
stock bool stringHasSymbols(const char[] input){
	
	int len = strlen(input)
	bool hasSymbols = false;
	for (int i; i < len; i++){
		if (!IsCharAlpha(input[i]) && !IsCharNumeric(input[i]) && input[i] != "-" && input[i] != "[" && input[i] != "]"){
			hasSymbols = true;
			break;
		}
	}
	
	return hasSymbols;
}
stock void stringToUpper(const char[] input){
	
	int len = strlen(input);
	
	for (int i; i < len; i++){
		if (IsCharAlpha(input[i])){
			CharToUpper(input[i]);
		}
	}
}