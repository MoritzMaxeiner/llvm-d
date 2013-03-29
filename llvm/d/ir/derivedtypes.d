module llvm.d.ir.derivedtypes;

private
{
	import core.vararg;
	
	import llvm.util.memory;

	import llvm.d.llvm_c;
	
	import llvm.d.ir.llvmcontext;
	import llvm.d.ir.type;
}

class IntegerType : Type
{
	package this(LLVMContext C, LLVMTypeRef _cref)
	{
		super(C, _cref);
	}
	
	package this(LLVMContext C, uint NumBits)
	{
		super(C, LLVMIntTypeInContext(C.cref, NumBits));
	}

	public uint getBitWidth()
	{ return LLVMGetIntTypeWidth(this._cref); }
	
	public ulong getBitMask()
	{ return ~0UL >> (64 - this.getBitWidth()); }
	
	public ulong getSignBit()
	{ return 1UL << (this.getBitWidth() - 1); }
	
	public bool isPowerOf2ByteWidth()
	{ return (this.getBitWidth() % 2) == 0; }
	
	public static IntegerType get(LLVMContext C, uint NumBits)
	{ return new IntegerType(C, NumBits); }
}

class CompositeType : Type
{
	package this(LLVMContext C, LLVMTypeRef _cref)
	{
		super(C, _cref);
	}
	
	package this(LLVMContext C, TypeID tid)
	{
		super(C, tid);
	}
}

package Type LLVMTypeRef_to_Type(LLVMContext C, LLVMTypeRef type)
{
	auto typeID = LLVMGetTypeKind(type);
	
	switch(typeID)
	{
		case TypeID.Void: return new Type(C, type);
		case TypeID.Half: return new Type(C, type);
		case TypeID.Float: return new Type(C, type);
		case TypeID.Double: return new Type(C, type);
		case TypeID.X86_FP80T: return new Type(C, type);
		case TypeID.FP128: return new Type(C, type);
		case TypeID.PPC_FP128: return new Type(C, type);
		case TypeID.Label: return new Type(C, type);
		case TypeID.Metadata: return new Type(C, type);
		case TypeID.X86_MMX: return new Type(C, type); // new VectorType ???
		case TypeID.Integer: return new IntegerType(C, type);
		case TypeID.Function: return new FunctionType(C, type);
		case TypeID.Struct: return new StructType(C, type);
		case TypeID.Array: return new ArrayType(C, type);
		case TypeID.Pointer: return new PointerType(C, type);
		case TypeID.Vector: return new VectorType(C, type);
		default: return null;
	}
}

class SequentialType : CompositeType
{
	package this(LLVMContext C, LLVMTypeRef _cref)
	{
		super(C, _cref);
	}
	
	package this(LLVMContext C, TypeID TID, Type ElType)
	{
		super(ElType.getContext(), TID);
	}
	
	public Type getElementType()
	{
		auto type = LLVMGetElementType(this._cref);
		return LLVMTypeRef_to_Type(this.context, type);
	}
}

class VectorType : SequentialType
{
	package this(LLVMContext C, LLVMTypeRef _cref)
	{
		super(C, _cref);
	}
	
	public uint getNumElements()
	{ return LLVMGetVectorSize(this._cref); }
	
	public uint getBitWidth()
	{
		return this.getNumElements() * this.getElementType().getPrimitiveSizeInBits();
	}
	
	public static VectorType get(Type ElementType, uint NumElements)
	{
		return new VectorType(ElementType.context, LLVMVectorType(ElementType.cref, NumElements));
	}
	
	public static VectorType getInteger(VectorType VTy)
	{
		auto EltBits = VTy.getElementType().getPrimitiveSizeInBits();
		assert(EltBits > 0, "Element size must be of a non-zero size");
		auto EltTy = IntegerType.get(VTy.getContext(), EltBits);
		return VectorType.get(EltTy, VTy.getNumElements());
	}
	
	public static VectorType getExtendedElementVectorType(VectorType VTy)
	{
		auto EltBits = VTy.getElementType().getPrimitiveSizeInBits();
		assert(EltBits > 0, "Element size must be of a non-zero size");
		auto EltTy = IntegerType.get(VTy.getContext(), EltBits * 2);
		return VectorType.get(EltTy, VTy.getNumElements());
	}
	
	public static VectorType getTruncatedElementVectorType(VectorType VTy)
	{
		auto EltBits = VTy.getElementType().getPrimitiveSizeInBits();
		assert(EltBits > 0, "Element size must be of a non-zero size");
		assert((EltBits & 1) == 0, "Cannot truncate vector element with odd bit-width");
		auto EltTy = IntegerType.get(VTy.getContext(), EltBits / 2);
		return VectorType.get(EltTy, VTy.getNumElements());
	}
	
	public static bool isValidElementType(Type ElemTy)
	{
		return ElemTy.isIntegerTy() || ElemTy.isFloatingPointTy() || ElemTy.isPointerTy();
	}
}

enum AddressSpace : uint
{
	Generic = 0,
	Global = 1,
	ConstNotGen = 2, // Not part of generic space
	Shared = 3,
	Const = 4,
	Local = 5,
	
	// NVVM Internal
	Param = 101
}

class PointerType : SequentialType
{
	package this(LLVMContext C, LLVMTypeRef _cref)
	{
		super(C, _cref);
	}
	
	public AddressSpace getAddressSpace()
	{ return cast(AddressSpace) LLVMGetPointerAddressSpace(this._cref); }
	
	public static PointerType get(Type ElementType, AddressSpace AddrSpace)
	{
		return new PointerType(ElementType.context, LLVMPointerType(ElementType.cref, AddrSpace));
	}
	
	public static PointerType getUnqual(Type ElementType)
	{
		return PointerType.get(ElementType, AddressSpace.Generic);
	}
	
	public static bool isValidElementType(Type ElemTy)
	{
		return !ElemTy.isVoidTy() && !ElemTy.isLabelTy() && !ElemTy.isMetadataTy();
	}
}

class ArrayType : SequentialType
{
	package this(LLVMContext C, LLVMTypeRef _cref)
	{
		super(C, _cref);
	}
	
	public uint getNumElements()
	{ return LLVMGetArrayLength(this._cref); }
	
	public static ArrayType get(Type ElementType, uint NumElements)
	{
		return new ArrayType(ElementType.context, LLVMArrayType(ElementType.cref, NumElements));
	}
	
	public static bool isValidElementType(Type ElemTy)
	{
		return !ElemTy.isVoidTy() && !ElemTy.isLabelTy() &&
		       !ElemTy.isMetadataTy() && !ElemTy.isFunctionTy();
	}
}

class StructType : CompositeType
{
	package this(LLVMContext C, LLVMTypeRef _cref)
	{
		super(C, _cref);
	}
	
	public bool isPacked()
	{ return cast(bool) LLVMIsPackedStruct(this._cref); }
	
	// bool isLiteral ()
	
	public bool isOpaque()
	{ return cast(bool) LLVMIsOpaqueStruct(this._cref); }
	
	// bool isSized ()
	
	public bool hasName()
	{ return LLVMGetStructName(this._cref) !is null; }
	
	public string getName()
	{ return fromCString(LLVMGetStructName(this._cref)); }
	
	// void setName(StringRef Name)
	
	public void setBody(Type[] Elements, bool isPacked = false)
	{
		auto elements = construct!LLVMTypeRef(Elements.length);
		foreach(i; 0 .. Elements.length)
		{
			elements[i] = Elements[i].cref;
		}

		LLVMStructSetBody(this._cref, elements, cast(uint) Elements.length, cast(LLVMBool) isPacked);
		if(elements !is null)
		{
			destruct(elements);
		}
	}
	
	public void setBody(Type elt1, ...)
	{ 
		Type[] Elements = [elt1];
		foreach(elt; _arguments)
		{
			Elements ~= va_arg!Type(_argptr);
		}
		
		this.setBody(Elements);
	}
	
	// element_iterator element_begin()
	// element_iterator element_end()
	
	public bool isLayoutIdentical(StructType Other)
	{
		if(this == Other)
		{
			return true;
		}
		
		if((this.isPacked() != Other.isPacked()) ||
		   (this.getNumElements != Other.getNumElements()))
		{
			return false;
		}
		
		bool equal = true;
		auto numElements = this.getNumElements();

		auto thisE = construct!LLVMTypeRef(numElements);
		LLVMGetStructElementTypes(this._cref, thisE);
		auto otherE = construct!LLVMTypeRef(numElements);
		LLVMGetStructElementTypes(Other.cref, otherE);
		
		foreach(i; 0 .. numElements)
		{
			if(thisE[i] != otherE[i])
			{
				equal = false;
				break;
			}
		}
		
		destruct(thisE);
		destruct(otherE);
		
		return equal;
	}
	
	public uint getNumElements()
	{ return LLVMCountStructElementTypes(this._cref); }
	
	public Type getElementType(uint N)
	{
		auto elements = construct!LLVMTypeRef(this.getNumElements());
		LLVMGetStructElementTypes(this._cref, elements);
		auto element = elements[N];
		destruct(elements);
		
		return LLVMTypeRef_to_Type(this.context, element);
	}
	
	public static StructType create(LLVMContext Context, string Name)
	{
		auto c_name = Name.toCString();
		Context.treatAsImmutable(c_name);
		return new StructType(Context, LLVMStructCreateNamed(Context.cref, c_name));
	}
	
	public static StructType create(LLVMContext Context)
	{ return StructType.create(Context, cast(string) null); }
	
	public static StructType create(Type[] Elements, string Name, bool isPacked = false)
	{
		assert(Elements.length > 0, "This method may not be invoked with an empty list!");
		return StructType.create(Elements[0].getContext(), Elements, Name, isPacked);
	}
	
	public static StructType create(Type[] Elements)
	{
		assert(Elements.length > 0, "This method may not be invoked with an empty list!");
		return StructType.get(Elements[0].getContext(), Elements);
	}
	
	public static StructType create(LLVMContext Context, Type[] Elements, string Name, bool isPacked = false)
	{
		auto type = StructType.create(Context, Name);
		type.setBody(Elements, isPacked);
		return type;
	}
	
	public static StructType create(LLVMContext Context, Type[] Elements)
	{
		return StructType.get(Context, Elements);
	}
	
	public static StructType create(string Name, Type elt1, ...)
	{
		Type[] Elements = [elt1];
		foreach(elt; _arguments)
		{
			Elements ~= va_arg!Type(_argptr);
		}
		
		return StructType.create(Elements[0].getContext(), Elements, Name);
	}

	public static StructType get(LLVMContext Context, Type[] Elements, bool isPacked = false)
	{
		auto elements = construct!LLVMTypeRef(Elements.length);
		foreach(i; 0 .. Elements.length)
		{
			elements[i] = Elements[i].cref;
		}

		auto type = LLVMStructTypeInContext(Context.cref, elements, cast(uint) Elements.length, cast(LLVMBool) isPacked);
		if(elements !is null)
		{
			destruct(elements);
		}

		return new StructType(Context, type);
	}
	
	public static StructType get(LLVMContext Context, bool isPacked = false)
	{
		return StructType.get(Context, [], isPacked);
	}
	
	public static StructType get(Type elt1, ...)
	{ 
		Type[] Elements = [elt1];
		foreach(elt; _arguments)
		{
			Elements ~= va_arg!Type(_argptr);
		}
		
		return StructType.get(Elements[0].getContext(), Elements);
	}
	
	public static bool isValidElementType(Type ElemTy)
	{
		return !ElemTy.isVoidTy() && !ElemTy.isLabelTy() &&
		       !ElemTy.isMetadataTy() && !ElemTy.isFunctionTy();
	}
}

class FunctionType : Type
{
	package this(LLVMContext C, LLVMTypeRef _cref)
	{
		super(C, _cref);
	}
	
	public bool isVarArg()
	{
		return cast(bool) LLVMIsFunctionVarArg(this._cref);
	}
	
	public Type getReturnType()
	{
		auto type = LLVMGetReturnType(this._cref);
		return LLVMTypeRef_to_Type(this.context, type);
	}
	
	// param_iterator param_begin ()
	// param_iterator param_end ()
	
	public Type getParamType(uint i)
	{
		auto params = construct!LLVMTypeRef(this.getNumParams());
		LLVMGetParamTypes(this._cref, params);
		auto param = params[i];
		destruct(params);
		
		return LLVMTypeRef_to_Type(this.context, param);
	}
	
	public uint getNumParams()
	{ return LLVMCountParamTypes(this._cref); }
	
	public static FunctionType get(Type Result, Type[] Params, bool isVarArg)
	{
		auto params = construct!LLVMTypeRef(Params.length);
		foreach(i; 0 .. Params.length)
		{
			params[i] = Params[i].cref;
		}

		auto type = LLVMFunctionType(Result.cref, params, cast(uint) Params.length, cast(LLVMBool) isVarArg);
		if(params !is null)
		{
			destruct(params);
		}
		return new FunctionType(Result.context, type);
	}
	
	public static FunctionType get(Type Result, bool isVarArg)
	{
		return FunctionType.get(Result, [], isVarArg);
	}
	
	public static bool isValidReturnType(Type RetTy)
	{
		return !RetTy.isFunctionTy() && !RetTy.isLabelTy() && !RetTy.isMetadataTy();
	}
	
	public static bool isValidArgumentType(Type ArgTy)
	{
		return ArgTy.isFirstClassType();
	}
}