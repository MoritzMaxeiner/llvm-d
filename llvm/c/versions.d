
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
//else version(LLVM_3_6) __gshared immutable string LLVM_VersionString = "3.6";
//else version(LLVM_3_7) __gshared immutable string LLVM_VersionString = "3.7";
else __gshared immutable string LLVM_VersionString = "3.4";

__gshared immutable float LLVM_Version = to!float(LLVM_VersionString);

__gshared immutable float LLVM_Trunk = 3.8;
