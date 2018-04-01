//---------------------------------------------------------------------------------------
//  FILE:    DevAbilityTemplateMods (adapted from LWTemplateMods)
//  AUTHOR:  tracktwo / Pavonis Interactive
//
//  PURPOSE: Mods to base XCOM2 templates
//---------------------------------------------------------------------------------------

//`include(LW_Overhaul\Src\LW_Overhaul.uci)

class DevAbilityTemplateMods extends X2StrategyElement config(Dev_SoldierSkills);

var protectedwrite name HelpingHandsAbilityName;

var config int HELPING_HANDS_DEV_MOBILITY_BONUS;
var config int RIPOSTE_DEV_DEFLECT_BONUS;
var config int RIPOSTE_DEV_REFLECT_BONUS;

var localized string HelpingHandsEffectFriendlyName;
var localized string HelpingHandsEffectFriendlyDesc;

function PerformAbilityTemplateMod()
{
  local X2AbilityTemplateManager				AbilityTemplateMgr;
  local X2AbilityTemplate AbilityTemplate;
  local array<Name> TemplateNames;
  local Name TemplateName;
  local array<X2DataTemplate> DataTemplates;
  local X2DataTemplate DataTemplate;
  local int Difficulty;

  AbilityTemplateMgr			= class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
  AbilityTemplateMgr.GetTemplateNames(TemplateNames);

  foreach TemplateNames(TemplateName)
  {
    AbilityTemplateMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
    foreach DataTemplates(DataTemplate)
    {
      AbilityTemplate = X2AbilityTemplate(DataTemplate);
      if(AbilityTemplate != none)
      {
        Difficulty = GetDifficultyFromTemplateName(TemplateName);
        ModifyAbilitiesGeneral(AbilityTemplate, Difficulty);
      }
    }
  }
}

function ModifyAbilitiesGeneral(X2AbilityTemplate Template, int Difficulty)
{
  local X2Effect_PersistentStatChange CarryUnitEffect;
  local X2AbilityCost_ConditionalActionPoints PutDownConditionalCost;
  local X2Effect_RemoveEffects RemoveEffects;
  local X2Condition_UnitInventory			InventoryCondition;
  local XMBCondition_SourceAbilities      SourceAbilityCondition;
  local X2AbilityCost_ActionPoints        ActionPointCost;
  local X2AbilityCost                     Cost;
  local X2Effect_Dev_Deflect              DeflectEffect;
  local X2Effect_Dev_Claymore              ClaymoreEffect;
  local int i;

  if (Template.DataName == 'CarryUnit')
  {
    CarryUnitEffect = new class'X2Effect_PersistentStatChange';
    CarryUnitEffect.BuildPersistentEffect(1, true, true);
    CarryUnitEffect.SetDisplayInfo(ePerkBuff_Bonus, default.HelpingHandsEffectFriendlyName, default.HelpingHandsEffectFriendlyDesc, Template.IconImage, true);
    CarryUnitEffect.AddPersistentStatChange(eStat_Mobility, default.HELPING_HANDS_DEV_MOBILITY_BONUS);
    CarryUnitEffect.DuplicateResponse = eDupe_Ignore;
    CarryUnitEffect.EffectName = 'HelpingHandsBonus';
    Template.AddShooterEffect(CarryUnitEffect);
  }

  if (Template.DataName == 'PutDownUnit')
  {
    PutDownConditionalCost = new class'X2AbilityCost_ConditionalActionPoints';
    PutDownConditionalCost.NoCostSoldierAbilities.AddItem('HelpingHands_Dev');
    PutDownConditionalCost.iNumPoints = 1;

    RemoveEffects = new class'X2Effect_RemoveEffects';
    RemoveEffects.EffectNamesToRemove.AddItem('HelpingHandsBonus');
    Template.AddShooterEffect(RemoveEffects);

    Template.AbilityCosts.Length = 0;
    Template.AbilityCosts.AddItem(PutDownConditionalCost);
  }

  // Update for NoScope
  if (Template.DataName == 'LW2WotC_SnapShot')
  {
    InventoryCondition = new class'X2Condition_UnitInventory';
    InventoryCondition.RelevantSlot=eInvSlot_PrimaryWeapon;
    InventoryCondition.RequireWeaponCategory = 'sniper_rifle';
    Template.AbilityShooterConditions.AddItem(InventoryCondition);

    Template.HideIfAvailable.AddItem('LW2WotC_LightEmUp');
    Template.HideIfAvailable.AddItem('SniperRifleOverwatch');
    Template.HideIfAvailable.AddItem('LongWatch');
  }

  // Update for NoScope
  if (Template.DataName == 'LW2WotC_LightEmUp')
  {
    InventoryCondition = new class'X2Condition_UnitInventory';
    InventoryCondition.RelevantSlot=eInvSlot_PrimaryWeapon;
    InventoryCondition.ExcludeWeaponCategory = 'sniper_rifle';
    Template.AbilityShooterConditions.AddItem(InventoryCondition);
  }

  // Make Fleche undetectable while running
  if (Template.DataName == 'LW2WotC_Fleche')
  {
    Template.AdditionalAbilities.AddItem('WhisperStrike_Dev');
  }

  // Hide throw grenade when Special Delivery is present
  if (Template.DataName == 'ThrowGrenade')
  {
    SourceAbilityCondition = new class'XMBCondition_SourceAbilities';
    SourceAbilityCondition.AddRequireAbility('SpecialDelivery_Dev', 'AA_HasSpecialDelivery_Dev');
    Template.AbilityShooterConditions.AddItem(SourceAbilityCondition);
    Template.HideErrors.AddItem('AA_HasSpecialDelivery_Dev');
  }

  // Setup for Hell Raiser action points
  if (Template.DataName == 'RemoteStart' || Template.DataName == 'StandardMove')
  {
    foreach Template.AbilityCosts(Cost)
    {
      ActionPointCost = X2AbilityCost_ActionPoints(Cost);
      if (ActionPointCost != none)
      {
        ActionPointCost.AllowedTypes.AddItem(class'X2Ability_DeviantClassPackAbilitySet'.default.HELL_RAISER_DEV_ACTION_POINT_NAME);
      }
    }
  }

  // Prime Deflect for Riposte
  if (Template.DataName == 'Deflect')
  {
    DeflectEffect = new class'X2Effect_Dev_Deflect';
    DeflectEffect.RiposteDeflectBonus = RIPOSTE_DEV_DEFLECT_BONUS;
    DeflectEffect.RiposteReflectBonus = RIPOSTE_DEV_REFLECT_BONUS;
    DeflectEffect.BuildPersistentEffect(1, true, false);
    DeflectEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true, , Template.AbilitySourceName);

    for (i = 0; i < Template.AbilityTargetEffects.Length; ++i)
    {
      if (X2Effect_Deflect(Template.AbilityTargetEffects[i]) != none)
      {
        Template.AbilityTargetEffects[i] = DeflectEffect;
        break;
      }
    }
  }

  // Add Timer to Claymores
  if (Template.DataName == 'ThrowClaymore' || Template.DataName = 'ThrowShrapnel')
  {
    ClaymoreEffect = new class 'X2Effect_Dev_Claymore';
    ClaymoreEffect.BuildPersistentEffect(2, true, false, false);

    if (TemplateName == 'ThrowShrapnel')
      ClaymoreEffect.DestructibleArchetype = class'X2Ability_ReaperAbilitySet'.default.ShrapnelDestructibleArchetype;
    else
      ClaymoreEffect.DestructibleArchetype = class'X2Ability_ReaperAbilitySet'.default.ClaymoreDestructibleArchetype;

    for (i = 0; i < Template.AbilityShooterEffects.Length; ++i)
    {
      if (X2Effect_Claymore(Template.AbilityShooterEffects[i]) != none)
      {
        Template.AbilityShooterEffects[i] = ClaymoreEffect;
        break;
      }
    }
  }
}

defaultProperties
{
  HelpingHandsAbilityName="HelpingHands_Dev"
}

//=================================================================================
//================= UTILITY CLASSES ===============================================
//=================================================================================

static function int GetDifficultyFromTemplateName(name TemplateName)
{
  return int(GetRightMost(string(TemplateName)));
}
