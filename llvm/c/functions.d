
module llvm.c.functions;

private
{
	import llvm.util.templates;

	import llvm.c.versions;
	import llvm.c.types;
}

extern(System)
{
	mixin(MixinMap!(
		      LLVMC_Functions,
		      function const(char)[] (string symbol, string[] signature)
		      {
			      if((signature.length == 1) ||
			         ((signature[1] == "+") && (to!float(signature[2]) <= LLVM_Version)) ||
			         ((signature[1] == "-") && (to!float(signature[2]) > LLVM_Version)))
			      {
				      return "alias nothrow " ~ signature[0] ~ " da_" ~ symbol ~ ";";
			      }
			      return null;
		      }
		      ));
}

__gshared
{
	mixin(MixinMap!(
		      LLVMC_Functions,
		      function const(char)[] (string symbol, string[] signature)
		      {
			      if((signature.length == 1) ||
			         ((signature[1] == "+") && (to!float(signature[2]) <= LLVM_Version)) ||
			         ((signature[1] == "-") && (to!float(signature[2]) > LLVM_Version)))
			      {
				      return "da_" ~ symbol ~ " " ~ symbol ~ ";";
			      }
			      return null;
		      }
		      ));

	mixin(MixinMap!([
		                "TargetInfo",
		                "Target",
		                "TargetMC",
		                "AsmPrinter",
		                "AsmParser",
		                "Disassembler"],
	                function const(char)[](size_t i, string capability)
	                {
		                char[] genOnlyTargetsWithCapability()
		                {
			                auto capabilities = LLVMC_TargetCapabilities;
			                char[] code = null;

			                foreach(string target; capabilities.keys)
			                {
				                foreach(string targetCapability; capabilities[target])
				                {
					                if(capability == targetCapability)
					                {
						                code ~= "if(LLVMInitialize"
							                ~ target ~ capability
							                ~ " !is null) { LLVMInitialize"
							                ~ target ~ capability
							                ~ "(); } ";
						                break;
					                }
				                }
			                }

			                return code;
		                }

		                return "nothrow void LLVMInitializeAll" ~ capability ~ "s() { "
			                ~ genOnlyTargetsWithCapability()
			                ~ " }";
	                }));

	nothrow LLVMBool LLVMInitializeNativeTarget()
	{
		mixin(MixinMap!(["ARM64" : "AArch64",
		                 "ARM" : "ARM",
		                 "X86" : "X86",
		                 "X86_64" : "X86",
		                 "MIPS" : "Mips",
		                 "PPC" : "PowerPC",
		                 "PPC64" : "PowerPC",
		                 "SPARC" : "Sparc",
		                 "SPARC64" : "SPARC64"],
		                function const(char)[](string arch, string target)
		                {
			                return "version(" ~ arch ~ ") {"
				                ~ " if((LLVMInitialize" ~ target ~ "TargetInfo !is null)"
				                ~ " && (LLVMInitialize" ~ target ~ "Target !is null)"
				                ~ " && (LLVMInitialize" ~ target ~ "TargetMC !is null)) {"
				                ~ " LLVMInitialize" ~ target ~ "TargetInfo();"
				                ~ " LLVMInitialize" ~ target ~ "Target();"
				                ~ " LLVMInitialize" ~ target ~ "TargetMC();"
				                ~ " return 0; }}";
		                }
			      ));

		return 1;
	}
}

private enum string[][string] LLVMC_TargetCapabilities = [
	"AArch64" : ["TargetInfo", "Target", "TargetMC", "AsmParser", "AsmPrinter", "Disassembler"],
	"ARM" : ["TargetInfo", "Target", "TargetMC", "AsmParser", "AsmPrinter", "Disassembler"],
	"CppBackend" : ["TargetInfo", "Target", "TargetMC"],
	"Hexagon" : ["TargetInfo", "Target", "TargetMC", "AsmPrinter"],
	"MBlaze" : ["TargetInfo", "Target", "TargetMC", "AsmParser", "AsmPrinter", "Disassembler"],
	"Mips" : ["TargetInfo", "Target", "TargetMC", "AsmParser", "AsmPrinter", "Disassembler"],
	"MSP430" : ["TargetInfo", "Target", "TargetMC", "AsmPrinter"],
	"NVPTX" : ["TargetInfo", "Target", "TargetMC", "AsmPrinter"],
	"PowerPC" : ["TargetInfo", "Target", "TargetMC", "AsmPrinter"],
	"Sparc" : ["TargetInfo", "Target", "TargetMC", "AsmPrinter"],
	"X86" : ["TargetInfo", "Target", "TargetMC", "AsmParser", "AsmPrinter", "Disassembler"],
	"XCore" : ["TargetInfo", "Target", "TargetMC", "AsmPrinter", "Disassembler"],
	];

package enum string[][string] LLVMC_Functions = [

	/+ Analysis +/

	"LLVMVerifyModule" : ["LLVMBool function(LLVMModuleRef M, LLVMVerifierFailureAction Action, char** OutMessage)"],
	"LLVMVerifyFunction" : ["LLVMBool function(LLVMValueRef Fn, LLVMVerifierFailureAction Action)"],
	"LLVMViewFunctionCFG" : ["void function(LLVMValueRef Fn)"],
	"LLVMViewFunctionCFGOnly" : ["void function(LLVMValueRef Fn)"],

	/+ Bit Reader +/

	"LLVMParseBitcode" : ["LLVMBool function(LLVMMemoryBufferRef MemBuf, LLVMModuleRef* OutModule, char** OutMessage)"],
	"LLVMParseBitcodeInContext" : ["LLVMBool function(LLVMContextRef ContextRef, LLVMMemoryBufferRef MemBuf, LLVMModuleRef* OutModule, char** OutMessage)"],
	"LLVMGetBitcodeModuleInContext" : ["LLVMBool function(LLVMContextRef ContextRef, LLVMMemoryBufferRef MemBuf, LLVMModuleRef* OutM, char** OutMessage)"],
	"LLVMGetBitcodeModule" : ["LLVMBool function(LLVMMemoryBufferRef MemBuf, LLVMModuleRef* OutM, char** OutMessage)"],
	"LLVMGetBitcodeModuleProviderInContext" : ["LLVMBool function(LLVMContextRef ContextRef, LLVMMemoryBufferRef MemBuf, LLVMModuleProviderRef* OutMP, char** OutMessage)"],
	"LLVMGetBitcodeModuleProvider" : ["LLVMBool function(LLVMMemoryBufferRef MemBuf, LLVMModuleProviderRef* OutMP, char** OutMessage)"],

	/+ Bit Writer +/

	"LLVMWriteBitcodeToFile" : ["int function(LLVMModuleRef M, const char* Path)"],
	"LLVMWriteBitcodeToFD" : ["int function(LLVMModuleRef M, int FD, int ShouldClose, int Unbuffered)"],
	"LLVMWriteBitcodeToFileHandle" : ["int function(LLVMModuleRef M, int Handle)"],

	/+ Transforms +/

	/++ Interprocedural transformations ++/

	"LLVMAddArgumentPromotionPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddConstantMergePass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddDeadArgEliminationPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddFunctionAttrsPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddFunctionInliningPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddAlwaysInlinerPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddGlobalDCEPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddGlobalOptimizerPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddIPConstantPropagationPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddPruneEHPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddIPSCCPPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddInternalizePass" : ["void function(LLVMPassManagerRef, uint AllButMain)"],
	"LLVMAddStripDeadPrototypesPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddStripSymbolsPass" : ["void function(LLVMPassManagerRef PM)"],

	/++ Pass manager builder ++/

	"LLVMPassManagerBuilderCreate" : ["LLVMPassManagerBuilderRef function()"],
	"LLVMPassManagerBuilderDispose" : ["void function(LLVMPassManagerBuilderRef PMB)"],
	"LLVMPassManagerBuilderSetOptLevel" : ["void function(LLVMPassManagerBuilderRef PMB, uint OptLevel)"],
	"LLVMPassManagerBuilderSetSizeLevel" : ["void function(LLVMPassManagerBuilderRef PMB, uint SizeLevel)"],
	"LLVMPassManagerBuilderSetDisableUnitAtATime" : ["void function(LLVMPassManagerBuilderRef PMB, LLVMBool Value)"],
	"LLVMPassManagerBuilderSetDisableUnrollLoops" : ["void function(LLVMPassManagerBuilderRef PMB, LLVMBool Value)"],
	"LLVMPassManagerBuilderSetDisableSimplifyLibCalls" : ["void function(LLVMPassManagerBuilderRef PMB, LLVMBool Value)"],
	"LLVMPassManagerBuilderUseInlinerWithThreshold" : ["void function(LLVMPassManagerBuilderRef PMB, uint Threshold)"],
	"LLVMPassManagerBuilderPopulateFunctionPassManager" : ["void function(LLVMPassManagerBuilderRef PMB, LLVMPassManagerRef PM)"],
	"LLVMPassManagerBuilderPopulateModulePassManager" : ["void function(LLVMPassManagerBuilderRef PMB, LLVMPassManagerRef PM)"],
	"LLVMPassManagerBuilderPopulateLTOPassManager" : ["void function(LLVMPassManagerBuilderRef PMB, LLVMPassManagerRef PM, LLVMBool Internalize, LLVMBool RunInliner)"],

	/++ Scalar transformations ++/

	"LLVMAddAggressiveDCEPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddCFGSimplificationPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddDeadStoreEliminationPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddGVNPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddIndVarSimplifyPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddInstructionCombiningPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddJumpThreadingPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddLICMPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddLoopDeletionPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddLoopIdiomPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddLoopRotatePass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddLoopUnrollPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddLoopUnswitchPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddMemCpyOptPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddPromoteMemoryToRegisterPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddReassociatePass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddSCCPPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddScalarReplAggregatesPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddScalarReplAggregatesPassSSA" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddScalarReplAggregatesPassWithThreshold" : ["void function(LLVMPassManagerRef PM, int Threshold)"],
	"LLVMAddSimplifyLibCallsPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddTailCallEliminationPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddConstantPropagationPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddDemoteMemoryToRegisterPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddVerifierPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddCorrelatedValuePropagationPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddEarlyCSEPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddLowerExpectIntrinsicPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddTypeBasedAliasAnalysisPass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddBasicAliasAnalysisPass" : ["void function(LLVMPassManagerRef PM)"],

	/++ Vectorization transformations ++/

	"LLVMAddBBVectorizePass" : ["void function(LLVMPassManagerRef PM)"],
	"LLVMAddLoopVectorizePass" : ["void function(LLVMPassManagerRef PM)",
	                              "+", "3.2"],

	/+ Core +/

	"LLVMShutdown" : ["void function()",
	                  "+", "3.3"],
	"LLVMDisposeMessage" : ["void function(char* Message)"],

	/++ Contexts ++/

	"LLVMContextCreate" : ["LLVMContextRef function()"],
	"LLVMGetGlobalContext" : ["LLVMContextRef function()"],
	"LLVMContextDispose" : ["void function(LLVMContextRef C)"],
	"LLVMGetMDKindIDInContext" : ["uint function(LLVMContextRef C, const char* Name, uint SLen)"],
	"LLVMGetMDKindID" : ["uint function(const char* Name, uint SLen)"],

	/++ Modules ++/

	"LLVMModuleCreateWithName" : ["LLVMModuleRef function(const char* ModuleID)"],
	"LLVMModuleCreateWithNameInContext" : ["LLVMModuleRef function(const char* ModuleID, LLVMContextRef C)"],
	"LLVMDisposeModule" : ["void function(LLVMModuleRef M)"],
	"LLVMGetDataLayout" : ["const(char)* function(LLVMModuleRef M)"],
	"LLVMSetDataLayout" : ["void function(LLVMModuleRef M, const char* Triple)"],
	"LLVMGetTarget" : ["const(char)* function(LLVMModuleRef M)"],
	"LLVMSetTarget" : ["void function(LLVMModuleRef M, const char* Triple)"],
	"LLVMDumpModule" : ["void function(LLVMModuleRef M)"],
	"LLVMPrintModuleToFile" : ["LLVMBool function(LLVMModuleRef M, const char* Filename, char** ErrorMessage)",
	                           "+", "3.2"],
	"LLVMSetModuleInlineAsm" : ["void function(LLVMModuleRef M, const char* Asm)"],
	"LLVMGetModuleContext" : ["LLVMContextRef function(LLVMModuleRef M)"],
	"LLVMGetTypeByName" : ["LLVMTypeRef function(LLVMModuleRef M, const char* Name)"],
	"LLVMGetNamedMetadataNumOperands" : ["uint function(LLVMModuleRef M, const char* name)"],
	"LLVMGetNamedMetadataOperands" : ["void function(LLVMModuleRef M, const char* name, LLVMValueRef *Dest)"],
	"LLVMAddNamedMetadataOperand" : ["void function(LLVMModuleRef M, const char* name, LLVMValueRef Val)"],
	"LLVMAddFunction" : ["LLVMValueRef function(LLVMModuleRef M, const char* Name, LLVMTypeRef FunctionTy)"],
	"LLVMGetNamedFunction" : ["LLVMValueRef function(LLVMModuleRef M, const char* Name)"],
	"LLVMGetFirstFunction" : ["LLVMValueRef function(LLVMModuleRef M)"],
	"LLVMGetLastFunction" : ["LLVMValueRef function(LLVMModuleRef M)"],
	"LLVMGetNextFunction" : ["LLVMValueRef function(LLVMValueRef Fn)"],
	"LLVMGetPreviousFunction" : ["LLVMValueRef function(LLVMValueRef Fn)"],

	/++ Types ++/

	"LLVMGetTypeKind" : ["LLVMTypeKind function(LLVMTypeRef Ty)"],
	"LLVMTypeIsSized" : ["LLVMBool function(LLVMTypeRef Ty)"],
	"LLVMGetTypeContext" : ["LLVMContextRef function(LLVMTypeRef Ty)"],

	/+++ Integer Types +++/

	"LLVMInt1TypeInContext" : ["LLVMTypeRef function(LLVMContextRef C)"],
	"LLVMInt8TypeInContext" : ["LLVMTypeRef function(LLVMContextRef C)"],
	"LLVMInt16TypeInContext" : ["LLVMTypeRef function(LLVMContextRef C)"],
	"LLVMInt32TypeInContext" : ["LLVMTypeRef function(LLVMContextRef C)"],
	"LLVMInt64TypeInContext" : ["LLVMTypeRef function(LLVMContextRef C)"],
	"LLVMIntTypeInContext" : ["LLVMTypeRef function(LLVMContextRef C, uint NumBits)"],
	"LLVMInt1Type" : ["LLVMTypeRef function()"],
	"LLVMInt8Type" : ["LLVMTypeRef function()"],
	"LLVMInt16Type" : ["LLVMTypeRef function()"],
	"LLVMInt32Type" : ["LLVMTypeRef function()"],
	"LLVMInt64Type" : ["LLVMTypeRef function()"],
	"LLVMIntType" : ["LLVMTypeRef function(uint NumBits)"],
	"LLVMGetIntTypeWidth" : ["uint function(LLVMTypeRef IntegerTy)"],

	/+++ Floating Point Types +++/

	"LLVMHalfTypeInContext" : ["LLVMTypeRef function(LLVMContextRef C)"],
	"LLVMFloatTypeInContext" : ["LLVMTypeRef function(LLVMContextRef C)"],
	"LLVMDoubleTypeInContext" : ["LLVMTypeRef function(LLVMContextRef C)"],
	"LLVMX86FP80TypeInContext" : ["LLVMTypeRef function(LLVMContextRef C)"],
	"LLVMFP128TypeInContext" : ["LLVMTypeRef function(LLVMContextRef C)"],
	"LLVMPPCFP128TypeInContext" : ["LLVMTypeRef function(LLVMContextRef C)"],
	"LLVMHalfType" : ["LLVMTypeRef function()"],
	"LLVMFloatType" : ["LLVMTypeRef function()"],
	"LLVMDoubleType" : ["LLVMTypeRef function()"],
	"LLVMX86FP80Type" : ["LLVMTypeRef function()"],
	"LLVMFP128Type" : ["LLVMTypeRef function()"],
	"LLVMPPCFP128Type" : ["LLVMTypeRef function()"],

	/+++ Function Types +++/

	"LLVMFunctionType" : ["LLVMTypeRef function(LLVMTypeRef ReturnType, LLVMTypeRef* ParamTypes, uint ParamCount, LLVMBool IsVarArg)"],
	"LLVMIsFunctionVarArg" : ["LLVMBool function(LLVMTypeRef FunctionTy)"],
	"LLVMGetReturnType" : ["LLVMTypeRef function(LLVMTypeRef FunctionTy)"],
	"LLVMCountParamTypes" : ["uint function(LLVMTypeRef FunctionTy)"],
	"LLVMGetParamTypes" : ["void function(LLVMTypeRef FunctionTy, LLVMTypeRef* Dest)"],

	/+++ Structure Types +++/

	"LLVMStructTypeInContext" : ["LLVMTypeRef function(LLVMContextRef C, LLVMTypeRef* ElementTypes, uint ElementCount, LLVMBool Packed)"],
	"LLVMStructType" : ["LLVMTypeRef function(LLVMTypeRef* ElementTypes, uint ElementCount, LLVMBool Packed)"],
	"LLVMStructCreateNamed" : ["LLVMTypeRef function(LLVMContextRef C, const char* Name)"],
	"LLVMGetStructName" : ["const(char)* function(LLVMTypeRef Ty)"],
	"LLVMStructSetBody" : ["void function(LLVMTypeRef StructTy, LLVMTypeRef* ElementTypes, uint ElementCount, LLVMBool Packed)"],
	"LLVMCountStructElementTypes" : ["uint function(LLVMTypeRef StructTy)"],
	"LLVMGetStructElementTypes" : ["void function(LLVMTypeRef StructTy, LLVMTypeRef* Dest)"],
	"LLVMIsPackedStruct" : ["LLVMBool function(LLVMTypeRef StructTy)"],
	"LLVMIsOpaqueStruct" : ["LLVMBool function(LLVMTypeRef StructTy)"],

	/+++ Sequential Types +++/

	"LLVMGetElementType" : ["LLVMTypeRef function(LLVMTypeRef Ty)"],
	"LLVMArrayType" : ["LLVMTypeRef function(LLVMTypeRef ElementType, uint ElementCount)"],
	"LLVMGetArrayLength" : ["uint function(LLVMTypeRef ArrayTy)"],
	"LLVMPointerType" : ["LLVMTypeRef function(LLVMTypeRef ElementType, uint AddressSpace)"],
	"LLVMGetPointerAddressSpace" : ["uint function(LLVMTypeRef PointerTy)"],
	"LLVMVectorType" : ["LLVMTypeRef function(LLVMTypeRef ElementType, uint ElementCount)"],
	"LLVMGetVectorSize" : ["uint function(LLVMTypeRef VectorTy)"],

	/+++ Other Types +++/

	"LLVMVoidTypeInContext" : ["LLVMTypeRef function(LLVMContextRef C)"],
	"LLVMLabelTypeInContext" : ["LLVMTypeRef function(LLVMContextRef C)"],
	"LLVMX86MMXTypeInContext" : ["LLVMTypeRef function(LLVMContextRef C)"],
	"LLVMVoidType" : ["LLVMTypeRef function()"],
	"LLVMLabelType" : ["LLVMTypeRef function()"],
	"LLVMX86MMXType" : ["LLVMTypeRef function()"],

	/++ Values ++/

	/+++ General APIs +++/

	"LLVMTypeOf" : ["LLVMTypeRef function(LLVMValueRef Val)"],
	"LLVMGetValueName" : ["const(char)* function(LLVMValueRef Val)"],
	"LLVMSetValueName" : ["void function(LLVMValueRef Val, const char *Name)"],
	"LLVMDumpValue" : ["void function(LLVMValueRef Val)"],
	"LLVMReplaceAllUsesWith" : ["void function(LLVMValueRef OldVal, LLVMValueRef NewVal)"],
	"LLVMIsConstant" : ["LLVMBool function(LLVMValueRef Val)"],
	"LLVMIsUndef" : ["LLVMBool function(LLVMValueRef Val)"],

	/+++ Usage +++/

	"LLVMGetFirstUse" : ["LLVMUseRef function(LLVMValueRef Val)"],
	"LLVMGetNextUse" : ["LLVMUseRef function(LLVMUseRef U)"],
	"LLVMGetUser" : ["LLVMValueRef function(LLVMUseRef U)"],
	"LLVMGetUsedValue" : ["LLVMValueRef function(LLVMUseRef U)"],

	/+++ User value +++/

	"LLVMGetOperand" : ["LLVMValueRef function(LLVMValueRef Val, uint Index)"],
	"LLVMSetOperand" : ["void function(LLVMValueRef User, uint Index, LLVMValueRef Val)"],
	"LLVMGetNumOperands" : ["int function(LLVMValueRef Val)"],

	/+++ Constants +++/

	"LLVMConstNull" : ["LLVMValueRef function(LLVMTypeRef Ty)"],
	"LLVMConstAllOnes" : ["LLVMValueRef function(LLVMTypeRef Ty)"],
	"LLVMGetUndef" : ["LLVMValueRef function(LLVMTypeRef Ty)"],
	"LLVMIsNull" : ["LLVMBool function(LLVMValueRef Val)"],
	"LLVMConstPointerNull" : ["LLVMValueRef function(LLVMTypeRef Ty)"],

	/++++ Scalar constants ++++/

	"LLVMConstInt" : ["LLVMValueRef function(LLVMTypeRef IntTy, ulong N, LLVMBool SignExtend)"],
	"LLVMConstIntOfArbitraryPrecision" : ["LLVMValueRef function(LLVMTypeRef IntTy, uint NumWords, const ulong* Words)"],
	"LLVMConstIntOfString" : ["LLVMValueRef function(LLVMTypeRef IntTy, const char* Text, ubyte Radix)"],
	"LLVMConstIntOfStringAndSize" : ["LLVMValueRef function(LLVMTypeRef IntTy, const char* Text, uint SLen, ubyte Radix)"],
	"LLVMConstReal" : ["LLVMValueRef function(LLVMTypeRef RealTy, double N)"],
	"LLVMConstRealOfString" : ["LLVMValueRef function(LLVMTypeRef RealTy, const char* Text)"],
	"LLVMConstRealOfStringAndSize" : ["LLVMValueRef function(LLVMTypeRef RealTy, const char* Text, uint SLen)"],
	"LLVMConstIntGetZExtValue" : ["ulong function(LLVMValueRef ConstantVal)"],
	"LLVMConstIntGetSExtValue" : ["long function(LLVMValueRef ConstantVal)"],

	/++++ Composite Constants ++++/

	"LLVMConstStringInContext" : ["LLVMValueRef function(LLVMContextRef C, const char* Str, uint Length, LLVMBool DontNullTerminate)"],
	"LLVMConstString" : ["LLVMValueRef function(const char* Str, uint Length, LLVMBool DontNullTerminate)"],
	"LLVMConstStructInContext" : ["LLVMValueRef function(LLVMContextRef C, LLVMValueRef* ConstantVals, uint Count, LLVMBool Packed)"],
	"LLVMConstStruct" : ["LLVMValueRef function(LLVMValueRef* ConstantVals, uint Count, LLVMBool Packed)"],
	"LLVMConstArray" : ["LLVMValueRef function(LLVMTypeRef ElementTy, LLVMValueRef* ConstantVals, uint Length)"],
	"LLVMConstNamedStruct" : ["LLVMValueRef function(LLVMTypeRef StructTy, LLVMValueRef* ConstantVals, uint Count)"],
	"LLVMConstVector" : ["LLVMValueRef function(LLVMValueRef* ScalarConstantVals, uint Size)"],

	/++++ Constant Expressions ++++/

	"LLVMGetConstOpcode" : ["LLVMOpcode function(LLVMValueRef ConstantVal)"],
	"LLVMAlignOf" : ["LLVMValueRef function(LLVMTypeRef Ty)"],
	"LLVMSizeOf" : ["LLVMValueRef function(LLVMTypeRef Ty)"],
	"LLVMConstNeg" : ["LLVMValueRef function(LLVMValueRef ConstantVal)"],
	"LLVMConstNSWNeg" : ["LLVMValueRef function(LLVMValueRef ConstantVal)"],
	"LLVMConstNUWNeg" : ["LLVMValueRef function(LLVMValueRef ConstantVal)"],
	"LLVMConstFNeg" : ["LLVMValueRef function(LLVMValueRef ConstantVal)"],
	"LLVMConstNot" : ["LLVMValueRef function(LLVMValueRef ConstantVal)"],
	"LLVMConstAdd" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstNSWAdd" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstNUWAdd" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstFAdd" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstSub" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstNSWSub" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstNUWSub" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstFSub" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstMul" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstNSWMul" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstNUWMul" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstFMul" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstUDiv" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstSDiv" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstExactSDiv" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstFDiv" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstURem" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstSRem" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstFRem" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstAnd" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstOr" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstXor" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstICmp" : ["LLVMValueRef function(LLVMIntPredicate Predicate, LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstFCmp" : ["LLVMValueRef function(LLVMRealPredicate Predicate, LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstShl" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstLShr" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstAShr" : ["LLVMValueRef function(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant)"],
	"LLVMConstGEP" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMValueRef* ConstantIndices, uint NumIndices)"],
	"LLVMConstInBoundsGEP" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMValueRef* ConstantIndices, uint NumIndices)"],
	"LLVMConstTrunc" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMTypeRef ToType)"],
	"LLVMConstSExt" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMTypeRef ToType)"],
	"LLVMConstZExt" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMTypeRef ToType)"],
	"LLVMConstFPTrunc" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMTypeRef ToType)"],
	"LLVMConstFPExt" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMTypeRef ToType)"],
	"LLVMConstUIToFP" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMTypeRef ToType)"],
	"LLVMConstSIToFP" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMTypeRef ToType)"],
	"LLVMConstFPToUI" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMTypeRef ToType)"],
	"LLVMConstFPToSI" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMTypeRef ToType)"],
	"LLVMConstPtrToInt" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMTypeRef ToType)"],
	"LLVMConstIntToPtr" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMTypeRef ToType)"],
	"LLVMConstBitCast" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMTypeRef ToType)"],
	"LLVMConstZExtOrBitCast" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMTypeRef ToType)"],
	"LLVMConstSExtOrBitCast" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMTypeRef ToType)"],
	"LLVMConstTruncOrBitCast" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMTypeRef ToType)"],
	"LLVMConstPointerCast" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMTypeRef ToType)"],
	"LLVMConstIntCast" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMTypeRef ToType, LLVMBool isSigned)"],
	"LLVMConstFPCast" : ["LLVMValueRef function(LLVMValueRef ConstantVal, LLVMTypeRef ToType)"],
	"LLVMConstSelect" : ["LLVMValueRef function(LLVMValueRef ConstantCondition, LLVMValueRef ConstantIfTrue, LLVMValueRef ConstantIfFalse)"],
	"LLVMConstExtractElement" : ["LLVMValueRef function(LLVMValueRef VectorConstant, LLVMValueRef IndexConstant)"],
	"LLVMConstInsertElement" : ["LLVMValueRef function(LLVMValueRef VectorConstant, LLVMValueRef ElementValueConstant, LLVMValueRef IndexConstant)"],
	"LLVMConstShuffleVector" : ["LLVMValueRef function(LLVMValueRef VectorAConstant, LLVMValueRef VectorBConstant, LLVMValueRef MaskConstant)"],
	"LLVMConstExtractValue" : ["LLVMValueRef function(LLVMValueRef AggConstant, uint* IdxList, uint NumIdx)"],
	"LLVMConstInsertValue" : ["LLVMValueRef function(LLVMValueRef AggConstant, LLVMValueRef ElementValueConstant, uint* IdxList, uint NumIdx)"],
	"LLVMConstInlineAsm" : ["LLVMValueRef function(LLVMTypeRef Ty, const char* AsmString, const char* Constraints, LLVMBool HasSideEffects, LLVMBool IsAlignStack)"],
	"LLVMBlockAddress" : ["LLVMValueRef function(LLVMValueRef F, LLVMBasicBlockRef BB)"],

	/++++ Global Values ++++/

	"LLVMGetGlobalParent" : ["LLVMModuleRef function(LLVMValueRef Global)"],
	"LLVMIsDeclaration" : ["LLVMBool function(LLVMValueRef Global)"],
	"LLVMGetLinkage" : ["LLVMLinkage function(LLVMValueRef Global)"],
	"LLVMSetLinkage" : ["void function(LLVMValueRef Global, LLVMLinkage Linkage)"],
	"LLVMGetSection" : ["const(char)* function(LLVMValueRef Global)"],
	"LLVMSetSection" : ["void function(LLVMValueRef Global, const char* Section)"],
	"LLVMGetVisibility" : ["LLVMVisibility function(LLVMValueRef Global)"],
	"LLVMSetVisibility" : ["void function(LLVMValueRef Global, LLVMVisibility Viz)"],
	"LLVMGetAlignment" : ["uint function(LLVMValueRef Global)"],
	"LLVMSetAlignment" : ["void function(LLVMValueRef Global, uint Bytes)"],

	/+++++ Global Variables +++++/

	"LLVMAddGlobal" : ["LLVMValueRef function(LLVMModuleRef M, LLVMTypeRef Ty, const char* Name)"],
	"LLVMAddGlobalInAddressSpace" : ["LLVMValueRef function(LLVMModuleRef M, LLVMTypeRef Ty, const char* Name, uint AddressSpace)"],
	"LLVMGetNamedGlobal" : ["LLVMValueRef function(LLVMModuleRef M, const char* Name)"],
	"LLVMGetFirstGlobal" : ["LLVMValueRef function(LLVMModuleRef M)"],
	"LLVMGetLastGlobal" : ["LLVMValueRef function(LLVMModuleRef M)"],
	"LLVMGetNextGlobal" : ["LLVMValueRef function(LLVMValueRef GlobalVar)"],
	"LLVMGetPreviousGlobal" : ["LLVMValueRef function(LLVMValueRef GlobalVar)"],
	"LLVMDeleteGlobal" : ["void function(LLVMValueRef GlobalVar)"],
	"LLVMGetInitializer" : ["LLVMValueRef function(LLVMValueRef GlobalVar)"],
	"LLVMSetInitializer" : ["void function(LLVMValueRef GlobalVar, LLVMValueRef ConstantVal)"],
	"LLVMIsThreadLocal" : ["LLVMBool function(LLVMValueRef GlobalVar)"],
	"LLVMSetThreadLocal" : ["void function(LLVMValueRef GlobalVar, LLVMBool IsThreadLocal)"],
	"LLVMIsGlobalConstant" : ["LLVMBool function(LLVMValueRef GlobalVar)"],
	"LLVMSetGlobalConstant" : ["void function(LLVMValueRef GlobalVar, LLVMBool IsConstant)"],

	/+++++ Global Aliases +++++/

	"LLVMAddAlias" : ["LLVMValueRef function(LLVMModuleRef M, LLVMTypeRef Ty, LLVMValueRef Aliasee, const char* Name)"],

	/+++++ Function values +++++/

	"LLVMDeleteFunction" : ["void function(LLVMValueRef Fn)"],
	"LLVMGetIntrinsicID" : ["uint function(LLVMValueRef Fn)"],
	"LLVMGetFunctionCallConv" : ["uint function(LLVMValueRef Fn)"],
	"LLVMSetFunctionCallConv" : ["void function(LLVMValueRef Fn, uint CC)"],
	"LLVMGetGC" : ["const(char)* function(LLVMValueRef Fn)"],
	"LLVMSetGC" : ["void function(LLVMValueRef Fn, const char *Name)"],
	"LLVMAddFunctionAttr" : ["void function(LLVMValueRef Fn, LLVMAttribute PA)"],
	"LLVMGetFunctionAttr" : ["LLVMAttribute function(LLVMValueRef Fn)"],
	"LLVMRemoveFunctionAttr" : ["void function(LLVMValueRef Fn, LLVMAttribute PA)"],

	/++++++ Function Parameters ++++++/

	"LLVMCountParams" : ["uint function(LLVMValueRef Fn)"],
	"LLVMGetParams" : ["void function(LLVMValueRef Fn, LLVMValueRef* Params)"],
	"LLVMGetParam" : ["LLVMValueRef function(LLVMValueRef Fn, uint Index)"],
	"LLVMGetParamParent" : ["LLVMValueRef function(LLVMValueRef Inst)"],
	"LLVMGetFirstParam" : ["LLVMValueRef function(LLVMValueRef Fn)"],
	"LLVMGetLastParam" : ["LLVMValueRef function(LLVMValueRef Fn)"],
	"LLVMGetNextParam" : ["LLVMValueRef function(LLVMValueRef Arg)"],
	"LLVMGetPreviousParam" : ["LLVMValueRef function(LLVMValueRef Arg)"],
	"LLVMAddAttribute" : ["void function(LLVMValueRef Arg, LLVMAttribute PA)"],
	"LLVMRemoveAttribute" : ["void function(LLVMValueRef Arg, LLVMAttribute PA)"],
	"LLVMGetAttribute" : ["LLVMAttribute function(LLVMValueRef Arg)"],
	"LLVMSetParamAlignment" : ["void function(LLVMValueRef Arg, uint Align)"],

	/+++ Metadata +++/

	"LLVMMDStringInContext" : ["LLVMValueRef function(LLVMContextRef C, const char* Str, uint SLen)"],
	"LLVMMDString" : ["LLVMValueRef function(const char* Str, uint SLen)"],
	"LLVMMDNodeInContext" : ["LLVMValueRef function(LLVMContextRef C, LLVMValueRef* Vals, uint Count)"],
	"LLVMMDNode" : ["LLVMValueRef function(LLVMValueRef* Vals, uint Count)"],
	"LLVMGetMDString" : ["const(char)* function(LLVMValueRef V, uint* Len)"],
	"LLVMGetMDNodeNumOperands" : ["uint function(LLVMValueRef V)",
	                              "+", "3.2"],
	"LLVMGetMDNodeOperands" : ["void function(LLVMValueRef V, LLVMValueRef *Dest)",
	                           "+", "3.2"],

	/+++ Basic Block +++/

	"LLVMBasicBlockAsValue" : ["LLVMValueRef function(LLVMBasicBlockRef BB)"],
	"LLVMValueIsBasicBlock" : ["LLVMBool function(LLVMValueRef Val)"],
	"LLVMValueAsBasicBlock" : ["LLVMBasicBlockRef function(LLVMValueRef Val)"],
	"LLVMGetBasicBlockParent" : ["LLVMValueRef function(LLVMBasicBlockRef BB)"],
	"LLVMGetBasicBlockTerminator" : ["LLVMValueRef function(LLVMBasicBlockRef BB)"],
	"LLVMCountBasicBlocks" : ["uint function(LLVMValueRef Fn)"],
	"LLVMGetBasicBlocks" : ["void function(LLVMValueRef Fn, LLVMBasicBlockRef* BasicBlocks)"],
	"LLVMGetFirstBasicBlock" : ["LLVMBasicBlockRef function(LLVMValueRef Fn)"],
	"LLVMGetLastBasicBlock" : ["LLVMBasicBlockRef function(LLVMValueRef Fn)"],
	"LLVMGetNextBasicBlock" : ["LLVMBasicBlockRef function(LLVMBasicBlockRef BB)"],
	"LLVMGetPreviousBasicBlock" : ["LLVMBasicBlockRef function(LLVMBasicBlockRef BB)"],
	"LLVMGetEntryBasicBlock" : ["LLVMBasicBlockRef function(LLVMValueRef Fn)"],
	"LLVMAppendBasicBlockInContext" : ["LLVMBasicBlockRef function(LLVMContextRef C, LLVMValueRef Fn, const char* Name)"],
	"LLVMAppendBasicBlock" : ["LLVMBasicBlockRef function(LLVMValueRef Fn, const char* Name)"],
	"LLVMInsertBasicBlockInContext" : ["LLVMBasicBlockRef function(LLVMContextRef C, LLVMBasicBlockRef BB, const char* Name)"],
	"LLVMInsertBasicBlock" : ["LLVMBasicBlockRef function(LLVMBasicBlockRef InsertBeforeBB, const char* Name)"],
	"LLVMDeleteBasicBlock" : ["void function(LLVMBasicBlockRef BB)"],
	"LLVMRemoveBasicBlockFromParent" : ["void function(LLVMBasicBlockRef BB)"],
	"LLVMMoveBasicBlockBefore" : ["void function(LLVMBasicBlockRef BB, LLVMBasicBlockRef MovePos)"],
	"LLVMMoveBasicBlockAfter" : ["void function(LLVMBasicBlockRef BB, LLVMBasicBlockRef MovePos)"],
	"LLVMGetFirstInstruction" : ["LLVMValueRef function(LLVMBasicBlockRef BB)"],
	"LLVMGetLastInstruction" : ["LLVMValueRef function(LLVMBasicBlockRef BB)"],

	/+++ Instructions +++/

	"LLVMHasMetadata" : ["int function(LLVMValueRef Val)"],
	"LLVMGetMetadata" : ["LLVMValueRef function(LLVMValueRef Val, uint KindID)"],
	"LLVMSetMetadata" : ["void function(LLVMValueRef Val, uint KindID, LLVMValueRef Node)"],
	"LLVMGetInstructionParent" : ["LLVMBasicBlockRef function(LLVMValueRef Inst)"],
	"LLVMGetNextInstruction" : ["LLVMValueRef function(LLVMValueRef Inst)"],
	"LLVMGetPreviousInstruction" : ["LLVMValueRef function(LLVMValueRef Inst)"],
	"LLVMInstructionEraseFromParent" : ["void function(LLVMValueRef Inst)"],
	"LLVMGetInstructionOpcode" : ["LLVMOpcode function(LLVMValueRef Inst)"],
	"LLVMGetICmpPredicate" : ["LLVMIntPredicate function(LLVMValueRef Inst)"],
	"LLVMGetSwitchDefaultDest" : ["LLVMBasicBlockRef function(LLVMValueRef SwitchInstr)"],

	/++++ Call Sites and Invocations ++++/

	"LLVMSetInstructionCallConv" : ["void function(LLVMValueRef Instr, uint CC)"],
	"LLVMGetInstructionCallConv" : ["uint function(LLVMValueRef Instr)"],
	"LLVMAddInstrAttribute" : ["void function(LLVMValueRef Instr, uint index, LLVMAttribute)"],
	"LLVMRemoveInstrAttribute" : ["void function(LLVMValueRef Instr, uint index, LLVMAttribute)"],
	"LLVMSetInstrParamAlignment" : ["void function(LLVMValueRef Instr, uint index, uint Align)"],
	"LLVMIsTailCall" : ["LLVMBool function(LLVMValueRef CallInst)"],
	"LLVMSetTailCall" : ["void function(LLVMValueRef CallInst, LLVMBool IsTailCall)"],

	/++++ PHI Nodes ++++/

	"LLVMAddIncoming" : ["void function(LLVMValueRef PhiNode, LLVMValueRef* IncomingValues, LLVMBasicBlockRef* IncomingBlocks, uint Count)"],
	"LLVMCountIncoming" : ["uint function(LLVMValueRef PhiNode)"],
	"LLVMGetIncomingValue" : ["LLVMValueRef function(LLVMValueRef PhiNode, uint Index)"],
	"LLVMGetIncomingBlock" : ["LLVMBasicBlockRef function(LLVMValueRef PhiNode, uint Index)"],

	/++ Instruction Builders ++/

	"LLVMCreateBuilderInContext" : ["LLVMBuilderRef function(LLVMContextRef C)"],
	"LLVMCreateBuilder" : ["LLVMBuilderRef function()"],
	"LLVMPositionBuilder" : ["void function(LLVMBuilderRef Builder, LLVMBasicBlockRef Block, LLVMValueRef Instr)"],
	"LLVMPositionBuilderBefore" : ["void function(LLVMBuilderRef Builder, LLVMValueRef Instr)"],
	"LLVMPositionBuilderAtEnd" : ["void function(LLVMBuilderRef Builder, LLVMBasicBlockRef Block)"],
	"LLVMGetInsertBlock" : ["LLVMBasicBlockRef function(LLVMBuilderRef Builder)"],
	"LLVMClearInsertionPosition" : ["void function(LLVMBuilderRef Builder)"],
	"LLVMInsertIntoBuilder" : ["void function(LLVMBuilderRef Builder, LLVMValueRef Instr)"],
	"LLVMInsertIntoBuilderWithName" : ["void function(LLVMBuilderRef Builder, LLVMValueRef Instr, const char* Name)"],
	"LLVMDisposeBuilder" : ["void function(LLVMBuilderRef Builder)"],
	"LLVMSetCurrentDebugLocation" : ["void function(LLVMBuilderRef Builder, LLVMValueRef L)"],
	"LLVMGetCurrentDebugLocation" : ["LLVMValueRef function(LLVMBuilderRef Builder)"],
	"LLVMSetInstDebugLocation" : ["void function(LLVMBuilderRef Builder, LLVMValueRef Inst)"],
	"LLVMBuildRetVoid" : ["LLVMValueRef function(LLVMBuilderRef)"],
	"LLVMBuildRet" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef V)"],
	"LLVMBuildAggregateRet" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef* RetVals, uint N)"],
	"LLVMBuildBr" : ["LLVMValueRef function(LLVMBuilderRef, LLVMBasicBlockRef Dest)"],
	"LLVMBuildCondBr" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef If, LLVMBasicBlockRef Then, LLVMBasicBlockRef Else)"],
	"LLVMBuildSwitch" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef V, LLVMBasicBlockRef Else, uint NumCases)"],
	"LLVMBuildIndirectBr" : ["LLVMValueRef function(LLVMBuilderRef B, LLVMValueRef Addr, uint NumDests)"],
	"LLVMBuildInvoke" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Fn, LLVMValueRef* Args, uint NumArgs, LLVMBasicBlockRef Then, LLVMBasicBlockRef Catch, const char* Name)"],
	"LLVMBuildLandingPad" : ["LLVMValueRef function(LLVMBuilderRef B, LLVMTypeRef Ty, LLVMValueRef PersFn, uint NumClauses, const char* Name)"],
	"LLVMBuildResume" : ["LLVMValueRef function(LLVMBuilderRef B, LLVMValueRef Exn)"],
	"LLVMBuildUnreachable" : ["LLVMValueRef function(LLVMBuilderRef)"],
	"LLVMAddCase" : ["void function(LLVMValueRef Switch, LLVMValueRef OnVal, LLVMBasicBlockRef Dest)"],
	"LLVMAddDestination" : ["void function(LLVMValueRef IndirectBr, LLVMBasicBlockRef Dest)"],
	"LLVMAddClause" : ["void function(LLVMValueRef LandingPad, LLVMValueRef ClauseVal)"],
	"LLVMSetCleanup" : ["void function(LLVMValueRef LandingPad, LLVMBool Val)"],
	"LLVMBuildAdd" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildNSWAdd" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildNUWAdd" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildFAdd" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildSub" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildNSWSub" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildNUWSub" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildFSub" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildMul" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildNSWMul" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildNUWMul" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildFMul" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildUDiv" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildSDiv" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildExactSDiv" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildFDiv" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildURem" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildSRem" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildFRem" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildShl" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildLShr" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildAShr" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildAnd" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildOr" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildXor" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildBinOp" : ["LLVMValueRef function(LLVMBuilderRef B, LLVMOpcode Op, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildNeg" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef V, const char* Name)"],
	"LLVMBuildNSWNeg" : ["LLVMValueRef function(LLVMBuilderRef B, LLVMValueRef V, const char* Name)"],
	"LLVMBuildNUWNeg" : ["LLVMValueRef function(LLVMBuilderRef B, LLVMValueRef V, const char* Name)"],
	"LLVMBuildFNeg" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef V, const char* Name)"],
	"LLVMBuildNot" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef V, const char* Name)"],
	"LLVMBuildMalloc" : ["LLVMValueRef function(LLVMBuilderRef, LLVMTypeRef Ty, const char* Name)"],
	"LLVMBuildArrayMalloc" : ["LLVMValueRef function(LLVMBuilderRef, LLVMTypeRef Ty, LLVMValueRef Val, const char* Name)"],
	"LLVMBuildAlloca" : ["LLVMValueRef function(LLVMBuilderRef, LLVMTypeRef Ty, const char* Name)"],
	"LLVMBuildArrayAlloca" : ["LLVMValueRef function(LLVMBuilderRef, LLVMTypeRef Ty, LLVMValueRef Val, const char* Name)"],
	"LLVMBuildFree" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef PointerVal)"],
	"LLVMBuildLoad" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef PointerVal, const char* Name)"],
	"LLVMBuildStore" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMValueRef Ptr)"],
	"LLVMBuildGEP" : ["LLVMValueRef function(LLVMBuilderRef B, LLVMValueRef Pointer, LLVMValueRef* Indices, uint NumIndices, const char* Name)"],
	"LLVMBuildInBoundsGEP" : ["LLVMValueRef function(LLVMBuilderRef B, LLVMValueRef Pointer, LLVMValueRef* Indices, uint NumIndices, const char* Name)"],
	"LLVMBuildStructGEP" : ["LLVMValueRef function(LLVMBuilderRef B, LLVMValueRef Pointer, uint Idx, const char* Name)"],
	"LLVMBuildGlobalString" : ["LLVMValueRef function(LLVMBuilderRef B, const char* Str, const char* Name)"],
	"LLVMBuildGlobalStringPtr" : ["LLVMValueRef function(LLVMBuilderRef B, const char* Str, const char* Name)"],
	"LLVMGetVolatile" : ["LLVMBool function(LLVMValueRef MemoryAccessInst)"],
	"LLVMSetVolatile" : ["void function(LLVMValueRef MemoryAccessInst, LLVMBool IsVolatile)"],
	"LLVMBuildTrunc" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildZExt" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildSExt" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildFPToUI" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildFPToSI" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildUIToFP" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildSIToFP" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildFPTrunc" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildFPExt" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildPtrToInt" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildIntToPtr" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildBitCast" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildZExtOrBitCast" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildSExtOrBitCast" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildTruncOrBitCast" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildCast" : ["LLVMValueRef function(LLVMBuilderRef B, LLVMOpcode Op, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildPointerCast" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildIntCast" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildFPCast" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char* Name)"],
	"LLVMBuildICmp" : ["LLVMValueRef function(LLVMBuilderRef, LLVMIntPredicate Op, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildFCmp" : ["LLVMValueRef function(LLVMBuilderRef, LLVMRealPredicate Op, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],
	"LLVMBuildPhi" : ["LLVMValueRef function(LLVMBuilderRef, LLVMTypeRef Ty, const char* Name)"],
	"LLVMBuildCall" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Fn, LLVMValueRef* Args, uint NumArgs, const char* Name)"],
	"LLVMBuildSelect" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef If, LLVMValueRef Then, LLVMValueRef Else, const char* Name)"],
	"LLVMBuildVAArg" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef List, LLVMTypeRef Ty, const char* Name)"],
	"LLVMBuildExtractElement" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef VecVal, LLVMValueRef Index, const char* Name)"],
	"LLVMBuildInsertElement" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef VecVal, LLVMValueRef EltVal, LLVMValueRef Index, const char* Name)"],
	"LLVMBuildShuffleVector" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef V1, LLVMValueRef V2, LLVMValueRef Mask, const char* Name)"],
	"LLVMBuildExtractValue" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef AggVal, uint Index, const char* Name)"],
	"LLVMBuildInsertValue" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef AggVal, LLVMValueRef EltVal, uint Index, const char* Name)"],
	"LLVMBuildIsNull" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, const char* Name)"],
	"LLVMBuildIsNotNull" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef Val, const char* Name)"],
	"LLVMBuildPtrDiff" : ["LLVMValueRef function(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char* Name)"],

	/++ Module Providers ++/

	"LLVMCreateModuleProviderForExistingModule" : ["LLVMModuleProviderRef function(LLVMModuleRef M)"],
	"LLVMDisposeModuleProvider" : ["void function(LLVMModuleProviderRef M)"],

	/++ Memory Buffers ++/

	"LLVMCreateMemoryBufferWithContentsOfFile" : ["LLVMBool function(const char* Path, LLVMMemoryBufferRef* OutMemBuf, char** OutMessage)"],
	"LLVMCreateMemoryBufferWithSTDIN" : ["LLVMBool function(LLVMMemoryBufferRef* OutMemBuf, char** OutMessage)"],
	"LLVMCreateMemoryBufferWithMemoryRange" : ["LLVMMemoryBufferRef function(const char* InputData, size_t InputDataLength, const char* BufferName, LLVMBool RequiresNullTerminator)",
	                                           "+", "3.3"],
	"LLVMCreateMemoryBufferWithMemoryRangeCopy" : ["LLVMMemoryBufferRef function(const char* InputData, size_t InputDataLength, const char* BufferName)",
	                                               "+", "3.3"],
	"LLVMDisposeMemoryBuffer" : ["void function(LLVMMemoryBufferRef MemBuf)"],

	/++ Pass Registry ++/

	"LLVMGetGlobalPassRegistry" : ["LLVMPassRegistryRef function()"],

	/++ Pass Managers ++/

	"LLVMCreatePassManager" : ["LLVMPassManagerRef function()"],
	"LLVMCreateFunctionPassManagerForModule" : ["LLVMPassManagerRef function(LLVMModuleRef M)"],
	"LLVMCreateFunctionPassManager" : ["LLVMPassManagerRef function(LLVMModuleProviderRef MP)"],
	"LLVMRunPassManager" : ["LLVMBool function(LLVMPassManagerRef PM, LLVMModuleRef M)"],
	"LLVMInitializeFunctionPassManager" : ["LLVMBool function(LLVMPassManagerRef FPM)"],
	"LLVMRunFunctionPassManager" : ["LLVMBool function(LLVMPassManagerRef FPM, LLVMValueRef F)"],
	"LLVMFinalizeFunctionPassManager" : ["LLVMBool function(LLVMPassManagerRef FPM)"],
	"LLVMDisposePassManager" : ["void function(LLVMPassManagerRef PM)"],

	/++ Threading ++/

	"LLVMStartMultithreaded" : ["LLVMBool function()",
	                            "+", "3.3"],
	"LLVMStopMultithreaded" : ["void function()",
	                            "+", "3.3"],
	"LLVMIsMultithreaded" : ["LLVMBool function()",
	                            "+", "3.3"],

	/+ Disassembler +/

	"LLVMCreateDisasm" : ["LLVMDisasmContextRef function(const char* TripleName, void* DisInfo, int TagType, LLVMOpInfoCallback GetOpInfo, LLVMSymbolLookupCallback SymbolLookUp)"],
	"LLVMCreateDisasmCPU" : ["LLVMDisasmContextRef function(const char* Triple, const char* CPU, void* DisInfo, int TagType, LLVMOpInfoCallback GetOpInfo, LLVMSymbolLookupCallback SymbolLookUp)",
	                         "+", "3.3"],
	"LLVMSetDisasmOptions" : ["int function(LLVMDisasmContextRef DC, ulong Options)",
	                          "+", "3.2"],
	"LLVMDisasmDispose" : ["void function(LLVMDisasmContextRef DC)"],
	"LLVMDisasmInstruction" : ["size_t function(LLVMDisasmContextRef DC, ubyte* Bytes, ulong BytesSize, ulong PC, char* OutString, size_t OutStringSize)"],

	/+ Enhanced Disassembly +/

	"EDGetDisassembler" : ["int function(EDDisassemblerRef* disassembler, const char* triple, EDAssemblySyntax_t syntax)",
	                       "-", "3.3"],
	"EDGetRegisterName" : ["int function(const char** regName, EDDisassemblerRef disassembler, uint regID)",
	                       "-", "3.3"],
	"EDRegisterIsStackPointer" : ["int function(EDDisassemblerRef disassembler, uint regID)",
	                              "-", "3.3"],
	"EDRegisterIsProgramCounter" : ["int function(EDDisassemblerRef disassembler, uint regID)",
	                                "-", "3.3"],
	"EDCreateInsts" : ["uint function(EDInstRef* insts, uint count, EDDisassemblerRef disassembler, EDByteReaderCallback byteReader, ulong address, void* arg)",
	                   "-", "3.3"],
	"EDReleaseInst" : ["void function(EDInstRef inst)",
	                   "-", "3.3"],
	"EDInstByteSize" : ["int function(EDInstRef inst)",
	                    "-", "3.3"],
	"EDGetInstString" : ["int function(const char* *buf, EDInstRef inst)",
	                     "-", "3.3"],
	"EDInstID" : ["int function(uint* instID, EDInstRef inst)",
	              "-", "3.3"],
	"EDInstIsBranch" : ["int function(EDInstRef inst)",
	                    "-", "3.3"],
	"EDInstIsMove" : ["int function(EDInstRef inst)",
	                  "-", "3.3"],
	"EDBranchTargetID" : ["int function(EDInstRef inst)",
	                      "-", "3.3"],
	"EDMoveSourceID" : ["int function(EDInstRef inst)",
	                    "-", "3.3"],
	"EDMoveTargetID" : ["int function(EDInstRef inst)",
	                    "-", "3.3"],
	"EDNumTokens" : ["int function(EDInstRef inst)",
	                 "-", "3.3"],
	"EDGetToken" : ["int function(EDTokenRef* token, EDInstRef inst, int index)",
	                "-", "3.3"],
	"EDGetTokenString" : ["int function(const char* *buf, EDTokenRef token)",
	                      "-", "3.3"],
	"EDOperandIndexForToken" : ["int function(EDTokenRef token)",
	                            "-", "3.3"],
	"EDTokenIsWhitespace" : ["int function(EDTokenRef token)",
	                         "-", "3.3"],
	"EDTokenIsPunctuation" : ["int function(EDTokenRef token)",
	                          "-", "3.3"],
	"EDTokenIsOpcode" : ["int function(EDTokenRef token)",
	                     "-", "3.3"],
	"EDTokenIsLiteral" : ["int function(EDTokenRef token)",
	                      "-", "3.3"],
	"EDTokenIsRegister" : ["int function(EDTokenRef token)",
	                       "-", "3.3"],
	"EDTokenIsNegativeLiteral" : ["int function(EDTokenRef token)",
	                              "-", "3.3"],
	"EDLiteralTokenAbsoluteValue" : ["int function(ulong* value, EDTokenRef token)",
	                                 "-", "3.3"],
	"EDRegisterTokenValue" : ["int function(uint* registerID, EDTokenRef token)",
	                          "-", "3.3"],
	"EDNumOperands" : ["int function(EDInstRef inst)",
	                   "-", "3.3"],
	"EDGetOperand" : ["int function(EDOperandRef* operand, EDInstRef inst, int index)",
	                  "-", "3.3"],
	"EDOperandIsRegister" : ["int function(EDOperandRef operand)",
	                         "-", "3.3"],
	"EDOperandIsImmediate" : ["int function(EDOperandRef operand)",
	                          "-", "3.3"],
	"EDOperandIsMemory" : ["int function(EDOperandRef operand)",
	                       "-", "3.3"],
	"EDRegisterOperandValue" : ["int function(uint* value, EDOperandRef operand)",
	                            "-", "3.3"],
	"EDImmediateOperandValue" : ["int function(ulong* value, EDOperandRef operand)",
	                             "-", "3.3"],
	"EDEvaluateOperand" : ["int function(ulong* result, EDOperandRef operand, EDRegisterReaderCallback regReader, void* arg)",
	                       "-", "3.3"],
	"EDBlockCreateInsts" : ["uint function(EDInstRef* insts, int count, EDDisassemblerRef disassembler, EDByteBlock_t byteBlock, ulong address)",
	                        "-", "3.3"],
	"EDBlockEvaluateOperand" : ["int function(ulong* result, EDOperandRef operand, EDRegisterBlock_t regBlock)",
	                            "-", "3.3"],
	"EDBlockVisitTokens" : ["int function(EDInstRef inst, EDTokenVisitor_t visitor)",
	                        "-", "3.3"],

	/+ Execution Engine +/

	"LLVMCreateGenericValueOfInt" : ["LLVMGenericValueRef function(LLVMTypeRef Ty, ulong N, LLVMBool IsSigned)"],
	"LLVMCreateGenericValueOfPointer" : ["LLVMGenericValueRef function(void* P)"],
	"LLVMCreateGenericValueOfFloat" : ["LLVMGenericValueRef function(LLVMTypeRef Ty, double N)"],
	"LLVMGenericValueIntWidth" : ["uint function(LLVMGenericValueRef GenValRef)"],
	"LLVMGenericValueToInt" : ["ulong function(LLVMGenericValueRef GenVal, LLVMBool IsSigned)"],
	"LLVMGenericValueToPointer" : ["void* function(LLVMGenericValueRef GenVal)"],
	"LLVMGenericValueToFloat" : ["double function(LLVMTypeRef TyRef, LLVMGenericValueRef GenVal)"],
	"LLVMDisposeGenericValue" : ["void function(LLVMGenericValueRef GenVal)"],
	"LLVMCreateExecutionEngineForModule" : ["LLVMBool function(LLVMExecutionEngineRef* OutEE, LLVMModuleRef M, char** OutError)"],
	"LLVMCreateInterpreterForModule" : ["LLVMBool function(LLVMExecutionEngineRef* OutInterp, LLVMModuleRef M, char** OutError)"],
	"LLVMCreateJITCompilerForModule" : ["LLVMBool function(LLVMExecutionEngineRef* OutJIT, LLVMModuleRef M, uint OptLevel, char** OutError)"],
	"LLVMCreateExecutionEngine" : ["LLVMBool function(LLVMExecutionEngineRef* OutEE, LLVMModuleProviderRef MP, char** OutError)"],
	"LLVMCreateInterpreter" : ["LLVMBool function(LLVMExecutionEngineRef* OutInterp, LLVMModuleProviderRef MP, char** OutError)"],
	"LLVMCreateJITCompiler" : ["LLVMBool function(LLVMExecutionEngineRef* OutJIT, LLVMModuleProviderRef MP, uint OptLevel, char** OutError)"],
	"LLVMDisposeExecutionEngine" : ["void function(LLVMExecutionEngineRef EE)"],
	"LLVMRunStaticConstructors" : ["void function(LLVMExecutionEngineRef EE)"],
	"LLVMRunStaticDestructors" : ["void function(LLVMExecutionEngineRef EE)"],
	"LLVMRunFunctionAsMain" : ["int function(LLVMExecutionEngineRef EE, LLVMValueRef F, uint ArgC, const(char*)* ArgV, const(char*)* EnvP)"],
	"LLVMRunFunction" : ["LLVMGenericValueRef function(LLVMExecutionEngineRef EE, LLVMValueRef F, uint NumArgs, LLVMGenericValueRef* Args)"],
	"LLVMFreeMachineCodeForFunction" : ["void function(LLVMExecutionEngineRef EE, LLVMValueRef F)"],
	"LLVMAddModule" : ["void function(LLVMExecutionEngineRef EE, LLVMModuleRef M)"],
	"LLVMAddModuleProvider" : ["void function(LLVMExecutionEngineRef EE, LLVMModuleProviderRef MP)"],
	"LLVMRemoveModule" : ["LLVMBool function(LLVMExecutionEngineRef EE, LLVMModuleRef M, LLVMModuleRef* OutMod, char** OutError)"],
	"LLVMRemoveModuleProvider" : ["LLVMBool function(LLVMExecutionEngineRef EE, LLVMModuleProviderRef MP, LLVMModuleRef* OutMod, char** OutError)"],
	"LLVMFindFunction" : ["LLVMBool function(LLVMExecutionEngineRef EE, const char* Name, LLVMValueRef* OutFn)"],
	"LLVMRecompileAndRelinkFunction" : ["void* function(LLVMExecutionEngineRef EE, LLVMValueRef Fn)"],
	"LLVMGetExecutionEngineTargetData" : ["LLVMTargetDataRef function(LLVMExecutionEngineRef EE)"],
	"LLVMAddGlobalMapping" : ["void function(LLVMExecutionEngineRef EE, LLVMValueRef Global, void* Addr)"],
	"LLVMGetPointerToGlobal" : ["void* function(LLVMExecutionEngineRef EE, LLVMValueRef Global)"],

	/+ Initialization Routines +/

	"LLVMInitializeCore" : ["void function(LLVMPassRegistryRef R)"],
	"LLVMInitializeTransformUtils" : ["void function(LLVMPassRegistryRef R)"],
	"LLVMInitializeScalarOpts" : ["void function(LLVMPassRegistryRef R)"],
	"LLVMInitializeObjCARCOpts" : ["void function(LLVMPassRegistryRef R)",
	                               "+", "3.3"],
	"LLVMInitializeVectorization" : ["void function(LLVMPassRegistryRef R)"],
	"LLVMInitializeInstCombine" : ["void function(LLVMPassRegistryRef R)"],
	"LLVMInitializeIPO" : ["void function(LLVMPassRegistryRef R)"],
	"LLVMInitializeInstrumentation" : ["void function(LLVMPassRegistryRef R)"],
	"LLVMInitializeAnalysis" : ["void function(LLVMPassRegistryRef R)"],
	"LLVMInitializeIPA" : ["void function(LLVMPassRegistryRef R)"],
	"LLVMInitializeCodeGen" : ["void function(LLVMPassRegistryRef R)"],
	"LLVMInitializeTarget" : ["void function(LLVMPassRegistryRef R)"],

	/+ Linker +/

	"LLVMLinkModules" : ["LLVMBool function(LLVMModuleRef Dest, LLVMModuleRef Src, LLVMLinkerMode Mode, char** OutMessage)",
	                     "+", "3.2"],

	/+ Link Time Optimization +/

	"llvm_create_optimizer" : ["llvm_lto_t function()"],
	"llvm_destroy_optimizer" : ["void function(llvm_lto_t lto)"],
	"llvm_read_object_file" : ["llvm_lto_status_t function(llvm_lto_t lto, const char* input_filename)"],
	"llvm_optimize_modules" : ["llvm_lto_status_t function(llvm_lto_t lto, const char* output_filename)"],

	/+ LTO +/

	"lto_get_version" : ["const(char)* function()"],
	"lto_get_error_message" : ["const(char)* function()"],
	"lto_module_is_object_file" : ["bool function(const char* path)"],
	"lto_module_is_object_file_for_target" : ["bool function(const char* path, const char* target_triple_prefix)"],
	"lto_module_is_object_file_in_memory" : ["bool function(const void* mem, size_t length)"],
	"lto_module_is_object_file_in_memory_for_target" : ["bool function(const void* mem, size_t length, const char* target_triple_prefix)"],
	"lto_module_create" : ["lto_module_t function(const char* path)"],
	"lto_module_create_from_memory" : ["lto_module_t function(const void* mem, size_t length)"],
	"lto_module_create_from_fd" : ["lto_module_t function(int fd, const char* path, size_t file_size)"],
	/+ "offset" is originally of type "off_t", which is 64 bit on 64 bit machines,
	 + but can be 32 bit or 64 bit on 32 bit machines depending on compilation.
	 + Since there is no way to be sure how LLVM was compiled, the type "size_t"
	 + is used instead as a compromise, which is 64 bit on 64 bit machines and
	 + 32 bit on 32 bit machines. On 32 bit machines you will thus lose the extra
	 + 32 bit if LLVM was compiled with off_t as 64 bit, but it seems to be
	 + a reasonable tradeoff for the sake of compatibility at this time. +/
	"lto_module_create_from_fd_at_offset" : ["lto_module_t function(int fd, const char* path, size_t file_size, size_t map_size, size_t offset)"],
	"lto_module_dispose" : ["void function(lto_module_t mod)"],
	"lto_module_get_target_triple" : ["const(char)* function(lto_module_t mod)"],
	"lto_module_set_target_triple" : ["void function(lto_module_t mod, const char* triple)"],
	"lto_module_get_num_symbols" : ["uint function(lto_module_t mod)"],
	"lto_module_get_symbol_name" : ["const(char)* function(lto_module_t mod, uint index)"],
	"lto_module_get_symbol_attribute" : ["lto_symbol_attributes function(lto_module_t mod, uint index)"],
	"lto_codegen_create" : ["lto_code_gen_t function()"],
	"lto_codegen_dispose" : ["void function(lto_code_gen_t)"],
	"lto_codegen_add_module" : ["bool function(lto_code_gen_t cg, lto_module_t mod)"],
	"lto_codegen_set_debug_model" : ["bool function(lto_code_gen_t cg, lto_debug_model)"],
	"lto_codegen_set_pic_model" : ["bool function(lto_code_gen_t cg, lto_codegen_model)"],
	"lto_codegen_set_cpu" : ["void function(lto_code_gen_t cg, const char* cpu)"],
	"lto_codegen_set_assembler_path" : ["void function(lto_code_gen_t cg, const char* path)"],
	"lto_codegen_set_assembler_args" : ["void function(lto_code_gen_t cg, const char** args, int nargs)"],
	"lto_codegen_add_must_preserve_symbol" : ["void function(lto_code_gen_t cg, const char* symbol)"],
	"lto_codegen_write_merged_modules" : ["bool function(lto_code_gen_t cg, const char* path)"],
	"lto_codegen_compile" : ["const(void)* function(lto_code_gen_t cg, size_t* length)"],
	"lto_codegen_compile_to_file" : ["bool function(lto_code_gen_t cg, const char** name)"],
	"lto_codegen_debug_options" : ["void function(lto_code_gen_t cg, const char* )"],
	"lto_initialize_disassembler" : ["void function()",
	                                 "+", "3.3"],

	/+ Object file reading and writing +/

	"LLVMCreateObjectFile" : ["LLVMObjectFileRef function(LLVMMemoryBufferRef MemBuf)"],
	"LLVMDisposeObjectFile" : ["void function(LLVMObjectFileRef ObjectFile)"],
	"LLVMGetSections" : ["LLVMSectionIteratorRef function(LLVMObjectFileRef ObjectFile)"],
	"LLVMDisposeSectionIterator" : ["void function(LLVMSectionIteratorRef SI)"],
	"LLVMIsSectionIteratorAtEnd" : ["LLVMBool function(LLVMObjectFileRef ObjectFile, LLVMSectionIteratorRef SI)"],
	"LLVMMoveToNextSection" : ["void function(LLVMSectionIteratorRef SI)"],
	"LLVMMoveToContainingSection" : ["void function(LLVMSectionIteratorRef Sect, LLVMSymbolIteratorRef Sym)"],
	"LLVMGetSymbols" : ["LLVMSymbolIteratorRef function(LLVMObjectFileRef ObjectFile)"],
	"LLVMDisposeSymbolIterator" : ["void function(LLVMSymbolIteratorRef SI)"],
	"LLVMIsSymbolIteratorAtEnd" : ["LLVMBool function(LLVMObjectFileRef ObjectFile, LLVMSymbolIteratorRef SI)"],
	"LLVMMoveToNextSymbol" : ["void function(LLVMSymbolIteratorRef SI)"],
	"LLVMGetSectionName" : ["const(char)* function(LLVMSectionIteratorRef SI)"],
	"LLVMGetSectionSize" : ["ulong function(LLVMSectionIteratorRef SI)"],
	"LLVMGetSectionContents" : ["const(char)* function(LLVMSectionIteratorRef SI)"],
	"LLVMGetSectionAddress" : ["ulong function(LLVMSectionIteratorRef SI)"],
	"LLVMGetSectionContainsSymbol" : ["LLVMBool function(LLVMSectionIteratorRef SI, LLVMSymbolIteratorRef Sym)"],
	"LLVMGetRelocations" : ["LLVMRelocationIteratorRef function(LLVMSectionIteratorRef Section)"],
	"LLVMDisposeRelocationIterator" : ["void function(LLVMRelocationIteratorRef RI)"],
	"LLVMIsRelocationIteratorAtEnd" : ["LLVMBool function(LLVMSectionIteratorRef Section, LLVMRelocationIteratorRef RI)"],
	"LLVMMoveToNextRelocation" : ["void function(LLVMRelocationIteratorRef RI)"],
	"LLVMGetSymbolName" : ["const(char)* function(LLVMSymbolIteratorRef SI)"],
	"LLVMGetSymbolAddress" : ["ulong function(LLVMSymbolIteratorRef SI)"],
	"LLVMGetSymbolFileOffset" : ["ulong function(LLVMSymbolIteratorRef SI)"],
	"LLVMGetSymbolSize" : ["ulong function(LLVMSymbolIteratorRef SI)"],
	"LLVMGetRelocationAddress" : ["ulong function(LLVMRelocationIteratorRef RI)"],
	"LLVMGetRelocationOffset" : ["ulong function(LLVMRelocationIteratorRef RI)"],
	"LLVMGetRelocationSymbol" : ["LLVMSymbolIteratorRef function(LLVMRelocationIteratorRef RI)"],
	"LLVMGetRelocationType" : ["ulong function(LLVMRelocationIteratorRef RI)"],
	"LLVMGetRelocationTypeName" : ["const(char)* function(LLVMRelocationIteratorRef RI)"],
	"LLVMGetRelocationValueString" : ["const(char)* function(LLVMRelocationIteratorRef RI)"],

	/+ Target information +/

	/+
	 + These are all inline functions, meaning their bodies are
	 + defined in the C headers, so currently they do not get exported
	 + and are not loadable from LLVM's dynamic library.
	 + The functions they themselves call, however, are, even though
	 + they are not in the official llvm-c documentation - because
	 + they are split across LLVMs target libraries.
	 + That is why these functions are loaded instead and then used
	 + further down in appropriate reimplementations of these
	 + inline functions.
	 + The list of targets is:
	 + AArch64
	 + ARM
	 + CppBackend
	 + Hexagon
	 + MBlaze
	 + MSP430
	 + Mips
	 + NVPTX
	 + PowerPC
	 + Sparc
	 + X86
	 + XCore
	 +
	 +
	 "LLVMInitializeAllTargetInfos" : ["static void function()"],
	 "LLVMInitializeAllTargets" : ["static void function()"],
	 "LLVMInitializeAllTargetMCs" : ["static void function()"],
	 "LLVMInitializeAllAsmPrinters" : ["static void function()"],
	 "LLVMInitializeAllAsmParsers" : ["static void function()"],
	 "LLVMInitializeAllDisassemblers" : ["static void function()"],
	 "LLVMInitializeNativeTarget" : ["static LLVMBool function()"], +/
	"LLVMInitializeAArch64TargetInfo" : ["void function()"],
	"LLVMInitializeAArch64Target" : ["void function()"],
	"LLVMInitializeAArch64TargetMC" : ["void function()"],
	"LLVMInitializeAArch64AsmPrinter" : ["void function()"],
	"LLVMInitializeAArch64AsmParser" : ["void function()"],
	"LLVMInitializeAArch64Disassembler" : ["void function()"],

	"LLVMInitializeARMTargetInfo" : ["void function()"],
	"LLVMInitializeARMTarget" : ["void function()"],
	"LLVMInitializeARMTargetMC" : ["void function()"],
	"LLVMInitializeARMAsmPrinter" : ["void function()"],
	"LLVMInitializeARMAsmParser" : ["void function()"],
	"LLVMInitializeARMDisassembler" : ["void function()"],

	"LLVMInitializeCppBackendTargetInfo" : ["void function()"],
	"LLVMInitializeCppBackendTarget" : ["void function()"],
	"LLVMInitializeCppBackendTargetMC" : ["void function()"],

	"LLVMInitializeHexagonTargetInfo" : ["void function()"],
	"LLVMInitializeHexagonTarget" : ["void function()"],
	"LLVMInitializeHexagonTargetMC" : ["void function()"],
	"LLVMInitializeHexagonAsmPrinter" : ["void function()"],

	"LLVMInitializeMBlazeTargetInfo" : ["void function()"],
	"LLVMInitializeMBlazeTarget" : ["void function()"],
	"LLVMInitializeMBlazeTargetMC" : ["void function()"],
	"LLVMInitializeMBlazeAsmPrinter" : ["void function()"],
	"LLVMInitializeMBlazeAsmParser" : ["void function()"],
	"LLVMInitializeMBlazeDisassembler" : ["void function()"],

	"LLVMInitializeMSP430TargetInfo" : ["void function()"],
	"LLVMInitializeMSP430Target" : ["void function()"],
	"LLVMInitializeMSP430TargetMC" : ["void function()"],
	"LLVMInitializeMSP430AsmPrinter" : ["void function()"],

	"LLVMInitializeMipsTargetInfo" : ["void function()"],
	"LLVMInitializeMipsTarget" : ["void function()"],
	"LLVMInitializeMipsTargetMC" : ["void function()"],
	"LLVMInitializeMipsAsmPrinter" : ["void function()"],
	"LLVMInitializeMipsAsmParser" : ["void function()"],
	"LLVMInitializeMipsDisassembler" : ["void function()"],

	"LLVMInitializeNVPTXTargetInfo" : ["void function()"],
	"LLVMInitializeNVPTXTarget" : ["void function()"],
	"LLVMInitializeNVPTXTargetMC" : ["void function()"],
	"LLVMInitializeNVPTXAsmPrinter" : ["void function()"],

	"LLVMInitializePowerPCTargetInfo" : ["void function()"],
	"LLVMInitializePowerPCTarget" : ["void function()"],
	"LLVMInitializePowerPCTargetMC" : ["void function()"],
	"LLVMInitializePowerPCAsmPrinter" : ["void function()"],

	"LLVMInitializeSparcTargetInfo" : ["void function()"],
	"LLVMInitializeSparcTarget" : ["void function()"],
	"LLVMInitializeSparcTargetMC" : ["void function()"],
	"LLVMInitializeSparcAsmPrinter" : ["void function()"],

	"LLVMInitializeX86TargetInfo" : ["void function()"],
	"LLVMInitializeX86Target" : ["void function()"],
	"LLVMInitializeX86TargetMC" : ["void function()"],
	"LLVMInitializeX86AsmPrinter" : ["void function()"],
	"LLVMInitializeX86AsmParser" : ["void function()"],
	"LLVMInitializeX86Disassembler" : ["void function()"],

	"LLVMInitializeXCoreTargetInfo" : ["void function()"],
	"LLVMInitializeXCoreTarget" : ["void function()"],
	"LLVMInitializeXCoreTargetMC" : ["void function()"],
	"LLVMInitializeXCoreAsmPrinter" : ["void function()"],
	"LLVMInitializeXCoreDisassembler" : ["void function()"],

	"LLVMCreateTargetData" : ["LLVMTargetDataRef function(const char* StringRep)"],
	"LLVMAddTargetData" : ["void function(LLVMTargetDataRef, LLVMPassManagerRef)"],
	"LLVMAddTargetLibraryInfo" : ["void function(LLVMTargetLibraryInfoRef, LLVMPassManagerRef)"],
	"LLVMCopyStringRepOfTargetData" : ["char* function(LLVMTargetDataRef)"],
	"LLVMByteOrder" : ["enum LLVMByteOrdering function(LLVMTargetDataRef)"],
	"LLVMPointerSize" : ["uint function(LLVMTargetDataRef)"],
	"LLVMPointerSizeForAS" : ["uint function(LLVMTargetDataRef, uint AS)",
	                          "+", "3.2"],
	"LLVMIntPtrType" : ["LLVMTypeRef function(LLVMTargetDataRef)"],
	"LLVMIntPtrTypeForAS" : ["LLVMTypeRef function(LLVMTargetDataRef, uint AS)",
	                         "+", "3.2"],
	"LLVMSizeOfTypeInBits" : ["ulong function(LLVMTargetDataRef, LLVMTypeRef)"],
	"LLVMStoreSizeOfType" : ["ulong function(LLVMTargetDataRef, LLVMTypeRef)"],
	"LLVMABISizeOfType" : ["ulong function(LLVMTargetDataRef, LLVMTypeRef)"],
	"LLVMABIAlignmentOfType" : ["uint function(LLVMTargetDataRef, LLVMTypeRef)"],
	"LLVMCallFrameAlignmentOfType" : ["uint function(LLVMTargetDataRef, LLVMTypeRef)"],
	"LLVMPreferredAlignmentOfType" : ["uint function(LLVMTargetDataRef, LLVMTypeRef)"],
	"LLVMPreferredAlignmentOfGlobal" : ["uint function(LLVMTargetDataRef, LLVMValueRef GlobalVar)"],
	"LLVMElementAtOffset" : ["uint function(LLVMTargetDataRef, LLVMTypeRef StructTy, ulong Offset)"],
	"LLVMOffsetOfElement" : ["ulong function(LLVMTargetDataRef, LLVMTypeRef StructTy, uint Element)"],
	"LLVMDisposeTargetData" : ["void function(LLVMTargetDataRef)"],

	/+ Target machine +/

	"LLVMGetFirstTarget" : ["LLVMTargetRef function()"],
	"LLVMGetNextTarget" :  ["LLVMTargetRef function(LLVMTargetRef T)"],
	"LLVMGetTargetName" : ["const(char)* function(LLVMTargetRef T)"],
	"LLVMGetTargetDescription" : ["const(char)* function(LLVMTargetRef T)"],
	"LLVMTargetHasJIT" : ["LLVMBool function(LLVMTargetRef T)"],
	"LLVMTargetHasTargetMachine" : ["LLVMBool function(LLVMTargetRef T)"],
	"LLVMTargetHasAsmBackend" : ["LLVMBool function(LLVMTargetRef T)"],
	"LLVMCreateTargetMachine" : ["LLVMTargetMachineRef function(LLVMTargetRef T, char* Triple,  char* CPU, char* Features, LLVMCodeGenOptLevel Level, LLVMRelocMode Reloc, LLVMCodeModel CodeModel)"],
	"LLVMDisposeTargetMachine" : ["void function(LLVMTargetMachineRef T)"],
	"LLVMGetTargetMachineTarget" : ["LLVMTargetRef function(LLVMTargetMachineRef T)"],
	"LLVMGetTargetMachineTriple" : ["char* function(LLVMTargetMachineRef T)"],
	"LLVMGetTargetMachineCPU" : ["char* function(LLVMTargetMachineRef T)"],
	"LLVMGetTargetMachineFeatureString" : ["char* function(LLVMTargetMachineRef T)"],
	"LLVMGetTargetMachineData" : ["LLVMTargetDataRef function(LLVMTargetMachineRef T)"],
	"LLVMTargetMachineEmitToFile" : ["LLVMBool function(LLVMTargetMachineRef T, LLVMModuleRef M,  char* Filename, LLVMCodeGenFileType codegen, char** ErrorMessage)"]
	];
