//
// Combos module
//


#define COMBOS_MODULE_VERSION 	"0.1"

// Combo defines
#define COMBO_DURATION 			5.5
#define COMBO_FORMULA_ADDITIVE 	253
#define COMBO_REWARD_BASE 		1.0

// Combo huds
#define COMBO_HUD_FINISH_HOLDTIME 	3.5
#define COMBO_HUD_FINISH_ALPHA 		1
#define COMBO_HUD_FINISH_EFFECT 	1
#define COMBO_HUD_FINISH_FXTIME 	1.2
#define COMBO_HUD_FINISH_FADEIN 	0.02
#define COMBO_HUD_FINISH_FADEOUT 	0.6

//#define COMBO_PARTY_REWARD_PU 	0.15

// Combos
float fEngineTime;
Handle hComboSynchronizer;
Handle hComboSynchronizer2;

//=====================================================
//				COMBOS VARIABLES
//=====================================================
ArrayList gComboName;
ArrayList gDifficulty; // Formula: player.iCombo >= RoundToCeil((player.iLevel+COMBO_FORMULA_ADDITIVE)*THISVALUE)
ArrayList gBonusExpGain;
ArrayList gRed;
ArrayList gGreen;
ArrayList gBlue;

enum Combos {
	COMBO_DEFAULT = 0,
	COMBO_NICE,
	COMBO_AMAZING,
	COMBO_GODLIKE,
	COMBO_BLOODY,
	COMBO_AGGRESSIVE,
	COMBO_RAMPAGE,
	COMBO_MASSIVE,
	COMBO_ULTRAMASSIVE,
	COMBO_FLAWLESS,
	
	COMBO_END
}

//
void CombosOnInit(){
	
	// Create hud synchronizers
	hComboSynchronizer = CreateHudSynchronizer();
	hComboSynchronizer2 = CreateHudSynchronizer();
	
	// Combo arrays
	gComboName = CreateArray(ByteCountToCells(32));
	gDifficulty = CreateArray(4);
	gBonusExpGain = CreateArray(4);
	gRed = CreateArray(4);
	gGreen = CreateArray(4);
	gBlue = CreateArray(4);
	
	// Register combos
	LoadCombos();
}

void CombosOnPluginEnd(){
	
	gComboName.Clear();
	gDifficulty.Clear();
	gBonusExpGain.Clear();
	gRed.Clear();
	gGreen.Clear();
	gBlue.Clear();
}

//=====================================================
//					METHOD
//=====================================================
methodmap ZCombo{
	public ZCombo(int value){
		return view_as<ZCombo>(value);
	}
	property int id{
		public get(){
			return view_as<int>(this);
		}
	}
	property float fDifficulty{
		public get(){
			return gDifficulty.Get(this.id);
		}
	}
	property float fBonusExpGain{
		public get(){
			return gBonusExpGain.Get(this.id);
		}
	}
	property int iRed{
		public get(){
			return gRed.Get(view_as<int>(this));
		}
	}
	property int iGreen{
		public get(){
			return gGreen.Get(view_as<int>(this));
		}
	}
	property int iBlue{
		public get(){
			return gBlue.Get(view_as<int>(this));
		}
	}
	public bool AdjustType(int client){
		
		bool updated = false;
		if (gClientData[client].iCombo >= RoundToNearest((COMBO_FORMULA_ADDITIVE+(gClientData[client].iLevel*COMBO_FORMULA_ADDITIVE*0.01))*(this.fDifficulty)) && gClientData[client].iComboType < view_as<int>(COMBO_END)-1){
			gClientData[client].iComboType++;
			updated = true;
		}
		return updated;
	}
}

//=====================================================
//					COMBOS
//=====================================================
stock int CreateCombo(const char[] name, float difficulty, float bonusExpGain, int red, int green, int blue){
	ZCombo combo = ZCombo(gComboName.Length);
	gComboName.PushString(name);
	gDifficulty.Push(difficulty);
	gBonusExpGain.Push(bonusExpGain);
	gRed.Push(red);
	gGreen.Push(green);
	gBlue.Push(blue);
	return combo.id;
}

// Combos
public void LoadCombos(){
	// CreateCombo(const char[] name,	float difficulty, float bonusExpGain,	int red, int green, int blue);
	CreateCombo("Common", 				0.0, 			1.0, 			232, 160, 128);
	CreateCombo("Nice!", 				0.45, 			1.10, 			102, 178, 255);
	CreateCombo("Amazing!",				1.0, 			1.15, 			232, 255, 168);
	
	// Intermediate
	CreateCombo("Godlike!",				1.2, 			1.20, 			255, 255, 168);
	CreateCombo("Bloody!",				1.6, 			1.25, 			255, 235, 128);
	CreateCombo("Aggressive!",			2.0, 			1.30, 			255, 187, 106);
	CreateCombo("Rampage!",				2.5, 			1.35, 			255, 95, 80);
	
	// Very high combos
	CreateCombo("MASSIVE!",				3.5, 			1.5, 			255, 255, 255);
	CreateCombo("ULTRA MASSIVE!",		5.5, 			1.75,			255, 255, 255);
	CreateCombo("FLAWLESS!!",			7.5, 			2.0, 			255, 255, 255);
}

// COMBOS' FORMULAS
stock int NextCombo(int iCombo, int iLevel, int iReset){
	/*
	int partial = RoundToNearest(1+(iReset*0.05));
	//int total = RoundToNearest(((iCombo*iCombo*0.0015)+500)*partial);
	int iRoundedCombo = RoundToNearest(iCombo*0.25);
	int total = RoundToNearest((((iRoundedCombo+500)*partial)/100.0)*iCombo);*/
	
	/*int partial = RoundToNearest(1+(iReset*0.05));
	int total = RoundToNearest((((iCombo+500)*partial)/100.0)*iCombo*iLevel/20);*/
	
	int total;
	total = RoundToFloor(  ( iCombo*58*( 1.0+(float(iLevel)/float(380) ) ) * ( 1+(iReset*0.0004) ) )  );
	//total = RoundToFloor(  ( iCombo*60*(1.0+(iLevel*0.005) ) ) * ( 1+(iReset*0.0004) ) );
	
	return total;
}

stock int NextComboLowReset(int iCombo, int iLevel, int iReset){
	/*
	int partial = RoundToNearest(1+(iReset*0.05));
	//int total = RoundToNearest(((iCombo*iCombo*0.0015)+500)*partial);
	int iRoundedCombo = RoundToNearest(iCombo*0.25);
	int total = RoundToNearest((((iRoundedCombo+500)*partial)/100.0)*iCombo);*/
	
	/*int partial = RoundToNearest(1+(iReset*0.05));
	int total = RoundToNearest((((iCombo+500)*partial)/100.0)*iCombo*iLevel/20);*/
	
	int total;
	total = RoundToFloor((iCombo*45*(1+iLevel/350))*(1+(iReset*0.0008)));
	
	return total;
}

stock int NextComboPt(int iCombo, int iLevel, int iReset){
	//int total = RoundToCeil(((iCombo*iCombo*0.00375)+1000)*(1+(iLevel*0.01)));
	
	int total;
	total = RoundToFloor((iCombo*40*(1+iLevel/200))*(1+(iReset*0.002)));
	
	return total;
}