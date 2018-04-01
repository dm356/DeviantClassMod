// Multiply damage by current focus level
class X2Effect_Dev_FocusedRendDamage extends X2Effect_Persistent;

var float DamageMultiplier;

// From X2Effect_Persistent. Returns a damage modifier for an attack by the unit with the effect.
function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
  if(AbilityState.GetMyTemplate().DataName != 'FocusedRend_Dev')
    return 0;

  return int(CurrentDamage * Attacker.GetTemplarFocusLevel() * DamageMultiplier);
}
