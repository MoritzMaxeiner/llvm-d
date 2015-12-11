llvm-d
======

[![Build Status](https://travis-ci.org/Calrama/llvm-d.svg?branch=master)](https://travis-ci.org/Calrama/llvm-d)

**llvm-d** provides bindings to LLVM for the D programming language.

It does so by automatically loading the LLVM dynamic library at program startup
and binding to LLVM's C API functions.

Usage
-----

To use **llvm-d** you just need to import it and then you can use
the functions defined by LLVM's C API. For example:

```d
module samples.multithreaded;

import llvm.all;
import std.stdio;

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
```

Note that a static if is used to assure that the function calls are only compiled
in if **llvm-d** is set to compile for at least the LLVM version that is needed
(the multithreaded functions where added to LLVM's C API in the 3.3 development
cycle and removed in the 3.5 development cycle; thus they are only available in versions 3.3 and 3.4).

A more complex example showing how to calculate the fibonacci series:

```d
module samples.fibonacci;

import std.conv : to;
import std.stdio : writefln, writeln;

import llvm.all;
import llvm.util.memory;

int main(string[] args)
{
	char* error;

	LLVMInitializeNativeTarget();
	auto _module = LLVMModuleCreateWithName("fibonacci".toCString());
	auto f_args = [ LLVMInt32Type() ];
	auto f = LLVMAddFunction(
		_module,
		"fib",
		LLVMFunctionType(LLVMInt32Type(), f_args.ptr, 1, cast(LLVMBool) false));
	LLVMSetFunctionCallConv(f, LLVMCCallConv);
	
	auto n = LLVMGetParam(f, 0);
	
	auto entry = LLVMAppendBasicBlock(f, "entry".toCString());
	auto case_base0 = LLVMAppendBasicBlock(f, "case_base0".toCString());
	auto case_base1 = LLVMAppendBasicBlock(f, "case_base1".toCString());
	auto case_default = LLVMAppendBasicBlock(f, "case_default".toCString());
	auto end = LLVMAppendBasicBlock(f, "end".toCString());
	auto builder = LLVMCreateBuilder();
	
	/+ Entry basic block +/
	LLVMPositionBuilderAtEnd(builder, entry);
	auto Switch = LLVMBuildSwitch(
		builder,
		n,
		case_default,
		2);
	LLVMAddCase(Switch, LLVMConstInt(LLVMInt32Type(), 0, cast(LLVMBool) false), case_base0);
	LLVMAddCase(Switch, LLVMConstInt(LLVMInt32Type(), 1, cast(LLVMBool) false), case_base1);

	/+ Basic block for n = 0: fib(n) = 0 +/
	LLVMPositionBuilderAtEnd(builder, case_base0);
	auto res_base0 = LLVMConstInt(LLVMInt32Type(), 0, cast(LLVMBool) false);
	LLVMBuildBr(builder, end);
	
	/+ Basic block for n = 1: fib(n) = 1 +/
	LLVMPositionBuilderAtEnd(builder, case_base1);
	auto res_base1 = LLVMConstInt(LLVMInt32Type(), 1, cast(LLVMBool) false);
	LLVMBuildBr(builder, end);
	
	/+ Basic block for n > 1: fib(n) = fib(n - 1) + fib(n - 2) +/
	LLVMPositionBuilderAtEnd(builder, case_default);

	auto n_minus_1 = LLVMBuildSub(
		builder,
		n,
		LLVMConstInt(LLVMInt32Type(), 1, cast(LLVMBool) false),
		"n - 1".toCString());
	auto call_f_1_args = [ n_minus_1 ];
	auto call_f_1 = LLVMBuildCall(builder, f, call_f_1_args.ptr, 1, "fib(n - 1)".toCString());
	
	auto n_minus_2 = LLVMBuildSub(
		builder,
		n,
		LLVMConstInt(LLVMInt32Type(), 2, cast(LLVMBool) false),
		"n - 2".toCString());
	auto call_f_2_args = [ n_minus_2 ];
	auto call_f_2 = LLVMBuildCall(builder, f, call_f_2_args.ptr, 1, "fib(n - 2)".toCString());
	
	auto res_default = LLVMBuildAdd(builder, call_f_1, call_f_2, "fib(n - 1) + fib(n - 2)".toCString());
	LLVMBuildBr(builder, end);
	
	/+ Basic block for collecting the result +/
	LLVMPositionBuilderAtEnd(builder, end);
	auto res = LLVMBuildPhi(builder, LLVMInt32Type(), "result".toCString());
	auto phi_vals = [ res_base0, res_base1, res_default ];
	auto phi_blocks = [ case_base0, case_base1, case_default ];
	LLVMAddIncoming(res, phi_vals.ptr, phi_blocks.ptr, 3);
	LLVMBuildRet(builder, res);
	
	LLVMVerifyModule(_module, LLVMAbortProcessAction, &error);
	LLVMDisposeMessage(error);
	
	LLVMExecutionEngineRef engine;
	error = null;
	if(cast(bool) LLVMCreateJITCompilerForModule(&engine, _module, 2, &error))
	{
		writefln("%s", error.fromCString());
		LLVMDisposeMessage(error);
		return 1;
	}
	
	auto pass = LLVMCreatePassManager();
	LLVMAddTargetData(LLVMGetExecutionEngineTargetData(engine), pass);
	LLVMAddConstantPropagationPass(pass);
	LLVMAddInstructionCombiningPass(pass);
	LLVMAddPromoteMemoryToRegisterPass(pass);
	LLVMAddGVNPass(pass);
	LLVMAddCFGSimplificationPass(pass);
	LLVMRunPassManager(pass, _module);
	
	writefln("The following module has been generated for the fibonacci series:\n");
	LLVMDumpModule(_module);
	
	writeln();
	
	int n_exec= 10;
	if(args.length > 1)
	{
		n_exec = to!int(args[1]);
	}
	else
	{
		writefln("; Argument for fib missing on command line, using default:  \"%d\"", n_exec);
	}
	
	auto exec_args = [ LLVMCreateGenericValueOfInt(LLVMInt32Type(), n_exec, cast(LLVMBool) 0) ];
	writefln("; Running (jit-compiled) fib(%d)...", n_exec);
	auto exec_res = LLVMRunFunction(engine, f, 1, exec_args.ptr);
	writefln("; fib(%d) = %d", n_exec, LLVMGenericValueToInt(exec_res, 0));
	
	LLVMDisposePassManager(pass);
	LLVMDisposeBuilder(builder);
	LLVMDisposeExecutionEngine(engine);
	return 0;	
}
```

LLVM versions
-------------

The LLVM version to be used is selected via D's conditional compilatidon
"version" system (For dmd that is set via the "-version" flag).

The identifier to set the LLVM version is defined as
"LLVM_{MAJOR_VERSION}_{MINOR_VERSION}", so to get LLVM version 3.1
use "LLVM_3_1" (without the quotes).

Current supported versions are 3.1 - 3.7 and if no version is given
at compile time, 3.7 will be assumed.

Documentation
-------------

The documentation for LLVM's C API can be found [here](http://llvm.org/doxygen/modules.html).

License
-------

**llvm-d** is released under the MIT license, see LICENSE.txt
or [here](http://opensource.org/licenses/MIT) for more details.

**llvm-d** uses source code from LLVM that has been ported to D for accessing LLVM's C API. The above paragraph does not apply
to that source code - it is a redistribution of LLVM source code.

**LLVM is Copyright (c) 2003-2015 University of Illinois at Urbana-Champaign.
All rights reserved.**

**LLVM is distributed under the University of Illinois Open Source
License. See http://opensource.org/licenses/UoI-NCSA.php for details.**
