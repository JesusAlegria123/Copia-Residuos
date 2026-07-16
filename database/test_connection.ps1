# Script de prueba de conexión a Supabase

$SUPABASE_URL = "https://gbpovfuiqbwjkdhgnyvi.supabase.co"
$SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdicG92ZnVpcWJ3amtkaGdueXZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjc5MDcwMDksImV4cCI6MjA0MzQ4MzAwOX0.RN-SZi0g4ELn59_ov6oFqJYHR5zLZUCc-tBUqWMvY0U"

Write-Host "`n========================================" -ForegroundColor Green
Write-Host " PRUEBA DE CONEXION A SUPABASE" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

$headers = @{
    "apikey" = $SUPABASE_KEY
    "Content-Type" = "application/json"
}

# Prueba 1: Roles
Write-Host "[1] Consultando tabla 'roles'..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/rest/v1/roles?select=*" -Headers $headers -Method Get
    Write-Host "✓ Exito - Registros encontrados: $($response.Count)" -ForegroundColor Green
    Write-Host "Datos: $($response | ConvertTo-Json)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Prueba 2: Zonas
Write-Host "[2] Consultando tabla 'zonas'..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/rest/v1/zonas?select=*" -Headers $headers -Method Get
    Write-Host "✓ Exito - Registros encontrados: $($response.Count)" -ForegroundColor Green
    Write-Host "Datos: $($response | ConvertTo-Json)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Prueba 3: Usuarios
Write-Host "[3] Consultando tabla 'usuarios'..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/rest/v1/usuarios?select=*" -Headers $headers -Method Get
    Write-Host "✓ Exito - Registros encontrados: $($response.Count)" -ForegroundColor Green
    Write-Host "Datos: $($response | ConvertTo-Json)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Prueba 4: Rutas
Write-Host "[4] Consultando tabla 'rutas'..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/rest/v1/rutas?select=*" -Headers $headers -Method Get
    Write-Host "✓ Exito - Registros encontrados: $($response.Count)" -ForegroundColor Green
    Write-Host "Datos: $($response | ConvertTo-Json)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Prueba 5: Ruta Puntos
Write-Host "[5] Consultando tabla 'ruta_puntos'..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/rest/v1/ruta_puntos?select=*" -Headers $headers -Method Get
    Write-Host "✓ Exito - Registros encontrados: $($response.Count)" -ForegroundColor Green
    Write-Host "Datos: $($response | ConvertTo-Json)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Prueba 6: Horarios
Write-Host "[6] Consultando tabla 'horarios'..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/rest/v1/horarios?select=*" -Headers $headers -Method Get
    Write-Host "✓ Exito - Registros encontrados: $($response.Count)" -ForegroundColor Green
    Write-Host "Datos: $($response | ConvertTo-Json)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host " PRUEBAS COMPLETADAS" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

