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
}

defaultProperties
{
  HelpingHandsAbilityName="HelpingHands_Dev"
}
