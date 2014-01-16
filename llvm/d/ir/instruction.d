module llvm.d.ir.instruction;

private
{
	import llvm.d.llvm_c;
	
	import llvm.d.ir.llvmcontext;
	import llvm.d.ir.type;
	import llvm.d.ir.user;
}


class Instruction : User
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	// Instruction * 	use_back ()
	// const Instruction * 	use_back () const
	// const BasicBlock * 	getParent () const
	// BasicBlock * 	getParent ()
	// void 	removeFromParent ()
	// void 	eraseFromParent ()
	// void 	insertBefore (Instruction *InsertPos)
	// void 	insertAfter (Instruction *InsertPos)
	// void 	moveBefore (Instruction *MovePos)
	// unsigned 	getOpcode () const
	// const char * 	getOpcodeName () const
	// bool 	isTerminator () const
	// bool 	isBinaryOp () const
	// bool 	isShift ()
	// bool 	isCast () const
	// bool 	isLogicalShift () const
	// bool 	isArithmeticShift () const
	// bool 	hasMetadata () const
	// bool 	hasMetadataOtherThanDebugLoc () const
	// MDNode * 	getMetadata (unsigned KindID) const
	// MDNode * 	getMetadata (StringRef Kind) const
	// void 	getAllMetadata (SmallVectorImpl< std::pair< unsigned, MDNode * > > &MDs) const
	// void 	getAllMetadataOtherThanDebugLoc (SmallVectorImpl< std::pair< unsigned, MDNode * > > &MDs) const
	// void 	setMetadata (unsigned KindID, MDNode *Node)
	// void 	setMetadata (StringRef Kind, MDNode *Node)
	// void 	setDebugLoc (const DebugLoc &Loc)
	// const DebugLoc & 	getDebugLoc () const
	// void 	setHasUnsafeAlgebra (bool B)
	// void 	setHasNoNaNs (bool B)
	// void 	setHasNoInfs (bool B)
	// void 	setHasNoSignedZeros (bool B)
	// void 	setHasAllowReciprocal (bool B)
	// void 	setFastMathFlags (FastMathFlags FMF)
	// bool 	hasUnsafeAlgebra () const
	// bool 	hasNoNaNs () const
	// bool 	hasNoInfs () const
	// bool 	hasNoSignedZeros () const
	// bool 	hasAllowReciprocal () const
	// FastMathFlags 	getFastMathFlags () const
	// void 	copyFastMathFlags (const Instruction *I)
	// bool 	isAssociative () const
	// bool 	isCommutative () const
	// bool 	isIdempotent () const
	// bool 	isNilpotent () const
	// bool 	mayWriteToMemory () const
	// bool 	mayReadFromMemory () const
	// bool 	mayReadOrWriteMemory () const
	// bool 	mayThrow () const
	// bool 	mayReturn () const
	// bool 	mayHaveSideEffects () const
	// Instruction * 	clone () const
	// bool 	isIdenticalTo (const Instruction *I) const
	// bool 	isIdenticalToWhenDefined (const Instruction *I) const
	// bool 	isSameOperationAs (const Instruction *I, unsigned flags=0) const
	// bool 	isUsedOutsideOfBlock (const BasicBlock *BB) const

	// static const char * 	getOpcodeName (unsigned OpCode)
	// static bool 	isTerminator (unsigned OpCode)
	// static bool 	isBinaryOp (unsigned Opcode)
	// static bool 	isShift (unsigned Opcode)
	// static bool 	isCast (unsigned OpCode)
	// static bool 	isAssociative (unsigned op)
	// static bool 	isCommutative (unsigned op)
	// static bool 	isIdempotent (unsigned op)
	// static bool 	isNilpotent (unsigned op)
}