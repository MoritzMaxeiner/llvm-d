module llvm.d.ir.basicblock;

private
{
	import llvm.d.llvm_c;

	import llvm.util.memory;

	import llvm.d.ir.llvmcontext;
	import llvm.d.ir.type;
	import llvm.d.ir.derivedtypes;
	import llvm.d.ir.value;
	import llvm.d.ir.user;
	import llvm.d.ir.constant;
	import llvm.d.ir.llvmfunction;
}

class BasicBlock : Value
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	// const Function * 	getParent () const

	// Function * 	getParent ()
	public Function getParent()
	{
		auto _cref = LLVMGetBasicBlockParent(LLVMValueAsBasicBlock(this._cref));
		auto type = LLVMTypeRef_to_Type(this.getContext(), LLVMTypeOf(_cref));

		return new Function(type, _cref);
	}

	// TerminatorInst * 	getTerminator ()
	/+public TerminatorInst getTerminator()
	{
		auto _cref = LLVMGetBasicBlockTerminator(this._cref);
		auto type = LLVMTypeRef_to_Type(this.getContext(), LLVMTypeOf(_cref));

		return new TerminatorInst(type, _cref);
	}+/

	// const TerminatorInst * 	getTerminator () const
	// Instruction * 	getFirstNonPHI ()
	// const Instruction * 	getFirstNonPHI () const
	// Instruction * 	getFirstNonPHIOrDbg ()
	// const Instruction * 	getFirstNonPHIOrDbg () const
	// Instruction * 	getFirstNonPHIOrDbgOrLifetime ()
	// const Instruction * 	getFirstNonPHIOrDbgOrLifetime () const
	// iterator 	getFirstInsertionPt ()
	// const_iterator 	getFirstInsertionPt () const

	// void 	removeFromParent ()
	public void removeFromParent()
	{
		/+ Note that because LLVM-C provides no means of adding an existing
		 + BasicBlock that is not already part of a Function (their parent) to another Function
		 + - it only allows to move around BasicBlocks which have a parent -
		 + at present this leaves you with a BasicBlock that cannot be used
		 + any further with Functions. +/
		LLVMRemoveBasicBlockFromParent(LLVMValueAsBasicBlock(this.cref));
	}

	// void 	eraseFromParent ()
	public void eraseFromParent()
	{
		LLVMDeleteBasicBlock(LLVMValueAsBasicBlock(this.cref));
	}

	// void 	moveBefore (BasicBlock *MovePos)
	public void moveBefore(BasicBlock MovePos)
	{
		LLVMMoveBasicBlockBefore(LLVMValueAsBasicBlock(this.cref), LLVMValueAsBasicBlock(MovePos.cref));
	}

	// void 	moveAfter (BasicBlock *MovePos)
	public void moveAfter(BasicBlock MovePos)
	{
		LLVMMoveBasicBlockAfter(LLVMValueAsBasicBlock(this.cref), LLVMValueAsBasicBlock(MovePos.cref));
	}

	// BasicBlock * 	getSinglePredecessor ()
	// const BasicBlock * 	getSinglePredecessor () const
	// BasicBlock * 	getUniquePredecessor ()
	// const BasicBlock * 	getUniquePredecessor () const
	// iterator 	begin ()
	// const_iterator 	begin () const
	// iterator 	end ()
	// const_iterator 	end () const
	// reverse_iterator 	rbegin ()
	// const_reverse_iterator 	rbegin () const
	// reverse_iterator 	rend ()
	// const_reverse_iterator 	rend () const
	// size_t 	size () const
	// bool 	empty () const
	// const Instruction & 	front () const
	// Instruction & 	front ()
	// const Instruction & 	back () const
	// Instruction & 	back ()
	// const InstListType & 	getInstList () const
	// InstListType & 	getInstList ()
	// ValueSymbolTable * 	getValueSymbolTable ()
	// void 	dropAllReferences ()
	// void 	removePredecessor (BasicBlock *Pred, bool DontDeleteUselessPHIs=false)
	// BasicBlock * 	splitBasicBlock (iterator I, const Twine &BBName="")
	// bool 	hasAddressTaken () const
	// void 	replaceSuccessorsPhiUsesWith (BasicBlock *New)
	// bool 	isLandingPad () const
	// LandingPadInst * 	getLandingPadInst ()
	// const LandingPadInst * 	getLandingPadInst () const

	// static BasicBlock * 	Create (LLVMContext &Context, const Twine &Name="", Function *Parent=0, BasicBlock *InsertBefore=0)
	public static BasicBlock Create(LLVMContext Context, string Name = "", Function Parent = null, BasicBlock InsertBefore = null)
	in
	{
		assert((Parent !is null) || (InsertBefore !is null), "Creation of standalone basic blocks is prohibited in llvm-d, as LLVM-C has no exports to later add them to functions");
	}
	body
	{
		LLVMValueRef _cref;

		immutable(char)* c_Name = Name.toCString();
		Context.treatAsImmutable(c_Name);

		if(InsertBefore !is null)
		{
			_cref = LLVMBasicBlockAsValue(LLVMInsertBasicBlockInContext(Context.cref, LLVMValueAsBasicBlock(InsertBefore.cref), c_Name));
		}
		else
		{
			_cref = LLVMBasicBlockAsValue(LLVMAppendBasicBlockInContext(Context.cref, Parent.cref, c_Name));
		}

		auto type = LLVMTypeRef_to_Type(Context, LLVMTypeOf(_cref));

		return new BasicBlock(type, _cref);
	}

	// static iplist< Instruction >
	// BasicBlock::* 	getSublistAccess (Instruction *)
}
