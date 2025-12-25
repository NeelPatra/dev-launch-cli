@echo off
setlocal EnableDelayedExpansion
TITLE DevLaunch CLI v1.0
COLOR 0B

:: ==============================================================
::                  USER CONFIGURATION (EDIT HERE)
:: ==============================================================

:: --- Define your presets names and URLs here ---
set "NAME_1=Localhost React"
set "URL_1=http://localhost:3000"

set "NAME_2=Localhost Vite"
set "URL_2=http://localhost:5173"

set "NAME_3=Localhost Django"
set "URL_3=http://localhost:8000"

:: --- Set your preferred default browser (C=Chrome, E=Edge, B=Brave, F=Firefox) ---
:: Leave blank to always ask.
set "DEFAULT_BROWSER="

:: ==============================================================
::                  END CONFIGURATION
:: ==============================================================

:home
CLS
ECHO.
ECHO  ================================================
ECHO   DEV LAUNCH CLI - Workflow Automation
ECHO  ================================================
ECHO.
ECHO   [1] %NAME_1%
ECHO   [2] %NAME_2%
ECHO   [3] %NAME_3%
ECHO   [4] Paste from Clipboard
ECHO   [5] Enter Custom URL
ECHO.
ECHO   [Q] Quit
ECHO.

CHOICE /C 12345Q /N

IF ERRORLEVEL 6 GOTO quit_script
IF ERRORLEVEL 5 GOTO ask_url
IF ERRORLEVEL 4 GOTO get_clipboard
IF ERRORLEVEL 3 set "target_url=%URL_3%" & goto select_mode
IF ERRORLEVEL 2 set "target_url=%URL_2%" & goto select_mode
IF ERRORLEVEL 1 set "target_url=%URL_1%" & goto select_mode

:ask_url
ECHO.
set /p "target_url=>> Enter URL: "
if "%target_url%"=="" goto home
goto select_mode

:get_clipboard
ECHO.
ECHO Reading clipboard...
for /f "usebackq tokens=*" %%i in (`powershell -command "Get-Clipboard"`) do set "target_url=%%i"
ECHO Found: %target_url%
goto select_mode

:select_mode
CLS
ECHO.
ECHO  Target: "%target_url%"
ECHO  --------------------------------
ECHO   [1] Standard Mode
ECHO   [2] Incognito Mode
ECHO.
ECHO   [B] Back   [H] Home   [Q] Quit

CHOICE /C 12BHQ /N

IF ERRORLEVEL 5 GOTO quit_script
IF ERRORLEVEL 4 GOTO home
IF ERRORLEVEL 3 GOTO home
IF ERRORLEVEL 2 set "is_incognito=1" & goto check_default_browser
IF ERRORLEVEL 1 set "is_incognito=0" & goto check_default_browser

:check_default_browser
:: If user set a default in config, skip the menu
if not "%DEFAULT_BROWSER%"=="" (
    set "browser_choice=%DEFAULT_BROWSER%"
    goto select_browser_logic
)
goto select_browser_menu

:select_browser_menu
CLS
ECHO.
ECHO  Target: "%target_url%"
ECHO  --------------------------------
ECHO   [1] Chrome   [2] Edge   [3] Brave   [4] Firefox
ECHO.
ECHO   [B] Back   [H] Home   [Q] Quit

CHOICE /C 1234BHQ /N

IF ERRORLEVEL 7 GOTO quit_script
IF ERRORLEVEL 6 GOTO home
IF ERRORLEVEL 5 GOTO select_mode
IF ERRORLEVEL 4 set "browser_choice=F" & goto select_browser_logic
IF ERRORLEVEL 3 set "browser_choice=B" & goto select_browser_logic
IF ERRORLEVEL 2 set "browser_choice=E" & goto select_browser_logic
IF ERRORLEVEL 1 set "browser_choice=C" & goto select_browser_logic

:select_browser_logic
if /i "%browser_choice%"=="C" goto launch_chrome
if /i "%browser_choice%"=="E" goto launch_edge
if /i "%browser_choice%"=="B" goto launch_brave
if /i "%browser_choice%"=="F" goto launch_firefox

:launch_chrome
if "%is_incognito%"=="1" set "incognito_flag=--incognito"
start chrome --app=%target_url% %incognito_flag% --auto-open-devtools-for-tabs
GOTO end

:launch_edge
if "%is_incognito%"=="1" set "incognito_flag=--inprivate"
start msedge --app=%target_url% %incognito_flag% --auto-open-devtools-for-tabs
GOTO end

:launch_brave
if "%is_incognito%"=="1" set "incognito_flag=--incognito"
start brave --app=%target_url% %incognito_flag% --auto-open-devtools-for-tabs
GOTO end

:launch_firefox
if "%is_incognito%"=="1" ( set "incognito_flag=-private-window" ) else ( set "incognito_flag=-new-window" )
start firefox %incognito_flag% %target_url% -devtools
GOTO end

:quit_script
EXIT

:end
timeout /t 2 >nul
EXIT