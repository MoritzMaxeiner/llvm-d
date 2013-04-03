
module llvm.d.llvm_c;

public
{
	version(DEIMOS_LLVM)
	{
		import deimos.llvm.all;
	}
	else
	{
		import llvm.c.all;
	}
}