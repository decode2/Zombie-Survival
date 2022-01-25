
#define DEBUG

#define PLUGIN_NAME           "Print discord"
#define PLUGIN_AUTHOR         "Deco"
#define PLUGIN_DESCRIPTION    "PLUGIN PARA PIU PA"
#define PLUGIN_VERSION        "1.0"
#define PLUGIN_URL            "www.piu-games.com"

#include <sourcemod>
#include <sdktools>

#pragma semicolon 1

#pragma newdecls required

#define DISCORD_LINK 	"https://discord.gg/6kTWrfN3tK"
#define SERVERSTRING "\x01 \x04[PIU - MOOD]\x01"


public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

public void OnPluginStart()
{
	if(GetEngineVersion() != Engine_CSGO)
		SetFailState("This plugin is for the game CSGO only.");
	
	RegConsoleCmd("discord", cmdDiscord);
	RegConsoleCmd("sm_discord", cmdDiscord);
	RegConsoleCmd("disc", cmdDiscord);
	RegConsoleCmd("ds", cmdDiscord);
}

public Action cmdDiscord(int client, int args){

	
	PrintToChat(client, "%s Ingresa al siguiente enlace para ingresar a nuestro servidor de \x09Discord\x01! (\x09%s\x01).", SERVERSTRING, DISCORD_LINK);
	PrintToChat(client, "%s Este mensaje también será enviado a tu consola para que puedas copiar y pegar.", SERVERSTRING);
	
	PrintToConsole(client, "[PIU] El enlace para ingresar al servidor de Discord es %s", DISCORD_LINK);
	PrintToConsole(client, "[PIU] TE ESPERAMOS!");
}

