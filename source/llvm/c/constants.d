
module llvm.c.constants;

private
{
	import llvm.util.templates;

	import llvm.c.types;
	import llvm.c.config;
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

mixin(MixinMap_VersionedEnum(
			  "", "LLVMOpcode", LLVM_Version,
			  ["LLVMRet            = 1" : null,
			   "LLVMBr             = 2" : null,
			   "LLVMSwitch         = 3" : null,
			   "LLVMIndirectBr     = 4" : null,
			   "LLVMInvoke         = 5" : null,
			   "LLVMUnreachable    = 7" : null,
			   "LLVMAdd            = 8" : null,
			   "LLVMFAdd           = 9" : null,
			   "LLVMSub            = 10" : null,
			   "LLVMFSub           = 11" : null,
			   "LLVMMul            = 12" : null,
			   "LLVMFMul           = 13" : null,
			   "LLVMUDiv           = 14" : null,
			   "LLVMSDiv           = 15" : null,
			   "LLVMFDiv           = 16" : null,
			   "LLVMURem           = 17" : null,
			   "LLVMSRem           = 18" : null,
			   "LLVMFRem           = 19" : null,
			   "LLVMShl            = 20" : null,
			   "LLVMLShr           = 21" : null,
			   "LLVMAShr           = 22" : null,
			   "LLVMAnd            = 23" : null,
			   "LLVMOr             = 24" : null,
			   "LLVMXor            = 25" : null,
			   "LLVMAlloca         = 26" : null,
			   "LLVMLoad           = 27" : null,
			   "LLVMStore          = 28" : null,
			   "LLVMGetElementPtr  = 29" : null,
			   "LLVMTrunc          = 30" : null,
			   "LLVMZExt           = 31" : null,
			   "LLVMSExt           = 32" : null,
			   "LLVMFPToUI         = 33" : null,
			   "LLVMFPToSI         = 34" : null,
			   "LLVMUIToFP         = 35" : null,
			   "LLVMSIToFP         = 36" : null,
			   "LLVMFPTrunc        = 37" : null,
			   "LLVMFPExt          = 38" : null,
			   "LLVMPtrToInt       = 39" : null,
			   "LLVMIntToPtr       = 40" : null,
			   "LLVMBitCast        = 41" : null,
			   "LLVMAddrSpaceCast  = 60" : ["+", "3", "4", "0"],
			   "LLVMICmp           = 42" : null,
			   "LLVMFCmp           = 43" : null,
			   "LLVMPHI            = 44" : null,
			   "LLVMCall           = 45" : null,
			   "LLVMSelect         = 46" : null,
			   "LLVMUserOp1        = 47" : null,
			   "LLVMUserOp2        = 48" : null,
			   "LLVMVAArg          = 49" : null,
			   "LLVMExtractElement = 50" : null,
			   "LLVMInsertElement  = 51" : null,
			   "LLVMShuffleVector  = 52" : null,
			   "LLVMExtractValue   = 53" : null,
			   "LLVMInsertValue    = 54" : null,
			   "LLVMFence          = 55" : null,
			   "LLVMAtomicCmpXchg  = 56" : null,
			   "LLVMAtomicRMW      = 57" : null,
			   "LLVMResume         = 58" : null,
			   "LLVMLandingPad     = 59" : null,
			   "LLVMCleanupRet     = 61" : ["+", "3", "8", "0"],
			   "LLVMCatchRet       = 62" : ["+", "3", "8", "0"],
			   "LLVMCatchPad       = 63" : ["+", "3", "8", "0"],
			   "LLVMCleanupPad     = 64" : ["+", "3", "8", "0"],
			   "LLVMCatchSwitch    = 65" : ["+", "3", "8", "0"]]));


static if(LLVM_Version >= LLVMDVersion(3, 9, 0))
{
	enum : LLVMValueKind
	{
		LLVMArgumentValueKind,
		LLVMBasicBlockValueKind,
		LLVMMemoryUseValueKind,
		LLVMMemoryDefValueKind,
		LLVMMemoryPhiValueKind,
		LLVMFunctionValueKind,
		LLVMGlobalAliasValueKind,
		LLVMGlobalIFuncValueKind,
		LLVMGlobalVariableValueKind,
		LLVMBlockAddressValueKind,
		LLVMConstantExprValueKind,
		LLVMConstantArrayValueKind,
		LLVMConstantStructValueKind,
		LLVMConstantVectorValueKind,
		LLVMUndefValueValueKind,
		LLVMConstantAggregateZeroValueKind,
		LLVMConstantDataArrayValueKind,
		LLVMConstantDataVectorValueKind,
		LLVMConstantIntValueKind,
		LLVMConstantFPValueKind,
		LLVMConstantPointerNullValueKind,
		LLVMConstantTokenNoneValueKind,
		LLVMMetadataAsValueValueKind,
		LLVMInlineAsmValueKind,
		LLVMInstructionValueKind,
	}

	enum : LLVMAttributeIndex
	{
		LLVMAttributeReturnIndex = 0U,
		LLVMAttributeFunctionIndex = -1,
	}
}

mixin(MixinMap_VersionedEnum(
	      "", "LLVMTypeKind", LLVM_Version,
	      ["LLVMVoidTypeKind" : null,
           "LLVMHalfTypeKind" : null,
           "LLVMFloatTypeKind" : null,
           "LLVMDoubleTypeKind" : null,
           "LLVMX86_FP80TypeKind" : null,
           "LLVMFP128TypeKind" : null,
           "LLVMPPC_FP128TypeKind" : null,
           "LLVMLabelTypeKind" : null,
           "LLVMIntegerTypeKind" : null,
           "LLVMFunctionTypeKind" : null,
           "LLVMStructTypeKind" : null,
           "LLVMArrayTypeKind" : null,
           "LLVMPointerTypeKind" : null,
           "LLVMVectorTypeKind" : null,
           "LLVMMetadataTypeKind" : null,
           "LLVMX86_MMXTypeKind" : null,
           "LLVMTokenTypeKind": ["+", "3", "8", "0"]]));


mixin(MixinMap_VersionedEnum(
	      "", "LLVMLinkage", LLVM_Version,
	      ["LLVMExternalLinkage" : null,
	       "LLVMAvailableExternallyLinkage" : null,
	       "LLVMLinkOnceAnyLinkage" : null,
	       "LLVMLinkOnceODRLinkage" : null,
	       "LLVMLinkOnceODRAutoHideLinkage" : ["+", "3", "2", "0"],
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
	       "LLVMLinkerPrivateWeakDefAutoLinkage" : ["-", "3", "2", "0"]]));

enum : LLVMVisibility
{
	LLVMDefaultVisibility,
	LLVMHiddenVisibility,
	LLVMProtectedVisibility
}

static if(LLVM_Version >= LLVMDVersion(3, 5, 0))
{
	enum : LLVMDLLStorageClass {
		LLVMDefaultStorageClass = 0,
		LLVMDLLImportStorageClass = 1,
		LLVMDLLExportStorageClass = 2
	}
}

mixin(MixinMap_VersionedEnum(
			  "", "LLVMCallConv", LLVM_Version,
			  ["LLVMCCallConv           = 0" : null,
			   "LLVMFastCallConv        = 8" : null,
			   "LLVMColdCallConv        = 9" : null,
			   "LLVMWebKitJSCallConv    = 12" : ["+", "3", "4", "0"],
			   "LLVMAnyRegCallConv      = 13" : ["+", "3", "4", "0"],
			   "LLVMX86StdcallCallConv  = 64" : null,
			   "LLVMX86FastcallCallConv = 65" : null]));

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

static if(LLVM_Version >= LLVMDVersion(3, 3, 0))
{
	enum : LLVMThreadLocalMode
	{
		LLVMNotThreadLocal = 0,
		LLVMGeneralDynamicTLSModel,
		LLVMLocalDynamicTLSModel,
		LLVMInitialExecTLSModel,
		LLVMLocalExecTLSModel
	}

	enum : LLVMAtomicOrdering
	{
		LLVMAtomicOrderingNotAtomic = 0,
		LLVMAtomicOrderingUnordered = 1,
		LLVMAtomicOrderingMonotonic = 2,
		LLVMAtomicOrderingAcquire = 4,
		LLVMAtomicOrderingRelease = 5,
		LLVMAtomicOrderingAcquireRelease = 6,
		LLVMAtomicOrderingSequentiallyConsistent = 7
	}

	enum : LLVMAtomicRMWBinOp
	{
		LLVMAtomicRMWBinOpXchg,
		LLVMAtomicRMWBinOpAdd,
		LLVMAtomicRMWBinOpSub,
		LLVMAtomicRMWBinOpAnd,
		LLVMAtomicRMWBinOpNand,
		LLVMAtomicRMWBinOpOr,
		LLVMAtomicRMWBinOpXor,
		LLVMAtomicRMWBinOpMax,
		LLVMAtomicRMWBinOpMin,
		LLVMAtomicRMWBinOpUMax,
		LLVMAtomicRMWBinOpUMin
	}
}
static if(LLVM_Version > LLVMDVersion(3, 5, 0))
{
	enum : LLVMDiagnosticSeverity {
		LLVMDSError,
		LLVMDSWarning,
		LLVMDSRemark,
		LLVMDSNote
	}
}

/+ Disassembler +/

//TODO: replace const with enum?
const
{
	uint LLVMDisassembler_VariantKind_None = 0;
	uint LLVMDisassembler_VariantKind_ARM_HI16 = 1;
	uint LLVMDisassembler_VariantKind_ARM_LO16 = 2;
	static if(LLVM_Version >= 3.5)
	{
		uint LLVMDisassembler_VariantKind_ARM64_PAGE = 1;
		uint LLVMDisassembler_VariantKind_ARM64_PAGEOFF = 2;
		uint LLVMDisassembler_VariantKind_ARM64_GOTPAGE = 3;
		uint LLVMDisassembler_VariantKind_ARM64_GOTPAGEOFF = 4;
		uint LLVMDisassembler_VariantKind_ARM64_TLVP = 5;
		uint LLVMDisassembler_VariantKind_ARM64_TLVOFF = 6;
	}
	uint LLVMDisassembler_ReferenceType_InOut_None = 0;
	uint LLVMDisassembler_ReferenceType_In_Branch = 1;
	uint LLVMDisassembler_ReferenceType_In_PCrel_Load = 2;
	static if(LLVM_Version >= 3.5)
	{
		ulong LLVMDisassembler_ReferenceType_In_ARM64_ADRP = 0x100000001;
		ulong LLVMDisassembler_ReferenceType_In_ARM64_ADDXri = 0x100000002;
		ulong LLVMDisassembler_ReferenceType_In_ARM64_LDRXui = 0x100000003;
		ulong LLVMDisassembler_ReferenceType_In_ARM64_LDRXl = 0x100000004;
		ulong LLVMDisassembler_ReferenceType_In_ARM64_ADR = 0x100000005;
	}
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
	static if(LLVM_Version >= 3.4)
	{
		uint LLVMDisassembler_ReferenceType_Out_Objc_CFString_Ref = 4;
		uint LLVMDisassembler_ReferenceType_Out_Objc_Message = 5;
		uint LLVMDisassembler_ReferenceType_Out_Objc_Message_Ref = 6;
		uint LLVMDisassembler_ReferenceType_Out_Objc_Selector_Ref = 7;
		uint LLVMDisassembler_ReferenceType_Out_Objc_Class_Ref = 8;
		uint LLVMDisassembler_Option_SetInstrComments = 8;
		uint LLVMDisassembler_Option_PrintLatency = 16;
	}
	static if(LLVM_Version >= 3.5)
	{
		uint LLVMDisassembler_ReferenceType_DeMangled_Name = 9;
	}
}

static if(LLVM_Version < LLVMDVersion(3, 3, 0))
{
	/+ Enhanced Disassembly +/

	enum : EDAssemblySyntax_t
	{
		kEDAssemblySyntaxX86Intel = 0,
		kEDAssemblySyntaxX86ATT = 1,
		kEDAssemblySyntaxARMUAL = 2
	}
}

static if(LLVM_Version >= LLVMDVersion(3, 2, 0))
{
	/+ Linker +/

	mixin(MixinMap_VersionedEnum(
			  "", "LLVMLinkerMode", LLVM_Version,
			  ["LLVMLinkerDestroySource  = 0" : null,
			   "LLVMLinkerPreserveSource = 1" : ["-", "3", "7", "0"]]));
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

static if(LLVM_Version >= LLVMDVersion(3, 7, 0))
{
	const uint LTO_API_VERSION = 17;
}
else static if(LLVM_Version >= LLVMDVersion(3, 6, 0))
{
	const uint LTO_API_VERSION = 11;
}
else static if(LLVM_Version >= LLVMDVersion(3, 5, 0))
{
	const uint LTO_API_VERSION = 10;
}
else static if(LLVM_Version >= LLVMDVersion(3, 4, 0))
{
	const uint LTO_API_VERSION = 5;
}
else
{
	const uint LTO_API_VERSION = 4;
}
mixin(MixinMap_VersionedEnum(
			  "", "lto_symbol_attributes", LLVM_Version,
			  ["LTO_SYMBOL_ALIGNMENT_MASK =				 0x0000001F" : null,
			   "LTO_SYMBOL_PERMISSIONS_MASK =			 0x000000E0" : null,
			   "LTO_SYMBOL_PERMISSIONS_CODE =			 0x000000A0" : null,
			   "LTO_SYMBOL_PERMISSIONS_DATA =			 0x000000C0" : null,
			   "LTO_SYMBOL_PERMISSIONS_RODATA =			 0x00000080" : null,
			   "LTO_SYMBOL_DEFINITION_MASK =			 0x00000700" : null,
			   "LTO_SYMBOL_DEFINITION_REGULAR =			 0x00000100" : null,
			   "LTO_SYMBOL_DEFINITION_TENTATIVE =		 0x00000200" : null,
			   "LTO_SYMBOL_DEFINITION_WEAK =			 0x00000300" : null,
			   "LTO_SYMBOL_DEFINITION_UNDEFINED =		 0x00000400" : null,
			   "LTO_SYMBOL_DEFINITION_WEAKUNDEF =		 0x00000500" : null,
			   "LTO_SYMBOL_SCOPE_MASK =					 0x00003800" : null,
			   "LTO_SYMBOL_SCOPE_INTERNAL =			 	 0x00000800" : null,
			   "LTO_SYMBOL_SCOPE_HIDDEN =				 0x00001000" : null,
			   "LTO_SYMBOL_SCOPE_PROTECTED =			 0x00002000" : null,
			   "LTO_SYMBOL_SCOPE_DEFAULT =				 0x00001800" : null,
			   "LTO_SYMBOL_SCOPE_DEFAULT_CAN_BE_HIDDEN = 0x00002800" : null,
			   "LTO_SYMBOL_COMDAT =						 0x00004000" : ["+", "3", "7", "0"],
			   "LTO_SYMBOL_ALIAS =						 0x00008000" : ["+", "3", "7", "0"]]));

enum : lto_debug_model
{
	LTO_DEBUG_MODEL_NONE = 0,
	LTO_DEBUG_MODEL_DWARF = 1
}

enum : lto_codegen_model
{
	LTO_CODEGEN_PIC_MODEL_STATIC = 0,
	LTO_CODEGEN_PIC_MODEL_DYNAMIC = 1,
	LTO_CODEGEN_PIC_MODEL_DYNAMIC_NO_PIC = 2,
	LTO_CODEGEN_PIC_MODEL_DEFAULT = 3
}

static if(LLVM_Version >= LLVMDVersion(3, 5, 0))
{
	enum : lto_codegen_diagnostic_severity_t
	{
		LTO_DS_ERROR = 0,
		LTO_DS_WARNING = 1,
	   	LTO_DS_REMARK = 3,
		LTO_DS_NOTE = 2
	}
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


/+ Orc +/

static if(LLVM_Version >= LLVMDVersion(3, 9, 0))
{
	enum : LLVMOrcErrorCode
	{
		LLVMOrcErrSuccess = 0,
		LLVMOrcErrGeneric,
	}
}