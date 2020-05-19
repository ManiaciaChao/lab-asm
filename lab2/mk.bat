@echo off
REM if not exist lib.obj masm lib.asm
REM if errorlevel 1 goto end
REM if not exist timer.obj masm timer.asm
REM if errorlevel 1 goto end
masm %1.asm /l
if not errorlevel 1 link %1.obj lib.obj timer.obj;
if exist %1.obj del %1.obj
:end