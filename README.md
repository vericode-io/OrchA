# automation_orcha
###### The Orchestrator Ant (OrchA)!




The Orchestrator Ant (short: OrchA!) was made to make the creation of automated tasks with Apache Ant easier.
Instead of using the xml files directly, we pass a csv file that configure each tasks in order to do things. 
With the use of some examples it becomes extremelly fast to teach new members of the team to make very 
simples tasks automated - like copyng files or folders, bring some windows services up, executing a list 
of command on a linux machine (which uses the Ganymed SSH-2 for Java http://www.ganymed.ethz.ch/ssh2/), and so on...

It was idealized on the Prime Up Labs to mainly be used on automations of quality assurance non-functional tests.



######Folder structure:

ant
    +---jobs
    +---orquestrador_ant_v.XX.xml
    +---metodos
    +---output
tools
    +---ant (the apache ant goes here)
    +---jdkXX



The tools directory is destined to put any tools needed on the automation process, such as:
    +---PSEXEC_Tools (The sysinternals applications)
    +---R-Portable (GNU-R)
    +---7za.exe
    +---baregrep.exe
    +---baretail.exe
    +---putty.exe
    +---jmeter
	+---cygwin


All the configurations / commands / scripts (linux, sql, windows, etc...) should be in a subdirectory of the job directory (preferentialy one directory per project).

###### TODO LIST:


- create an ant script to install everything that is needed to use OrchA;
- remove useless methods;
- translate everything to english;
- commit a lot of examples;
- create a way to stablish dependences between tasks (start one or more tasks and only start another after all those tasks ended);
- make possible to create remote windows process remotely without psexec (i.e.: using wmi class win32_process) that are capable 
of knowing the exit code (already have this solution on the net) and the stdout / stderr without writing files;
- create a GUI that make writing scripts a little faster
- develop a way do create timeouts and assertions;
