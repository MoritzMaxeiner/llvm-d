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
