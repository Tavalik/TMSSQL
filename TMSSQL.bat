rem @echo off

setlocal

set file="%~dp0\TMSSQL.os"

oscript %file% %*
