module llvm.d.ir.argument;

private
{
	import llvm.util.memory;

	import llvm.d.llvm_c;

	import llvm.d.ir.attributes;
	import llvm.d.ir.type;
	import llvm.d.ir.derivedtypes;
	import llvm.d.ir.value;
	import llvm.d.ir.llvmfunction;
}

class Argument : Value
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}

	// Argument (Type *Ty, const Twine &Name="", Function *F=0)
	// const Function * 	getParent () const

	public Function getParent()
	{
		auto _cref = LLVMGetParamParent(this._cref);
		auto type = LLVMTypeRef_to_Type(this.getContext(), LLVMTypeOf(_cref));

		return new Function(type, _cref);
	}

	public uint getArgNo()
	{
		uint length = LLVMCountParams(this._cref);
		
		LLVMValueRef* Params = construct!LLVMValueRef(length);
		LLVMGetParams(this.getParent().cref, Params);

		foreach(uint i; 0 .. length)
		{
			if(Params[i] == this._cref)
			{
				return i;
			}
		}

		assert(0, "Argument cannot not be in its parent's list of arguments");
	}

	public bool hasByValAttr()
	{
		if(!this.getType().isPointerTy())
		{
			return false;
		}

		return LLVMGetAttribute(this._cref) && Attribute.ByVal;
	}

	// unsigned 	getParamAlignment () const

	public bool hasNestAttr()
	{
		if(!this.getType().isPointerTy())
		{
			return false;
		}

		return LLVMGetAttribute(this._cref) && Attribute.Nest;
	}

	public bool hasNoAliasAttr()
	{
		if(!this.getType().isPointerTy())
		{
			return false;
		}

		return LLVMGetAttribute(this._cref) && Attribute.NoAlias;
	}

	public bool hasNoCaptureAttr()
	{
		if(!this.getType().isPointerTy())
		{
			return false;
		}

		return LLVMGetAttribute(this._cref) && Attribute.NoCapture;
	}

	public bool hasStructRetAttr()
	{
		if(!this.getType().isPointerTy())
		{
			return false;
		}

		if(this._cref != LLVMGetFirstParam(this.getParent().cref))
		{
			return false; // StructRet param must be first param
		}

		return LLVMGetAttribute(this._cref) && Attribute.StructRet;
	}

	// bool 	hasReturnedAttr () const

	public bool onlyReadsMemory()
	{
		return LLVMGetAttribute(this._cref) && (Attribute.ReadOnly || Attribute.ReadNone);
	}

	public void addAttr(Attribute A)
	{
		LLVMAddAttribute(this._cref, A);
	}

	public void removeAttr(Attribute A)
	{
		LLVMRemoveAttribute(this._cref, A);
	}
}
