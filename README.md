# Evolution API - Dokku

Evolution API v2.2.0 para WhatsApp desplegado en Dokku con PostgreSQL.

## 📋 Requisitos Previos

- Servidor con Dokku instalado y configurado
- Acceso SSH al servidor
- Git configurado localmente
- Dominio apuntando al servidor (opcional)

## 🚀 Instalación Desde Cero

### Paso 1: Clonar o Crear el Repositorio Local

```bash
# Si ya tienes el repo
git clone <tu-repo-url>
cd evolution-api-coolify

# O crear uno nuevo desde estos archivos
mkdir evolution-api-dokku
cd evolution-api-dokku
git init
# Copiar los archivos: Dockerfile, app.json, docker-compose.yaml, etc.
```

### Paso 2: Conectar al Servidor Dokku (SSH)

```bash
ssh root@tu-servidor
# O si usas usuario dokku:
ssh dokku@tu-servidor
```

### Paso 3: Crear la Aplicación en Dokku

```bash
# Crear la app llamada "evo"
dokku apps:create evo
```

### Paso 4: Instalar y Configurar PostgreSQL

```bash
# Instalar el plugin de PostgreSQL (solo primera vez en el servidor)
dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres

# Crear servicio PostgreSQL con el mismo nombre que la app
dokku postgres:create evo

# Vincular PostgreSQL a la aplicación
dokku postgres:link evo evo
```

Esto crea automáticamente la variable `DATABASE_URL`.

### Paso 5: Configurar Variable de Conexión a Base de Datos

```bash
# Configurar DATABASE_CONNECTION_URI usando el valor de DATABASE_URL
dokku config:set evo DATABASE_CONNECTION_URI="$(dokku config:get evo DATABASE_URL)"
```

### Paso 6: Configurar Puertos

```bash
# Mapear puerto 80 (externo) al 8080 (interno del contenedor)
dokku ports:set evo http:80:8080
```

### Paso 7: Configurar Almacenamiento Persistente

```bash
# Crear directorio para almacenamiento persistente
dokku storage:ensure-directory evo

# Montar volumen para instancias de WhatsApp
dokku storage:mount evo /var/lib/dokku/data/storage/evo:/evolution/instances
```

### Paso 8: Salir del Servidor

```bash
exit
```

### Paso 9: Agregar Remoto de Dokku (En tu Máquina Local)

```bash
# Agregar remoto de Dokku
git remote add dokku dokku@tu-servidor:evo

# O si usas root:
git remote add dokku root@tu-servidor:evo
```

### Paso 10: Desplegar la Aplicación

```bash
# Asegurarte de que todos los archivos están commiteados
git add .
git commit -m "Deploy Evolution API to Dokku"

# Hacer push a Dokku
git push dokku master
# O si tu rama principal es "main":
git push dokku main:master
```

¡Listo! La aplicación se desplegará automáticamente.

## ✅ Verificar el Deploy

### Ver Logs en Tiempo Real

```bash
ssh dokku@tu-servidor
dokku logs evo -t
```

### Ver Configuración

```bash
dokku config evo
```

Deberías ver todas las variables de entorno configuradas, incluyendo:
- `DATABASE_URL`
- `DATABASE_CONNECTION_URI`
- `DATABASE_PROVIDER=postgresql`
- `CACHE_REDIS_ENABLED=false`
- `CACHE_LOCAL_ENABLED=false`

### Obtener API Key

```bash
dokku config:get evo AUTHENTICATION_API_KEY
```

### Ver Estado de la Aplicación

```bash
dokku ps:report evo
```

## 🌐 Acceder a la Aplicación

Después del deploy exitoso, tu aplicación estará disponible en:

- **Con dominio configurado:** `http://tu-dominio.com`
- **Sin dominio:** `http://tu-servidor-ip`

La API escucha en el puerto configurado (80 por defecto).

### Probar la API

```bash
curl http://tu-dominio.com
```

Deberías recibir una respuesta de Evolution API.

## 🔐 Configurar SSL (Opcional pero Recomendado)

```bash
# Instalar plugin de Let's Encrypt (solo primera vez)
sudo dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git

# Configurar email
dokku letsencrypt:set evo email tu@email.com

# Habilitar SSL
dokku letsencrypt:enable evo

# Configurar renovación automática
dokku letsencrypt:cron-job --add
```

Ahora tu app estará en `https://tu-dominio.com`.

## 🔧 Comandos Útiles

### Logs y Monitoreo

```bash
# Ver logs en tiempo real
dokku logs evo -t

# Ver últimos logs
dokku logs evo

# Ver reporte completo
dokku ps:report evo
```

### Gestión de la Aplicación

```bash
# Reiniciar app
dokku ps:restart evo

# Detener app
dokku ps:stop evo

# Iniciar app
dokku ps:start evo

# Reconstruir app
dokku ps:rebuild evo
```

### Configuración

```bash
# Ver todas las variables
dokku config evo

# Ver una variable específica
dokku config:get evo DATABASE_URL

# Agregar/modificar variable
dokku config:set evo NUEVA_VARIABLE="valor"

# Eliminar variable
dokku config:unset evo VARIABLE
```

### PostgreSQL

```bash
# Ver información de PostgreSQL
dokku postgres:info evo

# Conectar a PostgreSQL
dokku postgres:connect evo

# Backup de PostgreSQL
dokku postgres:backup evo backup-$(date +%Y%m%d)

# Restaurar backup
dokku postgres:import evo < backup.sql

# Ver logs de PostgreSQL
dokku postgres:logs evo -t
```

### Dominios

```bash
# Agregar dominio personalizado
dokku domains:add evo tu-dominio.com

# Ver dominios configurados
dokku domains:report evo

# Eliminar dominio
dokku domains:remove evo tu-dominio.com
```

### Almacenamiento

```bash
# Ver volúmenes montados
dokku storage:report evo

# Agregar más volúmenes
dokku storage:mount evo /host/path:/container/path
```

## 🔄 Actualizaciones

Para actualizar la aplicación:

```bash
# En tu máquina local
git pull origin master  # Obtener últimos cambios
git push dokku master   # Desplegar a Dokku
```

Dokku automáticamente:
1. Construye la nueva imagen
2. Ejecuta las migraciones de Prisma
3. Hace health checks
4. Reemplaza el contenedor antiguo con el nuevo

## 🐛 Troubleshooting

### Error: "Database provider invalid"

```bash
# Verificar que DATABASE_PROVIDER está configurado
dokku config:get evo DATABASE_PROVIDER

# Si está vacío, configurarlo
dokku config:set evo DATABASE_PROVIDER="postgresql"
```

### Error: "Can't reach database server"

```bash
# Verificar DATABASE_CONNECTION_URI
dokku config:get evo DATABASE_CONNECTION_URI

# Reconfigurar desde DATABASE_URL
dokku config:set evo DATABASE_CONNECTION_URI="$(dokku config:get evo DATABASE_URL)"
```

### Health Check Falla

```bash
# Ver logs del contenedor
dokku logs evo -t

# Verificar que el puerto está correcto
dokku ports:list evo

# Reintentar deployment
dokku ps:rebuild evo
```

### PostgreSQL No Conecta

```bash
# Verificar que el servicio está corriendo
dokku postgres:info evo

# Verificar el link
dokku postgres:links evo

# Re-vincular si es necesario
dokku postgres:unlink evo evo
dokku postgres:link evo evo
```

## 📚 Documentación Adicional

- [Evolution API](https://doc.evolution-api.com/)
- [Dokku Docs](https://dokku.com/docs/)
- [Dokku PostgreSQL Plugin](https://github.com/dokku/dokku-postgres)

## 🌟 Características

- ✅ Solo PostgreSQL (sin Redis/Cache)
- ✅ Despliegue automático con health checks
- ✅ Migraciones de Prisma automáticas
- ✅ Almacenamiento persistente para instancias
- ✅ Variables de entorno pre-configuradas
- ✅ SSL con Let's Encrypt

## 📝 Notas

- **API Key**: Se genera automáticamente en el primer deploy
- **Puerto interno**: La app escucha en el puerto 8080
- **Puerto externo**: Dokku mapea al puerto 80 (o 443 con SSL)
- **Base de datos**: PostgreSQL gestionado por Dokku
- **Cache**: Deshabilitado (CACHE_REDIS_ENABLED=false, CACHE_LOCAL_ENABLED=false)
- **Backups**: Configurar backups periódicos de PostgreSQL con cron
