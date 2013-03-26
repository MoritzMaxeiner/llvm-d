module llvm.d.ir.use;

private
{
	import llvm.d.llvm_c;
	
	import llvm.d.ir.llvmcontext : LLVMContext;
	import llvm.d.ir.type : Type;
	import llvm.d.ir.value : Value, LLVMValueRef_to_Value;
	import llvm.d.ir.user : User;
}

class Use
{
	protected LLVMUseRef _cref = null;
	protected Value value = null;
	protected User user = null;
	
	@property
	LLVMUseRef cref() { return this._cref; }
	
	override public bool opEquals(Object obj)
	{
		return is(obj : Use) &&
			((cast(Use) obj)._cref == this._cref);
	}
	
	package this(LLVMContext C, LLVMUseRef _cref)
	{
		this._cref = _cref;
		this.value = LLVMValueRef_to_Value(C, LLVMGetUsedValue(this._cref));
		this.user = cast(User) LLVMValueRef_to_Value(C, LLVMGetUser(this._cref));
	}
	
	// void 	swap (Use &RHS)
	// operator Value * ()
	
	public Value get()
	{ return this.value; }
	
	public User get()
	{ return this.user; }
	
	// void 	set (Value *Val)
	// Value * 	operator= (Value *RHS)
	// const Use & 	operator= (const Use &RHS)
	// Value * 	operator-> ()
	// const Value * 	operator-> ()
	
	public Use getNext()
	{ return new Use(this.value.getContext(), LLVMGetNextUse(this._cref)); }

	// static Use * 	initTags (Use *Start, Use *Stop)
	// static void 	zap (Use *Start, const Use *Stop, bool del=false)
}