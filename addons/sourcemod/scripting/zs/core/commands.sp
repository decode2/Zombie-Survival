/**
 * @brief Commands are created.
 **/
void CommandsOnInit(/*void*/){
	
	// Forward event to modules
	//DebugOnCommandInit();
	ConfigOnCommandInit();
	//LogOnCommandInit();
	DeathOnCommandInit();
	//SpawnOnCommandInit();
	MenusOnCommandInit();
	ToolsOnCommandInit();
	/*ClassesOnCommandInit();
	WeaponsOnCommandInit();*/
	GameModesOnCommandInit();
	/*ExtraItemsOnCommandInit();
	CostumesOnCommandInit();
	VersionOnCommandInit();*/
	HappyHoursOnCommandInit();
	PartyOnCommandInit();
	LaserminesOnCommandInit();
}