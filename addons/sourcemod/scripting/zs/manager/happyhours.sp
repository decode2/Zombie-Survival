
#define HAPPYHOURS_MODULE_VERSION "0.1"

// Happy hour defines
/*#define HH_START	0
#define HH_END		4*/
#define HAPPY_HOUR_MULTIPLIER 	2
#define HAPPY_HOUR_MINPLAYERS 	15

// After hour defines
/*#define AH_START	4
#define AH_END		6*/
#define AFTER_HOUR_MULTIPLIER 	3
#define AFTER_HOUR_MINPLAYERS 	20

#define SERVER_EXP_MULTIPLIER 	7.0

//=====================================================
//				HAPPYHOURS & AFTERHOURS
//=====================================================
bool gHappyHour = false;
bool gAfterHour = false;

// Needed to know if HH & AH are available
int iPlayersQuantity = 0;

stock int HappyHours_GetIntegerHour(){
	char hour[32];
	FormatTime(hour, sizeof(hour), "%H", GetTime());
	
	return StringToInt(hour);
}
/*
stock int HappyHours_GetIntegerDay(){
	char day[2];
	FormatTime(day, sizeof(day), "%u", GetTime()); //%u -> dia de la semana (1 - 7)
	
	return StringToInt(day);
}*/

/*
stock bool isHappyHourTime(){
	
	int hora = HappyHours_GetIntegerHour();
	
	return ( (hora >= HH_START && hora < HH_END && iPlayersQuantity >= HAPPY_HOUR_MINPLAYERS) || (hora >= AH_START && hora < AH_END && iPlayersQuantity < AFTER_HOUR_MINPLAYERS && iPlayersQuantity >= HAPPY_HOUR_MINPLAYERS) );
}
stock bool isAfterHourTime(){
	int hora = HappyHours_GetIntegerHour();
	
	return (hora >= AH_START && hora < AH_END && iPlayersQuantity >= AFTER_HOUR_MINPLAYERS);
}*/

stock bool isHappyHourTime(){
	
	return (HAPPY_HOUR_MINPLAYERS <= iPlayersQuantity < AFTER_HOUR_MINPLAYERS);
	//return (iPlayersQuantity > 1000000);
}

stock bool isAfterHourTime(){
	
	return (iPlayersQuantity >= AFTER_HOUR_MINPLAYERS);
	//return (iPlayersQuantity >= 8);
}

////////////////////////////////
void HappyHoursOnCommandInit(){
	
	// Happy hour check
	RegConsoleCmd("hh", happyHour);
	RegConsoleCmd("happyhour", happyHour);
	RegConsoleCmd("happyhours", happyHour);
}

public Action happyHour(int client, int args){
	char buffer[128];
	
	if(gHappyHour)
		FormatEx(buffer, sizeof(buffer), "Happy hours time");
	else if(gAfterHour)
		FormatEx(buffer, sizeof(buffer), "After hours time");
	else
		FormatEx(buffer, sizeof(buffer), "Common hours time");
	
	(client != 0) ? TranslationPrintToChat(client, buffer) : TranslationPrintToChatAll(buffer);
}

void HappyHoursOnPostRoundStart(){
	
	// Happy hour check
	gHappyHour = isHappyHourTime();
	gAfterHour = isAfterHourTime();
	
	PrintToServer("[HAPPYHOURS] Timecheck: HH is %b | AH is %b", gHappyHour, gAfterHour);
	
	if (gHappyHour || gAfterHour) happyHour(0, 0);
}