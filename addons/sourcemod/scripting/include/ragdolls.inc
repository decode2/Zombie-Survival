//
// Ragdolls
//

#if defined _ragdolls_included
	#endinput
#endif
#define _ragdolls_included

// Visual effects
#define VISUAL_EFFECTS	1

#if VISUAL_EFFECTS == 1
#define VEFFECTS_RAGDOLL_DISSOLVE_EFFECTLESS	-2
#define VEFFECTS_RAGDOLL_DISSOLVE_RANDOM		-1
#define VEFFECTS_RAGDOLL_DISSOLVE_ENERGY		0
#define VEFFECTS_RAGDOLL_DISSOLVE_ELECTRICALH	1
#define VEFFECTS_RAGDOLL_DISSOLVE_ELECTRICALL	2
#define VEFFECTS_RAGDOLL_DISSOLVE_CORE		  	3

#define VEFFECTS_DISSOLVE_DELAY		0.5
#define VEFFECTS_DISSOLVE_TYPE		VEFFECTS_RAGDOLL_DISSOLVE_RANDOM

#pragma unused g_iToolsRagdoll
int g_iToolsRagdoll;
#endif

//=====================================================
//				RAGDOLL: DEATH EFFECTS
//=====================================================
#if VISUAL_EFFECTS == 1
#pragma unused RagdollOnClientDeath
void RagdollOnClientDeath(int client){
	int ragdoll = RagdollGetClientRagdoll(client);
	
	// If the ragdoll is invalid, then stop.
	if (ragdoll == -1)
	{
		return;
	}
	
	// Get the delay.
	float dissolvedelay = VEFFECTS_DISSOLVE_DELAY;
	
	// If the delay is 0 or less, then remove right now.
	if (dissolvedelay <= 0)
	{
		RagdollTimer(INVALID_HANDLE, ragdoll);
		return;
	}
	
	// Create a timer to remove/dissolve ragdoll.
	CreateTimer(dissolvedelay, RagdollTimer, ragdoll, TIMER_FLAG_NO_MAPCHANGE);
}
void RagdollRemove(int ragdoll){
	// Get the dissolve type.
	int dissolve = VEFFECTS_DISSOLVE_TYPE;
	
	if (dissolve == VEFFECTS_RAGDOLL_DISSOLVE_EFFECTLESS)
	{
		// Remove entity from world.
		AcceptEntityInput(ragdoll, "Kill");
		return;
	}
	
	// If random, set value to any between "energy" effect and "core" effect.
	if (dissolve == VEFFECTS_RAGDOLL_DISSOLVE_RANDOM)
	{
		dissolve = GetRandomInt(VEFFECTS_RAGDOLL_DISSOLVE_ENERGY, VEFFECTS_RAGDOLL_DISSOLVE_CORE);
	}
	
	// Prep the ragdoll for dissolving.
	char targetname[64];
	Format(targetname, sizeof(targetname), "zr_dissolve_%d", ragdoll);
	DispatchKeyValue(ragdoll, "targetname", targetname);
	
	// Prep the dissolve entity.
	int dissolver = CreateEntityByName("env_entity_dissolver");
	
	// Set the target to the ragdoll.
	DispatchKeyValue(dissolver, "target", targetname);
	
	// Set the dissolve type.
	char dissolvetype[16];
	Format(dissolvetype, sizeof(dissolvetype), "%d", dissolve);
	DispatchKeyValue(dissolver, "dissolvetype", dissolvetype);
	
	// Tell the entity to dissolve the ragdoll.
	AcceptEntityInput(dissolver, "Dissolve");
	
	// Remove the dissolver.
	AcceptEntityInput(dissolver, "Kill");
}
public Action RagdollTimer(Handle timer, any ragdoll){
	// If the ragdoll is already gone, then stop.
	if (!IsValidEdict(ragdoll))
	{
		return;
	}
	
	// Make sure this edict is still a ragdoll and not become a new valid entity.
	char classname[64];
	GetEdictClassname(ragdoll, classname, sizeof(classname));
	if (!StrEqual(classname, "cs_ragdoll"))
	{
		return;
	}
	
	// Remove the ragdoll.
	RagdollRemove(ragdoll);
}
stock int RagdollGetClientRagdoll(int client){
	return GetEntDataEnt2(client, g_iToolsRagdoll);
}
stock void RagdollResetClientRagdoll(int client){
	SetEntDataEnt2(client, g_iToolsRagdoll, -1);
}
#endif
