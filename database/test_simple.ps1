$SUPABASE_URL = "https://ybbhmauqilygldknzpcv.supabase.co"
$SUPABASE_KEY = "sb_publishable_c4fvqOdNYAouQPG3OBQ9OA_cr2IqnTR"

Write-Host "`n========================================" -ForegroundColor Green
Write-Host " PRUEBA DE CONEXION A SUPABASE" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

# Hacer una consulta simple a la tabla roles
Write-Host "[*] Consultando tabla 'roles'..." -ForegroundColor Yellow
Write-Host "URL: $SUPABASE_URL/rest/v1/roles?select=*" -ForegroundColor Cyan

try {
    $uri = "$SUPABASE_URL/rest/v1/roles?select=*"
    $headers = @{
        "apikey" = $SUPABASE_KEY
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $SUPABASE_KEY"
    }

    Write-Host "Enviando solicitud..." -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get -TimeoutSec 30

    Write-Host "`n✅ CONEXION EXITOSA!" -ForegroundColor Green
    Write-Host "Registros recibidos: $($response.Count)" -ForegroundColor Green
    Write-Host "`nDatos:" -ForegroundColor Cyan
    $response | Format-Table -AutoSize

} catch {
    Write-Host "`n❌ ERROR EN LA CONEXION" -ForegroundColor Red
    Write-Host "Tipo de error: $($_.Exception.GetType().Name)" -ForegroundColor Red
    Write-Host "Mensaje: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nDetalles:" -ForegroundColor Yellow
    $_ | Select-Object -Property * | Format-List
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host " FIN DE LA PRUEBA" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

