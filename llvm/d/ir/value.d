
module llvm.d.ir.value;

private
{
	import core.stdc.string : strlen;

	import llvm.util.memory;

	import llvm.d.llvm_c;

	import llvm.d.ir.llvmcontext;
	import llvm.d.ir.type;
	import llvm.d.ir.derivedtypes;
	
	import llvm.d.ir.user;
	import llvm.d.ir.constant;
	import llvm.d.ir.constants;
	import llvm.d.ir.globalvalue;
	import llvm.d.ir.globalalias;
	import llvm.d.ir.globalvariable;
	import llvm.d.ir.llvmfunction;
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

package Value LLVMValueRef_to_Value(LLVMContext C, LLVMValueRef value)
{
	auto type = LLVMTypeRef_to_Type(C, LLVMTypeOf(value));
	
	if(LLVMIsAArgument(value) !is null) 
	{
		//return new Argument(type, value);
	}
	else if(LLVMIsABasicBlock(value) !is null)
	{
		//return new BasicBlock(type, value);
	}
	else if(LLVMIsAInlineAsm(value) !is null)
	{
		//return new InlineAsm(type, value);
	}
	else if(LLVMIsAMDNode(value) !is null)
	{
		//return new MDNode(type, value);
	}
	else if(LLVMIsAMDString(value) !is null)
	{
		//return new MDString(type, value);
	}
	else if(LLVMIsAUser(value) !is null)
	{
		if(LLVMIsAConstant(value) !is null)
		{
			if(LLVMIsABlockAddress(value) !is null)
			{
				//return new BlockAddress(type, value);
			}
			else if(LLVMIsAConstantAggregateZero(value) !is null)
			{
				//return new ConstantAggregateZero(type, value);
			}
			else if(LLVMIsAConstantArray(value) !is null)
			{
				//return new ConstantArray(type, value);
			}
			else if(LLVMIsAConstantExpr(value) !is null)
			{
				//return new ConstantExpr(type, value);
			}
			else if(LLVMIsAConstantFP(value) !is null)
			{
				//return new ConstantFP(type, value);
			}
			else if(LLVMIsAConstantInt(value) !is null)
			{
				return new ConstantInt(type, value);
			}
			else if(LLVMIsAConstantPointerNull(value) !is null)
			{
				return new ConstantPointerNull(type, value);
			}
			else if(LLVMIsAConstantStruct(value) !is null)
			{
				return new ConstantStruct(type, value);
			}
			else if(LLVMIsAConstantVector(value) !is null)
			{
				return new ConstantVector(type, value);
			}
			else if(LLVMIsAGlobalValue(value) !is null)
			{
				if(LLVMIsAFunction(value) !is null)
				{
					return new Function(type, value);
				}
				else if(LLVMIsAGlobalAlias(value) !is null)
				{
					return new GlobalAlias(type, value);
				}
				else if(LLVMIsAGlobalVariable(value) !is null)
				{
					return new GlobalVariable(type, value);
				}
				else
				{
					return new GlobalValue(type, value);
				}
			}
			else if(LLVMIsAUndefValue(value) !is null)
			{
				return new UndefValue(type, value);
			}
			else
			{
				return new Constant(type, value);
			}
		}
		else if(LLVMIsAInstruction(value) !is null)
		{
			if(LLVMIsABinaryOperator(value) !is null)
			{
				//return new BinaryOperator(type, value);
			}
			else if(LLVMIsACallInst(value) !is null)
			{
				if(LLVMIsAIntrinsicInst(value) !is null)
				{
					if(LLVMIsADbgInfoIntrinsic(value) !is null)
					{
						if(LLVMIsADbgDeclareInst(value) !is null)
						{
							//return new DbgDeclareInst(type, value);
						}
						else
						{
							//return new DbgInfoIntrinsic(type, value);
						}
					}
					else if(LLVMIsAMemIntrinsic(value) !is null)
					{
						if(LLVMIsAMemCpyInst(value) !is null)
						{
							//return new MemCpyInst(type, value);
						}
						else if(LLVMIsAMemMoveInst(value) !is null)
						{
							//return new MemMoveInst(type, value);
						}
						else if(LLVMIsAMemSetInst(value) !is null)
						{
							//return new MemSetInst(type, value);
						}
						else
						{
							//return new MemIntrinsic(type, value);
						}
					}
					else
					{
						//return new IntrinsicInst(type, value);
					}
				}
				else
				{
					//return new CallInst(type, value);
				}
			}
			else if(LLVMIsACmpInst(value) !is null)
			{
				if(LLVMIsAFCmpInst(value) !is null)
				{
					//return new FCmpInst(type, value);
				}
				else if(LLVMIsAICmpInst(value) !is null)
				{
					//return new ICmpInst(type, value);
				}
				else
				{
					//return new CmpInst(type, value);
				}
			}
			else if(LLVMIsAExtractElementInst(value) !is null)
			{
				//return new ExtractElementInst(type, value);
			}
			else if(LLVMIsAGetElementPtrInst(value) !is null)
			{
				//return new GetElementPtrInst(type, value);
			}
			else if(LLVMIsAInsertElementInst(value) !is null)
			{
				//return new InsertElementInst(type, value);
			}
			else if(LLVMIsAInsertValueInst(value) !is null)
			{
				//return new InsertValueInst(type, value);
			}
			else if(LLVMIsALandingPadInst(value) !is null)
			{
				//return new LandingPadInst(type, value);
			}
			else if(LLVMIsAPHINode(value) !is null)
			{
				//return new PHINode(type, value);
			}
			else if(LLVMIsASelectInst(value) !is null)
			{
				//return new SelectInst(type, value);
			}
			else if(LLVMIsAShuffleVectorInst(value) !is null)
			{
				//return new ShuffleVectorInst(type, value);
			}
			else if(LLVMIsAStoreInst(value) !is null)
			{
				//return new StoreInst(type, value);
			}
			else if(LLVMIsATerminatorInst(value) !is null)
			{
				if(LLVMIsABranchInst(value) !is null)
				{
					//return new BranchInst(type, value);
				}
				else if(LLVMIsAIndirectBrInst(value) !is null)
				{
					//return new IndirectBrInst(type, value);
				}
				else if(LLVMIsAInvokeInst(value) !is null)
				{
					//return new InvokeInst(type, value);
				}
				else if(LLVMIsAReturnInst(value) !is null)
				{
					//return new ReturnInst(type, value);
				}
				else if(LLVMIsASwitchInst(value) !is null)
				{
					//return new SwitchInst(type, value);
				}
				else if(LLVMIsAUnreachableInst(value) !is null)
				{
					//return new UnreachableInst(type, value);
				}
				else if(LLVMIsAResumeInst(value) !is null)
				{
					//return new ResumeInst(type, value);
				}
				else
				{
					//return new TerminatorInst(type, value);
				}
			}
			else
			{
				//return new Instruction(type, value);
			}
		}
		else if(LLVMIsAUnaryInstruction(value) !is null)
		{
			if(LLVMIsAAllocaInst(value) !is null)
			{
				//return new AllocaInst(type, value);
			}
			else if(LLVMIsACastInst(value) !is null)
			{
				if(LLVMIsABitCastInst(value) !is null)
				{
					//return new BitCastInst(type, value);
				}
				else if(LLVMIsAFPExtInst(value) !is null)
				{
					//return new FPExtInst(type, value);
				}
				else if(LLVMIsAFPToSIInst(value) !is null)
				{
					//return new FPToSIInst(type, value);
				}
				else if(LLVMIsAFPToUIInst(value) !is null)
				{
					//return new FPToUIInst(type, value);
				}
				else if(LLVMIsAFPTruncInst(value) !is null)
				{
					//return new FPTruncInst(type, value);
				}
				else if(LLVMIsAIntToPtrInst(value) !is null)
				{
					//return new IntToPtrInst(type, value);
				}
				else if(LLVMIsAPtrToIntInst(value) !is null)
				{
					//return new PtrToIntInst(type, value);
				}
				else if(LLVMIsASExtInst(value) !is null)
				{
					//return new SExtInst(type, value);
				}
				else if(LLVMIsASIToFPInst(value) !is null)
				{
					//return new SIToFPInst(type, value);
				}
				else if(LLVMIsATruncInst(value) !is null)
				{
					//return new TruncInst(type, value);
				}
				else if(LLVMIsAUIToFPInst(value) !is null)
				{
					//return new UIToFPInst(type, value);
				}
				else if(LLVMIsAZExtInst(value) !is null)
				{
					//return new ZExtInst(type, value);
				}
				else
				{
					//return new CastInst(type, value);
				}
			}
			else if(LLVMIsAExtractValueInst(value) !is null)
			{
				//return new ExtractValueInst(type, value);
			}
			else if(LLVMIsALoadInst(value) !is null)
			{
				//return new LoadInst(type, value);
			}
			else if(LLVMIsAVAArgInst(value) !is null)
			{
				//return new VAArgInst(type, value);
			}
			else
			{
				//return new UnaryInstruction(type, value);
			}
		}
		else
		{
			return new User(type, value);
		}
	}
	
	return new Value(type, value);
}

/+ LLVM Value subclass hierarchy:
Argument
BasicBlock
InlineAsm
MDNode
MDString
User -- implemented
	Constant -- implemented
		BlockAddress
		ConstantAggregateZero
		ConstantArray
		ConstantDataSequential
			ConstantDataArray
			ConstantDataVector
		ConstantExpr
			BinaryConstantExpr
			CompareConstantExpr
			ExtractElementConstantExpr
			ExtractValueConstantExpr
			GetElementPtrConstantExpr
			InsertElementConstantExpr
			InsertValueConstantExpr
			SelectConstantExpr
			ShuffleVectorConstantExpr
			UnaryConstantExpr
		ConstantFP
		ConstantInt
		ConstantPointerNull -- implemented
		ConstantStruct -- implemented
		ConstantVector -- implemented
		GlobalValue -- implemented
			Function -- implemented
			GlobalAlias -- implemented
			GlobalVariable -- implemented
		UndefValue -- implemented
	Instruction
		AtomicCmpXchInst
		AtomicRMWInst
		BinaryOperator
		CallInst
			IntrinsicInst
				DbgInfoIntrinsic
					DbgDeclareInst
				MemIntrinsic
					MemCpyInst
					MemMoveInst
					MemSetInst
		CmpInst
			FCmpInst
			ICmpInst
		ExtractElementInst
		GetElementPtrInst
		InsertElementInst
		InsertValueInst
		LandingPadInst
		PHINode
		SelectInst
		ShuffleVectorInst
		StoreInst
		TerminatorInst
			BranchInst
			IndirectBrInst
			InvokeInst
			ReturnInst
			SwitchInst
			UnreachableInst
			ResumeInst
	UnaryInstruction
		AllocaInst
		CastInst
			BitCastInst
			FPExtInst
			FPToSIInst
			FPToUIInst
			FPTruncInst
			IntToPtrInst
			PtrToIntInst
			SExtInst
			SIToFPInst
			TruncInst
			UIToFPInst
			ZExtInst
		ExtractValueInst
		LoadInst
		VAArgInst
+/
