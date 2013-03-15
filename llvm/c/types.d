
module llvm.c.types;

private
{
	import llvm.c.versions;
}

/+ Analysis +/

alias uint LLVMVerifierFailureAction;

/+ Transforms +/

/++ Pass manager builder ++/

struct LLVMOpaquePassManagerBuilder; alias LLVMOpaquePassManagerBuilder* LLVMPassManagerBuilderRef;

/+ Core +/

/++ Types and Enumerations ++/

alias int LLVMBool;
struct LLVMOpaqueContext; alias LLVMOpaqueContext* LLVMContextRef;
struct LLVMOpaqueModule; alias LLVMOpaqueModule* LLVMModuleRef;
struct LLVMOpaqueType; alias LLVMOpaqueType* LLVMTypeRef;
struct LLVMOpaqueValue; alias LLVMOpaqueValue* LLVMValueRef;
struct LLVMOpaqueBasicBlock; alias LLVMOpaqueBasicBlock* LLVMBasicBlockRef;
struct LLVMOpaqueBuilder; alias LLVMOpaqueBuilder* LLVMBuilderRef;
struct LLVMOpaqueModuleProvider; alias LLVMOpaqueModuleProvider* LLVMModuleProviderRef;
struct LLVMOpaqueMemoryBuffer; alias LLVMOpaqueMemoryBuffer* LLVMMemoryBufferRef;
struct LLVMOpaquePassManager; alias LLVMOpaquePassManager* LLVMPassManagerRef;
struct LLVMOpaquePassRegistry; alias LLVMOpaquePassRegistry* LLVMPassRegistryRef;
struct LLVMOpaqueUse; alias LLVMOpaqueUse* LLVMUseRef;

alias ulong LLVMAttribute;
alias uint LLVMOpcode;
alias uint LLVMTypeKind;
alias uint LLVMLinkage;
alias uint LLVMVisibility;
alias uint LLVMCallConv;
alias uint LLVMIntPredicate;
alias uint LLVMRealPredicate;
alias uint LLVMLandingPadClauseTy;

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

	alias uint EDAssemblySyntax_t;

	alias extern(C) int function(ubyte* Byte, ulong address, void* arg) EDByteReaderCallback;
	alias extern(C) int function(ulong* value, uint regID, void* arg) EDRegisterReaderCallback;

	alias extern(C) int function(ubyte* Byte, ulong address) EDByteBlock_t;
	alias extern(C) int function(ulong* value, uint regID) EDRegisterBlock_t;
	alias extern(C) int function(EDTokenRef token) EDTokenVisitor_t;
}

/+ Execution Engine +/

struct LLVMOpaqueGenericValue; alias LLVMOpaqueGenericValue* LLVMGenericValueRef;
struct LLVMOpaqueExecutionEngine; alias LLVMOpaqueExecutionEngine* LLVMExecutionEngineRef;

static if(LLVM_Version >= 3.2)
{
	/+ Linker +/

	alias uint LLVMLinkerMode;
}

/+ Link Time Optimization +/

alias void* llvm_lto_t;
alias llvm_lto_status llvm_lto_status_t;


alias uint llvm_lto_status;

/+ LTO +/

struct LTOModule; alias LTOModule* lto_module_t;
struct LTOCodeGenerator; alias LTOCodeGenerator* lto_code_gen_t;

alias uint lto_symbol_attributes;
alias uint lto_debug_model;
alias uint lto_codegen_model;

/+ Object file reading and writing +/

struct LLVMOpaqueObjectFile; alias LLVMOpaqueObjectFile* LLVMObjectFileRef;
struct LLVMOpaqueSectionIterator; alias LLVMOpaqueSectionIterator* LLVMSectionIteratorRef;
struct LLVMOpaqueSymbolIterator; alias LLVMOpaqueSymbolIterator* LLVMSymbolIteratorRef;
struct LLVMOpaqueRelocationIterator; alias LLVMOpaqueRelocationIterator* LLVMRelocationIteratorRef;

/+ Target information +/

struct LLVMOpaqueTargetData; alias LLVMOpaqueTargetData* LLVMTargetDataRef;
struct LLVMOpaqueTargetLibraryInfotData; alias LLVMOpaqueTargetLibraryInfotData* LLVMTargetLibraryInfoRef;
struct LLVMStructLayout; alias LLVMStructLayout* LLVMStructLayoutRef;

alias uint LLVMByteOrdering;

/+ Target machine +/

struct LLVMTargetMachine; alias LLVMTargetMachine* LLVMTargetMachineRef;
struct LLVMTarget; alias LLVMTarget* LLVMTargetRef;

alias uint LLVMCodeGenOptLevel;
alias uint LLVMRelocMode;
alias uint LLVMCodeModel;
alias uint LLVMCodeGenFileType;