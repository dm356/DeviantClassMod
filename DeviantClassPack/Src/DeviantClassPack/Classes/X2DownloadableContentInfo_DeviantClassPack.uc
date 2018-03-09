///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Every Mod gets one of these files, DO NOT MESS WITH THIS
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_DeviantClassPack.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_DeviantClassPack extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{}

// Updates localization strings from config file values (Original file from Richard)
static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	local name TagText;
	//local int i;
	
	TagText = name(InString);
	switch (TagText)
	{
//Shared Perks
	case 'BARRIERRS_HEALTH':
			OutString = string(class'X2Ability_SharedAbilitiesDevAbilitySet'.default.BARRIERRS_HEALTH);
			return true;
	case 'BARRIERRS_DURATION':
			OutString = string(class'X2Ability_SharedAbilitiesDevAbilitySet'.default.BARRIERRS_DURATION);
			return true;
	case 'DISTORTIONFIELDRS_DEFENSE':
			OutString = string(class'X2Ability_SharedAbilitiesDevAbilitySet'.default.DISTORTIONFIELDRS_DEFENSE);
			return true;
	case 'RESTORERS_HEAL':
			OutString = string(class'X2Ability_SharedAbilitiesDevAbilitySet'.default.RESTORERS_HEAL);
			return true;
//GTS Perks
	case 'HIDDENPOTENTIAL_PSIOFFENSE':
			OutString = string(class'X2Ability_GTSAbilitiesDevAbilitySet'.default.HIDDENPOTENTIAL_PSIOFFENSE);
			return true;
//End
	default:
            return false;
    }  
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//END FILE
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////