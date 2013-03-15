module samples.multithreaded;

import std.stdio;

import llvm.all;

void main(string[] args)
{
	if(!LLVM.loaded)
	{
		LLVM.loadFromPath("lib");
	}

	static if(LLVM_Version >= 3.3)
	{
		writefln("LLVM multithreading on? %s", cast(bool) LLVMIsMultithreaded());
		writefln("Turning it on"); LLVMStartMultithreaded();
		writefln("LLVM multithreading on? %s", cast(bool) LLVMIsMultithreaded());
		writefln("Turning it off"); LLVMStopMultithreaded();
		writefln("LLVM multithreading on? %s", cast(bool) LLVMIsMultithreaded());
	}
}
