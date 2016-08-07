@echo off
set MATLAB=C:\PROGRA~1\MATLAB\R2015b
set MATLAB_ARCH=win64
set MATLAB_BIN="C:\Program Files\MATLAB\R2015b\bin"
set ENTRYPOINT=mexFunction
set OUTDIR=.\
set LIB_NAME=controllerDp_mex
set MEX_NAME=controllerDp_mex
set MEX_EXT=.mexw64
call setEnv.bat
echo # Make settings for controllerDp > controllerDp_mex.mki
echo COMPILER=%COMPILER%>> controllerDp_mex.mki
echo COMPFLAGS=%COMPFLAGS%>> controllerDp_mex.mki
echo OPTIMFLAGS=%OPTIMFLAGS%>> controllerDp_mex.mki
echo DEBUGFLAGS=%DEBUGFLAGS%>> controllerDp_mex.mki
echo LINKER=%LINKER%>> controllerDp_mex.mki
echo LINKFLAGS=%LINKFLAGS%>> controllerDp_mex.mki
echo LINKOPTIMFLAGS=%LINKOPTIMFLAGS%>> controllerDp_mex.mki
echo LINKDEBUGFLAGS=%LINKDEBUGFLAGS%>> controllerDp_mex.mki
echo MATLAB_ARCH=%MATLAB_ARCH%>> controllerDp_mex.mki
echo BORLAND=%BORLAND%>> controllerDp_mex.mki
echo OMPFLAGS= >> controllerDp_mex.mki
echo OMPLINKFLAGS= >> controllerDp_mex.mki
echo EMC_COMPILER=msvcsdk>> controllerDp_mex.mki
echo EMC_CONFIG=optim>> controllerDp_mex.mki
"C:\Program Files\MATLAB\R2015b\bin\win64\gmake" -B -f controllerDp_mex.mk
