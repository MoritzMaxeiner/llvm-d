
module llvm.util.shlib;

private
{
	import std.string : toStringz, fromStringz;
	import std.conv : to;
}

final class SharedLibLoadException : Exception
{
	@safe pure nothrow
	this(string msg)
	{
		super(msg);
	}
}

version(Posix)
{
	private import core.sys.posix.dlfcn;

	alias void* SharedLibHandle;

	version(OSX)
	{
		string libPrefix = "lib";
		string libSuffix = "dylib";
	}
	else
	{
		string libPrefix = "lib";
		string libSuffix = "so";
	}

	pragma(lib, "dl");
}
else version(Windows)
{
	private import core.sys.windows.windows;
	private import std.path : dirName;

	alias HMODULE SharedLibHandle;

	string libPrefix = "";
	string libSuffix = "dll";
} else {
	static assert(false, "Shared libraries unimplemented for this system.");
}

class SharedLib
{
	private SharedLibHandle handle;
	private string libName;
	
	public this(string libName)
	{
		this.libName = libName;
	}

	public void load()
	{
		return loadFile(libName);
	}

	private void loadFile(string file)
	{
		version(Posix)
		{
			if((handle = dlopen(file.toStringz(), RTLD_NOW)) is null)
			{
				throw new SharedLibLoadException("Failed to load library "~file~": "~dlerror().fromStringz().idup);
			}
		}
		else version(Windows)
		{
			if((handle = LoadLibraryA(file.toStringz())) is null)
			{
				LPCSTR error;
				DWORD tchar_length = FormatMessageA(
					FORMAT_MESSAGE_ALLOCATE_BUFFER |
					FORMAT_MESSAGE_FROM_SYSTEM |
					FORMAT_MESSAGE_IGNORE_INSERTS,
					null,
					GetLastError(),
					MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
					cast(char*) &error,
					0,
					null);
				scope(exit) LocalFree(cast(HLOCAL) error);
				
				throw new SharedLibLoadException("Failed to load library "~file~": "~error[0..tchar_length]);
			}
		}
	}

	public void unload()
	{
		version(Posix)
		{
			if(handle !is null)
			{
				dlclose(handle);
			}
		}
		else
		{
			if(handle !is null)
			{
				FreeLibrary(handle);
			}
		}
	}

	public T loadSymbol(T)(string symbol)
	{
		version(Posix)
		{
			return cast(T) dlsym(handle, symbol.toStringz());
		}
		else
		{
			return cast(T) GetProcAddress(handle, symbol.toStringz());
		}
	}
}