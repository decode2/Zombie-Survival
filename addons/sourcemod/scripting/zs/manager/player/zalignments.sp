
#if defined zalingments_included
	#endinput
#endif
#define zalingments_included

#define ZALIGNMENTS_MODULE_VERSION "0.1"

//=====================================================
//				ZOMBIE ALIGNMENTS VARIABLES
//=====================================================
ArrayList ZAlignments;
int iRadAlignment;

//=====================================================
//					ENUM STRUCT
//=====================================================
enum struct ZAlignment{
	
	int id;
	float flDamageMul;
	float flHealthMul;
	float flSpeedMul;
	float flGravityMul;
	int iAlpha;
	
	char name[32];
	char desc[48];
}

//
void ZAlignments_OnPluginStart(){
	
	// Zombie alignments	
	ZAlignments = new ArrayList(sizeof(ZAlignment));
	
	// Register zombie alignments
	LoadZAlignments();
}

void ZAlignments_OnPluginEnd(){
	
	// Zombie alignments
	ZAlignments.Clear();
	delete ZAlignments;
}

//=====================================================
//					ALIGNMENTS CREATION
//=====================================================
stock int CreateZAlignment(const char[] name, const char[] description, float damageMul, float hpMul, float speedMul, float gravityMul, int alpha = 255){
	
	ZAlignment alignment;
	alignment.id = ZAlignments.Length;
	strcopy(alignment.name, sizeof(alignment.name), name);
	strcopy(alignment.desc, sizeof(alignment.desc), description);
	alignment.flDamageMul = damageMul;
	alignment.flHealthMul = hpMul;
	alignment.flSpeedMul = speedMul;
	alignment.flGravityMul = gravityMul;
	alignment.iAlpha = alpha;
	
	return ZAlignments.PushArray(alignment);
}

// Load alignments
public void LoadZAlignments(){

	ZAlignments.Clear();
	
	//============================================================================
	//							ZOMBIE ALIGNMENTS
	//============================================================================
	
	//CreateZAlignment( name, 		description, 								damageMul, hpMul, speedMul, gravityMul, alpha)

	CreateZAlignment("Raptor", 		"Muy ágil, débil",								1.0,	0.92, 	1.32, 	0.8, 	255);
	CreateZAlignment("Fuerte", 		"Daño muy elevado, levemente lento",			1.5,	1.0,  	0.95, 	1.0, 	255);
	CreateZAlignment("Coloso", 		"Muy resistente",								1.0,	1.3,  	1.0, 	0.9, 	255);
	CreateZAlignment("Titán", 		"Daño elevado, vida elevada",					1.3,	1.1, 	1.0, 	1.0, 	255);
	CreateZAlignment("Transparente", "Ágil, poco visible",							1.0,	1.0,	1.15,	0.9, 	140);
	iRadAlignment = CreateZAlignment("Radioactivo",	"Berserker, muy visible",		1.2,	1.15,	1.1,	0.9,	255);
}