module llvm.d.ir.constants;

private
{
	import llvm.d.llvm_c;
	
	import llvm.d.ir.llvmcontext : LLVMContext;
	import llvm.d.ir.type : Type;
	import llvm.d.ir.value : Value, LLVMValueRef_to_Value;
	import llvm.d.ir.user : User;
	import llvm.d.ir.constant : Constant;
}

class UndefValue : Constant
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	public UndefValue getSequentialElement()
	{ return UndefValue.get(this.type.getSequentialElementType()); }

	public UndefValue getStructElement(uint Elt)
	{ return UndefValue.get(this.type.getStructElementType(Elt)); }

	// TODO: Uncomment once ConstantInt has been implemented
	/+public UndefValue getElementValue(Constant C)
	{
		if(is(this.type : SequentialType))
		{
			return this.getSequentialElement();
		}
		
		return this.getStructElement((cast(ConstantInt) C).getZExtValue());
	}+/
	
	public UndefValue getElementValue(uint Idx)
	{
		if(is(this.type : SequentialType))
		{
			return this.getSequentialElement();
		}
		
		return this.getStructElement(Idx);
	}

	// virtual void 	destroyConstant ()
	
	public static UndefValue get(Type T)
	{ return new UndefValue(T, LLVMGetUndef(T.cref)); }
}