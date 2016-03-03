
module llvm.c;

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
			      if(matchVersionQualifiers(signature[1 .. $]))
			      {
				      return symbol ~ " = " ~ "library.loadSymbol!(da_"
					      ~ symbol ~ ")(\"" ~ symbol ~ "\");\n";
			      }
			      return "";
		      }));
}

/++
 + Container for holding the LLVM library and the load/unload functions.
++/
public struct LLVM
{
	private __gshared static SharedLib library;

	/// Returns true if the LLVM library is loaded, false if not
	@property
	static bool loaded() { return library !is null; }

	/// Loads the LLVM library, using the default name.
	public static void load() {
		load(null);
	}

	/// Loads the LLVM library, using the specified file name
	public static void load(string file)
	{
		loadFromPath("", file);
	}

	/// Loads the LLVM library, using the specified file name and path
	public static void loadFromPath(string path, string file = null)
	{
		if(file is null)
		{
			file = libPrefix ~ "LLVM-" ~ LLVM_VersionString ~ "." ~ libSuffix;
		}

		if((path != "") && path[$-1] != '/')
		{
			path ~= '/';
		}

		if(library)
		{
			unload();
		}
		
		library = new SharedLib(path ~ file);
		library.load();
		loadSymbols(library);
	}

	/// Unloads the LLVM library
	public static void unload()
	{
		library.unload();
		library = null;
	}
}

version(LLVM_Autoload) {
	shared static this()
	{
		LLVM.load(null);
	}

	shared static ~this()
	{
		LLVM.unload();
	}
}
