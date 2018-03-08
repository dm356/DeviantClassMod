///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//File Title/Reference. For anyone reading, I have merged all the individual AbilitySets into two files, this set is for GTS Abilities only.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class X2Ability_GTSPerksRSAbilitySet extends X2Ability config(RS_SoldierSkills);


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//These are the lines you need to reference stuff in the config file (RS_SoldierSkills)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

var config int HIDDENPOTENTIAL_PSIOFFENSE;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//This is the list of my custom perks held in this file, with all the individual code wayyyy below. Use Ctrl + F to find the perk you need.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	//GTS Handles
	Templates.AddItem(AddPsionPerkGTSAbility());

	//Specific Abilities
	Templates.AddItem(HiddenPotentialRS());

	return Templates;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//All the Code is below this - CTRL + F is recommended to find what you need as it's a mess...
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//#############################################################
// Psion GTS - Hidden Potential (+25 Psi-Offense)
//#############################################################

// GTS Handle
static function X2AbilityTemplate AddPsionPerkGTSAbility()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle                  TargetStyle;
	local X2AbilityTrigger						Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'PsionPerkGTS');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	Template.AdditionalAbilities.AddItem('HiddenPotentialRS');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

// Hidden Potential Ability
static function X2AbilityTemplate HiddenPotentialRS()
{
	local X2AbilityTemplate						Template;
	local X2Effect_PersistentStatChange         PSI;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'HiddenPotentialRS');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventpsiwitch_confuse"; //ICON!

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	PSI = new class'X2Effect_PersistentStatChange';
	PSI.AddPersistentStatChange(eStat_PsiOffense, default.HIDDENPOTENTIAL_PSIOFFENSE);
	PSI.BuildPersistentEffect(1, true, false, false);
	PSI.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	Template.AddTargetEffect(PSI);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.PsiOffenseBonusLabel, eStat_PsiOffense, default.HIDDENPOTENTIAL_PSIOFFENSE); // eStat_PsiOffense has PsiOffenseBonusLabel for some reason.

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//END FILE
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////