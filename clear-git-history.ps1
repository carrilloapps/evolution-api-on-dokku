## Script para borrar el historial de Git manteniendo los archivos actuales
## ADVERTENCIA: Este script eliminará permanentemente todo el historial de commits.
## Autor: GitHub Copilot
## Fecha: 20 mayo 2025

# Cambiar al directorio del repositorio
Set-Location -Path "d:\Proyectos\Docker\evo-api-coolify"

# Verificar que estamos en un repositorio Git
if (-not (Test-Path -Path ".git")) {
    Write-Host "Error: No se encontró un repositorio Git en el directorio actual." -ForegroundColor Red
    exit 1
}

# Preguntar confirmación al usuario
Write-Host "ADVERTENCIA: Este script eliminará PERMANENTEMENTE todo el historial de commits." -ForegroundColor Yellow
Write-Host "Los archivos actuales se mantendrán intactos, pero todo el historial de cambios se perderá." -ForegroundColor Yellow
Write-Host "Esta acción NO SE PUEDE DESHACER." -ForegroundColor Red
$confirmacion = Read-Host "¿Estás seguro de que quieres continuar? (escribe 'SI' para confirmar)"

if ($confirmacion -ne "SI") {
    Write-Host "Operación cancelada por el usuario." -ForegroundColor Cyan
    exit 0
}

try {
    # Guardar la URL remota (si existe)
    $remoteUrl = git config --get remote.origin.url

    # Guardar la rama actual
    $currentBranch = git rev-parse --abbrev-ref HEAD

    # Crear una rama temporal
    Write-Host "Creando una rama temporal..." -ForegroundColor Cyan
    git checkout --orphan temp_branch

    # Añadir todos los archivos al stage
    Write-Host "Preparando archivos actuales..." -ForegroundColor Cyan
    git add -A

    # Crear un commit inicial
    Write-Host "Creando commit inicial..." -ForegroundColor Cyan
    git commit -m "Initial commit - historial eliminado por seguridad"

    # Eliminar todas las ramas excepto la temporal
    Write-Host "Eliminando ramas anteriores..." -ForegroundColor Cyan
    $branches = git branch | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "temp_branch" -and $_ -ne "*temp_branch" }
    foreach ($branch in $branches) {
        git branch -D $branch
    }

    # Renombrar la rama temporal a la rama principal (main o master)
    Write-Host "Recreando rama principal..." -ForegroundColor Cyan
    git branch -m $currentBranch

    # Si había un remoto, forzar el push (esto sobrescribirá el historial remoto)
    if ($remoteUrl) {
        Write-Host "ATENCIÓN: Se encontró un repositorio remoto." -ForegroundColor Yellow
        Write-Host "Para actualizar el repositorio remoto, deberás ejecutar el siguiente comando:" -ForegroundColor Yellow
        Write-Host "git push -f origin $currentBranch" -ForegroundColor Green
        
        $pushConfirmation = Read-Host "¿Quieres hacer push forzado al repositorio remoto ahora? (escribe 'SI' para confirmar)"
        if ($pushConfirmation -eq "SI") {
            Write-Host "Realizando push forzado al repositorio remoto..." -ForegroundColor Cyan
            git push -f origin $currentBranch
            Write-Host "Push completado. El historial remoto ha sido reemplazado." -ForegroundColor Green
        } else {
            Write-Host "No se ha realizado el push. Recuerda hacerlo manualmente cuando estés listo." -ForegroundColor Cyan
        }
    }

    # Limpieza y optimización del repositorio
    Write-Host "Realizando limpieza y optimización final..." -ForegroundColor Cyan
    git gc --aggressive --prune=now

    Write-Host "¡Proceso completado con éxito!" -ForegroundColor Green
    Write-Host "El historial de commits ha sido eliminado, pero los archivos actuales se mantienen intactos." -ForegroundColor Green
    
} catch {
    Write-Host "Error durante el proceso: $_" -ForegroundColor Red
    Write-Host "El script no pudo completarse correctamente." -ForegroundColor Red
}
