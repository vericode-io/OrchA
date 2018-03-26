

IF "%PROCESSOR_ARCHITECTURE%"=="x86" (set RBIN="..\tools\R-Portable\App\R-Portable\bin\i386\R.exe") else (set RBIN="..\tools\R-Portable\App\R-Portable\bin\x64\R.exe")

%RBIN% --no-environ --no-save --args %1% < ".\metodos\sar\alphaSAR\alphaSAR_ReportPDF.R" > log.r 