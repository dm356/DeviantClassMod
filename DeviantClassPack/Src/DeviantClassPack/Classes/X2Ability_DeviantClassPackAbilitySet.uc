///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//File Title/Reference. For anyone reading, I have merged all the individual AbilitySets into two files, this shared set and a set just for GTS abilities.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class X2Ability_DeviantClassPackAbilitySet extends X2Ability config(Dev_SoldierSkills);


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//These are the lines you need to reference stuff in the config file (Dev_SoldierSkills)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

var config int BARRIERRS_COOLDOWN, BARRIERRS_RADIUS, BARRIERRS_HEALTH, BARRIERRS_DURATION;
var config int DISABLERS_COOLDOWN, DISABLERS_RANGE, DISABLERS_RADIUS, DISABLERS_STUNCHANCE;
var config int DISTORTIONFIELDRS_DEFENSE;
var config int MALAISERS_COOLDOWN, MALAISERS_RANGE, MALAISERS_RADIUS;
var config int PSIREANIMATERS_COOLDOWN;
var config int RESTORERS_COOLDOWN, RESTORERS_HEAL;
var config int TELEPORTRS_COOLDOWN;

var config int DISMANTLE_DEV_CHARGES;
var config int DISMANTLE_DEV_WORLD_DAMAGE;
var config int FULL_RECOVERY_DEV_CHARGES;
var config int SUPERCHARGE_DEV_ABILITY_CHARGES;
var config int STICKANDMOVERS_DEFENSE;
var config int STICKANDMOVERS_MOBILITY;
var config int GHOST_PROTOCOL_DEV_CHARGES;
var config int REPAIRPROTOCOLRS_AMOUNTREPAIRED;
var config int REPAIRPROTOCOLRS_CHARGES;
var config int BURN_PROTOCOL_DEV_CHARGES;
var config int BURN_PROTOCOL_DEV_DAMAGEPERTICK;
var config int BURN_PROTOCOL_DEV_SPREADPERTICK;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//This is the list of my custom perks held in this file, with all the individual code wayyyy below. Use Ctrl + F to find the perk you need.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static function array<X2DataTemplate> CreateTemplates()
{
  local array<X2DataTemplate> Templates;

  Templates.AddItem(AddDismantle_Dev());
  Templates.AddItem(AddSpecialDelivery_Dev());
  Templates.AddItem(AddBurnProtocol_Dev());
  Templates.AddItem(RepairProtocolRS());
  Templates.AddItem(AddGhostProtocol_Dev());
  Templates.AddItem(AddBoostProtocol_Dev());
  Templates.AddItem(AddFullRecovery_Dev());
  Templates.AddItem(PurePassive('HelpingHands_Dev', "img:///UILibrary_LW_PerkPack.LW_AbilityExtraConditioning", true));
  Templates.AddItem(AddResuscitate_Dev());
  Templates.AddItem(StickAndMoveRS());
  Templates.AddItem(AddNoScopeAbility_Dev());
  Templates.AddItem(AddSupercharge_Dev());

  //Perks that Require other Perks to Function correctly

  return Templates;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//All the Code is below this - CTRL + F is recommended to find what you need as it's a mess...
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//#############################################################
//Dismantle - Send the gremlin to destroy some cover
//#############################################################
static function X2AbilityTemplate AddDismantle_Dev()
{
  local X2AbilityTemplate             Template;
  local X2AbilityCost_ActionPoints    ActionPointCost;
  local X2Condition_UnitProperty      UnitPropertyCondition;
  local X2AbilityTarget_Cursor        CursorTarget;
  local X2Effect_ApplyWeaponDamage    WorldDamage;
  local X2AbilityMultiTarget_Radius   RadiusMultiTarget;
  local X2AbilityCharges              Charges;
  local X2AbilityCost_Charges         ChargeCost;

  `CREATE_X2ABILITY_TEMPLATE(Template, 'Dismantle_Dev');

  ActionPointCost = new class'X2AbilityCost_ActionPoints';
  ActionPointCost.iNumPoints = 1;
  ActionPointCost.bConsumeAllPoints = true;
  Template.AbilityCosts.AddItem(ActionPointCost);

  Charges = new class'X2AbilityCharges';
  Charges.InitialCharges = default.DISMANTLE_DEV_CHARGES;
  Template.AbilityCharges = Charges;

  ChargeCost = new class'X2AbilityCost_Charges';
  ChargeCost.NumCharges = 1;
  Template.AbilityCosts.AddItem(ChargeCost);

  Template.AbilityToHitCalc = default.DeadEye;

  Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
  Template.AddShooterEffectExclusions();

  UnitPropertyCondition = new class'X2Condition_UnitProperty';
  UnitPropertyCondition.ExcludeDead = true;
  UnitPropertyCondition.ExcludeFriendlyToSource = false;
  Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);

  CursorTarget = new class'X2AbilityTarget_Cursor';
  CursorTarget.FixedAbilityRange = 24;            //  meters
  Template.AbilityTargetStyle = CursorTarget;

  RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
  RadiusMultiTarget.fTargetRadius = 3;
  Template.AbilityMultiTargetStyle = RadiusMultiTarget;

  WorldDamage = new class'X2Effect_ApplyWeaponDamage';
  WorldDamage.EnvironmentalDamageAmount = default.DISMANTLE_DEV_WORLD_DAMAGE;
  WorldDamage.bApplyOnHit = false;
  WorldDamage.bApplyOnMiss = false;
  WorldDamage.bApplyToWorldOnHit = true;
  WorldDamage.bApplyToWorldOnMiss = true;
  Template.AddMultiTargetEffect(WorldDamage);

  Template.AddMultiTargetEffect(class'X2StatusEffects'.static.CreateDisorientedStatusEffect(true, , false));

  Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
  Template.PostActivationEvents.AddItem('ItemRecalled');

  Template.bStationaryWeapon = true;
  Template.BuildNewGameStateFn = SendGremlinToLocation_BuildGameState;
  Template.BuildVisualizationFn = CapacitorDischarge_BuildVisualization;
  Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

  Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_LIEUTENANT_PRIORITY;
  Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
  Template.AbilitySourceName = 'eAbilitySource_Perk';
  Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_capacitordischarge";
  Template.Hostility = eHostility_Offensive;
  Template.TargetingMethod = class'X2TargetingMethod_GremlinAOE';

  Template.CustomSelfFireAnim = 'NO_CapacitorDischargeA';
  Template.DamagePreviewFn = CapacitorDischargeDamagePreview;

  Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
  Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
  //BEGIN AUTOGENERATED CODE: Template Overrides 'CapacitorDischarge'
  Template.bFrameEvenWhenUnitIsHidden = true;
  Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
  //END AUTOGENERATED CODE: Template Overrides 'CapacitorDischarge'

  return Template;
}

//#############################################################
//Special Delivery - Use the gremlin to deliver a grenade
//#############################################################
static function X2AbilityTemplate AddSpecialDelivery_Dev()
{
  local X2AbilityTemplate                 Template;
  local X2AbilityCost_Ammo                AmmoCost;
  local X2AbilityCost_ActionPoints        ActionPointCost;
  local X2AbilityToHitCalc_StandardAim    StandardAim;
  local X2AbilityTarget_Cursor            CursorTarget;
  local X2AbilityMultiTarget_Radius       RadiusMultiTarget;
  local X2Condition_UnitProperty          UnitPropertyCondition;
  local X2Condition_UnitInventory         UnitInventoryCondition;
  local X2Condition_AbilitySourceWeapon   GrenadeCondition, ProximityMineCondition;
  local X2Effect_ProximityMine            ProximityMineEffect;

  `CREATE_X2ABILITY_TEMPLATE(Template, 'SpecialDelivery_Dev');

  AmmoCost = new class'X2AbilityCost_Ammo';
  AmmoCost.iAmmo = 1;
  Template.AbilityCosts.AddItem(AmmoCost);

  ActionPointCost = new class'X2AbilityCost_ActionPoints';
  ActionPointCost.iNumPoints = 1;
  ActionPointCost.bConsumeAllPoints = true;
  ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('Salvo');
  ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('TotalCombat');
  Template.AbilityCosts.AddItem(ActionPointCost);

  StandardAim = new class'X2AbilityToHitCalc_StandardAim';
  StandardAim.bIndirectFire = true;
  StandardAim.bAllowCrit = false;
  Template.AbilityToHitCalc = StandardAim;

  Template.bUseThrownGrenadeEffects = true;
  Template.bHideWeaponDuringFire = true;

  CursorTarget = new class'X2AbilityTarget_Cursor';
  CursorTarget.bRestrictToSquadsightRange = true;
  Template.AbilityTargetStyle = CursorTarget;

  RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
  RadiusMultiTarget.bUseWeaponRadius = true;
  RadiusMultiTarget.bUseWeaponBlockingCoverFlag = true;
  Template.AbilityMultiTargetStyle = RadiusMultiTarget;

  UnitPropertyCondition = new class'X2Condition_UnitProperty';
  UnitPropertyCondition.ExcludeDead = true;
  Template.AbilityShooterConditions.AddItem(UnitPropertyCondition);

  UnitInventoryCondition = new class'X2Condition_UnitInventory';
  UnitInventoryCondition.RelevantSlot = eInvSlot_SecondaryWeapon;
  UnitInventoryCondition.RequireWeaponCategory = 'gremlin';
  Template.AbilityShooterConditions.AddItem(UnitInventoryCondition);

  UnitPropertyCondition = new class'X2Condition_UnitProperty';
  UnitPropertyCondition.ExcludeDead = false;
  UnitPropertyCondition.ExcludeFriendlyToSource = false;
  UnitPropertyCondition.ExcludeHostileToSource = false;
  UnitPropertyCondition.FailOnNonUnits = false; //The grenade can affect interactive objects, others
  Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);

  GrenadeCondition = new class'X2Condition_AbilitySourceWeapon';
  GrenadeCondition.CheckGrenadeFriendlyFire = true;
  Template.AbilityMultiTargetConditions.AddItem(GrenadeCondition);

  Template.AddShooterEffectExclusions();

  Template.bRecordValidTiles = true;

  ProximityMineEffect = new class'X2Effect_ProximityMine';
  ProximityMineEffect.BuildPersistentEffect(1, true, false, false);
  ProximityMineCondition = new class'X2Condition_AbilitySourceWeapon';
  ProximityMineCondition.MatchGrenadeType = 'ProximityMine';
  ProximityMineEffect.TargetConditions.AddItem(ProximityMineCondition);
  Template.AddShooterEffect(ProximityMineEffect);

  Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

  Template.AbilitySourceName = 'eAbilitySource_Standard';
  Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
  Template.HideErrors.AddItem('AA_WeaponIncompatible');
  Template.HideErrors.AddItem('AA_CannotAfford_AmmoCost');
	Template.IconImage = "img:///UILibrary_LW_PerkPack.LW_AbilityAirdrop";
  Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_GRENADE_PRIORITY;
  Template.bUseAmmoAsChargesForHUD = true;

  Template.bShowActivation = true;
  Template.DamagePreviewFn = GrenadeDamagePreview;
  Template.TargetingMethod = class'X2TargetingMethod_Grenade';
  Template.bStationaryWeapon = true;
  Template.BuildNewGameStateFn = class'X2Ability_SpecialistAbilitySet'.static.AttachGremlinToTarget_BuildGameState;
  Template.BuildVisualizationFn = class'X2Ability_SpecialistAbilitySet'.static.GremlinSingleTarget_BuildVisualization;
  Template.bSkipPerkActivationActions = true;
  Template.PostActivationEvents.AddItem('ItemRecalled');

  // This action is considered 'hostile' and can be interrupted!
  Template.Hostility = eHostility_Offensive;
  Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

  Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
  Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
  Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.GrenadeLostSpawnIncreasePerUse;
  //BEGIN AUTOGENERATED CODE: Template Overrides 'ThrowGrenade'
  Template.bFrameEvenWhenUnitIsHidden = true;
  //END AUTOGENERATED CODE: Template Overrides 'ThrowGrenade'

  return Template;
}

//#############################################################
//Burn Protocol - Sets a target on Fire (also deals half GREMLIN Damage)
//#############################################################
static function X2AbilityTemplate AddBurnProtocol_Dev()
{
  local X2AbilityTemplate                     Template;
  local X2AbilityCost_ActionPoints            ActionPointCost;
  local X2AbilityCharges                      Charges;
  local X2AbilityCost_Charges                 ChargeCost;
  local X2Effect_ApplyWeaponDamage            BurnDamage;
  local X2Condition_UnitProperty              OrganicProperty;
  local X2Condition_Visibility                VisCondition;
  local X2Effect_Burning                      BurningEffect;
  local X2Effect_ConditionalDamageModifier    HalfDamageEffect;

  `CREATE_X2ABILITY_TEMPLATE(Template, 'BurnProtocol_Dev');

  Template.AbilitySourceName = 'eAbilitySource_Perk';
  Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_combatprotocol";
  Template.Hostility = eHostility_Offensive;
  Template.bLimitTargetIcons = true;
  Template.DisplayTargetHitChance = false;
  Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;
  Template.bStationaryWeapon = true;
  Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
  Template.bSkipPerkActivationActions = true;
  Template.bCrossClassEligible = false;

  Charges = new class 'X2AbilityCharges';
  Charges.InitialCharges = default.BURN_PROTOCOL_DEV_CHARGES;
  Template.AbilityCharges = Charges;

  ChargeCost = new class'X2AbilityCost_Charges';
  ChargeCost.NumCharges = 1;
  Template.AbilityCosts.AddItem(ChargeCost);

  Template.AbilityToHitCalc = default.DeadEye;
  Template.AbilityTargetStyle = default.SingleTargetWithSelf;
  Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

  ActionPointCost = new class'X2AbilityCost_ActionPoints';
  ActionPointCost.iNumPoints = 1;
  ActionPointCost.bConsumeAllPoints = true;
  Template.AbilityCosts.AddItem(ActionPointCost);

  Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
  Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
  Template.AddShooterEffectExclusions();

  Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitOnlyProperty);
  VisCondition = new class'X2Condition_Visibility';
  VisCondition.bRequireGameplayVisible = true;
  VisCondition.bActAsSquadsight = true;
  Template.AbilityTargetConditions.AddItem(VisCondition);

  OrganicProperty = new class'X2Condition_UnitProperty';
  OrganicProperty.ExcludeRobotic = true;
  Template.AbilityTargetConditions.AddItem(OrganicProperty);

  BurnDamage = new class'X2Effect_ApplyWeaponDamage';
  BurnDamage.DamageTypes.AddItem('Fire');
  Template.AddTargetEffect(BurnDamage);

  // EFFECT
  //  Burning // Turns 2, Chance 100
  BurningEffect = class'X2StatusEffects'.static.CreateBurningStatusEffect(default.BURN_PROTOCOL_DEV_DAMAGEPERTICK, default.BURN_PROTOCOL_DEV_SPREADPERTICK);
  BurningEffect.ApplyChance = 100;
  BurningEffect.bRemoveWhenSourceDies = true;
  Template.AddTargetEffect(BurningEffect);

  HalfDamageEffect = new class'X2Effect_ConditionalDamageModifier';
  HalfDamageEffect.bModifyOutgoingDamage = true;
  HalfDamageEffect.DamageModifier = 0.5;
  Template.AddShooterEffect(HalfDamageEffect);

  Template.bShowActivation = true;
  Template.bStationaryWeapon = true;
  Template.BuildNewGameStateFn = class'X2Ability_SpecialistAbilitySet'.static.AttachGremlinToTarget_BuildGameState;
  Template.BuildVisualizationFn = class'X2Ability_SpecialistAbilitySet'.static.GremlinSingleTarget_BuildVisualization;
  Template.bSkipPerkActivationActions = true;
  Template.PostActivationEvents.AddItem('ItemRecalled');

  Template.CustomSelfFireAnim = 'NO_CombatProtocol';
  Template.CinescriptCameraType = "Specialist_CombatProtocol";

  Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
  Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
  Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;
  //BEGIN AUTOGENERATED CODE: Template Overrides 'CombatProtocol'
  Template.bFrameEvenWhenUnitIsHidden = true;
  Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
  //END AUTOGENERATED CODE: Template Overrides 'CombatProtocol'

  //Template.AdditionalAbilities.AddItem('BurnProtocolDamage_Dev');

  return Template;
}

//#############################################################
// Repair Protocol - Repairs an allied robotic unit (SPARK)
//#############################################################
static function X2AbilityTemplate RepairProtocolRS()
{
  local X2AbilityTemplate						Template;
  local X2AbilityCharges                      Charges;
  local X2AbilityCost_Charges                 ChargeCost;
  local X2AbilityCost_ActionPoints            ActionPointCost;
  local X2Effect_ApplyMedikitHeal             HealEffect;
  local X2Condition_UnitProperty              UnitCondition;


  `CREATE_X2ABILITY_TEMPLATE(Template, 'RepairProtocolRS');

  Template.AbilitySourceName = 'eAbilitySource_Perk';
  Template.IconImage = "img:///UILibrary_DLC3Images.UIPerk_spark_repair";
  Template.Hostility = eHostility_Neutral;
  Template.bLimitTargetIcons = true;
  Template.DisplayTargetHitChance = false;
  Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;
  Template.bStationaryWeapon = true;
  Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
  Template.bSkipPerkActivationActions = true;
  Template.bCrossClassEligible = false;


  Charges = new class'X2AbilityCharges';
  Charges.InitialCharges = default.REPAIRPROTOCOLRS_CHARGES;
  Template.AbilityCharges = Charges;

  ChargeCost = new class'X2AbilityCost_Charges';
  ChargeCost.NumCharges = 1;
  Template.AbilityCosts.AddItem(ChargeCost);

  ActionPointCost = new class'X2AbilityCost_ActionPoints';
  ActionPointCost.iNumPoints = 1;
  Template.AbilityCosts.AddItem(ActionPointCost);

  HealEffect = new class'X2Effect_ApplyMedikitHeal';
  HealEffect.PerUseHP = default.REPAIRPROTOCOLRS_AMOUNTREPAIRED;
  Template.AddTargetEffect(HealEffect);

  Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
  Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
  Template.AddShooterEffectExclusions();

  UnitCondition = new class'X2Condition_UnitProperty';
  UnitCondition.ExcludeDead = true;
  UnitCondition.ExcludeHostileToSource = true;
  UnitCondition.ExcludeFriendlyToSource = false;
  UnitCondition.ExcludeFullHealth = true;
  UnitCondition.ExcludeOrganic = true;
  Template.AbilityTargetConditions.AddItem(UnitCondition);

  Template.AbilityToHitCalc = default.DeadEye;
  Template.AbilityTargetStyle = default.SingleTargetWithSelf;
  Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

  Template.bStationaryWeapon = true;
  Template.BuildNewGameStateFn = class'X2Ability_SpecialistAbilitySet'.static.AttachGremlinToTarget_BuildGameState;
  Template.BuildVisualizationFn = class'X2Ability_SpecialistAbilitySet'.static.GremlinSingleTarget_BuildVisualization;
  Template.bSkipPerkActivationActions = true;
  Template.PostActivationEvents.AddItem('ItemRecalled');
  Template.bShowActivation = true;

  Template.CustomSelfFireAnim = 'NO_RevivalProtocol';
  //Template.CinescriptCameraType = "Specialist_CombatProtocol";

  return Template;
}


//#############################################################
//Ghost Protocol - Conceal an ally
//#############################################################

static function X2AbilityTemplate AddGhostProtocol_Dev()
{
  local X2AbilityTemplate						Template;
  local X2AbilityCost_ActionPoints        ActionPointCost;
  local X2AbilityCharges                      Charges;
  local X2AbilityCost_Charges             ChargeCost;
  local X2Condition_UnitProperty          UnitPropertyCondition;
  local X2Effect_RangerStealth                StealthEffect;
  local X2Condition_UnitEffects				NotCarryingCondition;
  local X2Condition_Visibility                			VisCondition;

  `CREATE_X2ABILITY_TEMPLATE(Template, 'GhostProtocol_Dev');

  Template.AbilitySourceName = 'eAbilitySource_Perk';
  Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_stealth";
  Template.Hostility = eHostility_Neutral;
  Template.bLimitTargetIcons = true;
  Template.DisplayTargetHitChance = false;
  Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;
  Template.bStationaryWeapon = true;
  Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
  Template.bSkipPerkActivationActions = true;
  Template.bCrossClassEligible = false;

  Charges = new class 'X2AbilityCharges';
  Charges.InitialCharges = 1;
  Template.AbilityCharges = Charges;

  ChargeCost = new class'X2AbilityCost_Charges';
  ChargeCost.NumCharges = default.GHOST_PROTOCOL_DEV_CHARGES;
  Template.AbilityCosts.AddItem(ChargeCost);

  Template.AbilityToHitCalc = default.DeadEye;
  Template.AbilityTargetStyle = default.SimpleSingleTarget;
  Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

  ActionPointCost = new class'X2AbilityCost_ActionPoints';
  ActionPointCost.iNumPoints = 1;
  ActionPointCost.bConsumeAllPoints = false;
  Template.AbilityCosts.AddItem(ActionPointCost);

  Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
  VisCondition = new class'X2Condition_Visibility';
  VisCondition.bRequireGameplayVisible = true;
  VisCondition.bActAsSquadsight = true;
  Template.AbilityTargetConditions.AddItem(VisCondition);
  Template.AddShooterEffectExclusions();

  NotCarryingCondition = new class'X2Condition_UnitEffects';
  NotCarryingCondition.AddExcludeEffect(class'X2Ability_CarryUnit'.default.CarryUnitEffectName, 'AA_CarryingUnit');
  NotCarryingCondition.AddExcludeEffect(class'X2AbilityTemplateManager'.default.BoundName, 'AA_UnitIsBound');
  Template.AbilityTargetConditions.AddItem(NotCarryingCondition);

  UnitPropertyCondition = new class'X2Condition_UnitProperty';
  UnitPropertyCondition.ExcludeDead = true;
  UnitPropertyCondition.ExcludeHostileToSource = true;
  UnitPropertyCondition.ExcludeFriendlyToSource = false;
  UnitPropertyCondition.RequireSquadmates = true;
  UnitPropertyCondition.ExcludeConcealed = true;
  UnitPropertyCondition.ExcludeCivilian = true;
  UnitPropertyCondition.ExcludeImpaired = true;
  UnitPropertyCondition.FailOnNonUnits = true;
  UnitPropertyCondition.IsAdvent = false;
  UnitPropertyCondition.ExcludePanicked = true;
  UnitPropertyCondition.ExcludeAlien = true;
  UnitPropertyCondition.IsBleedingOut = false;
  UnitPropertyCondition.IsConcealed = false;
  UnitPropertyCondition.ExcludeStunned = true;
  UnitPropertyCondition.IsImpaired = false;
  Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);
  //Template.AbilityTargetConditions.AddItem(new class'X2Condition_Stealth');

  StealthEffect = new class'X2Effect_RangerStealth';
  StealthEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
  StealthEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true);
  StealthEffect.bRemoveWhenTargetConcealmentBroken = true;
  Template.AddTargetEffect(StealthEffect);

  Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

  Template.bShowActivation = true;
  Template.PostActivationEvents.AddItem('ItemRecalled');
  //Template.CustomSelfFireAnim = 'NO_CombatProtocol';
  Template.ActivationSpeech = 'DefensiveProtocol';
  Template.TargetHitSpeech = 'ActivateConcealment';
  Template.BuildNewGameStateFn = class'X2Ability_SpecialistAbilitySet'.static.AttachGremlinToTarget_BuildGameState;
  Template.BuildVisualizationFn = class'X2Ability_SpecialistAbilitySet'.static.GremlinSingleTarget_BuildVisualization;

  Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;

  return Template;
}

//#############################################################
//Boost Protocol - Give Aim, Crit, and Mobility boost to a robotic ally
//#############################################################

static function X2AbilityTemplate AddBoostProtocol_Dev()
{
  local X2AbilityTemplate                 Template;
  local X2AbilityCost_ActionPoints        ActionPointCost;
  local X2AbilityCharges                  Charges;
  local X2AbilityCost_Charges             ChargeCost;
  local X2Condition_UnitProperty          UnitPropertyCondition;
  local X2Effect_PersistentStatChange     StatEffect;
  //local bool								bInfiniteDuration;

  `CREATE_X2ABILITY_TEMPLATE(Template, 'BoostProtocol_Dev');

  Template.AbilitySourceName = 'eAbilitySource_Perk';
  Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_defensiveprotocol";
  Template.Hostility = eHostility_Neutral;
  Template.bLimitTargetIcons = true;
  Template.DisplayTargetHitChance = false;
  Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
  Template.bStationaryWeapon = true;
  Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
  Template.bSkipPerkActivationActions = true;
  Template.bCrossClassEligible = false;

  Charges = new class 'X2AbilityCharges';
  Charges.InitialCharges = 1;
  Template.AbilityCharges = Charges;

  ChargeCost = new class'X2AbilityCost_Charges';
  ChargeCost.NumCharges = 1;
  Template.AbilityCosts.AddItem(ChargeCost);

  Template.AbilityToHitCalc = default.DeadEye;
  Template.AbilityTargetStyle = default.SimpleSingleTarget;
  Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

  ActionPointCost = new class'X2AbilityCost_ActionPoints';
  ActionPointCost.iNumPoints = 1;
  ActionPointCost.bConsumeAllPoints = false;
  Template.AbilityCosts.AddItem(ActionPointCost);

  Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
  Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
  Template.AddShooterEffectExclusions();

  UnitPropertyCondition = new class'X2Condition_UnitProperty';
  UnitPropertyCondition.ExcludeDead = true;
  UnitPropertyCondition.ExcludeFriendlyToSource = false;
  UnitPropertyCondition.ExcludeHostileToSource = true;
  UnitPropertyCondition.ExcludeUnrevealedAI = true;
  //UnitPropertyCondition.ExcludeConcealed = true;
  UnitPropertyCondition.ExcludeAlive = false;
  UnitPropertyCondition.ExcludePanicked = true;
  UnitPropertyCondition.ExcludeRobotic = false;
  UnitPropertyCondition.ExcludeOrganic = true;
  UnitPropertyCondition.ExcludeStunned = true;
  UnitPropertyCondition.FailOnNonUnits = true;
  UnitPropertyCondition.ExcludeTurret = false;
  UnitPropertyCondition.RequireWithinRange = true;
  Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

  StatEffect = new class'X2Effect_PersistentStatChange';
  StatEffect.BuildPersistentEffect(1, true, false, false, eGameRule_PlayerTurnBegin);
  StatEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,,Template.AbilitySourceName);
  StatEffect.AddPersistentStatChange(eStat_Offense, class'X2Ability_HackRewards'.default.CONTROL_ROBOT_AIM_BONUS);
  StatEffect.AddPersistentStatChange(eStat_CritChance, class'X2Ability_HackRewards'.default.CONTROL_ROBOT_CRIT_BONUS);
  //StatEffect.AddPersistentStatChange(eStat_Mobility, class'X2Ability_HackRewards'.default.CONTROL_ROBOT_MOBILITY_BONUS); // Set to zero by default
  Template.AddTargetEffect(StatEffect);

  Template.bShowActivation = true;
  Template.PostActivationEvents.AddItem('ItemRecalled');
  //Template.CustomSelfFireAnim = 'NO_CombatProtocol';
  Template.ActivationSpeech = 'DefensiveProtocol';
  Template.BuildNewGameStateFn = class'X2Ability_SpecialistAbilitySet'.static.AttachGremlinToTarget_BuildGameState;
  Template.BuildVisualizationFn = class'X2Ability_SpecialistAbilitySet'.static.GremlinSingleTarget_BuildVisualization;

  Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;

  return Template;
}

//#############################################################
//Full Recovery - Restore a unit to full health and remove all negative statuses
//#############################################################

static function X2AbilityTemplate AddFullRecovery_Dev()
{
  local X2AbilityTemplate                 Template;
  local X2AbilityCost_ActionPoints        ActionPointCost;
  local X2AbilityCharges                  Charges;
  local X2AbilityCost_Charges             ChargeCost;
  local X2AbilityTarget_Single            SingleTarget;
  local X2Condition_UnitProperty          UnitPropertyCondition;
  //local X2Condition_UnitStatCheck         UnitStatCheckCondition;
  //local X2Condition_UnitEffects           UnitEffectsCondition;
  local X2Effect_ApplyMedikitHeal         MedikitHeal;
  local X2Effect_RemoveEffects            RemoveEffects;

  `CREATE_X2ABILITY_TEMPLATE(Template, 'FullRecovery_Dev');

  Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_medicalprotocol";
  Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;
  Template.Hostility = eHostility_Defensive;
  Template.bDisplayInUITooltip = false;
  Template.bLimitTargetIcons = true;
  Template.AbilitySourceName = 'eAbilitySource_Perk';

  ActionPointCost = new class'X2AbilityCost_ActionPoints';
  ActionPointCost.iNumPoints = 1;
  Template.AbilityCosts.AddItem(ActionPointCost);

  Charges = new class'X2AbilityCharges';
  Charges.InitialCharges = default.FULL_RECOVERY_DEV_CHARGES;
  Template.AbilityCharges = Charges;

  ChargeCost = new class'X2AbilityCost_Charges';
  ChargeCost.NumCharges = 1;
  Template.AbilityCosts.AddItem(ChargeCost);

  Template.AbilityToHitCalc = default.DeadEye;

  SingleTarget = new class'X2AbilityTarget_Single';
  SingleTarget.bIncludeSelf = false;
  SingleTarget.bShowAOE = true;
  Template.AbilityTargetStyle = SingleTarget;

  Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

  // Shooter Condition
  Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
  Template.AddShooterEffectExclusions();

  UnitPropertyCondition = new class'X2Condition_UnitProperty';
  //UnitPropertyCondition.ExcludeDead = false; //Hack: See following comment.
  UnitPropertyCondition.ExcludeDead = true;
  UnitPropertyCondition.ExcludeHostileToSource = true;
  UnitPropertyCondition.ExcludeFriendlyToSource = false;
  UnitPropertyCondition.ExcludeFullHealth = true;
  UnitPropertyCondition.ExcludeRobotic = true;
  UnitPropertyCondition.ExcludeTurret = true;
  UnitPropertyCondition.RequireWithinRange = true;
  //UnitPropertyCondition.WithinRange = class'X2Item_DefaultUtilityItems'.default.MEDIKIT_RANGE_TILES;
  UnitPropertyCondition.WithinRange = 192;
  Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

  //Hack: Do this instead of ExcludeDead, to only exclude properly-dead or bleeding-out units.
  //UnitStatCheckCondition = new class'X2Condition_UnitStatCheck';
  //UnitStatCheckCondition.AddCheckStat(eStat_HP, 0, eCheck_GreaterThan);
  //Template.AbilityTargetConditions.AddItem(UnitStatCheckCondition);

  //UnitEffectsCondition = new class'X2Condition_UnitEffects';
  //UnitEffectsCondition.AddExcludeEffect(class'X2StatusEffects'.default.BleedingOutName, 'AA_UnitIsImpaired');
  //Template.AbilityTargetConditions.AddItem(UnitEffectsCondition);


  MedikitHeal = new class'X2Effect_ApplyMedikitHeal';
  MedikitHeal.PerUseHP = 30;
  Template.AddTargetEffect(MedikitHeal);

  //Template.AddTargetEffect(RemoveAllEffectsByDamageType());
  Template.AddTargetEffect(class'X2Ability_SpecialistAbilitySet'.static.RemoveAdditionalEffectsForRevivalProtocolAndRestorativeMist());

  RemoveEffects = new class'X2Effect_RemoveEffects';
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2StatusEffects'.default.BleedingOutName);
  Template.AddTargetEffect(RemoveEffects);

  Template.AddTargetEffect(new class'X2Effect_RestoreActionPoints');      //  put the unit back to full actions

  Template.ActivationSpeech = 'HealingAlly';

  Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
  Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

  Template.bShowPostActivation = true;
  //BEGIN AUTOGENERATED CODE: Template Overrides 'Revive'
  Template.bFrameEvenWhenUnitIsHidden = true;
  Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
  Template.CustomFireAnim = 'HL_Revive';
  //END AUTOGENERATED CODE: Template Overrides 'Revive'

  Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;

  return Template;
}

//#############################################################
//Supercharge - Give an additional action to a robot ally
//#############################################################

static function X2AbilityTemplate AddSupercharge_Dev()
{
  local X2AbilityTemplate					Template;
  local X2AbilityCost_ActionPoints		ActionPointCost;
  local X2AbilityCost_Charges				ChargeCost;
  local X2AbilityCharges				Charges;
  local X2Condition_UnitEffects			CommandRestriction;
  local X2Effect_GrantActionPoints		ActionPointEffect;
  local X2Effect_Persistent				ActionPointPersistEffect;
  local X2Condition_UnitProperty			UnitPropertyCondition;
  local X2Condition_UnitActionPoints		ValidTargetCondition;


  `CREATE_X2ABILITY_TEMPLATE(Template, 'Supercharge_Dev');

  Template.AbilitySourceName = 'eAbilitySource_Perk';
  Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_overdrive";
  Template.Hostility = eHostility_Neutral;
  Template.bLimitTargetIcons = true;
  Template.DisplayTargetHitChance = false;
  Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY;
  //Template.bStationaryWeapon = true;
  Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
  //Template.bSkipPerkActivationActions = true;
  Template.bCrossClassEligible = false;

  Charges = new class 'X2AbilityCharges';
  Charges.InitialCharges = default.SUPERCHARGE_DEV_ABILITY_CHARGES;
  Template.AbilityCharges = Charges;

  ChargeCost = new class'X2AbilityCost_Charges';
  ChargeCost.NumCharges = 1;
  Template.AbilityCosts.AddItem(ChargeCost);

  Template.AbilityToHitCalc = default.DeadEye;
  Template.AbilityTargetStyle = default.SimpleSingleTarget;
  Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

  ActionPointCost = new class'X2AbilityCost_ActionPoints';
  ActionPointCost.iNumPoints = 1;
  ActionPointCost.bConsumeAllPoints = true;
  Template.AbilityCosts.AddItem(ActionPointCost);

  Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
  Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
  Template.AddShooterEffectExclusions();


  ValidTargetCondition = new class'X2Condition_UnitActionPoints';
  ValidTargetCondition.AddActionPointCheck(0,class'X2CharacterTemplateManager'.default.OverwatchReserveActionPoint,true,eCheck_LessThanOrEqual);
  Template.AbilityTargetConditions.AddItem(ValidTargetCondition);

  ValidTargetCondition = new class'X2Condition_UnitActionPoints';
  ValidTargetCondition.AddActionPointCheck(0,'Suppression',true,eCheck_LessThanOrEqual);
  Template.AbilityTargetConditions.AddItem(ValidTargetCondition);

  ValidTargetCondition = new class'X2Condition_UnitActionPoints';
  ValidTargetCondition.AddActionPointCheck(0,class'X2Ability_SharpshooterAbilitySet'.default.KillZoneReserveType,true,eCheck_LessThanOrEqual);
  Template.AbilityTargetConditions.AddItem(ValidTargetCondition);

  ValidTargetCondition = new class'X2Condition_UnitActionPoints';
  ValidTargetCondition.AddActionPointCheck(0,class'X2CharacterTemplateManager'.default.OverwatchReserveActionPoint,true,eCheck_LessThanOrEqual);
  Template.AbilityTargetConditions.AddItem(ValidTargetCondition);

  //ValidTargetCondition = new class'X2Condition_UnitActionPoints';
  //ValidTargetCondition.AddActionPointCheck(0,class'X2CharacterTemplateManager'.default.StandardActionPoint,false,eCheck_LessThanOrEqual);
  //Template.AbilityTargetConditions.AddItem(ValidTargetCondition);

  ValidTargetCondition = new class'X2Condition_UnitActionPoints';
  ValidTargetCondition.AddActionPointCheck(0,class'X2CharacterTemplateManager'.default.PistolOverwatchReserveActionPoint,true,eCheck_LessThanOrEqual);
  Template.AbilityTargetConditions.AddItem(ValidTargetCondition);

  ValidTargetCondition = new class'X2Condition_UnitActionPoints';
  ValidTargetCondition.AddActionPointCheck(0,class'X2CharacterTemplateManager'.default.RunAndGunActionPoint,false,eCheck_LessThanOrEqual);
  Template.AbilityTargetConditions.AddItem(ValidTargetCondition);

  //ValidTargetCondition = new class'X2Condition_UnitActionPoints';
  //ValidTargetCondition.AddActionPointCheck(0,class'X2CharacterTemplateManager'.default.MoveActionPoint,false,eCheck_LessThanOrEqual);
  //Template.AbilityTargetConditions.AddItem(ValidTargetCondition);

  UnitPropertyCondition = new class'X2Condition_UnitProperty';
  UnitPropertyCondition.ExcludeDead = true;
  UnitPropertyCondition.ExcludeFriendlyToSource = false;
  UnitPropertyCondition.ExcludeHostileToSource = true;
  UnitPropertyCondition.ExcludeUnrevealedAI = true;
  //UnitPropertyCondition.ExcludeConcealed = true;
  UnitPropertyCondition.ExcludeAlive = false;
  UnitPropertyCondition.ExcludePanicked = true;
  UnitPropertyCondition.ExcludeRobotic = false;
  UnitPropertyCondition.ExcludeOrganic = true;
  UnitPropertyCondition.ExcludeStunned = true;
  UnitPropertyCondition.FailOnNonUnits = true;
  UnitPropertyCondition.ExcludeTurret = false;
  UnitPropertyCondition.RequireWithinRange = true;
  Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

  CommandRestriction = new class'X2Condition_UnitEffects';
  CommandRestriction.AddExcludeEffect('Command', 'AA_UnitIsCommanded');
  CommandRestriction.AddExcludeEffect('Supercharged_Dev', 'AA_UnitIsCommanded');
  CommandRestriction.AddExcludeEffect('HunkerDown', 'AA_UnitIsCommanded');
  CommandRestriction.AddExcludeEffect(class'X2StatusEffects'.default.BleedingOutName, 'AA_UnitIsImpaired');
  Template.AbilityTargetConditions.AddItem(CommandRestriction);

  ActionPointEffect = new class'X2Effect_GrantActionPoints';
  ActionPointEffect.NumActionPoints = 1;
  ActionPointEffect.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
  Template.AddTargetEffect(ActionPointEffect);

  ActionPointPersistEffect = new class'X2Effect_Persistent';
  ActionPointPersistEffect.EffectName = 'Supercharged_Dev';
  ActionPointPersistEffect.BuildPersistentEffect(1, false, true, false, 8);
  ActionPointPersistEffect.bRemoveWhenTargetDies = true;
  Template.AddTargetEffect(ActionPointPersistEffect);

  // Targeting Method
  Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
  Template.bUsesFiringCamera = true;
  Template.CinescriptCameraType = "StandardGunFiring";
  Template.ActivationSpeech = 'Inspire';
  Template.bUniqueSource = true;

  // MAKE IT LIVE!
  Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
  Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
  Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

  Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;

  return Template;
}

//#############################################################
//Stick and Move - Mobility & Defense Increase (Richards)
//#############################################################

static function X2AbilityTemplate StickAndMoveRS()
{
  local X2AbilityTemplate						Template;
  local X2Effect_PersistentStatChange         Mobility;
  local X2Effect_PersistentStatChange         DefenseSM;

  // Icon Properties
  `CREATE_X2ABILITY_TEMPLATE(Template, 'StickAndMoveRS');
  Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_shieldprojection";

  Template.AbilitySourceName = 'eAbilitySource_Perk';
  Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
  Template.Hostility = eHostility_Neutral;

  Template.AbilityToHitCalc = default.DeadEye;
  Template.AbilityTargetStyle = default.SelfTarget;
  Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

  Mobility = new class'X2Effect_PersistentStatChange';
  Mobility.AddPersistentStatChange(eStat_Mobility, default.STICKANDMOVERS_MOBILITY);
  Mobility.BuildPersistentEffect(1, true, false, false);
  Mobility.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,,Template.AbilitySourceName);
  Template.AddTargetEffect(Mobility);
  Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, default.STICKANDMOVERS_MOBILITY);

  DefenseSM = new class'X2Effect_PersistentStatChange';
  DefenseSM.AddPersistentStatChange(eStat_Defense, default.STICKANDMOVERS_DEFENSE);
  DefenseSM.BuildPersistentEffect(1, true, false, false);
  //DefenseSM.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,,Template.AbilitySourceName);
  Template.AddTargetEffect(DefenseSM);
  Template.SetUIStatMarkup(class'XLocalizedData'.default.DefenseLabel, eStat_Defense, default.STICKANDMOVERS_DEFENSE);

  Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
  //  NOTE: No visualization on purpose!

  //AWC Allow
  Template.bCrossClassEligible = true;

  return Template;
}

//#############################################################
//Resuscitate - Revival procotol without a gremlin
//#############################################################

static function X2AbilityTemplate AddResuscitate_Dev()
{
  local X2AbilityTemplate                 Template;
  local X2AbilityCost_ActionPoints        ActionPointCost;
  local X2AbilityTarget_Single            SingleTarget;
  local X2AbilityCost_Charges             ChargeCost;
  local X2AbilityCharges_GremlinHeal                  Charges;
  local X2Condition_UnitProperty          TargetCondition;
  local X2Effect_RemoveEffects RemoveEffects;

  `CREATE_X2ABILITY_TEMPLATE(Template, 'Resuscitate_Dev');

  Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_gremlinheal";
  Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;
  Template.Hostility = eHostility_Defensive;
  Template.bDisplayInUITooltip = true;
  Template.bLimitTargetIcons = true;
  Template.AbilitySourceName = 'eAbilitySource_Perk';

  ActionPointCost = new class'X2AbilityCost_ActionPoints';
  ActionPointCost.iNumPoints = 1;
  Template.AbilityCosts.AddItem(ActionPointCost);

  // Use same formula that does gremlin heal charges to determine Resuscitate charges
  Charges = new class'X2AbilityCharges_GremlinHeal';
  Charges.bStabilize = false;
  Template.AbilityCharges = Charges;

  ChargeCost = new class'X2AbilityCost_Charges';
  ChargeCost.NumCharges = 1;
  Template.AbilityCosts.AddItem(ChargeCost);

  Template.AbilityToHitCalc = default.DeadEye;

  SingleTarget = new class'X2AbilityTarget_Single';
  SingleTarget.bIncludeSelf = false;
  SingleTarget.bShowAOE = true;
  Template.AbilityTargetStyle = SingleTarget;

  Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
  Template.AddShooterEffectExclusions();

  Template.AbilityTargetConditions.AddItem(new class'X2Condition_RevivalProtocol');

  RemoveEffects = new class'X2Effect_RemoveEffects';
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.PanickedName);
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2StatusEffects'.default.UnconsciousName);
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.ConfusedName);
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.StunnedName);
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.DazedName);
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.ObsessedName);
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.BerserkName);
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.ShatteredName);

  Template.AddTargetEffect(RemoveEffects);
  Template.AddTargetEffect(new class'X2Effect_RestoreActionPoints');      //  put the unit back to full actions
  TargetCondition = new class'X2Condition_UnitProperty';
  TargetCondition.ExcludeDead = true;
  TargetCondition.ExcludeHostileToSource = true;
  TargetCondition.ExcludeFriendlyToSource = false;
  TargetCondition.ExcludeFullHealth = true;
  TargetCondition.ExcludeRobotic = true;
  TargetCondition.ExcludeTurret = true;
  TargetCondition.RequireWithinRange = true;
  //TargetCondition.WithinRange = class'X2Item_DefaultUtilityItems'.default.MEDIKIT_RANGE_TILES;
  TargetCondition.WithinRange = 192;
  Template.AbilityTargetConditions.AddItem(TargetCondition);

  Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

  Template.ActivationSpeech = 'HealingAlly';

  Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
  Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

  Template.CustomSelfFireAnim = 'HL_Revive';

  Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;

  Template.bShowPostActivation = true;
  //BEGIN AUTOGENERATED CODE: Template Overrides 'Revive'
  Template.bFrameEvenWhenUnitIsHidden = true;
  Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
  Template.CustomFireAnim = 'HL_Revive';
  //END AUTOGENERATED CODE: Template Overrides 'Revive'

  Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;

  return Template;
}


//#############################################################
//No Scope - Gives a soldier Snap shot if weilding a sniper rifle and Light Em Up if weilding anything else
//#############################################################
static function X2AbilityTemplate AddNoScopeAbility_Dev()
{
  local X2AbilityTemplate                 Template;

  Template = PurePassive('NoScope_Dev', "img:///UILibrary_LW_PerkPack.LW_AbilitySnapShot", false, 'eAbilitySource_Standard', true);
  Template.AdditionalAbilities.AddItem('LW2WotC_SnapShot');
  Template.AdditionalAbilities.AddItem('LW2WotC_LightEmUp');

  return Template;
}

//#############################################################
//Barrier - Creates an energy shield around nearby allies, granting some damage reduction
//#############################################################
static function X2DataTemplate BarrierRS()
{
  local X2AbilityTemplate Template;
  local X2AbilityCost_ActionPoints ActionPointCost;
  local X2AbilityCooldown             Cooldown;
  local X2Condition_UnitProperty UnitPropertyCondition;
  local X2AbilityTrigger_PlayerInput InputTrigger;
  local X2Effect_PersistentStatChange ShieldedEffect;
  local X2AbilityMultiTarget_Radius MultiTarget;

  Template= new(None, string('BarrierRS')) class'X2AbilityTemplate'; Template.SetTemplateName('BarrierRS');;;
  Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield";

  Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
  Template.AbilitySourceName = 'eAbilitySource_Psionic';
  Template.Hostility = eHostility_Defensive;
  Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;

  ActionPointCost = new class'X2AbilityCost_ActionPoints';
  ActionPointCost.iNumPoints = 1;
  ActionPointCost.bConsumeAllPoints = true;
  Template.AbilityCosts.AddItem(ActionPointCost);

  Cooldown = new class'X2AbilityCooldown';
  Cooldown.iNumTurns = default.BARRIERRS_COOLDOWN;
  Template.AbilityCooldown = Cooldown;

  //Can't use while dead
  Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
  Template.AddShooterEffectExclusions();

  // Add dead eye to guarantee
  Template.AbilityToHitCalc = default.DeadEye;
  Template.AbilityTargetStyle = default.SelfTarget;

  // Multi target
  MultiTarget = new class'X2AbilityMultiTarget_Radius';
  MultiTarget.fTargetRadius = default.BARRIERRS_RADIUS;
  MultiTarget.bIgnoreBlockingCover = true;
  Template.AbilityMultiTargetStyle = MultiTarget;

  InputTrigger = new class'X2AbilityTrigger_PlayerInput';
  Template.AbilityTriggers.AddItem(InputTrigger);

  // The Targets must be within the AOE, LOS, and friendly
  UnitPropertyCondition = new class'X2Condition_UnitProperty';
  UnitPropertyCondition.ExcludeDead = true;
  UnitPropertyCondition.ExcludeFriendlyToSource = false;
  UnitPropertyCondition.ExcludeHostileToSource = true;
  UnitPropertyCondition.ExcludeCivilian = true;
  UnitPropertyCondition.FailOnNonUnits = true;
  Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);

  // Friendlies in the radius receives a shield receives a shield
  ShieldedEffect = CreateShieldedEffect(Template.LocFriendlyName, Template.GetMyLongDescription(), default.BARRIERRS_HEALTH);

  Template.AddShooterEffect(ShieldedEffect);
  Template.AddMultiTargetEffect(ShieldedEffect);

  Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
  Template.BuildVisualizationFn = Shielded_BuildVisualization;
  Template.CinescriptCameraType = "Psionic_FireAtUnit";

  return Template;
}

static function X2Effect_PersistentStatChange CreateShieldedEffect(string FriendlyName, string LongDescription, int ShieldHPAmount)
{
  local X2Effect_EnergyShield ShieldedEffect;

  ShieldedEffect = new class'X2Effect_EnergyShield';
  ShieldedEffect.BuildPersistentEffect(default.BARRIERRS_DURATION, false, true, , eGameRule_PlayerTurnEnd);
  ShieldedEffect.SetDisplayInfo(ePerkBuff_Bonus, FriendlyName, LongDescription, "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield", true);
  ShieldedEffect.AddPersistentStatChange(eStat_ShieldHP, ShieldHPAmount);
  ShieldedEffect.EffectRemovedVisualizationFn = OnShieldRemoved_BuildVisualization;

  return ShieldedEffect;
}

simulated function OnShieldRemoved_BuildVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
  local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;

  if (XGUnit(ActionMetadata.VisualizeActor).IsAlive())
  {
    SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
    SoundAndFlyOver.SetSoundAndFlyOverParameters(None, class'XLocalizedData'.default.ShieldRemovedMsg, '', eColor_Bad, , 0.75, true);
  }
}

simulated function Shielded_BuildVisualization(XComGameState VisualizeGameState)
{
  local XComGameStateHistory History;
  local XComGameStateContext_Ability  Context;
  local StateObjectReference InteractingUnitRef;
  local VisualizationActionMetadata EmptyTrack;
  local VisualizationActionMetadata ActionMetadata;
  local X2Action_PlayAnimation PlayAnimationAction;

  History = class'XComGameStateHistory'.static.GetGameStateHistory();

  Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
  InteractingUnitRef = Context.InputContext.SourceObject;

  //Configure the visualization track for the shooter
  //****************************************************************************************
  ActionMetadata = EmptyTrack;
  ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
  ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
  ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

  PlayAnimationAction = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
  PlayAnimationAction.Params.AnimName = 'HL_EnergyShield';

}

//#############################################################
//Disable - Disable enemy weapons in an AoE radius with a Stun chance
//#############################################################

static function X2AbilityTemplate DisableRS()
{
  local X2AbilityTemplate                 Template;
  local X2AbilityCost_ActionPoints        ActionPointCost;
  local X2AbilityTarget_Cursor            CursorTarget;
  local X2AbilityMultiTarget_Radius       RadiusMultiTarget;
  local X2AbilityCooldown                 Cooldown;
  local X2Effect_DisableWeapon			DisableWeapon;
  local X2Effect_Stunned					StunnedEffect;

  Template= new(None, string('DisableRS')) class'X2AbilityTemplate'; Template.SetTemplateName('DisableRS');;;

  ActionPointCost = new class'X2AbilityCost_ActionPoints';
  ActionPointCost.iNumPoints = 1;
  ActionPointCost.bConsumeAllPoints = true;
  Template.AbilityCosts.AddItem(ActionPointCost);

  Cooldown = new class'X2AbilityCooldown';
  Cooldown.iNumTurns = default.DISABLERS_COOLDOWN;
  Template.AbilityCooldown = Cooldown;

  Template.AbilityToHitCalc = default.DeadEye;

  Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
  Template.AddShooterEffectExclusions();

  CursorTarget = new class'X2AbilityTarget_Cursor';
  CursorTarget.bRestrictToSquadsightRange = true;
  CursorTarget.FixedAbilityRange = default.DISABLERS_RANGE;
  Template.AbilityTargetStyle = CursorTarget;

  RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
  RadiusMultiTarget.fTargetRadius = default.DISABLERS_RADIUS;
  RadiusMultiTarget.bIgnoreBlockingCover = true;
  Template.AbilityMultiTargetStyle = RadiusMultiTarget;

  DisableWeapon = new class'X2Effect_DisableWeapon';
  DisableWeapon.TargetConditions.AddItem(default.LivingTargetUnitOnlyProperty);
  Template.AddMultiTargetEffect(DisableWeapon);

  StunnedEffect = class'X2StatusEffects'.static.CreateStunnedStatusEffect(2, default.DISABLERS_STUNCHANCE); // # turns, % chance
  StunnedEffect.bRemoveWhenSourceDies = true;
  Template.AddMultiTargetEffect(StunnedEffect);

  Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

  Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
  Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_psibomb";
  Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
  Template.AbilitySourceName = 'eAbilitySource_Psionic';
  Template.bShowActivation = true;
  Template.CustomFireAnim = 'HL_Psi_MindControl';

  Template.TargetingMethod = class'X2TargetingMethod_VoidRift';

  Template.ActivationSpeech = 'VoidRift';

  Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
  Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
  Template.CinescriptCameraType = "Psionic_FireAtLocation";

  return Template;
}

//#############################################################
//Malaise - Poisons a target, duration is based on targets willpower
//#############################################################
static function X2AbilityTemplate MalaiseRS()
{
  local X2AbilityTemplate             Template;
  local X2AbilityCost_ActionPoints    ActionPointCost;
  local X2AbilityTarget_Cursor        CursorTarget;
  local X2AbilityMultiTarget_Radius   RadiusMultiTarget;
  local X2AbilityCooldown             Cooldown;
  local X2Condition_UnitProperty      UnitPropertyCondition;
  local X2Effect_PersistentStatChange		DisorientedEffect;

  Template= new(None, string('MalaiseRS')) class'X2AbilityTemplate'; Template.SetTemplateName('MalaiseRS');;;

  ActionPointCost = new class'X2AbilityCost_ActionPoints';
  ActionPointCost.iNumPoints = 1;
  ActionPointCost.bConsumeAllPoints = true;
  Template.AbilityCosts.AddItem(ActionPointCost);

  // Cooldown on the ability
  Cooldown = new class'X2AbilityCooldown';
  Cooldown.iNumTurns = default.MALAISERS_COOLDOWN;
  Template.AbilityCooldown = Cooldown;

  Template.AbilityToHitCalc = default.DeadEye;

  Template.AddMultiTargetEffect(class'X2StatusEffects'.static.CreatePoisonedStatusEffect());
  Template.AddMultiTargetEffect(new class'X2Effect_ApplyPoisonToWorld');

  DisorientedEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect();
  DisorientedEffect.iNumTurns = 2;
  Template.AddMultiTargetEffect(DisorientedEffect);

  CursorTarget = new class'X2AbilityTarget_Cursor';
  CursorTarget.bRestrictToWeaponRange = true;
  CursorTarget.FixedAbilityRange = default.MALAISERS_RANGE;
  Template.AbilityTargetStyle = CursorTarget;

  RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
  RadiusMultiTarget.fTargetRadius = default.MALAISERS_RADIUS;
  RadiusMultiTarget.bIgnoreBlockingCover = true;
  Template.AbilityMultiTargetStyle = RadiusMultiTarget;

  UnitPropertyCondition = new class'X2Condition_UnitProperty';
  UnitPropertyCondition.ExcludeDead = true;
  Template.AbilityShooterConditions.AddItem(UnitPropertyCondition);
  Template.AddShooterEffectExclusions();

  Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

  Template.AbilitySourceName = 'eAbilitySource_Psionic';
  Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
  Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_viper_poisonspit";
  Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;
  Template.bShowActivation = true;

  Template.CustomFireAnim = 'HL_Psi_MindControl';
  Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
  Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
  Template.CinescriptCameraType = "Psionic_FireAtUnit";

  Template.TargetingMethod = class'X2TargetingMethod_VoidRift';

  Template.ActivationSpeech = 'Insanity';

  // This action is considered 'hostile' and can be interrupted!
  Template.Hostility = eHostility_Offensive;
  Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

  return Template;
}

//#############################################################
//Psi-Reanimate - Reanimate a nearby humanoid corpse into a shambling Zombie under your control
//#############################################################
static function X2AbilityTemplate PsiReanimateRS()
{
  local X2AbilityTemplate Template;
  local X2AbilityCost_ActionPoints ActionPointCost;
  local X2AbilityCooldown Cooldown;
  local X2Condition_UnitProperty UnitPropertyCondition;
  local X2Condition_Visibility TargetVisibilityCondition;
  local X2Effect_SpawnPsiZombie SpawnZombieEffect;
  local X2Condition_UnitValue UnitValue;
  local X2Condition_UnitEffects ExcludeEffects;

  Template= new(None, string('PsiReanimateRS')) class'X2AbilityTemplate'; Template.SetTemplateName('PsiReanimateRS');;;
  Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_sectoid_psireanimate";

  Template.AbilitySourceName = 'eAbilitySource_Psionic';
  Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
  Template.Hostility = eHostility_Offensive;

  // Cost of the ability
  ActionPointCost = new class'X2AbilityCost_ActionPoints';
  ActionPointCost.iNumPoints = 1;
  ActionPointCost.bConsumeAllPoints = true;
  Template.AbilityCosts.AddItem(ActionPointCost);

  // Cooldown on the ability
  Cooldown = new class'X2AbilityCooldown';
  Cooldown.iNumTurns = default.PSIREANIMATERS_COOLDOWN;
  Template.AbilityCooldown = Cooldown;

  Template.AbilityTargetStyle = new class'X2AbilityTarget_Single';
  Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

  Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);// Prevent ability from being available when dead
  Template.AddShooterEffectExclusions();

  // This ability is only valid if the target has not yet been turned into a zombie
  UnitValue = new class'X2Condition_UnitValue';
  UnitValue.AddCheckValue(class'X2Effect_SpawnPsiZombie'.default.TurnedZombieName, 1, eCheck_LessThan);
  Template.AbilityTargetConditions.AddItem(UnitValue);

  // the target's tile must be clear of obstruction. Functionally this is the same as the
  // unburrow condition, but it can't renamed now that we've launched the game
  Template.AbilityTargetConditions.AddItem(new class'X2Condition_ValidUnburrowTile');

  ExcludeEffects = new class'X2Condition_UnitEffects';
  ExcludeEffects.AddExcludeEffect(class'X2Ability_CarryUnit'.default.CarryUnitEffectName, 'AA_UnitIsImmune');
  ExcludeEffects.AddExcludeEffect(class'X2AbilityTemplateManager'.default.BeingCarriedEffectName, 'AA_UnitIsImmune');
  Template.AbilityTargetConditions.AddItem(ExcludeEffects);

  // The unit must be organic, dead, and not an alien
  UnitPropertyCondition = new class'X2Condition_UnitProperty';
  UnitPropertyCondition.ExcludeDead = false;
  UnitPropertyCondition.ExcludeAlive = true;
  UnitPropertyCondition.ExcludeRobotic = true;
  UnitPropertyCondition.ExcludeOrganic = false;
  UnitPropertyCondition.ExcludeAlien = true;
  UnitPropertyCondition.ExcludeCivilian = false;
  UnitPropertyCondition.ExcludeCosmetic = true;
  UnitPropertyCondition.ExcludeFriendlyToSource = false;
  UnitPropertyCondition.ExcludeHostileToSource = false;
  UnitPropertyCondition.FailOnNonUnits = true;
  Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

  // Must be able to see the dead unit to reanimate it
  TargetVisibilityCondition = new class'X2Condition_Visibility';
  TargetVisibilityCondition.bRequireGameplayVisible = true;
  Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);

  // Add dead eye to guarantee the reanimation occurs
  Template.AbilityToHitCalc = default.DeadEye;

  // The target will now be turned into a zombie
  SpawnZombieEffect = new class'X2Effect_SpawnPsiZombie';
  SpawnZombieEffect.BuildPersistentEffect(1, true);
  Template.AddTargetEffect(SpawnZombieEffect);

  Template.bSkipPerkActivationActions = true;
  Template.bSkipPerkActivationActionsSync = false;
  Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
  Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
  Template.BuildVisualizationFn = PsiReanimation_BuildVisualization;
  Template.CinescriptCameraType = "Psionic_FireAtUnit";

  return Template;
}

simulated function PsiReanimation_BuildVisualization(XComGameState VisualizeGameState)
{
  local XComGameStateHistory History;
  local XComGameStateContext_Ability Context;
  local StateObjectReference InteractingUnitRef;
  local X2Action_PlayAnimation AnimationAction;

  local VisualizationActionMetadata EmptyTrack;
  local VisualizationActionMetadata ActionMetadata, ZombieTrack, DeadUnitTrack;
  local XComGameState_Unit SpawnedUnit, DeadUnit, SectoidUnit;
  local UnitValue SpawnedUnitValue;
  local X2Effect_SpawnPsiZombie SpawnPsiZombieEffect;
  local X2Action_TimedWait ReanimateTimedWaitAction;

  History = class'XComGameStateHistory'.static.GetGameStateHistory();

  Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
  InteractingUnitRef = Context.InputContext.SourceObject;

  //Configure the visualization track for the shooter
  //****************************************************************************************
  ActionMetadata = EmptyTrack;
  ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
  ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
  ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

  SectoidUnit = XComGameState_Unit(ActionMetadata.StateObject_NewState);

  if( SectoidUnit != none )
  {
    // Configure the visualization track for the psi zombie
    //******************************************************************************************
    DeadUnitTrack.StateObject_OldState = History.GetGameStateForObjectID(Context.InputContext.PrimaryTarget.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex);
    DeadUnitTrack.StateObject_NewState = DeadUnitTrack.StateObject_OldState;
    DeadUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(Context.InputContext.PrimaryTarget.ObjectID));
    Assert(DeadUnit != none);
    DeadUnitTrack.VisualizeActor = History.GetVisualizer(DeadUnit.ObjectID);

    // Get the ObjectID for the ZombieUnit created from the DeadUnit
    DeadUnit.GetUnitValue(class'X2Effect_SpawnUnit'.default.SpawnedUnitValueName, SpawnedUnitValue);

    ZombieTrack = EmptyTrack;
    ZombieTrack.StateObject_OldState = History.GetGameStateForObjectID(SpawnedUnitValue.fValue, eReturnType_Reference, VisualizeGameState.HistoryIndex);
    ZombieTrack.StateObject_NewState = ZombieTrack.StateObject_OldState;
    SpawnedUnit = XComGameState_Unit(ZombieTrack.StateObject_NewState);
    Assert(SpawnedUnit != none);
    ZombieTrack.VisualizeActor = History.GetVisualizer(SpawnedUnit.ObjectID);

    // Only one target effect and it is X2Effect_SpawnPsiZombie
    SpawnPsiZombieEffect = X2Effect_SpawnPsiZombie(Context.ResultContext.TargetEffectResults.Effects[0]);

    if( SpawnPsiZombieEffect == none )
    {
      XComEngine(class'Engine'.static.GetEngine()).RedScreenOnce("PsiReanimation_BuildVisualization: Missing X2Effect_SpawnPsiZombie -dslonneger @gameplay");
      return;
    }

    // Build the tracks
    class'X2Action_ExitCover'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded);
    class'X2Action_AbilityPerkStart'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded);

    // Dead unit should wait for the Sectoid to play its Reanimation animation
    // Preferable to have an anim notify from content but can't do that currently, animation gave the time to wait before the zombie rises
    ReanimateTimedWaitAction = X2Action_TimedWait(class'X2Action_TimedWait'.static.AddToVisualizationTree(DeadUnitTrack, Context));
    ReanimateTimedWaitAction.DelayTimeSec = 3.0;

    SpawnPsiZombieEffect.AddSpawnVisualizationsToTracks(Context, SpawnedUnit, ZombieTrack, DeadUnit, DeadUnitTrack);

    AnimationAction = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
    AnimationAction.Params.AnimName = 'HL_Psi_ReAnimate';

    class'X2Action_AbilityPerkEnd'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded);
    class'X2Action_EnterCover'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded);
  }
}

//#############################################################
//Restore - Heals an allied units and restores their condition
//#############################################################
static function X2AbilityTemplate RestoreRS()
{
  local X2AbilityTemplate				Template;
  local X2AbilityCost_ActionPoints	ActionPointCost;
  local X2AbilityCooldown             Cooldown;
  local X2Effect_ApplyMedikitHeal     MedikitHeal;
  local X2Condition_UnitProperty      UnitPropertyCondition;
  local X2Condition_UnitStatCheck     UnitStatCheckCondition;
  local X2Condition_UnitEffects       UnitEffectsCondition;

  Template= new(None, string('RestoreRS')) class'X2AbilityTemplate'; Template.SetTemplateName('RestoreRS');;;

  // Icon Properties
  Template.DisplayTargetHitChance = true;
  Template.AbilitySourceName = 'eAbilitySource_Psionic';
  Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_regeneration";
  Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY;
  Template.Hostility = eHostility_Defensive;
  Template.bLimitTargetIcons = true;
  Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;

  Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

  ActionPointCost = new class'X2AbilityCost_ActionPoints';
  ActionPointCost.iNumPoints = 1;
  ActionPointCost.bConsumeAllPoints = true;
  Template.AbilityCosts.AddItem(ActionPointCost);

  Cooldown = new class'X2AbilityCooldown';
  Cooldown.iNumTurns = default.RESTORERS_COOLDOWN;
  Template.AbilityCooldown = Cooldown;

  Template.AbilityToHitCalc = default.DeadEye;
  Template.AbilityTargetStyle = default.SingleTargetWithSelf;

  UnitPropertyCondition = new class'X2Condition_UnitProperty';
  UnitPropertyCondition.ExcludeDead = false; //Hack: See following comment.
  UnitPropertyCondition.ExcludeRobotic = true;
  UnitPropertyCondition.ExcludeTurret = true;
  UnitPropertyCondition.ExcludeCivilian = true;
  UnitPropertyCondition.ExcludeCosmetic = true;
  UnitPropertyCondition.ExcludeHostileToSource = true;
  UnitPropertyCondition.ExcludeFriendlyToSource = false;
  UnitPropertyCondition.ExcludeFullHealth = false;
  Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

  //Hack: Do this instead of ExcludeDead, to only exclude properly-dead or bleeding-out units.
  UnitStatCheckCondition = new class'X2Condition_UnitStatCheck';
  UnitStatCheckCondition.AddCheckStat(eStat_HP, 0, eCheck_GreaterThan);
  Template.AbilityTargetConditions.AddItem(UnitStatCheckCondition);

  UnitEffectsCondition = new class'X2Condition_UnitEffects';
  UnitEffectsCondition.AddExcludeEffect(class'X2StatusEffects'.default.BleedingOutName, 'AA_UnitIsImpaired');
  Template.AbilityTargetConditions.AddItem(UnitEffectsCondition);

  Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
  Template.AddShooterEffectExclusions();

  MedikitHeal = new class'X2Effect_ApplyMedikitHeal';
  MedikitHeal.PerUseHP = default.RESTORERS_HEAL;
  Template.AddTargetEffect(MedikitHeal);

  //Remove Additional Effects
  Template.AddTargetEffect(RemoveAdditionalEffectsForRevivalProtocolAndRestorativeMist());
  Template.AddTargetEffect(RemoveAllEffectsByDamageType());
  Template.AddTargetEffect(new class'X2Effect_RestoreActionPoints');      //  put the unit back to full actions

  Template.AbilityTargetStyle = default.SimpleSingleTarget;

  Template.ActivationSpeech = 'Inspire';

  Template.bShowActivation = true;
  Template.CustomFireAnim = 'HL_Psi_ProjectileMedium';
  Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
  Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
  Template.CinescriptCameraType = "Psionic_FireAtUnit";

  return Template;
}

static function X2Effect_RemoveEffects RemoveAdditionalEffectsForRevivalProtocolAndRestorativeMist()
{
  local X2Effect_RemoveEffects RemoveEffects;
  RemoveEffects = new class'X2Effect_RemoveEffects';
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.PanickedName);
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2StatusEffects'.default.UnconsciousName);
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.ConfusedName);
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.StunnedName);
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.DazedName);
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.ObsessedName);
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.BerserkName);
  RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.ShatteredName);
  return RemoveEffects;
}

static function X2Effect_RemoveEffectsByDamageType RemoveAllEffectsByDamageType()
{
  local X2Effect_RemoveEffectsByDamageType RemoveEffectTypes;
  local name HealType;

  RemoveEffectTypes = new class'X2Effect_RemoveEffectsByDamageType';
  foreach class'X2Ability_DefaultAbilitySet'.default.MedikitHealEffectTypes(HealType)
  {
    RemoveEffectTypes.DamageTypesToRemove.AddItem(HealType);
  }
  return RemoveEffectTypes;
}

//#############################################################
//Teleport - A Free Teleport Action
//#############################################################
static function X2DataTemplate TeleportRS()
{
  local X2AbilityTemplate Template;
  local X2AbilityCooldown             Cooldown;
  local X2AbilityTarget_Cursor CursorTarget;
  local X2AbilityMultiTarget_Radius RadiusMultiTarget;
  local X2AbilityTrigger_PlayerInput InputTrigger;

  Template= new(None, string('TeleportRS')) class'X2AbilityTemplate'; Template.SetTemplateName('TeleportRS');;;

  Template.AbilitySourceName = 'eAbilitySource_Psionic';
  Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
  Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_codex_teleport";
  Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
  Template.Hostility = eHostility_Defensive;

  Template.AbilityCosts.AddItem(default.FreeActionCost);

  Cooldown = new class'X2AbilityCooldown';
  Cooldown.iNumTurns = default.TELEPORTRS_COOLDOWN;
  Template.AbilityCooldown = Cooldown;

  Template.TargetingMethod = class'X2TargetingMethod_Teleport';

  InputTrigger = new class'X2AbilityTrigger_PlayerInput';
  Template.AbilityTriggers.AddItem(InputTrigger);

  Template.AbilityToHitCalc = default.DeadEye;

  CursorTarget = new class'X2AbilityTarget_Cursor';
  CursorTarget.bRestrictToSquadsightRange = true;
  //	CursorTarget.FixedAbilityRange = default.CYBERUS_TELEPORT_RANGE;     // yes there is.
  Template.AbilityTargetStyle = CursorTarget;

  RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
  RadiusMultiTarget.fTargetRadius = 0.25; // small amount so it just grabs one tile
  Template.AbilityMultiTargetStyle = RadiusMultiTarget;

  // Shooter Conditions
  Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
  Template.AddShooterEffectExclusions();

  //// Damage Effect
  Template.AbilityMultiTargetConditions.AddItem(default.LivingTargetUnitOnlyProperty);
  //TeleportDamageEffect = new class'X2Effect_ApplyWeaponDamage';
  //TeleportDamageEffect.EffectDamageValue = class'X2Item_DefaultWeapons'.default.CYBERUS_TELEPORT_BASEDAMAGE;
  //TeleportDamageEffect.EnvironmentalDamageAmount = default.TELEPORT_ENVIRONMENT_DAMAGE_AMOUNT;
  //TeleportDamageEffect.EffectDamageValue.DamageType = 'Melee';
  //Template.AddMultiTargetEffect(TeleportDamageEffect);

  //Template.bSkipFireAction = true;
  Template.ModifyNewContextFn = Teleport_ModifyActivatedAbilityContext;
  Template.BuildNewGameStateFn = Teleport_BuildGameState;
  Template.BuildVisualizationFn = Teleport_BuildVisualization;
  Template.CinescriptCameraType = "Psionic_FireAtUnit";

  return Template;
}

static simulated function Teleport_ModifyActivatedAbilityContext(XComGameStateContext Context)
{
  local XComGameState_Unit UnitState;
  local XComGameStateContext_Ability AbilityContext;
  local XComGameStateHistory History;
  local PathPoint NextPoint, EmptyPoint;
  local PathingInputData InputData;
  local XComWorldData World;
  local vector NewLocation;
  local TTile NewTileLocation;

  History = class'XComGameStateHistory'.static.GetGameStateHistory();
  World = class'XComWorldData'.static.GetWorldData();

  AbilityContext = XComGameStateContext_Ability(Context);
  Assert(AbilityContext.InputContext.TargetLocations.Length > 0);

  UnitState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));

  // Build the MovementData for the path
  // First posiiton is the current location
  InputData.MovementTiles.AddItem(UnitState.TileLocation);

  NextPoint.Position = World.GetPositionFromTileCoordinates(UnitState.TileLocation);
  NextPoint.Traversal = eTraversal_Teleport;
  NextPoint.PathTileIndex = 0;
  InputData.MovementData.AddItem(NextPoint);

  // Second posiiton is the cursor position
  Assert(AbilityContext.InputContext.TargetLocations.Length == 1);

  NewLocation = AbilityContext.InputContext.TargetLocations[0];
  NewTileLocation = World.GetTileCoordinatesFromPosition(NewLocation);
  NewLocation = World.GetPositionFromTileCoordinates(NewTileLocation);

  NextPoint = EmptyPoint;
  NextPoint.Position = NewLocation;
  NextPoint.Traversal = eTraversal_Landing;
  NextPoint.PathTileIndex = 1;
  InputData.MovementData.AddItem(NextPoint);
  InputData.MovementTiles.AddItem(NewTileLocation);

  //Now add the path to the input context
  InputData.MovingUnitRef = UnitState.GetReference();
  AbilityContext.InputContext.MovementPaths.AddItem(InputData);
}

static simulated function XComGameState Teleport_BuildGameState(XComGameStateContext Context)
{
  local XComGameState NewGameState;
  local XComGameState_Unit UnitState;
  local XComGameStateContext_Ability AbilityContext;
  local vector NewLocation;
  local TTile NewTileLocation;
  local XComWorldData World;
  local X2EventManager EventManager;
  local int LastElementIndex;

  World = class'XComWorldData'.static.GetWorldData();
  EventManager = class'X2EventManager'.static.GetEventManager();

  //Build the new game state frame
  NewGameState = TypicalAbility_BuildGameState(Context);

  AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());
  UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', AbilityContext.InputContext.SourceObject.ObjectID));

  LastElementIndex = AbilityContext.InputContext.MovementPaths[0].MovementData.Length - 1;

  // Set the unit's new location
  // The last position in MovementData will be the end location
  Assert(LastElementIndex > 0);
  NewLocation = AbilityContext.InputContext.MovementPaths[0].MovementData[LastElementIndex].Position;
  NewTileLocation = World.GetTileCoordinatesFromPosition(NewLocation);
  UnitState.SetVisibilityLocation(NewTileLocation);

  AbilityContext.ResultContext.bPathCausesDestruction = MoveAbility_StepCausesDestruction(UnitState, AbilityContext.InputContext, 0, AbilityContext.InputContext.MovementPaths[0].MovementTiles.Length - 1);
  MoveAbility_AddTileStateObjects(NewGameState, UnitState, AbilityContext.InputContext, 0, AbilityContext.InputContext.MovementPaths[0].MovementTiles.Length - 1);

  EventManager.TriggerEvent('ObjectMoved', UnitState, UnitState, NewGameState);
  EventManager.TriggerEvent('UnitMoveFinished', UnitState, UnitState, NewGameState);

  //Return the game state we have created
  return NewGameState;
}

simulated function Teleport_BuildVisualization(XComGameState VisualizeGameState)
{
  local XComGameStateHistory History;
  local XComGameStateContext_Ability  AbilityContext;
  local StateObjectReference InteractingUnitRef;
  local X2AbilityTemplate AbilityTemplate;
  local VisualizationActionMetadata EmptyTrack, ActionMetadata;
  local X2Action_PlaySoundAndFlyOver SoundAndFlyover;
  local int i, j;
  local XComGameState_WorldEffectTileData WorldDataUpdate;
  local X2Action_MoveTurn MoveTurnAction;
  local X2VisualizerInterface TargetVisualizerInterface;

  History = class'XComGameStateHistory'.static.GetGameStateHistory();

  AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());
  InteractingUnitRef = AbilityContext.InputContext.SourceObject;

  AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.InputContext.AbilityTemplateName);

  //****************************************************************************************
  //Configure the visualization track for the source
  //****************************************************************************************
  ActionMetadata = EmptyTrack;
  ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
  ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
  ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

  SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
  SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFlyOverText, '', eColor_Bad);

  // Turn to face the target action. The target location is the center of the ability's radius, stored in the 0 index of the TargetLocations
  MoveTurnAction = X2Action_MoveTurn(class'X2Action_MoveTurn'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
  MoveTurnAction.m_vFacePoint = AbilityContext.InputContext.TargetLocations[0];

  // move action
  class'X2VisualizerHelpers'.static.ParsePath(AbilityContext, ActionMetadata);


  //****************************************************************************************

  foreach VisualizeGameState.IterateByClassType(class'XComGameState_WorldEffectTileData', WorldDataUpdate)
  {
    ActionMetadata = EmptyTrack;
    ActionMetadata.VisualizeActor = none;
    ActionMetadata.StateObject_NewState = WorldDataUpdate;
    ActionMetadata.StateObject_OldState = WorldDataUpdate;

    for (i = 0; i < AbilityTemplate.AbilityTargetEffects.Length; ++i)
    {
      AbilityTemplate.AbilityTargetEffects[i].AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, AbilityContext.FindTargetEffectApplyResult(AbilityTemplate.AbilityTargetEffects[i]));
    }

  }

  //****************************************************************************************
  //Configure the visualization track for the targets
  //****************************************************************************************
  for( i = 0; i < AbilityContext.InputContext.MultiTargets.Length; ++i )
  {
    InteractingUnitRef = AbilityContext.InputContext.MultiTargets[i];
    ActionMetadata = EmptyTrack;
    ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
    ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
    ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

    class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(ActionMetadata, AbilityContext);
    for( j = 0; j < AbilityContext.ResultContext.MultiTargetEffectResults[i].Effects.Length; ++j )
    {
      AbilityContext.ResultContext.MultiTargetEffectResults[i].Effects[j].AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, AbilityContext.ResultContext.MultiTargetEffectResults[i].ApplyResults[j]);
    }

    TargetVisualizerInterface = X2VisualizerInterface(ActionMetadata.VisualizeActor);
    if( TargetVisualizerInterface != none )
    {
      //Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
      TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, ActionMetadata);
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//END FILE
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
