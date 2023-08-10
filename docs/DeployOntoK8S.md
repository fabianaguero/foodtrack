# Use Minifabric para implementar Hyperledger Fabric en Kubernetes

Para implementar una red de Hyperledger Fabric en Kubernetes mediante Minifabric
no hay diferencia que implementar Fabric en un entorno Docker local. El
El único requisito es tener un clúster de Kubernetes en funcionamiento y un 
Nginx Ingress controller.

Siga los siguientes pasos para implementar Fabric en Kubernetes:

### 1. Obtenga Minifabric (el mismo proceso que se describe en el archivo principal README.md)

##### Si está utilizando Linux (Ubuntu, Fedora, CentOS) u OS X
```
mkdir -p ~/mywork && cd ~/mywork && curl -o minifab -sL https://tinyurl.com/yxa2q6yr && chmod +x minifab
```

##### Si está utilizando Windows 10
```
mkdir %userprofile%\mywork & cd %userprofile%\mywork & curl -o minifab.cmd -sL https://tinyurl.com/y3gupzby
```

##### Hacer que minifab esté disponible en todo el sistema

Mueva el script minifab (Linux y OS X) o minifab.cmd (Windows) a un directorio que sea parte de su PATH de ejecución en su sistema o agregue el directorio que lo contiene a su PATH. Esto es para facilitar un poco las operaciones posteriores, podrá ejecutar el comando minifab en cualquier lugar de su sistema sin especificar la PATH al script minifab.

### 2. Entorno Docker donde ejecuta Minifabric

Minifabric en sí mismo está en contenedores. Cuando está funcionando, usa docker. Si no lo hace
tiene Docker ejecutándose en la máquina en la que planea ejecutar Minifabric, debe instalar docker
18.01 o posterior. Sin Docker, Minifabric no funcionará.

### 3. Prepare su archivo de configuración kube

Minifabric depende del archivo de configuración de kube para realizar conexiones a un Kubernetes en ejecución
grupo. Debe tener un archivo de configuración de kube listo como Minifabric vars/kubeconfig/config.
El archivo debe tener un permiso de lectura por parte del usuario root. Obtener su archivo de configuración de kube es
depende de la nube, consulte cada nube diferente sobre cómo obtener el archivo. Típicamente
necesitaría ejecutar un comando específico de la nube como `gcloud`, `ibmcloud`, `az`, `aws`
etc. Una vez que use un comando diferente para iniciar sesión, debe ejecutar `kubectl get nodes`
para verificar que efectivamente puede acceder al clúster. Minifabric en sí no usa `kubectl`,
hacer referencia aquí es para que usted verifique que ciertamente puede iniciar sesión en el clúster.
El comando `kubectl` normalmente producirá un archivo de configuración de kube que se guarda en `~/.kube/config`
debería poder copiar directamente ese archivo en el directorio `vars/kubeconfig/` de Minifabric
ya que ese archivo contiene token de acceso.


### 4. (condicional) consideración de proxy http
Si existe un proxy http entre su máquina operativa y kubernetes,
necesita sigue esta sección. de lo contrario, pase a la siguiente sección.

más concretamente, cuando tu caso sea:
- configure la estructura desde su oficina, en el clúster de kubernetes administrado en la nube => siga esta sección
- configure la estructura desde su oficina, en el clúster de kubernetes local => salte a la siguiente sección.
- otros casos => tal vez pase a la siguiente sección.

en la actualidad, necesita establecer las siguientes variables de entorno en el shell del terminal.

en linux:
```bash
#
export https_proxy=http://yourID:yourPass@yourProxyhost:port/
# you can use no_proxy environment variable as usuall.
export no_proxy=localhost,127.0.0.1/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,*.local,*.yourdomain.com

# for kubernetes operation via ansible
export K8S_AUTH_PROXY=http://yourProxyhost:port/
export K8S_AUTH_PROXY_HEADERS_PROXY_BASIC_AUTH=yourID:yourPass
```

en win10:
```bat
set https_proxy=http://yourID:yourPass@yourProxyhost:port/
set no_proxy=localhost,127.0.0.1/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,*.local,*.yourdomain.com
set K8S_AUTH_PROXY=http://yourProxyhost:port/
set K8S_AUTH_PROXY_HEADERS_PROXY_BASIC_AUTH=yourID:yourPass
REM you can set above variables as environment variables in win10 OS.
```

### 5. Preparar el Nginx ingress controller

Minifabric usa los servicios de ingreso de kubernetes para exponer los puntos finales del nodo Fabric. Sin
ingreso para exponer los puntos finales del nodo Fabric, Fabric solo estará disponible dentro de un kubernetes
clúster que normalmente no es muy útil. Para implementar el controlador Nginx Ingress, uno simplemente
necesita ejecutar el siguiente comando.

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.44.0/deploy/static/provider/cloud/deploy.yaml
```

Consulte el documento aquí[https://kubernetes.github.io/ingress-nginx/deploy/]   para mayor informacion
de Nginx ingress controller

Una vez que se implementa y se ejecuta, debe obtener una dirección IP pública que se necesita para
Configura tu archivo Minifabric spec.yaml.

### 6. Prepare su archivo de especificaciones Minifabric

Cree un archivo yaml llamado `spec.yaml` en el directorio de trabajo de Minifabric. Lo siguiente es un ejemplo

```
fabric:
  cas:
  - "ca1.org0.foodtracking.com"
  - "ca1.org1.foodtracking.com"
  peers: 
  - "peer1.org0.foodtracking.com"
  - "peer2.org0.foodtracking.com"
  - "peer1.org1.foodtracking.com"
  - "peer2.org1.foodtracking.com"
  orderers:
  - "orderer1.foodtracking.com"
  - "orderer2.foodtracking.com"
  - "orderer3.foodtracking.com"
  settings:
    ca:
      FABRIC_LOGGING_SPEC: DEBUG
    peer:
      FABRIC_LOGGING_SPEC: DEBUG
    orderer:
      FABRIC_LOGGING_SPEC: DEBUG
  ### use go proxy when default go proxy is restricted in some of the regions.
  ### the default goproxy
  # goproxy: "https://proxy.golang.org,direct"
  ### the goproxy in China area
  # goproxy: "https://goproxy.cn,direct"
  ### set the endpoint address to override the automatically detected IP address
  endpoint_address: <The public IP address from your ingress controller>
  ### set the docker network name to override the automatically generated name.
  netname: "mysite0"
  ### set the extra optins for docker run command
  # container_options: "--restart=always --log-opt max-size=10m --log-opt max-file=3"
```

Observe el campo `endpoint_address`, que era opcional cuando se implementaba en docker env, pero
ahora es obligatorio para la implementación de Kubernetes. Sin configurar esta entrada, cuando
Minifabric detecta la presencia del archivo `vars/kubeconfig/config`, fallará
el proceso. En este archivo `spec.yaml`, puede personalizar el nodo tal como lo hace
normalmente con la implementación del entorno Docker.


### 7. (opcional) Asigne etiquetas a los nodos para controlar el enlace de pod y nodo.

primero, verifique el nodo y las etiquetas en su k8s.
```
kubectl get node --show-labels
NAME        STATUS   ROLES    AGE    VERSION   LABELS
node1       Ready    <none>   3h12m   v1.19.6  ...
node2       Ready    <none>   3h12m   v1.19.6  ...
```

asigne etiquetas al nodo para controlar el enlace de pod y nodo.
```
# this is a sample, play and decide bindings by yourself

# add label to node
#      all pods in org0 => node1
kubectl label node node1 dock.hlf-dn/org0.foodtracking.com=ok
#      all pods in org1 => node2
kubectl label node node2 dock.hlf-dn/org1.foodtracking.com=ok
#      all ordererer  => node2, excepts orderer1 => node1
kubectl label node node2 dock.hlf-type/orderer=ok
kubectl label node node1 dock.hlf-fqdn/orderer1.foodtracking.com=ok
:

# delete label from node
kubectl label node node1 dock.hlf-dn/org0.foodtracking.com-
kubectl label node node2 dock.hlf-dn/org1.foodtracking.com-
kubectl label node node2 dock.hlf-type/orderer-
kubectl label node node1 dock.hlf-fqdn/orderer1.foodtracking.com-
:
```

Como puede ver arriba, hay tres tipos de etiquetas involucradas para controlar el nodo de destino del pod.

* Tipo A (mas fuerte;  dock.hlf-fqdn/*)
   - Puedes controlar completamente, una por una.
   - la palabra que sigue a 'dock.hlf-fqdn/' depende de su 'spec.yaml'.
* Tipo B (segunda;     dock.hlf-type/*)
   - puedes controlar tipo por tipo.
   - las etiquetas definidas son las siguientes:
       - dock.hlf-type/peer:     todos los pods enumerados en 'pares:' de spec.yaml
       - dock.hlf-type/orderer:  todos los pods enumerados en 'orderer:' de spec.yaml
       - dock.hlf-type/ca:       todos los pods enumerados en 'cas:' de spec.yaml
       - dock.hlf-type/couchdb:  todos los pods de back-end para peers solo si 'minifab ... -s couchdb' es sospecha
* Tipo C (tercera;        dock.hlf-dn/*)
   - puedes controlar dominio por dominio.
   - la palabra que sigue a 'dock.hlf-dn/' depende de su 'spec.yaml'.

* nota: el etiquetado de nodos para couchdb necesita un poco de cuidado como el siguiente ejemplo:
   - dock.hlf-fqdn/peer1.org0.foodtracking.com.couchdb=ok   ('.couchdb' adjunto al final del fqdn del peer frontend).
   - dock.hlf-dn/org0.foodtracking.com=ok controla couchdb, así como peer y CA.

* Puede asignar varias etiquetas a un nodo (también se permite mezclar).
* después de la implementación de los pods, puede comprobar los resultados de vinculación mediante ```kubectl get pod -A -o wide```
* esta función SOLO funciona SI asignó etiquetas ANTES de implementar la red Fabric.

* NOTA: k8s despliega un pod de la manera original como antes, en los siguientes casos:
  - si la etiqueta correspondiente no está asignada en ningún nodo.
  - si el nodo de destino alcanzó el límite máximo de pods por nodo.

### 8. Deploy Fabric network onto your Kubernetes cluster

Una vez que haya realizado todos los pasos anteriores, puede ejecutar el comando `minifab up` para obtener su
Red Fabric que se ejecuta en el clúster de Kubernetes.

```
   minifab up -e true
```

Observe el indicador de línea de comando `-e` que ahora también se requiere por la misma razón que
la configuración `endpoint_address` en el archivo `spec.yaml`

### 9. (optional) Deploy Fabric network onto Kubernetes with Fabric Operator

Para implementar con Fabric Operator, incluya el indicador `-a` del entorno de destino y especifique `K8SOPERATOR`.

```
   minifab up -e true -a K8SOPERATOR
```
Con Fabric Operator en ejecución, es fácil implementar nodos en la red. Primero, cree un directorio nodespecs dentro del directorio vars `vars/nodespecs` y luego agregue los archivos de especificaciones de los nodos que desea implementar en nodespecs.

Ahora simplemente ejecuta la operación `deploynodes`:

```
   minifab deploynodes
```

Esta operación clasificará e implementará las especificaciones en orden según su tipo. Deploynodes priorizará los nodos por orden de `nodecert`, `ca`, `orderer`, `peer`, `chaincode`, `agent` y, por último, `console`.

### 10. Remove Fabric network from your Kubernetes cluster

Para eliminar todo, incluido el almacenamiento persistente creado durante la implementación,
simplemente puede ejecutar el viejo y buen comando `minifab cleanup`:

```
   minifab cleanup
```

### 11. How about other operations?

Minifabric admite todas las operaciones en el clúster de Kubernetes al igual que lo hace
todas las operaciones de Fabric como en Docker env. Si desea unirse a un canal, instale
un código de cadena, etc., haces exactamente lo mismo. Por ejemplo, para crear un nuevo canal, ejecute
el siguiente comando:

```
   minifab create -c funchannel
```

Para unir pares definidos en `spec.yaml` al canal actual, ejecute este comando:

```
   minifab join
```

Para instalar un código de cadena en todos los nodos definidos en el archivo `spec.yaml`, ejecute este comando.
```
   minifab install -n mychaincode
```
Solo para asegurarse de que la fuente de su código de cadena esté en `vars/chaincode/mychaincode`
directorio.

Cualquier otro comando que no se haya discutido anteriormente funciona exactamente de la misma manera que en
Entorno Docker.