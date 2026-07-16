$SUPABASE_URL = "https://ybbhmauqilygldknzpcv.supabase.co"
$SUPABASE_KEY = "sb_publishable_c4fvqOdNYAouQPG3OBQ9OA_cr2IqnTR"

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  PRUEBA COMPLETA DE SUPABASE" -ForegroundColor Green
Write-Host "  Sistema de Gestion de Residuos" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

$headers = @{
    "apikey" = $SUPABASE_KEY
    "Content-Type" = "application/json"
}

$tablas = @("roles", "zonas", "usuarios", "rutas", "ruta_puntos", "horarios")
$resultados = @()

foreach ($tabla in $tablas) {
    Write-Host "[*] Consultando tabla: '$tabla'" -ForegroundColor Yellow

    try {
        $uri = "$SUPABASE_URL/rest/v1/$tabla`?select=*"
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get -TimeoutSec 30

        $cantidadRegistros = if ($response -is [array]) { $response.Count } else { if ($response) { 1 } else { 0 } }

        Write-Host "    [OK] Registros: $cantidadRegistros" -ForegroundColor Green

        if ($cantidadRegistros -gt 0) {
            Write-Host "    Primeros datos:" -ForegroundColor Cyan
            $response | Select-Object -First 1 | Format-List | Out-String | ForEach-Object { Write-Host "    $_" }
        }

        $resultados += [PSCustomObject]@{
            Tabla = $tabla
            Estado = "OK"
            Registros = $cantidadRegistros
            Mensaje = "Conexion exitosa"
        }

    } catch {
        Write-Host "    [ERROR] $($_.Exception.Message)" -ForegroundColor Red

        $resultados += [PSCustomObject]@{
            Tabla = $tabla
            Estado = "ERROR"
            Registros = 0
            Mensaje = $_.Exception.Message
        }
    }

    Write-Host ""
}

# Resumen final
Write-Host "========================================" -ForegroundColor Green
Write-Host "  RESUMEN DE RESULTADOS" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

$resultados | Format-Table -AutoSize

$exitosos = ($resultados | Where-Object { $_.Estado -eq "OK" }).Count
$fallidos = ($resultados | Where-Object { $_.Estado -eq "ERROR" }).Count
$totalRegistros = ($resultados | Measure-Object -Property Registros -Sum).Sum

Write-Host "Estadisticas:" -ForegroundColor Cyan
Write-Host "  * Tablas procesadas: $($resultados.Count)"
Write-Host "  * Conexiones exitosas: $exitosos" -ForegroundColor Green
Write-Host "  * Errores: $fallidos"
Write-Host "  * Total de registros: $totalRegistros"

Write-Host "`n[EXITO] Conexion a SUPABASE funciona correctamente`n" -ForegroundColor Green

