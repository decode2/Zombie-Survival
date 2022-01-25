#define HALIGNMENTS_MODULE_VERSION "0.1"

//=====================================================
//				HUMAN ALIGNMENTS VARIABLES
//=====================================================
ArrayList HAlignments;
int iMutantAlignment;

//=====================================================
//					ENUM STRUCT
//=====================================================
enum struct HAlignment{
	
	int id;
	float flDamageMul;
	float flHealthMul;
	int iArmorAdd;
	float flSpeedMul;
	float flGravityMul;
	
	char name[32];
	char desc[48];
}

//
void HAlignments_OnPluginStart(){
	
	// Human alignments	
	HAlignments = new ArrayList(sizeof(HAlignment));
	
	// Register human alignments
	LoadHAlignments();
}

void HAlignments_OnPluginEnd(){

	// Human alignments
	HAlignments.Clear();
	delete HAlignments;
}

//=====================================================
//					ALIGNMENTS CREATION
//=====================================================
stock int CreateHAlignment(const char[] name, const char[] description, float damageMul, float hpMul, int armorAdd, float speedMul, float gravityMul){

	HAlignment alignment;
	alignment.id = HAlignments.Length;
	strcopy(alignment.name, sizeof(alignment.name), name);
	strcopy(alignment.desc, sizeof(alignment.desc), description);
	alignment.flDamageMul = damageMul;
	alignment.flHealthMul = hpMul;
	alignment.iArmorAdd = armorAdd;
	alignment.flSpeedMul = speedMul;
	alignment.flGravityMul = gravityMul;
	
	return HAlignments.PushArray(alignment);
}

// Alignments
public void LoadHAlignments(){

	HAlignments.Clear();
	
	//============================================================================
	//							HUMAN ALIGNMENTS
	//============================================================================
	
	//CreateHAlignment(name, 		description, 									damageMul, hpMul, armorAdd, speedMul, gravityMul)
	CreateHAlignment("Ágil", 		"Saltos altos, rápido",							1.0, 		1.0,	0, 		1.20, 		0.8);
	CreateHAlignment("Resistente", 	"Mucha vida",									1.0, 		1.8,	0, 		1.0, 		1.0);
	CreateHAlignment("Inmune", 		"200 de chaleco gratis, daño aumentado", 		1.25, 		1.0,	200, 	1.0, 		1.0);
	CreateHAlignment("Berserker", 	"Daño elevado, vulnerable",						1.5, 		0.6,	0, 		1.0, 		1.0);
	iMutantAlignment = CreateHAlignment("Mutante",		"Fuerte, ágil, puede mutar",		1.65, 		1.0,	25, 		1.1, 		0.9);
}