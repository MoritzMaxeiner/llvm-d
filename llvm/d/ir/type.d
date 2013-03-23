
module llvm.d.ir.type;

private
{
	import llvm.d.llvm_c;

	import llvm.d.ir.llvmcontext;
	import llvm.d.ir.derivedtypes;
}

alias LLVMTypeKind TypeID;
enum : TypeID
{
	VoidTyID = LLVMVoidTypeKind,
	HalfTyID = LLVMHalfTypeKind,
	FloatTyID = LLVMFloatTypeKind,
	DoubleTyID = LLVMDoubleTypeKind,
	X86_FP80TyID = LLVMX86_FP80TypeKind,
	FP128TyID = LLVMFP128TypeKind,
	PPC_FP128TyID = LLVMPPC_FP128TypeKind,
	LabelTyID = LLVMLabelTypeKind,
	MetadataTyID = LLVMMetadataTypeKind,
	X86_MMXTyID = LLVMX86_MMXTypeKind,
	IntegerTyID = LLVMIntegerTypeKind,
	FunctionTyID = LLVMFunctionTypeKind,
	StructTyID = LLVMStructTypeKind,
	ArrayTyID = LLVMArrayTypeKind,
	PointerTyID = LLVMPointerTypeKind,
	VectorTyID = LLVMVectorTypeKind,
	
	NumTypeIDs/+,
	Doesn't work, because the items
	of LLVMTypeKind are not properly ordered
	the way the original items of TypeID are.
	LastPrimitiveTyID = X86_MMXTyID,
	FirstDerivedTyID = IntegerTyID+/
}

class Type
{
	protected LLVMTypeRef _cref = null;

	@property
	LLVMTypeRef cref() { return this._cref; }

	override public bool opEquals(Object obj)
	{
		return is(obj : Type) &&
			((cast(Type) obj)._cref == this._cref);
	}

	package this(LLVMTypeRef _cref)
	{
		this._cref = _cref;
	}
	
	package this(LLVMContext C, TypeID tid)
	{
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
	{ return new LLVMContext(LLVMGetTypeContext(this._cref)); }

	public TypeID getTypeID()
	{ return LLVMGetTypeKind(this._cref); }

	public bool isVoidTy()
	{ return this.getTypeID() == VoidTyID; }

	public bool isHalfTy()
	{ return this.getTypeID() == HalfTyID; }

	public bool isFloatTy()
	{ return this.getTypeID() == FloatTyID; }

	public bool isDoubleTy()
	{ return this.getTypeID() == DoubleTyID; }

	public bool isX86_FP80Ty()
	{ return this.getTypeID() == X86_MMXTyID; }

	public bool isFP128Ty()
	{ return this.getTypeID() == FP128TyID; }

	public bool isPPC_FP128Ty()
	{ return this.getTypeID() == PPC_FP128TyID; }

	public bool isFloatingPointTy()
	{
		auto typeID = this.getTypeID();
		return (typeID == HalfTyID) ||
		       (typeID == FloatTyID) ||
		       (typeID == DoubleTyID) ||
		       (typeID == X86_FP80TyID) ||
		       (typeID == FP128TyID) ||
		       (typeID == PPC_FP128TyID);
	}
	
	// const fltSemantics& getFltSemantics()

	public bool isX86_MMXTy()
	{ return this.getTypeID() == X86_MMXTyID; }
	
	public bool isFPOrFPVectorTy()
	{ return this.getScalarType().isFloatingPointTy(); }

	public bool isLabelTy()
	{ return this.getTypeID() == LabelTyID; }

	public bool isMetadataTy()
	{ return this.getTypeID() == MetadataTyID; }

	public bool isIntegerTy()
	{ return this.getTypeID() == IntegerTyID; }

	public bool isIntegerTy(uint Bitwidth)
	{ return is(this : IntegerType) && (cast(IntegerType) this).getBitWidth() == Bitwidth; }
	
	public bool isIntOrIntVectorTy()
	{ return this.getScalarType().isIntegerTy(); }

	public bool isFunctionTy()
	{ return this.getTypeID() == FunctionTyID; }
	
	public bool isStructTy()
	{ return this.getTypeID() == StructTyID; }
	
	public bool isArrayTy()
	{ return this.getTypeID() == ArrayTyID; }
	
	public bool isPointerTy()
	{ return this.getTypeID() == PointerTyID; }
	
	public bool isPtrOrPtrVectorTy()
	{ return this.getScalarType().isPointerTy(); }
	
	public bool isVectorTy()
	{ return this.getTypeID() == VectorTyID; }
	
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
			else if((Ty.getTypeID() == X86_MMXTyID) && ((cast(VectorType) this).getBitWidth() == 64))
			{
				return true;
			}
		}
		
		if((this.getTypeID() == X86_MMXTyID) &&
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
		return (type == VoidTyID) ||
		       (type == HalfTyID) ||
		       (type == FloatTyID) ||
		       (type == DoubleTyID) ||
		       (type == X86_FP80TyID) ||
		       (type == FP128TyID) ||
		       (type == PPC_FP128TyID) ||
		       (type == LabelTyID) ||
		       (type == MetadataTyID) ||
		       (type == X86_MMXTyID);
	}
	
	public bool isDerivedType()
	{ return !this.isPrimitiveType(); }
	
	public bool isFirstClassType()
	{
		auto typeID = this.getTypeID();
		return (typeID != FunctionTyID) && (typeID != VoidTyID);
	}
	
	public bool isSingleValueType()
	{
		auto typeID = this.getTypeID();
		return ((typeID != VoidTyID) && this.isPrimitiveType()) ||
		       (typeID == IntegerTyID) || (typeID == PointerTyID) ||
		       (typeID == VectorTyID);
	}
	
	public bool isAggregateType()
	{
		auto typeID = this.getTypeID();
		return (typeID == StructTyID) || (typeID == ArrayTyID);
	}

	public bool isSized()
	{
		auto typeID = this.getTypeID();
		// If it's a primitive, it is always sized.
		if((typeID == IntegerTyID) || isFloatingPointTy() ||
		   (typeID == PointerTyID) ||
		   (typeID == X86_MMXTyID))
		{
			return true;
		}
		
		// If it is not something that can have a size (e.g. a function or label),
		// it doesn't have a size.
		if((typeID != StructTyID) && (typeID != ArrayTyID) &&
		   (typeID != VectorTyID))
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
			case HalfTyID: return 16;
			case FloatTyID: return 32;
			case DoubleTyID: return 64;
			case X86_FP80TyID: return 80;
			case FP128TyID: return 128;
			case PPC_FP128TyID: return 128;
			case X86_MMXTyID: return 64;
			case IntegerTyID: return (cast(IntegerType) this).getBitWidth();
			case VectorTyID: return (cast(VectorType) this).getBitWidth();
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
			case HalfTyID: return 11;
			case FloatTyID: return 24;
			case DoubleTyID: return 53;
			case X86_FP80TyID: return 64;
			case FP128TyID: return 113;
			case PPC_FP128TyID: return -1;
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
	
	public Type getSequentialElementType(uint N)
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
			case VoidTyID: return getVoidTy(C);
			case HalfTyID: return getHalfTy(C);
			case FloatTyID: return getFloatTy(C);
			case DoubleTyID: return getDoubleTy(C);
			case X86_FP80TyID: return getX86_FP80Ty(C);
			case FP128TyID: return getFP128Ty(C);
			case PPC_FP128TyID: return getPPC_FP128Ty(C);
			case LabelTyID: return getLabelTy(C);
			// "getMetadataTy" not implemented, LLVM C API function missing
			/+case MetadataTyID: return getMetadataTy(C);+/
			case X86_MMXTyID: return getX86_MMXTy(C);
			default: return null;
		}
	}

	static Type getVoidTy(LLVMContext C)
	{ return new Type(LLVMVoidTypeInContext(C.cref)); }

	static Type getLabelTy(LLVMContext C)
	{ return new Type(LLVMLabelTypeInContext(C.cref)); }

	static Type getHalfTy(LLVMContext C)
	{ return new Type(LLVMHalfTypeInContext(C.cref)); }

	static Type getFloatTy(LLVMContext C)
	{ return new Type(LLVMFloatTypeInContext(C.cref)); }

	static Type getDoubleTy(LLVMContext C)
	{ return new Type(LLVMDoubleTypeInContext(C.cref)); }
	
	/+static Type getMetadataTy(LLVMContext C)
	{ return new Type(LLVMMetadataTypeInContext(C.cref)); }+/

	static Type getX86_FP80Ty(LLVMContext C)
	{ return new Type(LLVMX86FP80TypeInContext(C.cref)); }

	static Type getFP128Ty(LLVMContext C)
	{ return new Type(LLVMFP128TypeInContext(C.cref)); }

	static Type getPPC_FP128Ty(LLVMContext C)
	{ return new Type(LLVMPPCFP128TypeInContext(C.cref)); }

	static Type getX86_MMXTy(LLVMContext C)
	{ return new Type(LLVMX86MMXTypeInContext(C.cref)); }

	static Type getIntNTy(LLVMContext C, uint N)
	{ return new IntegerType(LLVMIntTypeInContext(C.cref, N)); }

	static Type getInt1Ty(LLVMContext C)
	{ return new IntegerType(LLVMInt1TypeInContext(C.cref)); }

	static Type getInt8Ty(LLVMContext C)
	{ return new IntegerType(LLVMInt8TypeInContext(C.cref)); }

	static Type getInt16Ty(LLVMContext C)
	{ return new IntegerType(LLVMInt16TypeInContext(C.cref)); }

	static Type getInt32Ty(LLVMContext C)
	{ return new IntegerType(LLVMInt32TypeInContext(C.cref)); }

	static Type getInt64Ty(LLVMContext C)
	{ return new IntegerType(LLVMInt64TypeInContext(C.cref)); }

	static Type getHalfPtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(LLVMPointerType(LLVMHalfTypeInContext(C.cref), AS)); }

	static Type getFloatPtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(LLVMPointerType(LLVMFloatTypeInContext(C.cref), AS)); }

	static Type getDoublePtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(LLVMPointerType(LLVMDoubleTypeInContext(C.cref), AS)); }

	static Type getX86_FP80PtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(LLVMPointerType(LLVMX86FP80TypeInContext(C.cref), AS)); }

	static Type getFP128PtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(LLVMPointerType(LLVMFP128TypeInContext(C.cref), AS)); }

	static Type getPPC_FP128PtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(LLVMPointerType(LLVMPPCFP128TypeInContext(C.cref), AS)); }

	static Type getX86_MMXPtrTy (LLVMContext C, uint AS = 0)
	{ return new Type(LLVMPointerType(LLVMX86MMXTypeInContext(C.cref), AS)); }

	static Type getIntNPtrTy(LLVMContext C, uint N, uint AS = 0)
	{ return new Type(LLVMPointerType(LLVMIntTypeInContext(C.cref, N), AS)); }

	static Type getInt1PtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(LLVMPointerType(LLVMInt1TypeInContext(C.cref), AS)); }

	static Type getInt8PtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(LLVMPointerType(LLVMInt8TypeInContext(C.cref), AS)); }

	static Type getInt16PtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(LLVMPointerType(LLVMInt16TypeInContext(C.cref), AS)); }

	static Type getInt32PtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(LLVMPointerType(LLVMInt32TypeInContext(C.cref), AS)); }

	static Type getInt64PtrTy(LLVMContext C, uint AS = 0)
	{ return new Type(LLVMPointerType(LLVMInt64TypeInContext(C.cref), AS)); }
}


















