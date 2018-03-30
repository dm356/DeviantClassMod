class X2Effect_Dev_HellRaiser extends X2Effect_Persistent;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
  local X2EventManager EventMgr;
  local XComGameState_Unit UnitState;
  local Object EffectObj;

  EventMgr = `XEVENTMGR;

  EffectObj = EffectGameState;
  UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

  EventMgr.RegisterForEvent(EffectObj, 'HellRaiser_Dev', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
  local XComGameStateHistory History;
  local XComGameState_Unit TargetUnit, PrevTargetUnit;
  local X2EventManager EventMgr;
  local XComGameState_Ability AbilityState;

  local XComGameState_Destructible DestructibleState;
  local XComDestructibleActor Actor;
  local XComDestructibleActor_Action_RadialDamage DamageAction;
  local array<XComGameState_Unit> UnitsInBlastRadius;
  local int i;

  if(kAbility.GetMyTemplateName() == 'RemoteStart' && kAbility.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef)
  {
    History = class'XComGameStateHistory'.static.GetGameStateHistory();

    DestructibleState = XComGameState_Destructible(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
    Actor = XComDestructibleActor(DestructibleState.GetVisualizer());

    `assert(Actor != none);

    for (i = 0; i < Actor.DestroyedEvents.Length; ++i)
    {
      if (Actor.DestroyedEvents[i].Action != None)
      {
        DamageAction = XComDestructibleActor_Action_RadialDamage(Actor.DestroyedEvents[i].Action);
        if (DamageAction != none)
        {
          DamageAction.GetUnitsInBlastRadius(UnitsInBlastRadius);
        }
      }
    }

    foreach UnitsInBlastRadius(TargetUnit){
      TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
      if(TargetUnit != none)
      {
        PrevTargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(TargetUnit.ObjectID));
        if(TargetUnit.IsDead() && PrevTargetUnit != none)
        {
          if(SourceUnit.NumActionPoints() == 0 && PreCostActionPoints.Length > 0)
          {
            AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
            if(AbilityState != none)
            {
              SourceUnit.ActionPoints.AddItem(class'X2Ability_DeviantClassPackAbilitySet'.default.HELL_RAISER_DEV_ACTION_POINT_NAME);

              EventMgr = class'X2EventManager'.static.GetEventManager();
              EventMgr.TriggerEvent('HellRaiser_Dev', AbilityState, SourceUnit, NewGameState);

              // Refresh Remote Start
              for (i = 0; i < SourceUnit.Abilities.Length; ++i)
              {
                AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(UnitState.Abilities[i].ObjectID));
                if (AbilityState.GetMyTemplateName() == 'RemoteStart' && AbilityState.iCooldown > 0)
                {
                  AbilityState = XComGameState_Ability(NewGameState.ModifyStateObject(AbilityState.Class, AbilityState.ObjectID));
                  AbilityState.iCooldown = 0;
                }
              }

              return true;
            }
          }
        }
      }
    }
  }
  return false;
}
