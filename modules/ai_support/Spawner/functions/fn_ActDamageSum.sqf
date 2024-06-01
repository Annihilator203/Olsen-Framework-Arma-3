#include "script_component.hpp"
params ["_veh"];	
private _sum = 0;

if (count (getAllHitPointsDamage _veh)> 0) then
{
{
	_sum = _sum + _x;
} foreach ((getAllHitPointsDamage _veh) select 2);	
};
_sum