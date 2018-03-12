//---------------------------------------------------------------------------------------
//  FILE:    LWTemplateMods
//  AUTHOR:  tracktwo / Pavonis Interactive
//
//  PURPOSE: Mods to base XCOM2 templates
//---------------------------------------------------------------------------------------

//`include(LW_Overhaul\Src\LW_Overhaul.uci)

class LWTemplateMods extends X2StrategyElement config(LW_SoldierSkills);

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

var config array<GTSTableEntry> GTSTable;

var config int SERIAL_CRIT_MALUS_PER_KILL;
var config int SERIAL_AIM_MALUS_PER_KILL;
var config bool SERIAL_DAMAGE_FALLOFF;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

  Templates.Additem(CreateReconfigGearTemplate());
	Templates.AddItem(CreateEditGTSProjectsTemplate());
	//Vanilla Perks that need adjustment
	Templates.AddItem(CreateModifyAbilitiesGeneralTemplate());
	return Templates;
}

static function X2LWTemplateModTemplate CreateReconfigGearTemplate()
{
  local X2LWTemplateModTemplate Template;

  `CREATE_X2TEMPLATE(class'X2LWTemplateModTemplate', Template, 'ReconfigGear');
  Template.ItemTemplateModFn = ReconfigGear;
  return Template;
}

// Hack for now, eventually move into separate sub-mod
function ReconfigGear(X2ItemTemplate Template, int Difficulty)
{
  local X2WeaponTemplate WeaponTemplate;

  // Reconfig Weapons and Weapon Schematics
  WeaponTemplate = X2WeaponTemplate(Template);
  if (WeaponTemplate != none)
  {
    // substitute cannon range table
    if (WeaponTemplate.WeaponCat == 'sniper_rifle')
    {
	  WeaponTemplate.Abilities.AddItem('LongWatch');
      WeaponTemplate.Abilities.AddItem('Squadsight');
    }
  }
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

// various small changes to vanilla abilities
static function X2LWTemplateModTemplate CreateModifyAbilitiesGeneralTemplate()
{
   local X2LWTemplateModTemplate Template;

   `CREATE_X2TEMPLATE(class'X2LWTemplateModTemplate', Template, 'ModifyAbilitiesGeneral');
   Template.AbilityTemplateModFn = ModifyAbilitiesGeneral;
   return Template;
}

function ModifyAbilitiesGeneral(X2AbilityTemplate Template, int Difficulty)
{
	local X2Effect_CancelLongRangePenalty	DFAEffect;
	local X2Effect_DeathFromAbove_LW		DeathEffect;
	local X2Effect_SerialCritReduction		SerialCritReduction;
	local X2Effect_Persistent				ShotEffect;

  switch (Template.DataName)
  {
    case 'OverwatchShot':
    case 'LongWatchShot':
    case 'GunslingerShot':
    case 'KillZoneShot':
    case 'PistolOverwatchShot':
    case 'SuppressionShot_LW':
    case 'SuppressionShot':
    case 'AreaSuppressionShot_LW':
    case 'CloseCombatSpecialistAttack':
      ShotEffect = class'X2Ability_PerkPackAbilitySet'.static.CoveringFireMalusEffect();
      ShotEffect.TargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.static.OverwatchTargetEffectsCondition());
      Template.AddTargetEffect(ShotEffect);
  }

  // centralizing suppression rules. first batch is new vanilla abilities restricted by suppress.
  // second batch is abilities affected by vanilla suppression that need area suppression change
  // Third batch are vanilla abilities that need suppression limits AND general shooter effect exclusions
  // Mod abilities have restrictions in template defintions
  switch (Template.DataName)
  {
    case 'ThrowGrenade':
    case 'LaunchGrenade':
    case 'MicroMissiles':
    case 'RocketLauncher':
    case 'PoisonSpit':
    case 'GetOverHere':
    case 'Bind':
    case 'AcidBlob':
    case 'BlazingPinionsStage1':
    case 'HailOfBullets':
    case 'SaturationFire':
    case 'Demolition':
    case 'PlasmaBlaster':
    case 'ShredderGun':
    case 'ShredstormCannon':
    case 'BladestormAttack':
    case 'Grapple':
    case 'GrapplePowered':
    case 'IntheZone':
    case 'Reaper':
    case 'Suppression':
      SuppressedCondition = new class'X2Condition_UnitEffects';
      SuppressedCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
      SuppressedCondition.AddExcludeEffect(class'X2Effect_AreaSuppression'.default.EffectName, 'AA_UnitIsSuppressed');
      Template.AbilityShooterConditions.AddItem(SuppressedCondition);
      break;
    case 'Overwatch':
    case 'PistolOverwatch':
    case 'SniperRifleOverwatch':
    case 'LongWatch':
    case 'Killzone':
      SuppressedCondition = new class'X2Condition_UnitEffects';
      SuppressedCondition.AddExcludeEffect(class'X2Effect_AreaSuppression'.default.EffectName, 'AA_UnitIsSuppressed');
      Template.AbilityShooterConditions.AddItem(SuppressedCondition);
      break;
    case 'MarkTarget':
    case 'EnergyShield':
    case 'EnergyShieldMk3':
    case 'BulletShred':
    case 'Stealth':
      Template.AddShooterEffectExclusions();
      SuppressedCondition = new class'X2Condition_UnitEffects';
      SuppressedCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
      SuppressedCondition.AddExcludeEffect(class'X2Effect_AreaSuppression'.default.EffectName, 'AA_UnitIsSuppressed');
      Template.AbilityShooterConditions.AddItem(SuppressedCondition);
      break;
    default:
      break;
  }

  if (Template.DataName == class'X2Ability_Viper'.default.BindAbilityName)
  {
    SuppressedCondition = new class'X2Condition_UnitEffects';
    SuppressedCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
    SuppressedCondition.AddExcludeEffect(class'X2Effect_AreaSuppression'.default.EffectName, 'AA_UnitIsSuppressed');
    SuppressedCondition.AddExcludeEffect(class'X2AbilityTemplateManager'.default.StunnedName, 'AA_UnitIsStunned');
    Template.AbilityTargetConditions.AddItem(SuppressedCondition);
  }

	// Use alternate DFA effect so it's compatible with Double Tap 2, and add additional ability of canceling long-range sniper rifle penalty
	if (Template.DataName == 'DeathFromAbove')
	{
		Template.AbilityTargetEffects.Length = 0;
		DFAEffect = New class'X2Effect_CancelLongRangePenalty';
		DFAEffect.BuildPersistentEffect (1, true, false);
		DFAEffect.SetDisplayInfo (0, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false,, Template.AbilitySourceName);
		Template.AddTargetEffect(DFAEffect);
		DeathEffect = new class'X2Effect_DeathFromAbove_LW';
		DeathEffect.BuildPersistentEffect(1, true, false, false);
		DeathEffect.SetDisplayInfo(0, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
		Template.AddTargetEffect(DeathEffect);
	}

  if (Template.DataName == 'HailofBullets')
  {
    InventoryCondition = new class'X2Condition_UnitInventory';
    InventoryCondition.RelevantSlot=eInvSlot_PrimaryWeapon;
    InventoryCondition.ExcludeWeaponCategory = 'shotgun';
    Template.AbilityShooterConditions.AddItem(InventoryCondition);

    InventoryCondition2 = new class'X2Condition_UnitInventory';
    InventoryCondition2.RelevantSlot=eInvSlot_PrimaryWeapon;
    InventoryCondition2.ExcludeWeaponCategory = 'sniper_rifle';
    Template.AbilityShooterConditions.AddItem(InventoryCondition2);

    for (k = 0; k < Template.AbilityCosts.length; k++)
    {
      AmmoCost = X2AbilityCost_Ammo(Template.AbilityCosts[k]);
      if (AmmoCost != none)
      {
        X2AbilityCost_Ammo(Template.AbilityCosts[k]).iAmmo = default.HAIL_OF_BULLETS_AMMO_COST;
      }
    }
  }

  if (Template.DataName == 'InTheZone')
  {
    SerialCritReduction = new class 'X2Effect_SerialCritReduction';
    SerialCritReduction.BuildPersistentEffect(1, false, true, false, 8);
    SerialCritReduction.CritReductionPerKill = default.SERIAL_CRIT_MALUS_PER_KILL;
    SerialCritReduction.AimReductionPerKill = default.SERIAL_AIM_MALUS_PER_KILL;
    SerialCritReduction.Damage_Falloff = default.SERIAL_DAMAGE_FALLOFF;
    SerialCritReduction.SetDisplayInfo (ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true,, Template.AbilitySourceName);
    Template.AddTargetEffect(SerialCritReduction);
  }

  if (Template.DataName == 'CoolUnderPressure')
  {
    Template.AbilityTargetEffects.length = 0;
    ReactionFire = new class'X2Effect_ModifyReactionFire';
    ReactionFire.bAllowCrit = true;
    ReactionFire.ReactionModifier = class'X2Ability_SpecialistAbilitySet'.default.UNDER_PRESSURE_BONUS;
    ReactionFire.BuildPersistentEffect(1, true, false, true);
    ReactionFire.SetDisplayInfo(0, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,, Template.AbilitySourceName);
    Template.AddTargetEffect(ReactionFire);
  }

  if (Template.DataName == 'BulletShred')
  {
    StandardAim = new class'X2AbilityToHitCalc_StandardAim';
    StandardAim.bHitsAreCrits = false;
    StandardAim.BuiltInCritMod = default.RUPTURE_CRIT_BONUS;
    Template.AbilityToHitCalc = StandardAim;
    Template.AbilityToHitOwnerOnMissCalc = StandardAim;

    for (k = 0; k < Template.AbilityTargetConditions.Length; k++)
    {
      TargetVisibilityCondition = X2Condition_Visibility(Template.AbilityTargetConditions[k]);
      if (TargetVisibilityCondition != none)
      {
        // Allow rupture to work from SS
        TargetVisibilityCondition = new class'X2Condition_Visibility';
        TargetVisibilityCondition.bRequireGameplayVisible  = true;
        TargetVisibilityCondition.bAllowSquadsight = true;
        Template.AbilityTargetConditions[k] = TargetVisibilityCondition;
      }
    }
  }

  if (Template.DataName == 'KillZone' || Template.DataName == 'Deadeye' || Template.DataName == 'BulletShred')
  {
    for (k = 0; k < Template.AbilityCosts.length; k++)
    {
      ActionPointCost = X2AbilityCost_ActionPoints(Template.AbilityCosts[k]);
      if (ActionPointCost != none)
      {
        X2AbilityCost_ActionPoints(Template.AbilityCosts[k]).iNumPoints = 0;
        X2AbilityCost_ActionPoints(Template.AbilityCosts[k]).bAddWeaponTypicalCost = true;
      }
    }
  }

  // adds config to ammo cost and fixes vanilla bug in which
  if (Template.DataName == 'SaturationFire')
  {
    for (k = 0; k < Template.AbilityCosts.length; k++)
    {
      AmmoCost = X2AbilityCost_Ammo(Template.AbilityCosts[k]);
      if (AmmoCost != none)
      {
        X2AbilityCost_Ammo(Template.AbilityCosts[k]).iAmmo = default.SATURATION_FIRE_AMMO_COST;
      }
    }
    Template.AbilityMultiTargetEffects.length = 0;
    Template.AddMultiTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());
    WorldDamage = new class'X2Effect_MaybeApplyDirectionalWorldDamage';
    WorldDamage.bUseWeaponDamageType = true;
    WorldDamage.bUseWeaponEnvironmentalDamage = false;
    WorldDamage.EnvironmentalDamageAmount = 30;
    WorldDamage.bApplyOnHit = true;
    WorldDamage.bApplyOnMiss = true;
    WorldDamage.bApplyToWorldOnHit = true;
    WorldDamage.bApplyToWorldOnMiss = true;
    WorldDamage.bHitAdjacentDestructibles = true;
    WorldDamage.PlusNumZTiles = 1;
    WorldDamage.bHitTargetTile = true;
    WorldDamage.ApplyChance = class'X2Ability_GrenadierAbilitySet'.default.SATURATION_DESTRUCTION_CHANCE;
    Template.AddMultiTargetEffect(WorldDamage);
  }
}
