
module llvm.util.memory;

public
{
	import core.stdc.stdlib : malloc, calloc, free;
	import core.stdc.string : memcpy, strlen;
	import core.exception : OutOfMemoryError;

	import std.exception : enforceEx;
	import std.conv : emplace;
}

T construct(T, Args...)(auto ref Args args) if(is(T == class))
{
	enum size = __traits(classInstanceSize, T);
	auto obj = enforceEx!OutOfMemoryError(malloc(size));
	return emplace!(T, Args)(obj[0 .. size], args);
}

T* construct(T)() if(!is(T == class))
{
	enum size = T.sizeof;
	auto obj = enforceEx!OutOfMemoryError(malloc(size));
	return emplace!(T)(obj[0 .. size]);
}

T* construct(T)(size_t length) if(!is(T == class))
{
	if(length > 0)
	{
		enum size = T.sizeof;
		auto obj = enforceEx!OutOfMemoryError(calloc(length, size));
	
		static T init;
		foreach(i; 0 .. length)
		{
			memcpy(obj[i*size .. (i+1)*size], &init, size);
		}
	
		return cast(T*) obj;
	}
	else
	{
		return null;
	}
}

void destruct(T)(ref T obj) if(is(T == class))
{
	free(cast(void*) obj);
	obj = null;
}

void destruct(T)(ref T* obj) if(!is(T == class))
{
	free(cast(void*) obj);
	obj = null;
}

immutable(char)* toCString(const(char)[] s)
{
	auto copy = construct!char(s.length + 1);
	if(s.length > 0) memcpy(copy, s.ptr, s.length);
	copy[s.length] = 0;

	return cast(immutable(char)*) copy;
}

immutable(char)* toCString(string s)
{
	return toCString(cast(const(char)[]) s);
}

string fromCString(const(char)* c_s)
{
	char[] s = new char[strlen(c_s) - 1];
	memcpy(s.ptr, c_s, s.length);
	return cast(immutable(char)[]) s;
}