
module samples.nongc;

import std.stdio : writefln;
import core.stdc.stdio : printf;

import llvm.util.memory;

class Foo
{
	private int bar = 4;

	this() {}

	this(int bar)
	{
		this.bar = bar;
	}

	void print()
	{
		writefln("%d", this.bar);
	}
}

void main(string[] args)
{
	Foo foo;

	/+
	 foo = new Foo();
	 foo.print();
	 +/

	foo = construct!Foo();
	foo.print();
	destruct(foo);

	/+
	 foo = new Foo(6);
	 foo.print();
	 +/

	foo = construct!Foo(6);
	foo.print();
	destruct(foo);

	/+
	 auto bar = "Hello, world!\n".toStringz();
	 printf(bar);
	 +/

	auto bar = "Hello, world!\n".toCString();
	printf(bar);
	destruct(bar);
}