@echo off
if not exist lib.obj masm lib.asm
if errorlevel 1 goto end
if not exist case6.obj masm case6.asm
if errorlevel 1 goto end
masm %1.asm /l
if not errorlevel 1 link %1.obj lib.obj case6.obj;
if exist %1.obj del %1.obj
:end