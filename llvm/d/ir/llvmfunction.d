module llvm.d.ir.llvmfunction;

private
{
	import core.stdc.string : strlen;

	import std.algorithm : find;

	import llvm.util.templates;
	import llvm.util.memory;

	import llvm.d.llvm_c;

	import llvm.d.ir.llvmcontext;
	import llvm.d.ir.type;
	import llvm.d.ir.derivedtypes;
	import llvm.d.ir.value;
	import llvm.d.ir.user;
	import llvm.d.ir.constant;
	import llvm.d.ir.globalvalue;
	import llvm.d.ir.attributes;
}

class Function : GlobalValue
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	// Type * 	getReturnType () const
	// FunctionType * 	getFunctionType () const
	// LLVMContext & 	getContext () const
	// bool 	isVarArg () const

	public uint getIntrinsicID()
	{
		return LLVMGetIntrinsicID(this._cref);
	}

	// bool 	isIntrinsic () const

	public uint getCallingConv()
	{
		return LLVMGetFunctionCallConv(this._cref);
	}

	public void setCallingConv(uint CC)
	{
		LLVMSetFunctionCallConv(this._cref, CC);
	}

	// AttributeSet 	getAttributes () const
	public Attribute getAttributes()
	{
		return cast(Attribute) (this._cref);
	}

	// void 	setAttributes (AttributeSet attrs)

	public void addFnAttr(Attribute N)
	{
		LLVMAddFunctionAttr(this._cref, N);
	}

	public void removeFnAttr(Attribute N)
	{
		LLVMRemoveFunctionAttr(this._cref, N);
	}

	// void 	addFnAttr (StringRef Kind)
	// void 	addFnAttr (StringRef Kind, StringRef Value)
	// bool 	hasFnAttribute (Attribute::AttrKind Kind) const
	// bool 	hasFnAttribute (StringRef Kind) const
	// Attribute 	getFnAttribute (Attribute::AttrKind Kind) const
	// Attribute 	getFnAttribute (StringRef Kind) const
	// bool 	hasGC () const

	public string getGC()
	{
		return LLVMGetGC(this._cref).fromCString();
	}

	public void setGC(string Str)
	{
		auto context = this.getContext();
		auto c_Str = Str.toCString();
		context.treatAsImmutable(c_Str);
		LLVMSetGC(this._cref, c_Str);
	}

	// void 	clearGC ()
	// void 	addAttribute (unsigned i, Attribute::AttrKind attr)
	// void 	addAttributes (unsigned i, AttributeSet attrs)
	// void 	removeAttributes (unsigned i, AttributeSet attr)
	// unsigned 	getParamAlignment (unsigned i) const
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
	// bool 	hasUWTable () const
	// void 	setHasUWTable ()
	// bool 	needsUnwindTableEntry () const
	// bool 	hasStructRetAttr () const
	// bool 	doesNotAlias (unsigned n) const
	// void 	setDoesNotAlias (unsigned n)
	// bool 	doesNotCapture (unsigned n) const
	// void 	setDoesNotCapture (unsigned n)
	// bool 	doesNotAccessMemory (unsigned n) const
	// void 	setDoesNotAccessMemory (unsigned n)
	// bool 	onlyReadsMemory (unsigned n) const
	// void 	setOnlyReadsMemory (unsigned n)
	// void 	copyAttributesFrom (const GlobalValue *Src)
	// void 	deleteBody ()
	// virtual void 	removeFromParent ()
	
	public override void eraseFromParent()
	{
		LLVMDeleteFunction(this._cref);
	}

	// const ArgumentListType & 	getArgumentList () const
	// ArgumentListType & 	getArgumentList ()
	// const BasicBlockListType & 	getBasicBlockList () const
	// BasicBlockListType & 	getBasicBlockList ()
	// const BasicBlock & 	getEntryBlock () const
	// BasicBlock & 	getEntryBlock ()
	// ValueSymbolTable & 	getValueSymbolTable ()
	// const ValueSymbolTable & 	getValueSymbolTable () const
	// iterator 	begin ()
	// const_iterator 	begin () const
	// iterator 	end ()
	// const_iterator 	end () const


	public uint size()
	{
		return LLVMCountBasicBlocks(this.cref);
	}

	// bool 	empty () const
	// const BasicBlock & 	front () const
	// BasicBlock & 	front ()
	// const BasicBlock & 	back () const
	// BasicBlock & 	back ()
	// arg_iterator 	arg_begin ()
	// const_arg_iterator 	arg_begin () const
	// arg_iterator 	arg_end ()
	// const_arg_iterator 	arg_end () const
	// size_t 	arg_size () const
	// bool 	arg_empty () const
	// void 	viewCFG () const
	// void 	viewCFGOnly () const
	// void 	dropAllReferences ()
	// bool 	hasAddressTaken (const User **=0) const
	// bool 	isDefTriviallyDead () const
	// bool 	callsFunctionThatReturnsTwice () const

	// static Function * 	Create (FunctionType *Ty, LinkageTypes Linkage, const Twine &N="", Module *M=0)
	// static iplist< Argument >
	// Function::* 	getSublistAccess (Argument *)
	// static iplist< BasicBlock >
	// Function::* 	getSublistAccess (BasicBlock *)
	// static bool 	classof (const Value *V)
}
