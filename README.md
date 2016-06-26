llvm-d
========

-[![Build Status](https://travis-ci.org/Calrama/llvm-d.svg?branch=master)](https://travis-ci.org/Calrama/llvm-d)

llvm-d provides bindings to LLVM for the D programming language.

It does so by automatically loading the LLVM dynamic library at program startup
and binding to LLVM's C API functions.

This was forked from the llvm-d project, as the original has a few issues with the API
and does not version its releases.

Usage
-----

To use llvm-d you just need to import it and then you can use
the functions defined by LLVM's C API. For example:

```d
module samples.multithreaded;

import std.stdio;

import llvm.d.llvm_c;

void main(string[] args)
{
	LLVM.load();
	
	static if((LLVMDVersion(3, 3, 0) <= LLVM_Version) && (LLVM_Version < LLVMDVersion(3, 5, 0)))
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
in if llvm-d is set to compile for at least the LLVM version that is needed
(the multithreaded functions where added to LLVM's C API in the 3.3 development
cycle and removed in the 3.5 development cycle; thus they are only available in versions 3.3 and 3.4).

A more complex example showing how to calculate the fibonacci series; see the `samples/fibonacci.d` file
for an example.

LLVM versions
-------------

The LLVM version to be used is selected by setting a [conditional compilation version identifier](https://dlang.org/spec/version.html).
For DMD, this is the `-version` argument; for dub, the `versions` field.

The identifier to set the LLVM version is defined as
`LLVM_{MAJOR_VERSION}_{MINOR_VERSION}_{PATCH_VERSION}`, so to get LLVM version 3.1.0
use `LLVM_3_1_0`.

Current supported versions are 3.1.0 - 3.8.0 and if no version is given
at compile time, 3.8.0 will be assumed.

Documentation
-------------

llvm-d exposes C function pointers, constants, and types with the same names as LLVM's C API.
[See the LLVM Doxygen pages for a reference.](http://llvm.org/doxygen/modules.html)

Changes from llvm-d
-------------------

* The LLVM library is no longer automatically loaded at startup; this causes issues when loading from paths other than the hardcoded one.
* The LLVM library loading functions now throw exceptions on failure.
* `llvm.util.memory` was removed; there are better options for what it contained in Phobos now.
* Releases are tagged, so that clients do not need to use the deprecated "~master" version.
* Patch-level versioning is supported; LLVM_Version is a `ulong` instead of a `float`

License
-------

llvm-d is released under the [MIT license](http://opensource.org/licenses/MIT), see LICENSE.txt.

llvm-d uses source code from LLVM that has been ported to D for accessing LLVM's C API. The above paragraph does not apply
to that source code - it is a redistribution of LLVM source code.

LLVM is Copyright (c) 2003-2015 University of Illinois at Urbana-Champaign.
All rights reserved.

LLVM is distributed under the University of Illinois Open Source
License. See http://opensource.org/licenses/UoI-NCSA.php for details.
