
module llvm.d.ir.llvmcontext;

private
{
	import core.sync.mutex;
	import std.conv : to;

	import llvm.d.llvm_c;

	import llvm.util.memory;
}

private __gshared immutable(char)*[] global_c_strings = null;
private __gshared Mutex global_c_strings_mutex = null;

shared static this()
{
	global_c_strings_mutex = new Mutex();
}

shared static ~this()
{
	foreach(c_string; global_c_strings)
	{
		destruct(c_string);
	}
}

/+ List of how the LLVM C API functions are
 + being wrapped in the D API:
 + LLVMContextCreate -> new LLVMContext
 + LLVMContextDispose -> delete LLVMContext (if not global context)
 + LLVMGetMDKindIDInContext -> getMDKindID
 + LLVMGetGlobalContext -> getGlobalContext
 + LLVMGetMDKindID -> None, use getGlobalContext().getMDKindID +/

class LLVMContext
{
	private LLVMContextRef _cref = null;

	private immutable(char)*[] c_strings = null;
	private Mutex c_strings_mutex = null;

	@property
	public LLVMContextRef cref() { return this._cref; }
	
	void destructOnCollection(immutable(char)* c_string)
	{
		try { this.c_strings_mutex.lock(); }
		catch(SyncException e) {}
		this.c_strings ~= c_string;
		try { this.c_strings_mutex.unlock(); }
		catch(SyncException e) {}
	}

	@property
	public bool isGlobal() { return LLVMGetGlobalContext() == this._cref; }

	override bool opEquals(Object obj)
	{
		return is(o : LLVMContext) &&
			((cast(LLVMContext) obj)._cref == this._cref);
	}

	package this(LLVMContextRef _cref)
	{
		this._cref = _cref;
		this.c_strings_mutex = new Mutex();
	}

	public this()
	{
		this._cref = LLVMContextCreate();
		this.c_strings_mutex = new Mutex();
	}


	~this()
	{
		if(!this.isGlobal)
		{
			LLVMContextDispose(this._cref);
			/+ After the LLVMContext is gone
			 + we can free the memory of all
			 + the strings it needed to see
			 + as immutable. +/
			foreach(c_string; this.c_strings)
			{
				destruct(c_string);
			}
		}
		else
		{
			/+ If the LLVMContext is LLVM's
			 + global context the c_strings
			 + should be freed when that global context
			 + gets deleted. Since there is no way
			 + to know when that will happen we have to
			 + keep them around until program termination,
			 + potentially leaking memory.
			 + Avoidable by not using LLVM's global context. +/
			try { global_c_strings_mutex.lock(); }
			catch(SyncException e) {}
			global_c_strings ~= this.c_strings;
			try { global_c_strings_mutex.unlock(); }
			catch(SyncException e) {}
		}
	}
	
	uint getMDKindID(string name)
	{
		/+ LLVM will keep c_name around, but never free its
		 + memory as it views that memory as immutable,
		 + so we habe to keep it around as long as this
		 + context exists. +/
		auto c_name = name.toCString();
		this.destructOnCollection(c_name);
		return LLVMGetMDKindIDInContext(
			this._cref,
			c_name,
			to!uint(name.length));
	}
}


LLVMContext getGlobalContext()
{
	return new LLVMContext(LLVMGetGlobalContext());
}