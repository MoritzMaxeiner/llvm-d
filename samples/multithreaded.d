module samples.multithreaded;

import std.stdio;

import llvm.d.llvm_c;

void main(string[] args)
{
	LLVM.load();
	
	static if((LLVMDVersion(3, 3, 0) <= LLVM_Version) && (LLVM_Version < LLVMDVersion(3, 5, 0)))
	{
		writefln("LLVM multithreading on? %s", cast(bool) LLVMIsMultithreaded());
		writefln("Turning it on"); LLVMStartMultithreaded();
		writefln("LLVM multithreading on? %s", cast(bool) LLVMIsMultithreaded());
		writefln("Turning it off"); LLVMStopMultithreaded();
		writefln("LLVM multithreading on? %s", cast(bool) LLVMIsMultithreaded());
	}
}
