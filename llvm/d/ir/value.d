
module llvm.d.ir.value;

private
{
	import core.stdc.string : strlen;
	
	import llvm.util.memory : fromCString, toCString;

	import llvm.d.llvm_c;
	
	import llvm.d.ir.llvmcontext;
	import llvm.d.ir.type : Type;
}

class Value
{
	protected LLVMValueRef _cref = null;
	protected Type type = null;
	
	@property
	LLVMValueRef cref() { return this._cref; }
	
	override public bool opEquals(Object obj)
	{
		return is(obj : Value) &&
			((cast(Value) obj)._cref == this._cref);
	}
	
	package this(Type type, LLVMValueRef _cref)
	{
		this.type = type;
		this._cref = _cref;
	}
	
	public void dump()
	{ LLVMDumpValue(this._cref); }
	
	// void 	print (raw_ostream &O, AssemblyAnnotationWriter *AAW=0) const
	
	public Type getType()
	{ return this.type; }

	public LLVMContext getContext()
	{ return this.type.getContext(); }
	
	public bool hasName()
	{ return strlen(LLVMGetValueName(this._cref)) > 0; }

	// ValueName * 	getValueName () const
	// void 	setValueName (ValueName *VN)
	
	public string getName()
	{
		if(this.hasName())
		{
			return LLVMGetValueName(this._cref).fromCString();
		}
		else
		{
			return null;
		}
	}
	
	public void setName(string Name)
	{
		auto context = this.getContext();
		auto c_Name = Name.toCString();
		context.treatAsImmutable(c_Name);
		LLVMSetValueName(this._cref, c_Name);
	}

	// void 	takeName (Value *V)
	
	public void replaceAllUsesWith(Value V)
	{ LLVMReplaceAllUsesWith(this._cref, V.cref); }

	// bool 	use_empty () const
	// use_iterator 	use_begin ()
	// const_use_iterator 	use_begin () const
	// use_iterator 	use_end ()
	// const_use_iterator 	use_end () const
	// User * 	use_back ()
	// const User * 	use_back () const
	
	public bool hasOneUse()
	{
		auto use = LLVMGetFirstUse(this._cref);
		return LLVMGetNextUse(use) is null;
	}
	
	public bool hasNUses(uint N)
	{
		auto use = LLVMGetFirstUse(this._cref);
		foreach(i; 0 .. N)
		{
			if(use is null)
			{
				return false;
			}
			else
			{
				use = LLVMGetNextUse(use);
			}
		}
		
		return LLVMGetNextUse(use) is null;
	}
	
	public bool hasNUsesOrMore(uint N)
	{
		auto use = LLVMGetFirstUse(this._cref);
		foreach(i; 0 .. N)
		{
			if(use is null)
			{
				return false;
			}
			else
			{
				use = LLVMGetNextUse(use);
			}
		}
		
		return true;
	}

	// bool 	isUsedInBasicBlock (const BasicBlock *BB) const

	public uint getNumUses()
	{
		uint uses = 0;
		
		auto use = LLVMGetFirstUse(this._cref);
		while(use !is null)
		{
			uses += 1;
			use = LLVMGetNextUse(use);
		}
		
		return uses;
	}

	// void 	addUse (Use &U)
	// unsigned 	getValueID () const
	// unsigned 	getRawSubclassOptionalData () const
	// void 	clearSubclassOptionalData ()
	// bool 	hasSameSubclassOptionalData (const Value *V) const
	// void 	intersectOptionalDataWith (const Value *V)
	// bool 	hasValueHandle () const
	// Value * 	stripPointerCasts ()
	// const Value * 	stripPointerCasts () const
	// Value * 	stripInBoundsConstantOffsets ()
	// const Value * 	stripInBoundsConstantOffsets () const
	// Value * 	stripInBoundsOffsets ()
	// const Value * 	stripInBoundsOffsets () const
	// bool 	isDereferenceablePointer () const
	// Value * 	DoPHITranslation (const BasicBlock *CurBB, const BasicBlock *PredBB)
	// const Value * 	DoPHITranslation (const BasicBlock *CurBB, const BasicBlock *PredBB) const
	
	public void mutateType(Type Ty)
	{ this.type = Ty; }
	
	public static immutable uint MaximumAlignment = 1U << 29;
	// virtual void 	printCustom (raw_ostream &O) const
	// unsigned short 	getSubclassDataFromValue () const
	// void 	setValueSubclassData (unsigned short D)
}