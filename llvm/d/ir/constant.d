module llvm.d.ir.constant;

private
{
	import llvm.d.llvm_c;
	
	import llvm.d.ir.llvmcontext;
	import llvm.d.ir.type;
	import llvm.d.ir.value;
	import llvm.d.ir.user;
	import llvm.d.ir.use;
}

class Constant : User
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}
	
	public bool isNullValue()
	{ return cast(bool) LLVMIsNull(this._cref); }

	// bool 	isAllOnesValue ()
	// bool 	isNegativeZeroValue ()
	// bool 	isZeroValue ()
	// bool 	canTrap ()
	// bool 	isThreadDependent ()
	// bool 	isConstantUsed ()
	// PossibleRelocationsTy 	getRelocationInfo ()
	// Constant * 	getAggregateElement (unsigned Elt)
	// Constant * 	getAggregateElement (Constant *Elt)
	// Constant * 	getSplatValue ()
	// const APInt & 	getUniqueInteger ()
	// virtual void 	destroyConstant ()

	public void replaceUsesOfWithOnConstant(Value From, Value To, Use U);
	// void 	removeDeadConstantUsers ()
	
	public static Constant getNullValue(Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(
			Ty.getContext(),
			LLVMConstNull(Ty.cref));
	}
	
	public static Constant getAllOnesValue(Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(
			Ty.getContext(),
			LLVMConstAllOnes(Ty.cref));
	}
	
	// static Constant * 	getIntegerValue (Type *Ty, const APInt &V)
}