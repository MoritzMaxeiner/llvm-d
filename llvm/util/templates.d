
module llvm.util.templates;

private
{
	import std.conv : to;
	import std.traits : isArray, isAssociativeArray, isCallable;
}

public string MixinMap(List,Function)(List l, Function f)
in
{
	assert(isArray!(List) || isAssociativeArray!(List));
	assert(isCallable!(Function));
}
body
{
	string code = "";

	/+ Store the list (which may be coming in as
		 + an enum (e.g. "enum string[] ...") in a
		 + variable, so in case of an enum it won't
		 + get simply textual-copied everywhere inside
		 + the function - which would slow this down
		 + significantly, so DO NOT REMOVE! +/
	List list = l;

	static if(isAssociativeArray!(List))
	{
		alias typeof(list.keys[0]) Index;
		alias typeof(list.values[0]) Value;
	}
	else
	{
		alias size_t Index;
		alias typeof(list[0]) Value;
	}

	foreach(Index index, Value value; l)
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

/+public template MixinMap(alias list, alias f)
{
	const char[] MixinMap = ctfe_worker();

	char[] ctfe_worker()
	{
		alias typeof(list) List;
		/+ Store the list (which may be coming in as
		 + an enum (e.g. "enum string[] ...") in a
		 + variable, so in case of an enum it won't
		 + get simply textual-copied everywhere inside
		 + the function - which would slow this down
		 + significantly, so DO NOT REMOVE! +/
		List list = list;
		char[] code = null;

		/+ We need the list as an array +/
		assert(isArray!(List) || isAssociativeArray!(List));

		static if(isAssociativeArray!(List))
		{
			alias typeof(list.keys[0]) Index;
			alias typeof(list.values[0]) Value;
		}
		else
		{
			alias size_t Index;
			alias typeof(list[0]) Value;
		}

		foreach(Index index, Value value; list)
		{
			code ~= f(index, value);
		}

		return code;
	}
}

public template MixinMap_VersionedEnum(
	string enumName,
	string enumType,
	string enumVersion,
	alias enumList)
{
	const char[] MixinMap_VersionedEnum = ctfe_worker();

	char[] ctfe_worker()
	{
		return "enum"
			~ (enumName !is null ? (" " ~ enumName) : "")
			~ (enumType !is null ? (" : " ~ enumType) : "")
			~ " { "
			~ MixinMap!(
				enumList,
				function const(char)[] (string item, string[] change)
				{
					if((change is null) ||
					   ((change[0] == "+") && (to!float(change[1]) <= to!float(enumVersion))) ||
					   ((change[0] == "-") && (to!float(change[1]) > to!float(enumVersion))))
					{
						return item ~ ",";
					}
					return null;
				})[0..$-1] ~ " }";
	}
}+/