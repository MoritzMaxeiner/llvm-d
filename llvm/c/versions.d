
module llvm.c.versions;

private
{
	import std.conv : to;
	import std.algorithm;
	import std.range;
}

/// Makes an ordered identifier from a major, minor, and patch number
pure nothrow @nogc
ulong LLVMDVersion(ushort major, ushort minor, ushort patch)
{
	return cast(ulong)(major) << (ushort.sizeof*2*8) | cast(ulong)(minor) << (ushort.sizeof*8) | cast(ulong)(patch);
}

private enum KnownVersions = [
	[3,7,1],
	[3,7,0],
	[3,6,2],
	[3,6,1],
	[3,6,0],
	[3,5,2],
	[3,5,1],
	[3,5,0],
	[3,4,2],
	[3,4,1],
	[3,4,0],
	[3,3,0],
	[3,2,0],
	[3,1,0],
];

mixin(KnownVersions.map!(ver =>
	q{version(LLVM_%MAJOR_%MINOR_%PATCH) {
			enum LLVM_VERSION_MAJOR = %MAJOR;
			enum LLVM_VERSION_MINOR = %MINOR;
			enum LLVM_VERSION_PATCH = %PATCH;
		}}.replace("%MAJOR", ver[0].to!string).replace("%MINOR", ver[1].to!string).replace("%PATCH", ver[2].to!string)
	).join("else\n") ~
	q{else {
		enum LLVM_VERSION_MAJOR = KnownVersions[0][0];
		enum LLVM_VERSION_MINOR = KnownVersions[0][1];
		enum LLVM_VERSION_PATCH = KnownVersions[0][2];
	}}
);

/// LLVM Version that LLVM-D was compiled with
enum LLVM_Version = LLVMDVersion(LLVM_VERSION_MAJOR, LLVM_VERSION_MINOR, LLVM_VERSION_PATCH);
/// ditto
enum LLVM_VersionString = LLVM_VERSION_MAJOR.to!string ~ "." ~ LLVM_VERSION_MINOR.to!string ~ "." ~ LLVM_VERSION_PATCH.to!string;

//qualifiers is in the form ["+", "3", "2, "0", "-", "3", "5", "0"]
bool matchVersionQualifiers(string[] qualifiers)
{
	while(qualifiers.length > 0)
	{
		string op = qualifiers[0];
		ulong ver = LLVMDVersion(qualifiers[1].to!ushort, qualifiers[2].to!ushort, qualifiers[3].to!ushort);
		if((op == "+" && LLVM_Version < ver) ||
		   (op == "-" && LLVM_Version >= ver))
		{
			return false;
		}
		qualifiers = qualifiers[4 .. $];
	}
	return true;
}
