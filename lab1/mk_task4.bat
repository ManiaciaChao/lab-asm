@echo off
masm task4_l.asm /l /Zi
if not errorlevel 1 masm task4.asm
if not errorlevel 1 link task4.obj task4_l.obj;
if exist task4.obj del task4.obj
if exist task4_l.obj del task4_l.obj
