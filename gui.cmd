@echo off

@if [%1]==[] goto usage

@start /B mstsc "%~dp0\miscellaneous\%1.rdp"
@goto :eof

:usage
@echo This command requires a specific VM name to target.
@echo Usage: %0 ^<Hostname^>
exit /B 1


