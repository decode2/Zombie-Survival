#define EXTRAITEMS_MODULE_VERSION "0.1"

// Madness sound
#define ZOMBIE_MADNESS_SOUND "*/MassiveInfection/zombie_madness1.mp3"

// Nightvision
#define NIGHTVISION_DISTANCE_HUMANS 	600.0
#define NIGHTVISION_DISTANCE_ZOMBIES 	800.0

enum ExtraItems{
	EXTRA_ITEM_ANTIDOTE = 0,
	EXTRA_ITEM_MADNESS,
	EXTRA_ITEM_INFAMMO,
	EXTRA_ITEM_NIGHTVISION,
	EXTRA_ITEM_ARMOR,
	EXTRA_ITEMS_MAX
};

//=====================================================
//				EXTRA ITEMS VARIABLES
//=====================================================

#define MAX_ANTIDOTES	1
#define MAX_TOTAL_ANTIDOTES_PER_ROUND 10
#define ANTIDOTE_COST 		240
#define ANTIDOTE_MIN_ZOMBIES_REQUIRED 	50/100

#define MADNESS_COST 		97
#define MAX_MADNESS 		6
#define MADNESS_COOLDOWN 	40.0
#define MADNESS_DURATION 	5.0

#define INFI_COST			170

#define NIGHTVISION_COST 	58

#define ARMOR_COST			72
#define ARMOR_QUANTITY 		100
#define ARMOR_MAX_QUANTITY 	800
#define ARMOR_MAX_BUYS_PER_ROUND 	10

#define EXTRA_ITEMS_COUNT 	5
//int gItemsCount[MAXPLAYERS+1][EXTRA_ITEMS_COUNT];

int gConsumedAntidotes;

// Arrays
ArrayList gPersistantAntidotesId;
ArrayList gPersistantAntidotesCount;

ArrayList ZExtraItems;

//=====================================================
//					ENUM STRUCT
//=====================================================

enum struct ZExtraItem{
	
	int id;
	int iCost;
	ExtraItems iItemId;
	char name[32];
}

void ExtraItems_OnPluginStart(){
	
	gPersistantAntidotesId = CreateArray(1);
	gPersistantAntidotesCount = CreateArray(1);
	
	ZExtraItems = new ArrayList(sizeof(ZExtraItem));
	
	gConsumedAntidotes = 0;
	
	// Register extra items
	LoadExtraItems();
}

void ExtraItems_OnPluginEnd(){
	
	gPersistantAntidotesId.Clear();
	delete gPersistantAntidotesId;
	
	gPersistantAntidotesCount.Clear();
	delete gPersistantAntidotesCount;
	
	ZExtraItems.Clear();
	delete ZExtraItems;
}

void LoadExtraItems(){
	CreateExtraItem("1", EXTRA_ITEM_ANTIDOTE, ANTIDOTE_COST);
	CreateExtraItem("2", EXTRA_ITEM_MADNESS, MADNESS_COST);
	CreateExtraItem("3", EXTRA_ITEM_INFAMMO, INFI_COST);
	CreateExtraItem("4", EXTRA_ITEM_NIGHTVISION, NIGHTVISION_COST);
	CreateExtraItem("5", EXTRA_ITEM_ARMOR, ARMOR_COST);
}

// Create extra item
int CreateExtraItem(char[] name, ExtraItems itemid, int cost){
	
	ZExtraItem item;
	item.id = ZExtraItems.Length;
	strcopy(item.name, sizeof(item.name), name);
	item.iItemId = itemid;
	item.iCost = cost;
	
	return ZExtraItems.PushArray(item);
}

// Gets the array number where the type is found
int GetItemIndexByItemid(ExtraItems itemid){
	
	ZExtraItem item;
	int index = -1;
	
	for (int i = 0; i < ZExtraItems.Length; i++){
		ZExtraItems.GetArray(i, item);
		
		if (item.iItemId == itemid){
			index = i;
			break;
		}
	}
	
	return index;
}

// Resets variables to default value for selected client
void ExtraItemsOnResetVariables(int client){
	
	gClientData[client].bInfiniteAmmo = false;
	gClientData[client].iAntidotes = MAX_ANTIDOTES;
	gClientData[client].iMadness = MAX_MADNESS;
	gClientData[client].bNightvision = false;
	gClientData[client].flMadnessTime = 0.0;
	gClientData[client].iRemainingPurchases = ARMOR_MAX_BUYS_PER_ROUND;
	
	for (int i = 0; i < EXTRA_ITEMS_COUNT; i++){
		gClientData[client].iItemsCount[i] = 0;
	}
}

// Called when the event in name occurs
void ExtraItemsOnRoundEnd(){
	
	for (int i = 1; i <= MaxClients; i++){
		ExtraItemsOnResetVariables(i);
	}
}

// Called when the event in name occurs
void ExtraItemsOnPostRoundStart(){
	
	ExtraItemsOnRoundEnd();
}

// Called when the event in name occurs
void ExtraItemsOnPreRoundStart(){
	
	ExtraItemsOnRoundEnd();
	
	// Delete persistances on new rounds
	gPersistantAntidotesId.Clear();
	gPersistantAntidotesCount.Clear();
}