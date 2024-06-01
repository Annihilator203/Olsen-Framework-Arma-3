//["Test,123,123,Test", "Test"] call _fnc_findStringsInString; // returns [0, 13]

params ["_string", "_search"];
if (_string == "") exitWith { [] };
private _searchLength = count _search;
private _return = [];
private _i = 0;
private _index = 0;
while { _index = _string find _search; _index != -1 } do
{
	_string = _string select [_index + _searchLength];
	_i = _i + _index + _searchLength;
	_return pushBack _i - _searchLength;
};
_return;
