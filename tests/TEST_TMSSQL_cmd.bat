@echo off

setlocal

set file="%~dp0..\TMSSQL.bat"
set server="10.1.1.40"
set uid="sa"
set pwd="pass"
set database="Test_OS_TMSSQL"
set connectionstring=-server %server% -uid %uid% -pwd %pwd% -database %database%

rem Вывод справки
echo ----------------------------------------------
echo help:
call %file% help

rem Создание базы данных 
echo ----------------------------------------------
echo createdatabase:
call %file% createdatabase %connectionstring%

rem Изменение модели восстановления
echo ----------------------------------------------
echo setrecovery:
call %file% setrecovery FULL %connectionstring%

rem Создание резервных копий
echo ----------------------------------------------
echo backupdatabase:
set file_FULL=%database%_FILE_FULL.bak
set file_DIFF=%database%_FILE_DIFF.bak
set file_LOG=%database%_FILE_LOG.trn
call %file% backupdatabase "" %file_FULL% FULL %connectionstring%
TIMEOUT 1 /NOBREAK
call %file% backupdatabase "" %file_DIFF% DIFFERENTIAL %connectionstring%
TIMEOUT 1 /NOBREAK
call %file% backupdatabase "" %file_LOG% LOG %connectionstring%
TIMEOUT 1 /NOBREAK

rem Восстановление базы данных
echo ----------------------------------------------
echo restoredatabase:
call %file% restoredatabase %connectionstring%

rem Удаление файлов на сервере
echo ----------------------------------------------
echo deletefile:
call %file% deletefile %file_FULL% %connectionstring%
call %file% deletefile %file_DIFF% %connectionstring%
call %file% deletefile %file_LOG% %connectionstring%

rem Сжатие файлов базы данных
echo ----------------------------------------------
echo shrinkfile:
call %file% shrinkfile LOG %connectionstring%

rem Сжатие базы данных
echo ----------------------------------------------
echo shrinkdatabase:
call %file% shrinkdatabase %connectionstring%

rem Удаление базы данных
echo ----------------------------------------------
echo dropdatabase:
call %file% dropdatabase %connectionstring%

pause
