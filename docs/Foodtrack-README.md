# Foodtracking

Foodtrackng es un sistema para seguir desde su manufactura hasta la entrega al cliente se deploya en una red Fabric Actualmente proporciona las siguientes funciones:

1. Deployar una red Fabric basado en esto  [spec](https://github.com/hyperledger-labs/minifabric/blob/main/spec.yaml) o [your own spec](#Setup-a-network-using-a-different-spec).
2. Bajar la red Fabric deployada.
3. Operaciones de canal como creación, actualización, unión de peers a canales, actualización de canales y consulta de canales.
4. Operaciones de Chaincode como instalar, aprobar, confirmar, actualizar, inicializar, instanciar, invocar y consultar.
5. Consultas de  blocks y transacciones.
6. Soporte de recopilación de datos privados.
7. Generacion de perfiles de conexión y archivos de billetera para SDK de go/node/python de fabric y extensiones de VS Code.
8. Soporte de métricas y estado del nodo de Fabric.
9. Integracion con Hyperledger Explorer y Caliper.
10.Ejecute aplicaciones que funcionan con la red Fabric

The table of the content
========================
1. [Prerequisitos](#prerequisites)
2. [Directorio de trabajo](#working-directory)
3. [Levantar la red Fabric](#stand-up-a-fabric-network)
4. [Bajar la red Fabric](#tear-down-the-fabric-network)
5. [El proceso normal del trabajo con Hyperledger Fabric](#the-normal-process-of-working-with-hyperledger-fabric)
6. [Configurar la red con distintos parametros](#setup-a-network-using-a-different-spec)
7. [Instalar su propio chaincode](#install-your-own-chaincode)
8. [Actualizar el chaincode](#upgrade-your-chaincode)
9. [Invocar metodos del chaincode](#invoke-chaincode-methods)
10. [Query blocks](#query-blocks)
11. [Actualizar la configuracion del canal](#update-the-channel-configuration)
12. [Agregar una nueva organizacion a la red Fabric](#add-a-new-organization-to-your-fabric-network)
13. [Verificar la salud y las metricas del nodo](#check-node-health-and-metrics)
14. [Contexto de ejecucion](#execution-context)
15. [Trabajar con los constructores de chaincodes personalizados](#working-with-customised-chaincode-builders)
16. [Actualizar minifabric](#update-minifabric)
17. [Ver mas comandos de  Minifabric](#see-more-available-minifabric-commands)
18. [Videos de Minifabric](#minifabric-videos)
19. [Construir loclmente minifabric](#build-minifabric-locally)
20. [Conectar Explorer a su red Fabric](#hook-up-explorer-to-your-fabric-network)
21. [Ejecute su aplicación rápidamente](#run-your-application-quickly)
22. [Ejectuar test de Caliper](#run-caliper-test)
23. [Levantar Portainer web ui](#start-up-portainer-web-ui)
24. [Usar la consola para operaciones de Fabric](#use-fabric-operation-console)

### Prerequisitos
Esta herramienta requiere  **docker CE 18.03** o superior, Minifabric corre en Linux, OS X y Windows 10

### Obtenga el script y hága que este disponible en todo el sistema
##### Ejecute el siguiente comando en Linux o OS X
```
mkdir -p ~/mywork && cd ~/mywork && curl -o minifab -sL https://tinyurl.com/yxa2q6yr && chmod +x minifab
```
##### Ejecute el siguiente comando en windows 10
```
mkdir %userprofile%\mywork & cd %userprofile%\mywork & curl -o minifab.cmd -sL https://tinyurl.com/y3gupzby
```
##### Haga que minifab este disponible en todo el sistema
Mueva el script `minifab` (Linux y OS X) o `minifab.cmd` (Windows) que acaba de descargar a un directorio que sea parte de su PATH de ejecución en su sistema o agregue el directorio que lo contiene a su PATH. Esto es para facilitar un poco las ejecuciones de Minifabric, podrá ejecutar el comando `minifab` en cualquier parte de su sistema sin especificar la PATH al script de `minifab`. Cuando se usa el término 'Minifabric', se refiere a la herramienta, cuando se usa el término 'minifabric', se refiere al comando Minifabric, que es el único comando que tiene Minifabric.
### Directorio de trabajo
Un directorio de trabajo es un directorio desde donde se deben ejecutar todos los comandos de Minifabric. Puede ser cualquier directorio en su sistema, Minifabric creará scripts en ejecución, plantillas, archivos intermedios en un subdirectorio llamado `vars` en este directorio de trabajo. Este es el directorio al que siempre puede ir para ver cómo Minifabric hace las cosas. Cree un directorio con el nombre que prefiera y cambie a ese directorio cuando comience a ejecutar los comandos de Minifabric. En toda la documentación de Minifabric, usamos `~/mywork` como directorio de trabajo; sin embargo, eso no significa que tenga que usar ese directorio como directorio de trabajo. Si usa un directorio diferente, simplemente reemplace cualquier referencia a este directorio con la suya.
### Levantar la red Fabric:

Para levantar una red Fabric, simplemente ejecute el comando `minifab up` en su directorio de trabajo. Cuando finalice el comando, debería tener una red Fabric funcionando normalmente con la última versión de Fabric (actualmente 2.3.0) en su máquina. También tendrá un canal de aplicación llamado `mainchannel` creado, todos los peers definidos en el archivo de configuracion de red se unieron a ese canal y un chaincode llamado `simple` instalado e instanciado. Este comando es el comando que debe usar si simplemente desea establecer una red Fabric con canal y chaincode, todo listo para el negocio. Dado que ejecuta la mayoría de las operaciones de red de Fabric, el proceso tardará alrededor de 4 minutos en completarse si tiene una conexión a Internet razonablemente buena porque el proceso también descargará las imágenes oficiales de Hyperledger Fabric de Docker Hub.
Si desea usar una versión diferente de Fabric, simplemente especifique la versión usando el indicador -i de la siguiente manera
```
minifab up -i 1.4.4
```
Minifabric es compatible con la versión 1.4.1 y posteriores de Fabric. Si desea cambiar a otra versión de Fabric, deberá ejecutar el comando `minifab cleanup`, luego `minifab up -i x.x.x` comando para garantizar que los certificados y los artefactos de canal se regeneren correctamente. Por ejemplo: 
 
 
```
minifab up -i 1.4.2
minifab cleanup
minifab up -i 2.0.0
```

### Bajar la red Fabric:
Puede usar uno de los dos comandos a continuación para bajar la red Fabric.

```
minifab down
minifab cleanup
```
El primer comando simplemente elimina todos los contenedores docker que componen la red Fabric, NO eliminará ningún certificado ni datos contables, puede ejecutar `minifab netup` más tarde para reiniciar todo, incluidos los contenedores de chaincode, si los hay. El segundo comando elimina todos los contenedores y limpia el directorio de trabajo.
### El proceso normal del trabajo con Hyperledger Fabric
Trabajar con Hyperledger Fabric puede ser intimidante al principio, la siguiente lista es para mostrarle el proceso normal de trabajo con Fabric:

    1. Levantar una red Fabric 
    2. Crear un canal
    3. Unir peers al canal 
    4. Instalar un chaincode en los peers
    5. Aprobar un chaincode (solo para la version 2.0)
    6. Confirmar o instanciar un chaincode
    7. Invocar metodos del chaincode (utilizando minifab o sus aplicaciones)
    8. Consulta sobre bloques
    
Si completa con éxito cada una de las tareas de la lista, básicamente ha verificado que su red Fabric funciona correctamente. Después de completar estas tareas, puede realizar algunas operaciones más avanzadas, como consulta de canal, aprobación de actualización de canal, actualización de canal. Si tiene varias redes Fabric creadas con minifabric, incluso puede usar el minifab para unirlas todas y crear una red Fabric más grande.

### Configurar la red con distintos parametros
Cuando simplemente hace `minifab up`, Minifabric usa el archivo de especificaciones de red `spec.yaml` en el directorio de trabajo para levantar una red Fabric. 
En muchos casos, probablemente desee utilizar diferentes nombres de organizaciones, nombres de nodos, cantidad de organizaciones, cantidad de peers, etc., para diseñar su propia red Fabric.

Si ya tiene una red Fabric ejecutándose en esta máquina, deberá eliminar la red Fabric en ejecución para evitar conflictos de nombres.
Cuando tenga su propio archivo de especificaciones de red, puede personalizar aún más su nodo utilizando la sección de configuración del archivo de especificaciones de red.
Puede tener una sección de `configuración` como la siguiente en su archivo de especificaciones.

```
  cas:
     ...
  peers:
     ...
  orderers:
     ...
  settings:
    ca:
      FABRIC_LOGGING_SPEC: ERROR
    peer:
      FABRIC_LOGGING_SPEC: INFO
    orderer:
      FABRIC_LOGGING_SPEC: DEBUG
```

Puede colocar cualquier parámetro de configuración de nodo ca, peer o orderer debajo de cada tipo de nodo.

- **Organization Name** para cada nodo es la parte del nombre de dominio después del primer punto (.)
- **mspid** para cada Organización es el Nombre de la Organización traducido sustituyendo cada punto (.) con un guión (-)
- **host:port** se genera como secuencias incrementales del número de puerto inicial (suministrado en -e 7778)
- el segundo puerto(`7061`) del peer se asignará al puerto de host de [1000 + número de puerto de host asignado de su primer puerto (`7051`)]

Por ejemplo, el siguiente es el resultado de spec.yaml predeterminado con`-e 7778`


> ca1.org0.foodtracking.com --> hostPort=7778
> ca1.org1.foodtracking.com --> hostPort=7779
> orderer1.foodtracking.com --> 0.0.0.0:7784->7050/tcp, 0.0.0.0:8784->7060/tcp   
> orderer2.foodtracking.com --> 0.0.0.0:7785->7050/tcp, 0.0.0.0:8785->7060/tcp
> orderer3.foodtracking.com --> 0.0.0.0:7786->7050/tcp, 0.0.0.0:8786->7060/tcp
> peer1.org0.foodtracking.com --> mspid = org0-example-com, organization name = org0.foodtracking.com, hostPort=7780, 8780
> peer2.org0.foodtracking.com --> mspid = org0-example-com, organization name = org0.foodtracking.com, hostPort=7781, 8781
> peer1.org1.foodtracking.com --> mspid = org1-example-com, organization name = org1.foodtracking.com, hostPort=7782, 8782
> peer2.org1.foodtracking.com --> mspid = org1-example-com, organization name = org1.foodtracking.com, hostPort=7783, 8783

De forma predeterminada, **docker network** se genera automáticamente en función del directorio de trabajo. Esto garantiza que dos directorios de trabajo diferentes darán como resultado dos redes acoplables diferentes. Esto le permite configurar varios sitios en la misma máquina para imitar varias organizaciones en varias máquinas.
Puede asignar un nombre de red docker descomentando la siguiente línea en el archivo spec.yaml. Esto le permite configurar fácilmente la capacidad de estructura en la red docker existente. Si tiene varios sitios en la misma máquina, será necesario tener un nombre diferente para cada sitio para evitar conflictos de red.
```
  # netname: "mysite"
```

```
  # container_options: "--restart=always --log-opt max-size=10m --log-opt max-file=3"
```
Puede agregar opciones para iniciar contenedores descomentando la siguiente línea en el archivo spec.yaml. puede especificar cualquier opción compatible con el comando 'docker run'.

Tenga en cuenta que el valor especificado por container_options se agregará cuando minifabric inicie todos los contenedores de tipo de nodo (CA, peer, orderer, cli) sin distinción.

### Instalar su propio chaincode
Para instalar su propio chaincode, cree el siguiente subdirectorio en su directorio de trabajo:
```
mkdir -p $(pwd)/vars/chaincode/<chaincodename>/<lang>
```
donde `<chaincodename>` debe ser el nombre que le da a su chaincode, y `<lang>` debe ser el idioma de su chaincode, ya sea go, node o java.
     

Su código debe estar en los siguientes directorios respectivamente según su nombre de chaincode y su idioma.




```
$(pwd)/vars/chaincode/<chaincodename>/go
$(pwd)/vars/chaincode/<chaincodename>/node
$(pwd)/vars/chaincode/<chaincodename>/java
```
Coloque el codigo fuente del chaincode en ese directorio, luego haga lo siguiente
```
minifab ccup -n <chaincodename> -l <lang> -v 1.0
```

Cuando desarrolla su propio chaincode para 1.4.x, es importante colocar todo su código en un paquete porque Fabric 1.4.x usa go 1.12.12, que no es totalmente compatible con los módulos y el código en los subdirectorios no se puede seleccionar. Para Fabric 2.0 o superior, se admiten los módulos go y puede tener algunos módulos locales con su propio chaincode. Si se encuentra en una ubicación sin acceso a repositorios públicos relacionados con golang (como los sitios alojados de Google), puede empaquetar su chaincode a con un directorio de proveedores que incluye todas las dependencias necesarias. Durante la instalación, Minifabric no intentará obtener las dependencias nuevamente.

En algunas áreas, cuando instala un chaincode escrito en golang, las dependencias no se pueden extraer directamente de los sitios alojados de Google. En ese caso, usted
lo más probable es que necesite usar goproxy para eludir estas restricciones. Puede hacerlo especificando un goproxy accesible en el archivo spec.yaml. El archivo spec.yaml predeterminado
tiene un ejemplo comentado, puede descomentar esa línea y usar su propio proxy go para instalar su chaincode escrito golang.
En el caso del chaincode que usa datos privados, el comando de instalación debe incluir el indicador -r o 
--chaincode-private seteado en `true`. 
```
minifab ccup -n <chaincodename> -l <lang> -v 1.0 -r true
```
Luego, minifab generará un archivo de configuración de recopilación de datos privados en el directorio `vars` con
el formato `<nombre de chaincode>_collection_config.json`. Este archivo necesita ser modificado para el específico
requisitos de su chaincode antes de continuar con los pasos de aprobación, confirmación e inicialización.
Alternativamente, se puede colocar un archivo de configuración de colección preconfigurado en el directorio `vars` usando el mismo
formato de nombre antes de la instalación, y minifab lo usará en lugar de crear el archivo predeterminado.

### Actualizacion del chaincode 
simplemente puede instalar el chaincode con un número de versión más alto, como se muestra a continuación en los siguientes casos: 
- cuando haya cambiado su chaincode y desee actualizar el chaincode instalado en su red Minifabric
- cuando el procedimiento de instalación del chaincode falló por algún motivo y desea intentar instalar el mismo chaincode nuevamente.

```
minifab ccup -v 2.0 [ -n simple ] [ -l go ]
minifab ccup -v 3.0 [ -n simple ] [ -l go ]

```

`minifab ccup` es en realidad el alias de los siguientes comandos. puede ejecutar los siguientes comandos separados paso a paso.

```
minifab install -v version [ -n <chaincodename> ] [ -l <lang> ] [ -r true ]
minifab approve
minifab commit
minifab initialize [ -p '"methodname","p1","p2",...' ]
minifab discover
minifab channelquery
```
en vez de :
```
minifab ccup -v version [ -n <chaicnodename> ] [ -l <lang> ] [ -r true ] [ -p '"methodname","p1","p2",...' ]
```

### Invoke chaincode methods
Minifab utiliza el parámetro -p para invocar un método de chaincode. El parámetro -p debe incluir el nombre del método y sus parámetros, el comando `minifab invocar` debe seguir este formato:

```
minifab invoke -n chaincodename -p '"methodname","p1","p2",...'
```

Dado que la invocación de chaincode depende en gran medida de cómo se desarrollaron los métodos de chaincode, es importante conocer la interfaz del método antes de intentar invocarlo. Los dos ejemplos siguientes invocan los métodos `invoke` y `query` del chaincode `simple`:

```
minifab invoke -n simple -p '"invoke","a","b","5"'
minifab invoke -p '"query","a"'
```

Tenga en cuenta que el valor del parámetro `-p` probablemente diferirá de un método a otro. Dado que Minifabric recuerda cada parámetro de comando en el contexto de ejecución, siempre puede omitir un parámetro de comando si el parámetro para el siguiente comando sigue siendo el mismo. Cuando no quiera que sean iguales, simplemente especifíquelos nuevamente en la línea de comando con el parámetro `-p` para cada invocación como en el siguiente ejemplo:

```
minifab invoke -n simple -p '"invoke","a","b","3"'
minifab invoke -p '"invoke","a","b","24"'
```

Observe el uso de comillas dobles y comillas simples, estas son muy importantes. No seguir esta convención probablemente producirá un error durante la invocación. Si está haciendo esto en un entorno de Windows, los parámetros de la línea de comando que contienen comillas dobles deberán reemplazarse con `\"`. Los dos comandos anteriores en Windows deberán ejecutarse como se muestra a continuación, observe que se eliminaron todas las comillas simples. :

```
minifab invoke -n simple -p \"invoke\",\"a\",\"b\",\"4\"
minifab invoke -p \"invoke\",\"a\",\"b\",\"24\"
```

### Query blocks
Minifab le permite consultar fácilmente su libro mayor. Para obtener el último bloque y las transacciones contenidas, ejecute los siguientes comandos:

```
minifab blockquery
minifab blockquery -b newest
minifab blockquery -b 6
```

Los dos primeros comandos hacen lo mismo y recuperan el bloque más reciente. El último comando recupera el número de bloque 7 (observe que el primer bloque es 0)

### Update the channel configuration
Para actualizar la configuración del canal, siga estos pasos:

```
   minifab channelquery
```

TEl comando anterior producirá un archivo JSON de configuración de canal en el directorio vars. El nombre del archivo será
`<nombre_del_canal>_config.json`. Una vez que encuentre ese archivo, puede continuar y realizar cambios en el archivo. Cuando esté satisfecho con los cambios, ejecute el siguiente comando:

```
   minifab channelsign,channelupdate
```
El comando anterior firmará la actualización de la configuración del canal usando todas las credenciales de administrador de las organizaciones y luego enviará el
transacción de actualización de configuración de canal. Cuando todo haya terminado con éxito, puede hacer otra "channelquery" para ver el
si los cambios toman efecto.

### Add a new organization to your Fabric network
Para agregar una nueva organización a su red, siga los pasos a continuación:

1. Obtenga la configuración del canal ejecutando el comando `minifab channelquery`. Este comando producirá un archivo llamado `./vars/<channel_name>_config.json`
2. Busque el archivo JoinRequest para la nueva organización que debería haber sido producido por Minifabric cuando Minifabric configuró la nueva organización en `vars` en su directorio de trabajo. Si su red no fue configurada por Minifabric, entonces debe crear este archivo por otros medios.
3. Edite el archivo `<channel_name>_config.json` y agregue todo el contenido del archivo JoinRequest al archivo de configuración del canal. Asegúrese de que el nuevo contenido se coloque en paralelo con las organizaciones existentes.
4. Ejecute el comando 'minifab channelsign,channelupdate'.

Una vez que todos los pasos se han realizado correctamente, la nueva organización ahora es parte de su canal. El administrador de la nueva organización ahora puede unir a sus peers a ese canal. Puede encontrar útil [el video que muestra cómo agregar una nueva organización a una red](https://www.youtube.com/watch?v=c1Ab57IrgZg&list=PL0MZ85B_96CExhq0YdHLPS5cmSBvSmwyO&index=5&t=3s).

### Check node health and metrics
Cuando Minifabric configura su red Fabric, habilita la salud y el
capacidades métricas. El puerto para servir el control de estado y las métricas normalmente se denomina puerto de operación, este puerto
es un puerto diferente al puerto GRPC del servicio de nodo Fabric. Minifabric siempre establece el puerto de operación en 7061
para peer y 7060 para orderer. Observe que el puerto GRPC de servicio predeterminado para el nodo par es 7051, el puerto predeterminado
El puerto para el nodo de pedido es 7050, Minifabric agrega 10 al puerto GRPC para el puerto de operación. cuando eliges
exponga los puntos finales del nodo fuera de su host (opción -e del comando minifab), el puerto de operación también se asignará a un puerto de host para que el puerto de operación sea accesible para las herramientas que se ejecutan fuera del host. Si elige no exponer los puntos finales, la salud y las métricas también se ocultarán desde fuera del host y solo se podrá acceder a ellos internamente. Para hacer las cosas un
Un poco más fácil, el puerto de operación para un nodo siempre será 1000 más alto que el puerto GRPC del nodo. Por ejemplo, si
un nodo par se ejecuta en el host docker que tiene la dirección IP 9.8.7.6 y su puerto GRPC 7051 está asignado a
7001, entonces el puerto de operación será 8001. Como se menciona en otra parte de esta documentación, tendrá que hacer
asegúrese de que el bloque de estos puertos en su host esté disponible. Usando el ejemplo anterior, puede acceder a la salud
y métricas en los siguientes puntos finales:


```
node:      9.8.7.6:8001
health:    9.8.7.6:9001/healthz
metrics:   9.8.7.6:9001/metrics
```

### Contexto de ejecucion 
Minifab utiliza muchas configuraciones a lo largo de todas las operaciones. Esta configuración se puede cambiar cada vez que ejecuta un comando minifab y esta configuración se guardará en el archivo vars/envsetting. Cada vez que se ejecuta un comando, ese archivo se cargará y la configuración especificada en la línea de comando se escribirá en ese archivo. Todas las configuraciones guardadas y especificadas en el comando crean el contexto de ejecución actual. Incluyen el nombre del chaincode los parámetros de invocación del chaincode la versión del chaincode el idioma del chaincode el nombre del canal, la versión de Fabric, la exposición del punto final y el número de consulta de bloque.

Todos los valores predeterminados los establece [envsettings](https://github.com/hyperledger-labs/minifabric/blob/main/envsettings). Cada uno de los valores se actualiza si se especifica en una línea de comando y se guarda en `./vars/envsettings`. Se desaconseja encarecidamente a los usuarios que cambien manualmente ese archivo, ya que es básicamente un script. Los cambios en ese archivo solo deben realizarse con el comando minifab.

Debido al contexto de ejecución, cuando ejecuta un comando, realmente no tiene que especificar todos los parámetros necesarios si no necesita cambiar el contexto. Por ejemplo, si acaba de ejecutar un comando de invocación de chaincode y desea ejecutar invocar nuevamente, entonces no necesita especificar el parámetro -n porque ya está en el contexto de ejecución actual. Lo mismo se aplica a todos los parámetros enumerados en ese archivo. No necesita especificar el parámetro en un comando a menos que tenga la intención de usar un nuevo valor en su comando. Una vez que lo haga, el nuevo valor se convierte en parte del contexto de ejecución actual.

### Working with customised chaincode builders
Fabric (v> 2.0) permite a los usuarios trabajar con generadores de chaincode personalizados y entornos de tiempo de ejecución. Esto es particularmente útil para los usuarios que operan dentro de redes restringidas porque las imágenes del generador de chaincode a menudo necesitan acceder a la web externa para operaciones como `npm install`. Una vez que haya creado una imagen acoplable personalizada, puede apuntar a minifab desde `spec.yaml`, p.
```
fabric:
  settings:
    peer:
      CORE_CHAINCODE_BUILDER: hyperledger/fabric-ccenv:my2.2
      CORE_CHAINCODE_NODE_RUNTIME: hyperledger/fabric-nodeenv:my2.2
```
donde  `hyperledger/fabric-nodeenv:my2.2` es el nombre y el tag de su imagen personalizada. Cambie `NODE` poe `GO` o `JAVA` para códigos de cadena escritos en esos idiomas, respectivamente. Tenga en cuenta que esto establece la variable de entorno en todos los nodos del mismo nivel (use varios spec.yaml en varios directorios para una aplicación de política más granular).


### Update minifabric
Minifabric evoluciona muy rápido. Siempre es una buena idea actualizar su Minifabric de vez en cuando simplemente ejecutando el siguiente script
```
curl -o minifab -L https://tinyurl.com/twrt8zv && chmod +x minifab
docker pull hyperledgerlabs/minifab:latest
```

### See more available Minifabric commands
```
minifab
```

### For the people who has trouble to download images from docker hub
Minifabric utiliza imágenes Docker oficiales de Hyperledger de Docker Hub. Extraerá automáticamente estas imágenes cuando las necesite. Para las personas con una conexión a Internet lenta, extraer imágenes puede ser extremadamente lento o casi imposible. Para evitar roturas debido a problemas de extracción de imágenes, puede extraer las siguientes imágenes de otros repositorios acoplables o usar diferentes medios para extraer estas imágenes, como, por ejemplo, escribir su propio script para extraer imágenes durante la noche. Mientras estas imágenes existan en su máquina, minifab no las volverá a extraer. Para ayudarte con esto, aquí está la lista de imágenes en caso de que quieras sacarlas por algún otro medio.

##### Fabric 2.0
```
hyperledgerlabs/minifab:latest
hyperledger/fabric-tools:2.0
hyperledger/fabric-peer:2.0
hyperledger/fabric-orderer:2.0
hyperledger/fabric-ccenv:2.0
hyperledger/fabric-baseos:2.0
hyperledger/fabric-ca:1.4
hyperledger/fabric-couchdb:latest
```

##### Fabric 1.4 which is an alias to 1.4.6
```
hyperledgerlabs/minifab:latest
hyperledger/fabric-ca:1.4
hyperledger/fabric-tools:1.4
hyperledger/fabric-ccenv:1.4
hyperledger/fabric-orderer:1.4
hyperledger/fabric-peer:1.4
hyperledger/fabric-couchdb:latest
hyperledger/fabric-baseos:amd64-0.4.18
```

Para otras versiones de Fabric que sean iguales o superiores a 1.4.1, reemplace la etiqueta según corresponda.

### Minifabric videos
Si desea obtener más información, mire la [serie de 6 videos sobre cómo desarrollar Hyperledger Fabric usando Minifabric](https://www.youtube.com/playlist?list=PL0MZ85B_96CExhq0YdHLPS5cmSBvSmwyO)

### Build minifabric locally
Minifabric cuando se instala en su sistema es realmente solo un script corto. Después de ejecutar al menos un comando minifab, una imagen acoplable denominada hyperledgerlabs/minifab:latest se extraerá automáticamente de Docker Hub. A lo largo del ciclo de vida de Minifabric, su sistema solo debe tener este script y la imagen de Docker. Para eliminar Minifabric, solo necesita eliminar el script y la imagen de Docker. Si desea crear la imagen de Docker usted mismo, siga los pasos a continuación, el proceso se aplica a Linux, OS X y Windows:

```
git clone https://github.com/hyperledger-labs/minifabric.git
cd minifabric
docker build -t hyperledgerlabs/minifab:latest .
```

### Hook up Explorer to your Fabric network
Si desea utilizar una interfaz de usuario para ver su red Fabric, las transacciones y los bloques, puede iniciar fácilmente Hyperledger Explorer ejecutando lo siguiente comando:

```
minifab explorerup
```
El ID de usuario y la contraseña de inicio de sesión para Explorer son `exploreradmin` y `exploreradminpw`
Para cerrar Explorer, simplemente ejecute el siguiente comando:

```
minifab explorerdown
```
Minifabric `cleanup` también cerrará Hyperledger Explorer.

### Run your application quickly
Si ya tiene su aplicación desarrollada, puede utilizar el comando apprun de Minifabric para ejecutarla rápidamente. Coloque todo su código en el directorio vars/app/node o vars/app/go, luego ejecute el comando `minifab apprun -l go` para la aplicación escrita en go, o ejecute el comando `minifab apprun -l node` para la aplicación escrita en nodo. Minifabric creará un entorno para ejecutar su aplicación. Minifabric viene con aplicaciones de muestra que invocan el chaincode samplecc. Si no tiene una aplicación, simplemente puede ejecutar la aplicación de muestra para ver cómo funcionan las cosas. Una vez que inicie el comando apprun, Minifabric colocará los archivos de conexión necesarios en el directorio de la aplicación, luego desplegará las dependencias y ejecutará su programa. Esta función es experimental y actualmente se admiten las aplicaciones escritas en go o node. Para probar su propia aplicación, reemplace el archivo main.go o main.js con su código, y posiblemente cambie el paquete.json o mod.go para que coincida con sus dependencias, luego ejecute el comando `minifab apprun`.

```
app
├── go.mod
├── go.sum
└── main.go
```

### Run Caliper test
Minifabric viene con un chaincode llamado samplecc escrito en go y una aplicación de muestra que invoca métodos de samplecc. Puede usar los siguientes dos comandos para ejecutar Hyperledger Caliper después de abrir su red de estructura.

```
minifab install,approve,commit,initialize -n samplecc -p ''
minifab caliperrun
```

Después de que finalicen los comandos, puede revisar el resultado en el archivo `vars/report.html` en el directorio de trabajo actual. Lo mejor es abrir este archivo en un navegador.
Si desea probar su propio chaincode la forma más fácil es instalar, aprobar, confirmar e inicializar su propio chaincode como cualquier otro chaincode utilizando los comandos de Minifabric. Luego, use su propio código de prueba para reemplazar el código en el archivo vars/app/callback/app.js, su propio código de nodo js debe seguir la estructura de devolución de llamada de Caliper; de lo contrario, el comando caliperrun ciertamente fallará. Una vez que su chaincode se haya instalado correctamente y su devolución de llamada esté en su lugar, ejecute el comando `minifab caliperrun` nuevamente para probar su chaincode.
El comando caliperrun ejecutará la prueba durante 60 segundos de forma predeterminada. Si desea cambiar la configuración predeterminada que establece Minifabric para ejecutar la prueba, puede cambiar el archivo vars/run/caliperbenchmarkconfig.yaml después del primero, ya que Minifabric crea este archivo solo cuando no existe dicho archivo. Puede personalizar este archivo de la forma que desee, realizar cambios en cualquier configuración disponible en este archivo y ejecutar el comando nuevamente. Todos los cambios que realice tendrán efecto la próxima vez que ejecute el comando.

### Start up portainer web ui
Mientras ejecuta su red Fabric, puede usar la administración basada en web de Portainer para ver e interactuar con su red en ejecución.
Para iniciar la interfaz de usuario web de Portainer, simplemente ejecute el comando `minifab portainerup`, para apagarlo, ejecute el comando `minifab portainerdown`

### Use Fabric operation console
Si desea utilizar la consola de operaciones de Fabric que IBM abrió recientemente, puede configurar su red de Fabric exponiendo los puntos finales y luego abrir la consola. Para ello, siga estos dos pasos:


```
   minifab up -e true
   minifab consoleup
```
El comando `consoleup` también creará un archivo de activos llamado assets.zip en vars/console
directorio. Este archivo contiene carteras de administración y varios certificados y puntos finales de
toda su red Fabric. Cuando inicia sesión en la consola, puede usar este archivo para importar
la información a la consola para continuar.

Para eliminar la consola y todos sus recursos relacionados, ejecute el siguiente comando:

```
   minifab consoledown
```
