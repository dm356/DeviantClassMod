class X2Item_Dev_UtilityItems extends X2Item;

static function array<X2DataTemplate> CreateTemplates()
{
  local array<X2DataTemplate> Items;

  Items.AddItem(MisdirectItem_Dev());

  return Items;
}

// Dummy grenade to represent junk thrown via Misdirect
static function X2GrenadeTemplate MisdirectItem_Dev()
{
  local X2GrenadeTemplate Template;

  `CREATE_X2TEMPLATE(class'X2GrenadeTemplate', Template, 'MisdirectItem_Dev');

  Template.WeaponCat = 'Utility';
  Template.ItemCat = 'Utility';

  Template.iRange = class'X2Item_DefaultGrenades'.default.FLASHBANGGRENADE_RANGE;
  Template.iRadius = 0.75;
  Template.iSoundRange = class'X2Ability_DeviantClassPackAbilitySet'.default.MISDIRECT_DEV_SOUND_RANGE;
  Template.iEnvironmentDamage = 0;
  Template.iClipSize = 0;
  Template.Tier = 1;

  Template.Abilities.AddItem('MakeNoise_Dev');

	Template.GameArchetype = "WP_Grenade_Frag.WP_Grenade_Frag";
	//Template.OnThrowBarkSoundCue = 'ThrowFlashbang';

  Template.CanBeBuilt = false;

  return Template;
}

