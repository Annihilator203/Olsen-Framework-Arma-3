#include "script_component.hpp"

class GVAR(unitStanceStateMachine) {
    list = QUOTE(allUnits select { \
        local _x && \
        {!isPlayer _x} && \
        {QGETVAR(_x,spawned,false)} && \
        {(QGETVAR(_x,stance,'AUTO') == 'AUTO') && {(QGETVAR(group _x,stance,'AUTO') == 'AUTO')}} && \
        {!(QGETVAR(_x,NOAI,false))} && \
        {!([group _x] call FUNC(isMoveTask))} && \
        {!(QGETVAR(_x,Busy,false))} && \
        {(vehicle _x isEqualTo _x)} \
    });
    skipNull = 1;
    class Initial {
        onStateEntered = QFUNC(US_onSEInitial);
        class isInitialized {
            targetState = QUOTE(Unit_Checks);

            condition = QUOTE(true);
        };
    };
    class Unit_Checks {
        onStateEntered = QFUNC(US_onSEUnitChecks);
        class Is_Suppressed {
            targetState = QUOTE(Check_Suppression);

            condition = QUOTE(((behaviour _this) in [ARR_2(QN(COMBAT),QN(STEALTH))])\
            && {(QGETVAR(_this,suppressionFactor,0) > 20)}\
            && {!(QGETVAR(_this,suppressionImmunity,false))}\
            && {!(QGETVAR(_this,reloading,false))});
        };
        class Is_Targeting {
            targetState = QUOTE(Check_Stance);

            condition = QUOTE(((behaviour _this) in [ARR_2(QN(COMBAT),QN(STEALTH))])\
            && {(QGETVAR(_this,suppressionFactor,0) < 20) || (QGETVAR(_this,suppressionImmunity,false))}\
            && {(_this targets []) isNotEqualTo []}\
            && {!(QGETVAR(_this,reloading,false))});
        };
        class No_target {
            targetState = QUOTE(Reset_Stance);

            condition = QUOTE(!((behaviour _this) in [ARR_2(QN(COMBAT),QN(STEALTH))])\
            && {(QGETVAR(_this,suppressionFactor,0) < 20) || (QGETVAR(_this,suppressionImmunity,false))}\
            && {(_this targets []) isEqualTo []}\
            && {QGETVAR(_this,US_SetStance,false)}\
            && {!(QGETVAR(_this,reloading,false))});
        };
        class No_Enemy_Targets {
            targetState = QUOTE(Wait);

            condition = QUOTE(true);
        };
    };
    class Check_Suppression {
        onStateEntered = QFUNC(US_onSESuppressionCheck);
        class Wait_Completed {
            targetState = QUOTE(Unit_Checks);
            conditionFrequency = 2;
            condition = QUOTE(true);
        };
    };
    class Check_Stance {
        onStateEntered = QFUNC(US_onSEStanceCheck);
        class Wait_Completed {
            targetState = QUOTE(Unit_Checks);
            conditionFrequency = 2;
            condition = QUOTE(true);
        };
    };
    class Wait {
        onStateEntered = "";
        class Wait_Completed {
            targetState = QUOTE(Unit_Checks);
            conditionFrequency = 2;
            condition = QUOTE(true);
        };
    };
    class Reset_Stance {
        onStateEntered = QFUNC(US_onSEStanceCheck);
        class Wait_Completed {
            targetState = QUOTE(Unit_Checks);
            conditionFrequency = 2;
            condition = QUOTE(true);
        };
    };
};
