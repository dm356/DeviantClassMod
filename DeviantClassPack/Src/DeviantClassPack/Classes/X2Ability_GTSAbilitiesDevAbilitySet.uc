///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//File Title/Reference. For anyone reading, I have merged all the individual AbilitySets into two files, this set is for GTS Abilities only.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class X2Ability_GTSAbilitiesDevAbilitySet extends X2Ability config(Dev_SoldierSkills);

struct GTSTableEntry
{
	var name	GTSProjectTemplateName;
	var	int		SupplyCost;
	var int		RankRequired;
	var	bool	HideifInsufficientRank;
	var name	UniqueClass;
	structdefaultproperties
	{
		GTSProjectTemplateName=None
		SupplyCost=0
		RankRequired=0
		HideifInsufficientRank=false
		UniqueClass=none
	}
};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//These are the lines you need to reference stuff in the config file (Dev_SoldierSkills)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

var config int HIDDENPOTENTIAL_PSIOFFENSE;
var config array<GTSTableEntry> GTSTable;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//This is the list of my custom perks held in this file, with all the individual code wayyyy below. Use Ctrl + F to find the perk you need.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateEditGTSProjectsTemplate());

	//GTS Handles
	Templates.AddItem(AddPsionPerkGTSAbility());

	//Specific Abilities
	Templates.AddItem(HiddenPotentialDev());

	return Templates;
}


static function X2LWTemplateModTemplate CreateEditGTSProjectsTemplate()
{
	local X2LWTemplateModTemplate Template;

	`CREATE_X2TEMPLATE(class'X2LWTemplateModTemplate', Template, 'EditGTSProjectsTree');
	Template.StrategyElementTemplateModFn = EditGTSProjects;
	return Template;
}

function EditGTSProjects(X2StrategyElementTemplate Template, int Difficulty)
{
	local int						i;
	local ArtifactCost				Resources;
	local X2SoldierUnlockTemplate	GTSTemplate;

	GTSTemplate = X2SoldierUnlockTemplate (Template);
	if (GTSTemplate != none)
	{
		for (i=0; i < GTSTable.Length; ++i)
		{
			if (GTSTemplate.DataName == GTSTable[i].GTSProjectTemplateName)
			{
				GTSTemplate.Cost.ResourceCosts.Length=0;
				if (GTSTable[i].SupplyCost > 0)
				{
					Resources.ItemTemplateName = 'Supplies';
					Resources.Quantity = GTSTable[i].SupplyCost;
					GTSTemplate.Cost.ResourceCosts.AddItem(Resources);
				}
				GTSTemplate.Requirements.RequiredHighestSoldierRank = GTSTable[i].RankRequired;
				//bVisibleIfSoldierRankGatesNotMet does not work
				GTSTemplate.Requirements.bVisibleIfSoldierRankGatesNotMet = !GTSTable[i].HideIfInsufficientRank;
				GTSTemplate.AllowedClasses.Length = 0;
				GTSTemplate.Requirements.RequiredSoldierClass = '';
				if (GTSTable[i].UniqueClass != '')
				{
					GTSTemplate.Requirements.RequiredSoldierRankClassCombo = true;
					GTSTemplate.AllowedClasses.AddItem(GTSTable[i].UniqueClass);
					GTSTemplate.Requirements.RequiredSoldierClass = GTSTable[i].UniqueClass;
				}
				else
				{
					GTSTemplate.bAllClasses=true;
				}
			}
		}
	}
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

	Template.AdditionalAbilities.AddItem('HiddenPotentialDev');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

// Hidden Potential Ability
static function X2AbilityTemplate HiddenPotentialDev()
{
	local X2AbilityTemplate						Template;
	local X2Effect_PersistentStatChange         PSI;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'HiddenPotentialDev');
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