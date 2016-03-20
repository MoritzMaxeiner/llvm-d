
module llvm.util.templates;

private
{
	import std.conv : to;
	import std.traits : isArray, isAssociativeArray, isCallable;
	import llvm.c.versions;
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

public string MixinMap_VersionedEnum(List)(string enumName, string enumType, ulong enumVersion, List enumList)
if(isAssociativeArray!(List))
{
	return "enum"
		~ (enumName != "" ? (" " ~ enumName) : "")
			~ (enumType != "" ? (" : " ~ enumType) : "")
			~ " { "
			~ MixinMap(enumList, delegate string (string item, string[] change)
				{
					if((change is null) ||
						((change[0] == "+") && (LLVMDVersion(change[1].to!ushort, change[2].to!ushort, change[3].to!ushort) <= enumVersion)) ||
						((change[0] == "-") && (LLVMDVersion(change[1].to!ushort, change[2].to!ushort, change[3].to!ushort) > enumVersion)))
					{
						return item ~ ",";
					}

					return "";
				})[0..$-1] ~ " }";
}
