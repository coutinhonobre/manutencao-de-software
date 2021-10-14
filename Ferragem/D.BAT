clipper pan_prin -b
clipper PAN_MENU -B
clipper PAN_CAD -B
clipper Pan_Func -b
clipper Pan_Util -b
clipper Pan_Vend -b
clipper PAN_COMP -b
clipper Pan_Rela -b
clipper Pan_Mot -b
if not errorlevel=1 rtlink @pao
pause
CLD /S PAN_PRIN
