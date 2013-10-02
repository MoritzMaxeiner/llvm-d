module samples.fibonacci;

import std.conv : to;
import std.stdio : writefln, writeln;

import llvm.d.llvm_c;

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
	
	version(Windows)
	{
		/+ On Windows, we can only use the old JIT for now +/
		LLVMCreateJITCompilerForModule(&engine, _module, 2, &error);
	}
	else
	{
		// Ran into some issues under Arch, so comment the new MVJIT out for now
		/+static if(LLVM_Version >= 3.3)
		{
			/+ On other systems we should be able to use the newer
			 + MCJIT instead - if we have a high enough LLVM version +/
			LLVMMCJITCompilerOptions options;
			LLVMInitializeMCJITCompilerOptions(&options, options.sizeof);

			LLVMCreateMCJITCompilerForModule(&engine, _module, &options, options.sizeof, &error);
		}
		else
		{+/
			LLVMCreateJITCompilerForModule(&engine, _module, 2, &error);
		//}
	}

	if(error !is null)
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
