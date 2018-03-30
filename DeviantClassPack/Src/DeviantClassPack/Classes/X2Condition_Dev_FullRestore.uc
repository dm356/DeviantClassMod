// Check if target has a status that can be healed
class X2Condition_Dev_FullRestore extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
  local XComGameState_Unit TargetUnit;

  TargetUnit = XComGameState_Unit(kTarget);
  if (TargetUnit == none)
    return 'AA_NotAUnit';

  if (TargetUnit.IsBeingCarried())
    return 'AA_UnitIsImmune';

  // Revival checks
  if (TargetUnit.IsPanicked() || TargetUnit.IsUnconscious() || TargetUnit.IsDisoriented() || TargetUnit.IsDazed())
  {
    if (!TargetUnit.GetMyTemplate().bCanBeRevived)
      return 'AA_UnitIsImmune';
    return 'AA_Success';
  }

  if (TargetUnit.IsBurning() || TargetUnit.IsPoisioned() || TargetUnit.IsAcidBurning() || TargetUnit.IsBleedingOut())
    return 'AA_Success';

  if(TargetUnit.GetCurrentStat(eStat_HP) < TargetUnit.GetMaxStat(eStat_HP))
    return 'AA_Success';

  return 'AA_UnitIsNotImpaired';
}

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
  local XComGameState_Unit SourceUnit, TargetUnit;

  SourceUnit = XComGameState_Unit(kSource);
  TargetUnit = XComGameState_Unit(kTarget);

  if (SourceUnit == none || TargetUnit == none)
    return 'AA_NotAUnit';

  if (SourceUnit.ControllingPlayer == TargetUnit.ControllingPlayer)
    return 'AA_Success';

  return 'AA_UnitIsHostile';
}
