echo off

rem coisa horrivel... (thiago ruiz)
set var1=%1
shift
set var2=%1
shift
set var3=%1
shift
set var4=%1
shift
set var5=%1
shift
set var6=%1
shift
set var7=%1
shift
set var8=%1
shift
set var9=%1
shift
set var10=%1
shift
set var11=%1
shift
set var12=%1
shift
set var13=%1
shift
set var14=%1
shift
set var15=%1
shift
set var16=%1
shift
set var17=%1
shift
set var18=%1
shift
set var19=%1
shift
set var20=%1
shift
set var21=%1
shift
set var22=%1
shift
set var23=%1
shift


rem echo %var1% %var2% %var3% %var4% %var5% %var6% %var7% %var8% %var9% %var10% %var11% %var12% %var13% %var14% %var15% %var16% %var17% %var18% %var19% %var20% %var21% %var22% %var23%

..\tools\PSEXEC_Tools\PsExec.exe -w %var1% -h \\%var2% cmd /c %var3% %var4% %var5% %var6% %var7% %var8% %var9% %var10% %var11% %var12% %var13% %var14% %var15% %var16% %var17% %var18% %var19% %var20% %var21% %var22% %var23%

