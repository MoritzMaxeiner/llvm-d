
module llvm.util.templates;

private
{
	import std.conv : to;
	import std.traits : isArray, isAssociativeArray, isCallable;
}

public string MixinMap(List,Function)(List list, Function f)
in
{
	assert(isArray!(List) || isAssociativeArray!(List));
	assert(isCallable!(Function));
}
body
{
	string code = "";

	foreach(index, value; list)
	{
		code ~= f(index, value);
	}
	
	return code;
}

public string MixinMap_VersionedEnum(List)(string enumName, string enumType, float enumVersion, List enumList)
in
{
	assert(isArray!(List) || isAssociativeArray!(List));
}
body
{
	return "enum"
		~ (enumName != "" ? (" " ~ enumName) : "")
			~ (enumType != "" ? (" : " ~ enumType) : "")
			~ " { "
			~ MixinMap(enumList, delegate string (string item, string[] change)
				{
					if((change is null) ||
						((change[0] == "+") && (to!float(change[1]) <= enumVersion)) ||
						((change[0] == "-") && (to!float(change[1]) > enumVersion)))
					{
						return item ~ ",";
					}

					return "";
				})[0..$-1] ~ " }";
}
