
module llvm.d.ir.llvmcontext;

private
{
	import core.sync.mutex;
	import std.conv : to;

	import llvm.d.llvm_c;

	import llvm.util.memory;
}

private __gshared LLVMContext GlobalContext = null;

version(DEIMOS_LLVM) shared static this()
{
	GlobalContext = new LLVMContext(LLVMGetGlobalContext());
}

class LLVMContext
{
	private LLVMContextRef _cref = null;
	
	/+ Data that the real context this instance represents
	 + must see as immutable during its lifetime
	 + (i.e. data for which either knowing if or when LLVM
	 + releases it is impossible or it is known that
	 + it will not do so in this context's lifetime). +/
	private immutable(void)*[] ImmutableData = null;

	@property
	public LLVMContextRef cref() { return this._cref; }

	public void treatAsImmutable(T)(T* data)
	{
		synchronized(this)
		{
			this.ImmutableData ~= cast(immutable(void*)) data;
		}
	}

	public void treatAsImmutable(T)(T[] array)
	{
		synchronized(this)
		{
			this.ImmutableData ~= cast(immutable(void*)) array;
		}
	}

	override bool opEquals(Object obj)
	{
		return is(o : LLVMContext) &&
			((cast(LLVMContext) obj)._cref == this._cref);
	}

	package this(LLVMContextRef _cref)
	{
		this._cref = _cref;
	}

	public this()
	{
		this._cref = LLVMContextCreate();
	}


	~this()
	{
		// Do not attempt to dispose LLVM's
		// global context.
		if(LLVMGetGlobalContext() != this._cref)
		{
			LLVMContextDispose(this._cref);
		}
		
		foreach(data; this.ImmutableData)
		{
			destruct(data);
		}
	}
	
	uint getMDKindID(string name)
	{
		/+ LLVM will keep c_name around, but never free its
		 + memory as it views that memory as immutable,
		 + so we habe to keep it around as long as this
		 + context exists. +/
		auto c_name = name.toCString();
		this.treatAsImmutable(c_name);
		return LLVMGetMDKindIDInContext(
			this._cref,
			c_name,
			to!uint(name.length));
	}
}


LLVMContext getGlobalContext()
{
	version(DEIMOS_LLVM) {} else
	{
		if(GlobalContext is null)
		{
			synchronized
			{
				if(GlobalContext is null)
				{
					GlobalContext = new LLVMContext(LLVMGetGlobalContext());
				}
			}
		}
	}

	return GlobalContext;
}