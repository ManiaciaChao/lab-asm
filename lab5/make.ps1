rc .\menu.rc
if($?) {
  ml /c /coff /Zi .\task1.asm
  if ($?) {
    link /subsystem:windows /debug /debugtype:cv .\task1.obj .\menu.RES
  }
}