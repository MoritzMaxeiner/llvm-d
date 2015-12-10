
module llvm.c.versions;

private
{
	import std.conv : to;
}

version(LLVM_3_1) __gshared immutable string LLVM_VersionString = "3.1";
else version(LLVM_3_2) __gshared immutable string LLVM_VersionString = "3.2";
else version(LLVM_3_3) __gshared immutable string LLVM_VersionString = "3.3";
else version(LLVM_3_4) __gshared immutable string LLVM_VersionString = "3.4";
else version(LLVM_3_5) __gshared immutable string LLVM_VersionString = "3.5";
else version(LLVM_3_6) __gshared immutable string LLVM_VersionString = "3.6";
else version(LLVM_3_7) __gshared immutable string LLVM_VersionString = "3.7";
else __gshared immutable string LLVM_VersionString = "3.7";

__gshared immutable float LLVM_Version = to!float(LLVM_VersionString);

__gshared immutable float LLVM_Trunk = 3.8;

//qualifiers is in the form ["+", "3.3", "-", "3.5"]
bool matchVersionQualifiers(string[] qualifiers)
{
	while(qualifiers.length > 0)
	{
		string op = qualifiers[0];
		//TODO: use a proper semantic version type?
		//(floats may exhibit rounding issues.)
		float ver = to!float(qualifiers[1]);
		if((op == "+" && LLVM_Version < ver) ||
		   (op == "-" && LLVM_Version >= ver))
		{
			return false;
		}
		qualifiers = qualifiers[2 .. $];
	}
	return true;
}
