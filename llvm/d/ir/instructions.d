
module llvm.d.ir.instructions;

private
{
	import llvm.d.llvm_c;

	import llvm.d.ir.llvmcontext;
	import llvm.d.ir.type;
	import llvm.d.ir.user;
	import llvm.d.ir.instruction;
}

class BinaryOperator : Instruction
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	// BinaryOps 	getOpcode () const
	// bool 	swapOperands ()
	// void 	setHasNoUnsignedWrap (bool b=true)
	// void 	setHasNoSignedWrap (bool b=true)
	// void 	setIsExact (bool b=true)
	// bool 	hasNoUnsignedWrap () const
	// bool 	hasNoSignedWrap () const
	// bool 	isExact () const
    // 
	// static BinaryOperator * 	Create (BinaryOps Op, Value *S1, Value *S2, const Twine &Name=Twine(), Instruction *InsertBefore=0)
	// static BinaryOperator * 	Create (BinaryOps Op, Value *S1, Value *S2, const Twine &Name, BasicBlock *InsertAtEnd)
	// static BinaryOperator * 	CreateNeg (Value *Op, const Twine &Name, BasicBlock *InsertAtEnd)
	// static BinaryOperator * 	CreateNSWNeg (Value *Op, const Twine &Name="", Instruction *InsertBefore=0)
	// static BinaryOperator * 	CreateNSWNeg (Value *Op, const Twine &Name, BasicBlock *InsertAtEnd)
	// static BinaryOperator * 	CreateNUWNeg (Value *Op, const Twine &Name="", Instruction *InsertBefore=0)
	// static BinaryOperator * 	CreateNUWNeg (Value *Op, const Twine &Name, BasicBlock *InsertAtEnd)
	// static BinaryOperator * 	CreateFNeg (Value *Op, const Twine &Name="", Instruction *InsertBefore=0)
	// static BinaryOperator * 	CreateFNeg (Value *Op, const Twine &Name, BasicBlock *InsertAtEnd)
	// static BinaryOperator * 	CreateNot (Value *Op, const Twine &Name="", Instruction *InsertBefore=0)
	// static BinaryOperator * 	CreateNot (Value *Op, const Twine &Name, BasicBlock *InsertAtEnd)
	// static bool 	isNeg (const Value *V)
	// static bool 	isFNeg (const Value *V, bool IgnoreZeroSign=false)
	// static bool 	isNot (const Value *V)
	// static const Value * 	getNegArgument (const Value *BinOp)
	// static Value * 	getNegArgument (Value *BinOp)
	// static const Value * 	getFNegArgument (const Value *BinOp)
	// static Value * 	getFNegArgument (Value *BinOp)
	// static const Value * 	getNotArgument (const Value *BinOp)
	// static Value * 	getNotArgument (Value *BinOp)
}

class CallInst : Instruction
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}
	
	// bool 	isTailCall () const
	// void 	setTailCall (bool isTC=true)
	// DECLARE_TRANSPARENT_OPERAND_ACCESSORS (Value)
	// unsigned 	getNumArgOperands () const
	// Value * 	getArgOperand (unsigned i) const
	// void 	setArgOperand (unsigned i, Value *v)
	// CallingConv::ID 	getCallingConv () const
	// void 	setCallingConv (CallingConv::ID CC)
	// const AttributeSet & 	getAttributes () const
	// void 	setAttributes (const AttributeSet &Attrs)
	// void 	addAttribute (unsigned i, Attribute::AttrKind attr)
	// void 	removeAttribute (unsigned i, Attribute attr)
	// bool 	hasFnAttr (Attribute::AttrKind A) const
	// bool 	paramHasAttr (unsigned i, Attribute::AttrKind A) const
	// unsigned 	getParamAlignment (unsigned i) const
	// bool 	isNoBuiltin () const
	// bool 	isNoInline () const
	// void 	setIsNoInline ()
	// bool 	canReturnTwice () const
	// void 	setCanReturnTwice ()
	// bool 	doesNotAccessMemory () const
	// void 	setDoesNotAccessMemory ()
	// bool 	onlyReadsMemory () const
	// void 	setOnlyReadsMemory ()
	// bool 	doesNotReturn () const
	// void 	setDoesNotReturn ()
	// bool 	doesNotThrow () const
	// void 	setDoesNotThrow ()
	// bool 	cannotDuplicate () const
	// void 	setCannotDuplicate ()
	// bool 	hasStructRetAttr () const
	// bool 	hasByValArgument () const
	// Function * 	getCalledFunction () const
	// const Value * 	getCalledValue () const
	// Value * 	getCalledValue ()
	// void 	setCalledFunction (Value *Fn)
	// bool 	isInlineAsm () const

	// static CallInst * 	Create (Value *Func, ArrayRef< Value * > Args, const Twine &NameStr="", Instruction *InsertBefore=0)
	// static CallInst * 	Create (Value *Func, ArrayRef< Value * > Args, const Twine &NameStr, BasicBlock *InsertAtEnd)
	// static CallInst * 	Create (Value *F, const Twine &NameStr="", Instruction *InsertBefore=0)
	// static CallInst * 	Create (Value *F, const Twine &NameStr, BasicBlock *InsertAtEnd)
	// static Instruction * 	CreateMalloc (Instruction *InsertBefore, Type *IntPtrTy, Type *AllocTy, Value *AllocSize, Value *ArraySize=0, Function *MallocF=0, const Twine &Name="")
	// static Instruction * 	CreateMalloc (BasicBlock *InsertAtEnd, Type *IntPtrTy, Type *AllocTy, Value *AllocSize, Value *ArraySize=0, Function *MallocF=0, const Twine &Name="")
	// static Instruction * 	CreateFree (Value *Source, Instruction *InsertBefore)
	// static Instruction * 	CreateFree (Value *Source, BasicBlock *InsertAtEnd)
}