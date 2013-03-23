
module llvm.d.llvm_c;

public
{
	version(DEIMOS_LLVM)
	{
		import deimos.llvm.c.transforms.ipo;
		import deimos.llvm.c.transforms.passmanagerbuilder;
		import deimos.llvm.c.transforms.scalar;
		import deimos.llvm.c.transforms.vectorize;
		import deimos.llvm.c.analysis;
		import deimos.llvm.c.bitreader;
		import deimos.llvm.c.bitwriter;
		import deimos.llvm.c.core;
		import deimos.llvm.c.disassembler;
		import deimos.llvm.c.enhanceddisassembly;
		import deimos.llvm.c.executionengine;
		import deimos.llvm.c.initialization;
		import deimos.llvm.c.linktimeoptimizer;
		import deimos.llvm.c.lto;
		import deimos.llvm.c.object;
		import deimos.llvm.c.target;
		import deimos.llvm.c.targetmachine;
	}
	else
	{
		import llvm.c.all;
	}
}