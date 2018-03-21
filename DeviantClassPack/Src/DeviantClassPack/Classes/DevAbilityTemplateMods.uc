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

static function array<X2DataTemplate> CreateTemplates()
{
  local array<X2DataTemplate> Templates;

  //Vanilla Perks that need adjustment
  Templates.AddItem(CreateModifyAbilitiesGeneralTemplate());
  return Templates;
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
