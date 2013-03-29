
module llvm.d.ir.type;

private
{
	import llvm.d.llvm_c;

	import llvm.d.ir.llvmcontext;
	import llvm.d.ir.derivedtypes;
}

enum TypeID : LLVMTypeKind
{
	Void = LLVMVoidTypeKind,
	Half = LLVMHalfTypeKind,
	Float = LLVMFloatTypeKind,
	Double = LLVMDoubleTypeKind,
	X86_FP80T = LLVMX86_FP80TypeKind,
	FP128 = LLVMFP128TypeKind,
	PPC_FP128 = LLVMPPC_FP128TypeKind,
	Label = LLVMLabelTypeKind,
	Metadata = LLVMMetadataTypeKind,
	X86_MMX = LLVMX86_MMXTypeKind,
	Integer = LLVMIntegerTypeKind,
	Function = LLVMFunctionTypeKind,
	Struct = LLVMStructTypeKind,
	Array = LLVMArrayTypeKind,
	Pointer = LLVMPointerTypeKind,
	Vector = LLVMVectorTypeKind,
	
	NumTypeIDs/+,
	Doesn't work, because the items
	of LLVMTypeKind are not properly ordered
	the way the original items of TypeID are.
	LastPrimitive = X86_MMX,
	FirstDerived = Integer+/
}

class Type
{
	protected LLVMTypeRef _cref = null;
	package LLVMContext context = null;

	@property
	LLVMTypeRef cref() { return this._cref; }

	override public bool opEquals(Object obj)
	{
		return is(obj : Type) &&
			((cast(Type) obj)._cref == this._cref);
	}

	package this(LLVMContext C, LLVMTypeRef _cref)
	{
		this.context = C;
		this._cref = _cref;
	}
	
	package this(LLVMContext C, TypeID tid)
	{
		this.context = C;
		auto type = getPrimitiveType(C, tid);
		this._cref = type._cref;
	}
	
	private bool isSizedDerivedType()
	{
		if(this.isIntegerTy())
		{
			return true;
		}
		
		if(is(this : ArrayType))
		{
			return (cast(ArrayType) this).getElementType().isSized();
		}
		
		if(is(this : VectorType))
		{
			return (cast(VectorType) this).getElementType().isSized();
		}
		
		if(is(this : StructType))
		{
			return (cast(StructType) this).isSized();
		}
		
		return false;
	}
	
	// void print(raw_ostream &O)
	// void dump()

	public LLVMContext getContext()
	{ return this.context; }

	public TypeID getTypeID()
	{ return cast(TypeID) LLVMGetTypeKind(this._cref); }

	public bool isVoidTy()
	{ return this.getTypeID() == TypeID.Void; }

	public bool isHalfTy()
	{ return this.getTypeID() == TypeID.Half; }

	public bool isFloatTy()
	{ return this.getTypeID() == TypeID.Float; }

	public bool isDoubleTy()
	{ return this.getTypeID() == TypeID.Double; }

	public bool isX86_FP80Ty()
	{ return this.getTypeID() == TypeID.X86_MMX; }

	public bool isFP128Ty()
	{ return this.getTypeID() == TypeID.FP128; }

	public bool isPPC_FP128Ty()
	{ return this.getTypeID() == TypeID.PPC_FP128; }

	public bool isFloatingPointTy()
	{
		auto typeID = this.getTypeID();
		return (typeID == TypeID.Half) ||
		       (typeID == TypeID.Float) ||
		       (typeID == TypeID.Double) ||
		       (typeID == TypeID.X86_FP80T) ||
		       (typeID == TypeID.FP128) ||
		       (typeID == TypeID.PPC_FP128);
	}
	
	// const fltSemantics& getFltSemantics()

	public bool isX86_MMXTy()
	{ return this.getTypeID() == TypeID.X86_MMX; }
	
	public bool isFPOrFPVectorTy()
	{ return this.getScalarType().isFloatingPointTy(); }

	public bool isLabelTy()
	{ return this.getTypeID() == TypeID.Label; }

	public bool isMetadataTy()
	{ return this.getTypeID() == TypeID.Metadata; }

	public bool isIntegerTy()
	{ return this.getTypeID() == TypeID.Integer; }

	public bool isIntegerTy(uint Bitwidth)
	{ return is(this : IntegerType) && (cast(IntegerType) this).getBitWidth() == Bitwidth; }
	
	public bool isIntOrIntVectorTy()
	{ return this.getScalarType().isIntegerTy(); }

	public bool isFunctionTy()
	{ return this.getTypeID() == TypeID.Function; }
	
	public bool isStructTy()
	{ return this.getTypeID() == TypeID.Struct; }
	
	public bool isArrayTy()
	{ return this.getTypeID() == TypeID.Array; }
	
	public bool isPointerTy()
	{ return this.getTypeID() == TypeID.Pointer; }
	
	public bool isPtrOrPtrVectorTy()
	{ return this.getScalarType().isPointerTy(); }
	
	public bool isVectorTy()
	{ return this.getTypeID() == TypeID.Vector; }
	
	public bool canLosslesslyBitCastTo(Type Ty)
	{
		// Identity cast means no change so return true
		if(this == Ty)
		{
			return true;
		}
		
		// They are not convertible unless they are at least first class types
		if(!this.isFirstClassType() || !Ty.isFirstClassType())
		{
			return false;
		}
		
		// Vector -> Vector conversions are always lossless if the two vector types
		// have the same size, otherwise not.  Also, 64-bit vector types can be
		// converted to x86mmx.
		if(is(this : VectorType))
		{
			if(is(Ty : VectorType))
			{
				return (cast(VectorType) this).getBitWidth() == (cast(VectorType) Ty).getBitWidth();
			}
			else if((Ty.getTypeID() == TypeID.X86_MMX) && ((cast(VectorType) this).getBitWidth() == 64))
			{
				return true;
			}
		}
		
		if((this.getTypeID() == TypeID.X86_MMX) &&
		   is(Ty : VectorType) &&
		   ((cast(VectorType) Ty).getBitWidth() == 64))
		{
			return true;
		}
		
		// At this point we have only various mismatches of the first class types
		// remaining and ptr->ptr. Just select the lossless conversions. Everything
		// else is not lossless.
		if(this.isPointerTy())
		{
			return Ty.isPointerTy();
		}
		
		// Other types have no identity values
		return false;
	}
	
	public bool isEmptyTy()
	{
		if(is(this : ArrayType))
		{
			auto ATy = cast(ArrayType) this;
			return (ATy.getNumElements() == 0) || ATy.getElementType().isEmptyTy();
		}
		
		if(is(this : StructType))
		{
			auto STy = cast(StructType) this;
			foreach(i; 0 .. STy.getNumElements())
			{
				if(!STy.getElementType(i).isEmptyTy())
				{
					return false;
				}
			}
			
			return true;
		}
		
		return false;
	}
	
	public bool isPrimitiveType()
	{
		auto type = this.getTypeID();
		return (type == TypeID.Void) ||
		       (type == TypeID.Half) ||
		       (type == TypeID.Float) ||
		       (type == TypeID.Double) ||
		       (type == TypeID.X86_FP80T) ||
		       (type == TypeID.FP128) ||
		       (type == TypeID.PPC_FP128) ||
		       (type == TypeID.Label) ||
		       (type == TypeID.Metadata) ||
		       (type == TypeID.X86_MMX);
	}
	
	public bool isDerivedType()
	{ return !this.isPrimitiveType(); }
	
	public bool isFirstClassType()
	{
		auto typeID = this.getTypeID();
		return (typeID != TypeID.Function) && (typeID != TypeID.Void);
	}
	
	public bool isSingleValueType()
	{
		auto typeID = this.getTypeID();
		return ((typeID != TypeID.Void) && this.isPrimitiveType()) ||
		       (typeID == TypeID.Integer) || (typeID == TypeID.Pointer) ||
		       (typeID == TypeID.Vector);
	}
	
	public bool isAggregateType()
	{
		auto typeID = this.getTypeID();
		return (typeID == TypeID.Struct) || (typeID == TypeID.Array);
	}

	public bool isSized()
	{
		auto typeID = this.getTypeID();
		// If it's a primitive, it is always sized.
		if((typeID == TypeID.Integer) || isFloatingPointTy() ||
		   (typeID == TypeID.Pointer) ||
		   (typeID == TypeID.X86_MMX))
		{
			return true;
		}
		
		// If it is not something that can have a size (e.g. a function or label),
		// it doesn't have a size.
		if((typeID != TypeID.Struct) && (typeID != TypeID.Array) &&
		   (typeID != TypeID.Vector))
		{
			return false;
		}
		
		// Otherwise we have to try harder to decide.
		return this.isSizedDerivedType();
	}
	
	public uint getPrimitiveSizeInBits()
	{
		switch(this.getTypeID())
		{
			case TypeID.Half: return 16;
			case TypeID.Float: return 32;
			case TypeID.Double: return 64;
			case TypeID.X86_FP80T: return 80;
			case TypeID.FP128: return 128;
			case TypeID.PPC_FP128: return 128;
			case TypeID.X86_MMX: return 64;
			case TypeID.Integer: return (cast(IntegerType) this).getBitWidth();
			case TypeID.Vector: return (cast(VectorType) this).getBitWidth();
			default: return 0;
		}
	}
	
	public uint getScalarSizeInBits()
	{ return this.getScalarType().getPrimitiveSizeInBits(); }

	public int getFPMantissaWidth()
	{
		if(is(this : VectorType))
		{
			return (cast(VectorType) this).getElementType().getFPMantissaWidth();
		}
		
		assert(this.isFloatingPointTy(), "Not a floating point type!");
		
		auto typeID = this.getTypeID();
		switch(typeID)
		{
			case TypeID.Half: return 11;
			case TypeID.Float: return 24;
			case TypeID.Double: return 53;
			case TypeID.X86_FP80T: return 64;
			case TypeID.FP128: return 113;
			case TypeID.PPC_FP128: return -1;
			default: assert(false, "unknown fp type");
		}
	}

	public Type getScalarType()
	{
		return is(this : VectorType) ?
			(cast(VectorType) this).getElementType() :
			this;
	}

	//subtype_iterator subtype_begin ()
	//subtype_iterator subtype_end ()
	//Type * getContainedType (unsigned i)
	//unsigned getNumContainedTypes ()

	public uint getIntegerBitWidth()
	in
	{
		assert(is(this : IntegerType), "Not integer type");
	}
	body
	{
		return (cast(IntegerType) this).getBitWidth();
	}

	public Type getFunctionParamType(uint i)
	in
	{
		assert(is(this : FunctionType), "Not function type");
	}
	body
	{
		return (cast(FunctionType) this).getParamType(i);
	}
	
	public uint getFunctionNumParams()
	in
	{
		assert(is(this : FunctionType), "Not function type");
	}
	body
	{
		return (cast(FunctionType) this).getNumParams();
	}

	public bool isFunctionVarArg()
	in
	{
		assert(is(this : FunctionType), "Not function type");
	}
	body
	{
		return cast(bool) (cast(FunctionType) this).isVarArg();
	}
	
	public string getStructName()
	in
	{
		assert(is(this : StructType), "Not struct type");
	}
	body
	{
		return (cast(StructType) this).getName();
	}
	
	public uint getStructNumElements()
	in
	{
		assert(is(this : StructType), "Not struct type");
	}
	body
	{
		return (cast(StructType) this).getStructNumElements();
	}
	
	public Type getStructElementType(uint N)
	in
	{
		assert(is(this : StructType), "Not struct type");
	}
	body
	{
		return (cast(StructType) this).getElementType(N);
	}
	
	public Type getSequentialElementType()
	in
	{
		assert(is(this : SequentialType), "Not sequential type");
	}
	body
	{
		return (cast(SequentialType) this).getElementType();
	}
	
	public ulong getArrayNumElements()
	in
	{
		assert(is(this : ArrayType), "Not array type");
	}
	body
	{
		return (cast(ArrayType) this).getArrayNumElements();
	}
	
	public Type getArrayElementType()
	in
	{
		assert(is(this : ArrayType), "Not array type");
	}
	body
	{
		return (cast(ArrayType) this).getArrayElementType();
	}

	public uint getVectorNumElements()
	in
	{
		assert(is(this : VectorType), "Not vector type");
	}
	body
	{
		return (cast(VectorType) this).getVectorNumElements();
	}

	public Type getVectorElementType()
	in
	{
		assert(is(this : VectorType), "Not vector type");
	}
	body
	{
		return (cast(VectorType) this).getVectorElementType();
	}
	
	public Type getPointerElementType()
	in
	{
		assert(is(this : VectorType), "Not pointer type");
	}
	body
	{
		return (cast(VectorType) this).getPointerElementType();
	}

	public uint getPointerAddressSpace()
	in
	{
		assert(is(this : PointerType), "Not pointer type");
	}
	body
	{
		return (cast(PointerType) this).getPointerAddressSpace();
	}

	public PointerType getPointerTo(uint AddrSpace = 0)
	in
	{
		assert(is(this : PointerType), "Not pointer type");
	}
	body
	{
		return (cast(PointerType) this).getPointerTo(AddrSpace);
	}

	static Type getPrimitiveType(LLVMContext C, TypeID IDNumber)
	{
		switch(IDNumber)
		{
			case TypeID.Void: return getVoidTy(C);
			case TypeID.Half: return getHalfTy(C);
			case TypeID.Float: return getFloatTy(C);
			case TypeID.Double: return getDoubleTy(C);
			case TypeID.X86_FP80T: return getX86_FP80Ty(C);
			case TypeID.FP128: return getFP128Ty(C);
			case TypeID.PPC_FP128: return getPPC_FP128Ty(C);
			case TypeID.Label: return getLabelTy(C);
			// "getMetadataTy" not implemented, LLVM C API function missing
			/+case Metadata: return getMetadataTy(C);+/
			case TypeID.X86_MMX: return getX86_MMXTy(C);
			default: return null;
		}
	}

	static Type getVoidTy(LLVMContext C)
	{ return new Type(C, LLVMVoidTypeInContext(C.cref)); }

	static Type getLabelTy(LLVMContext C)
	{ return new Type(C, LLVMLabelTypeInContext(C.cref)); }

	static Type getHalfTy(LLVMContext C)
	{ return new Type(C, LLVMHalfTypeInContext(C.cref)); }

	static Type getFloatTy(LLVMContext C)
	{ return new Type(C, LLVMFloatTypeInContext(C.cref)); }

	static Type getDoubleTy(LLVMContext C)
	{ return new Type(C, LLVMDoubleTypeInContext(C.cref)); }
	
	/+static Type getMetadataTy(LLVMContext C)
	{ return new Type(C, LLVMMetadataTypeInContext(C.cref)); }+/

	static Type getX86_FP80Ty(LLVMContext C)
	{ return new Type(C, LLVMX86FP80TypeInContext(C.cref)); }

	static Type getFP128Ty(LLVMContext C)
	{ return new Type(C, LLVMFP128TypeInContext(C.cref)); }

	static Type getPPC_FP128Ty(LLVMContext C)
	{ return new Type(C, LLVMPPCFP128TypeInContext(C.cref)); }

	static Type getX86_MMXTy(LLVMContext C)
	{ return new Type(C, LLVMX86MMXTypeInContext(C.cref)); }

	static Type getIntNTy(LLVMContext C, uint N)
	{ return new IntegerType(C, LLVMIntTypeInContext(C.cref, N)); }

	static Type getInt1Ty(LLVMContext C)
	{ return new IntegerType(C, LLVMInt1TypeInContext(C.cref)); }

	static Type getInt8Ty(LLVMContext C)
	{ return new IntegerType(C, LLVMInt8TypeInContext(C.cref)); }

	static Type getInt16Ty(LLVMContext C)
	{ return new IntegerType(C, LLVMInt16TypeInContext(C.cref)); }

	static Type getInt32Ty(LLVMContext C)
	{ return new IntegerType(C, LLVMInt32TypeInContext(C.cref)); }

	static Type getInt64Ty(LLVMContext C)
	{ return new IntegerType(C, LLVMInt64TypeInContext(C.cref)); }

	static Type getHalfPtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(C, LLVMPointerType(LLVMHalfTypeInContext(C.cref), AS)); }

	static Type getFloatPtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(C, LLVMPointerType(LLVMFloatTypeInContext(C.cref), AS)); }

	static Type getDoublePtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(C, LLVMPointerType(LLVMDoubleTypeInContext(C.cref), AS)); }

	static Type getX86_FP80PtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(C, LLVMPointerType(LLVMX86FP80TypeInContext(C.cref), AS)); }

	static Type getFP128PtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(C, LLVMPointerType(LLVMFP128TypeInContext(C.cref), AS)); }

	static Type getPPC_FP128PtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(C, LLVMPointerType(LLVMPPCFP128TypeInContext(C.cref), AS)); }

	static Type getX86_MMXPtrTy (LLVMContext C, uint AS = 0)
	{ return new Type(C, LLVMPointerType(LLVMX86MMXTypeInContext(C.cref), AS)); }

	static Type getIntNPtrTy(LLVMContext C, uint N, uint AS = 0)
	{ return new Type(C, LLVMPointerType(LLVMIntTypeInContext(C.cref, N), AS)); }

	static Type getInt1PtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(C, LLVMPointerType(LLVMInt1TypeInContext(C.cref), AS)); }

	static Type getInt8PtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(C, LLVMPointerType(LLVMInt8TypeInContext(C.cref), AS)); }

	static Type getInt16PtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(C, LLVMPointerType(LLVMInt16TypeInContext(C.cref), AS)); }

	static Type getInt32PtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(C, LLVMPointerType(LLVMInt32TypeInContext(C.cref), AS)); }

	static Type getInt64PtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(C, LLVMPointerType(LLVMInt64TypeInContext(C.cref), AS)); }
}


















