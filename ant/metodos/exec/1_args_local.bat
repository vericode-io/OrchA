set oldDir=%CD%
set newDir=%1
cd %newDir%
%2 %3
cd %oldDir%