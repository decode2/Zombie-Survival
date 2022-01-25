//Weapon Attachment API include file

#if defined _WeaponAttachmentAPI_included
 #endinput
#endif
#define _WeaponAttachmentAPI_included

/**
 * Gets the attachment postion of the client's current weapon.
 *
 * @param client		Client index
 * @param attachment	The attachment point to look up
 * @return 				Returns false if the position could not be looked up
 * @error				Invalid client.
 */
native bool WA_GetAttachmentPos(int client, char[] attachment, float pos[3]);


public SharedPlugin:__pl_WeaponAttachmentAPI =
{
	name = "WeaponAttachmentAPI",
	file = "WeaponAttachmentAPI.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_WeaponAttachmentAPI_SetNTVOptional()
{
	MarkNativeAsOptional("WA_GetAttachmentPos");
}
#endif
