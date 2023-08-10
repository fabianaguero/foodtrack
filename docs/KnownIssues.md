# Problemas conocidos
Este documento enumera los problemas conocidos que puede experimentar durante el funcionamiento de minifabric.

### Instalación del chaincode 
1. [Error al instalarel chaincode](#1)

### Kubernetes
1. [Error en el Service Endpoint](#2)

****
### PROBLEMA:

<a name="1"></a>Error: chaincode install failed with status: 500 - failed to invoke backing implementation of 'InstallChaincode'

### AMBIENTE:

Mac con Intel Chip / MacOS Big Sur 11.3.1 / Docker 20.10.6

### SOLUCION:

- Inicie el panel Docker
- Preferencias abiertas
- Haga clic en Funciones experimentales
- Deshabilitar Usar gRPC FUSE para compartir archivos
- Aplicar / Reiniciar

### Problemas relacionados: [#214](https://github.com/hyperledger-labs/minifabric/issues/214)  [#87](https://github.com/hyperledger-labs/minifabric/issues/87)

****

### PROBLEMA:

<a name="2"></a>ServiceEndpoint Error: Failed to connect to remote gRPC server x.x.x.x:xxxx, url:grpcs://localhost:xxxx

### AMBIENTE:

Kubernetes / K8S

### SOLUCION:

Al conectarse a la red de estructura implementada en el clúster de Kubernetes/K8S mediante los perfiles de conexión generados por minifabric con Fabric SDK, asegúrese de verificar que **GatewayOptions.discovery asLocalhost = false** como se muestra a continuación (de lo contrario, si se establece en **true **, el SDK se verá obligado a usar **localhost** al descubrir pares/pedidos).
```
 GatewayOptions = {
  wallet,
  identity: ca_admin,
  discovery: { enabled: true, asLocalhost: false }
}
```
### Problemas relacionados: [#215](https://github.com/hyperledger-labs/minifabric/issues/215)

****

### PROBLEMA:

<a name="2"></a>The file contains an identity that already exists.
### AMBIENTE:

fabric-operations-console - Docker or K8S
Cualquier plataforma - Linux or Mac or Windows

### SOLUCION:
Al intentar importar el archivo assets.zip como parte de la implementación de la consola de operaciones de Fabric en Minifabric, no es la primera vez que se encuentra con este mensaje de error y no puede realizar la importación del archivo zip correctamente.

La solución alternativa es navegar a la opción Wallet en la misma consola, eliminar las identidades ya almacenadas en el almacenamiento web del navegador y volver a importar el archivo assets.zip.

La razón por la que aparece este error se debe a las identidades que quedan en el almacenamiento web del navegador y al conflicto/nombre que choca con los mismos artefactos que ya están en el almacenamiento web.

### Problemas relacionados(s): 
