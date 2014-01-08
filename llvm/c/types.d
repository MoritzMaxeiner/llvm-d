
module llvm.c.types;

private
{
	import std.stdint : uintptr_t;

	import llvm.c.versions;
}

/+ Analysis +/

alias int LLVMVerifierFailureAction;

/+ Transforms +/

/++ Pass manager builder ++/

struct LLVMOpaquePassManagerBuilder {}; alias LLVMOpaquePassManagerBuilder* LLVMPassManagerBuilderRef;

/+ Core +/

static if(LLVM_Version >= 3.4)
{
		alias extern(C) void function(const char* Reason) LLVMFatalErrorHandler;
}

/++ Types and Enumerations ++/

alias int LLVMBool;
struct LLVMOpaqueContext {}; alias LLVMOpaqueContext* LLVMContextRef;
struct LLVMOpaqueModule {}; alias LLVMOpaqueModule* LLVMModuleRef;
struct LLVMOpaqueType {}; alias LLVMOpaqueType* LLVMTypeRef;
struct LLVMOpaqueValue {}; alias LLVMOpaqueValue* LLVMValueRef;
struct LLVMOpaqueBasicBlock {}; alias LLVMOpaqueBasicBlock* LLVMBasicBlockRef;
struct LLVMOpaqueBuilder {}; alias LLVMOpaqueBuilder* LLVMBuilderRef;
struct LLVMOpaqueModuleProvider {}; alias LLVMOpaqueModuleProvider* LLVMModuleProviderRef;
struct LLVMOpaqueMemoryBuffer {}; alias LLVMOpaqueMemoryBuffer* LLVMMemoryBufferRef;
struct LLVMOpaquePassManager {}; alias LLVMOpaquePassManager* LLVMPassManagerRef;
struct LLVMOpaquePassRegistry {}; alias LLVMOpaquePassRegistry* LLVMPassRegistryRef;
struct LLVMOpaqueUse {}; alias LLVMOpaqueUse* LLVMUseRef;

alias long LLVMAttribute;
alias int LLVMOpcode;
alias int LLVMTypeKind;
alias int LLVMLinkage;
alias int LLVMVisibility;
alias int LLVMCallConv;
alias int LLVMIntPredicate;
alias int LLVMRealPredicate;
alias int LLVMLandingPadClauseTy;
static if(LLVM_Version >= 3.3)
{
	alias int LLVMThreadLocalMode;
	alias int LLVMAtomicOrdering;
	alias int LLVMAtomicRMWBinOp;
}

/+ Disassembler +/

alias void* LLVMDisasmContextRef;
alias extern(C) int function(void* DisInfo, ulong PC, ulong Offset, ulong Size, int TagType, void* TagBuf) LLVMOpInfoCallback;
alias extern(C) const char* function(void* DisInfo, ulong ReferenceValue, ulong* ReferenceType, ulong ReferencePC, const char** ReferenceName) LLVMSymbolLookupCallback;

struct LLVMOpInfoSymbol1
{
	ulong Present;
	const char* Name;
	ulong Value;
}

struct LLVMOpInfo1
{
	LLVMOpInfoSymbol1 AddSymbol;
	LLVMOpInfoSymbol1 SubtractSymbol;
	ulong Value;
	ulong VariantKind;
}

static if(LLVM_Version < 3.3)
{
	/+ Enhanced Disassembly +/

	alias void* EDDisassemblerRef;
	alias void* EDInstRef;
	alias void* EDTokenRef;
	alias void* EDOperandRef;

	alias int EDAssemblySyntax_t;

	alias extern(C) int function(ubyte* Byte, ulong address, void* arg) EDByteReaderCallback;
	alias extern(C) int function(ulong* value, uint regID, void* arg) EDRegisterReaderCallback;

	alias extern(C) int function(ubyte* Byte, ulong address) EDByteBlock_t;
	alias extern(C) int function(ulong* value, uint regID) EDRegisterBlock_t;
	alias extern(C) int function(EDTokenRef token) EDTokenVisitor_t;
}

/+ Execution Engine +/

struct LLVMOpaqueGenericValue {}; alias LLVMOpaqueGenericValue* LLVMGenericValueRef;
struct LLVMOpaqueExecutionEngine {}; alias LLVMOpaqueExecutionEngine* LLVMExecutionEngineRef;

static if(LLVM_Version >= 3.3)
{
	static if(LLVM_Version >= 3.4)
	{
		struct LLVMOpaqueMCJITMemoryManager {}; alias LLVMOpaqueMCJITMemoryManager* LLVMMCJITMemoryManagerRef;

		struct LLVMMCJITCompilerOptions
		{
			uint OptLevel;
			LLVMCodeModel CodeModel;
			LLVMBool NoFramePointerElim;
			LLVMBool EnableFastISel;
			LLVMMCJITMemoryManagerRef MCJMM;
		}

		alias extern(C) ubyte function(void* Opaque, uintptr_t Size, uint Alignment, uint SectionID, const char* SectionName) LLVMMemoryManagerAllocateCodeSectionCallback;
		alias extern(C) ubyte function(void* Opaque, uintptr_t Size, uint Alignment, uint SectionID, const char* SectionName, LLVMBool IsReadOnly) LLVMMemoryManagerAllocateDataSectionCallback;
		alias extern(C) LLVMBool function(void* Opaque, char** ErrMsg) LLVMMemoryManagerFinalizeMemoryCallback;
		alias extern(C) void function(void* Opaque) LLVMMemoryManagerDestroyCallback;
	}
	else
	{
		struct LLVMMCJITCompilerOptions
		{
			uint OptLevel;
			LLVMCodeModel CodeModel;
			LLVMBool NoFramePointerElim;
			LLVMBool EnableFastISel;
		}
	}
}

static if(LLVM_Version >= 3.2)
{
	/+ Linker +/

	alias int LLVMLinkerMode;
}

/+ Link Time Optimization +/

alias void* llvm_lto_t;
alias llvm_lto_status llvm_lto_status_t;


alias int llvm_lto_status;

/+ LTO +/

struct LTOModule {}; alias LTOModule* lto_module_t;
struct LTOCodeGenerator {}; alias LTOCodeGenerator* lto_code_gen_t;

alias int lto_symbol_attributes;
alias int lto_debug_model;
alias int lto_codegen_model;

/+ Object file reading and writing +/

struct LLVMOpaqueObjectFile {}; alias LLVMOpaqueObjectFile* LLVMObjectFileRef;
struct LLVMOpaqueSectionIterator {}; alias LLVMOpaqueSectionIterator* LLVMSectionIteratorRef;
struct LLVMOpaqueSymbolIterator {}; alias LLVMOpaqueSymbolIterator* LLVMSymbolIteratorRef;
struct LLVMOpaqueRelocationIterator {}; alias LLVMOpaqueRelocationIterator* LLVMRelocationIteratorRef;

/+ Target information +/

struct LLVMOpaqueTargetData {}; alias LLVMOpaqueTargetData* LLVMTargetDataRef;
struct LLVMOpaqueTargetLibraryInfotData {}; alias LLVMOpaqueTargetLibraryInfotData* LLVMTargetLibraryInfoRef;
static if(LLVM_Version < 3.4)
{
	struct LLVMStructLayout {}; alias LLVMStructLayout* LLVMStructLayoutRef;
}
alias int LLVMByteOrdering;

/+ Target machine +/

struct LLVMOpaqueTargetMachine {}; alias LLVMOpaqueTargetMachine* LLVMTargetMachineRef;
struct LLVMTarget {}; alias LLVMTarget* LLVMTargetRef;

alias int LLVMCodeGenOptLevel;
alias int LLVMRelocMode;
alias int LLVMCodeModel;
alias int LLVMCodeGenFileType;