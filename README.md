# Minifabric 

![MiniFab CI](https://github.com/hyperledger-labs/minifabric/workflows/MiniFab%20CI/badge.svg)
[![Discord](https://img.shields.io/discord/905194001349627914?logo=Hyperledger&style=plastic)](https://discord.gg/hyperledger)

[中文](https://github.com/hyperledger-labs/minifabric/blob/main/README.zh.md)

Si desea aprender Hyperledger Fabric o desarrollar su contrato inteligente, o simplemente quiere tener una idea de Hyperledger Fabric, Minifabric es la herramienta para comenzar. Minifabric puede soportar una red Fabric en una máquina pequeña como una máquina virtual VirtualBox, pero también puede implementar redes Fabric en múltiples servidores de grado de producción. Minifabric ha sido probado en Linux, OS X, Windows 10 y es compatible con las versiones 1.4.4 o posteriores de Fabric.

## Características destacadas

Minifabric es pequeño pero le permite experimentar el pleno
capacidades de Hyperledger Fabric.

- Configuración y expansión de la red fabric, como la adición de nuevas organizaciones.
- Consulta de canal, crear, unirse, actualizar canal.
- Instalación, aprobación, creación de instancias, invocación, consulta y recopilación de datos privados de chaincode.
- Tamaño del ledger y consulta de bloques y compatibilidad con Hyperledger Explorer.
- Monitoreo de nodos, verificación de estado y descubrimiento.
- Nunca contamines tu medio ambiente.

## Prerequisitos
[docker](https://www.docker.com/) (18.03 o superior ) environment

5 GB de almacenamiento de disco disponible
## Comenzando   

Si desea obtener más información antes de chomenzar , mire  [series of 6 videos](https://www.youtube.com/playlist?list=PL0MZ85B_96CExhq0YdHLPS5cmSBvSmwyO) sobre cómo desarrollar Hyperledger Fabric utilizando Minifabric y leer el [blog](https://www.hyperledger.org/blog/2020/04/29/minifabric-a-hyperledger-fabric-quick-start-tool-with-video-guides). Para aquellos impacientes, siga los pasos a continuación para comenzar.
### 1.Obtener el script .

##### Si está utilizando Linux (Ubuntu, Fedora, CentOS) u OS X
```
mkdir -p ~/mywork && cd ~/mywork && curl -o minifab -sL https://tinyurl.com/yxa2q6yr && chmod +x minifab
```

##### Si está utilizando Windows 10
```
mkdir %userprofile%\mywork & cd %userprofile%\mywork & curl -o minifab.cmd -sL https://tinyurl.com/y3gupzby
```

##### Hacer que minifab esté disponible en todo el sistema

Mueva el script minifab (Linux y OS X) o minifab.cmd (Windows) a un directorio que sea parte de su RUTA de ejecución en su sistema o agregue el directorio que lo contiene a su RUTA. Esto es para facilitar un poco las operaciones posteriores, podrá ejecutar el comando minifab en cualquier lugar de su sistema sin especificar la ruta al script minifab.

### 2. Levantar la red fabric :

```
minifab up
```

### 3. Bajar la red de fabric y limpiar todo el entorno :
```
minifab cleanup
```

### 4. Para aprender otras funciones de minifab:
```
minifab
```

## Documentacion 
Para saber más sobre MiniFabric, ver en [docs](./docs/README.md)

## Problemas conocidos
Para conocer más detalles, ver en [KnownIssues](./docs/KnownIssues.md)
