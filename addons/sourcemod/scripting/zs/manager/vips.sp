#define VIPS_MODULE_VERSION "0.1"

#define SILVER_VIP_POINTSBONUS 2
#define GOLDEN_VIP_POINTSBONUS 3
#define PLATINUM_VIP_POINTSBONUS 4

// Array
ArrayList ZVips;

enum struct ZVip{
	
	int id;
	int cost;
	float expBoost;
	int pointsBonus;
	int days;
	bool available;
	
	char name[32];
	//char tag[32];
	
	void GetName(char[] buffer, int maxlength){
		strcopy(buffer, maxlength, this.name);
	}
	
	/*void GetTag(char[] buffer, int maxlength){
		strcopy(buffer, maxlength, this.tag);
	}*/
}

void Vips_OnPluginStart(){
	
	ZVips = new ArrayList(sizeof(ZVip));
	
	// Register vips
	LoadVips();
}

void Vips_OnPluginEnd(){
	
	ZVips.Clear();
	delete ZVips;
}

int CreateVip(char[] name, float multiplier, int cost, /*char[] tag,*/ int pointsBonus, int days, bool bAvailable = true){
	
	ZVip vip;
	vip.id = ZVips.Length;
	strcopy(vip.name, sizeof(vip.name), name);
	//strcopy(vip.tag, sizeof(vip.tag), tag);
	vip.expBoost = multiplier;
	vip.cost = cost;
	vip.pointsBonus = pointsBonus;
	vip.days = days;
	vip.available = bAvailable;
	
	return ZVips.PushArray(vip);
}

void LoadVips(){
	//Func(		"Name",		flExp,		price, "Tag", 				pointsBonus, availableToBuy);
	CreateVip("Silver VIP Diario", 		2.0, 	360, 	SILVER_VIP_POINTSBONUS, 1);
	CreateVip("Silver VIP Semanal", 	2.0, 	2500, 	SILVER_VIP_POINTSBONUS, 7);
	CreateVip("Silver VIP Mensual", 	2.0, 	10000, 	SILVER_VIP_POINTSBONUS, 30);
	CreateVip("Golden VIP Diario", 		3.0, 	540, 	GOLDEN_VIP_POINTSBONUS, 1);
	CreateVip("Golden VIP Semanal", 	3.0, 	3800, 	GOLDEN_VIP_POINTSBONUS, 7);
	CreateVip("Golden VIP Mensual", 	3.0, 	15000, 	GOLDEN_VIP_POINTSBONUS, 30);
	
	//CreateVip("PLATINUM VIP", 			4.0, 	30000, PLATINUM_VIP_POINTSBONUS, false); // default PRICE = 30000
}

int getTotalVips(){
	return ZVips.Length-1;
}