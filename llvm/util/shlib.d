
module llvm.util.shlib;

private
{
	import std.string : toStringz, to;
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
}
else version(Windows)
{
	private import core.sys.windows.windows;
	private import std.path : dirName;

	alias HMODULE SharedLibHandle;

	string libPrefix = "";
	string libSuffix = "dll";
}

class SharedLib
{
	private SharedLibHandle handle;
	private string libName;
	private string[] _errors;

	@property
	public string[] error()
	{
		string[] errors = _errors;
		_errors = null;
		return errors;
	}

	public this(string libName)
	{
		this.libName = libName;
	}

	public bool load()
	{
		if((libName[0] != '/' ? loadFile("./" ~ libName) : false) || loadFile(libName))
		{
			_errors = null;
			return true;
		}

		return false;
	}

	private bool loadFile(string file)
	{
		version(Posix)
		{
			if((handle = dlopen(file.toStringz(), RTLD_NOW)) !is null)
			{
				return true;
			}
			else
			{
				auto error = dlerror();
				_errors ~= (error !is null) ? to!string(error) : "Unknown error";
			}
		}
		else version(Windows)
		{
			if((handle = LoadLibraryA(file.toStringz())) !is null)
			{
				return true;
			}
			else
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

				_errors ~= to!string(error[0..tchar_length+1]);
				LocalFree(cast(HLOCAL) error);
			}
		}

		return false;
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
		else version(Windows)
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
		else version(Windows)
		{
			return cast(T) GetProcAddress(handle, symbol.toStringz());
		}
		else
		{
			return null;
		}
	}
}