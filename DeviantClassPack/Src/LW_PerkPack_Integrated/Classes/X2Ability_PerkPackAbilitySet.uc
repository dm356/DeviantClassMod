//---------------------------------------------------------------------------------------
//  FILE:    X2Ability_PerkPackAbilitySet
//  AUTHOR:  Amineri / John Lumpkin (Pavonis Interactive)
//  PURPOSE: Defines general use ability templates
//---------------------------------------------------------------------------------------

class X2Ability_PerkPackAbilitySet extends X2Ability config (LW_SoldierSkills);

var config int LETHAL_DAMAGE;
var config int PRECISION_SHOT_COOLDOWN;
var config int PRECISION_SHOT_AMMO_COST;
var config int PRECISION_SHOT_CRIT_BONUS;
var config int COVERING_FIRE_OFFENSE_MALUS;
var localized string LocCoveringFire;
var localized string LocCoveringFireMalus;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(AddAggressionAbility());
	Templates.AddItem(AddLethalAbility());
	Templates.AddItem(AddDamnGoodGroundAbility());
	Templates.AddItem(AddLoneWolfAbility());
	Templates.AddItem(AddLowProfileAbility());
	Templates.AddItem(AddPrecisionShotAbility());
	Templates.AddItem(PrecisionShotCritDamage()); //Additional Ability
	Templates.AddItem(AddSentinel_LWAbility());
	return Templates;
}

static function X2AbilityTemplate AddAggressionAbility()
{
	local X2AbilityTemplate				Template;
	local X2Effect_Aggression			MyCritModifier;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'Aggression');
	Template.IconImage = "img:///UILibrary_LW_PerkPack.LW_AbilityAggression";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	MyCritModifier = new class 'X2Effect_Aggression';
	MyCritModifier.BuildPersistentEffect (1, true, false);
	MyCritModifier.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect (MyCritModifier);
	Template.bCrossClassEligible = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate AddLethalAbility()
{
	local X2AbilityTemplate						Template;
	local X2Effect_PrimaryHitBonusDamage        DamageEffect;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'Lethal');
	Template.IconImage = "img:///UILibrary_LW_PerkPack.LW_AbilityKinetic";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	DamageEffect = new class'X2Effect_PrimaryHitBonusDamage';
	DamageEffect.BonusDmg = default.LETHAL_DAMAGE;
	DamageEffect.includepistols = false;
	DamageEffect.includesos = false;
	DamageEffect.BuildPersistentEffect(1, true, false, false);
	DamageEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(DamageEffect);
	Template.bCrossClassEligible = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// No visualization
	// NOTE: Limitation of this ability to PRIMARY weapons only must be configured in ClassData.ini, otherwise will apply to pistols/swords, etc., contrary to design and loc text
	// Ability parameter is ApplyToWeaponSlot=eInvSlot_PrimaryWeapon
	return Template;
}

static function X2AbilityTemplate AddDamnGoodGroundAbility()
{
	local X2AbilityTemplate					Template;
	local X2Effect_DamnGoodGround			AimandDefModifiers;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DamnGoodGround');
	Template.IconImage = "img:///UILibrary_LW_PerkPack.LW_AbilityDamnGoodGround";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	AimandDefModifiers = new class 'X2Effect_DamnGoodGround';
	AimandDefModifiers.BuildPersistentEffect (1, true, true);
	AimandDefModifiers.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect (AimandDefModifiers);
	Template.bCrossClassEligible = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	return Template;
}

static function X2AbilityTemplate AddLoneWolfAbility()
{
	local X2AbilityTemplate					Template;
	local X2Effect_LoneWolf					AimandDefModifiers;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'LoneWolf');
	Template.IconImage = "img:///UILibrary_LW_PerkPack.LW_AbilityLoneWolf";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	AimandDefModifiers = new class 'X2Effect_LoneWolf';
	AimandDefModifiers.BuildPersistentEffect (1, true, false);
	AimandDefModifiers.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect (AimandDefModifiers);
	Template.bCrossClassEligible = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//no visualization
	return Template;
}

static function X2AbilityTemplate AddLowProfileAbility()
{
	local X2AbilityTemplate					Template;
	local X2Effect_LowProfile_LW			DefModifier;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'LowProfile');
	Template.IconImage = "img:///UILibrary_LW_PerkPack.LW_AbilityLowProfile";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	DefModifier = new class 'X2Effect_LowProfile_LW';
	DefModifier.BuildPersistentEffect (1, true, false);
	DefModifier.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect (DefModifier);
	Template.bCrossClassEligible = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//no visualization
	return Template;
}

static function X2AbilityTemplate AddPrecisionShotAbility()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2AbilityCost_Ammo				AmmoCost;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;
	local X2AbilityCooldown					Cooldown;
	local X2Effect_Knockback				KnockbackEffect;
	local X2Condition_Visibility            VisibilityCondition;
	local X2Condition_UnitEffects			SuppressedCondition;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'PrecisionShot');
	Template.IconImage = "img:///UILibrary_LW_PerkPack.LW_AbilityPrecisionShot";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;
	Template.DisplayTargetHitChance = true;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.CinescriptCameraType = "StandardGunFiring";
	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bCrossClassEligible = true;
	Template.bUsesFiringCamera = true;
	Template.Hostility = eHostility_Offensive;
	Template.bPreventsTargetTeleport = false;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	ActionPointCost = new class 'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 0;
	ActionPointCost.bAddWeaponTypicalCost = true;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.BuiltInCritMod = default.PRECISION_SHOT_CRIT_BONUS;
	Template.AbilityToHitCalc = ToHitCalc;
	Template.AbilityToHitOwnerOnMissCalc = ToHitCalc;

	Cooldown = new class'X2AbilityCooldown';
    Cooldown.iNumTurns = default.PRECISION_SHOT_COOLDOWN;
    Template.AbilityCooldown = Cooldown;

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = default.PRECISION_SHOT_AMMO_COST;
	Template.AbilityCosts.AddItem(AmmoCost);
	Template.bAllowAmmoEffects = true;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AddShooterEffectExclusions();

	SuppressedCondition = new class'X2Condition_UnitEffects';
	SuppressedCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
	//SuppressedCondition.AddExcludeEffect(class'X2Effect_AreaSuppression'.default.EffectName, 'AA_UnitIsSuppressed');
	Template.AbilityShooterConditions.AddItem(SuppressedCondition);

	VisibilityCondition = new class'X2Condition_Visibility';
	VisibilityCondition.bRequireGameplayVisible = true;
	VisibilityCondition.bAllowSquadsight = true;
	Template.AbilityTargetConditions.AddItem(VisibilityCondition);

	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AssociatedPassives.AddItem('HoloTargeting');
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());
	Template.bAllowAmmoEffects = true;

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	//KnockbackEffect.bUseTargetLocation = true;
	Template.AddTargetEffect(KnockbackEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
    Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.AdditionalAbilities.AddItem('PrecisionShotCritDamage');

	return Template;
}

static function X2AbilityTemplate PrecisionShotCritDamage()
{
    local X2AbilityTemplate Template;
    local X2Effect_PrecisionShotCritDamage CritEffect;

    `CREATE_X2ABILITY_TEMPLATE (Template, 'PrecisionShotCritDamage');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_momentum";
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = 2;
    Template.Hostility = 2;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
    CritEffect = new class'X2Effect_PrecisionShotCritDamage';
    CritEffect.BuildPersistentEffect(1, true, false, false);
    CritEffect.SetDisplayInfo(0, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false,, Template.AbilitySourceName);
    Template.AddTargetEffect(CritEffect);
    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    return Template;
}

static function X2AbilityTemplate AddSentinel_LWAbility()
{
	local X2AbilityTemplate                 Template;
	local X2Effect_Sentinel_LW				PersistentEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'Sentinel_LW');
	Template.IconImage = "img:///UILibrary_LW_PerkPack.LW_AbilitySentinel";
	Template.Hostility = eHostility_Neutral;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	PersistentEffect = new class'X2Effect_Sentinel_LW';
	PersistentEffect.BuildPersistentEffect(1, true, false);
	PersistentEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(PersistentEffect);
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.bCrossClassEligible = false;
	return Template;
}

static function X2Effect_Persistent CoveringFireMalusEffect()
{
	local X2Effect_PersistentStatChange Effect;
    local X2Condition_AbilityProperty AbilityCondition;

    Effect = new class'X2Effect_PersistentStatChange';
	Effect.AddPersistentStatChange(eStat_Offense, -default.COVERING_FIRE_OFFENSE_MALUS);
	Effect.BuildPersistentEffect(2, false, false, false, eGameRule_PlayerTurnBegin);
	Effect.SetDisplayInfo(ePerkBuff_Penalty, default.LocCoveringFire, default.LocCoveringFireMalus, "img:///UILibrary_PerkIcons.UIPerk_coverfire", true);
    Effect.bRemoveWhenTargetDies = false;
    Effect.bUseSourcePlayerState = true;
	Effect.bApplyOnMiss = true;
	Effect.DuplicateResponse=eDupe_Allow;
    AbilityCondition = new class'X2Condition_AbilityProperty';
    AbilityCondition.OwnerHasSoldierAbilities.AddItem('CoveringFire');
    Effect.TargetConditions.AddItem(AbilityCondition);
    return Effect;
}
