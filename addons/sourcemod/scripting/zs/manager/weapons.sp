/**
 * @brief Gets the map weapon state.
 *
 * @param weapon            The weapon index.
 * @return                  True or false.    
 **/
bool WeaponsGetMap(int weapon)
{
	// Gets value on the weapon
	return view_as<bool>(GetEntProp(weapon, Prop_Data, "m_bIsAutoaimTarget"));
}

/**
 * @brief Gets the weapon owner.
 *
 * @param weapon            The weapon index.
 * @return                  The owner index.    
 **/
int WeaponsGetOwner(int weapon)
{
	// Gets value on the weapon
	return GetEntPropEnt(weapon, Prop_Send, "m_hOwner");
}

