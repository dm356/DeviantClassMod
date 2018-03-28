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
    Template.AddShooterEffect(class'X2Ability_DeviantClassPackAbilitySet'.static.AddWhisperStrikeEffect_Dev('LW2WotC_Fleche'));
  }

  if (Template.DataName == 'ThrowGrenade')
  {
    SourceAbilityCondition = new class'XMBCondition_SourceAbilities';
    SourceAbilityCondition.AddRequireAbility('SpecialDelivery_Dev', 'AA_HasSpecialDelivery_Dev');
    Template.AbilityShooterConditions.AddItem(SourceAbilityCondition);
    Template.HideErrors.AddItem('AA_HasSpecialDelivery_Dev');
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
