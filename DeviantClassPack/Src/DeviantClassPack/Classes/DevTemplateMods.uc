//---------------------------------------------------------------------------------------
//  FILE:    LWTemplateMods
//  AUTHOR:  tracktwo / Pavonis Interactive
//
//  PURPOSE: Mods to base XCOM2 templates
//---------------------------------------------------------------------------------------

//`include(LW_Overhaul\Src\LW_Overhaul.uci)

class DevTemplateMods extends X2StrategyElement config(Dev_SoldierSkills);

static function array<X2DataTemplate> CreateTemplates()
{
  local array<X2DataTemplate> Templates;

  Templates.Additem(CreateReconfigGearTemplate());
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
