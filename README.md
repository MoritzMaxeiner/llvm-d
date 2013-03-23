llvm-d
======

**llvm-d** provides bindings to LLVM for the D programming language.

It does so by automatically loading the LLVM dynamic library at program startup
and binding to LLVM's C API functions.

Usage
-----

To use **llvm-d** you just need to import it and then you can use
the functions defined by LLVM's C API. For example:

```d
import llvm.all;
import std.stdio;

void main(string[] args)
{
    if(!LLVM.loaded)
	{
		LLVM.loadFromPath("lib");
	}

	static if(LLVM_Version >= 3.3)
	{
		writefln("LLVM multithreading on? %s", cast(bool) LLVMIsMultithreaded());
		writefln("Turning it on"); LLVMStartMultithreaded();
		writefln("LLVM multithreading on? %s", cast(bool) LLVMIsMultithreaded());
		writefln("Turning it off"); LLVMStopMultithreaded();
		writefln("LLVM multithreading on? %s", cast(bool) LLVMIsMultithreaded());
	}
}
```

Note that a static if is used to assure that the function calls are only compiled
in if **llvm-d** is set to compile for at least the LLVM version that is needed
(the multithreaded functions where added to LLVM's C API in the 3.3 development
cycle and are thus only available from version 3.3 upwards).

Also note that the example also shows how to load the LLVM dynamic library from a
specific path (here a subfolder "lib" in the application directory).

Furthermore you can use "LLVM.loaded" to check whether any errors happened
in the library loading process and then access them via the "LLVM.errors" property
(access to that property clears the stored errors); or you can compile in debug mode
(dmd flag "-debug"), which will cause **llvm-d** to print success to stdout and errors to stderr
(in which case the errors will not be stored for later access via the "LLVM.errors" property).

LLVM versions
-------------

The LLVM version to be used is selected via D's conditional compilatidon
"version" system (For dmd that is set via the "-version" flag).

The identifier to set the LLVM version is defined as
"LLVM_{MAJOR_VERSION}_{MINOR_VERSION}", so to get LLVM version 3.1
use "LLVM_3_1" (without the quotes).

Current supported versions are 3.1 - 3.3 and if no version is given
at compile time, 3.2 will be assumed.

Documentation
-------------

The documentation for LLVM's C API can be found [here](http://llvm.org/doxygen/modules.html).

Planned features
---------------

Partially rebuild LLVM's OOP structure in D around the C API.

License
-------

**llvm-d** is released under the MIT license, see LICENSE.txt
or [here](http://opensource.org/licenses/MIT) for more details.

**llvm-d** uses source code from LLVM that has been ported to D
both for accessing LLVM's C API as well as in recreating
LLVM's class hierarchy in D. The above paragraph does not apply
to that source code - it is a redistribution of LLVM source code.

**LLVM is Copyright (c) 2003-2013 University of Illinois at Urbana-Champaign.
All rights reserved.**

**LLVM is distributed under the University of Illinois Open Source
License. See http://opensource.org/licenses/UoI-NCSA.php for details.**
