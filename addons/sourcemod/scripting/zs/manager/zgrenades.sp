
#if defined zgrenades_included
	#endinput
#endif
#define zgrenades_included

#define ZGRENADES_MODULE_VERSION "0.1"

// Grenades defines
#define FLASH 0
#define SMOKE 1

float NULL_VELOCITY[3] =	{ 0.0, 0.0, 0.0 };

#define SOUND_FREEZE	"*/MassiveInfection/impalehit.mp3"
#define SOUND_FREEZE_EXPLODE	"ui/freeze_cam.wav"

#define FragColor 	{255, 75, 75, 255}
#define FlashColor 	{255, 255, 255, 255}
#define InfectColor {0, 255, 0, 255}
#define SmokeColor 	{75, 255, 75, 255}
#define FreezeColor	{75, 75, 255, 255}
#define BurnColor	{255, 75, 45, 255}
#define BlackHoleColor {45, 80, 200, 200}

// Freeze grenade
#define	FREEZE_DURATION 4.0
#define FREEZE_DISTANCE 250.0

// Fire grenade
#define	BURN_DURATION 	8.0
#define	BURN_DISTANCE 	250.0
#define BURN_DAMAGE_PER_HIT 	0.6 // Percentage of total life

// Flare V2
#define GRENADE_FLARE_RADIUS         250.0				// Flare lightning size (radius)
#define GRENADE_FLARE_DISTANCE       450.0				// Flare lightning size (distance)
#define GRENADE_FLARE_DURATION       50.0				// Flare lightning duration in seconds

// AURA SHIELD
#define AURA_CLASSNAME 		"AuraShield"
#define AURA_WORLDMODEL 	"models/weapons/eminem/aura_shield/aura_shield2.mdl"
#define AURA_VMODEL 		"models/weapons/eminem/shield_grenade/v_shield_grenade.mdl"
#define AURA_WMODEL 		"models/weapons/eminem/shield_grenade/w_shield_grenade.mdl"
#define AURA_DROPPED_GRENADE "models/weapons/eminem/shield_grenade/w_shield_grenade_dropped.mdl"
#define AURA_DURATION 		10.0

// BLACK HOLE
#define BLACKHOLE_FORCE_PULL 	500.0
#define BLACKHOLE_MIN_DISTANCE 	200.0
#define BLACKHOLE_BOUNCE_VELOCITY 	300.0
#define BLACKHOLE_INDICATOR 	1 // Indicate minimum distance to push player towards black hole
#define BLACKHOLE_DURATION 	10.0
#define BLACKHOLE_EFFECT_NAME 	"blackhole"
#define BLACKHOLE_VOLUME 	1.0
#define BLACKHOLE_VMODEL 	"models/weapons/futuristicgrenades/v_eq_decoy.mdl"
#define BLACKHOLE_WMODEL 	"models/weapons/futuristicgrenades/w_eq_decoy.mdl"

// Infect grenade models
#define INFECT_GRENADE_VMODEL "models/weapons/csstocsgo/v_eq_adn.mdl"
#define INFECT_GRENADE_WMODEL "models/weapons/csstocsgo/w_eq_adn.mdl"
#define INFECT_GRENADE_DROPPED_MODEL "models/weapons/csstocsgo/w_eq_adn_dropped.mdl"


//=====================================================
//				GRENADES PACKS VARIABLES
//=====================================================

#define GRENADE_SLOTS 4
#define GRENADE1 0
#define GRENADE2 1
#define GRENADE3 2
#define GRENADE4 3

enum GrenadeType{
	NULL_GRENADE = -1,
	FIRE_GRENADE,
	FREEZE_GRENADE,
	LIGHT_GRENADE,
	MOLOTOV_GRENADE,
	AURA_GRENADE,
	VOID_GRENADE,
	END_GRENADES
}

int BeamSprite;

// AuraShields cache
ArrayList AuraShields;

// BlackHoles cache
ArrayList BlackHoles;

ArrayList gGrenadePackLevel;
ArrayList gGrenadePackReset;

ArrayList grenadeType[GRENADE_SLOTS];
ArrayList grenadeCount[GRENADE_SLOTS];

// Game functions
void ZGrenades_OnPluginStart(){
	
	// Aura shield array
	AuraShields = CreateArray(2);
	BlackHoles = CreateArray(2);
	
	// Grenades arrays
	gGrenadePackLevel = CreateArray(5);
	gGrenadePackReset = CreateArray(5);
	
	// Grenade packs arrays
	for (int i; i < GRENADE_SLOTS; i++){
		grenadeType[i] = CreateArray(5);
		grenadeCount[i] = CreateArray(5);
	}
	
	// Avoid exploding decoys
	HookEvent("decoy_started", Event_DecoyStarted, EventHookMode_Pre);
	
	// Hook entity events
	HookEvent("smokegrenade_detonate", Event_EntitySmoke, EventHookMode_Post);
	
	// Register grenade packs
	LoadGrenadePacks();
}

void ZGrenades_OnMapStart(){
	
	//PARTICLES
	AddFileToDownloadsTable("particles/piugrenades/piugrenades.pcf");
	PrecacheGeneric("particles/piugrenades/piugrenades.pcf", true);
	PrecacheParticleEffect("piugrenades");
}

void ZGrenades_OnPluginEnd(){
	
	gGrenadePackLevel.Clear();
	gGrenadePackReset.Clear();
	
	for(int i; i < GRENADE_SLOTS; i++){
		grenadeType[i].Clear();
		grenadeCount[i].Clear();
	}
	
	// Reset aura shields cache
	AuraShields.Clear();
	BlackHoles.Clear();
}

public void ZGrenades_OnEntityCreated(int entity, const char[] classname){
	if (StrContains(classname, "_projectile") != -1) SDKHook(entity, SDKHook_SpawnPost, GrenadeSpawnPost);
	else if (!strcmp(classname, "env_particlesmokegrenade")){
		AcceptEntityInput(entity, "Kill");
	}
}

void LoadGrenadePacks(){
	
	//============================================================================
	//							GRENADE PACKS
	//============================================================================
	// CreateGrenadePack(int level, int reset, GrenadeType first, GrenadeType second, GrenadeType third, GrenadeType fourth, int firstCount, int secondCount, int thirdCount, int fourthCount)
	
	CreateGrenadePack(	1, 0,
					 	{FIRE_GRENADE, FREEZE_GRENADE, LIGHT_GRENADE, NULL_GRENADE},
					 	{1, 1, 1, 0});
	
	CreateGrenadePack(	30, 0,
						{FIRE_GRENADE, FREEZE_GRENADE, LIGHT_GRENADE, NULL_GRENADE},
						{2, 1, 1, 0});
	
	CreateGrenadePack(	60, 0,
						{FIRE_GRENADE, FREEZE_GRENADE, LIGHT_GRENADE, NULL_GRENADE},
						{2, 2, 1, 0});
	
	CreateGrenadePack(	120, 0,
						{FIRE_GRENADE, FREEZE_GRENADE, LIGHT_GRENADE, NULL_GRENADE},
						{2, 2, 2, 0});
	
	CreateGrenadePack(	170, 0,
						{FIRE_GRENADE, FREEZE_GRENADE, LIGHT_GRENADE, NULL_GRENADE},
						{3, 2, 2, 0});
	
	CreateGrenadePack(	220, 0,
						{FIRE_GRENADE, FREEZE_GRENADE, AURA_GRENADE, NULL_GRENADE},
						{2, 1, 1, 0});
	
	CreateGrenadePack(	260, 0,
						{FIRE_GRENADE, FREEZE_GRENADE, AURA_GRENADE, NULL_GRENADE},
						{2, 2, 1, 0});
	
	CreateGrenadePack(	310, 0,
						{FIRE_GRENADE, FREEZE_GRENADE, AURA_GRENADE, NULL_GRENADE},
						{3, 2, 1, 0});
	
	CreateGrenadePack(	360, 0,
						{FIRE_GRENADE, FREEZE_GRENADE, AURA_GRENADE, VOID_GRENADE},
						{3, 2, 1, 1});
}

//=====================================================
//					METHOD
//=====================================================

// Grenades packs
methodmap ZGrenadePack{
	public ZGrenadePack(int value){
		return view_as<ZGrenadePack>(value);
	}
	
	property int id{
		public get(){
			return view_as<int>(this);
		}
	}
	property int iLevel{
		public get(){
			return gGrenadePackLevel.Get(this.id);
		}
		public set(int value){
			gGrenadePackLevel.Set(this.id, value);
		}
	}
	property int iReset{
		public get(){
			return gGrenadePackReset.Get(this.id);
		}
		public set(int value){
			gGrenadePackReset.Set(this.id, value);
		}
	}
	property GrenadeType iFirstGrenadeType{
		public get(){
			return grenadeType[GRENADE1].Get(this.id);
		}
		public set(GrenadeType value){
			grenadeType[GRENADE1].Set(this.id, value);
		}
	}
	property GrenadeType iSecondGrenadeType{
		public get(){
			return grenadeType[GRENADE2].Get(this.id);
		}
		public set(GrenadeType value){
			grenadeType[GRENADE2].Set(this.id, value);
		}
	}
	property GrenadeType iThirdGrenadeType{
		public get(){
			return grenadeType[GRENADE3].Get(this.id);
		}
		public set(GrenadeType value){
			grenadeType[GRENADE3].Set(this.id, value);
		}
	}
	property GrenadeType iFourthGrenadeType{
		public get(){
			return grenadeType[GRENADE4].Get(this.id);
		}
		public set(GrenadeType value){
			grenadeType[GRENADE4].Set(this.id, value);
		}
	}
	property int iFirstGrenadeCount{
		public get(){
			return grenadeCount[GRENADE1].Get(this.id);
		}
		public set(int value){
			grenadeCount[GRENADE1].Set(this.id, value);
		}
	}
	property int iSecondGrenadeCount{
		public get(){
			return grenadeCount[GRENADE2].Get(this.id);
		}
		public set(int value){
			grenadeCount[GRENADE2].Set(this.id, value);
		}
	}
	property int iThirdGrenadeCount{
		public get(){
			return grenadeCount[GRENADE3].Get(this.id);
		}
		public set(int value){
			grenadeCount[GRENADE3].Set(this.id, value);
		}
	}
	property int iFourthGrenadeCount{
		public get(){
			return grenadeCount[GRENADE4].Get(this.id);
		}
		public set(int value){
			grenadeCount[GRENADE4].Set(this.id, value);
		}
	}
	public bool hasGrenade(GrenadeType type){
		bool ret = false;
		
		for(int i; i < GRENADE_SLOTS; i++){
			if(view_as<GrenadeType>(grenadeType[i].Get(this.id)) == type && grenadeCount[i].Get(this.id) > 0){
				ret = true;
				break;
			}
		}
		
		return ret;
	}
	public int getGrenadeCount(GrenadeType type){
		int ret = -1;
		
		for(int i; i < GRENADE_SLOTS; i++){
			if(view_as<GrenadeType>(grenadeType[i].Get(this.id)) == type){
				ret = grenadeCount[i].Get(this.id);
				break;
			}
		}
		
		return ret;
	}

}

//=====================================================
//					GRENADES CREATION
//=====================================================
stock int CreateGrenadePack(int level, int reset, GrenadeType types[GRENADE_SLOTS], int counts[GRENADE_SLOTS]){
	ZGrenadePack pack = ZGrenadePack(gGrenadePackLevel.Length);
	gGrenadePackLevel.Push(level);
	gGrenadePackReset.Push(reset);
	
	for(int i; i < GRENADE_SLOTS; i++){
		grenadeType[i].Push(types[i]);
		grenadeCount[i].Push(counts[i]);
	}
	return pack.id;
}