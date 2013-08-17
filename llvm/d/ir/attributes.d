module llvm.d.ir.attributes;

private
{
	import llvm.d.llvm_c;
}

enum Attribute : LLVMAttribute
{
	// None
	Alignment = LLVMAlignment,
	AlwaysInline = LLVMAlwaysInlineAttribute,
	// Builtin
	ByVal = LLVMByValAttribute,
	// Cold
	InlineHint = LLVMInlineHintAttribute,
	InReg = LLVMInRegAttribute,
	// MinSize
	Naked = LLVMNakedAttribute,
	Nest = LLVMNestAttribute,
	NoAlias = LLVMNoAliasAttribute,
	// NoBuiltin
	NoCapture = LLVMNoCaptureAttribute,
	// NoDuplicate
	NoImplicitFloat = LLVMNoImplicitFloatAttribute,
	NoInline = LLVMNoInlineAttribute,
	NonLazyBind = LLVMNonLazyBind,
	NoRedZone = LLVMNoRedZoneAttribute,
	NoReturn = LLVMNoReturnAttribute,
	NoUnwind = LLVMNoUnwindAttribute,
	OptimizeForSize = LLVMOptimizeForSizeAttribute,
	ReadNone = LLVMReadNoneAttribute,
	ReadOnly = LLVMReadOnlyAttribute,
	// Returned
	ReturnsTwice = LLVMReturnsTwice,
	SExt = LLVMSExtAttribute,
	StackAlignment = LLVMStackAlignment,
	StackProtect = LLVMStackProtectAttribute,
	StackProtectReq = LLVMStackProtectReqAttribute,
	// StackProtectStrong
	StructRet = LLVMStructRetAttribute,
	// SanitizeAddress
	// SanitizeThread
	// SanitizeMemory
	UWTable = LLVMUWTable,
	ZExt = LLVMZExtAttribute,
	// EndAttrKinds
}