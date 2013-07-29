
module llvm.c.constants;

private
{
	import llvm.util.templates;

	import llvm.c.types;
	import llvm.c.versions;
}

/+ Analysis +/

enum : LLVMVerifierFailureAction
{
	LLVMAbortProcessAction,
	LLVMPrintMessageAction,
	LLVMReturnStatusAction
}

/+ Core +/

/++ Types and Enumerations ++/

enum : LLVMAttribute
{
	LLVMZExtAttribute = 1<<0,
	LLVMSExtAttribute = 1<<1,
	LLVMNoReturnAttribute = 1<<2,
	LLVMInRegAttribute = 1<<3,
	LLVMStructRetAttribute = 1<<4,
	LLVMNoUnwindAttribute = 1<<5,
	LLVMNoAliasAttribute = 1<<6,
	LLVMByValAttribute = 1<<7,
	LLVMNestAttribute = 1<<8,
	LLVMReadNoneAttribute = 1<<9,
	LLVMReadOnlyAttribute = 1<<10,
	LLVMNoInlineAttribute = 1<<11,
	LLVMAlwaysInlineAttribute = 1<<12,
	LLVMOptimizeForSizeAttribute = 1<<13,
	LLVMStackProtectAttribute = 1<<14,
	LLVMStackProtectReqAttribute = 1<<15,
	LLVMAlignment = 31<<16,
	LLVMNoCaptureAttribute = 1<<21,
	LLVMNoRedZoneAttribute = 1<<22,
	LLVMNoImplicitFloatAttribute = 1<<23,
	LLVMNakedAttribute = 1<<24,
	LLVMInlineHintAttribute = 1<<25,
	LLVMStackAlignment = 7<<26,
	LLVMReturnsTwice = 1<<29,
	LLVMUWTable = 1<<30,
	LLVMNonLazyBind = 1<<31
}

enum : LLVMOpcode
{
	LLVMRet            = 1,
	LLVMBr             = 2,
	LLVMSwitch         = 3,
	LLVMIndirectBr     = 4,
	LLVMInvoke         = 5,
	LLVMUnreachable    = 7,
	LLVMAdd            = 8,
	LLVMFAdd           = 9,
	LLVMSub            = 10,
	LLVMFSub           = 11,
	LLVMMul            = 12,
	LLVMFMul           = 13,
	LLVMUDiv           = 14,
	LLVMSDiv           = 15,
	LLVMFDiv           = 16,
	LLVMURem           = 17,
	LLVMSRem           = 18,
	LLVMFRem           = 19,
	LLVMShl            = 20,
	LLVMLShr           = 21,
	LLVMAShr           = 22,
	LLVMAnd            = 23,
	LLVMOr             = 24,
	LLVMXor            = 25,
	LLVMAlloca         = 26,
	LLVMLoad           = 27,
	LLVMStore          = 28,
	LLVMGetElementPtr  = 29,
	LLVMTrunc          = 30,
	LLVMZExt           = 31,
	LLVMSExt           = 32,
	LLVMFPToUI         = 33,
	LLVMFPToSI         = 34,
	LLVMUIToFP         = 35,
	LLVMSIToFP         = 36,
	LLVMFPTrunc        = 37,
	LLVMFPExt          = 38,
	LLVMPtrToInt       = 39,
	LLVMIntToPtr       = 40,
	LLVMBitCast        = 41,
	LLVMICmp           = 42,
	LLVMFCmp           = 43,
	LLVMPHI            = 44,
	LLVMCall           = 45,
	LLVMSelect         = 46,
	LLVMUserOp1        = 47,
	LLVMUserOp2        = 48,
	LLVMVAArg          = 49,
	LLVMExtractElement = 50,
	LLVMInsertElement  = 51,
	LLVMShuffleVector  = 52,
	LLVMExtractValue   = 53,
	LLVMInsertValue    = 54,
	LLVMFence          = 55,
	LLVMAtomicCmpXchg  = 56,
	LLVMAtomicRMW      = 57,
	LLVMResume         = 58,
	LLVMLandingPad     = 59
}

enum : LLVMTypeKind
{
	LLVMVoidTypeKind,
	LLVMHalfTypeKind,
	LLVMFloatTypeKind,
	LLVMDoubleTypeKind,
	LLVMX86_FP80TypeKind,
	LLVMFP128TypeKind,
	LLVMPPC_FP128TypeKind,
	LLVMLabelTypeKind,
	LLVMIntegerTypeKind,
	LLVMFunctionTypeKind,
	LLVMStructTypeKind,
	LLVMArrayTypeKind,
	LLVMPointerTypeKind,
	LLVMVectorTypeKind,
	LLVMMetadataTypeKind,
	LLVMX86_MMXTypeKind
}

mixin(MixinMap_VersionedEnum(
	      "", "LLVMLinkage", LLVM_Version,
	      ["LLVMExternalLinkage" : null,
	       "LLVMAvailableExternallyLinkage" : null,
	       "LLVMLinkOnceAnyLinkage" : null,
	       "LLVMLinkOnceODRLinkage" : null,
	       "LLVMLinkOnceODRAutoHideLinkage" : ["+", "3.2"],
	       "LLVMWeakAnyLinkage" : null,
	       "LLVMWeakODRLinkage" : null,
	       "LLVMAppendingLinkage" : null,
	       "LLVMInternalLinkage" : null,
	       "LLVMPrivateLinkage" : null,
	       "LLVMDLLImportLinkage" : null,
	       "LLVMDLLExportLinkage" : null,
	       "LLVMExternalWeakLinkage" : null,
	       "LLVMGhostLinkage" : null,
	       "LLVMCommonLinkage" : null,
	       "LLVMLinkerPrivateLinkage" : null,
	       "LLVMLinkerPrivateWeakLinkage" : null,
	       "LLVMLinkerPrivateWeakDefAutoLinkage" : ["-", "3.2"]]));

enum : LLVMVisibility
{
	LLVMDefaultVisibility,
	LLVMHiddenVisibility,
	LLVMProtectedVisibility
}

enum : LLVMCallConv
{
	LLVMCCallConv           = 0,
	LLVMFastCallConv        = 8,
	LLVMColdCallConv        = 9,
	LLVMX86StdcallCallConv  = 64,
	LLVMX86FastcallCallConv = 65
}

enum : LLVMIntPredicate
{
	LLVMIntEQ = 32,
	LLVMIntNE,
	LLVMIntUGT,
	LLVMIntUGE,
	LLVMIntULT,
	LLVMIntULE,
	LLVMIntSGT,
	LLVMIntSGE,
	LLVMIntSLT,
	LLVMIntSLE
}

enum : LLVMRealPredicate
{
	LLVMRealPredicateFalse,
	LLVMRealOEQ,
	LLVMRealOGT,
	LLVMRealOGE,
	LLVMRealOLT,
	LLVMRealOLE,
	LLVMRealONE,
	LLVMRealORD,
	LLVMRealUNO,
	LLVMRealUEQ,
	LLVMRealUGT,
	LLVMRealUGE,
	LLVMRealULT,
	LLVMRealULE,
	LLVMRealUNE,
	LLVMRealPredicateTrue
}

enum : LLVMLandingPadClauseTy
{
	LLVMLandingPadCatch,
	LLVMLandingPadFilter
}

/+ Disassembler +/

const
{
	uint LLVMDisassembler_VariantKind_None = 0;
	uint LLVMDisassembler_VariantKind_ARM_HI16 = 1;
	uint LLVMDisassembler_VariantKind_ARM_LO16 = 2;
	uint LLVMDisassembler_ReferenceType_InOut_None = 0;
	uint LLVMDisassembler_ReferenceType_In_Branch = 1;
	uint LLVMDisassembler_ReferenceType_In_PCrel_Load = 2;
	uint LLVMDisassembler_ReferenceType_Out_SymbolStub = 1;
	uint LLVMDisassembler_ReferenceType_Out_LitPool_SymAddr = 2;
	uint LLVMDisassembler_ReferenceType_Out_LitPool_CstrAddr = 3;
	static if(LLVM_Version >= 3.2)
	{
		uint LLVMDisassembler_Option_UseMarkup = 1;
	}
	static if(LLVM_Version >= 3.3)
	{
		uint LLVMDisassembler_Option_PrintImmHex = 2;
		uint LLVMDisassembler_Option_AsmPrinterVariant = 4;
	}
}

static if(LLVM_Version < 3.3)
{
	/+ Enhanced Disassembly +/

	enum : EDAssemblySyntax_t
	{
		kEDAssemblySyntaxX86Intel = 0,
		kEDAssemblySyntaxX86ATT = 1,
		kEDAssemblySyntaxARMUAL = 2
	}
}

static if(LLVM_Version >= 3.2)
{
	/+ Linker +/

	enum : LLVMLinkerMode
	{
		LLVMLinkerDestroySource = 0,
		LLVMLinkerPreserveSource = 1
	}
}

/+ Link Time Optimization +/

enum : llvm_lto_status
{
	LLVM_LTO_UNKNOWN,
	LLVM_LTO_OPT_SUCCESS,
	LLVM_LTO_READ_SUCCESS,
	LLVM_LTO_READ_FAILURE,
	LLVM_LTO_WRITE_FAILURE,
	LLVM_LTO_NO_TARGET,
	LLVM_LTO_NO_WORK,
	LLVM_LTO_MODULE_MERGE_FAILURE,
	LLVM_LTO_ASM_FAILURE,
	LLVM_LTO_NULL_OBJECT
}

/+ LTO +/

const
{
	uint LTO_API_VERSION = 4;
}

enum : lto_symbol_attributes
{
	LTO_SYMBOL_ALIGNMENT_MASK = 0x0000001F,
	LTO_SYMBOL_PERMISSIONS_MASK = 0x000000E0,
	LTO_SYMBOL_PERMISSIONS_CODE = 0x000000A0,
	LTO_SYMBOL_PERMISSIONS_DATA = 0x000000C0,
	LTO_SYMBOL_PERMISSIONS_RODATA = 0x00000080,
	LTO_SYMBOL_DEFINITION_MASK = 0x00000700,
	LTO_SYMBOL_DEFINITION_REGULAR = 0x00000100,
	LTO_SYMBOL_DEFINITION_TENTATIVE = 0x00000200,
	LTO_SYMBOL_DEFINITION_WEAK = 0x00000300,
	LTO_SYMBOL_DEFINITION_UNDEFINED = 0x00000400,
	LTO_SYMBOL_DEFINITION_WEAKUNDEF = 0x00000500,
	LTO_SYMBOL_SCOPE_MASK = 0x00003800,
	LTO_SYMBOL_SCOPE_INTERNAL = 0x00000800,
	LTO_SYMBOL_SCOPE_HIDDEN = 0x00001000,
	LTO_SYMBOL_SCOPE_PROTECTED = 0x00002000,
	LTO_SYMBOL_SCOPE_DEFAULT = 0x00001800,
	LTO_SYMBOL_SCOPE_DEFAULT_CAN_BE_HIDDEN = 0x00002800
}

enum : lto_debug_model
{
	LTO_DEBUG_MODEL_NONE = 0,
	LTO_DEBUG_MODEL_DWARF = 1
}

enum : lto_codegen_model
{
	LTO_CODEGEN_PIC_MODEL_STATIC = 0,
	LTO_CODEGEN_PIC_MODEL_DYNAMIC = 1,
	LTO_CODEGEN_PIC_MODEL_DYNAMIC_NO_PIC = 2
}

/+ Target information +/

enum : LLVMByteOrdering
{
	LLVMBigEndian,
	LLVMLittleEndian
}

/+ Target machine +/

enum : LLVMCodeGenOptLevel
{
	LLVMCodeGenLevelNone,
	LLVMCodeGenLevelLess,
	LLVMCodeGenLevelDefault,
	LLVMCodeGenLevelAggressive
}

enum : LLVMRelocMode
{
	LLVMRelocDefault,
	LLVMRelocStatic,
	LLVMRelocPIC,
	LLVMRelocDynamicNoPic
}

enum : LLVMCodeModel
{
	LLVMCodeModelDefault,
	LLVMCodeModelJITDefault,
	LLVMCodeModelSmall,
	LLVMCodeModelKernel,
	LLVMCodeModelMedium,
	LLVMCodeModelLarge
}

enum : LLVMCodeGenFileType
{
	LLVMAssemblyFile,
	LLVMObjectFile
}