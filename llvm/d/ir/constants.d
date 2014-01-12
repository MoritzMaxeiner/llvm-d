module llvm.d.ir.constants;

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
	import llvm.d.ir.basicblock;
	import llvm.d.ir.llvmfunction;
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

class BlockAddress : Constant
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	// Function * 	getFunction () const
	// BasicBlock * 	getBasicBlock () const
	// virtual void 	destroyConstant ()
	// virtual void 	replaceUsesOfWithOnConstant (Value *From, Value *To, Use *U)

	// static BlockAddress * 	get (Function *F, BasicBlock *BB)
	public static BlockAddress get(Function F, BasicBlock BB)
	{
		auto _cref = LLVMBlockAddress(F.cref, LLVMValueAsBasicBlock(BB.cref));
		auto type = LLVMTypeRef_to_Type(F.getContext(), LLVMTypeOf(_cref));

		return new BlockAddress(type, _cref);
	}

	// static BlockAddress * 	get (BasicBlock *BB)
}

class ConstantFP : Constant
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	// const APFloat & 	getValueAPF () const
	// bool 	isZero () const
	// bool 	isNegative () const
	// bool 	isNaN () const
	// bool 	isExactlyValue (const APFloat &V) const
	// bool 	isExactlyValue (double V) const
	// static Constant * 	getZeroValueForNegation (Type *Ty)

	public static Constant get(Type Ty, double V)
	{
		return new ConstantFP(Ty, LLVMConstReal(Ty.cref, V));
	}

	public static Constant get(Type Ty, string Str)
	{
		auto c_Str = Str.toCString();
		Ty.getContext().treatAsImmutable(c_Str);
		return new ConstantFP(Ty, LLVMConstRealOfStringAndSize(Ty.cref, c_Str, to!uint(Str.length)));
	}

	// static ConstantFP * 	get (LLVMContext &Context, const APFloat &V)
	// static ConstantFP * 	getNegativeZero (Type *Ty)
	// static ConstantFP * 	getInfinity (Type *Ty, bool Negative=false)
	// static bool 	isValueValidForType (Type *Ty, const APFloat &V)
}

class ConstantInt : Constant
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	// const APInt & 	getValue () const

	public uint getBitWidth()
	{
		return this.type.getIntegerBitWidth();
	}

	public ulong getZExtValue()
	in
	{
		assert(this.type.getIntegerBitWidth() <= 64, "Too many bits for ulong");
	}
	body
	{
		return LLVMConstIntGetZExtValue(this._cref);
	}

	public long getSExtValue()
	in
	{
		assert(this.type.getIntegerBitWidth() <= 64, "Too many bits for long");
	}
	body
	{
		return LLVMConstIntGetSExtValue(this._cref);
	}

	public bool equalsInt(ulong V)
	{
		return V == getSExtValue();
	}

	public override IntegerType getType()
	{
		return cast(IntegerType) Value.getType();
	}

	// bool 	isNegative () const
	// bool 	isZero () const
	// bool 	isOne () const
	// bool 	isMinusOne () const
	// bool 	isMaxValue (bool isSigned) const
	// bool 	isMinValue (bool isSigned) const
	// bool 	uge (uint64_t Num) const
	// uint64_t 	getLimitedValue (uint64_t Limit=~0ULL) const

	public static ConstantInt getTrue(LLVMContext Context)
	{
		return ConstantInt.get(Type.getInt1Ty(Context), 1);
	}

	public static ConstantInt getFalse(LLVMContext Context)
	{
		return ConstantInt.get(Type.getInt1Ty(Context), 0);
	}

	// static Constant * 	getTrue (Type *Ty)
	// static Constant * 	getFalse (Type *Ty)

	// static Constant * 	get (Type *Ty, uint64_t V, bool isSigned=false)
	/+public static Constant get(Type Ty, ulong V, bool isSigned = false)
	{
		Constant C = ConstantInt.get(cast(IntegerType) Ty.getScalarType(), V, isSigned);

		// For vectors, broadcast the value.
		if(is(Ty : VectorType))
		{
			VectorType VTy = cast(VectorType) Ty;
			return ConstantVector.getSplat(VTy.getNumElements(), C);
		}

		return C;
	}+/

	public static ConstantInt get(IntegerType Ty, ulong V, bool isSigned = false)
	{
		return new ConstantInt(Ty, LLVMConstInt(Ty.cref, V, to!LLVMBool(isSigned)));
	}

	public static ConstantInt getSigned(IntegerType Ty, long V)
	{
		return ConstantInt.get(Ty, cast(ulong) V, true);
	}

	// static Constant * 	getSigned (Type *Ty, int64_t V)
	// static ConstantInt * 	get (LLVMContext &Context, const APInt &V)

	public static ConstantInt get(IntegerType Ty, string Str, ubyte radix)
	{
		auto c_Str = Str.toCString();
		Ty.getContext().treatAsImmutable(c_Str);
		return new ConstantInt(Ty, LLVMConstIntOfStringAndSize (Ty.cref, c_Str, to!uint(Str.length), radix));
	}

	// static Constant * 	get (Type *Ty, const APInt &V)

	public static bool isValueValidForType(Type Ty, ulong Val)
	{
		uint NumBits = Ty.getIntegerBitWidth(); // assert okay
		
		if(Ty.isIntegerTy(1))
		{
		  return Val == 0 || Val == 1;
		}

		if(NumBits >= 64)
		{
		  return true; // always true, has to fit in largest type
		}

		ulong Max = (1L << NumBits) - 1;
		return Val <= Max;
	}

	public static bool isValueValidForType(Type Ty, long Val)
	{
		uint NumBits = Ty.getIntegerBitWidth();

		if(Ty.isIntegerTy(1))
		{
		  return Val == 0 || Val == 1 || Val == -1;
		}

		if (NumBits >= 64)
		{
		  return true; // always true, has to fit in largest type
		}

		long Min = -(1L << (NumBits-1));
		long Max = (1L << (NumBits-1)) - 1;
		return (Val >= Min && Val <= Max);
	}
}

class ConstantPointerNull : Constant
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	// virtual void 	destroyConstant ()

	public override PointerType getType()
	{
		return cast(PointerType) Value.getType();
	}

	public static ConstantPointerNull get(PointerType T)
	{
		auto _cref = LLVMConstPointerNull(T.cref);
		auto type = LLVMTypeRef_to_Type(T.getContext(), LLVMTypeOf(_cref));

		return new ConstantPointerNull(type, _cref);
	}
}

class ConstantStruct : Constant
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	public override StructType getType()
	{
		return cast(StructType) Value.getType();
	}

	// virtual void 	destroyConstant ()
	// virtual void 	replaceUsesOfWithOnConstant (Value *From, Value *To, Use *U)

	public static Constant get(StructType T, Constant[] V ...)
	{
		LLVMValueRef* ConstantVals = construct!LLVMValueRef(V.length);

		foreach(i; 0 .. V.length)
		{
			ConstantVals[i] = V[i].cref;
		}

		/+ As can be seen at http://llvm.org/docs/doxygen/html/Constants_8cpp_source.html#l00874
		 + LLVM may either copy the pointers contained in ConstantVals (in which case we
		 + should deallocate it after the call to the C API), or remember ConstantVals itself
		 + - by adding it to a map as a value - (in which case we could only deallocate it when
		 + the current LLVMContext gets destroyed, as there is no way to know for sure when LLVM
		 + loses its last reference to ConstantVals at an earlier time).
		 + Because there is no way to know here which of the two possibilities will happen, we
		 + have to assume the latter (remember it until the current LLVMContext dies).
		 +/
		LLVMContext context = T.getContext();
		if(ConstantVals !is null)
		{
			context.treatAsImmutable!LLVMValueRef(ConstantVals);
		}

		auto _cref = LLVMConstNamedStruct(T.cref, ConstantVals, to!uint(V.length));
		auto type = LLVMTypeRef_to_Type(context, LLVMTypeOf(_cref));

		return new ConstantStruct(type, _cref);
	}

	public static Constant getAnon(Constant[] V, bool Packed = false)
	in
	{
		assert(V.length > 0, "ConstantStruct.getAnon cannot be called on empty list");
	}
	body
	{
		LLVMValueRef* ConstantVals = construct!LLVMValueRef(V.length);

		foreach(i; 0 .. V.length)
		{
			ConstantVals[i] = V[i].cref;
		}

		/+ As can be seen at http://llvm.org/docs/doxygen/html/Constants_8cpp_source.html#l00874
		+ LLVM may either copy the pointers contained in ConstantVals (in which case we
		+ should deallocate it after the call to the C API), or remember ConstantVals itself
		+ - by adding it to a map as a value - (in which case we could only deallocate it when
		+ the current LLVMContext gets destroyed, as there is no way to know for sure when LLVM
		+ loses its last reference to ConstantVals at an earlier time).
		+ Because there is no way to know here which of the two possibilities will happen, we
		+ have to assume the latter (remember it until the current LLVMContext dies).
		+/
		LLVMContext context = V[0].getContext();
		context.treatAsImmutable!LLVMValueRef(ConstantVals);

		auto _cref = LLVMConstStructInContext(context.cref, ConstantVals, to!uint(V.length), to!LLVMBool(Packed));
		auto type = LLVMTypeRef_to_Type(context, LLVMTypeOf(_cref));

		return new ConstantStruct(type, _cref);
	}

	public static Constant getAnon(LLVMContext Ctx, Constant[] V, bool Packed = false)
	{
		alias Ctx context;
		LLVMValueRef* ConstantVals = construct!LLVMValueRef(V.length);

		foreach(i; 0 .. V.length)
		{
			ConstantVals[i] = V[i].cref;
		}

		/+ As can be seen at http://llvm.org/docs/doxygen/html/Constants_8cpp_source.html#l00874
		+ LLVM may either copy the pointers contained in ConstantVals (in which case we
		+ should deallocate it after the call to the C API), or remember ConstantVals itself
		+ - by adding it to a map as a value - (in which case we could only deallocate it when
		+ the current LLVMContext gets destroyed, as there is no way to know for sure when LLVM
		+ loses its last reference to ConstantVals at an earlier time).
		+ Because there is no way to know here which of the two possibilities will happen, we
		+ have to assume the latter (remember it until the current LLVMContext dies).
		+/
		if(ConstantVals !is null)
		{
			context.treatAsImmutable!LLVMValueRef(ConstantVals);
		}

		auto _cref = LLVMConstStructInContext(context.cref, ConstantVals, to!uint(V.length), to!LLVMBool(Packed));
		auto type = LLVMTypeRef_to_Type(context, LLVMTypeOf(_cref));

		return new ConstantStruct(type, _cref);
	}

	public static StructType getTypeForElements(Constant V[], bool Packed = false)
	in
	{
		assert(V.length > 0, "ConstantStruct.getTypeForElements cannot be called on empty list");
	}
	body
	{
		return ConstantStruct.getTypeForElements(V[0].getContext(), V, Packed);
	}

	public static StructType getTypeForElements(LLVMContext Ctx, Constant V[], bool Packed = false)
	{
		Type[] EltTypes;
		EltTypes.length = V.length;

		foreach(i; 0 .. V.length)
		{
			EltTypes[i] = V[i].getType();
		}

		return StructType.get(Ctx, EltTypes, Packed);
	}
}

class ConstantVector : Constant
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	public override VectorType getType()
	{
		return cast(VectorType) Value.getType();
	}

	public Constant getSplatValue()
	{
		// Check out first element.
		Constant Elt = cast(Constant) getOperand(0);
		// Then make sure all remaining elements point to the same value.
		foreach(uint I; 1 .. getNumOperands())
		{
			if(getOperand(I) != Elt)
			{
				return null;
			}
		}

		return Elt;
	}

	// virtual void 	destroyConstant ()
	// virtual void 	replaceUsesOfWithOnConstant (Value *From, Value *To, Use *U)

	public static Constant get(Constant[] V)
	in
	{
		assert(V.length > 0, "Vectors can't be empty");
	}
	body
	{
		LLVMValueRef* ScalarConstantVals = construct!LLVMValueRef(V.length);

		foreach(i; 0 .. V.length)
		{
			ScalarConstantVals[i] = V[i].cref;
		}

		/+ As can be seen at http://llvm.org/docs/doxygen/html/Constants_8cpp_source.html#l00923
		 + LLVM may either copy the pointers contained in ScalarConstantVals (in which case we
		 + should deallocate it after the call to the C API), or remember ScalarConstantVals itself
		 + - by adding it to a map as a value - (in which case we could only deallocate it when
		 + the current LLVMContext gets destroyed, as there is no way to know for sure when LLVM
		 + loses its last reference to ScalarConstantVals at an earlier time).
		 + Because there is no way to know here which of the two possibilities will happen, we
		 + have to assume the latter (remember it until the current LLVMContext dies).
		 +/
		LLVMContext context = V[0].getContext();
		context.treatAsImmutable!LLVMValueRef(ScalarConstantVals);

		auto _cref = LLVMConstVector(ScalarConstantVals, to!uint(V.length));
		auto type = LLVMTypeRef_to_Type(context, LLVMTypeOf(_cref));

		return new ConstantVector(type, _cref);
	}

	/+public static Constant getSplat(uint NumElts, Constant V)
	{
		// If this splat is compatible with ConstantDataVector, use it instead of
		// ConstantVector.
		if((is(V : ConstantFP) || is(V : ConstantInt)) &&
		   ConstantDataSequential.isElementTypeCompatible(V.getType()))
		  return ConstantDataVector.getSplat(NumElts, V);
		
		Constant[] Elts;
		Elts.length = 32;
		foreach(i; 0 .. Elts.length)
		{
			Elts[i] = V;
		}

		return get(Elts);
	}+/
}

class ConstantAggregateZero : Constant
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	// virtual void 	destroyConstant ()

	// Constant * 	getSequentialElement () const
	public Constant getSequentialElement()
	{
		return Constant.getNullValue(this.getType().getSequentialElementType());
	}

	// Constant * 	getStructElement (unsigned Elt) const
	public Constant getStructElement(uint Elt)
	{
		return Constant.getNullValue(this.getType().getStructElementType(Elt));
	}

	// Constant * 	getElementValue (Constant *C) const
	/+ public const Constant getElementValue(Constant C)
	{
		if(is(this.getType() : SequentialType))
		{
			return this.getSequentialElement();
		}

		return this.getStructElement((cast(ConstantInt) C).getZExtValue());
	}+/

	// Constant * 	getElementValue (unsigned Idx) const
	public Constant getElementValue(uint Idx)
	{
		if(is(this.type : SequentialType))
		{
			return this.getSequentialElement();
		}

		return this.getStructElement(Idx);
	}

	// static ConstantAggregateZero * 	get (Type *Ty)
	public static ConstantAggregateZero get(Type Ty)
	in
	{
		assert(Ty.isStructTy() || Ty.isArrayTy() || Ty.isVectorTy(),
		       "Cannot create an aggregate zero of non-aggregate type!");
	}
	body
	{
		return cast(ConstantAggregateZero) Constant.getNullValue(Ty);
	}
}

class ConstantArray : Constant
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	// DECLARE_TRANSPARENT_OPERAND_ACCESSORS (Constant)

	// ArrayType * 	getType () const
	public override ArrayType getType()
	{
		return cast(ArrayType) Value.getType();
	}

	// virtual void 	destroyConstant ()
	// virtual void 	replaceUsesOfWithOnConstant (Value *From, Value *To, Use *U)

	// static Constant * 	get (ArrayType *T, ArrayRef< Constant * > V)
	public static Constant get(ArrayType T, Constant[] V)
	{
		auto elements = construct!LLVMValueRef(V.length);
		foreach(i; 0 .. V.length)
		{
			elements[i] = V[i].cref;
		}

		auto constant = LLVMConstArray(T.getElementType().cref, elements, cast(uint) V.length);
		if(elements !is null)
		{
			destruct(elements);
		}

		return new ConstantArray(T,	constant);
	}
}

class ConstantExpr : Constant
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	// DECLARE_TRANSPARENT_OPERAND_ACCESSORS (Constant)

	// bool 	isCast () const
	// bool 	isCompare () const
	// bool 	hasIndices () const
	// bool 	isGEPWithNoNotionalOverIndexing () const
	// unsigned 	getOpcode () const
	// unsigned 	getPredicate () const
	// ArrayRef< unsigned > 	getIndices () const
	// const char * 	getOpcodeName () const
	// Constant * 	getWithOperandReplaced (unsigned OpNo, Constant *Op) const
	// Constant * 	getWithOperands (ArrayRef< Constant * > Ops) const
	// Constant * 	getWithOperands (ArrayRef< Constant * > Ops, Type *Ty) const
	// Instruction * 	getAsInstruction ()
	// virtual void 	destroyConstant ()
	// virtual void 	replaceUsesOfWithOnConstant (Value *From, Value *To, Use *U)

	// static Constant * 	getAlignOf (Type *Ty)
	public static Constant getAlignOf(Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(Ty.getContext(), LLVMAlignOf(Ty.cref));
	}

	// static Constant * 	getSizeOf (Type *Ty)
	public static Constant getSizeOf(Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(Ty.getContext(), LLVMSizeOf(Ty.cref));
	}

	// static Constant * 	getOffsetOf (StructType *STy, unsigned FieldNo)
	// static Constant * 	getOffsetOf (Type *Ty, Constant *FieldNo)

	// static Constant * 	getNeg (Constant *C, bool HasNUW=false, bool HasNSW=false)
	public static Constant getNeg(Constant C, bool HasNUW=false, bool HasNSW=false)
	in
	{
		assert(!(HasNUW && HasNSW), "LLVM-C has no wrapper for both 'HasNUW' and 'HasNSW' being true");
	}
	body
	{
		if(HasNUW)
		{
			return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstNUWNeg(C.cref));
		}
		else if(HasNSW)
		{
			return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstNSWNeg(C.cref));
		}

		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstNeg(C.cref));
	}

	// static Constant * 	getFNeg (Constant *C)
	public static Constant getFNeg(Constant C)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstFNeg(C.cref));
	}

	// static Constant * 	getNot (Constant *C)
	public static Constant getNot(Constant C)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstNot(C.cref));
	}

	// static Constant * 	getAdd (Constant *C1, Constant *C2, bool HasNUW=false, bool HasNSW=false)
	public static Constant getAdd(Constant C1, Constant C2, bool HasNUW=false, bool HasNSW=false)
	in
	{
		assert(!(HasNUW && HasNSW), "LLVM-C has no wrapper for both 'HasNUW' and 'HasNSW' being true");
	}
	body
	{
		if(HasNUW)
		{
			return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstNUWAdd(C1.cref, C2.cref));
		}
		else if(HasNSW)
		{
			return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstNSWAdd(C1.cref, C2.cref));
		}
		
		return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstAdd(C1.cref, C2.cref));
	}

	// static Constant * 	getFAdd (Constant *C1, Constant *C2)
	public static Constant getFAdd(Constant C1, Constant C2)
	{
		return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstFAdd(C1.cref, C2.cref));
	}

	// static Constant * 	getSub (Constant *C1, Constant *C2, bool HasNUW=false, bool HasNSW=false)
	public static Constant getSub(Constant C1, Constant C2, bool HasNUW=false, bool HasNSW=false)
	in
	{
		assert(!(HasNUW && HasNSW), "LLVM-C has no wrapper for both 'HasNUW' and 'HasNSW' being true");
	}
	body
	{
		if(HasNUW)
		{
			return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstNUWSub(C1.cref, C2.cref));
		}
		else if(HasNSW)
		{
			return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstNSWSub(C1.cref, C2.cref));
		}
		
		return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstSub(C1.cref, C2.cref));
	}

	// static Constant * 	getFSub (Constant *C1, Constant *C2)
	public static Constant getFSub(Constant C1, Constant C2)
	{
		return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstFSub(C1.cref, C2.cref));
	}

	// static Constant * 	getMul (Constant *C1, Constant *C2, bool HasNUW=false, bool HasNSW=false)
	public static Constant getMul(Constant C1, Constant C2, bool HasNUW=false, bool HasNSW=false)
	in
	{
		assert(!(HasNUW && HasNSW), "LLVM-C has no wrapper for both 'HasNUW' and 'HasNSW' being true");
	}
	body
	{
		if(HasNUW)
		{
			return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstNUWMul(C1.cref, C2.cref));
		}
		else if(HasNSW)
		{
			return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstNSWMul(C1.cref, C2.cref));
		}
		
		return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstMul(C1.cref, C2.cref));
	}

	// static Constant * 	getFMul (Constant *C1, Constant *C2)
	public static Constant getFMul(Constant C1, Constant C2)
	{
		return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstFMul(C1.cref, C2.cref));
	}

	// static Constant * 	getUDiv (Constant *C1, Constant *C2, bool isExact=false)
	public static Constant getUDiv(Constant C1, Constant C2)
	{
		return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstUDiv(C1.cref, C2.cref));
	}

	// static Constant * 	getSDiv (Constant *C1, Constant *C2, bool isExact=false)
	public static Constant getSDiv(Constant C1, Constant C2, bool isExact=false)
	{
		if(isExact)
		{
			return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstExactSDiv(C1.cref, C2.cref));
		}
		
		return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstSDiv(C1.cref, C2.cref));
	}

	// static Constant * 	getFDiv (Constant *C1, Constant *C2)
	public static Constant getFDiv(Constant C1, Constant C2)
	{
		return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstFDiv(C1.cref, C2.cref));
	}

	// static Constant * 	getURem (Constant *C1, Constant *C2)
	public static Constant getURem(Constant C1, Constant C2)
	{
		return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstURem(C1.cref, C2.cref));
	}

	// static Constant * 	getSRem (Constant *C1, Constant *C2)
	public static Constant getSRem(Constant C1, Constant C2)
	{
		return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstSRem(C1.cref, C2.cref));
	}

	// static Constant * 	getFRem (Constant *C1, Constant *C2)
	public static Constant getFRem(Constant C1, Constant C2)
	{
		return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstFRem(C1.cref, C2.cref));
	}

	// static Constant * 	getAnd (Constant *C1, Constant *C2)
	public static Constant getAnd(Constant C1, Constant C2)
	{
		return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstAnd(C1.cref, C2.cref));
	}

	// static Constant * 	getOr (Constant *C1, Constant *C2)
	public static Constant getOr(Constant C1, Constant C2)
	{
		return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstOr(C1.cref, C2.cref));
	}

	// static Constant * 	getXor (Constant *C1, Constant *C2)
	public static Constant getXor(Constant C1, Constant C2)
	{
		return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstXor(C1.cref, C2.cref));
	}

	// static Constant * 	getShl (Constant *C1, Constant *C2, bool HasNUW=false, bool HasNSW=false)
	public static Constant getShl(Constant C1, Constant C2)
	{
		return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstShl(C1.cref, C2.cref));
	}

	// static Constant * 	getLShr (Constant *C1, Constant *C2, bool isExact=false)
	public static Constant getLShr(Constant C1, Constant C2)
	{
		return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstLShr(C1.cref, C2.cref));
	}

	// static Constant * 	getAShr (Constant *C1, Constant *C2, bool isExact=false)
	public static Constant getAShr(Constant C1, Constant C2)
	{
		return cast(Constant) LLVMValueRef_to_Value(C1.getContext(), LLVMConstAShr(C1.cref, C2.cref));
	}

	// static Constant * 	getTrunc (Constant *C, Type *Ty)
	public static Constant getTrunc(Constant C, Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstTrunc(C.cref, Ty.cref));
	}

	// static Constant * 	getSExt (Constant *C, Type *Ty)
	public static Constant getSExt(Constant C, Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstSExt(C.cref, Ty.cref));
	}

	// static Constant * 	getZExt (Constant *C, Type *Ty)
	public static Constant getZExt(Constant C, Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstZExt(C.cref, Ty.cref));
	}

	// static Constant * 	getFPTrunc (Constant *C, Type *Ty)
	public static Constant getFPTrunc(Constant C, Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstFPTrunc(C.cref, Ty.cref));
	}

	// static Constant * 	getFPExtend (Constant *C, Type *Ty)
	public static Constant getFPExtend(Constant C, Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstFPExt(C.cref, Ty.cref));
	}

	// static Constant * 	getUIToFP (Constant *C, Type *Ty)
	public static Constant getUIToFP(Constant C, Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstUIToFP(C.cref, Ty.cref));
	}

	// static Constant * 	getSIToFP (Constant *C, Type *Ty)
	public static Constant getSIToFP(Constant C, Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstSIToFP(C.cref, Ty.cref));
	}

	// static Constant * 	getFPToUI (Constant *C, Type *Ty)
	public static Constant getFPToUI(Constant C, Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstFPToUI(C.cref, Ty.cref));
	}

	// static Constant * 	getFPToSI (Constant *C, Type *Ty)
	public static Constant getFPToSI(Constant C, Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstFPToSI(C.cref, Ty.cref));
	}

	// static Constant * 	getPtrToInt (Constant *C, Type *Ty)
	public static Constant getPtrToInt(Constant C, Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstPtrToInt(C.cref, Ty.cref));
	}

	// static Constant * 	getIntToPtr (Constant *C, Type *Ty)
	public static Constant getIntToPtr(Constant C, Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstIntToPtr(C.cref, Ty.cref));
	}

	// static Constant * 	getBitCast (Constant *C, Type *Ty)
	public static Constant getBitCast(Constant C, Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstBitCast(C.cref, Ty.cref));
	}

	// static Constant * 	getNSWNeg (Constant *C)
	public static Constant getNSWNeg(Constant C)
	{
		return ConstantExpr.getNeg(C, false, true);
	}

	// static Constant * 	getNUWNeg (Constant *C)
	public static Constant getNUWNeg(Constant C)
	{
		return ConstantExpr.getNeg(C, true, false);
	}

	// static Constant * 	getNSWAdd (Constant *C1, Constant *C2)
	public static Constant getNSWAdd(Constant C1, Constant C2)
	{
		return ConstantExpr.getAdd(C1, C2, false, true);
	}

	// static Constant * 	getNUWAdd (Constant *C1, Constant *C2)
	public static Constant getNUWAdd(Constant C1, Constant C2)
	{
		return ConstantExpr.getAdd(C1, C2, true, false);
	}

	// static Constant * 	getNSWSub (Constant *C1, Constant *C2)
	public static Constant getNSWSub(Constant C1, Constant C2)
	{
		return ConstantExpr.getSub(C1, C2, false, true);
	}

	// static Constant * 	getNUWSub (Constant *C1, Constant *C2)
	public static Constant getNUWSub(Constant C1, Constant C2)
	{
		return ConstantExpr.getSub(C1, C2, true, false);
	}

	// static Constant * 	getNSWMul (Constant *C1, Constant *C2)
	public static Constant getNSWMul(Constant C1, Constant C2)
	{
		return ConstantExpr.getMul(C1, C2, false, true);
	}

	// static Constant * 	getNUWMul (Constant *C1, Constant *C2)
	public static Constant getNUWMul(Constant C1, Constant C2)
	{
		return ConstantExpr.getMul(C1, C2, true, false);
	}

	// static Constant * 	getNSWShl (Constant *C1, Constant *C2)
	// static Constant * 	getNUWShl (Constant *C1, Constant *C2)

	// static Constant * 	getExactSDiv (Constant *C1, Constant *C2)
	public static Constant getExactSDiv(Constant C1, Constant C2)
	{
		return ConstantExpr.getSDiv(C1, C2, true);
	}

	// static Constant * 	getExactUDiv (Constant *C1, Constant *C2)
	// static Constant * 	getExactAShr (Constant *C1, Constant *C2)
	// static Constant * 	getExactLShr (Constant *C1, Constant *C2)
	// static Constant * 	getBinOpIdentity (unsigned Opcode, Type *Ty)
	// static Constant * 	getBinOpAbsorber (unsigned Opcode, Type *Ty)
	// static Constant * 	getCast (unsigned ops, Constant *C, Type *Ty)

	// static Constant * 	getZExtOrBitCast (Constant *C, Type *Ty)
	public static Constant getZExtOrBitCast(Constant C, Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstZExtOrBitCast(C.cref, Ty.cref));
	}

	// static Constant * 	getSExtOrBitCast (Constant *C, Type *Ty)
	public static Constant getSExtOrBitCast(Constant C, Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstSExtOrBitCast(C.cref, Ty.cref));
	}

	// static Constant * 	getTruncOrBitCast (Constant *C, Type *Ty)
	public static Constant getTruncOrBitCast(Constant C, Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstTruncOrBitCast(C.cref, Ty.cref));
	}

	// static Constant * 	getPointerCast (Constant *C, Type *Ty)
	public static Constant getPointerCast(Constant C, Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstPointerCast(C.cref, Ty.cref));
	}

	// static Constant * 	getIntegerCast (Constant *C, Type *Ty, bool isSigned)
	public static Constant getIntegerCast(Constant C, Type Ty, bool isSigned)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstIntCast(C.cref, Ty.cref, cast(LLVMBool) isSigned));
	}

	// static Constant * 	getFPCast (Constant *C, Type *Ty)
	public static Constant getFPCast(Constant C, Type Ty)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstFPCast(C.cref, Ty.cref));
	}

	// static Constant * 	getSelect (Constant *C, Constant *V1, Constant *V2)
	public static Constant getSelect(Constant C, Constant V1, Constant V2)
	{
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstSelect(C.cref, V1.cref, V2.cref));
	}

	// static Constant * 	get (unsigned Opcode, Constant *C1, Constant *C2, unsigned Flags=0)
	// static Constant * 	getCompare (unsigned short pred, Constant *C1, Constant *C2)

	// static Constant * 	getICmp (unsigned short pred, Constant *LHS, Constant *RHS)
	public static Constant getICmp(LLVMIntPredicate pred, Constant LHS, Constant RHS)
	{
		return cast(Constant) LLVMValueRef_to_Value(LHS.getContext(), LLVMConstICmp(pred, LHS.cref, RHS.cref));
	}

	// static Constant * 	getFCmp (unsigned short pred, Constant *LHS, Constant *RHS)
	public static Constant getFCmp(LLVMRealPredicate pred, Constant LHS, Constant RHS)
	{
		return cast(Constant) LLVMValueRef_to_Value(LHS.getContext(), LLVMConstFCmp(pred, LHS.cref, RHS.cref));
	}

	// static Constant * 	getGetElementPtr (Constant *C, ArrayRef< Constant * > IdxList, bool InBounds=false)
	// static Constant * 	getGetElementPtr (Constant *C, Constant *Idx, bool InBounds=false)
	// static Constant * 	getGetElementPtr (Constant *C, ArrayRef< Value * > IdxList, bool InBounds=false)
	public static Constant getGetElementPtr(Constant C, Constant[] IdxList, bool InBounds=false)
	{
		LLVMValueRef* IdxListVals = construct!LLVMValueRef(IdxList.length);
		
		foreach(i; 0 .. IdxList.length)
		{
			IdxListVals[i] = IdxList[i].cref;
		}
		
		/+ LLVM may either copy the pointers contained in ConstantVals (in which case we
		 + should deallocate it after the call to the C API), or remember ConstantVals itself
		 + - by adding it to a map as a value - (in which case we could only deallocate it when
		 + the current LLVMContext gets destroyed, as there is no way to know for sure when LLVM
		 + loses its last reference to ConstantVals at an earlier time).
		 + Because there is no way to know here which of the two possibilities will happen, we
		 + have to assume the latter (remember it until the current LLVMContext dies).
		 +/
		LLVMContext context = C.getContext();
		if(IdxListVals !is null)
		{
			context.treatAsImmutable!LLVMValueRef(IdxListVals);
		}

		if(InBounds)
		{
			return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstInBoundsGEP(C.cref, IdxListVals, cast(uint) IdxList.length));
		}
		
		return cast(Constant) LLVMValueRef_to_Value(C.getContext(), LLVMConstGEP(C.cref, IdxListVals, cast(uint) IdxList.length));
	}

	// static Constant * 	getInBoundsGetElementPtr (Constant *C, ArrayRef< Constant * > IdxList)
	// static Constant * 	getInBoundsGetElementPtr (Constant *C, Constant *Idx)
	// static Constant * 	getInBoundsGetElementPtr (Constant *C, ArrayRef< Value * > IdxList)
	public static Constant getInBoundsGetElementPtr(Constant C, Constant[] IdxList)
	{
		return ConstantExpr.getGetElementPtr(C, IdxList, true);
	}

	// static Constant * 	getExtractElement (Constant *Vec, Constant *Idx)
	public static Constant getExtractElement(Constant Vec, Constant Idx)
	{
		return cast(Constant) LLVMValueRef_to_Value(Vec.getContext(), LLVMConstExtractElement(Vec.cref, Idx.cref));
	}

	// static Constant * 	getInsertElement (Constant *Vec, Constant *Elt, Constant *Idx)
	public static Constant getInsertElement(Constant Vec, Constant Elt, Constant Idx)
	{
		return cast(Constant) LLVMValueRef_to_Value(Vec.getContext(), LLVMConstInsertElement(Vec.cref, Elt.cref, Idx.cref));
	}

	// static Constant * 	getShuffleVector (Constant *V1, Constant *V2, Constant *Mask)
	public static Constant getInsertElement(Constant V1, Constant V2, Constant Mask)
	{
		return cast(Constant) LLVMValueRef_to_Value(V1.getContext(), LLVMConstShuffleVector(V1.cref, V2.cref, Mask.cref));
	}

	// static Constant * 	getExtractValue (Constant *Agg, ArrayRef< unsigned > Idxs)
	public static Constant getExtractValue(Constant Agg, uint[] IdxList)
	{
		uint[] IdxListVals = IdxList.dup;
		
		/+ LLVM may either copy the integers contained in IdxList (in which case we
		 + should deallocate it after the call to the C API), or remember IdxList itself
		 + - by adding it to a map as a value - (in which case we could only deallocate it when
		 + the current LLVMContext gets destroyed, as there is no way to know for sure when LLVM
		 + loses its last reference to ConstantVals at an earlier time).
		 + Because there is no way to know here which of the two possibilities will happen, we
		 + have to assume the latter (remember it until the current LLVMContext dies).
		 +/
		LLVMContext context = Agg.getContext();
		if(IdxListVals.length > 0)
		{
			context.treatAsImmutable!uint(IdxListVals);
		}
		
		return cast(Constant) LLVMValueRef_to_Value(Agg.getContext(), LLVMConstExtractValue(Agg.cref, IdxListVals.ptr, cast(uint) IdxList.length));
	}

	// static Constant * 	getInsertValue (Constant *Agg, Constant *Val, ArrayRef< unsigned > Idxs)
	public static Constant getInsertValue(Constant Agg, Constant Val, uint[] IdxList)
	{
		uint[] IdxListVals = IdxList.dup;
		
		/+ LLVM may either copy the integers contained in IdxList (in which case we
		 + should deallocate it after the call to the C API), or remember IdxList itself
		 + - by adding it to a map as a value - (in which case we could only deallocate it when
		 + the current LLVMContext gets destroyed, as there is no way to know for sure when LLVM
		 + loses its last reference to ConstantVals at an earlier time).
		 + Because there is no way to know here which of the two possibilities will happen, we
		 + have to assume the latter (remember it until the current LLVMContext dies).
		 +/
		LLVMContext context = Agg.getContext();
		if(IdxListVals.length > 0)
		{
			context.treatAsImmutable!uint(IdxListVals);
		}
		
		return cast(Constant) LLVMValueRef_to_Value(Agg.getContext(), LLVMConstInsertValue(Agg.cref, Val.cref, IdxListVals.ptr, cast(uint) IdxList.length));
	}
}
