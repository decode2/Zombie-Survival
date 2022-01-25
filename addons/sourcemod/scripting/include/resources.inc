#pragma semicolon 1

#define DEBUG

#include <sourcemod>
#include <sdktools_stringtables>

#define CFG_ROOT "/addons/sourcemod/configs/resources"
#define DIRECTORY_AMMOUNT 4

//#define	DEBUG_MESSAGES	0

File g_FileExclusionList[DIRECTORY_AMMOUNT];
char g_cRootDirectoryName[][] = { "models", "materials", "sound", "particles" };
int g_iFileExtCount[] = { 5, 2, 4, 2 };
char g_cFileExtension[][][] = { {"mdl", "vvd", "vtx", "phy", "ani"}, {"vmt", "vtf", "", "", ""}, {"mp3", "wav", "", "", ""}, {"pcf", "txt", "", "", ""} };
int g_iCacheFileExtCount[] = { 1, 1, 4, 2 };
char g_cCacheFileExtension[][][] = { {"mdl", "", "", ""}, {"vmt", "", "", ""}, {"mp3", "wav", "", ""}, {"pcf", "txt", "", ""} };

stock void RegisterResources(int index, DirectoryListing dirList = view_as<DirectoryListing>(INVALID_HANDLE), const char[] cDirectory){
	SetUpConfigs();

	FileType iType;
	char cFileName[PLATFORM_MAX_PATH];
	char cBuffer[PLATFORM_MAX_PATH];
	char cExtensionName[PLATFORM_MAX_PATH];

	if(dirList == INVALID_HANDLE) dirList = OpenDirectory(g_cRootDirectoryName[index], false);

	if(dirList == INVALID_HANDLE) return;

	while(ReadDirEntry(dirList, cFileName, PLATFORM_MAX_PATH, iType)){

		if(iType == FileType_File){

			GetFileExtension(cExtensionName, cFileName, PLATFORM_MAX_PATH);
			
			// check if file's extension is what i'm finding
			for(int i = 0; i < g_iFileExtCount[index]; i++){
				
				// found.
				if(StrEqual(cExtensionName, g_cFileExtension[index][i])){

					Format(cBuffer, sizeof(cBuffer), "%s/%s", cDirectory, cFileName);
					AddFileToDownloadsTable(cBuffer);

					// check whether this file needs to be precached. 
					for(int x = 0; x < g_iCacheFileExtCount[index]; x++){

						if(StrEqual(cExtensionName, g_cCacheFileExtension[index][x])){
							
							if(index == 0)
								PrecacheModel(cBuffer);

							else if(index == 2){

								ReplaceStringEx(cBuffer, sizeof(cBuffer), "sound/", "*/");
								PrecacheSound(cBuffer);

							}
							else if (index == 3){
								if (StrContains(cExtensionName, "pcf") != -1)
									PrecacheGeneric(cBuffer, true);
								else if (StrContains(cExtensionName, "txt") != -1 && StrContains(cBuffer, "_particles") != -1)
									PrecacheGeneric(cBuffer);
							}
							//PrintToServer("%s registrado y agregado a tabla de descargas", cBuffer);
							break;
						}

						//else PrintToServer("%s agregado a tabla de descargas",cBuffer);
					}
					break;
				}
			}
		}

		// dir
		else if(iType == FileType_Directory && IsStringNotFuckingIdiotDot(cFileName)){

			Format(cBuffer, sizeof(cBuffer), "%s/%s", cDirectory, cFileName);

			if(!IsDirectoryExcluded(cBuffer, index))
				RegisterResources(index, OpenDirectory(cBuffer, false), cBuffer);
			#if defined DEBUG_MESSAGES
			else PrintToServer("[RESOURCES] Directory Excluded : %s", cBuffer);

			PrintToServer("Abriendo: %s", cBuffer);
			#endif
		}
	}

	delete dirList;
	//PrintToServer("Carga de recursos completada en: %s", g_cRootDirectoryName[index]);
}

stock void GetExclusionList(){

	char cPath[PLATFORM_MAX_PATH];
	char cBuffer[PLATFORM_MAX_PATH];
	
	Format(cPath, sizeof(cPath), "configs/resources/exclusionList");
	
	for(int x = 0; x < sizeof(g_cRootDirectoryName); x++){
		BuildPath(Path_SM, cBuffer, sizeof(cBuffer), "%s_%s.cfg", cPath, g_cRootDirectoryName[x]);
		g_FileExclusionList[x] = OpenFile(cBuffer, "r");
	}
}

stock bool IsDirectoryExcluded(const char[] cDirectory, int index){
	
	if(!DirExists("configs/resources/exclusionList")){
		return false;
	}
	
	char cLine[PLATFORM_MAX_PATH];

	g_FileExclusionList[index].Seek(0, SEEK_SET);

	while(ReadFileLine(g_FileExclusionList[index], cLine, sizeof(cLine))){

		TrimString(cLine);

		if(cLine[0] != '0' && StrEqual(cLine, cDirectory)){
			return true;
		}
	}
	return false;
}

stock void GetFileExtension(char[] cExtensionName, const char[] cFileName, int maxlength){

	Format(cExtensionName, maxlength, "%s", cFileName[FindCharInString(cFileName, '.', true) + 1]);
}

stock bool IsStringNotFuckingIdiotDot(const char[] cString){

	if(StrEqual(cString, ".") || StrEqual(cString, ".."))
		return false;
	return true;
}

stock void SetUpConfigs(){
	char models[255], materials[255], sounds[255], particles[255];
	
	FormatEx(models, sizeof(models), "%s/exclusionList_models.cfg", CFG_ROOT);
	FormatEx(materials, sizeof(materials), "%s/exclusionList_materials.cfg", CFG_ROOT);
	FormatEx(sounds, sizeof(sounds), "%s/exclusionList_sound.cfg", CFG_ROOT);
	FormatEx(particles, sizeof(particles), "%s/exclusionList_particles.cfg", CFG_ROOT);

	if(!DirExists(CFG_ROOT)){
		PrintToServer("Creating directory.. (%s)", CreateDirectory(CFG_ROOT, 511) ? "Success" : "Failed");
	}
	if(!FileExists(models)){
		PrintToServer("Creating models cfg...");
		File f = OpenFile(models, "w");
		delete f;
	}
	if(!FileExists(materials)){
		PrintToServer("Creating materials cfg...");
		File f = OpenFile(materials, "w");
		delete f;
	}
	if(!FileExists(sounds)){
		PrintToServer("Creating sounds cfg...");
		File f = OpenFile(sounds, "w");
		delete f;
	}
	if(!FileExists(particles)){
		PrintToServer("Creating particles cfg...");
		File f = OpenFile(particles, "w");
		delete f;
	}
}

// Initialize resources functionss
stock void Resources_OnMapStart(){
	GetExclusionList();
	
	for(int x = 0; x < sizeof(g_cRootDirectoryName); x++){
		RegisterResources(x, view_as<DirectoryListing>(INVALID_HANDLE), g_cRootDirectoryName[x]);
	}
	
	for(int y = 0; y < sizeof(g_cRootDirectoryName); y++){
		delete g_FileExclusionList[y];
	}
}