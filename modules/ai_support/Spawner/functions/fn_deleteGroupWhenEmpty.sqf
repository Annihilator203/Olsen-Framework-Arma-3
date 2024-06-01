#include "script_component.hpp"
private _group = _this select 0;
if (local _group) then{
	_group deleteGroupWhenEmpty true;
}
else // group is local to a client
{
	[_group, true] remoteExec ["deleteGroupWhenEmpty", groupOwner _group];
};