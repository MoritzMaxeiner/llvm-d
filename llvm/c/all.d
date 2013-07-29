
module llvm.c.all;

private
{
	import llvm.util.templates;
	import llvm.util.shlib;
}

public
{
	import llvm.c.versions;
	import llvm.c.types;
	import llvm.c.constants;
	import llvm.c.functions;
}

private void loadSymbols(SharedLib library)
{
	mixin(MixinMap(
		      LLVMC_Functions,
		      delegate string(string symbol, string[] signature)
		      {
			      if((signature.length == 1) ||
			         ((signature[1] == "+") && (to!float(signature[2]) <= LLVM_Version)) ||
			         ((signature[1] == "-") && (to!float(signature[2]) > LLVM_Version)))
			      {
				      return symbol ~ " = " ~ "library.loadSymbol!(da_"
					      ~ symbol ~ ")(\"" ~ symbol ~ "\");\n";
			      }
			      return "";
		      }));
}

public struct LLVM
{
	private __gshared static SharedLib library;
	private __gshared static bool _loaded = false;

	@property
	static bool loaded() { return _loaded; }

	public static void load(string file)
	{
		loadFromPath("", file);
	}

	public static void loadFromPath(string path, string file = null)
	{
		if(file is null)
		{
			file = libPrefix ~ "LLVM-" ~
				to!string(LLVM_Version) ~ (LLVM_Version == LLVM_Trunk ? "svn" : "")
				~ "." ~ libSuffix;
		}

		if((path != "") && path[$-1] != '/')
		{
			path ~= '/';
		}

		if(!_loaded)
		{
			library = new SharedLib(path ~ file);
			if(library.load())
			{
				loadSymbols(library);
				_loaded = true;
				debug
				{
					import std.stdio;
					writefln("LLVM shared library \"%s\" sucessfully loaded", path ~ file);
				}
			}
			else debug
			{
				import std.cstream;
				derr.writefln(to!string(library.error));
			}
		}
	}

	private static void unload()
	{
		library.unload();
		_loaded = false;
	}
}

shared static this()
{
	LLVM.load(null);
}

shared static ~this()
{
	LLVM.unload();
}