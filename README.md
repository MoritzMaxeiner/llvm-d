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
module samples.multithreaded;

import llvm.all;
import std.stdio;

void main(string[] args)
{
	LLVM.load();
	
	static if((3.3 <= LLVM_Version) && (LLVM_Version < 3.5))
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
cycle and removed in the 3.5 development cycle; thus they are only available in versions 3.3 and 3.4).

A more complex example showing how to calculate the fibonacci series; see the `samples/fibonacci.d` file
for an example.

LLVM versions
-------------

The LLVM version to be used is selected via D's conditional compilatidon
"version" system (For dmd that is set via the "-version" flag).

The identifier to set the LLVM version is defined as
"LLVM_{MAJOR_VERSION}_{MINOR_VERSION}", so to get LLVM version 3.1
use "LLVM_3_1" (without the quotes).

Current supported versions are 3.1 - 3.7 and if no version is given
at compile time, 3.7 will be assumed.

Documentation
-------------

The documentation for LLVM's C API can be found [here](http://llvm.org/doxygen/modules.html).

License
-------

**llvm-d** is released under the MIT license, see LICENSE.txt
or [here](http://opensource.org/licenses/MIT) for more details.

**llvm-d** uses source code from LLVM that has been ported to D for accessing LLVM's C API. The above paragraph does not apply
to that source code - it is a redistribution of LLVM source code.

**LLVM is Copyright (c) 2003-2015 University of Illinois at Urbana-Champaign.
All rights reserved.**

**LLVM is distributed under the University of Illinois Open Source
License. See http://opensource.org/licenses/UoI-NCSA.php for details.**
