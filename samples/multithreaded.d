module samples.multithreaded;

import std.stdio;

import llvm.d.llvm_c;

void main(string[] args)
{
	static if((3.3 <= LLVM_Version) && (LLVM_Version < 3.5))
	{
		writefln("LLVM multithreading on? %s", cast(bool) LLVMIsMultithreaded());
		writefln("Turning it on"); LLVMStartMultithreaded();
		writefln("LLVM multithreading on? %s", cast(bool) LLVMIsMultithreaded());
		writefln("Turning it off"); LLVMStopMultithreaded();
		writefln("LLVM multithreading on? %s", cast(bool) LLVMIsMultithreaded());
	}
}
