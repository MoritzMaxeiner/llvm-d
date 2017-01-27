
module llvm.c.config;

private
{
	import std.conv : to;
	import std.algorithm;
	import std.range;
	import std.array;
	import std.algorithm.iteration : filter;
	import std.algorithm.searching : canFind;
}

/// Makes an ordered identifier from a major, minor, and patch number
pure nothrow @nogc
ulong LLVMDVersion(ushort major, ushort minor, ushort patch)
{
	return cast(ulong)(major) << (ushort.sizeof*2*8) | cast(ulong)(minor) << (ushort.sizeof*8) | cast(ulong)(patch);
}

private enum KnownVersions = [
	[3,9,1],
	[3,9,0],
	[3,8,1],
	[3,8,0],
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

// Qualifiers are expressed in the form ["+", "3", "2, "0", "-", "3", "5", "0"].
// The example translates to "added in LLVM 3.2.0 and removed in LLVM 3.5.0"
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


immutable LLVM_Targets = {
	string[] targets;
	mixin({
		       static if (LLVM_Version >= LLVMDVersion(3, 9, 0)) {
			return ["AArch64","AMDGPU","ARM","AVR","BPF","Hexagon","Lanai","MSP430","Mips","NVPTX","PowerPC","Sparc","SystemZ","WebAssembly","X86","XCore"];
		} else static if (LLVM_Version >= LLVMDVersion(3, 8, 0)) {
			return ["AArch64","AMDGPU","ARM","AVR","BPF","CppBackend","Hexagon","MSP430","Mips","NVPTX","PowerPC","Sparc","SystemZ","WebAssembly","X86","XCore"];
		} else static if (LLVM_Version >= LLVMDVersion(3, 7, 0)) {
			return ["AArch64","AMDGPU","ARM","BPF","CppBackend","Hexagon","MSP430","Mips","NVPTX","PowerPC","Sparc","SystemZ","WebAssembly","X86","XCore"];
		} else static if (LLVM_Version >= LLVMDVersion(3, 6, 0)) {
			return ["AArch64","ARM","CppBackend","Hexagon","MSP430","Mips","NVPTX","PowerPC","R600","Sparc","SystemZ","X86","XCore"];
		} else static if (LLVM_Version >= LLVMDVersion(3, 5, 0)) {
			return ["AArch64","ARM","CppBackend","Hexagon","MSP430","Mips","NVPTX","PowerPC","R600","Sparc","SystemZ","X86","XCore"];
		} else static if (LLVM_Version >= LLVMDVersion(3, 4, 0)) {
			return ["AArch64","ARM","CppBackend","Hexagon","MSP430","Mips","NVPTX","PowerPC","R600","Sparc","SystemZ","X86","XCore"];
		} else static if (LLVM_Version >= LLVMDVersion(3, 3, 0)) {
			return ["AArch64","ARM","CppBackend","Hexagon","MBlaze","MSP430","Mips","NVPTX","PowerPC","R600","Sparc","SystemZ","X86","XCore"];
		} else static if (LLVM_Version >= LLVMDVersion(3, 2, 0)) {
			return ["ARM","CellSPU","CppBackend","Hexagon","MBlaze","MSP430","Mips","NVPTX","PTX","PowerPC","Sparc","X86","XCore"];
		} else {
			return ["ARM","CellSPU","CppBackend","Hexagon","MBlaze","MSP430","Mips","PTX","PowerPC","Sparc","X86","XCore"];
		}
	}().map!(t => "version (LLVM_Target_" ~ t ~ ") targets ~= \"" ~ t ~ "\";").joiner.array);
	return targets;
}();

immutable LLVM_AsmPrinters = {
	       static if (LLVM_Version >= LLVMDVersion(3, 9, 0)) {
		return ["AArch64","AMDGPU","ARM","BPF","Hexagon","Lanai","MSP430","Mips","NVPTX","PowerPC","Sparc","SystemZ","WebAssembly","X86","XCore"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 8, 0)) {
		return ["AArch64","AMDGPU","ARM","BPF","Hexagon","MSP430","Mips","NVPTX","PowerPC","Sparc","SystemZ","WebAssembly","X86","XCore"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 7, 0)) {
		return ["AArch64","AMDGPU","ARM","BPF","Hexagon","MSP430","Mips","NVPTX","PowerPC","Sparc","SystemZ","X86","XCore"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 6, 0)) {
		return ["AArch64","ARM","Hexagon","MSP430","Mips","NVPTX","PowerPC","R600","Sparc","SystemZ","X86","XCore"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 5, 0)) {
		return ["AArch64","ARM","Hexagon","MSP430","Mips","NVPTX","PowerPC","R600","Sparc","SystemZ","X86","XCore"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 4, 0)) {
		return ["AArch64","ARM","Hexagon","MSP430","Mips","NVPTX","PowerPC","R600","Sparc","SystemZ","X86","XCore"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 3, 0)) {
		return ["AArch64","ARM","Hexagon","MBlaze","MSP430","Mips","NVPTX","PowerPC","R600","Sparc","SystemZ","X86","XCore"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 2, 0)) {
		return ["ARM","CellSPU","Hexagon","MBlaze","MSP430","Mips","NVPTX","PowerPC","Sparc","X86","XCore"];
	} else {
		return ["ARM","CellSPU","Hexagon","MBlaze","MSP430","Mips","PTX","PowerPC","Sparc","X86","XCore"];
	}
}().filter!(t => LLVM_Targets.canFind(t)).array;

immutable LLVM_AsmParsers = {
	       static if (LLVM_Version >= LLVMDVersion(3, 9, 0)) {
		return ["AArch64","AMDGPU","ARM","Hexagon","Lanai","Mips","PowerPC","Sparc","SystemZ","X86"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 8, 0)) {
		return ["AArch64","AMDGPU","ARM","Hexagon","Mips","PowerPC","Sparc","SystemZ","X86"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 7, 0)) {
		return ["AArch64","AMDGPU","ARM","Mips","PowerPC","Sparc","SystemZ","X86"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 6, 0)) {
		return ["AArch64","ARM","Mips","PowerPC","R600","Sparc","SystemZ","X86"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 5, 0)) {
		return ["AArch64","ARM","Mips","PowerPC","Sparc","SystemZ","X86"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 4, 0)) {
		return ["AArch64","ARM","Mips","PowerPC","SystemZ","X86"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 3, 0)) {
		return ["AArch64","ARM","MBlaze","Mips","PowerPC","SystemZ","X86"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 2, 0)) {
		return ["ARM","MBlaze","Mips","X86"];
	} else {
		return ["ARM","MBlaze","Mips","X86"];
	}
}().filter!(t => LLVM_Targets.canFind(t)).array;

immutable LLVM_Disassemblers = {
	       static if (LLVM_Version >= LLVMDVersion(3, 9, 0)) {
		return ["AArch64","AMDGPU","ARM","Hexagon","Lanai","Mips","PowerPC","Sparc","SystemZ","WebAssembly","X86","XCore"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 8, 0)) {
		return ["AArch64","ARM","Hexagon","Mips","PowerPC","Sparc","SystemZ","WebAssembly","X86","XCore"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 7, 0)) {
		return ["AArch64","ARM","Hexagon","Mips","PowerPC","Sparc","SystemZ","X86","XCore"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 6, 0)) {
		return ["AArch64","ARM","Hexagon","Mips","PowerPC","Sparc","SystemZ","X86","XCore"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 5, 0)) {
		return ["AArch64","ARM","Mips","PowerPC","Sparc","SystemZ","X86","XCore"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 4, 0)) {
		return ["AArch64","ARM","Mips","SystemZ","X86","XCore"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 3, 0)) {
		return ["AArch64","ARM","MBlaze","Mips","X86","XCore"];
	} else static if (LLVM_Version >= LLVMDVersion(3, 2, 0)) {
		return ["ARM","MBlaze","Mips","X86"];
	} else {
		return ["ARM","MBlaze","Mips","X86"];
	}
}().filter!(t => LLVM_Targets.canFind(t)).array;

immutable LLVM_NativeTarget = {
	auto t = {
		     version(X86)     return "X86";
		else version(X86_64)  return "X86";
		else version(SPARC)   return "Sparc";
		else version(SPARC64) return "Sparc";
		else version(PPC)     return "PowerPC";
		else version(PPC64)   return "PowerPC";
		else version(AArch64) return "AArch64";
		else version(ARM)     return "ARM";
		else version(MIPS32)  return "Mips";
		else version(MIPS64)  return "Mips";
		else version(SystemZ) return "SystemZ";
		else                  return "";
	}();
	if (t != "" && LLVM_Targets.canFind(t)) return t;
	else return "";
}();