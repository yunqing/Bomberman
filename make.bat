SET PATH=D:\0_Learning\0_Assembly_Language_and_Compliing\masm32\bin;%PATH%
SET INCLUDE=D:\0_Learning\0_Assembly_Language_and_Compliing\experiment\bomberman\bomberman\include
SET LIB=D:\0_Learning\0_Assembly_Language_and_Compliing\experiment\bomberman\bomberman\lib

%~d1

cd %~p1

del %~n1.exe

ML -Zi -c -Fl -coff %1
if errorlevel 1 goto terminate

rc %~n1.rc
if errorlevel 1 goto terminate


LINK %~n1.obj %~n1.res /SUBSYSTEM:WINDOWS /NOLOGO /RELEASE
if errorlevel 1 goto terminate

goto next
LINK %~n1.obj /SUBSYSTEM:WINDOWS /NOLOGO /RELEASE
if errorlevel 1 goto terminate
:next

del %~n1.res
del %~n1.lst
del %~n1.ilk
del %~n1.obj
del %~n1.pdb

:terminate
pause 

