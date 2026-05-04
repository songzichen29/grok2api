@echo off
chcp 65001 >nul
setlocal

REM ============================================================
REM grok2api 启动脚本（Windows / conda 环境）
REM 双击运行；或在 cmd / Anaconda Prompt 里执行 start.bat
REM ============================================================

REM 切到脚本所在目录（包含盘符切换）
cd /d "%~dp0"

REM ---------- 1. 激活 conda 环境 ----------
REM conda 安装路径（写死，按需修改）
set "CONDA_ROOT=E:\software\Anaconda"
set "CONDA_ACTIVATE=%CONDA_ROOT%\Scripts\activate.bat"

if not exist "%CONDA_ACTIVATE%" (
    echo [ERROR] 找不到 conda 激活脚本：%CONDA_ACTIVATE%
    echo         请检查 CONDA_ROOT 是否正确
    pause
    exit /b 1
)

echo [INFO] 激活 conda 环境 grok2api ...
call "%CONDA_ACTIVATE%" grok2api
if errorlevel 1 (
    echo.
    echo [ERROR] 无法激活 conda 环境 grok2api
    echo         请确认环境已创建：conda env list
    echo.
    pause
    exit /b 1
)

REM ---------- 2. 初始化数据 / 日志目录 ----------
if not exist "data" (
    echo [INFO] 创建目录 data
    mkdir "data"
)
if not exist "logs" (
    echo [INFO] 创建目录 logs
    mkdir "logs"
)

REM ---------- 3. 首次启动复制默认配置 ----------
if not exist "data\config.toml" (
    echo [INFO] 首次启动，复制默认配置 -^> data\config.toml
    copy /Y "config.defaults.toml" "data\config.toml" >nul
)

REM ---------- 4. 读取 .env 端口（可选，未配置走默认）----------
set "SERVER_HOST=0.0.0.0"
set "SERVER_PORT=8000"
set "SERVER_WORKERS=1"
if exist ".env" (
    for /f "usebackq tokens=1,2 delims==" %%A in (".env") do (
        if /I "%%A"=="SERVER_HOST"    set "SERVER_HOST=%%B"
        if /I "%%A"=="SERVER_PORT"    set "SERVER_PORT=%%B"
        if /I "%%A"=="SERVER_WORKERS" set "SERVER_WORKERS=%%B"
    )
)

REM ---------- 5. 启动服务 ----------
echo.
echo [INFO] 启动 grok2api：http://%SERVER_HOST%:%SERVER_PORT%
echo [INFO] Admin 后台：    http://localhost:%SERVER_PORT%/admin/login
echo [INFO] 按 Ctrl+C 退出
echo.

granian --interface asgi --host %SERVER_HOST% --port %SERVER_PORT% --workers %SERVER_WORKERS% app.main:app

REM 服务退出后保留窗口便于查看错误
echo.
echo [INFO] 服务已停止
pause
endlocal
