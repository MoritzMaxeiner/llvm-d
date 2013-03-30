module llvm.d.ir.globalvariable;

private
{
	import core.stdc.string : strlen;
	
	import std.algorithm : find;
	
	import llvm.util.templates : MixinMap_VersionedEnum;
	import llvm.util.memory : fromCString, toCString;
	
	import llvm.d.llvm_c;
	
	import llvm.d.ir.llvmcontext : LLVMContext;
	import llvm.d.ir.type : Type;
	import llvm.d.ir.derivedtypes : PointerType, AddressSpace;
	import llvm.d.ir.value : Value, LLVMValueRef_to_Value;
	import llvm.d.ir.user : User;
	import llvm.d.ir.use : Use;
	import llvm.d.ir.constant : Constant;
	import llvm.d.ir.globalvalue : GlobalValue;
}

class GlobalVariable : GlobalValue
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	// GlobalVariable(Type *Ty, bool isConstant, LinkageTypes Linkage, Constant *Initializer=0,
	// const Twine &Name="", ThreadLocalMode=NotThreadLocal, unsigned AddressSpace=0, bool isExternallyInitialized=false)
	
	public this(Type Ty, bool isConstant, LinkageTypes Linkage, Constant Initializer = null, string Name = "", bool isThreadLocal = false, AddressSpace AddrSpace = AddressSpace.Generic)
	{
		auto c_Name = Name.toCString();
		Ty.getContext().treatAsImmutable(c_Name);
		auto __cref = LLVMAddGlobalInAddressSpace(
			null,
			Ty.cref,
			c_Name,
			AddrSpace);
		this.setConstant(isConstant);
		this.setLinkage(Linkage);
		this.setInitializer(Initializer);
		this.setThreadLocal(isThreadLocal);
		super(Ty, __cref);
	}
	
	// GlobalVariable(Module &M, Type *Ty, bool isConstant, LinkageTypes Linkage, Constant
	// *Initializer, const Twine &Name="", GlobalVariable *InsertBefore=0, ThreadLocalMode=NotThreadLocal,
	//  unsigned AddressSpace=0, bool isExternallyInitialized=false)
	
	// TODO: Uncomment once Module is implemented
	/+public this(Module M, Type Ty, bool isConstant, LinkageTypes Linkage, Constant Initializer = null, string Name = "", bool isThreadLocal = false, AddressSpace AddrSpace = AddressSpace.Generic)
	{
		auto c_Name = Name.toCString();
		Ty.getContext().treatAsImmutable(c_Name);
		auto __cref = LLVMAddGlobalInAddressSpace(
			M.cref,
			Ty.cref,
			c_Name,
			AddrSpace);
		this.setConstant(isConstant);
		this.setLinkage(Linkage);
		this.setInitializer(Initializer);
		this.setThreadLocal(isThreadLocal);
		super(Ty, __cref);
	}+/

	public bool hasInitializer()
	{ return LLVMGetInitializer(this._cref) !is null; }

	
	// TODO: Uncomment once LLVM C API patch has been commited
	/+static if(LLVM_Version >= 3.3)
	public bool hasDefinitiveInitializer()
	{
		return this.hasInitializer() &&
			// The initializer of a global variable with weak linkage may change at
			// link time.
			!this.mayBeOverridden() &&
			// The initializer of a global variable with the externally_initialized
			// marker may change at runtime before C++ initializers are evaluated.
			!this.isExternallyInitialized();
				
	}+/

	// TODO: Uncomment once LLVM C API patch has been commited
	/+static if(LLVM_Version >= 3.3)
	public bool hasUniqueInitializer()
	{
		return this.hasInitializer() &&
			// It's not safe to modify initializers of global variables with weak
			// linkage, because the linker might choose to discard the initializer and
			// use the initializer from another instance of the global variable
			// instead. It is wrong to modify the initializer of a global variable
			// with *_odr linkage because then different instances of the global may
			// have different initializers, breaking the One Definition Rule.
			!this.isWeakForLinker &&
			// It is not safe to modify initializers of global variables with the
			// external_initializer marker since the value may be changed at runtime
			// before C++ initializers are evaluated.
			!this.isExternallyInitialized();
	}+/

	public Constant getInitializer()
	{
		auto init = LLVMGetInitializer(this._cref);
		if(init !is null)
		{
			return cast(Constant) LLVMValueRef_to_Value(this.getContext(), init);
		}
		else
		{
			return null;
		}
	}

	void setInitializer(Constant InitVal)
	{ LLVMSetInitializer(this._cref, InitVal.cref); }

	public bool isConstant()
	{ return cast(bool) LLVMIsGlobalConstant(this._cref); }

	public void setConstant(bool Val)
	{ LLVMSetGlobalConstant(this._cref, cast(LLVMBool) Val); }

	public bool isThreadLocal()
	{ return cast(bool) LLVMIsThreadLocal(this._cref); }

	public void setThreadLocal(bool Val)
	{ LLVMSetThreadLocal(this._cref, cast(LLVMBool) Val); }

	// TODO: Implement these four once C API patch has been committed
	// void setThreadLocalMode(ThreadLocalMode Val)
	// ThreadLocalMode getThreadLocalMode()
	// bool isExternallyInitialized()
	// void setExternallyInitialized(bool Val)

	// void copyAttributesFrom(const GlobalValue *Src)
	// virtual void removeFromParent()

	public override void eraseFromParent()
	{ LLVMDeleteGlobal(this._cref); }

	public override void replaceUsesOfWithOnConstant(Value From, Value To, Use U)
	in
	{
		// If you call this, then you better know this GVar has a constant
		// initializer worth replacing. Enforce that here.
		assert(this.getNumOperands() == 1, "Attempt to replace uses of Constants on a GVar with no initializer");
		
		// And, since you know it has an initializer, the From value better be
		// the initializer :)
		assert(this.getOperand(0) == From, "Attempt to replace wrong constant initializer in GVar");
		
		// And, you better have a constant for the replacement value
		assert(is(To : Constant), "Attempt to replace GVar initializer with non-constant");
	}
	body
	{
		// Okay, preconditions out of the way, replace the constant initializer.
		this.setOperand(0, cast(Constant) To);
	}
}