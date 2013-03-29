module llvm.d.ir.globalvalue;

private
{
	import core.stdc.string : strlen;

	import llvm.util.templates : MixinMap_VersionedEnum;
	import llvm.util.memory : fromCString, toCString;

	import llvm.d.llvm_c;

	import llvm.d.ir.llvmcontext : LLVMContext;
	import llvm.d.ir.type : Type;
	import llvm.d.ir.derivedtypes : PointerType;
	import llvm.d.ir.value : Value, LLVMValueRef_to_Value;
	import llvm.d.ir.user : User;
	import llvm.d.ir.constant : Constant;
}

class GlobalValue : Constant
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	mixin("public " ~ MixinMap_VersionedEnum!(
		      "LinkageTypes", null, LLVM_VersionString,
		      ["External = LLVMExternalLinkage" : null,
			   "AvailableExternally = LLVMAvailableExternallyLinkage" : null,
			   "LinkOnceAny = LLVMLinkOnceAnyLinkage" : null,
			   "LinkOnceODR = LLVMLinkOnceODRLinkage" : null,
			   "LinkOnceODRAutoHide = LLVMLinkOnceODRAutoHideLinkage" : ["+", "3.2"],
			   "WeakAny = LLVMWeakAnyLinkage" : null,
			   "WeakODR = LLVMWeakODRLinkage" : null,
			   "Appending = LLVMAppendingLinkage" : null,
			   "Internal = LLVMInternalLinkage" : null,
			   "Private = LLVMPrivateLinkage" : null,
		       "LinkerPrivate = LLVMLinkerPrivateLinkage" : null,
			   "LinkerPrivateWeak = LLVMLinkerPrivateWeakLinkage" : null,
		       "LinkerPrivateWeakDefAuto = LLVMLinkerPrivateWeakDefAutoLinkage" : ["-", "3.2"],
			   "DLLImport = LLVMDLLImportLinkage" : null,
			   "DLLExport = LLVMDLLExportLinkage" : null,
			   "ExternalWeak = LLVMExternalWeakLinkage" : null,
			   "Common = LLVMCommonLinkage" : null]));
	
	public enum VisibilityTypes
	{
		Default = LLVMDefaultVisibility,
		Hidden = LLVMHiddenVisibility,
		Protected = LLVMProtectedVisibility
	}
	
	public uint getAlignment()
	{ return LLVMGetAlignment(this._cref); }
	
	public void setAlignment(uint Align)
	in
	{
		assert((Align & (Align - 1)) == 0, "Alignment is not a power of 2!");
		assert(Align <= MaximumAlignment, "Alignment is greater than MaximumAlignment!");
	}
	out
	{
		assert(this.getAlignment() == Align, "Alignment representation error!");
	}
	body
	{
		LLVMSetAlignment(this._cref, Align);
	}

	// bool hasUnnamedAddr () const
	// void setUnnamedAddr (bool Val)

	public VisibilityTypes getVisibility()
	{ return cast(VisibilityTypes) LLVMGetVisibility(this._cref); }

	public bool hasDefaultVisibility()
	{ return this.getVisibility == VisibilityTypes.Default; }

	public bool hasHiddenVisibility()
	{ return this.getVisibility == VisibilityTypes.Hidden; }

	public bool hasProtectedVisibility()
	{ return this.getVisibility == VisibilityTypes.Protected; }

	public void setVisibility(VisibilityTypes V)
	{ LLVMSetVisibility(this._cref, V); }
	
	public bool hasSection()
	{ return strlen(LLVMGetSection(this._cref)) > 0; }

	public string getSection()
	{ return LLVMGetSection(this._cref).fromCString(); }

	public void setSection (string S)
	{
		auto c_S = S.toCString();
		this.getContext().treatAsImmutable(c_S);
		LLVMSetSection(this._cref, c_S);
	}

	// bool use_empty_except_constants ()

	public override PointerType getType()
	{ return cast(PointerType) this.type; }

	// bool hasExternalLinkage () const
	// bool hasAvailableExternallyLinkage () const
	// bool hasLinkOnceLinkage () const
	// bool hasLinkOnceODRAutoHideLinkage () const
	// bool hasWeakLinkage () const
	// bool hasAppendingLinkage () const
	// bool hasInternalLinkage () const
	// bool hasPrivateLinkage () const
	// bool hasLinkerPrivateLinkage () const
	// bool hasLinkerPrivateWeakLinkage () const
	// bool hasLocalLinkage () const
	// bool hasDLLImportLinkage () const
	// bool hasDLLExportLinkage () const
	// bool hasExternalWeakLinkage () const
	// bool hasCommonLinkage () const
	// void setLinkage (LinkageTypes LT)
	// LinkageTypes 	getLinkage () const
	// bool isDiscardableIfUnused () const
	// bool mayBeOverridden () const
	// bool isWeakForLinker () const
	// virtual void 	copyAttributesFrom (const GlobalValue *Src)
	// virtual void 	destroyConstant ()
	// bool isDeclaration () const
	// virtual void 	removeFromParent ()=0
	// virtual void 	eraseFromParent ()=0
	// Module * 	getParent ()
	// const Module * 	getParent () const
	// bool isMaterializable () const
	// bool isDematerializable () const
	// bool Materialize (std::string *ErrInfo=0)
	// void Dematerialize ()
	// static LinkageTypes 	getLinkOnceLinkage (bool ODR)
	// static LinkageTypes 	getWeakLinkage (bool ODR)

	public static bool isExternalLinkage(LinkageTypes Linkage)
	{ return Linkage == LinkageTypes.External; }

	public static bool isAvailableExternallyLinkage(LinkageTypes Linkage)
	{ return Linkage == LinkageTypes.AvailableExternally; }
	
	public static bool isLinkOnceLinkage(LinkageTypes Linkage)
	{
		static if(LLVM_Version >= 3.2)
		return (Linkage == LinkageTypes.LinkOnceAny) ||
		       (Linkage == LinkageTypes.LinkOnceODR) ||
		       (Linkage == LinkageTypes.LinkOnceODRAutoHide);
		else
		return (Linkage == LinkageTypes.LinkOnceAny) ||
		       (Linkage == LinkageTypes.LinkOnceODR);
	}
	
	static if(LLVM_Version >= 3.2)
	public static bool isLinkOnceODRAutoHideLinkage(LinkageTypes Linkage)
	{ return Linkage == LinkageTypes.LinkOnceODRAutoHide; }
	
	public static bool isWeakLinkage(LinkageTypes Linkage)
	{
		return (Linkage == LinkageTypes.WeakAny) || (Linkage == LinkageTypes.WeakODR);
	}
	
	public static bool isAppendingLinkage(LinkageTypes Linkage)
	{ return Linkage == LinkageTypes.Appending; }
	
	public static bool isInternalLinkage(LinkageTypes Linkage)
	{ return Linkage == LinkageTypes.Internal; }
	
	public static bool isPrivateLinkage(LinkageTypes Linkage)
	{ return Linkage == LinkageTypes.Private; }
	
	public static bool isLinkerPrivateLinkage(LinkageTypes Linkage)
	{ return Linkage == LinkageTypes.LinkerPrivate; }
	
	public static bool isLinkerPrivateWeakLinkage(LinkageTypes Linkage)
	{ return Linkage == LinkageTypes.LinkerPrivateWeak; }
	
	static if(LLVM_Version < 3.2)
	public static bool isLinkerPrivateWeakDefAutoLinkage(LinkageTypes Linkage)
	{ return Linkage == LinkageTypes.LinkerPrivateWeakDefAuto; }
	
	public static bool isLocalLinkage(LinkageTypes Linkage)
	{
		return (Linkage == LinkageTypes.Internal) ||
		       (Linkage == LinkageTypes.Private) ||
		       (Linkage == LinkageTypes.LinkerPrivate) ||
		       (Linkage == LinkageTypes.LinkerPrivateWeak);
	}
	
	public static bool isDLLImportLinkage(LinkageTypes Linkage)
	{ return Linkage == LinkageTypes.DLLImport; }
	
	public static bool isDLLExportLinkage(LinkageTypes Linkage)
	{ return Linkage == LinkageTypes.DLLExport; }
	
	public static bool isExternalWeakLinkage(LinkageTypes Linkage)
	{ return Linkage == LinkageTypes.External; }
	
	public static bool isCommonLinkage(LinkageTypes Linkage)
	{ return Linkage == LinkageTypes.Common; }
	
	// static bool isDiscardableIfUnused(LinkageTypes Linkage)
	// static bool mayBeOverridden(LinkageTypes Linkage)
	// static bool isWeakForLinker(LinkageTypes Linkage)
}