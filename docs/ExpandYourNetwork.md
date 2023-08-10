# Ampliar una red Fabric existente con una nueva organización

Este documento describe el proceso de cómo hacer lo siguiente:

0. Configure dos sitios, uno se considera una red Fabric existente, el otro se considera una nueva organización
1. Agregue una nueva organización a la red Fabric existente.
2. Agregar peers de la nueva organización en el canal existente. 
3. Instale el chaincode que se ejecuta en los peers existentes en nuevos peers.
4. Aprobar y confirmar el chaincode.
5. Verifique los contenedores de endoso y chaincode.

Suponga que tiene dos directorios de trabajo, `mysite0` y `mysite1` en su directorio raíz. cada uno trabajando
directorio representará un sitio que puede incluir una o varias organizaciones y peers, los dos directorios de trabajo
puede muy bien estar en diferentes servidores, en ese caso, necesitará tener otros medios como `scp` para transferir
archivos necesarios entre servidores. Aquí están los dos archivos `spec.yaml`.

```
cat ~/mysite0/spec.yaml

fabric:
  peers:
  - "peer1.org0.foodtracking.com"
  - "peer2.org0.foodtracking.com"
  - "peer1.org1.foodtracking.com"
  - "peer2.org1.foodtracking.com"
  orderers:
  - "orderer1.foodtracking.com"
  - "orderer2.foodtracking.com"
  - "orderer3.foodtracking.com"

cat ~/mysite1/spec.yaml

fabric:
  peers:
  - "peer1.orgx.foodtracking.com"
  - "peer2.orgx.foodtracking.com"

```
 
## Abra ambos sitios usando los siguientes comandos

```
cd ~/mysite0
minifab up -e 7000 -n samplecc -p ''

cd ~/mysite1
minifab netup -e 7200 -o orgx.foodtracking.com
```

El primer comando muestra una red Fabric en ejecución completa con un canal llamado `mainchannel`
creado y un chaincode llamado `samplecc` instalado, aprobado, comiteado e inicializado. Hay
dos organizaciones peers y una organización orderer. Una vez que el comando finalizó con éxito, se está ejecutando completamente 
red Fabric y considere esto como una red Fabric existente.

El segundo comando abre una nueva organización con solo dos nodos peers. Sin canal, sin orden
nodos, solo dos nodos peers en ejecución.


## Unir a orgx.foodtracking.com al canal de aplicación con el siguiente paso

Dado que mysite1 tiene la organización orgx.foodtracking.com, el archivo producido
por Minifabric para unirse a una red existente se llamará `JoinRequest_orgx-example-com.json`
en el directorio `~/mysite1/vars`. Si tiene un nombre diferente para su organización, entonces el
El archivo de solicitud de unión tendrá un nombre de archivo diferente, haga los cambios correspondientes cuando ejecute los comandos.

```
cd ~/mysite0
sudo cp ~/mysite1/vars/JoinRequest_orgx-example-com.json ~/mysite0/vars/NewOrgJoinRequest.json
minifab orgjoin
```

## Importar nodos de pedidos a orgx.foodtracking.com y unir a peers de orgx.foodtracking.com al `mainchannel`
Para que los peers de orgx.foodtracking.com participen en la red Fabric, la organización debe saber dónde están los nodos orderers.
Para hacer eso, hacemos `nodeimport`

```
cd ~/mysite1
sudo cp ~/mysite0/vars/profiles/endpoints.yaml vars
minifab nodeimport,join
```

## Instalar y aprobar chaincode `samplecc` para peers orgx

```
cd ~/mysite1
minifab install,approve -n samplecc -p ''
```

## Aprobar el chaincode en org0 y org1
Dado que se unieron nuevas organizaciones, el chaincode deberá aprobarse nuevamente para que la nueva organización también pueda comprometerse
```
cd ~/mysite0
minifab approve,discover,commit
```

## Descubra y verifique el chaincode en orgx
```
cd ~/mysite1
minifab discover
```

Verifique que el archivo `./vars/discover/mainchannel/samplecc_endorsers.json` contenga el orgx como
grupo avalador.

```
cd ~/mysite1
minifab stats
```
El comando anterior debería mostrar que mysite1 debería tener un contenedor de chaincode como el siguiente
correr

```
  dev-peer1.orgx.foodtracking.com-samplecc_1.0-9ea5e3809f : Up 4 minutes
  dev-peer2.orgx.foodtracking.com-samplecc_1.0-9ea5e3809f : Up 4 minutes
```

## Para usar tu propio chaincode
Si desea utilizar su propio chaincode, debe tener el chaincode en el directorio vars/chaincode
y siga la estructura para formar chaincode. Luego use su propio chaincode en varios comandos.
