echo off
SETLOCAL ENABLEDELAYEDEXPANSION

set javaHome=..\tools\jre8\jre1.8.0_71_win_x64
set jarFile= metodos\gcViewer\ParserGC\gcviewer-1.35-SNAPSHOT.jar

rem java -jar gcviewer.jar [<gc-log-file>] [<export.csv>] [<chart.png>] [-t <SUMMARY, CSV, CSV_TS, PLAIN, SIMPLE>]

for /R %%f in (output\logsGC\*gc*log) do (

    set fileName=%%~nf
	set dirName=gc_files_output
	md output\logsGC\!dirName!
	@echo Processando arquivo '!fileName!'...
	%javaHome%\bin\java -Xmx50M -jar %jarFile% %%f output\logsGC\!dirName!\!fileName!_summary_CSV.csv     output\logsGC\!dirName!\!fileName!_chart_CSV.png     -t CSV
	%javaHome%\bin\java -Xmx50M -jar %jarFile% %%f output\logsGC\!dirName!\!fileName!_summary_PLAIN.csv   output\logsGC\!dirName!\!fileName!_chart_PLAIN.png   -t PLAIN
	%javaHome%\bin\java -Xmx50M -jar %jarFile% %%f output\logsGC\!dirName!\!fileName!_summary_CSV_TS.csv  output\logsGC\!dirName!\!fileName!_chart_CSV_TS.png  -t CSV_TS
	%javaHome%\bin\java -Xmx50M -jar %jarFile% %%f output\logsGC\!dirName!\!fileName!_summary_SIMPLE.csv  output\logsGC\!dirName!\!fileName!_chart_SIMPLE.png  -t SIMPLE
	%javaHome%\bin\java -Xmx50M -jar %jarFile% %%f output\logsGC\!dirName!\!fileName!_summary_SUMMARY.csv output\logsGC\!dirName!\!fileName!_chart_SUMMARY.png -t SUMMARY
)