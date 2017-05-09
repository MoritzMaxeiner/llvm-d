module llvm.functions.load;

version (LLVM_Load):

import std.traits;
import std.meta;

import functions = llvm.functions.link;

private:

template isCFunction(alias scope_, string member)
{
    static if (isFunction!(__traits(getMember, scope_, member)) &&
               (functionLinkage!(__traits(getMember, scope_, member)) == "C" ||
                functionLinkage!(__traits(getMember, scope_, member)) == "Windows")) {
        enum isCFunction = true;
    } else {
        enum isCFunction = false;
    }
}

template CFunctions(alias mod)
{
    alias isCFunction(string member) = .isCFunction!(mod, member);
    alias CFunctions = Filter!(isCFunction, __traits(allMembers, mod));
}

string declareStubs()
{
    import std.array : appender;
    auto code = appender!string;
    foreach (fn; CFunctions!functions) {
        code.put("typeof(functions."); code.put(fn);
        code.put(")* "); code.put(fn); code.put(";\n");
    }
    return code.data;
}

version(Posix)
{
    import core.sys.posix.dlfcn;

    alias SharedLibHandle = void*;

    version(OSX)
    {
        enum libPrefix = "lib";
        enum libSuffix = "dylib";
    }
    else
    {
        enum libPrefix = "lib";
        enum libSuffix = "so";
    }

    pragma(lib, "dl");
}
else version(Windows)
{
    import core.sys.windows.windows;
    import std.path : dirName;

    alias SharedLibHandle = HMODULE;

    enum libPrefix = "";
    enum libSuffix = "dll";
} else {
    static assert(0, "Unsupported operating system");
}

struct SharedLib
{
    import std.string : fromStringz, toStringz;
private:
    SharedLibHandle handle;
public:
    bool loaded() @property { return handle !is null; }

    void load(string filename)
    {
        version(Posix)
        {
            if((handle = dlopen(filename.toStringz(), RTLD_NOW)) is null)
            {
                throw new SharedLibException("Failed to load library " ~ filename ~ ": " ~ dlerror().fromStringz().idup);
            }
        }
        else version(Windows)
        {
            if((handle = LoadLibraryA(filename.toStringz())) is null)
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

                throw new SharedLibException("Failed to load library " ~ filename ~ ": " ~ error[0..tchar_length].idup);
            }
        }
        else static assert(0, "Unsupported operating system");
    }

    void unload()
    {
             version (Posix)   alias close = dlclose;
        else version (Windows) alias close = FreeLibrary;
        else static assert(0, "Unsupported operating system");

        if (handle) {
            close(handle);
            handle = null;
        }
    }

    T getSymbol(T)(string symbol)
    {
             version (Posix)   alias get = dlsym;
        else version (Windows) alias get = GetProcAddress;
        else static assert(0, "Unsupported operating system");

        return cast(T) get(handle, symbol.toStringz());
    }
}

public:

final class SharedLibException : Exception
{
    this(string msg) @safe pure nothrow
    {
        super(msg);
    }
}

__gshared
{
    mixin (declareStubs);
}

/// Container for holding the LLVM library and the load/unload functions.
public struct LLVM
{
    import llvm.config : LLVM_VersionString;
private:
    __gshared static SharedLib library;

    static void getSymbols()
    {
        import std.stdio : stderr;
        foreach (fn; CFunctions!functions) {
            mixin(fn ~ " = library.getSymbol!(typeof(" ~ fn ~ "))(\"" ~ fn ~ "\");");
            debug if (!mixin(fn)) stderr.writeln("Warning, your LLVM shared library does not provide " ~ fn);
        }
    }
public:
    /// true iff the LLVM library is loaded
    static bool loaded() @property { return library.loaded; }

    /// Loads the LLVM library using the default filename.
    static void load()
    {
        load(null);
    }

    /// Loads the LLVM library using the specified filename
    static void load(string filename)
    {
        if (filename is null) {
            filename = libPrefix ~ "LLVM-" ~ LLVM_VersionString ~ "." ~ libSuffix;
        }

        if (library.loaded) library.unload();

        library.load(filename);
        getSymbols();
    }

    /// Unloads the LLVM library
    static void unload()
    {
        library.unload();
    }
}

version (LLVM_Autoload)
{
    shared static this()
    {
        LLVM.load();
    }

    shared static ~this()
    {
        LLVM.unload();
    }
}
