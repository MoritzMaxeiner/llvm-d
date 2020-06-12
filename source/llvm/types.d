module llvm.types;

public import std.stdint : uintptr_t;

import llvm.config;
import core.stdc.stdint;

/+ Analysis +/

alias int LLVMVerifierFailureAction;

/+ Transforms +/

/++ Interprocedural transformations ++/

static if (LLVM_Version >= asVersion(10, 0, 0))
{
	alias extern(C) LLVMBool function(LLVMValueRef, void*) MustPreserveCallback;
}

/++ Pass manager builder ++/

struct LLVMOpaquePassManagerBuilder; alias LLVMOpaquePassManagerBuilder* LLVMPassManagerBuilderRef;

/+ Core +/

static if (LLVM_Version >= asVersion(3, 4, 0))
{
	alias extern(C) void function(const char* Reason) LLVMFatalErrorHandler;
}

static if (LLVM_Version >= asVersion(3, 5, 0))
{
	//This is here because putting it where it semantically belongs creates a forward reference issues.
	struct LLVMOpaqueDiagnosticInfo; alias LLVMOpaqueDiagnosticInfo* LLVMDiagnosticInfoRef;

	alias extern(C) void function(LLVMDiagnosticInfoRef, void*) LLVMDiagnosticHandler;
	alias extern(C) void function(LLVMContextRef, void *) LLVMYieldCallback;
}

/++ Types and Enumerations ++/

alias int LLVMBool;
struct LLVMOpaqueContext; alias LLVMOpaqueContext* LLVMContextRef;
struct LLVMOpaqueModule; alias LLVMOpaqueModule* LLVMModuleRef;
struct LLVMOpaqueType; alias LLVMOpaqueType* LLVMTypeRef;
struct LLVMOpaqueValue; alias LLVMOpaqueValue* LLVMValueRef;
static if (LLVM_Version >= asVersion(5, 0, 0)) {
	struct LLVMOpaqueMetadata; alias LLVMOpaqueMetadata* LLVMMetadataRef;
}
static if (LLVM_Version >= asVersion(8, 0, 0)) {
	struct LLVMOpaqueNamedMDNode; alias LLVMOpaqueNamedMDNode* LLVMNamedMDNodeRef;

	struct LLVMOpaqueValueMetadataEntry; alias LLVMOpaqueValueMetadataEntry* LLVMValueMetadataEntry;
}
struct LLVMOpaqueBasicBlock; alias LLVMOpaqueBasicBlock* LLVMBasicBlockRef;
static if (LLVM_Version >= asVersion(5, 0, 0)) {
	struct LLVMOpaqueDIBuilder; alias LLVMOpaqueDIBuilder* LLVMDIBuilderRef;
}
struct LLVMOpaqueBuilder; alias LLVMOpaqueBuilder* LLVMBuilderRef;
struct LLVMOpaqueModuleProvider; alias LLVMOpaqueModuleProvider* LLVMModuleProviderRef;
struct LLVMOpaqueMemoryBuffer; alias LLVMOpaqueMemoryBuffer* LLVMMemoryBufferRef;
struct LLVMOpaquePassManager; alias LLVMOpaquePassManager* LLVMPassManagerRef;
struct LLVMOpaquePassRegistry; alias LLVMOpaquePassRegistry* LLVMPassRegistryRef;
struct LLVMOpaqueUse; alias LLVMOpaqueUse* LLVMUseRef;

static if (LLVM_Version >= asVersion(3, 9, 0)) {
	struct LLVMOpaqueAttributeRef; alias LLVMOpaqueAttributeRef* LLVMAttributeRef;
}

alias long LLVMAttribute;
alias int LLVMOpcode;
alias int LLVMTypeKind;
alias int LLVMLinkage;
alias int LLVMVisibility;
alias int LLVMDLLStorageClass;
alias int LLVMCallConv;
alias int LLVMIntPredicate;
alias int LLVMRealPredicate;
alias int LLVMLandingPadClauseTy;
static if (LLVM_Version >= asVersion(3, 3, 0))
{
	alias int LLVMThreadLocalMode;
	alias int LLVMAtomicOrdering;
	alias int LLVMAtomicRMWBinOp;
}
static if (LLVM_Version >= asVersion(3, 5, 0))
{
	alias int LLVMDiagnosticSeverity;
}
static if (LLVM_Version >= asVersion(3, 9, 0))
{
	alias int LLVMValueKind;
	alias uint LLVMAttributeIndex;
}
/+ Disassembler +/

alias void* LLVMDisasmContextRef;
alias extern(C) int function(void* DisInfo, ulong PC, ulong Offset, ulong Size, int TagType, void* TagBuf) LLVMOpInfoCallback;
alias extern(C) const char* function(void* DisInfo, ulong ReferenceValue, ulong* ReferenceType, ulong ReferencePC, const char** ReferenceName) LLVMSymbolLookupCallback;

struct LLVMOpInfoSymbol1
{
	ulong Present;
	const(char)* Name;
	ulong Value;
}

struct LLVMOpInfo1
{
	LLVMOpInfoSymbol1 AddSymbol;
	LLVMOpInfoSymbol1 SubtractSymbol;
	ulong Value;
	ulong VariantKind;
}

static if (LLVM_Version < asVersion(3, 3, 0))
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

struct LLVMOpaqueGenericValue; alias LLVMOpaqueGenericValue* LLVMGenericValueRef;
struct LLVMOpaqueExecutionEngine; alias LLVMOpaqueExecutionEngine* LLVMExecutionEngineRef;

static if (LLVM_Version >= asVersion(3, 3, 0))
{
	static if (LLVM_Version >= asVersion(3, 4, 0))
	{
		struct LLVMOpaqueMCJITMemoryManager; alias LLVMOpaqueMCJITMemoryManager* LLVMMCJITMemoryManagerRef;

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

static if (LLVM_Version >= asVersion(3, 2, 0))
{
	/+ Linker +/

	alias int LLVMLinkerMode;
}

/+ Link Time Optimization +/
alias bool lto_bool_t;
alias void* llvm_lto_t;
alias llvm_lto_status llvm_lto_status_t;


alias int llvm_lto_status;

/+ LTO +/

static if (LLVM_Version >= asVersion(9, 0, 0))
{
	struct LLVMOpaqueLTOInput; alias LLVMOpaqueLTOInput* lto_input_t;
}
static if (LLVM_Version >= asVersion(3, 5, 0))
{
	struct LLVMOpaqueLTOModule; alias LLVMOpaqueLTOModule* lto_module_t;
}
else
{
	struct LTOModule; alias LTOModule* lto_module_t;
}
static if (LLVM_Version >= asVersion(3, 5, 0))
{
	struct LLVMOpaqueLTOCodeGenerator; alias LLVMOpaqueLTOCodeGenerator* lto_code_gen_t;
}
else
{
	struct LTOCodeGenerator; alias LTOCodeGenerator* lto_code_gen_t;
}
static if (LLVM_Version >= asVersion(3, 9, 0))
{
	struct LLVMOpaqueThinLTOCodeGenerator; alias LLVMOpaqueThinLTOCodeGenerator* thinlto_code_gen_t;
}

alias int lto_symbol_attributes;
alias int lto_debug_model;
alias int lto_codegen_model;
alias int lto_codegen_diagnostic_severity_t;
alias extern(C) void function(lto_codegen_diagnostic_severity_t severity, const(char)* diag, void* ctxt) lto_diagnostic_handler_t;

/+ Object file reading and writing +/

static if (LLVM_Version >= asVersion(9, 0, 0))
{
	alias int LLVMBinaryType;

	struct LLVMOpaqueBinary; alias LLVMOpaqueBinary* LLVMBinaryRef;

	deprecated("Use LLVMBinaryRef instead.") struct LLVMOpaqueObjectFile;
	deprecated("Use LLVMBinaryRef instead.") alias LLVMOpaqueObjectFile* LLVMObjectFileRef;
}
else
{
	struct LLVMOpaqueObjectFile; alias LLVMOpaqueObjectFile* LLVMObjectFileRef;
}
struct LLVMOpaqueSectionIterator; alias LLVMOpaqueSectionIterator* LLVMSectionIteratorRef;
struct LLVMOpaqueSymbolIterator; alias LLVMOpaqueSymbolIterator* LLVMSymbolIteratorRef;
struct LLVMOpaqueRelocationIterator; alias LLVMOpaqueRelocationIterator* LLVMRelocationIteratorRef;

/+ Target information +/

struct LLVMOpaqueTargetData; alias LLVMOpaqueTargetData* LLVMTargetDataRef;
struct LLVMOpaqueTargetLibraryInfotData; alias LLVMOpaqueTargetLibraryInfotData* LLVMTargetLibraryInfoRef;
static if (LLVM_Version < asVersion(3, 4, 0))
{
	struct LLVMStructLayout; alias LLVMStructLayout* LLVMStructLayoutRef;
}
alias int LLVMByteOrdering;

/+ Target machine +/

struct LLVMOpaqueTargetMachine; alias LLVMOpaqueTargetMachine* LLVMTargetMachineRef;
struct LLVMTarget; alias LLVMTarget* LLVMTargetRef;

alias int LLVMCodeGenOptLevel;
alias int LLVMRelocMode;
alias int LLVMCodeModel;
alias int LLVMCodeGenFileType;

static if (LLVM_Version >= asVersion(5, 0, 0) && LLVM_Version < asVersion(7, 0, 0)) {
	struct LLVMOpaqueSharedModule; alias LLVMOpaqueSharedModule* LLVMSharedModuleRef;
}
static if (LLVM_Version >= asVersion(5, 0, 0) && LLVM_Version < asVersion(6, 0, 0)) {
	struct LLVMOpaqueSharedObjectBuffer; alias LLVMOpaqueSharedObjectBuffer* LLVMSharedObjectBufferRef;
}

static if (LLVM_Version >= asVersion(3, 8, 0))
{
	/+ JIT compilation of LLVM IR +/

	struct LLVMOrcOpaqueJITStack; alias LLVMOrcOpaqueJITStack* LLVMOrcJITStackRef;
}

static if (LLVM_Version >= asVersion(7, 0, 0))
{
	alias uint64_t LLVMOrcModuleHandle;
}
else static if (LLVM_Version >= asVersion(3, 8, 0))
{
	alias uint32_t LLVMOrcModuleHandle;
}

static if (LLVM_Version >= asVersion(3, 8, 0))
{
	alias ulong LLVMOrcTargetAddress;

	alias extern(C) ulong function(const(char)* Name, void* LookupCtx) LLVMOrcSymbolResolverFn;
	alias extern(C) ulong function(LLVMOrcJITStackRef JITStack, void* CallbackCtx) LLVMOrcLazyCompileCallbackFn;
}

static if (LLVM_Version >= asVersion(3, 9, 0))
{
	alias int LLVMOrcErrorCode;

	struct LTOObjectBuffer
	{
		const(char)* Buffer;
		size_t Size;
	}
}

/+ Debug info flags +/

static if (LLVM_Version >= asVersion(6, 0, 0))
{
	alias int LLVMDIFlags;
	alias int LLVMDWARFSourceLanguage;
	alias int LLVMDWARFEmissionKind;
}


static if (LLVM_Version >= asVersion(7, 0, 0))
{
	alias int LLVMComdatSelectionKind;
	alias int LLVMUnnamedAddr;
	alias int LLVMInlineAsmDialect;
	alias int LLVMModuleFlagBehavior;
	alias int LLVMDWARFTypeEncoding;

}

static if (LLVM_Version >= asVersion(10, 0, 0))
{
	alias int LLVMDWARFMacinfoRecordType;
}


static if (LLVM_Version >= asVersion(8, 0, 0)) {
	alias uint LLVMMetadataKind;
}

static if (LLVM_Version >= asVersion(7, 0, 0)) {
	struct LLVMComdat; alias LLVMComdat* LLVMComdatRef;
}

static if (LLVM_Version >= asVersion(7, 0, 0)) {
	struct LLVMOpaqueModuleFlagEntry; alias LLVMOpaqueModuleFlagEntry* LLVMModuleFlagEntry;
}

static if (LLVM_Version >= asVersion(7, 0, 0)) {
	struct LLVMOpaqueJITEventListener; alias LLVMOpaqueJITEventListener* LLVMJITEventListenerRef;
}

/+ Error +/

static if (LLVM_Version >= asVersion(8, 0, 0)) {
	struct LLVMOpaqueError; alias LLVMOpaqueError* LLVMErrorRef;

	alias const void* LLVMErrorTypeId;
}

/+ Remarks / OptRemarks +/

static if (LLVM_Version >= asVersion(9, 0, 0)) {
	struct LLVMRemarkOpaqueString; alias LLVMRemarkOpaqueString* LLVMRemarkStringRef;
	struct LLVMRemarkOpaqueEntry; alias LLVMRemarkOpaqueEntry* LLVMRemarkEntryRef;
	struct LLVMRemarkOpaqueParser; alias LLVMRemarkOpaqueParser* LLVMRemarkParserRef;
	struct LLVMRemarkOpaqueArg; alias LLVMRemarkOpaqueArg* LLVMRemarkArgRef;
	struct LLVMRemarkOpaqueDebugLoc; alias LLVMRemarkOpaqueDebugLoc* LLVMRemarkDebugLocRef;

	alias int LLVMRemarkType;
} else static if (LLVM_Version >= asVersion(8, 0, 0)) {
	struct LLVMOptRemarkStringRef
	{
		const(char)* Str;
		uint32_t Len;
	}

	struct LLVMOptRemarkDebugLoc
	{
		// File:
		LLVMOptRemarkStringRef SourceFile;
		// Line:
		uint32_t SourceLineNumber;
		// Column:
		uint32_t SourceColumnNumber;
	}

	struct LLVMOptRemarkArg
	{
		// e.g. "Callee"
		LLVMOptRemarkStringRef Key;
		// e.g. "malloc"
		LLVMOptRemarkStringRef Value;

		// "DebugLoc": Optional
		LLVMOptRemarkDebugLoc DebugLoc;
	}

	struct LLVMOptRemarkEntry
	{
		// e.g. !Missed, !Passed
		LLVMOptRemarkStringRef RemarkType;
		// "Pass": Required
		LLVMOptRemarkStringRef PassName;
		// "Name": Required
		LLVMOptRemarkStringRef RemarkName;
		// "Function": Required
		LLVMOptRemarkStringRef FunctionName;

		// "DebugLoc": Optional
		LLVMOptRemarkDebugLoc DebugLoc;
		// "Hotness": Optional
		uint32_t Hotness;
		// "Args": Optional. It is an array of `num_args` elements.
		uint32_t NumArgs;
		LLVMOptRemarkArg* Args;
	}

	struct LLVMOptRemarkOpaqueParser; alias LLVMOptRemarkOpaqueParser* LLVMOptRemarkParserRef;
}
