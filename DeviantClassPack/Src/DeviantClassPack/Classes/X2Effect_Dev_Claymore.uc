// Add Conditional infinite duration to claymore
class X2Effect_Dev_Claymore extends X2Effect_Claymore
	native(Core);

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit SourceUnit;
	//local XComGameState_Destructible DestructibleState;

	SourceUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	`assert(SourceUnit != none);

  if (SourceUnit.HasSoldierAbility('TimedClaymore_Dev'))
  {
    bInfiniteDuration = false;
  }

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}
