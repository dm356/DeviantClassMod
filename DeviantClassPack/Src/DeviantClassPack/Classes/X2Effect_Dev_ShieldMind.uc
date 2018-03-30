class X2Effect_Dev_ShieldMind extends X2Effect_ModifyStats;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
  local StatChange Change;
  local XComGameState_Unit kTargetUnitState;

  kTargetUnitState = XComGameState_Unit(kNewTargetState);
	Change.StatType = eStat_Will;
	Change.StatAmount = kTargetUnitState.GetCurrentStat(eStat_PsiOffense) * 0.5;
	Change.ModOp = MODOP_Addition;

  NewEffectState.StatChanges.AddItem(Change);

  super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}
