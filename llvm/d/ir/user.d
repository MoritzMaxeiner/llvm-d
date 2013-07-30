module llvm.d.ir.user;

private
{
	import llvm.d.llvm_c;
	
	import llvm.d.ir.llvmcontext;
	import llvm.d.ir.type;
	import llvm.d.ir.value;
}

class User : Value
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	// void 	operator delete (void *Usr)
	// void 	operator delete (void *, unsigned)
	// void 	operator delete (void *, unsigned, bool)
	
	public Value getOperand(uint i)
	{ return LLVMValueRef_to_Value(this.getContext(), LLVMGetOperand(this._cref, i)); }

	public void setOperand(uint i, Value Val)
	{ LLVMSetOperand(this._cref, i, Val.cref); }

	// const Use & 	getOperandUse (unsigned i)
	// Use & 	getOperandUse (unsigned i)
	
	public uint getNumOperands()
	{ return LLVMGetNumOperands(this._cref); }

	// op_iterator 	op_begin ()
	// const_op_iterator 	op_begin ()
	// op_iterator 	op_end ()
	// const_op_iterator 	op_end ()
	// value_op_iterator 	value_op_begin ()
	// value_op_iterator 	value_op_end ()
	// void 	dropAllReferences ()
	
	// TODO: Uncomment once "Constant" and "GlobalValue" have been added
	/+public void replaceUsesOfWith(Value From, Value To)
	in
	{
		assert(!is(this : Constant) || is(this : GlobalValue),
		       "Cannot call User.replaceUsesOfWith on a constant!");
	}
	body
	{
		if(From == To)
		{
			return;
		}
		
		foreach(i; 0 .. this.getNumOperands())
		{
			if(this.getOperand(i) == From)
			{
				this.setOperand(i, To);
			}
		}
	}+/
}