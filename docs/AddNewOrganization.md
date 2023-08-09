#  Agregar una nueva organización a la red existente

Normalmente hay dos casos diferentes para agregar una nueva organización a una red de estructura en ejecución. Ambos casos son esencialmente las operaciones de actualización de la configuración del canal. Si una nueva organización entra en el canal de la aplicación, entonces la nueva organización no podrá crear nuevos canales. Si una nueva organización entra en el canal del sistema, entonces la nueva organización podrá
crear nuevos canales.

1. [Nueva organización al canal de aplicaciones de manera fácil](#new-organization-to-application-channel-easy-way)
2. [Nueva organización al canal del sistema](#new-organization-to-system-channel)
3. [Nueva organización al canal de aplicación (Manera rápida)](#new-organization-to-application-channel)

### Nueva organización al canal de aplicaciones de manera fácil

Busque el archivo json JoinRequest de la nueva organización y guárdelo como `vars/NewOrgJoinRequest.json`.
Si estás usando  el comando ` minifabric netup`  que configura la nueva organización, ese archivo se creará en el directorio `vars` del directorio de trabajo. Si está utilizando otros medios para configurar una nueva organización, entonces lo más probable tengas que crear manualmente el archivo

Ejecute el siguiente comando :

```
  minifab orgjoin
```

Este comando recuperará la configuración del canal actual, luego fusionará la solicitud de la nueva organización, finalmente cierre la sesión del canal y actualice el canal. Una vez hecho esto, puede hacer `minifab channelquery` para verificar que la nueva organización es parte del canal.

### Nueva organización al canal del sistema
1. Use el comando minifab channelquery para obtener la configuración del canal del sistema
```
   minifab channelquery -c systemchannel
```
El comando anterior debería producir un archivo llamado  `vars/systemchannel_config.json ` .

2. Encuentre la nueva configuración de la organización, si está utilizando minifabric para levantar una nueva organización, entonces ya debería tener el archivo en el directorio `vars` en el host donde se ejecutó minifabric, cada organización debe tener un archivo JoinRequest. Los nombres de estos
los archivos deben seguir un patrón como este:

```
   JoinRequest_<organization msp id>.json

   Por ejemplo:
   JoinRequest_org50-example-com.json
```

Coloque el nuevo archivo de configuración de la organización en el directorio de trabajo. En todos los siguientes pasos, asumimos que el nuevo archivo de configuración de la organización se llama `JoinRequest_org50-example-com.json`

3. Una vez que tenga el archivo json de configuración del canal del sistema y la nueva configuración de la organización archivos listos, ejecute el siguiente comando una línea larga para producir un nuevo archivo de configuración de canal.
```
  jq -s '.[0] * {"channel_group":{"groups":{"Consortiums":{"groups":{"SampleConsortium":{"groups":
  {(.[1].values.MSP.value.config.name): .[1]}}}}}}}' vars/systemchannel_config.json
  JoinRequest_org50-example-com.json |
  jq -s '.[0] * {"channel_group":{"groups":{"Consortiums":{"groups":{"SampleConsortium":{"version":
  (.[0].channel_group.groups.Consortiums.groups.SampleConsortium.version|tonumber + 1)|tostring }}}}}}' > updatedchannel.json
```

El comando anterior asume que el consorcio se llama `SampleConsortium`.Cuando configura la red fabric usando minifabric, el nombre del canal del sistema es `systemchannel`, el nombre del consorcio es `SampleConsortium``. Si su red Fabric no fue configurada por minifabric, el nombre del canal de su sistema y el nombre del consorcio pueden ser diferentes..
Dado que está agregando un elemento al archivo json de configuración del canal, deberá aumentar el número de versión del elemento que cambio, en este caso, el elemento es channel_group.groups.Consortiums.groups.SampleConsortium. Ahora use `updatedchannel.json` para sobrescribir `vars/systemchannel_config.json`.

```
  sudo cp updatedchannel.json vars/systemchannel_config.json
```

5.Ahora simplemente ejecute el siguiente comando para que la nueva organización forme parte del canal de la aplicación.

```
   minifab channelsign,channelupdate -c systemchannel
```

Si tiene organizaciones distribuidas en varios hosts, deberá ejecutar channelsign en los hosts que constituyen la mayoría de los canales o la cantidad requerida de organizaciones según la política de respaldo de su canal. El archivo firmado deberá pasarse de una organización a otra para que se recopilen todos los endorsements. cuando se ejecuta el comando de actualización de canal.

### Nueva organización al canal de aplicación.

1. Use el comando minifab channelquery para obtener una configuración de canal existente.
```
   minifab channelquery -c mainchannel
```
El comando anterior debería producir un archivo llamado `vars/mainchannel_config.json`.

2. Encuentre la nueva configuración de la organización, si está utilizando minifabric para levantar una nueva organización, entonces ya debería tener el archivo en el directorio `vars `en el host donde
se ejecutó minifabric, cada organización debe tener un archivo `JoinRequest`. Los nombres de estos
los archivos deben seguir el patrón como este:

```
   JoinRequest_<organization msp id>.json

   Por ejemplo:
   JoinRequest_org50-example-com.json
```

Coloque el nuevo archivo de configuración de la organización en el directorio de trabajo. En todos los siguientes pasos, asumimos que el nuevo archivo de configuración de la organización se llama `JoinRequest_org50-example-com.json`.

3. Una vez que tenga el archivo json de configuración del canal y la nueva configuración de la organización
archivos listos, ejecute el siguiente comando para generar un nuevo archivo de configuración de canal.
```
  jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {(.[1].values.MSP.value.config.name): .[1]}}}}}'
  vars/mainchannel_config.json JoinRequest_org50-example-com.json |
  jq -s '.[0] * {"channel_group":{"groups":{"Application":{"version":
  (.[0].channel_group.groups.Application.version|tonumber + 1)|tostring }}}}' > updatedchannel.json
```

Dado que está agregando un elemento json a un elemento en el archivo de configuración del canal, tendrá
para aumentar el número de versión del elemento que cambio, en este caso, el elemento es
`channel_group.groups.Application`. Verifique que la nueva organización ahora sea parte del archivo `newchannel.json`
y también asegúrese de que la versión del elemento haya aumentado en 1. Ahora use el canal `actualizado.json`
para sobrescribir `vars/mainchannel_config.json`.

```
  sudo cp updatedchannel.json vars/mainchannel_config.json
```

4. Ahora simplemente ejecute el siguiente comando para que la nueva organización forme parte del canal de la aplicación
```
   minifab channelsign,channelupdate
```

Si tiene organizaciones distribuidas en varios hosts, deberá ejecutar channelsign en los hosts.
que constituyen la mayoría de los canales o la cantidad requerida de organizaciones según la política de respaldo de su canal.
El archivo firmado deberá pasarse de una organización a otra para que se recopilen todos los endosos.
cuando se ejecuta el comando de actualización de canal.
