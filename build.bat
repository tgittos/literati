@echo off

IF "%~1"==""			GOTO build
IF "%~1"=="install"		GOTO install
GOTO end

REM Build with no args
:build
@echo Tangling literati files
rmdir lib /s /q
call literati tangle -o ..\ examples\literati\
GOTO end

REM Install with install arg
:install
@echo Building gem (install)
rmdir lib /s /q
call literati tangle -o ..\ examples\literati\
@echo Installing gem
call gem uninstall literati
call gem build literati.gemspec
call gem install literati
del literati*.gem
GOTO end

:end
@echo on