//---------------------------------------------------------------------------------------
//  FILE:    DevAbilityTemplateMods (adapted from LWTemplateMods)
//  AUTHOR:  tracktwo / Pavonis Interactive
//
//  PURPOSE: Mods to base XCOM2 templates
//---------------------------------------------------------------------------------------

//`include(LW_Overhaul\Src\LW_Overhaul.uci)

class DevAbilityTemplateMods extends X2StrategyElement config(Dev_SoldierSkills);

var protectedwrite name HelpingHandsAbilityName;

var config array<Name> DoubleTapAbilities;

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
  local X2Effect_GrantActionPoints CarryActionEffect;
  local X2Condition_AbilityProperty CarryActionCondition;

  if (Template.DataName == 'CarryUnit' || Template.DataName == 'PutDownUnit')
  {
    CarryActionCondition = new class'X2Condition_AbilityProperty';
    CarryActionCondition.OwnerHasSoldierAbilities.AddItem(default.HelpingHandsAbilityName);

    CarryActionEffect = new class'X2Effect_GrantActionPoints';
    CarryActionEffect.NumActionPoints = 1;
    CarryActionEffect.PointType = class'X2CharacterTemplateManager'.default.MoveActionPoint;
    CarryActionEffect.bApplyOnlyWhenOut = false;
    CarryActionEffect.bSelectUnit = false;
    CarryActionEffect.TargetConditions.AddItem(CarryActionCondition);
    Template.AddShooterEffect(CarryActionEffect);
  }
}

defaultProperties
{
  HelpingHandsAbilityName="HelpingHands_Dev"
}
