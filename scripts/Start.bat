@echo off
REM Double-click starter for ComfyUI (Windows). For low-VRAM GPUs add --lowvram after main.py.
cd /d "%~dp0..\tmp\ComfyUI"
if not exist "venv\Scripts\python.exe" (
  echo venv not found. Run scripts\Install.ps1 first.
  pause
  exit /b 1
)
venv\Scripts\python.exe main.py --listen 127.0.0.1 --port 8188 --enable-manager %*
pause
