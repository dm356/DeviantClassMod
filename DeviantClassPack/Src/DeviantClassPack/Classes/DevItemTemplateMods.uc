//---------------------------------------------------------------------------------------
//  FILE:    DevItemTemplateMods (Mods to standard items, pulled from LWTemplateMods.uc)
//  AUTHOR:  tracktwo / Pavonis Interactive
//
//  PURPOSE: Mods to base XCOM2 templates
//---------------------------------------------------------------------------------------

//`include(LW_Overhaul\Src\LW_Overhaul.uci)

class DevItemTemplateMods extends X2StrategyElement config(Dev_SoldierSkills);


function PerformItemTemplateMod()
{
  local X2ItemTemplateManager				ItemTemplateMgr;
  local X2ItemTemplate ItemTemplate;
  local array<Name> TemplateNames;
  local Name TemplateName;
  local array<X2DataTemplate> DataTemplates;
  local X2DataTemplate DataTemplate;
  local int Difficulty;

  ItemTemplateMgr			= class'X2ItemTemplateManager'.static.GetItemTemplateManager();
  ItemTemplateMgr.GetTemplateNames(TemplateNames);

  foreach TemplateNames(TemplateName)
  {
    ItemTemplateMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
    foreach DataTemplates(DataTemplate)
    {
      ItemTemplate = X2ItemTemplate(DataTemplate);
      if(ItemTemplate != none)
      {
        Difficulty = GetDifficultyFromTemplateName(TemplateName);
        ReconfigGear(ItemTemplate, Difficulty);
      }
    }
  }
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

//=================================================================================
//================= UTILITY CLASSES ===============================================
//=================================================================================

static function int GetDifficultyFromTemplateName(name TemplateName)
{
  return int(GetRightMost(string(TemplateName)));
}
