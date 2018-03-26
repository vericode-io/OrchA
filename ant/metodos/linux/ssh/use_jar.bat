@echo off
IF "%PROCESSOR_ARCHITECTURE%"=="x86" (set JAVA_HOME=..\tools\jre7\jre1.7.0_10_win_x86) else (set JAVA_HOME=..\tools\jre7\jre1.7.0_10_win_x64)
%JAVA_HOME%\bin\java -DUA=%UA% -DPA=%PA% -jar %1 %2 %3 %4 %5 .\output\ant\logs\shell\
