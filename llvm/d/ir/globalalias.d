module llvm.d.ir.globalalias;

private
{
	import core.stdc.string : strlen;
	
	import std.algorithm : find;
	
	import llvm.util.templates : MixinMap_VersionedEnum;
	import llvm.util.memory : fromCString, toCString;
	
	import llvm.d.llvm_c;
	
	import llvm.d.ir.llvmcontext : LLVMContext;
	import llvm.d.ir.type : Type;
	import llvm.d.ir.derivedtypes : PointerType;
	import llvm.d.ir.value : Value, LLVMValueRef_to_Value;
	import llvm.d.ir.user : User;
	import llvm.d.ir.constant : Constant;
	import llvm.d.ir.globalvalue : GlobalValue;
}

class GlobalAlias : GlobalValue
{
	package this(Type type, LLVMValueRef _cref)
	{
		super(type, _cref);
	}
	
	// void * 	operator new (size_t s)
	// TODO: Uncomment once Module is implemented
	/+public this(Type Ty, string Name, Constant Aliasee = null, Module Parent = null)
	{
		auto c_Name = Name.toCString();
		Ty.getContext().treatAsImmutable(c_Name);
		LLVMAddAlias(Parent is null ? null : Parent.cref,
		             Ty.cref,
		             Aliasee is null ? null : Aliasee.cref,
		             c_Name);
	}+/
	
	// TODO: Create new function LLVMAddAliasWithLinkage and send to llvm-commits.
	//       Uncomment after Module is implemented and the new C API function is in LLVM
	/+static if(LLVM_Version >= 3.3)
	public this(Type Ty, LinkageTypes Linkage, string Name, Constant Aliasee = null, Module Parent = null)
	{
		auto c_Name = Name.toCString();
		Ty.getContext().treatAsImmutable(c_Name);
		LLVMAddAliasWithLinkage(Parent is null ? null : Parent.cref,
		             Ty.cref,
		             Aliasee is null ? null : Aliasee.cref,
		             c_Name,
		             Linkage);
	}+/

	// virtual void 	removeFromParent ()
	// virtual void 	eraseFromParent ()
	// void 	setAliasee (Constant *GV)

	public Constant getAliasee()
	{ return cast(Constant) this.getOperand(0); }

	// TODO: Uncomment once ConstantExpr and Instruction are implemented
	/+public GlobalValue getAliasedGlobal()
	{
		auto C = this.getAliasee();
		
		if(C is null)
		{
			return null;
		}
		
		if(is(C : GlobalValue))
		{
			return cast(GlobalValue) C;
		}
		
		auto CE = cast(ConstantExpr) C;
		auto code = CE.getOpCode();
		if(!((code == Instruction.BitCast) || (code == Instruction.GetElementPtr)))
		{
			throw new Exception("Unsupported aliasee");
		}
		
		return cast(GlobalValue) CE.getOperand(0);
	}+/

	// TODO: Uncomment once this.getAliasedGlobal is implemented
	/+public GlobalValue resolveAliasedGlobal(bool stopOnWeak = true)
	{
		GlobalValue[] Visited;
		
		// Check if we need to stop early.
		if(stopOnWeak && this.mayBeOverridden())
		{
			return this;
		}
		
		auto GV = this.getAliasedGlobal();
		Visited ~= GV;
		
		// Iterate over aliasing chain, stopping on weak alias if necessary.
		while(is(GV : GlobalAlias))
		{
			auto GA = cast(GlobalAlias) GV;
			if(stopOnWeak && GA.mayBeOverridden())
			{
				break;
			}
			
			GV = GA.getAliasedGlobal();
			
			if(find(Visited, GV).length == 0)
			{
				Visited ~= GV;
			}
			else
			{
				return null;
			}
		}
		
		return GV;
	}+/
}