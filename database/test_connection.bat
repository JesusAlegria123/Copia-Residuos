@echo off
REM Script para probar la conexión a Supabase usando API REST

setlocal enabledelayedexpansion

set "SUPABASE_URL=https://gbpovfuiqbwjkdhgnyvi.supabase.co"
set "SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdicG92ZnVpcWJ3amtkaGdueXZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjc5MDcwMDksImV4cCI6MjA0MzQ4MzAwOX0.RN-SZi0g4ELn59_ov6oFqJYHR5zLZUCc-tBUqWMvY0U"

echo.
echo ========================================
echo  PRUEBA DE CONEXION A SUPABASE
echo ========================================
echo.

REM Prueba 1: Verificar conexión básica
echo [1] Probando conexión básica...
curl -s -X GET "!SUPABASE_URL!/rest/v1/roles?select=*" ^
  -H "apikey: !SUPABASE_KEY!" ^
  -H "Content-Type: application/json" > nul 2>&1

if errorlevel 1 (
  echo ❌ No se puede conectar a Supabase
  exit /b 1
) else (
  echo ✓ Conexión OK
)
echo.

REM Prueba 2: Obtener datos de roles
echo [2] Consultando tabla "roles"...
curl -s -X GET "!SUPABASE_URL!/rest/v1/roles?select=*" ^
  -H "apikey: !SUPABASE_KEY!" ^
  -H "Content-Type: application/json"
echo.
echo.

REM Prueba 3: Obtener datos de zonas
echo [3] Consultando tabla "zonas"...
curl -s -X GET "!SUPABASE_URL!/rest/v1/zonas?select=*" ^
  -H "apikey: !SUPABASE_KEY!" ^
  -H "Content-Type: application/json"
echo.
echo.

REM Prueba 4: Obtener datos de usuarios
echo [4] Consultando tabla "usuarios"...
curl -s -X GET "!SUPABASE_URL!/rest/v1/usuarios?select=*" ^
  -H "apikey: !SUPABASE_KEY!" ^
  -H "Content-Type: application/json"
echo.
echo.

REM Prueba 5: Obtener datos de rutas
echo [5] Consultando tabla "rutas"...
curl -s -X GET "!SUPABASE_URL!/rest/v1/rutas?select=*" ^
  -H "apikey: !SUPABASE_KEY!" ^
  -H "Content-Type: application/json"
echo.
echo.

echo ========================================
echo  PRUEBAS COMPLETADAS
echo ========================================
pause

