module llvm.d.ir.globalvalue;

private
{
	import core.stdc.string : strlen;

	import llvm.util.templates;
	import llvm.util.memory;

	import llvm.d.llvm_c;

	import llvm.d.ir.llvmcontext;
	import llvm.d.ir.type;
	import llvm.d.ir.derivedtypes;
	import llvm.d.ir.value;
	import llvm.d.ir.user;
	import llvm.d.ir.constant;
}

class GlobalValue : Constant
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	mixin("public " ~ MixinMap_VersionedEnum(
		      "LinkageTypes", "", LLVM_Version,
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

	// bool hasUnnamedAddr ()
	// void setUnnamedAddr (bool Val)

	public VisibilityTypes getVisibility()
	{ return cast(VisibilityTypes) LLVMGetVisibility(this._cref); }

	public bool hasDefaultVisibility()
	{ return this.getVisibility() == VisibilityTypes.Default; }

	public bool hasHiddenVisibility()
	{ return this.getVisibility() == VisibilityTypes.Hidden; }

	public bool hasProtectedVisibility()
	{ return this.getVisibility() == VisibilityTypes.Protected; }

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

	public bool hasExternalLinkage()
	{ return this.isExternalLinkage(this.getLinkage()); }

	public bool hasAvailableExternallyLinkage()
	{ return this.isAvailableExternallyLinkage(this.getLinkage()); }
	
	public bool hasLinkOnceLinkage ()
	{ return this.isLinkOnceLinkage(this.getLinkage()); }

	static if(LLVM_Version >= 3.2)
	public bool hasLinkOnceODRAutoHideLinkage ()
	{ return this.isLinkOnceODRAutoHideLinkage(this.getLinkage()); }
	
	public bool hasWeakLinkage ()
	{ return this.isWeakLinkage(this.getLinkage()); }
	
	public bool hasAppendingLinkage ()
	{ return this.isAppendingLinkage(this.getLinkage()); }
	
	public bool hasInternalLinkage ()
	{ return this.isInternalLinkage(this.getLinkage()); }
	
	public bool hasPrivateLinkage ()
	{ return this.isPrivateLinkage(this.getLinkage()); }
	
	public bool hasLinkerPrivateLinkage ()
	{ return this.isLinkerPrivateLinkage(this.getLinkage()); }
	
	public bool hasLinkerPrivateWeakLinkage ()
	{ return this.isLinkerPrivateWeakLinkage(this.getLinkage()); }
	
	static if(LLVM_Version < 3.2)
	public bool hasLinkerPrivateWeakDefAutoLinkage(LinkageTypes Linkage)
	{ return this.isLinkerPrivateWeakDefAutoLinkage(this.getLinkage()); }

	public bool hasLocalLinkage ()
	{ return this.isLocalLinkage(this.getLinkage()); }
	
	public bool hasDLLImportLinkage ()
	{ return this.isDLLImportLinkage(this.getLinkage()); }
	
	public bool hasDLLExportLinkage ()
	{ return this.isDLLExportLinkage(this.getLinkage()); }
	
	public bool hasExternalWeakLinkage ()
	{ return this.isExternalWeakLinkage(this.getLinkage()); }
	
	public bool hasCommonLinkage ()
	{ return this.isCommonLinkage(this.getLinkage()); }

	public void setLinkage(LinkageTypes LT)
	{ LLVMSetLinkage(this._cref, LT); }

	public LinkageTypes getLinkage()
	{ return cast(LinkageTypes) LLVMGetLinkage(this._cref); }

	public bool isDiscardableIfUnused()
	{ return GlobalValue.isDiscardableIfUnused(this.getLinkage()); }

	public bool mayBeOverridden()
	{ return GlobalValue.mayBeOverridden(this.getLinkage()); }

	public bool isWeakForLinker()
	{ return GlobalValue.isWeakForLinker(this.getLinkage()); }

	// virtual void 	copyAttributesFrom (const GlobalValue *Src)
	// virtual void 	destroyConstant ()

	// TODO: Uncomment once GlobalVariable, GlobalAlias and Function are implemented
	/+public bool isDeclaration()
	{
		// Globals are definitions if they have an initializer.
		if(is(this : GlobalVariable))
		{
			return (cast(GlobalVariable) this).getNumOperands() == 0;
		}
		
		// Functions are definitions if they have a body.
		if(is(this : Function))
		{
			return (cast(Function) this).empty();
		}
		
		// Aliases are always definitions.
		if(is(this : GlobalAlias))
		{
			return false;
		}
		
		/+ Should not be possible, as GlobalValue only has the
		 + above mentioned three subclasses and it itself doesn't
		 + get instantiated. +/
		 throw new Exception("Unknown subclass of GlobalValue");
	}+/

	// virtual void 	removeFromParent ()=0
	public void eraseFromParent() {}

	// TODO: Uncomment once Module is implemented
	/+public Module getParent()
	{ return new Module(this.getContext(), LLVMGetGlobalParent(this._cref)); }+/

	// bool isMaterializable ()
	// bool isDematerializable ()
	// bool Materialize (std::string *ErrInfo=0)
	// void Dematerialize ()

	public static LinkageTypes getLinkOnceLinkage(bool ODR)
	{ return ODR ? LinkageTypes.LinkOnceODR : LinkageTypes.LinkOnceAny; }

	public static LinkageTypes getWeakLinkage(bool ODR)
	{ return ODR ? LinkageTypes.WeakODR : LinkageTypes.WeakAny; }

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
		static if(LLVM_Version >= 3.2)
		return (Linkage == LinkageTypes.Internal) ||
		       (Linkage == LinkageTypes.Private) ||
		       (Linkage == LinkageTypes.LinkerPrivate) ||
		       (Linkage == LinkageTypes.LinkerPrivateWeak);
		else
		return (Linkage == LinkageTypes.Internal) ||
		       (Linkage == LinkageTypes.Private) ||
		       (Linkage == LinkageTypes.LinkerPrivate) ||
		       (Linkage == LinkageTypes.LinkerPrivateWeak) ||
		       (Linkage == LinkageTypes.LinkerPrivateWeakDefAuto);
	}
	
	public static bool isDLLImportLinkage(LinkageTypes Linkage)
	{ return Linkage == LinkageTypes.DLLImport; }
	
	public static bool isDLLExportLinkage(LinkageTypes Linkage)
	{ return Linkage == LinkageTypes.DLLExport; }
	
	public static bool isExternalWeakLinkage(LinkageTypes Linkage)
	{ return Linkage == LinkageTypes.External; }
	
	public static bool isCommonLinkage(LinkageTypes Linkage)
	{ return Linkage == LinkageTypes.Common; }
	
	public static bool isDiscardableIfUnused(LinkageTypes Linkage)
	{ return isLinkOnceLinkage(Linkage) || isLocalLinkage(Linkage); }

	public static bool mayBeOverridden(LinkageTypes Linkage)
	{
		static if(LLVM_Version >= 3.2)
		return (Linkage == LinkageTypes.WeakAny) ||
		       (Linkage == LinkageTypes.LinkOnceAny) ||
		       (Linkage == LinkageTypes.Common) ||
		       (Linkage == LinkageTypes.ExternalWeak) ||
		       (Linkage == LinkageTypes.LinkerPrivateWeak);
		else
		return (Linkage == LinkageTypes.WeakAnyLinkage) ||
		       (Linkage == LinkageTypes.LinkOnceAny) ||
		       (Linkage == LinkageTypes.Common) ||
		       (Linkage == LinkageTypes.ExternalWeak) ||
		       (Linkage == LinkageTypes.LinkerPrivateWeak) ||
		       (Linkage == LinkageTypes.LinkerPrivateWeakDefAuto);
	}

	public static bool isWeakForLinker(LinkageTypes Linkage)
	{
		static if(LLVM_Version >= 3.2)
		return (Linkage == LinkageTypes.AvailableExternally) ||
		       (Linkage == LinkageTypes.WeakAny) ||
		       (Linkage == LinkageTypes.WeakODR) ||
		       (Linkage == LinkageTypes.LinkOnceAny) ||
		       (Linkage == LinkageTypes.LinkOnceODR) ||
		       (Linkage == LinkageTypes.LinkOnceODRAutoHide) ||
		       (Linkage == LinkageTypes.Common) ||
		       (Linkage == LinkageTypes.ExternalWeak) ||
		       (Linkage == LinkageTypes.LinkerPrivateWeak);
		else
		return (Linkage == LinkageTypes.AvailableExternally) ||
		       (Linkage == LinkageTypes.WeakAny) ||
		       (Linkage == LinkageTypes.WeakODR) ||
		       (Linkage == LinkageTypes.LinkOnceAny) ||
		       (Linkage == LinkageTypes.LinkOnceODR) ||
		       (Linkage == LinkageTypes.LinkOnceODRAutoHide) ||
		       (Linkage == LinkageTypes.Common) ||
		       (Linkage == LinkageTypes.ExternalWeak) ||
		       (Linkage == LinkageTypes.LinkerPrivateWeak) ||
		       (Linkage == LinkageTypes.LinkerPrivateWeakDefAuto);
	}
}